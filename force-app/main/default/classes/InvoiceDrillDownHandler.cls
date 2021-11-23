public with sharing class InvoiceDrillDownHandler {
  
    @AuraEnabled
    public static String getBillingAccNum(String billAccId)
    {
        system.debug('Bill Account ID' +billAccId);
        String billAccNum ='';
        List<Billing_Account__c> billAccList =[SELECT  Billing_Account_Number__c FROM Billing_Account__c WHERE Id =: billAccId];
        billAccNum = billAccList[0].Billing_Account_Number__c;
        system.debug(' return bill Acc Num' + billAccNum);
        return billAccNum;
        
    }
}