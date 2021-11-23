/**
* @Story : EDGE-53653
*/
public with sharing class APTPS_FundTransactionTriggerHandler {

    public void afterUpdate(Map<Id,Fund_Transaction__c> oldMap, Map<Id,Fund_Transaction__c> newMap){
        List<Id> listOfIds = new List<Id>();
        List<Fund_Transaction_Running_Balance__c> listOfFundTransactionBalanceIds = new List<Fund_Transaction_Running_Balance__c>();
        List<Fund_Transaction_Running_Balance__c> listOfFundTransactionBalance = new List<Fund_Transaction_Running_Balance__c>();
        ID redemptionTransactionRecordTypeId = Schema.SObjectType.Fund_Transaction__c.getRecordTypeInfosByName().get('Redemption Transaction').getRecordTypeId();
		for(Fund_Transaction__c fundTransaction : newMap.values()){
            if(redemptionTransactionRecordTypeId.equals(fundTransaction.RecordTypeId) &&
               (('Approval Required'.equals(fundTransaction.APTPS_Fund_Approval_Status__c) && 'Pending Approval'.equals(oldMap.get(fundTransaction.Id).APTPS_Fund_Approval_Status__c))
                || (fundTransaction.isFTBRecordCreated__c && 'Rejected'.equals(fundTransaction.APTPS_Fund_Approval_Status__c) && 'Pending Approval'.equals(oldMap.get(fundTransaction.Id).APTPS_Fund_Approval_Status__c)))){
                  listOfIds.add(fundTransaction.Id);  
                }
        }
        if(!listOfIds.isEmpty()){
            for(Fund_Transaction_Running_Balance__c fundTransactionBalance : [SELECT Id, CreatedDate, Fund__c, Fund_Transaction__c, Transaction_Amount__c FROM Fund_Transaction_Running_Balance__c where Fund_Transaction__c in :listOfIds]){
                listOfFundTransactionBalanceIds.add(fundTransactionBalance);
                for(Fund_Transaction_Running_Balance__c fundTransactionBalanceUpdate : [SELECT Id, Fund__c, Current_Balance__c FROM Fund_Transaction_Running_Balance__c where Fund__c = :fundTransactionBalance.Fund__c and CreatedDate > :fundTransactionBalance.CreatedDate]){
                    fundTransactionBalanceUpdate.Current_Balance__c +=  fundTransactionBalance.Transaction_Amount__c;
                    listOfFundTransactionBalance.add(fundTransactionBalanceUpdate);
                }
            }
        }
        if(!listOfFundTransactionBalance.isEmpty()){
            update listOfFundTransactionBalance;
        }
		if(!listOfFundTransactionBalanceIds.isEmpty()){
            delete listOfFundTransactionBalanceIds;
        }
    }
    
}