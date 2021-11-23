/*
===============================================================================================================================
Class : TransitionReviewConfirmWrapper
Developer Name : Rohit
Test Class : TransitionReviewConfirmWrapperTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
public with sharing class TransitionReviewConfirmWrapper{
    @AuraEnabled public String siteId{get; set;}
    @AuraEnabled public string offer{get;set;}
    @AuraEnabled public string legacyTechnology{get; set;}
    @AuraEnabled public String orderType{get; set;}//EDGE-77981
    @AuraEnabled public string siteName{get;set;}
    @AuraEnabled public string locality{get;set;}
    @AuraEnabled public string state{get;set;}
    @AuraEnabled public string fNN{get;set;}
}