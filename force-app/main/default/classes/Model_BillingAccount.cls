/*************************************************************************************************
Name : Model_BillingAccount
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             1-july-2020        EDGE-147513  (new)
===============================================================================================================================
***************************************************************************************************/

public with sharing class Model_BillingAccount{
   
     /*  
     * Method Name : getConfigMap
     * Input Parameter 1 : accountId
     * Return Parameter : returns Billiing acc map
     * Owner : shubhi V
     * Jira : EDGE-147513
    */
    public static Map<String,Billing_Account__c> getBillingAccountOnStatus(String accountId ,Set<String> billingAccStatusSet){
        if(String.isNotBlank(accountId) && billingAccStatusSet !=null && billingAccStatusSet.size()>0){
            return new Map<String,Billing_Account__c>([Select id,
            Billing_Account_Number__c,
            Account__c,Status__c 
            from Billing_Account__c 
            where 
            Account__c=:accountId and Account__c!=null 
            AND Status__c IN:billingAccStatusSet]);
            }else{
            return new Map<String,Billing_Account__c>();
        }
    }
    
}