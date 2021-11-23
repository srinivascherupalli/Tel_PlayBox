/*
 @ DEVELOPER : Anil
 @ TEAM: Napier
 @ DESCRIPTION : This class has logics implemented for invocations from NapierTeamOneFundTriggerHandler
 @ EDGE-113060,EDGE-112655
*/
public with sharing class OneFundTriggerHelper {	
    
    public static id committedRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
    public static id accrualOFTRecId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();

    /*
    @ DEVELOPER : Anil
    @ Team : Napier
	@ Method to calculate StartDate and EndDate while inserting OneFund record.
	*/     
    public static void calculateStartDateEndDate(List<OneFund__c> newOneFunds){
        for(OneFund__c newOnefund: newOneFunds){
            if(newOnefund.Contract_Duration__c != null){                
                newOnefund.Start_Date__c = newOnefund.Start_Date__c==null?System.today():newOnefund.Start_Date__c;
                newOnefund.End_Date__c = newOnefund.End_Date__c==null?Date.newInstance(newOnefund.Start_Date__c.year(),newOnefund.Start_Date__c.month() + integer.valueof(newOneFund.Contract_Duration__c),newOnefund.Start_Date__c.day()):newOnefund.End_Date__c;            
            }
        }
    }
    
    /*
    @ DEVELOPER : Anil
    @ Team : Napier
	@ Method to calculate EndDate for OneFund record when Contract Duration is updated.
	*/    
    public static void calculateEndDate(List<OneFund__c> oldFunds, List<OneFund__c> updatedFunds, Map<ID, OneFund__c> oldFundsMap, Map<ID, OneFund__c> updatedFundsMap){
        for(OneFund__c newOnefund: updatedFunds){            
            if(oldFundsMap.get(newOnefund.id).Contract_Duration__c!=null && oldFundsMap.get(newOnefund.id).End_Date__c!=null && (oldFundsMap.get(newOnefund.id).Contract_Duration__c != newOneFund.Contract_Duration__c || oldFundsMap.get(newOnefund.id).Customer_Commitment__c != newOneFund.Customer_Commitment__c)){
                //Calculating EndDate acc to New Contract Duration
                newOnefund.End_Date__c = Date.newInstance(oldFundsMap.get(newOnefund.id).End_Date__c.year(),oldFundsMap.get(newOnefund.id).End_Date__c.month() + (integer.valueof(newOneFund.Contract_Duration__c) - integer.valueof(oldFundsMap.get(newOnefund.id).Contract_Duration__c)),oldFundsMap.get(newOnefund.id).End_Date__c.day());            
            }
        }
    }
    
    /*
    @ DEVELOPER : Anil
    @ Method to create New OneFundTransaction record when OneFund Committed record is inserted.
    @ Transaction Amount is calculated based on contract duration, monthly commitment and from OneFund Committed metaData
    @ EDGE-113060
    */
	public static void createNewOneFundTransactionRecord(List<OneFund__c> newOneFunds){
        List<OneFund__c> oneFundListCommitted = new List<OneFund__c>();
        List<OneFund_Transactions__c> oneFundTransactionsList = new List<OneFund_Transactions__c>();            
        string mdtlabel;
        Map<id,string> mdtlabelMap = new Map<id,string>();
        Map<id,string> mdtlabelMap1 = new Map<id,string>();
        for(OneFund__c  fund : newOneFunds){
            if(fund.RecordTypeId == committedRecId && fund.Contract_Duration__c!=null && fund.Customer_Commitment__c!=null){
                oneFundListCommitted.add(fund);
                //Update code by Vidhata as per user Story#EDGE-122646(Monthly Commitment field type changes to picklist. )
                mdtlabel = 'duration'+ integer.valueof(fund.Contract_Duration__c)+ ' commitment'+integer.valueof(fund.Customer_Commitment__c);
                mdtlabelMap.put(fund.id,mdtlabel); 
            }
        }
        Map<string,string> mdtlabelAmountMap = new Map<string,string>();     
        
        for(OneFund_Committed_Calculation__mdt calmdt: [select label,OneFund_Amount__c from OneFund_Committed_Calculation__mdt where label in :mdtlabelMap.values()]){
            mdtlabelAmountMap.put(calmdt.label, calmdt.OneFund_Amount__c); 
        }
        string tranSubtype='Committed OneFund';
        for(OneFund__c  fund1 : oneFundListCommitted){
            string amount = mdtlabelAmountMap.get(mdtlabelMap.get(fund1.id));
            double amt = amount!=null?decimal.valueof(amount):0.00;
            OneFund_Transactions__c fundTransactionRecord = new OneFund_Transactions__c(OneFund__c = fund1.id,RecordTypeId =accrualOFTRecId, Transaction_Amount__c = amt,Transaction_Status__c = 'Active',Sub_Type__c = tranSubtype,Start_Date__c = fund1.Start_Date__c,Expiry_Date__c = fund1.End_Date__c);
            oneFundTransactionsList.add(fundTransactionRecord); 
        } 
        
        if(Schema.sObjectType.OneFund_Transactions__c.fields.Transaction_Amount__c.isAccessible() && Schema.sObjectType.OneFund_Transactions__c.fields.Transaction_Status__c.isAccessible() 
           && Schema.sObjectType.OneFund_Transactions__c.fields.Start_Date__c.isAccessible() && Schema.sObjectType.OneFund_Transactions__c.fields.Expiry_Date__c.isAccessible() ){
               insert oneFundTransactionsList;
        }
	}
}