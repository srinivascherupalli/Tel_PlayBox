/*
* DESCRIPTION :
* When Scheduled, it collects the onefund and onefund transaction records that reach Start & End Date and changes Status accordingly.
* Team : Napier (OneFund)
* AUTHOR : Shivaprasad
* EDGE-205066 09/04/2021 Tandle OneFund transactions of Fund Console
* Shivaprasad Patil      14/07/2021		EDGE-228130: Tech Story: Governance team review updates
*/

global with sharing class ScheduleFundTransactions implements Schedulable{
    Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();    
    id committedRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();//'Committed'
    Id oneFundAccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
    
    global void execute(SchedulableContext sc){
        try{
        List<OneFund_Transactions__c> fundTransList = [SELECT Id,Start_Date__c,Expiry_Date__c,OneFund__r.End_Date__c,OneFund__r.RecordTypeId,Transaction_Status__c FROM OneFund_Transactions__c 
                                                       WHERE (OneFund__r.RecordTypeId =: flexibleRecordId or OneFund__r.RecordTypeId =: committedRecId) AND RecordTypeId =: oneFundAccrualRecordId AND Transaction_Status__c != 'Expired'];
        List<OneFund_Transactions__c> oneFundTransListToUpdate = new  List<OneFund_Transactions__c>();
        Date todaysDate =  System.today();
		
        //Datetime.now().format('yyyy-MM-dd');
        if(fundTransList.size() > 0){
            for (OneFund_Transactions__c fundTransactionRecord: fundTransList){              
                if(fundTransactionRecord.Expiry_Date__c != null && 
                   fundTransactionRecord.OneFund__r.End_Date__c > fundTransactionRecord.Expiry_Date__c && 
                   fundTransactionRecord.Expiry_Date__c == todaysDate && 
                   fundTransactionRecord.OneFund__r.RecordTypeId == flexibleRecordId && 
                   fundTransactionRecord.Transaction_Status__c == 'Active'){
                       System.debug('fundTransactionRecord:::'+fundTransactionRecord.Id);
                       system.debug('fundTransactionRecord.OneFund__r.End_Date__c::'+fundTransactionRecord.OneFund__r.End_Date__c);
                       System.debug('todaysDate'+ todaysDate);
                       fundTransactionRecord.Transaction_Status__c = 'Expired';
                       oneFundTransListToUpdate.add(fundTransactionRecord);
                   }
                else if(fundTransactionRecord.Expiry_Date__c != null && 
                        fundTransactionRecord.OneFund__r.End_Date__c == fundTransactionRecord.Expiry_Date__c  && 
                        fundTransactionRecord.Expiry_Date__c.addMonths(1) == todaysDate &&
                        fundTransactionRecord.OneFund__r.RecordTypeId == flexibleRecordId && 
                        fundTransactionRecord.Transaction_Status__c == 'Active'){
                            
                            System.debug('fundTransactionRecord.Start_Date__c'+fundTransactionRecord.Start_Date__c);
                            System.debug('todaysDate'+ todaysDate);
                            fundTransactionRecord.Transaction_Status__c = 'Expired';
                            oneFundTransListToUpdate.add(fundTransactionRecord);
                        }
                else if(fundTransactionRecord.Expiry_Date__c != null && 
                        fundTransactionRecord.OneFund__r.End_Date__c == fundTransactionRecord.Expiry_Date__c && 
                        fundTransactionRecord.Expiry_Date__c == todaysDate && 
                        fundTransactionRecord.OneFund__r.RecordTypeId == flexibleRecordId){
                            fundTransactionRecord.Transaction_Status__c = 'Active';
                            oneFundTransListToUpdate.add(fundTransactionRecord);
                        }
                else if(fundTransactionRecord.Start_Date__c == todaysDate && fundTransactionRecord.OneFund__r.RecordTypeId == flexibleRecordId && fundTransactionRecord.Transaction_Status__c == 'Pending'){
                    System.debug('fundTransactionRecord.Start_Date__c'+fundTransactionRecord.Start_Date__c);
                    System.debug('todaysDate'+ todaysDate);
                    fundTransactionRecord.Transaction_Status__c = 'Active';
                    oneFundTransListToUpdate.add(fundTransactionRecord);
                }
            }
            
            system.debug('oneFundTransListToUpdate.size()'+oneFundTransListToUpdate.size());
            system.debug('oneFundTransListToUpdate::'+oneFundTransListToUpdate);
            //update oneFundTransListToUpdate;
			
			if(oneFundTransListToUpdate != null && !oneFundTransListToUpdate.isEmpty()){
			Database.SaveResult[] updateResultList = Database.update(oneFundTransListToUpdate);
			for (Database.SaveResult sr : updateResultList) {
				if (!sr.isSuccess()) {
					
					System.debug('Issue in scheduling records update:'+sr.getErrors());
				}
			}
			}//End If
			
        }
	}catch(Exception ex){new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'One Fund','ScheduleFundTransactions', '', '', ex.getMessage(), 'Scheduling of Transaction Failed',false);}
    }
}