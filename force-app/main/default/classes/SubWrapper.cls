/*
===============================================================================================================================
Class : ShowSubscriptionsOnMACButtonController
Developer Name : SubWrapper
Test Class : ShowSubscriptionsOnMACButtonControllerrTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        Shubhi Vijayvergia  21/3/2018     Edge-53882 MAC page for Sim Replacement for Assurance service agent Profile
2.        Mladen              24/05/2019    No change - need the class to deploy EDGE-77981 NBN Story
3.        Vaibhav             21/11/2019    EDGE-98386  
4.        Vaibhav             27/05/2020    EDGE-138655
5.        Ankit Goswani       31/05/2020    EDGE-165020 added ExistingSIMType,RequestedSIMType
6.        Ankit Goswami       31/08/2020    EDGE-165020 add isValidSIM
7.        Pooja Bhat          26/03/2021    EDGE-205597 added firstActivationDate 
8.        Gokul R             12/04/2021    EDGE-205598 added decimal Rc value and Datetime createddate
===============================================================================================================================
*/
public with sharing class SubWrapper{
   // @auraEnabled
    public SubWrapper(){
        isBillStopped = true;
    }
    @AuraEnabled public Id SubscriptionID{get; set;}
    @AuraEnabled public string subscriptionName{get;set;}
    @AuraEnabled public Id SiteID{get; set;}
    @AuraEnabled public String accessType{get; set;}//EDGE-77981
    @AuraEnabled public string siteAddress{get;set;}
    @AuraEnabled public string subscriptionNumber{get;set;}
    @AuraEnabled public string status{get;set;}
    @AuraEnabled public string createdBy{get;set;}
    @AuraEnabled public boolean disableRow{get;set;}
    @AuraEnabled public String createdDate{get;set;}
    @AuraEnabled public String totalRC{get;set;}
    @AuraEnabled public String totalOC{get;set;}
    @AuraEnabled public boolean isCWP{get;set;}
    @AuraEnabled public String productDefinitionName{get;set;}
    @AuraEnabled public String ServiceId{get;set;}
    //sr1. for Sim Replacement subscription table
    @AuraEnabled public Boolean SimDispatchedRequired{get;set;}
    @AuraEnabled public Boolean IsDeliveryDetailsDisabled{get;set;}
    @AuraEnabled public String DeliveryContact{get;set;}
    @AuraEnabled public String DeliveryAddress{get;set;}
    @AuraEnabled public String DeliveryContactID{get;set;}
    @AuraEnabled public String DeliveryAddressID{get;set;}
    @AuraEnabled public String SimSerialNumber{get;set;}
    @AuraEnabled public Boolean IsSimSerialNumber{get;set;}
    @AuraEnabled public Boolean isBillStopped{get;set;}
    @AuraEnabled public String suspensionReason{get;set;}//EDGE-91569
    @AuraEnabled public String billingAccount{get;set;} //EDGE-93501
    @AuraEnabled public String MarketOffer{get;set;} //EDGE-98386
    @AuraEnabled public String subNameLink{get;set;}//EDGE-138655
    @AuraEnabled public String ExistingSIMType{get;set;}//EDGE-165020
    @AuraEnabled public String RequestedSIMType{get;set;}//EDGE-165020  
    @AuraEnabled public String ProductOffer{get;set;}//EDGE-165020  
    @AuraEnabled public String responseStausMsg{get;set;}//EDGE-167254
    @AuraEnabled public Boolean isValidSIM {get;set;}//EDGE-165020
    @AuraEnabled public String SimAvailabilityType{get;set;}//EDGE-174221
    @AuraEnabled public String suspensionReasonSummary{get;set;}//DPG-4542
    @AuraEnabled public Map<String, String> suspensionReasonDescriptionCodeMap{get;set;}//DPG-4542
    @AuraEnabled public String firstActivationDate {get;set; } //EDGE-205597
    @AuraEnabled public decimal totalRCVal{get;set;} //EDGE-205598
    @AuraEnabled public datetime createdDateVal{get;set;}//EDGE-205598
    @AuraEnabled public String OrderNumber {get;set;}//EDGE-205903
	@AuraEnabled public String productConfigId {get;set;}
    @AuraEnabled public String serviceNumber {get;set;} //DIGI-13386  
    
}