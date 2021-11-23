/*
 * AUTHOR : Shivaprasad
 * DESCRIPTION : EDGE-217670
*/

public class OneFundTransactionTriggerHandler {

    public void handleAfterInsertEvents(Set<Id> transactionIds){

		List<OneFund_Transactions__c> toUpdateTrans = new List<OneFund_Transactions__c>();
        List<OneFund_Transactions__c> toUpdateTransNoFAActive = new List<OneFund_Transactions__c>();
			 
		system.debug('trigger.newmap.keyset()::'+transactionIds);
		Map<String,List<OneFund_Transactions__c>> mapOfAccountIdWithTransactions=new  Map<String,List<OneFund_Transactions__c>>();
        
        for(OneFund_Transactions__c transactions: [SELECT OneFund__r.CIDN__c FROM OneFund_Transactions__c where Id IN :transactionIds and Sub_Type__c = 'Legacy Fund Transfer']){
			system.debug('transactions::'+transactions);
			if(mapOfAccountIdWithTransactions.containsKey(transactions.OneFund__r.CIDN__c)){
				List<OneFund_Transactions__c> records=mapOfAccountIdWithTransactions.get(transactions.OneFund__r.CIDN__c);
				records.add(transactions);
                mapOfAccountIdWithTransactions.put(transactions.OneFund__r.CIDN__c,records);
			}else{
				mapOfAccountIdWithTransactions.put(transactions.OneFund__r.CIDN__c,new List<OneFund_Transactions__c> {transactions});
			}
        }

		for(csconta__Frame_Agreement__c frameAgreement:[SELECT  csconta__Status__c, csconta__effective_end_date__c,csconta__Account__c FROM csconta__Frame_Agreement__c WHERE csconta__Status__c = 'Active' and csconta__Account__c IN: mapOfAccountIdWithTransactions.keyset()]){	
			system.debug('mapOfAccountIdWithTransactions.keyset()::'+mapOfAccountIdWithTransactions.keyset());
            system.debug('frameAgreement::'+frameAgreement);
          
               for(OneFund_Transactions__c tempTrans:mapOfAccountIdWithTransactions.get(frameAgreement.csconta__Account__c)){
                tempTrans.Expiry_Date__c = frameAgreement.csconta__effective_end_date__c.Date();
                toUpdateTrans.add(tempTrans);
			} 
		}

		system.debug('toUpdateTrans::'+toUpdateTrans);
        
        if(toUpdateTrans.isEmpty()){
             for(OneFund_Transactions__c transactions: [SELECT Sub_Type__c,OneFund__r.CIDN__c,Expiry_Date__c FROM OneFund_Transactions__c where Id IN :transactionIds and Sub_Type__c = 'Legacy Fund Transfer']){
                 transactions.Expiry_Date__c = system.today().addMonths(12);
                 toUpdateTransNoFAActive.add(transactions);
             }
            update toUpdateTransNoFAActive;
        }
        else{
            update toUpdateTrans;        
		}
		
		
    }
}