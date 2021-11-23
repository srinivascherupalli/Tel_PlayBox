/*  
* @Author : Nikhil Sharma
* @Date   : 05 Aug 2021
* @Desc   : Rate Card for DMS
* @Jira   : DIGI-603  
* @testclass : RateMatrixForDMSControllerTest
*/  
public class RateMatrixForDMSController {
    Public static RetrieveRateCard.PriceItemWrapper wrappedLineItems; 
    private static String correlationId = GuidUtil.NewGuid();
    private static final String CONST_INTERFACENAME = 'RateMatrixForDMSController';
    public static  RateCardDTODMS getRateCardData(String offerId,String jsonsios){
        Boolean excessChargeFlag = false;
        RateCardDTODMS rateCard = new RateCardDTODMS();
        Map<Decimal,Decimal> mapFromToColumnHeader = new Map<Decimal,Decimal>();
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        Map <String,List<ChargeRateCardDTODMS>> RateCardMap = new Map <String,List<ChargeRateCardDTODMS>>();
        Map <String,List<ChargeRateCardDTODMS>> RateCardMapSorted = new Map <String,List<ChargeRateCardDTODMS>>();
        List<RateCardSIOWrapper.wrapSIO> lstSIOs = new  List<RateCardSIOWrapper.wrapSIO>();
        if(String.isNotBlank(jsonsios)){
            lstSIOs = (List<RateCardSIOWrapper.wrapSIO>) JSON.deserialize(jsonsios, List<RateCardSIOWrapper.wrapSIO>.class); 
        }
        system.debug('lstSIOs'+lstSIOs);
        Map<String,RateCardSIOWrapper.wrapSIO> mPlanRateSIO = new Map<String,RateCardSIOWrapper.wrapSIO>();
        for(RateCardSIOWrapper.wrapSIO objSIOs :lstSIOs){
            mPlanRateSIO.put(objSIOs.rateCardName ,objSIOs);
            mPlanRateSIO.put(objSIOs.chargeFrequency ,objSIOs); // added by shashank DIGI-32149
        }
        try{
            wrappedLineItems  =  RetrieveRateCard.getLinesFromCPGeneric(null,null, offerId);
            if ( wrappedLineItems != NULL && wrappedLineItems.rateCardLinesWrap.size() > 0 ) {
                rateCardLineList = wrappedLineItems.rateCardLinesWrap;
            }
            if(!rateCardLineList.isEmpty() && String.isNotBlank(offerId)){
                for( cspmb__Rate_Card_Line__c rcl: rateCardLineList ){
                    ChargeRateCardDTODMS rateCardDto=new ChargeRateCardDTODMS();
                    List <ChargeRateCardDTODMS> ChargeRateCardDTOList = new List < ChargeRateCardDTODMS > ();
                    rateCardDto.rateCardName = rcl.cspmb__Rate_Card__r.RateCard_Bill_Description__c;
                    rateCardDto.rateCardCode=rcl.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
                    rateCardDto.rangeFrom=rcl.fromUnit__c;
                    rateCardDto.rangeTo=rcl.toUnit__c;
                    rateCardDto.recurringCharge=String.valueOf(rcl.cspmb__rate_value__c);
                    rateCardDto.rateCardId = rcl.External_Id__c;
                    rateCardDto.isSIODisabled = true;
                    rateCardDto.chargeFrequency = wrappedLineItems.chargeFrequency; // changes added by shashank DIGI-32149
                    system.debug('charge freq -'+ wrappedLineItems.chargeFrequency);
                    if(mPlanRateSIO.containsKey(rcl.cspmb__Rate_Card__r.RateCard_Bill_Description__c)){
                        RateCardSIOWrapper.wrapSIO mWrapId = mPlanRateSIO.get(rcl.cspmb__Rate_Card__r.RateCard_Bill_Description__c);
                        rateCardDto.expectedSIO = mWrapId.expectedSIO;
                        rateCardDto.actualSIO = mWrapId.actualSIO;
                        rateCardDto.isSIODisabled = false;
                        rateCardDto.rateGroupIdentifier = rcl.cspmb__Rate_Card__r.RateCard_Bill_Description__c;
                    }
                    if(RateCardMap!=null && RateCardMap.size()>0 && RateCardMap.containskey(rateCardDto.rateCardName)){
                        ChargeRateCardDTOList.addAll(RateCardMap.get(rateCardDto.rateCardName));
                        ChargeRateCardDTOList.add(rateCardDto);
                        RateCardMap.put(rateCardDto.rateCardName,ChargeRateCardDTOList);
                    }else{
                        ChargeRateCardDTOList.add(rateCardDto);
                        RateCardMap.put(rateCardDto.rateCardName,ChargeRateCardDTOList);
                    }
                    if(!mapFromToColumnHeader.containskey(rcl.fromUnit__c)){
                        mapFromToColumnHeader.put(rcl.fromUnit__c, rcl.toUnit__c);
                    }
                }
                List<String> allKeyToSort = new List<String>();
                allKeyToSort.addAll(RateCardMap.keySet());
                allKeyToSort.sort(); 
                for( String s : allKeyToSort ){
                    RateCardMapSorted.put(s ,RateCardMap.get(s) );
                }
                rateCard.rateCardMap = RateCardMapSorted;
                rateCard.excessCharge = excessChargeFlag;
                rateCard.mapFromToColumnHeader = mapFromToColumnHeader;
                rateCard.solutionType = 'DMS';
                return rateCard;
            }else{
                throw new AuraHandledException('Please Contact your System Administratior (ERROR : Cannot find metadata for selected offer)'); 
            }
        }catch(Exception e){
            //Exception log
            logException('getRateCardData','',correlationId, e.getMessage(), 'Retrieve DMS rate card data failed',CONST_INTERFACENAME);
            throw new AuraHandledException('Please Contact your System Administratior (ERROR : '+ e+')');
        }
    }
    
    /*----------------------------------------------------------------
Method     : logException
Description: Method to create log exceptions
Author     : Nikhil Sharma
Story      : DIGI-4694 
-------------------------------------------------------------------------------------*/ 
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription,String CONST_INTERFACENAME){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
    public class ChargeRateCardDTODMS {
        @AuraEnabled public String rateCardCode {get;set;}
        @AuraEnabled public String rateCardName {get;set;}
        @AuraEnabled public Decimal rangeFrom {get;set;}
        @AuraEnabled public Decimal rangeTo {get;set;}
        @AuraEnabled public String recurringCharge {get;set;}
        @AuraEnabled public Decimal rateValueInclGST {get;set;}
        @AuraEnabled public Integer expectedSIO {get;set;}
        @AuraEnabled public Integer actualSIO {get;set;}
        @AuraEnabled public Boolean isSIODisabled {get;set;}
        @AuraEnabled public String rateCardId {get;set;}
        @AuraEnabled public String rateGroupIdentifier {get;set;}
        //added by Nikhil as part of DIGI-32149
        @AuraEnabled public String chargeFrequency{get;set;}
        public ChargeRateCardDTODMS(){
            expectedSIO = 0;
            actualSIO = 0;
            chargeFrequency= 'Monthly';
        }
    }
    public class RateCardDTODMS {  
        @AuraEnabled public Map<String,List<ChargeRateCardDTODMS>> rateCardMap{get;set;}
        @AuraEnabled public Boolean excessCharge {get;set;}
        @AuraEnabled public Map<Decimal,Decimal> mapFromToColumnHeader {get;set;}
        @AuraEnabled public String solutionType {get;set;}
    }
}