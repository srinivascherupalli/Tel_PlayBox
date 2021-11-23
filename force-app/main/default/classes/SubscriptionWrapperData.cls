/******************************************************************************************************************************
Class Name : SubscriptionWrapperData
Test Class : TestSubscriptionWrapperData
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           19/03/2021    EDGE-199911(New Class)           22.      Sarfraj Ahmad       04/07/2021    DPG-5729                         21.09
*******************************************************************************************************************************/
public with sharing class SubscriptionWrapperData{
    @AuraEnabled
    public String subscriptionName{get; set;}
    @AuraEnabled
    public String subscriptionNumber{get; set;}
    @AuraEnabled
    public String serviceID{get; set;}
    @AuraEnabled
    public String billingAccNumber{get; set;}
    @AuraEnabled
    public String nickname{get; set;}
    @AuraEnabled
    public String Id{get; set;}
    @AuraEnabled
    public String tonBarringStatus{get; set;} // Changes by Sarfraj [DPG-5729] 

}