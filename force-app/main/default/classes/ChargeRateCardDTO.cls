/*
* @Author : Jagadeswary
* @Date : 17 March 2021
* @Desc : ChargeRateCardDTO wrapper class for Rate card matrix
* @Jira : EDGE-207998 new component 
* @testclass : RateMatrixForNGUCControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1           Jagadeswary        17/3/2021   EDGE-207998 //moved wrapper class from controller

===============================================================================================================================
*/
public class ChargeRateCardDTO {
    @AuraEnabled public String rateCardCode {get;set;}
    @AuraEnabled public String rateCardName {get;set;}
    @AuraEnabled public Boolean discountEligibility {get;set;}
    @AuraEnabled public Decimal rangeFrom {get;set;}
    @AuraEnabled public Decimal rangeTo {get;set;}
    @AuraEnabled public String recurringCharge {get;set;}
    @AuraEnabled public Boolean excessCharge {get;set;}
    @auraEnabled public String capValue {get;set;}
    @AuraEnabled public Integer expectedSIO {get;set;}
    @AuraEnabled public Integer actualSIO {get;set;}
    @AuraEnabled public Boolean isSIODisabled {get;set;}
    @AuraEnabled public String rateGroupIdentifier {get;set;}
    @AuraEnabled public String rateCardId {get;set;}
    public ChargeRateCardDTO(){
        expectedSIO = 0;
        actualSIO = 0;
    }
}