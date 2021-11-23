/*
* @Desc : Refactored class for ProductBasketDataHandler with feature toggling
* @Jira : DIGI-518
*/
global with sharing class RF_ProductBasketDataHandler {
    static list <cscfga__Product_Configuration__c> prodcList = null;
    static Set <String> offers = null;
    static String offerFamily; 
    @TestVisible public static String val='Old';
    //helper method to get child product-configurations of basket    
    public static list <cscfga__Product_Configuration__c> getPCsForBasket(String basketId) {        
        ProductBasketDataHandler handler= new ProductBasketDataHandler();        

        prodcList = Test.isRunningTest() ? ((val == 'Old') ? ProductBasketDataHandler.getPCsForBasket(basketId) : BSK_Utilities.getPCsForBasket(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('BasketUtil', 'Old')) ? ProductBasketDataHandler.getPCsForBasket(basketId): BSK_Utilities.getPCsForBasket(basketId));    
        return prodcList;
    }
    //helper method to get status of Case-record(for ETC waiver) created for an opportunity 
    public static Map<id,String> getCaseStatusMap(String basketId){
        Map<id,String> caseStatusMap= new Map<id,String>();
        ProductBasketDataHandler handler= new ProductBasketDataHandler();        
        caseStatusMap= ProductBasketDataHandler.getCaseStatusMap(basketId);
        return caseStatusMap;
    }
    //Get parent products to dynamically show/hide Minimum Commitment table
    public List<Map<String,Object>> getParentProducts(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        rows=handler.getParentProducts(basketId);
        return rows;
    }
    //utility Method to check if value is a record-id
    static public Boolean isValidId(String strId) {
        Boolean isValid = ProductBasketDataHandler.isValidId(strId) ;
        return isValid ;
    }
    //hanlder to get the discount applied
    public List<String> getDiscountApplied(String pCId,Map<String,List<Discount_Line_Item__c>> mapOfDiscounts){
        List<String> listOfDiscountText=new List<String>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        listOfDiscountText= handler.getDiscountApplied(pCId, mapOfDiscounts);
        return listOfDiscountText;
    }
    
    //helper method to get distinct offers added in the basket
    public static Set <String> getOffersInBasket(String basketId) { 
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
     
        offers = Test.isRunningTest() ? ((val == 'Old') ? ProductBasketDataHandler.getOffersInBasket(basketId) : BSK_Utilities.getOffersInBasket(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('BasketUtil', 'Old')) ? ProductBasketDataHandler.getOffersInBasket(basketId) : BSK_Utilities.getOffersInBasket(basketId));
        return offers;       
    }
    //helper method to identify the offer-family for a selected offer
    public static String getOfferFamily(String offerName) {
       
        offerFamily = Test.isRunningTest() ? ((val == 'Old') ? ProductBasketDataHandler.getOfferFamily(offerName) : BSK_Utilities.getOfferFamily(offerName)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('BasketUtil', 'Old')) ? ProductBasketDataHandler.getOfferFamily(offerName) : BSK_Utilities.getOfferFamily(offerName));
        return offerFamily;
    }
    //Helper method to check if the account has an active Contract for the same offer
    public static boolean checkifContractExistsForAccount(String basketId, String Offer) {
        Boolean valAcc;
      
        valAcc = Test.isRunningTest() ? ((val == 'Old') ? ProductBasketDataHandler.checkifContractExistsForAccount(basketId, Offer) : CTR_Utilities.checkifContractExistsForAccount(basketId, Offer)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('CTRUtil', 'Old')) ? ProductBasketDataHandler.checkifContractExistsForAccount(basketId, Offer) : CTR_Utilities.checkifContractExistsForAccount(basketId, Offer));
        return valAcc;
    }
    //Method to bring data for table 'Changes to Existing Services' in Summary section of Quote/Orderform
    public List <Map <String, Object>> getSummaryForChangesToExisting(String basketID) {
        //bcf
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        BCF_Utilities bcfUtil = new BCF_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getSummaryForChangesToExisting(basketId) : bcfUtil.getSummaryForChangesToExisting(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('GST', 'Old')) ? handler.getSummaryForChangesToExisting(basketId) : bcfUtil.getSummaryForChangesToExisting(basketId));
        return rows;
    }
    //Method to populate New-Services table in summary section of quote/orderform
    public List <Map <String, Object>> getSummaryForNewServices(String basketId) { //bcf
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        BCF_Utilities bcfUtil = new BCF_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
       
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getSummaryForNewServices(basketId) : bcfUtil.getSummaryForNewServices(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('GST', 'Old')) ? handler.getSummaryForNewServices(basketId) : bcfUtil.getSummaryForNewServices(basketId));
        return rows;
    }
    //Method to populate new service table with recurring charge
    public List <Map <String, Object>> getSummaryForNewServicesRC(String basketId) { //bcf
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        BCF_Utilities bcfUtil = new BCF_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
 
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getSummaryForNewServicesRC(basketId) : bcfUtil.getSummaryForNewServicesRCRF(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('GST', 'Old')) ? handler.getSummaryForNewServicesRC(basketId) : bcfUtil.getSummaryForNewServicesRCRF(basketId));
        return rows;
    }
    //Method to calculate GST
    public static Map <Id, Decimal> getGSTIncPriceforPC(String basketId, Boolean incDisc) { //bcf
        Map <Id, Decimal> map_PCVSGSTIncPrice = new Map <Id, Decimal>();
 
        map_PCVSGSTIncPrice = Test.isRunningTest() ? ((val == 'Old') ? ProductBasketDataHandler.getGSTIncPriceforPC(basketId, incDisc) : BCF_Utilities.getGSTIncPriceforPCRF(basketId, incDisc)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('GST', 'Old')) ? ProductBasketDataHandler.getGSTIncPriceforPC(basketId, incDisc) : BCF_Utilities.getGSTIncPriceforPCRF(basketId, incDisc));
        return map_PCVSGSTIncPrice;
    }
    //Method to populate New-Services table in summary section of DOP quote/orderform
    public List <Map <String, Object>> getDOPServices(String basketId, Map <String, String> subfilters) { //bcf
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        BCF_Utilities bcfUtil = new BCF_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
    
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getDOPServices(basketId, subfilters) : bcfUtil.getDOPServices(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('GST', 'Old')) ? handler.getDOPServices(basketId, subfilters) : bcfUtil.getDOPServices(basketId, subfilters));
        return rows;
    }
    //Method to bring Mobility and Mobile-device details into BasketSnapshot, for displaying in Quote/Orderform
    public List <Map <String, Object>> getMobilityTypeProducts(String basketId, Map <String, String> subfilters) { //mobility
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        Mobility_Utilities util = new Mobility_Utilities();

        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getMobilityTypeProducts(basketId, subfilters) : util.getMobilityTypeProducts(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('MobilityUtil', 'Old')) ? handler.getMobilityTypeProducts(basketId, subfilters) : util.getMobilityTypeProducts(basketId, subfilters));
        return rows;
    }
    //Method to populate Early Termination Charges for Mobility Products
    public List <Map <String, Object>> getMobilityCancelTypeProducts(String basketId) { //mobility
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        Mobility_Utilities util = new Mobility_Utilities();
     
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getMobilityCancelTypeProducts(basketId) : util.getMobilityCancelTypeProducts(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('MobilityUtil', 'Old')) ? handler.getMobilityCancelTypeProducts(basketId) : util.getMobilityCancelTypeProducts(basketId));
        return rows;
    }
	//Method to populate line-items in Services-To-cancel table of Quote/Orderform
	public List <Map <String, Object>> getCancelTypeProducts(String basketId) { //mobility
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        Mobility_Utilities util = new Mobility_Utilities();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getCancelTypeProducts(basketId) : util.getCancelTypeProducts(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('MobilityUtil', 'Old')) ? handler.getCancelTypeProducts(basketId) : util.getCancelTypeProducts(basketId));
        return rows;
    }
    //Get Corporate Mobile Plus Services
    public List <Map <String, Object>> getCMPServices(String basketId, Map <String, String> subfilters) { //cmp
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        CMP_Utilities bcfUtil = new CMP_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
   
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getCMPServices(basketId, subfilters) : bcfUtil.getCMPServices(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('CMPUtil', 'Old')) ? handler.getCMPServices(basketId, subfilters) : bcfUtil.getCMPServices(basketId, subfilters));
        return rows;
    }
    //Method to get CMP Devices 
    public List <Map <String, Object>> getCMPDevices(String basketId, Map <String, String> subfilters) { //cmp
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        CMP_Utilities bcfUtil = new CMP_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();

        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getCMPDevices(basketId, subfilters) : bcfUtil.getCMPDevices(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('CMPUtil', 'Old')) ? handler.getCMPDevices(basketId, subfilters) : bcfUtil.getCMPDevices(basketId, subfilters));
        return rows;
    }
    //Method to get CMP-products of cancel type
    public List <Map <String, Object>> getCMPCancelProducts(String basketID, Map <String, String> subfilters) { //cmp
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        CMP_Utilities cmpUtil = new CMP_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
 
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getCMPCancelProducts(basketId, subfilters) : cmpUtil.getCMPCancelProducts(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('CMPUtil', 'Old')) ? handler.getCMPCancelProducts(basketId, subfilters) : cmpUtil.getCMPCancelProducts(basketId, subfilters));
        return rows;
    }
    //CMP-Committed Offer Quote/Orderform
    public List <Map <String, Object>> getCMPCommittedData(String basketId, Map <String, String> subfilters) { //cmp
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        CMP_Utilities cmpUtil = new CMP_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();

        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getCMPCommittedData(basketId, subfilters) : cmpUtil.getCMPCommittedData(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('CMPUtil', 'Old')) ? handler.getCMPCommittedData(basketId, subfilters) : cmpUtil.getCMPCommittedData(basketId, subfilters));
        return rows;
    }
    
    public static String calculateTotalDataforCommittedPlan(String Plan_Data, String Bonus_Data) { //cmp
        String total_data;
        CMP_Utilities bcfUtil = new CMP_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
  
        total_data = Test.isRunningTest() ? ((val == 'Old') ? ProductBasketDataHandler.calculateTotalDataforCommittedPlan(Plan_Data, Bonus_Data) : CMP_Utilities.calculateTotalDataforCommittedPlan(Plan_Data, Bonus_Data)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('CMPUtil', 'Old')) ? ProductBasketDataHandler.calculateTotalDataforCommittedPlan(Plan_Data, Bonus_Data) : CMP_Utilities.calculateTotalDataforCommittedPlan(Plan_Data, Bonus_Data));
        return total_data;
    }
    
    public List <Map <String, Object>> getTenancyDetails(String basketId, Map <String, String> subfilters) { //tenancy    
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        Tenancy_Utilities tenancy = new Tenancy_Utilities(); 

        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getTenancyDetails(basketId, subfilters) : tenancy.getTenancyDetails(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('TenancyUtil', 'Old')) ? handler.getTenancyDetails(basketId, subfilters) : tenancy.getTenancyDetails(basketId, subfilters));
        return rows;
    }
    //Below function is invoked from function getngUCCancel to calculate remaining terms of the contract.
    public static Integer calculateRemainingTermngUC(Date initialActivationDate, Date disconnectionDate, Integer contractTerm, BillingAccountDetailsDTO billAccDTO) { //nguc
        Integer remainingTerm;
 
        remainingTerm = Test.isRunningTest() ? ((val == 'Old') ? ProductBasketDataHandler.calculateRemainingTermngUC(initialActivationDate, disconnectionDate, contractTerm, billAccDTO) : NGUC_Utilities.calculateRemainingTermngUC(initialActivationDate, disconnectionDate, contractTerm, billAccDTO)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('NGUCUtil', 'Old')) ? ProductBasketDataHandler.calculateRemainingTermngUC(initialActivationDate, disconnectionDate, contractTerm, billAccDTO) : NGUC_Utilities.calculateRemainingTermngUC(initialActivationDate, disconnectionDate, contractTerm, billAccDTO));
        return remainingTerm;
    }
    
    public List <Map <String, Object>> getTIDDetails(String basketId, Map <String, String> subfilters) { //tid   
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        TID_Utilities tidUtil = new TID_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getTIDDetails(basketId, subfilters) : tidUtil.getTIDDetails(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('TIDUtil', 'Old')) ? handler.getTIDDetails(basketId, subfilters) : tidUtil.getTIDDetails(basketId, subfilters));
        return rows;
    }
    
    public List <Map <String, Object>> getTIDCancel(String basketId, Map <String, String> subfilters) { //tid 
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        TID_Utilities tidUtil = new TID_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getTIDCancel(basketId, subfilters) : tidUtil.getTIDCancel(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('TIDUtil', 'Old')) ? handler.getTIDCancel(basketId, subfilters) : tidUtil.getTIDCancel(basketId, subfilters));
        return rows;
    }
    //getSummaryforTotal charges
    public List <Map <String, Object>> getSummaryForNewCharges(String basketId) { //bcf
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        BCF_Utilities bcfUtil = new BCF_Utilities();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getSummaryForNewCharges(basketId) : bcfUtil.getSummaryForNewCharges(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('GST', 'Old')) ? handler.getSummaryForNewCharges(basketId) : bcfUtil.getSummaryForNewCharges(basketId));
        return rows;
    }
    
    public List <Map <String, Object>> getMobilityTransitionHardwareAndDevice(String basketId, Map <String, String> subfilters) { //mobility 
        list <Map <String, Object>> rows = new List <Map <String, Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        Mobility_Utilities util = new Mobility_Utilities();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getMobilityTransitionHardwareAndDevice(basketId, subfilters) : util.getMobilityTransitionHardwareAndDevice(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('MobilityUtil', 'Old')) ? handler.getMobilityTransitionHardwareAndDevice(basketId, subfilters) : util.getMobilityTransitionHardwareAndDevice(basketId, subfilters));
        return rows;
    }
    
    public List <Map <String, Object>> getBSMobilityTransition(String basketId) { //mobility
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        Mobility_Utilities util = new Mobility_Utilities();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getBSMobilityTransition(basketId) : util.getBSMobilityTransition(basketId)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('MobilityUtil', 'Old')) ? handler.getBSMobilityTransition(basketId) : util.getBSMobilityTransition(basketId));
        return rows;
    }
    
    public List <Map <String, Object>> getMDMProfServices(String basketId, Map <String, String> subfilters) { //mdm
        List <Map <String, Object>> rows = new List <Map <String, Object>>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        MDMPS_Utilities util = new MDMPS_Utilities();
        
        rows = Test.isRunningTest() ? ((val == 'Old') ? handler.getMDMProfServices(basketId, subfilters) : util.getMDMProfServices(basketId, subfilters)) : ((FeatureEligibilityChecker.determineFeatureEligiblity('MDMUtil', 'Old')) ? handler.getMDMProfServices(basketId, subfilters) : util.getMDMProfServices(basketId, subfilters));
        return rows;
    }
    //EDGE-114970 : Capturing redemption information in Order form for customer sign off
    public List<Double> offerWiseRedeemedAmountList(String basketId, String offerName){         
        List<Double> validRedeemAmtList = new List<Double>(); 
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        validRedeemAmtList= handler.offerWiseRedeemedAmountList(basketId, offerName);
        return validRedeemAmtList;
    }
    //Display Delegated Discounts in Quote Document
    public Boolean isPromotionApplied(String basketId){
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        Boolean val;
        val = handler.isPromotionApplied(basketId);
        return val;
    }
    
    public static list<cspmb__Price_Item_Add_On_Price_Item_Association__c> getPIsForPC(List<Id> piIds){
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> priceItemList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        priceItemList= ProductBasketDataHandler.getPIsForPC(piIds);
        return priceItemList;
    }
    
    //Delegation discounts to be displayed in the Quote& Order form document(MAC order) 
    public List<Map<String,Object>> getPromotionsApplied(String basketId,Map<String,String> subfilters){
        List<Map<String,Object>> rows = new List<Map<String,Object>>(); 
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        rows = handler.getPromotionsApplied(basketId,subfilters);
        return rows;
    }
    
    //Method to get list price From Product Configuration using discount value (Strategic solution). 
    public static Map<String,Double> getListPriceUsingDiscount(String basketId,List<cscfga__Product_Configuration__c> pcList){ 
        Map<String,Double> mapOfPCListPriceRC=new Map<String,Double>();
        ProductBasketDataHandler handler = new ProductBasketDataHandler();
        mapOfPCListPriceRC=ProductBasketDataHandler.getListPriceUsingDiscount(basketId,pcList);
        return mapOfPCListPriceRC;
    }
}