/*********************************************************************************************************************************
*Class Name      :  ReactivateServiceWrapper
Test Class : ReactivateServiceWrapperTest
author:  Shubhi V
EDGE-EDGE-185011
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.              Shubhi V            15-12-2020          Edge-185856 
2.             Shubhi v             22/04/2021          EDGE-207352 
================================================================================================================================
*/
public with sharing class ReactivateServiceWrapper {
    @AuraEnabled public string serviceNumber {get; set;}
    @AuraEnabled public string subscriptionName {get; set;}
    @AuraEnabled public string subscriptionNumber {get; set;}
    @AuraEnabled public Date disconnectedDate {get; set;}
    @AuraEnabled public string AddonDescription {get; set;} //Edge-185856
    @AuraEnabled public string Id {get; set;}
    @AuraEnabled public Billing_Account__c billingAcc{get; set;} //EDGE-207352
    @AuraEnabled public List<ReactivateServiceWrapper> addondetails{get; set;} //Edge-185856
    
}