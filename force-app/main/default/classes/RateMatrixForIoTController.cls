/*
* @Author : Suyash Chiplunkar    
* @Date : 1 July 2020
* @Desc : Rate Card for IOT
* @Jira : DPG-1964 
*/
/***History of Updates
Sr.No.    Developer Name      Date          Story Description 
1         Shresth Dixit                     DPG-2084(Generalised code for TMDM)
2         Shresth Dixit                     DPG-2395(Generalised code for Adaptive Care)
3         Shresth Dixit                     DPG-2745
4         Shresth Dixit                     DPG-2319
5         Vijay                             EDGE-169456
6         Payal                             EDGE-189788 : Added a parameter in getRateCardData and created a wrpper class to desearlize JSON
7         Gokul            11/03/2021       EDGE-205510 -  Update RateGroupIdentifier as Key for the RateCardMap
8         Aruna Aware      16/07/2021       DIGI-1597 - Configure plans/ allowances for shared data plan variants (DPG-5395)
9         Aruna Aware      27/07/2021       DIGI-5330 - In Rate Card, not finding the Excess Usage Rates/MB Column
10        Nikhil Sharma    05/08/2021       DIGI-603 (Rate Card for DMS)
11        Aman Gupta       26/08/2021       DIGI-17715  Defect
12		  Aruna Aware      13/10/2021	    DIGI-31600 - Not finding the pricing values in rate card for the plans of all the three plan variants.
***/ 
/*
--------------------------------------------------------------------------------------------------
# method to fetch rate card  details
# DPG-1964
# Author: Suyash Chiplunkar
--------------------------------------------------------------------------------------------------*/

public with sharing class RateMatrixForIoTController {
    private static String currentSolution;
    public static  Map<Id, Map<Id, Decimal>> rateCardAndRateValueMap= new Map<Id, Map<Id, Decimal>>();
    public static Map<Id, String> rateCardIdPlanMap = new Map<Id, String>();
    @AuraEnabled
    public static RateCardDTOIOT getRateCardData(String callingPlan,String offerId, string commProdId,String jsonsios,String selectplanname){
        //EDGE-189788 : Added as a part of this story
        List<RateCardSIOWrapper.wrapSIO> lstSIOs = new  List<RateCardSIOWrapper.wrapSIO>();
        if(String.isNotBlank(jsonsios)){
           lstSIOs = (List<RateCardSIOWrapper.wrapSIO>) JSON.deserialize(jsonsios, List<RateCardSIOWrapper.wrapSIO>.class); 
        }
        //EDGE-205510 -- Start
        Map<String,RateCardSIOWrapper.wrapSIO> mPlanRateSIO = new Map<String,RateCardSIOWrapper.wrapSIO>();
        for(RateCardSIOWrapper.wrapSIO objSIOs :lstSIOs){
            mPlanRateSIO.put(objSIOs.rateGroupIdentifier,objSIOs);
        }
        //EDGE-205510 -- End
        try{
            //Current solution is extracted on the base of related offerId of the solution
            PopulateRateCardBilling__mdt[] rateMatrixRecord = [SELECT Id,Solution_Type__c FROM PopulateRateCardBilling__mdt WHERE Offer_Id__c = :offerId LIMIT 1];
            if(rateMatrixRecord.size()>0){
                currentSolution = rateMatrixRecord[0].Solution_Type__c;
            }
            RateCardDTOIOT rateCardDTOIOT = new RateCardDTOIOT();
            //rateCardMap represent the plan name and the associated line items list
            Map <String,List<ChargeRateCardDTOIOT>> rateCardMap = new Map <String,List<ChargeRateCardDTOIOT>>();
            //mapFromToColumnHeader contains the from and to volume range value
            Map<Decimal,Decimal> mapFromToColumnHeader = new Map<Decimal,Decimal>();
            if( String.isNotBlank(offerId) && ((String.isNotBlank(callingPlan) && currentSolution=='IOT')||(currentSolution=='TMDM')||(currentSolution=='NGADP')||(currentSolution=='MS' || (currentSolution=='AMMSLC')))){
                /*In case of IoT from getRateCardDataAssociations plan name are fetched from the commercial products which are associated with the rate cards i.e a 
                map for the rate card and associated plan name are created, for other offers plan name are fetched from the rate card name itself*/
                //DIGI-1597 - Configure plans/ allowances for shared data plan variants (DPG-5395) 
                Map<Id, String> rateCardIdPlanMap =(currentSolution=='IOT'|| currentSolution=='MS')?getRateCardDataAssociations(callingPlan, offerId, commProdId, selectplanname):new Map<Id, String>();
                if ((rateCardIdPlanMap != null && !rateCardIdPlanMap.isEmpty()) || (currentSolution=='TMDM')||(currentSolution=='NGADP')||(currentSolution=='AMMSLC')){
                    Set<Id> rateCardIdSet;
                    if(currentSolution=='IOT' || currentSolution=='MS'){
                        rateCardIdSet = rateCardIdPlanMap.keySet();
                        String queryFilter = '%'+callingPlan+'%';
                    }
                    //Query performed to retrieve the rate card line item on the base of offerId, dynamic query is used inorder to conditinally add condition in case when current solution is IoT. 
                    for(cspmb__Rate_Card_Line__c rcl:Database.query('Select cspmb__Rate_Card__r.Name,id,enableSIOCaptureSM__c,name,Check_todays_date__c,'+
                                                                    'toUnit__c,fromUnit__c,cspmb__Rate_Card__c,rateLineGroupIdentifier__c,'+
                                                                    'cspmb__rate_value__c,cspmb__Rate_Card_Line_Unit__c,cspmb__Rate_Card__r.Offer_Id__c,'+
                                                                    'cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c,cspmb__Rate_Card__r.Check_todays_date__c,cspmb__Cap__c ,RateValueInclGST__c,External_Id__c '+ 
                                                                    'FROM  cspmb__Rate_Card_Line__c '+ 
                                                                    'WHERE  cspmb__Rate_Card__r.Offer_Id__c=:offerId '+ 
                                                                    'AND  cspmb__Rate_Card__r.cspmb__Is_Active__c = True '+
                                                                    'AND cspmb__Is_Active__c = true '+
                                                                    (currentSolution=='IOT' || currentSolution=='MS'?'AND cspmb__Rate_Card__c IN :rateCardIdSet ':'')+
                                                                    'AND    Check_todays_date__c=true '+
                                                                    (currentSolution !='IOT' ?'AND cspmb__Is_Active__c = True ' :'') + /*DIGI-17715*/
                                                                    'ORDER By fromUnit__c'))
                    {
                        ChargeRateCardDTOIOT rateCardDto = new ChargeRateCardDTOIOT();
                        rateCardDto.rateCardCode=rcl.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
                            rateCardDto.rangeFrom=rcl.fromUnit__c;
                            rateCardDto.rangeTo=rcl.toUnit__c;
                            rateCardDto.recurringCharge=String.Valueof(rcl.cspmb__rate_value__c);
                          //DIGI-5330 - In Rate Card, not finding the Excess Usage Rates/MB Column
                          rateCardDto.capValue=String.Valueof(rcl.cspmb__Cap__c);
                            rateCardDto.rateCardId = rcl.External_Id__c;
                            if(!mapFromToColumnHeader.containskey(rcl.fromUnit__c)){
                                mapFromToColumnHeader.put(rcl.fromUnit__c, rcl.toUnit__c);
                            }
                        rateCardDto.rateCardName = currentSolution=='IOT'?rateCardIdPlanMap.get(rcl.cspmb__Rate_Card__c).replaceAll(' ', ''):rcl.Name;
                        rateCardDto.rateValueInclGST = rcl.RateValueInclGST__c;
                        
                        rateCardDto.isSIODisabled = true;

                        //EDGE-205510 - Get the SIos value from mPlanRateSIO
                        //Added by Rajesh, Part of display rate cards for Intune Offer
                        if(rcl.enableSIOCaptureSM__c == true){
                            rateCardDto.isSIODisabled = false;
                            rateCardDto.rateGroupIdentifier = rcl.rateLineGroupIdentifier__c;
                        }
                        //DIGI-5330 - In Rate Card, not finding the Excess Usage Rates/MB Column
                         if(mPlanRateSIO.get(rcl.rateLineGroupIdentifier__c) != null){
                            rateCardDto.excessCharge = true;
                            RateCardSIOWrapper.wrapSIO mWrapId = mPlanRateSIO.get(rcl.rateLineGroupIdentifier__c);
                           rateCardDto.expectedSIO = mWrapId.expectedSIO;
                           rateCardDto.actualSIO = mWrapId.actualSIO;
                         }
                        
                        //rateCardMap contains the plan and the associated line items List
                        if(rateCardMap!=null && rateCardMap.size()>0 && rateCardMap.containskey(rateCardDto.rateCardName)){
                            rateCardMap.get(rateCardDto.rateCardName).add(rateCardDto);
                        }else{
                            rateCardMap.put(rateCardDto.rateCardName,new List<ChargeRateCardDTOIOT>{rateCardDto});
                        }
                    }
                }
                
                //solutionType is also used for rate matrix branding
                rateCardDTOIOT.solutionType = currentSolution=='NGADP'?'Adaptive Care':currentSolution;
                if(rateCardMap.isEmpty()){
                    throw new AuraHandledException('Please Contact your System Administratior (ERROR : Data issue)');
                }
                else if(currentSolution=='IOT'){
                    //rateCardDTOIOT.rateCardMap = sortByPlan(rateCardMap);
                }
                else{
                    rateCardDTOIOT.rateCardMap = rateCardMap;
                }
                rateCardDTOIOT.mapFromToColumnHeader = mapFromToColumnHeader;
                return rateCardDTOIOT;
            }
            else{
                throw new AuraHandledException('Please Contact your System Administratior (ERROR : Cannot find metadata for selected offer)'); 
            }
        }
        catch(Exception e){
            throw new AuraHandledException('Please Contact your System Administratior (ERROR : '+ e+')');
        }
    }

    /*
--------------------------------------------------------------------------------------------------
# method to fetch rate card  based on commercial products and it's associations
# DPG-1964
# Author: Suyash Chiplunkar
--------------------------------------------------------------------------------------------------*/
    public static Map<Id, String> getRateCardDataAssociations(String callingPlan,String offerId, String commProdId, String selectplanname){
        Map<Id, String> rateCardIdPlanMap = new Map<Id, String>();
        if(String.isNotBlank(offerId) && (String.isNotBlank(callingPlan) || (currentSolution=='MS' && String.isNotBlank(commProdId)))){
            String queryFilter = '%'+callingPlan+'%';
            for(cspmb__Price_Item_Rate_Card_Association__c rcl: Database.query('SELECT id,cspmb__Price_Item__r.Plan__c,cspmb__Price_Item__r.Name,'+
                                                                             'cspmb__Rate_Card__r.Name,cspmb__Rate_Card__c '+ 
                                                                            'FROM   cspmb__Price_Item_Rate_Card_Association__c '+ 
                                                                            'WHERE  cspmb__Price_Item__r.Check_todays_date__c=true '+  
                                                                            'AND  cspmb__Price_Item__r.Offer_Id__c=:offerId '+
                                                                            'AND cspmb__Price_Item__r.Plan_Type__c=:selectplanname '+
                                                                            (currentSolution == 'MS'?'AND cspmb__Price_Item__r.id=:commProdId ':'')+
                                                                            (currentSolution == 'IOT'?'AND cspmb__Price_Item__r.Plan__c != NULL '+
                                                                             'AND cspmb__Price_Item__r.Commercial_Product_Code__c LIKE :queryFilter':''))) // Removed cspmb__Price_Item__r.cspmb__Price_Item_Code__c And added cspmb__Price_Item__r.Commercial_Product_Code__c:EDGE-169456
                {
                                                                                                            
                   rateCardIdPlanMap.put(rcl.cspmb__Rate_Card__c,rcl.cspmb__Price_Item__r.Plan__c);
                                                                     
                }
        }
        return rateCardIdPlanMap;
    }
    
    /*
--------------------------------------------------------------------------------------------------
# Method to sort Rate Cards based on unit of Memory
# DPG-1964
# Author: Suyash Chiplunkar
--------------------------------------------------------------------------------------------------*/
    public static Map <String,List<ChargeRateCardDTO>> sortByPlan(Map <String,List<ChargeRateCardDTO>> rateCardMap){
        Map <String,List<ChargeRateCardDTO>> sortedRateCardMap = new Map <String,List<ChargeRateCardDTO>>();
        Set<String> planKeyList = rateCardMap.keySet();
        Map<String, Integer> dataPlanUnitList = new Map<String, Integer>();
        dataPlanUnitList.put('KB', 1);
        dataPlanUnitList.put('MB', 2);
        dataPlanUnitList.put('GB', 3);
        dataPlanUnitList.put('TB', 4);
        
        Map<String, List<Integer>> mapPlanNameListOfValues = new Map<String, List<Integer>>();
        for(String planeName : dataPlanUnitList.keySet()){
            mapPlanNameListOfValues.put(planeName, new List<Integer>());
        }
        
        List<String> planList = new List<String>();
        for(String dataPlan: planKeyList){
            String planType = dataPlan.trim().right(2);
            Integer planValue = Integer.valueof(dataPlan.remove(planType).trim()); 
            if(String.isNotBlank(planType.trim()) && planValue != null){
                sortByValue(planType.trim(), planValue, mapPlanNameListOfValues);
            }
        }
        List<String> mainList = new List<String>();
        for(String planName : mapPlanNameListOfValues.keySet()){
            for(Integer planValue : mapPlanNameListOfValues.get(planName)){
                mainList.add(planValue + planName);
            }
        }
        
        for(String key : mainList){
            List<ChargeRateCardDTO> row = new List<ChargeRateCardDTO>();
            row = rateCardMap.get(key);
            System.debug('Key++'+ key);
            System.debug('Value++'+ rateCardMap.get(key));
            sortedRateCardMap.put(key, rateCardMap.get(key));
        }
        return sortedRateCardMap;
    }
    public static void sortByValue(String planType, Integer planValue, Map<String, List<Integer>> mapPlanNameListOfValues){
        List<Integer> planString = mapPlanNameListOfValues.get(planType);
        planString.add(planValue);
        planString.sort();
    }
    
     // changes started by shashank - DIGI-37779
      /*--------------------------------------------------------------------------------------------------
    # DIGI-37779
    # Author: shashank
    # to check the FeatureEligibility
    --------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean dmsRatematrixActive(){
        //system.debug('FeatureEligibilityChecker DMS -'+FeatureEligibilityChecker.determineFeatureEligiblity('EnableRateMatrixDMS', Null));
        return FeatureEligibilityChecker.determineFeatureEligiblity('EnableRateMatrixDMS', 'RateMatrixDMS');
    }
	// changes ended by shashank - DIGI-37779

    /*--------------------------------------------------------------------------------------------------
    # DIGI-603
    # Author: Nikhil Sharma 
    # get solution type from metadata records
    --------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String getSolutionType(String offerId){
    //PopulateRateCardBilling__mdt rateMatrixRecord =PopulateRateCardBilling__mdt.getInstance(offerId);
    List<PopulateRateCardBilling__mdt> rateMatrixRecord = [SELECT MasterLabel,Offer_Id__c,Solution_Type__c FROM PopulateRateCardBilling__mdt WHERE Offer_Id__c =: offerId];
    system.debug(rateMatrixRecord[0].Offer_Id__c);
    if(rateMatrixRecord != null){
    return rateMatrixRecord[0].Solution_Type__c;
    }
    return '';
    }
    
    /*--------------------------------------------------------------------------------------------------
    # DIGI-603
    # Author: Nikhil Sharma 
    # method to fetch rate card records details
    --------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static RateMatrixForDMSController.RateCardDTODMS retrieveConsumptionRateCards(String offerId,String jsonsios){
        return RateMatrixForDMSController.getRateCardData(offerId,jsonsios);
    }
    
    public class ChargeRateCardDTOIOT {
        @AuraEnabled public String rateCardCode {get;set;}
        @AuraEnabled public String rateCardName {get;set;}
        @AuraEnabled public Decimal rangeFrom {get;set;}
        @AuraEnabled public Decimal rangeTo {get;set;}
        @AuraEnabled public String recurringCharge {get;set;}
        @AuraEnabled public Decimal rateValueInclGST {get;set;}
        @AuraEnabled public Boolean excessCharge {get;set;}
        @AuraEnabled public Integer expectedSIO {get;set;}
        @auraEnabled public String capValue {get;set;}
        @AuraEnabled public Integer actualSIO {get;set;}
        @AuraEnabled public Boolean isSIODisabled {get;set;}
        @AuraEnabled public String rateCardId {get;set;}
        //EDGE-205510
        @AuraEnabled public String rateGroupIdentifier {get;set;}
    }
    public class RateCardDTOIOT {  
        @AuraEnabled public Map<String,List<ChargeRateCardDTOIOT>> rateCardMap{get;set;}
        @AuraEnabled public Map<Decimal,Decimal> mapFromToColumnHeader {get;set;}
        @AuraEnabled public String solutionType {get;set;}//DPG-2084
    }
  // DIGI-31600 - Not finding the pricing values in rate card for the plans of all the three plan variants.
    public class RateCardDTOIOTDiscounted {  
        @AuraEnabled public Map<String,List<ChargeRateCardDTO>> rateCardMap{get;set;}
        @AuraEnabled public List<DiscountDTO> discountDTOList {get;set;}
        @AuraEnabled public Map<Decimal,Decimal> mapFromToColumnHeader {get;set;}
        @AuraEnabled public String solutionType {get;set;}//DPG-2084
    }
    
    //Vamsi
    @AuraEnabled
    public static RateCardDTOIOTDiscounted getRateCard_DiscountsIoT(String callingPlan,String offerId,String solutionId,String changeType,String jsonsoiString,String selectplanname,String guid)
    {
	    Map<Decimal,Decimal> mapFromToColumnHeader = new Map<Decimal,Decimal>();
        List<RateCardSIOWrapper.wrapSIO> lstSIOs = new List<RateCardSIOWrapper.wrapSIO>();
        List <DiscountDTO> discountDTOList = new List <DiscountDTO> ();
        Map<String,RateCardSIOWrapper.wrapSIO> mPlanRateSIO = new Map<String,RateCardSIOWrapper.wrapSIO>();
        Map <String,List<ChargeRateCardDTO>> rateCardMap = new Map <String,List<ChargeRateCardDTO>>();  
        RateCardDTOIOTDiscounted rateDiscountCard=new RateCardDTOIOTDiscounted();
        rateDiscountCard.discountDTOList = new List<DiscountDTO>();
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        List<String> allKeyToSort = new List<String>();
        Map <String,List<ChargeRateCardDTO>> rateCardMapSorted = new Map <String,List<ChargeRateCardDTO>>(); 
        Boolean discountEligible = false;
        Id commercialProductVariantId;
        Id commercialProductMasterId;
        try{
            //Current solution is extracted on the base of related offerId of the solution
            PopulateRateCardBilling__mdt[] rateMatrixRecord = [SELECT Id,Solution_Type__c FROM PopulateRateCardBilling__mdt WHERE Offer_Id__c = :offerId LIMIT 1];
            if(rateMatrixRecord.size()>0){
                currentSolution = rateMatrixRecord[0].Solution_Type__c;
            }
            if(changeType!='Modify')
            discountDTOList=RateMatrixForNGUCController.getDiscountdata();
        else
            discountDTOList=RateMatrixForNGUCController.fetchModifyDiscountData(callingPlan,solutionId,guid);
            discountEligible = discountDTOList.size() > 0 ? true : false;

            if(string.isNotBlank(jsonsoiString)){
                lstSIOs = (List<RateCardSIOWrapper.wrapSIO>) JSON.deserialize(jsonsoiString, List<RateCardSIOWrapper.wrapSIO>.class);
            }
            for(RateCardSIOWrapper.wrapSIO objSIOs :lstSIOs){
                mPlanRateSIO.put(objSIOs.rateGroupIdentifier,objSIOs);
            }

            rateCardLineList = getRateCardDataIoT(callingPlan,selectplanname,solutionId);
            for( cspmb__Rate_Card_Line__c rcl: rateCardLineList){
                ChargeRateCardDTO rateCardDto = RateCardHelper.getRateCardJsonData(rcl,mPlanRateSIO,discountEligible);
				if(!mapFromToColumnHeader.containskey(rcl.fromUnit__c)){
                                mapFromToColumnHeader.put(rcl.fromUnit__c, rcl.toUnit__c);
                            }
				//DIGI-5330 - In Rate Card, not finding the Excess Usage Rates/MB Column
                 if(rcl.cspmb__Rate_Card__r.Name.contains('ExcessCharge')){
                     rateCardDto.excessCharge = true;
                     rateCardDto.capValue = String.Valueof(rcl.cspmb__Cap__c);
                 }
				rateCardDto.rateCardName = rateCardIdPlanMap.get(rcl.cspmb__Rate_Card__c).replaceAll(' ', '');
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
			if(rateCardMap.isEmpty()){
                    throw new AuraHandledException('Please Contact your System Administratior (ERROR : Data issue)');
                }
                else if(currentSolution=='IOT'){
                    rateDiscountCard.rateCardMap = sortByPlan(rateCardMap);
                }
                else{
                    rateDiscountCard.rateCardMap = rateCardMap;
                }
			rateDiscountCard.solutionType = 'IOT';
			rateDiscountCard.mapFromToColumnHeader = mapFromToColumnHeader;			
        }
        catch(Exception e)
        {
            throw new AuraHandledException('An exception occured - '+e.getMessage()+':'+e.getLineNumber());
        }
        return rateDiscountCard;
    }
    
    @AuraEnabled
   public static List<cspmb__Rate_Card_Line__c> getRateCardDataIoT(String offerType,String planType, Id solutionId){
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        Map<Id,Boolean> rateCardToSioDisabledMap = new Map<Id,Boolean>();
        //EDGE-213651
          if ( solutionId != null ){
                     RateCardHelper.checkFrameAgreement( solutionId );
        }
       
        if(String.isNotBlank(offerType) && String.isNotBlank(planType)){
            //query all rate card association records based on commercial products
            for(cspmb__Price_Item_Rate_Card_Association__c rateCardAssc: [select cspmb__Rate_Card__c,cspmb__Price_Item__c,
                                                                            cspmb__Price_Item__r.cspmb__Master_Price_item__c,cspmb__Price_Item__r.Plan__c 
                                                                            from cspmb__Price_Item_Rate_Card_Association__c
                                                                            where cspmb__Price_Item__r.Check_todays_date__c = TRUE AND cspmb__Price_Item__r.cspmb__Is_Active__c = TRUE //EDGE-207998 - Added condition to check today's date
                                                                            AND cspmb__Price_Item__r.Offer_Type__c =: offerType AND cspmb__Price_Item__r.Plan_Type__c =: planType]){
                                                                                
                    rateCardToSioDisabledMap.put(rateCardAssc.cspmb__Rate_Card__c,true);
                	rateCardIdPlanMap.put(rateCardAssc.cspmb__Rate_Card__c,rateCardAssc.cspmb__Price_Item__r.Plan__c);
            }
            //return a list of rate card lines from rate card association records from previous query
            rateCardLineList = [select id,cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c,cspmb__Rate_Card__r.Name,
                                fromUnit__c,toUnit__c,cspmb__rate_value__c,cspmb__Rate_Card__r.External_Rate_Row_ID__c,
                                cspmb__Rate_Card__c,cspmb__Cap__c from cspmb__Rate_Card_Line__c 
                                where cspmb__Rate_Card__c in: rateCardToSioDisabledMap.keyset() and Check_todays_date__c = TRUE ORDER BY fromUnit__c ASC];//EDGE-207998 - Added condition to check today's date
        }  
        return rateCardLineList;
    }    
    //Vamsi
}