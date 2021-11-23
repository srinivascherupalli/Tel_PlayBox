/*
* @Author : Jagadeswary
* @Date : 17 March 2021
* @Desc : RateCardHelper class for helper methods for RateMatrixForNGUCController
* @Jira : EDGE-207998 new component 
* @testclass : RateMatrixForNGUCControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1           Jagadeswary        17/3/2021   EDGE-207998 //helper class for controller
2           Gokul              13/05/2021   EDGE-207998 - Added Conditions in query to filter out line items based on End date
3.          Vivek              15/05/2021  EDGE-213651 : Show prices from frame agreement if present on basket
===============================================================================================================================
*/
public with sharing class RateCardHelper{       

    //static variable to be used for sio disabling on UI
    public static Map<Id,Boolean> rateCardToSioDisabledMap = new Map<Id,Boolean>();
    //EDGE-213651
    public static  Map<Id, Map<Id, Decimal>> rateCardAndRateValueMap= new Map<Id, Map<Id, Decimal>>();

    //Method to get rate card lines from commercial product id and master id
    public static List<cspmb__Rate_Card_Line__c> getRateCardData(Id commercialProductVariantId,Id commercialProductMasterId , Id solutionId){
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        //EDGE-213651
        if ( solutionId != null ){
            checkFrameAgreement( solutionId );
        }

        if(commercialProductVariantId !=null && commercialProductMasterId !=null){
            //query all rate card association records based on commercial products
            for(cspmb__Price_Item_Rate_Card_Association__c rateCardAssc: [select cspmb__Rate_Card__c,cspmb__Price_Item__c,
                                                                            cspmb__Price_Item__r.cspmb__Master_Price_item__c 
                                                                            from cspmb__Price_Item_Rate_Card_Association__c
                                                                            where cspmb__Price_Item__r.Check_todays_date__c = TRUE AND cspmb__Price_Item__r.cspmb__Is_Active__c = TRUE //EDGE-207998 - Added condition to check today's date
                                                                            and (cspmb__Price_Item__c  =:commercialProductVariantId 
                                                                            or cspmb__Price_Item__c =:commercialProductMasterId)]){
                if(rateCardAssc.cspmb__Price_Item__r.cspmb__Master_Price_item__c != null)                                                              
                    rateCardToSioDisabledMap.put(rateCardAssc.cspmb__Rate_Card__c,false);
                else 
                    rateCardToSioDisabledMap.put(rateCardAssc.cspmb__Rate_Card__c,true);
                
            }
            //return a list of rate card lines from rate card association records from previous query
            rateCardLineList = [select id,cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c,cspmb__Rate_Card__r.Name,
                                fromUnit__c,toUnit__c,cspmb__rate_value__c,cspmb__Rate_Card__r.External_Rate_Row_ID__c,
                                cspmb__Rate_Card__c from cspmb__Rate_Card_Line__c 
                                where cspmb__Rate_Card__c in: rateCardToSioDisabledMap.keyset() and Check_todays_date__c = TRUE ORDER BY fromUnit__c ASC];//EDGE-207998 - Added condition to check today's date
        }                   
        return rateCardLineList;
    }
    public static ChargeRateCardDTO getRateCardJsonData(cspmb__Rate_Card_Line__c rateCardLine,Map<String,RateCardSIOWrapper.wrapSIO> mJSONRateMatrix,Boolean discountEligible){
        //assign values to wrapper class from ratecard lines, json rate matrix
        ChargeRateCardDTO rateCardDto             = new ChargeRateCardDTO();
        rateCardDto.rateCardCode                  = rateCardLine.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
        rateCardDto.rateCardName                  = rateCardLine.cspmb__Rate_Card__r.Name;
        rateCardDto.discountEligibility           = discountEligible;
        rateCardDto.rangeFrom                     = (rateCardLine.fromUnit__c == null)?0:rateCardLine.fromUnit__c;
        rateCardDto.rangeTo                       = (rateCardLine.toUnit__c== null)?0:rateCardLine.toUnit__c;
        // EDGE-213651 Added condition
        if ( rateCardAndRateValueMap.size() > 0 && rateCardAndRateValueMap.containsKey( rateCardLine.cspmb__Rate_Card__c ) 
            &&  rateCardAndRateValueMap.get( rateCardLine.cspmb__Rate_Card__c ).containsKey( rateCardLine.Id ) ) {
                rateCardDto.recurringCharge       = String.Valueof(rateCardAndRateValueMap.get( rateCardLine.cspmb__Rate_Card__c ).get( rateCardLine.Id ));
            }else{
                rateCardDto.recurringCharge       = String.Valueof(rateCardLine.cspmb__rate_value__c);
            }
        rateCardDto.rateCardId                    = rateCardLine.cspmb__Rate_Card__r.External_Rate_Row_ID__c;
        if(!rateCardToSioDisabledMap.isEmpty() && rateCardToSioDisabledMap.containskey(rateCardLine.cspmb__Rate_Card__c))
            rateCardDto.isSIODisabled             = rateCardToSioDisabledMap.get(rateCardLine.cspmb__Rate_Card__c);
        //populate expected and actual sios
        if(mJSONRateMatrix.containsKey(rateCardDto.rateCardCode)){
            rateCardDto.expectedSIO               = mJSONRateMatrix.get(rateCardDto.rateCardCode).expectedSIO;
            rateCardDto.actualSIO                 = mJSONRateMatrix.get(rateCardDto.rateCardCode).actualSIO;
        }
        else{
            rateCardDto.expectedSIO               = 0;
            rateCardDto.actualSIO                 = 0;
        }
        return rateCardDto;
    }

    // EDGE-213651 : Method to check if Basket has agreement and read data from there.
    public static void checkFrameAgreement( Id solutionId ){
        List<Id> soulutionIdList                                	= new List<Id>();
        soulutionIdList.add( solutionId );
        
        Map<Id,Map<Id,Map<Id,Decimal>>> solutionIdIdRateValueMap  = GenerateNegoiatedPayload.getSubscriptionIdRateValueMap( soulutionIdList );
        if ( solutionIdIdRateValueMap.containsKey( solutionId ) ){
        	rateCardAndRateValueMap 								  = solutionIdIdRateValueMap.get( solutionId );
        }  
    }

}