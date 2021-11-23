/*
* @Author : Shubhi
* @Date : 12 March 2020
* @Desc : RateMatrixForNGUCController for display rate and discount data   
* @Jira : Edge-133882 new component 
* @testclass : RateMatrixForNGUCControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1           shubhi              30/3/2020   EDGE-140157
1           shubhi              30/3/2020   EDGE-140157 updated remainig term formula and status field
2.          shubhi              23/4/2020   Edge-120919 added Mode for nguc consumption based model
3.      Shubhi              22/5/2020       EDGE-146184
4.          Kamlesh             29/10/2020  EDGE-185639 creating a wrapper for ExpectedSios and send it back to component
5.          Vivek               18/01/2021  EDGE-189344 Rate Card Changes for NGUC
6.          Payal               11/02/2020  EDGE-203443 updated rateCardId for RCL
7.          Jagadeswary         17/03/2021  EDGE-207998 Rate card changes to retrieve from commercial products
===============================================================================================================================
*/
public with sharing class RateMatrixForNGUCController {
    Public static RetrieveRateCard.PriceItemWrapper wrappedLineItems;  // EDGE-189344 @Vivek

  /*
--------------------------------------------------------------------------------------------------
# method to fetch rate card  and discount data this method gets call from lightning comp
# Edge-133882
# Author: shubhi
Edge-120919 --> added mode as parameter
--------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static RateDiscountCardDTO getRateCard_Discounts(String callingPlan,String offerId,String solutionId,String changeType,String guid,String Mode,String jsonsoiString){
        //EDGE-207998 start
        List<RateCardSIOWrapper.wrapSIO> lstSIOs = new List<RateCardSIOWrapper.wrapSIO>();
        List <DiscountDTO> discountDTOList = new List <DiscountDTO> ();
        Map<String,RateCardSIOWrapper.wrapSIO> mPlanRateSIO = new Map<String,RateCardSIOWrapper.wrapSIO>();
        Map <String,List<ChargeRateCardDTO>> RateCardMap = new Map <String,List<ChargeRateCardDTO>>();  
        RateDiscountCardDTO rateDiscountCard=new RateDiscountCardDTO();
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        List<String> allKeyToSort = new List<String>();
        Map <String,List<ChargeRateCardDTO>> rateCardMapSorted = new Map <String,List<ChargeRateCardDTO>>(); 
        Boolean discountEligible = false;
        Id commercialProductVariantId;
        Id commercialProductMasterId;
        try{
            if(changeType!='Modify')
                discountDTOList=getDiscountdata();
            else
                discountDTOList=fetchModifyDiscountData(callingPlan,solutionId,guid);
            
            discountEligible = discountDTOList.size() > 0 ? true : false;

            if(string.isNotBlank(jsonsoiString)){
                lstSIOs = (List<RateCardSIOWrapper.wrapSIO>) JSON.deserialize(jsonsoiString, List<RateCardSIOWrapper.wrapSIO>.class);
            }
            for(RateCardSIOWrapper.wrapSIO objSIOs :lstSIOs){
                mPlanRateSIO.put(objSIOs.rateGroupIdentifier,objSIOs);
            } 

            for(cspmb__price_item__c priceItem:  [Select Id, cspmb__Master_Price_item__c from cspmb__Price_Item__c 
                                                    where Check_todays_date__c = TRUE AND
                                                    cspmb__Is_Active__c = TRUE AND
                                                    Offer_Id__c =: offerId AND
                                                    Mode__c =: Mode AND
                                                    Plan__c =: callingPlan]){
                commercialProductVariantId = priceItem.Id;  
                commercialProductMasterId = priceItem.cspmb__Master_Price_item__c;  
            }
            rateCardLineList = RateCardHelper.getRateCardData(commercialProductVariantId,commercialProductMasterId,solutionId);
            for( cspmb__Rate_Card_Line__c rcl: rateCardLineList){
                ChargeRateCardDTO rateCardDto = RateCardHelper.getRateCardJsonData(rcl,mPlanRateSIO,discountEligible);
                if(rateCardMap.containskey(rateCardDto.rateCardName)){
                    List<ChargeRateCardDTO> temp = rateCardMap.get(rateCardDto.rateCardName);
                    temp.add(rateCardDto);
                    rateCardMap.put(rateCardDto.rateCardName,temp);
                }
                else{
                    List<ChargeRateCardDTO> temp = new List<ChargeRateCardDTO>();
                    temp.add(rateCardDto);
                    rateCardMap.put(rateCardDto.rateCardName,temp);
                }
            }

            allKeyToSort.addAll(RateCardMap.keySet());
            allKeyToSort.sort();  

            for( String s : allKeyToSort ){
                RateCardMapSorted.put(s,RateCardMap.get(s));
            }
            if(RateCardMap.size() > 0 ){
                rateDiscountCard.RateCardMap=RateCardMapSorted;
            }
            rateDiscountCard.discountDTOList=discountDTOList;

        }catch(Exception e){
           throw new AuraHandledException('An exception occured - '+e.getMessage()+':'+e.getLineNumber());
        }
        return rateDiscountCard;
        //EDGE-207998 end
    }


    /*--------------------------------------------------------------------------------------------------
# method to EAP  promotion for nguc voice
# Edge-133882
# Author: shubhiv 
Edge-120919 --> added mode as parameter
--------------------------------------------------------------------------------------------------*/
@AuraEnabled
    public static Map <String,List<ChargeRateCardDTO>> getRateCardData(String callingPlan,String offerId,List < DiscountDTO > discountDTOList,String Mode, Map<String,RateCardSIOWrapper.wrapSIO> mJSONRateMatrix){
        List<String> rateCardCodeList=DiscountConstants.getChargeIdentifier();
        Map<String,String> RatecardNamemap=DiscountConstants.getRateCardNameMap(); 
        Map <String,List<ChargeRateCardDTO>> RateCardMap = new Map <String,List<ChargeRateCardDTO>>();
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
         // EDGE-189344 @Vivek : START
         wrappedLineItems  =  RetrieveRateCard.getLinesFromCPGeneric(callingPlan,Mode, offerId);

        if ( wrappedLineItems != NULL && wrappedLineItems.rateCardLinesWrap.size() > 0 ) {
                rateCardLineList    =         wrappedLineItems.rateCardLinesWrap;
                // EDGE-189344 @Vivek : END
               
        }else{
               rateCardLineList     =    RetrieveRateCard.fetchRelatedLines( new Set<String>() , rateCardCodeList );
             //String RateLinequery =  Model_RateCardLineItem.getRelatedLines( offerId , new Set<String>() , rateCardCodeList );
             //rateCardLineList = Database.query(RateLinequery);
              /*  rateCardLineList    =       [Select id,name,Check_todays_date__c,toUnit__c,fromUnit__c,cspmb__Rate_Card__c,rateLineGroupIdentifier__c,cspmb__rate_value__c,cspmb__Rate_Card_Line_Unit__c,cspmb__Rate_Card__r.Offer_Id__c,cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c,cspmb__Rate_Card__r.Check_todays_date__c,External_Id__c FROM  cspmb__Rate_Card_Line__c WHERE cspmb__Rate_Card__r.Offer_Id__c=:offerId AND cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c IN :rateCardCodeList AND Check_todays_date__c=true order by fromUnit__c ASC]; */
        }

        if(rateCardCodeList!=null &&  String.isNotBlank(offerId)){

            for( cspmb__Rate_Card_Line__c rcl: rateCardLineList ){  ///EDGE-146184 added todays date check

                ChargeRateCardDTO rateCardDto=new ChargeRateCardDTO();
                List < ChargeRateCardDTO > ChargeRateCardDTOList = new List < ChargeRateCardDTO > ();
                system.debug(rcl.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c+'--'+rcl.rateLineGroupIdentifier__c+'--'+callingPlan+Mode);
                if((rcl.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c==DiscountConstants.Voice_Code && rcl.rateLineGroupIdentifier__c==callingPlan+Mode) || String.IsBlank(rcl.rateLineGroupIdentifier__c) ){
                    rateCardDto.rateCardCode=rcl.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
                   // if(!masterCPList.isEmpty()){
                    // EDGE-189344 @Vivek ; ADD A Bill description instead of name in NGUC Product
                    if( wrappedLineItems != null && wrappedLineItems.rateCardLinesWrap.size() > 0 ){
                        system.debug( rcl.cspmb__Rate_Card__r.RateCard_Bill_Description__c);
                        rateCardDto.rateCardName = rcl.cspmb__Rate_Card__r.RateCard_Bill_Description__c;
                    }
                    else{
                    rateCardDto.rateCardName=(RatecardNamemap!=null && RatecardNamemap.size()>0 && RatecardNamemap.containskey(rateCardDto.rateCardCode))? RatecardNamemap.get(rateCardDto.rateCardCode) : '';
                    }
                    rateCardDto.discountEligibility=discountDTOList!=null && discountDTOList.size()>0? true : false;
                    rateCardDto.rangeFrom=(rcl.fromUnit__c == null)?0:rcl.fromUnit__c;
                    rateCardDto.rangeTo=rcl.toUnit__c;
                    rateCardDto.recurringCharge=String.Valueof(rcl.cspmb__rate_value__c);
                    rateCardDto.rateCardId = rcl.External_Id__c;
                    rateCardDto.isSIODisabled = true;
                    if(mJSONRateMatrix.containsKey(rateCardDto.rateCardName)){
                       rateCardDto.expectedSIO = mJSONRateMatrix.get(rateCardDto.rateCardName).expectedSIO;
                       rateCardDto.actualSIO = mJSONRateMatrix.get(rateCardDto.rateCardName).actualSIO;
                       rateCardDto.isSIODisabled = false;
                    }
                    if(RateCardMap!=null && RateCardMap.size()>0 && RateCardMap.containskey(rateCardDto.rateCardName)){
                        ChargeRateCardDTOList.addAll(RateCardMap.get(rateCardDto.rateCardName));
                        ChargeRateCardDTOList.add(rateCardDto);
                        RateCardMap.put(rateCardDto.rateCardName,ChargeRateCardDTOList);
                    }else{
                        ChargeRateCardDTOList.add(rateCardDto);
                        RateCardMap.put(rateCardDto.rateCardName,ChargeRateCardDTOList);
                    }
                }else if(rcl.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c!=DiscountConstants.Voice_Code){
                    rateCardDto.rateCardCode=rcl.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
                    if ( wrappedLineItems != NULL && wrappedLineItems.rateCardLinesWrap.size() > 0 ) {
                        rateCardDto.rateCardName = rcl.cspmb__Rate_Card__r.RateCard_Bill_Description__c;
                    }
                    else{
                    rateCardDto.rateCardName=(RatecardNamemap.size()>0 && RatecardNamemap.containskey(rateCardDto.rateCardCode))? RatecardNamemap.get(rateCardDto.rateCardCode) : '';

                    }
                    rateCardDto.discountEligibility=discountDTOList.size()>0? true : false;
                    rateCardDto.rangeFrom=rcl.fromUnit__c;
                    rateCardDto.rangeTo=rcl.toUnit__c;
                    rateCardDto.recurringCharge=String.valueOf(rcl.cspmb__rate_value__c);
                    rateCardDto.rateCardId = rcl.External_Id__c;
                    rateCardDto.isSIODisabled = true;
                    if(mJSONRateMatrix.containsKey(rateCardDto.rateCardName)){
                       rateCardDto.expectedSIO = mJSONRateMatrix.get(rateCardDto.rateCardName).expectedSIO;
                       rateCardDto.actualSIO = mJSONRateMatrix.get(rateCardDto.rateCardName).actualSIO;
                       rateCardDto.isSIODisabled = false;
                    }
                    if(RateCardMap!=null && RateCardMap.size()>0 && RateCardMap.containskey(rateCardDto.rateCardName)){
                        ChargeRateCardDTOList.addAll(RateCardMap.get(rateCardDto.rateCardName));
                        ChargeRateCardDTOList.add(rateCardDto);
                        RateCardMap.put(rateCardDto.rateCardName,ChargeRateCardDTOList);
                    }else{
                        ChargeRateCardDTOList.add(rateCardDto);
                        RateCardMap.put(rateCardDto.rateCardName,ChargeRateCardDTOList);
                    }
                }
            }
        }
        // EDGE-189344 @Vivek : START
        system.debug('check::::'+RateCardMap);
        List<String> allKeyToSort = new List<String>();
        allKeyToSort.addAll(RateCardMap.keySet());
        allKeyToSort.sort();                

        Map <String,List<ChargeRateCardDTO>> RateCardMapSorted = new Map <String,List<ChargeRateCardDTO>>(); 

        for( String s : allKeyToSort ){
            RateCardMapSorted.put(s ,RateCardMap.get(s) );
        }
        // EDGE-189344 @Vivek : END
        system.debug('RateCardMapSorted '+RateCardMapSorted);
        return RateCardMapSorted;
    }
/*--------------------------------------------------------------------------------------------------
# method to EAP  promotion for nguc voice
# Edge-133882
# Author: shubhi
--------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<DiscountDTO> getDiscountdata(){
        List < DiscountDTO > discountDTOList = new List < DiscountDTO > ();
        Set<String> businessIdSet=DiscountConstants.VoicePromoBUSINESSIDset;
        if(businessIdSet!=null && !businessIdSet.isEmpty()){
            for(cspmb__Discount_Level__c dl:fetchApplicablePromotions(businessIdSet)){
                DiscountDTO dto=ShowPromotionAndDiscountHandlerClass.getDiscounTDTOData(dl);
                discountDTOList.add(dto);
            }
        }
        return discountDTOList;
    }

    // method to fetch discount level data 
    public static List<cspmb__Discount_Level__c> fetchApplicablePromotions(Set<String> businessIdSet){
        List<cspmb__Discount_Level__c> applicablePromotionsList = new List<cspmb__Discount_Level__c >();
        if(businessIdSet!=null && !businessIdSet.isEmpty()){
            for(cspmb__Discount_Level__c dl:[SELECT Id,cspmb__Discount__c,cspmb__duration__c,Check_todays_date__c,
                       Is_Delegated__c,cspmb__Discount_Type__c, Business_ID__c,Description__c, name,
                       is_Unlimited__c,Effective_Start_Date__c,Effective_End_Date__c FROM cspmb__Discount_Level__c  WHERE Business_ID__c IN :businessIdSet 
                       AND Check_todays_date__c = true AND Is_Delegated__c=false AND Account__c=null]){
                applicablePromotionsList.add(dl);
            }
        }
        return applicablePromotionsList;
    }
/*--------------------------------------------------------------------------------------------------------------
# method to fetch Pricing MSresponse Object for NGUC and charge line item this to be run only in case of macd
# EDGE-140157
# Author: shubhi
----------------------------------------------------------------------------------------------------------------*/
    public static List<DiscountDTO> fetchModifyDiscountData(String callingPlan,String solutionId,String guid){
        Map<String,Discount_Line_Item__c> dliMap = new Map<String,Discount_Line_Item__c>();
        String cliId='';
        List<DiscountDTO> dliList=new List<DiscountDTO>();
        system.debug('@@@solutionId@@'+solutionId);
        
        
        system.debug('@@@guid@@'+guid);
        if(String.isNotBlank(solutionId) &&  String.isNotBlank(guid)){
            for(Discount_Line_Item__c dli:[SELECT Id,name,description__c,isUnlimited__c,
                                           duration__c,BusinessID__c,discountType__c,
                                           discountEndDate__c,discountClass__c,
                                           chargeInstance__c,chargeInstance__r.solutionId__c,
                                           chargeInstance__r.guid__c,actionCode__c,appliedDate__c,discountValue__c 
                                           FROM Discount_Line_Item__c WHERE 
                                           chargeInstance__r.solutionId__c=:solutionId AND chargeInstance__r.guid__c=:guid]){
                dliMap.put(dli.BusinessID__c,dli);
                if(String.IsBlank(cliId))
                    cliId=dli.chargeInstance__c;
            }
            system.debug('@@@dliMap@@'+dliMap);
            if(cliId!=null && String.IsNotBlank(cliId) && dliMap!=null && !dliMap.isEmpty()){
            PricingMSResponseObject__c msPricing=new PricingMSResponseObject__c();
             msPricing=[SELECT Id,areAllDiscountsElapsed__c,CLI_Instance_ID__c,ResponsePayload__c,      
                                                    RemainingTerm__c FROM PricingMSResponseObject__c  
                                                    WHERE CLI_Instance_ID__c = :cliId order By lastmodifiedDate DESC limit 1];
                system.debug('@@@msPricing@@'+msPricing);               
                if(msPricing!=null && !msPricing.areAllDiscountsElapsed__c){
                    for(Discount_Line_Item__c dl:dliMap.values()){
                        DiscountDTO dto=new DiscountDTO();
                        dto.discountName=dl.name;
                        dto.description =dl.Description__c==null ? '' : dl.Description__c;
                        dto.discDuration =dl.duration__c;
                        dto.promotionID = dl.BusinessID__c==null ? '' : dl.BusinessID__c;
                        dto.DiscountType = dl.discountType__c==null ? '' : dl.discountType__c;
                        dto.discAmount=dl.discountValue__c==null?'':dto.DiscountType=='Amount'?'$'+String.valueOf(dl.discountValue__c):dto.DiscountType=='Credit Months'||dto.DiscountType.contains('Percent') ?String.valueOf(dl.discountValue__c)+'%':String.valueOf(dl.discountValue__c);
                        system.debug('Applieddate-->'+dl.appliedDate__c);
                        dto.initialActivationDate=dl.appliedDate__c==null?'':String.valueOf(dl.appliedDate__c.day())+' '+String.valueOf(ShowPromotionAndDiscountHandlerClass.calculateMonth(dl.appliedDate__c.month()))+' '+String.valueOf(dl.appliedDate__c.year());
                        dto.remainingTerm =dl.appliedDate__c==null?'':String.valueof(Date.today().monthsBetween(dl.appliedDate__c.addMonths(Integer.valueof(dl.duration__c)))); // updated formula for status EDGE-140157
                        dto.status=dl.actionCode__c; // updated field for status EDGE-140157
                        dliList.add(dto);
                    }
                }
            }
        }
        

        system.debug('@@@dliList@@'+dliList);
        return dliList;
    }
    

}