/*
===============================================================================================================================

Test Class : EDGE-116138 - RateMatrixForManagedServicesController
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        Rohit  14/10/2019   Edge-116138 conroller for Lightining Page to show Rate Card
2.        Venkat 01/11/2019   Edge-117274 Updated the query logic to cater for the generic Tenancy modelling 
=========================================  ======================================================================================
*/

public with sharing class RateMatrixForManagedServicesController {
    
    @AuraEnabled
    public static List<ChargeRateCardDTO> getRateCard(String externalId,String offerId,String vendor){
    List<cspmb__Price_Item__c> returnList= new List<cspmb__Price_Item__c>();
    if(vendor != null && vendor.contains('"')){
            List<String> newvendor = vendor.split('"',2);
            vendor = newvendor[0];
        }
        
        Map<String,Object> numberMap = new Map<String,Object>();
        numberMap.put('externalId', externalId);
        numberMap.put('offerId',offerId);
        numberMap.put('vendor',vendor);
                if (numberMap!= null){
                    returnList = SolutionGetEMSRangeData.getData(numberMap);
                }
        System.debug('returnList--->'+returnList);
        List<ChargeRateCardDTO> chargeRateCardData = new List<ChargeRateCardDTO>();
        Boolean isRangeDTOCreated = false;
        
        Map<String, ChargeRateCardDTO>  resultDTO = new Map<String, ChargeRateCardDTO>();
        
        if (returnList.size()>0 && ! (returnList.isEmpty()))
        {     
            
            for (cspmb__Price_Item__c obj : returnList){   
                ChargeRateCardDTO chargeRate= new ChargeRateCardDTO();
                if (!resultDTO.containsKey(obj.rangeFrom__c)){  
                    chargeRate= new ChargeRateCardDTO();
                }
                else {
                    chargeRate =   resultDTO.get(obj.rangeFrom__c);
                }
                chargeRate.chargeType=obj.Type__c;
                chargeRate.featureLevel=obj.Feature_Level__c;
                chargeRate.techSupport=obj.Technical_Support__c;
                chargeRate.rangeFrom=obj.rangeFrom__c;
                chargeRate.rangeTo=obj.rangeTo__C;
                chargeRate.recurringCharge=obj.cspmb__Recurring_Charge__c;
                chargeRate.externalId=obj.External_Id__c;
                if (obj.External_Id__c.contains('Charge_000851')){
                    chargeRate.type='T-MDM';  
                }
                else if (obj.External_Id__c.contains('Charge_000852')){
                    
                    chargeRate.type='End User Support';    
                }
                
                if (obj.Feature_Level__c == 'Standard' && obj.Technical_Support__c == 'Bus Hrs')
                    chargeRate.rangeSTDBUSCharge=obj.cspmb__Recurring_Charge__c;
                if (obj.Feature_Level__c == 'Standard' && obj.Technical_Support__c == '24X7')
                    chargeRate.rangeSTD24X7Charge=obj.cspmb__Recurring_Charge__c;
                if (obj.Feature_Level__c == 'Advanced' && obj.Technical_Support__c == 'Bus Hrs')
                    chargeRate.rangeADVBUSCharge=obj.cspmb__Recurring_Charge__c;
                if (obj.Feature_Level__c == 'Advanced' && obj.Technical_Support__c == '24X7')
                    chargeRate.rangeADV24X7Charge=obj.cspmb__Recurring_Charge__c;
                chargeRate.vendor = obj.Vendor__c;
                resultDTO.put(obj.rangeFrom__c,chargeRate);
                
                
                
            }
            
        }
        else return null;
        
        System.debug('Final Result DTO Map --->'+resultDTO);
        
        for (ChargeRateCardDTO CRDDTO : resultDTO.values()){
            chargeRateCardData.add(CRDDTO);  
        }
        System.debug('Final Result DTO List --->'+chargeRateCardData);
        return chargeRateCardData;
    }
    /*
    --------------------------------------------------------------------------------------------------
    Enabling for lightening
    --------------------------------------------------------------------------------------------------
    */
    public class ChargeRateCardDTO {
        @AuraEnabled public String chargeType {get;set;}
        @AuraEnabled public String featureLevel {get;set;}
        @AuraEnabled public String techSupport {get;set;}
        @AuraEnabled public Decimal rangeSTDBUSCharge {get;set;}
        @AuraEnabled public Decimal rangeSTD24X7Charge {get;set;}
        @AuraEnabled public Decimal rangeADVBUSCharge {get;set;}
        @AuraEnabled public Decimal rangeADV24X7Charge {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String rangeFrom {get;set;}
        @AuraEnabled public String rangeTo {get;set;}
        @AuraEnabled public Decimal recurringCharge {get;set;}
        @AuraEnabled public String externalId {get;set;}
        @AuraEnabled public String vendor {get;set;}
        
        
        
    }
    
}