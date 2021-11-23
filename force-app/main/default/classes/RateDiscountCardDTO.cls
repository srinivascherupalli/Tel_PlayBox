/*
* @Author : Jagadeswary
* @Date : 17 March 2021
* @Desc : RateDiscountCardDTO wrapper class for Rate card matrix
* @Jira : EDGE-207998 new component 
* @testclass : RateMatrixForNGUCControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1           Jagadeswary        17/3/2021   EDGE-207998 //moved wrapper class from controller

===============================================================================================================================
*/
public class RateDiscountCardDTO {  
    @AuraEnabled public List<DiscountDTO> discountDTOList {get;set;}
    @AuraEnabled public Map<String,List<ChargeRateCardDTO>> RateCardMap{get;set;}
    @AuraEnabled public Map<Decimal,Decimal> mapFromToColumnHeader {get;set;}
}