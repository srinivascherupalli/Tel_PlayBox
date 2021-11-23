/*****************************************************************************************
* ModifiedBy     ModifiedDate     Edge          Description
* Shashank Jadhav   17/03/2021    EDGE-203808   Changes related to the FundConsole Tab Functionality

* Shivaprasad       15/04/2021    EDGE-203808   Changes to include Flexi Contribution

* Parmanand Shete    20/04/2021   EDGE-211114    Added Minimum spent per month manual field 
* Manish Berad      26/04/2021    EDGE-211115 & EDGE-211116 Create DPR Rate Card record in backend to store Rate Card Lines (Rate value and Negotiated Rate value) per tier from FA configuration.

* Parmanand Shete   18/05/2021  EDGE-212164
* Shashank Jadhav   08/06/2021    EDGE-223653   CI || sonar cube defect fix required
* Shashidhar Kumar  24/06/2021    EDGE-219471: Updated field Contract_Term to PF_Contract_Term
* Shivaprasad Patil 25/06/2021    EDGE-219475: Added field Fund Expiry (Fund Term)
* Shashank Jadhav:  13/07/2021    EDGE-221893-Insert Exception Log records with Exception Log Frameworks
*Shubham Tiwari:  27/08/2021    DIGI-12187- Deal scoring is failing when devices are added to enterprise mobility fix required
************************************************************************************************************************************************/

/**
 * Class to hold various FAM DPR related helper methods.
 */
public with sharing class FAM_DPR_Utility {
    
    public static Map<Id,Integer> mapOfProductQuantity=new Map<Id,Integer>(); //EDGE-203808-To get the quantity
    
    // Added by Shivaprasad for Fund Console data retrieval
    // Updated the Contract term API to new "PF_Contract_Term__c" as part of EDGE-219471
    // EDGE-219475
    public static String getDPRRecords(String faId){
        //List<csconta__Frame_Agreement__c> fa = [SELECT Delegated_Pricing_Request__c FROM csconta__Frame_Agreement__c where Id =: faId];
        List<DPR_Offer__c> dprOffers = [select id,Fund_Amount__c, Fund_Amount_Calc__c, Fund_Term__c, Advance_Fund_Amount_Percent__c, Fund_Increment_Frequency__c, Fund_Contribution__c, Fund_Type__c, Minimum_Spend_per_Month__c, Minimum_Spent_per_Month_Manual__c, Product_Family__c, PF_Contract_Term__c, Total_Spend_over_Contract_Term__c, Flexi_Fund_Amount_Percent__c, Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c, isAllocated__c, ContractStartDate__c, ContractEndDate__c from DPR_Offer__c where Delegated_Pricing_Request__c IN (SELECT Delegated_Pricing_Request__c FROM csconta__Frame_Agreement__c where Id =: faId)];

        //return JSON.serialize([select id,Fund_Amount__c, Fund_Amount_Calc__c, Fund_Term__c, Advance_Fund_Amount_Percent__c, Fund_Increment_Frequency__c, Fund_Contribution__c, Fund_Type__c, Minimum_Spend_per_Month__c, Minimum_Spent_per_Month_Manual__c, Product_Family__c, PF_Contract_Term__c, Total_Spend_over_Contract_Term__c, Flexi_Fund_Amount_Percent__c, Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c, isAllocated__c, ContractStartDate__c, ContractEndDate__c from DPR_Offer__c where Delegated_Pricing_Request__c =:fa[0].Delegated_Pricing_Request__c]);
		return JSON.serialize(dprOffers);

    }
    //End
    
    //EDGE-203808-Update DPR Offers FundData-Start
    //EDGE-219475: Added field Fund Expiry (Fund Term)
    //public Boolean UpdateDPROffersForFundData(Id frameAgreementId,Id dprId,Map<String, FAM_Utility.FundData> fundDataRecords) {
    public static Boolean updateDPROffersForFundData(Id dprId,Map<String, FAM_Utility.FundData> fundDataRecords) {
        try{//EDGE-221893: Added try block
        List<DPR_Offer__c> listOfDPROfferForUpdate=new List<DPR_Offer__c>();


        List<Delegated_Pricing_Request__c> delegatedPR = [SELECT Id, Tech_Reward_Type__c FROM Delegated_Pricing_Request__c WHERE Id =: dprId];


        for(DPR_Offer__c dprOffer:[select id,Fund_Amount__c,Fund_Amount_Calc__c,Advance_Fund_Amount_Percent__c, Fund_Term__c,Fund_Increment_Frequency__c, Fund_Contribution__c, Fund_Type__c, Product_Family__c, PF_Contract_Term__c, Total_Spend_over_Contract_Term__c from DPR_Offer__c where Delegated_Pricing_Request__r.Id =:dprId]){
            if(dprOffer.Product_Family__c != null){
                FAM_Utility.FundData fundDataRecord=fundDataRecords.get(dprOffer.Product_Family__c);
                System.debug('@@Shashank='+fundDataRecord);
                if(fundDataRecord != null){
                     dprOffer.isAllocated__c= fundDataRecord.isAllocated;
                     dprOffer.ContractStartDate__c=fundDataRecord.ContractStartDate != null ? fundDataRecord.ContractStartDate : null; 
                     dprOffer.ContractEndDate__c= fundDataRecord.ContractEndDate != null ? fundDataRecord.ContractEndDate : null; 
                    dprOffer.Minimum_Spent_per_Month_Manual__c = (fundDataRecord.minimumSpendPerMonth != null)?Decimal.valueOf(fundDataRecord.minimumSpendPerMonth):0;//EDGE-211114
                    dprOffer.Fund_Amount__c = (fundDataRecord.advanceFundAmount != null && fundDataRecord.fundType=='Advance')?Decimal.valueOf(fundDataRecord.advanceFundAmount):null;//Defect-EDGE-212284
                    dprOffer.Fund_Increment_Frequency__c = fundDataRecord.fundIncrementFrequency;
                    dprOffer.Fund_Type__c = fundDataRecord.fundType;
                    dprOffer.PF_Contract_Term__c = (fundDataRecord.contractTerm != null)?Decimal.valueOf(fundDataRecord.contractTerm):0;//EDGE-219471
                    dprOffer.Fund_Term__c = (fundDataRecord.fundExpiry != null)?Decimal.valueOf(fundDataRecord.fundExpiry):12; //EDGE-219475
                    listOfDPROfferForUpdate.add(dprOffer);
                    if(delegatedPR!= null && !delegatedPR.isEmpty() && fundDataRecord.fundType != null)             delegatedPR[0].Tech_Reward_Type__c = fundDataRecord.fundType;//Defect-EDGE-212284
                    system.debug('dprOffer-->'+dprOffer);
                 }
            }
        }
        
        update delegatedPR;

        system.debug('listOfDPROfferForUpdate-->'+listOfDPROfferForUpdate);

        if(!listOfDPROfferForUpdate.isEmpty() && listOfDPROfferForUpdate != null){
            //update listOfDPROfferForUpdate;
            system.debug('updating dpr offers using database');
            Database.SaveResult[] saveResultList = Database.update(listOfDPROfferForUpdate);
            Boolean isError=false;
            system.debug('saveResultList-->'+saveResultList);
            for (Database.SaveResult sr : saveResultList) {
                system.debug('saveResultList in for loop-->');
                if (!sr.isSuccess()) {
                    isError=true;
                    System.debug('@@SS:Issue in DPR Offer Update:'+sr.getErrors());
                }
            }
            if(isError)
                return false;
        }
        }catch(Exception ex){//EDGE-221893-Start
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','updateDPROffersForFundData', '', dprId, ex.getMessage(), 'Generation of Agreement Document Failed.',false);
                   
        }//EDGE-221893-End  
        return true;
    }
    //EDGE-203808-Update DPR Offers FundData-End
    //EDGE-203808-Inserting DPR Offers-Start
    /**
     * Insert DPR Offer records
     */
    public static List<DPR_Offer__c> createDPROffers(Delegated_Pricing_Request__c dpr,Map<Id,DPR_Offer__c> existingMoIdToDprOffer,Map<String,Marketable_Offer__c> offerIdToMO,Map<String,List<Marketable_Offer__c>> productFamilyToMO){
        List<DPR_Offer__c> dprOffersForInsert = new List<DPR_Offer__c>(); //master list where we have missing ones created and no longer needed ones removed
        // EDGE-203808-enableFundConsole not equals to true then execute existing logic-Start
     
        //DIGI-12187- Start  creating Map of product family to dpr offer record
        Map<String,DPR_Offer__c> mapOfProductFamilyToDPROffer=new Map<String,DPR_Offer__c>();//Not used we check to delete this mapOfProductFamilyToDPROffer
		
		for(DPR_Offer__c dprOfferRecord :existingMoIdToDprOffer.values()){
            if(!mapOfProductFamilyToDPROffer.containsKey(dprOfferRecord.Name))
                mapOfProductFamilyToDPROffer.put(dprOfferRecord.Name, dprOfferRecord);
        }
		//DIGI-12187- End 
        
        try{//EDGE-221893: Added try block
            for (String keyId :productFamilyToMO.keySet()) {
                List<Marketable_Offer__c> listOfMO=productFamilyToMO.get(keyId);
                if(!listOfMO.isEmpty() && listOfMO != null){
                 //  if (!existingMoIdToDprOffer.containsKey(listOfMO[0].Id) ) {
                        //we need to create new DPR Offer and also add it to the list so we have it after insert
                       			//DIGI-12187- Start Instead of checking existingMoIdToDprOffer now we will check mapOfProductFamilyToDPROffer
                        if(! mapOfProductFamilyToDPROffer.containsKey(keyId))
                        //DIGI-12187- End 
			{  
                        dprOffersForInsert.add(
                            new DPR_Offer__c(
                                Delegated_Pricing_Request__c = dpr.Id,
                                Marketable_Offer__c          = listOfMO[0].Id, //Need to discuss to stamp it or not
                                Name                         = listOfMO[0].Product_Family__c,
                                PF_Contract_Term__c       = dpr.Opportunity__r.Contract_Term__c
                              ) 
                            );
                    }
                }
            }
            // EDGE-203808- enableFundConsole not equals to true then execute existing logic-End
            //insert ones that were missing
            //insert dprOffersForInsert;
            if(!dprOffersForInsert.isEmpty() && dprOffersForInsert != null){
                Database.SaveResult[] saveResultList = Database.insert(dprOffersForInsert);
                for (Database.SaveResult sr : saveResultList) {
                    if (!sr.isSuccess()) {
                        System.debug('@@SS:Issue in DPR Offer Update:'+sr.getErrors());
                        return new List<DPR_Offer__c>();//EDGE-223653-Sonar Cube Changes
                    }
                }
            }
        }catch(Exception ex){//EDGE-221893-Start
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','createDPROffers', '', dpr.Id, ex.getMessage(), 'Generation of Agreement Document Failed.',false);
        }//EDGE-221893-End  
        return getCreatedDPROffers(dprOffersForInsert,existingMoIdToDprOffer);
    }
    
    //getDPRCreatedDPROffers
    public static List<DPR_Offer__c> getCreatedDPROffers(List<DPR_Offer__c> dprOffersList,Map<Id,DPR_Offer__c> existingMoIdToDprOffer){
        Set<Id> dprOffersSet=new Set<Id>();
        for(DPR_Offer__c dprOffer:dprOffersList){
            dprOffersSet.add(dprOffer.Id);
        }
        for(DPR_Offer__c dprOfferRecord :existingMoIdToDprOffer.values()){
            if(!dprOffersSet.contains(dprOfferRecord.Id))
                dprOffersSet.add(dprOfferRecord.Id);
        }
        //DPR_Offer_Line_Item_Value__c * dprOLI.Fund_Allocation__c * dprOLI.Portfolio_Margin__c * dprOLI.Quantity__c)/10000) : 0 ;
        if(dprOffersSet != null && !dprOffersSet.isEmpty()){
            return [Select Id,Name,Product_Family__c,Delegated_Pricing_Request__c,Marketable_Offer__c,Marketable_Offer__r.Fund_Allocation_Percentage__c,Marketable_Offer__r.Portfolio_Margin_Percentage__c,PF_Contract_Term__c
                    FROM DPR_Offer__c where Id IN : dprOffersSet];    
        }
        
        return new List<DPR_Offer__c>();//EDGE-223653-Sonar Cube Changes
    }
    
    public static List<DPR_Offer_Line_Item__c> createDPROfferLineItems(List<DPR_Offer__c> dprOffers,Map<Id, DPR_Offer_Line_Item__c> commercialProductIdToExistingParentOliMap,
                                                                       Map<Id, FAM_Utility.VolumeAndPricing> productToVolumeAndPricingMap,
                                                                       Map<String, List<cspmb__Price_Item__c>> offerNameToCP,
                                                                       Map<String,Marketable_Offer__c> offerIdToMO,
                                                                       Boolean isVariation,Map<String,List<Marketable_Offer__c>> productFamilyToMO,
                                                                       Map<String, FAM_Utility.FundData> fundConsoleRecordsMap){
        List<DPR_Offer_Line_Item__c> dprOLIForUpsert = new List<DPR_Offer_Line_Item__c>();
        try{//EDGE-221893: Added try block
        if(dprOffers != null && !dprOffers.isEmpty()){
            for (DPR_Offer__c dprOffer : dprOffers) {
                //Modified by Shashank-Start
                // EDGE-203808-enableFundConsole flag is equals to true then iterate over the productFamilyToMO map -Start
                if(productFamilyToMO.containsKey(dprOffer.Name)){
                    for(Marketable_Offer__c mo:productFamilyToMO.get(dprOffer.Name)){
                        //for all commercial products with this offer id
                        String offerId = mo.Offer_ID__c;
                        if(offerNameToCP.containsKey(offerId)){
                            for (cspmb__Price_Item__c cp :offerNameToCP.get(offerId)) {
                                DPR_Offer_Line_Item__c dprOLI;
                                if (commercialProductIdToExistingParentOliMap.containsKey(cp.Id)) {
                                    //get existing one
                                    dprOLI = commercialProductIdToExistingParentOliMap.get(cp.Id);
                                    //EDGE-203808-To update the quantity from FA JSON attachment-Start
                                    if(productToVolumeAndPricingMap.get(cp.Id).mv == null || productToVolumeAndPricingMap.get(cp.Id).mv == 0){
                                        dprOLI.Quantity__c=  1;  

                                        mapOfProductQuantity.put(cp.Id,1);

                                    }else{
                                        dprOLI.Quantity__c=productToVolumeAndPricingMap.get(cp.Id).mv;
                                        mapOfProductQuantity.put(cp.Id,Integer.valueOf(productToVolumeAndPricingMap.get(cp.Id).mv));
                                    }
                                    //EDGE-203808-To update the quantity from FA JSON attachment-End
                                }
                                //parent not found, create it
                                if (dprOLI == null) {
                                    dprOLI                                  = new DPR_Offer_Line_Item__c();
                                    //dprOLI.Name                             = cp.Plan__c;    //Name;

                                   //dprOLI.Name=cp.ProdSpecId__c=='DMCAT_ProductSpecification_001211'?cp.Model__c:cp.Plan__c;//added as part EDGE-177929
                                    if(cp.ProdSpecId__c=='DMCAT_ProductSpecification_001211'){
                                        dprOLI.Name=cp.Model__c;
                                    }else{
                                        if(cp.Plan__c!=null){
                                            dprOLI.Name=cp.Plan__c;
                                        }else{
                                            dprOLI.Name = cp.Name;
                                        }
                                    }

                                      // dprOLI.Marketable_Offer__c              = dprOffer.Marketable_Offer__c;  
                                         //DIGI-12187- Start 
                                      dprOLI.Marketable_Offer__c              =  mo.Id;
                                      //DIGI-12187- End 
                                        dprOLI.Offer_Type__c                    = cp.Id;
                                        dprOLI.Offer_Type_Name__c               = cp.Type__c;
                                        dprOLI.Delegated_Pricing_Request__c     = dprOffer.Delegated_Pricing_Request__c;
                                        dprOLI.DPR_Offer__c                     = dprOffer.Id;
                                        dprOLI.cspmb_Price_Item__c              = cp.Id;
                                        dprOLI.DPR_Offer_Line_Item_Type__c      = 'Plan';
                                        dprOLI.DPR_Offer_Line_Item_Unit_Type__c = 'Amount';
                                        //dprOLI.Quantity__c                      = 0;
                                        dprOLI.Recontracting_Quantity__c        = 0;
                                        
                                        //Commented by Shashank-Start
                                        //EDGE-177929 - Condition added by team Amsterdam
                                        //Commented by Shashank-End` 
                                        //EDGE-203808-To update the quantity from FA JSON attachment-Start
                                        if(productToVolumeAndPricingMap.get(cp.Id).mv == null || productToVolumeAndPricingMap.get(cp.Id).mv == 0){
                                            dprOLI.Quantity__c=  1;  //EDGE-177929 - Condition added by team Amsterdam
                                            mapOfProductQuantity.put(cp.Id,1);
                                        }else{
                                            dprOLI.Quantity__c=productToVolumeAndPricingMap.get(cp.Id).mv;
                                            mapOfProductQuantity.put(cp.Id,Integer.valueOf(productToVolumeAndPricingMap.get(cp.Id).mv));
                                        }
                                        //EDGE-203808-To update the quantity from FA JSON attachment-End
                                    }
                                    //update part for both, not touching qty or recontracting qty as that is maintaind by another logic
                                    //parent
                                    //added as part EDGE-177929
                                    if(cp.ChargeType__c=='RC'){
                                        dprOLI.List_Price__c                = cp.cspmb__Recurring_Charge__c != null ? cp.cspmb__Recurring_Charge__c : 0;//defaulting to 0
                                        dprOLI.Total_Recurring_Charge__c    = cp.cspmb__Recurring_Charge__c != null ? cp.cspmb__Recurring_Charge__c : 0;
                                        dprOLI.Overridden_Unit_price__c     = productToVolumeAndPricingMap.get(cp.Id).recurring != null ? productToVolumeAndPricingMap.get(cp.Id).recurring : dprOLI.List_Price__c;
                                    }else{
                                        dprOLI.List_Price__c                = cp.cspmb__One_Off_Charge__c != null ? cp.cspmb__One_Off_Charge__c : 0;//defaulting to 0
                                        dprOLI.Total_Once_Off_Charge__c = cp.cspmb__One_Off_Charge__c != null ? cp.cspmb__One_Off_Charge__c : 0;
                                        dprOLI.Overridden_Unit_price__c     = productToVolumeAndPricingMap.get(cp.Id).Oneoff != null ? productToVolumeAndPricingMap.get(cp.Id).oneoff : dprOLI.List_Price__c;
                                    }
                                    dprOLI.DPR_Offer_Line_Item_Value__c = dprOLI.Overridden_Unit_price__c;
                                    //184803 start
                                    dprOLI.isNegotiableCharge__c=(cp.cspmb__Is_Recurring_Discount_Allowed__c == true || cp.cspmb__Is_One_Off_Discount_Allowed__c == true)?true:false;
                                    dprOLI.Overridden_Total_Price__c=dprOLI.Overridden_Unit_price__c*dprOLI.Quantity__c;
                                    //184803 end
                                     if(fundConsoleRecordsMap!=null){
                                            if(dprOffer.Product_Family__c != null){
                                                FAM_Utility.FundData fundDataRecord=fundConsoleRecordsMap.get(dprOffer.Product_Family__c);
                                                if(fundDataRecord != null){
                                                    if(fundDataRecord.isAllocated == null || !fundDataRecord.isAllocated){
                                                       // dprOLI.Fund_Amount__c =(cp.IsContributing__c) ? ((dprOffer.PF_Contract_Term__c * dprOLI.DPR_Offer_Line_Item_Value__c * dprOffer.Marketable_Offer__r.Fund_Allocation_Percentage__c * dprOffer.Marketable_Offer__r.Portfolio_Margin_Percentage__c * dprOLI.Quantity__c)/10000) : 0 ;
                                                       //DIGI-12187- Start 
                                                       dprOLI.Fund_Amount__c =(cp.IsContributing__c) ? ((dprOffer.PF_Contract_Term__c  * dprOLI.DPR_Offer_Line_Item_Value__c * mo.Fund_Allocation_Percentage__c * mo.Portfolio_Margin_Percentage__c * dprOLI.Quantity__c)/10000) : 0 ;
                                                            //DIGI-12187- End 
                                                    }
                                                }else{
                                                        //dprOLI.Fund_Amount__c =(cp.IsContributing__c) ? ((dprOffer.PF_Contract_Term__c * dprOLI.DPR_Offer_Line_Item_Value__c * dprOffer.Marketable_Offer__r.Fund_Allocation_Percentage__c * dprOffer.Marketable_Offer__r.Portfolio_Margin_Percentage__c * dprOLI.Quantity__c)/10000) : 0 ;
                                                     //DIGI-12187- Start   
                                                        dprOLI.Fund_Amount__c =(cp.IsContributing__c) ? ((dprOffer.PF_Contract_Term__c  * dprOLI.DPR_Offer_Line_Item_Value__c * mo.Fund_Allocation_Percentage__c * mo.Portfolio_Margin_Percentage__c * dprOLI.Quantity__c)/10000) : 0 ;
                                                            //DIGI-12187- End 
                                                }
                                            }
                                        }else{
                                            //dprOLI.Fund_Amount__c =(cp.IsContributing__c) ? ((dprOffer.PF_Contract_Term__c * dprOLI.DPR_Offer_Line_Item_Value__c * dprOffer.Marketable_Offer__r.Fund_Allocation_Percentage__c * dprOffer.Marketable_Offer__r.Portfolio_Margin_Percentage__c * dprOLI.Quantity__c)/10000) : 0 ;
                                          //DIGI-12187- Start               
                                            dprOLI.Fund_Amount__c =(cp.IsContributing__c) ? ((dprOffer.PF_Contract_Term__c  * dprOLI.DPR_Offer_Line_Item_Value__c * mo.Fund_Allocation_Percentage__c * mo.Portfolio_Margin_Percentage__c * dprOLI.Quantity__c)/10000) : 0 ;
                                        //DIGI-12187- End 
                                        }
                                   // if(!isVariation)  dprOLI.Fund_Amount__c =(cp.IsContributing__c) ? ((dprOffer.PF_Contract_Term__c * dprOLI.DPR_Offer_Line_Item_Value__c * dprOffer.Marketable_Offer__r.Fund_Allocation_Percentage__c * dprOffer.Marketable_Offer__r.Portfolio_Margin_Percentage__c * dprOLI.Quantity__c)/10000) : 0 ;
                                    //add to lists
                                    dprOLIForUpsert.add(dprOLI);
                                }
                            }   
                        }
                    }
                    // EDGE-203808-enableFundConsole flag is not equals to true then execute the existing logic-End
                    //Modified by Shashank-End
                    
                }
                //ready to save DPR OLIs
                //upsert dprOLIForUpsert;
                if(!dprOLIForUpsert.isEmpty() && dprOLIForUpsert != null){
                    //update listOfDPROfferForUpdate;
                    Database.UpsertResult[] upsertResultList = Database.upsert(dprOLIForUpsert);
                    for (Database.UpsertResult sr : upsertResultList ) {
                        if (!sr.isSuccess()) {System.debug('@@SS:Issue in dprOLIForUpsert Upsert:'+sr.getErrors());return new List<DPR_Offer_Line_Item__c>();}//EDGE-223653-Sonar Cube Changes
                    }
                }
            }
        }catch(Exception ex){//EDGE-221893-Start
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','createDPROfferLineItems', '', '', ex.getMessage(), 'Generation of Agreement Document Failed.',false);
    
        }//EDGE-221893-End
        return dprOLIForUpsert;
    }

    public static Map<Id,DPR_Offer_Line_Item__c> updateChildDPROfferLineItemsForAddonsAndDiscounts(List<DPR_Offer_Line_Item__c> dprOLIForUpsert,Map<Id, DPR_Offer_Line_Item__c> commercialProductIdToExistingParentOliMap,Map<Id,DPR_Offer_Line_Item__c> existingDPROLI,Map<String, List<cspmb__Price_Item_Add_On_Price_Item_Association__c>> mapOfPriceItemVsPIA,Map<String,FAM_Utility.AddOnPricing> mapOfAddOn,Boolean isVariation){
        //child ones that need to inserted have to be seperate DML i.e. after the 1st upsert as we need to have parent Ids
        Map<Id,DPR_Offer_Line_Item__c> allNeededOLIs= new Map<Id,DPR_Offer_Line_Item__c>();
        
        List<DPR_Offer_Line_Item__c> childDprOLIForUpsert = new List<DPR_Offer_Line_Item__c>();
        List<DPR_Offer_Line_Item__c> childDprOLIForAddOnUpsert = new List<DPR_Offer_Line_Item__c>();
        
        Double mmcDiscount = 0.0;
        try{//EDGE-221893: Added try block
        for (DPR_Offer_Line_Item__c parentOLI :dprOLIForUpsert) {
            DPR_Offer_Line_Item__c childDprOLI;
            DPR_Offer_Line_Item__c childDprAddOnOLI;
            //if parent was updated then we would also have a existing child record so use that
            if (commercialProductIdToExistingParentOliMap.containsKey(parentOLI.cspmb_Price_Item__c)) {
                if (!parentOLI.DPR_Offer_Line_Items__r.isEmpty()) {
                    //one and only child record expected so get the Id so we can get full record from the map
                    childDprOLI = existingDPROLI.get(parentOLI.DPR_Offer_Line_Items__r[0].Id);
                    childDprOLI.Quantity__c = (mapOfProductQuantity.containsKey(parentOLI.cspmb_Price_Item__c))? mapOfProductQuantity.get(parentOLI.cspmb_Price_Item__c): 1;//Added by Shashank
                }
            }
            mmcDiscount = parentOLI.List_Price__c - parentOLI.Overridden_Unit_price__c;//added as part EDGE-177929
            //if child not found, create it
            if (mmcDiscount > 0.0 ) {
                childDprOLI                                  = new DPR_Offer_Line_Item__c();
                childDprOLI.Parent_DPR_Offer_Line_Item_Id__c = parentOLI.Id;
                childDprOLI.Name                             = 'MMC Discount';
                childDprOLI.Marketable_Offer__c              = parentOLI.Marketable_Offer__c;
                childDprOLI.Offer_Type__c                    = parentOLI.Offer_Type__c;
                childDprOLI.Offer_Type_Name__c               = parentOLI.Offer_Type_Name__c;
                childDprOLI.Delegated_Pricing_Request__c     = parentOLI.Delegated_Pricing_Request__c;
                childDprOLI.DPR_Offer__c                     = parentOLI.DPR_Offer__c;
                childDprOLI.cspmb_Price_Item__c              = parentOLI.Offer_Type__c;
                childDprOLI.DPR_Offer_Line_Item_Type__c      = 'Discount';
                childDprOLI.DPR_Offer_Line_Item_Unit_Type__c = 'Amount';


                childDprOLI.Quantity__c                      = 0; 
                //childDprOLI.Quantity__c = (mapOfProductQuantity.containsKey(parentOLI.cspmb_Price_Item__c))? mapOfProductQuantity.get(parentOLI.cspmb_Price_Item__c): 1;//Commented by Shashank


                childDprOLI.Recontracting_Quantity__c        = 0;

                //184803 start - added by team Amsterdam
                childDprOLI.isNegotiableCharge__c            = parentOLI.isNegotiableCharge__c;
                childDprOLI.Overridden_Total_Price__c        = 0;
                childDprOLI.Overridden_Unit_price__c         = 0;
                //184803 end
                //System.debug('@@$$parentOLI.cspmb_Price_Item__r.IsContributing__c:'+parentOLI.cspmb_Price_Item__r.IsContributing__c);
                

            //update part
                childDprOLI.DPR_Offer_Line_Item_Value__c =mmcDiscount;
            childDprOLIForUpsert.add(childDprOLI);
            }
            //childDprOLIForUpsert.add(childDprOLI);
            //System.debug('@@SS:childDprOLIForUpsert:'+childDprOLIForUpsert);
            /** EDGE-177926 Start **/
            if(childDprAddOnOLI==null && mapOfPriceItemVsPIA.containsKey(parentOLI.cspmb_Price_Item__c)){
                    List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lstPIA=mapOfPriceItemVsPIA.get(parentOLI.cspmb_Price_Item__c);
                    for(cspmb__Price_Item_Add_On_Price_Item_Association__c priceAtemAddOn:lstPIA){
                        childDprAddOnOLI = new DPR_Offer_Line_Item__c();
                        childDprAddOnOLI.Parent_DPR_Offer_Line_Item_Id__c = parentOLI.Id;
                        childDprAddOnOLI.Name                             = priceAtemAddOn.AddOnName__c;
                        childDprAddOnOLI.Marketable_Offer__c              = parentOLI.Marketable_Offer__c;
                        childDprAddOnOLI.Offer_Type__c                    = parentOLI.Offer_Type__c;
                        childDprAddOnOLI.Offer_Type_Name__c               = parentOLI.Offer_Type_Name__c;
                        childDprAddOnOLI.Delegated_Pricing_Request__c     = parentOLI.Delegated_Pricing_Request__c;
                        childDprAddOnOLI.DPR_Offer__c                     = parentOLI.DPR_Offer__c;
                        childDprAddOnOLI.cspmb_Price_Item__c              = parentOLI.Offer_Type__c;
                        childDprAddOnOLI.cspmb_Add_On_Price_Item__c       = priceAtemAddOn.cspmb__Add_On_Price_Item__c;
                        childDprAddOnOLI.DPR_Offer_Line_Item_Type__c      = 'Addon';
                        childDprAddOnOLI.DPR_Offer_Line_Item_Unit_Type__c = 'Amount';


                        childDprAddOnOLI.Quantity__c                      = 0; //Commented by Shashank
                        //childDprAddOnOLI.Quantity__c = (mapOfProductQuantity.containsKey(parentOLI.cspmb_Price_Item__c))? mapOfProductQuantity.get(parentOLI.cspmb_Price_Item__c): 1;//Commented by Shashank

                        

                        childDprAddOnOLI.Recontracting_Quantity__c        = 0;
                        if(priceAtemAddOn.cspmb__Add_On_Price_Item__r.cspmb__Is_One_Off_Discount_Allowed__c==true ||
                           priceAtemAddOn.cspmb__Add_On_Price_Item__r.cspmb__Is_Recurring_Discount_Allowed__c==true){
                            childDprAddOnOLI.isNegotiableCharge__c            = true;   
                        }
                        if (priceAtemAddOn.cspmb__Recurring_Charge__c != null 
                            && priceAtemAddOn.cspmb__Recurring_Charge__c >= 0){
                                childDprAddOnOLI.List_Price__c=priceAtemAddOn.cspmb__Recurring_Charge__c;
                                childDprAddOnOLI.Total_Recurring_Charge__c=priceAtemAddOn.cspmb__Recurring_Charge__c;
                            }else{
                                childDprAddOnOLI.List_Price__c=priceAtemAddOn.cspmb__One_Off_Charge__c ;
                                childDprAddOnOLI.Total_Recurring_Charge__c=0;
                            }
                        if(priceAtemAddOn.cspmb__One_Off_Charge__c != null &&
                           priceAtemAddOn.cspmb__One_Off_Charge__c > 0){
                               childDprAddOnOLI.Total_Once_Off_Charge__c = priceAtemAddOn.cspmb__One_Off_Charge__c;
                           }else{
                               childDprAddOnOLI.Total_Once_Off_Charge__c =0;
                           }
                        if(priceAtemAddOn.cspmb__Recurring_Charge__c != null && priceAtemAddOn.cspmb__Recurring_Charge__c >= 0 && mapOfAddOn.containsKey(priceAtemAddOn.Id) && mapOfAddOn.get(priceAtemAddOn.Id).recurring!=null){
                              childDprAddOnOLI.Overridden_Unit_price__c=mapOfAddOn.get(priceAtemAddOn.Id).recurring;
                                childDprAddOnOLI.DPR_Offer_Line_Item_Value__c=mapOfAddOn.get(priceAtemAddOn.Id).recurring;
                           }else if(priceAtemAddOn.cspmb__One_Off_Charge__c != null && priceAtemAddOn.cspmb__One_Off_Charge__c >= 0 && mapOfAddOn.containsKey(priceAtemAddOn.Id) && mapOfAddOn.get(priceAtemAddOn.Id).oneOff!=null){
                               childDprAddOnOLI.Overridden_Unit_price__c=mapOfAddOn.get(priceAtemAddOn.Id).oneOff;
                               childDprAddOnOLI.DPR_Offer_Line_Item_Value__c=mapOfAddOn.get(priceAtemAddOn.Id).oneOff;
                           }
                        if(childDprAddOnOLI.Overridden_Unit_price__c != null && parentOLI.Quantity__c != null && parentOLI.Recontracting_Quantity__c != null)
                          childDprAddOnOLI.Overridden_Total_Price__c = childDprAddOnOLI.Overridden_Unit_price__c*(parentOLI.Quantity__c + parentOLI.Recontracting_Quantity__c);
                        
                        childDprOLIForAddOnUpsert.add(childDprAddOnOLI);
                    }
            }   
            
        }
        
        /** EDGE-177926 end **/
        //upsert dprOLIForUpsert;
        //upsert childDprOLIForUpsert;
        if(!childDprOLIForUpsert.isEmpty() && childDprOLIForUpsert != null){
            //update listOfDPROfferForUpdate;
            Database.UpsertResult[] upsertResultList = Database.upsert(childDprOLIForUpsert);
            for (Database.UpsertResult sr : upsertResultList) {
                if (!sr.isSuccess()) {
                    return new Map<Id,DPR_Offer_Line_Item__c>();//EDGE-223653-Sonar Cube Changes
                }
            }
        }
        /*
        if(!childDprOLIForAddOnUpsert.isEmpty()){
            upsert childDprOLIForAddOnUpsert;    
        }*/
        if(!childDprOLIForAddOnUpsert.isEmpty() && childDprOLIForAddOnUpsert != null){
            //update listOfDPROfferForUpdate;
            Database.UpsertResult[] upsertResultList = Database.upsert(childDprOLIForAddOnUpsert);
            for (Database.UpsertResult sr : upsertResultList) {


                if (!sr.isSuccess()) return new Map<Id,DPR_Offer_Line_Item__c>();//EDGE-223653-Sonar Cube Changes


            }
        }
        //final task to find OLIs to be delete
        //add both lists to map
        allNeededOLIs.putAll(dprOLIForUpsert); 
        allNeededOLIs.putAll(childDprOLIForUpsert);
        }catch(Exception ex){//EDGE-221893-Start
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','updateChildDPROfferLineItemsForAddonsAndDiscounts', '', '', ex.getMessage(), 'Generation of Agreement Document Failed.',false);
        }//EDGE-221893-End   
        return allNeededOLIs;
    }
    //EDGE-203808-Inserting DPR Offers-End

    //EDGE-211115 & EDGE-211116 ....Start
    public static void upsertRateCardAndRateCardLineItems(List<DPR_Offer_Line_Item__c> dprOLIForUpsert,Map<Id, Map<Id, Decimal>> mapOfRCvsRCL,Map<String,cspmb__Price_Item_Rate_Card_Association__c> mapOfCPvsRCAssociation,Map<String,cspmb__Rate_Card_Line__c> mapOfRCL,Map<Id,DPR_Rate_Card__c> mapOfExistingRateCard,Map<Id,DPR_Rate_Card__c> mapOfExistingRateCardLine){
        
        List<DPR_Rate_Card__c> lstToUpsertDPRRateCard=new List<DPR_Rate_Card__c>();
        List<DPR_Rate_Card__c> lstToUpsertDPRRateCardLine=new List<DPR_Rate_Card__c>();                                                                                               
        for (DPR_Offer_Line_Item__c parentOLI :dprOLIForUpsert) {

            if(mapOfCPvsRCAssociation!=null)// && mapOfCPvsRCAssociation.containsKey(parentOLI.cspmb_Price_Item__c)){
                if(mapOfRCvsRCL!=null){
                    for(String rcaKey:mapOfCPvsRCAssociation.keySet()){
                        cspmb__Price_Item_Rate_Card_Association__c rateCard=mapOfCPvsRCAssociation.get(rcaKey);
                        if(rateCard!=null && rateCard.cspmb__Rate_Card__c!=null && 
                           parentOLI.cspmb_Price_Item__c==rateCard.cspmb__Price_Item__c){

                        DPR_Rate_Card__c rcObj;
                        if(mapOfExistingRateCard.containsKey(rateCard.cspmb__Rate_Card__c)){
                            rcObj=mapOfExistingRateCard.get(rateCard.cspmb__Rate_Card__c);
                        }else{
                            rcObj=new DPR_Rate_Card__c();
                            rcObj.Delegated_Pricing_Request__c=parentOLI.Delegated_Pricing_Request__c;
                            rcObj.DPR_Rate_Card_Type__c='Rate Card';
                            rcObj.Parent_DPR_OLI_id__c=parentOLI.Id;
                            rcObj.Rate_Card__c=rateCard.cspmb__Rate_Card__c;
                        }

                        
                        lstToUpsertDPRRateCard.add(rcObj);
                    }
                    
                }
            }
        }                                                                                             

        if(!lstToUpsertDPRRateCard.isEmpty()){
            upsert lstToUpsertDPRRateCard;
            
            for(DPR_Rate_Card__c rc:lstToUpsertDPRRateCard){
                if(rc.Rate_Card__c!=null){
                    Map<Id,Decimal>  mapOfRCvsRCLValus=mapOfRCvsRCL.get(rc.Rate_Card__c);
                    if(mapOfRCvsRCLValus!=null){
                        for(Id rclKey:mapOfRCvsRCLValus.keySet()){
                            cspmb__Rate_Card_Line__c rcl=mapOfRCL.get(rclKey);
                            DPR_Rate_Card__c rclObj;
                            if(mapOfExistingRateCardLine.containsKey(rclKey)){
                                rclObj=mapOfExistingRateCardLine.get(rclKey);
                            }else{
                                rclObj=new DPR_Rate_Card__c();
                                rclObj.Parent_DPR_OLI_id__c=rc.Parent_DPR_OLI_id__c;
                            }
                            rclObj.Delegated_Pricing_Request__c=rc.Delegated_Pricing_Request__c;
                            rclObj.DPR_Rate_Card_Type__c='Rate Card Line';
                            rclObj.DPR_RC_Negotiated_Value__c=mapOfRCvsRCLValus.get(rclKey);
                            rclObj.Negotiated_Discount__c=rcl.cspmb__rate_value__c-mapOfRCvsRCLValus.get(rclKey);
                            rclObj.Parent_DPR_Rate_Card_ID__c=rc.Id;
                            rclObj.Rate_Card__c=rc.Rate_Card__c;
                            rclObj.Rate_Card_Line__c=rclKey;
                            lstToUpsertDPRRateCardLine.add(rclObj);
                        }
                    }
                }
            }
            
            if(!lstToUpsertDPRRateCardLine.isempty()){
                upsert lstToUpsertDPRRateCardLine;
            }
        } 
    }

}