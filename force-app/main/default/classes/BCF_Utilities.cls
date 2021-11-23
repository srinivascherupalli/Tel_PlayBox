/*
* @Author : Mary Thangaraj
* @Created Date : 6/07/2021
* @Desc : BCF Utility called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
public with sharing class BCF_Utilities {
    static final String ngemDeviceProdSpecId = 'DMCAT_ProductSpecification_001211'; // EDGE-172118
    static final String AMDeviceProdSpecId = 'DMCAT_ProductSpecification_001342'; // EDGE-191284
    static final String ngemDeviceCare = 'DMCAT_ProductSpecification_001208'; //EDGE-176688
    public static List<String> productSpecCodes;
    static final String ngemAccProdSpecId= 'DMCAT_ProductSpecification_001389'; // DPG-3508-3708
    static final String mobileSubscription = 'DMCAT_ProductSpecification_000420';//EDGE-148534
    static final String internetSite = 'DMCAT_ProductSpecification_000747';//EDGE-148534
    static list<cscfga__Product_Configuration__c> parentProdcList = null;
    static final String deviceProdSpecificationId = 'DMCAT_ProductSpecification_000423';//EDGE-188062
    String etcAttr = 'EarlyTerminationCharge';//EDGE-148722
    static final String dopId = 'DMCAT_Offer_000783';
    public static List<String> lstDeviceSpecCode;
    public static List<String> ngUCAcceUCDSpecCode;
    public static List<String> lstEMSpecCodes;
    static final String RedeemFund = 'RedeemFundCopy' ; //EDGE-164623
    public static string CMPordertype = 'Transition to Corporate Mobile Plus';
    public static string CMPOffer = 'Corporate Mobile Plus';
    //DIGI-26659
    public static final string NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c;
    // public static string ngUCordertype = 'Transition to Telstra Collaboration';
    public static string ngUCordertype = 'Transition to ' + NGUC_OFFER_NAME;
    public static string ngUCOffer = 'PSTN/ISDN/ISDN2/ISDN30/TIPT/SIPC';
    public static string AMSCMPOffertype = 'Transition to Adaptive Mobility';//EDGE-170932
    public static string AMSCMPOffer = Label.ExistingMobPlan;//EDGE-170932 
    public static string NGEMPlanStr='NGEMPlan';
    public static string subtypeVal='Inflight Amend';
    public static List<String> lstIPSitesSpecCode;
    public static List<String> lstDevAccSpecCode;//DIGI-14501
    static final String IoTConnectivity = 'IoT Connectivity';//DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
    //Calculate GST based on PC's lookup configuration
    public BCF_Utilities(){
        AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();        
        lstIPSitesSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('IPSitesSpecCode'));
        lstDeviceSpecCode=new List<String>(AllCQEnvironmentVariable.getValueAsList('DeviceSpecCode'));
        ngUCAcceUCDSpecCode=new List<String>(AllCQEnvironmentVariable.getValueAsList('NGUCAcceUCD'));
        lstEMSpecCodes=new List<String>(AllCQEnvironmentVariable.getValueAsList('EMSpecCodes'));
        productSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ProductSpeccificationCode'));
        lstDevAccSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('DevAccSpecCode')); //DIGI-14501
    }
    public static Map<Id,Decimal> getGSTIncPriceforPCRF(String basketId, Boolean incDisc){
        
        List<String> attrIdList = new List<String>();
        List<String> ngemPlanPDId = new List<String>();
        Map<string, string> labelMap = new Map<string, string>();
        Map<Id,Decimal> map_PCVSGSTIncPrice=new Map<Id,Decimal>();
        Decimal rateOfGST = Decimal.valueOf(Label.GSTChargeRate);
        List<String> labelList = new List<String>{'ngemPlanPDName', 'ngemDataPDname', 'ngemVoicePDName', 'ngemCallMsgPDName', 'ngemIRPDName'};//add in custom label
            try{
                Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
                List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt where ProductCategory__c=:NGEMPlanStr];
                for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){                    
                    map_PDvsSecId.put(ngemSpec.Label,ngemSpec);                               
                }
                List<Apex_Label__mdt> labels = [Select id,Label, Value__c from Apex_Label__mdt where isActive__c = true];
                for(Apex_Label__mdt l:labels){
                    labelMap.put(l.label,l.value__c); 
                }
                if(map_PDvsSecId != null && !map_PDvsSecId.isEmpty()){
                    for (String labelStr : labelList) {                                               
                        if (labelMap.get(labelStr) != null)
                            ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get(labelStr)).ProdSpecId__c);
                    }               
                }
                
                List<cscfga__Product_Configuration__c> pcList =[SELECT id,add_on__r.taxTreatment__c,add_on__r.cspmb__Recurring_Charge__c,
                                                                cscfga__Product_Definition__r.product_Specification__c,cscfga__recurring_charge_line_discount_value__c, cscfga__recurring_charge_product_discount_value__c,
                                                                cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c FROM cscfga__Product_Configuration__c
                                                                WHERE cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId AND cscfga__Product_Basket__c=:basketId];
                for(cscfga__Product_Configuration__c pc:pcList) {            
                    Decimal totalRecChargeAddOn = 0.00;
                    Decimal recurringChargePC =0.00;
                    Decimal recurringChargePCGSTInc = 0.00;
                    if(incDisc)
                        recurringChargePC = pc.cscfga__total_recurring_charge__c + pc.cscfga__recurring_charge_line_discount_value__c + pc.cscfga__recurring_charge_product_discount_value__c; //EDGE-187507 added cscfga__recurring_charge_product_discount_value__c
                    else
                        recurringChargePC = pc.cscfga__total_recurring_charge__c;        
                    if(pc.add_on__r.taxTreatment__c == 'TAX Exempt'){
                        totalRecChargeAddOn = totalRecChargeAddOn + pc.add_on__r.cspmb__Recurring_Charge__c;
                    }
                    recurringChargePC = recurringChargePC - totalRecChargeAddOn;        
                    recurringChargePC = recurringChargePC + (recurringChargePC*rateOfGST);        
                    recurringChargePCGSTInc = recurringChargePC +  totalRecChargeAddOn;        
                    map_PCVSGSTIncPrice.put(pc.id,recurringChargePCGSTInc);
                }
            } 
        catch(Exception e)
        {
            C2O_Utilities.createException(e);
        }
        
        return map_PCVSGSTIncPrice;
    }
    //getSummaryforTotal charges
    public List <Map<String, Object>> getSummaryForNewCharges(String basketId) {
        List <Map<String, Object>> rows = new List <Map<String, Object>>();
        ProductBasketDataHandler util = new ProductBasketDataHandler();
        List <cscfga__Product_Configuration__c> pcList = new List <cscfga__Product_Configuration__c>();
        String paymentTypeStringAttr = 'PaymentTypeString'; //EDGE-176688          //DN: can be set as custom metadata?
        String oneOffPaymentTypeValue = 'Purchase'; //EDGE-176688                                       //DN: can be set as custom metadata?
        //String paymentTypeStringAttr = Label.Payment_Type_String;                                             
        // String oneOffPaymentTypeValue = Label.Oneoff_Payment_Type;
        Map<Id, Decimal> map_PCVSGSTInc;
        try {
            Integer externalID = 1;
            Map<String, Object> row = new Map<String, Object>();
            pcList = [SELECT ID, Name, cscfga__Product_Basket__r.name, type__c, cscfga__One_Off_Charge__c, cscfga__total_recurring_charge__c,cscfga__Quantity__c, cscfga__Parent_Configuration__c, subType__c, cscfga__total_one_off_charge__c, cscfga__Product_Definition__r.product_Specification__c, (SELECT Id, Name, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c from cscfga__Attributes__r) from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basketId AND subType__c !=:subtypeVal
                      AND Type__c != 'Active' AND Type__c!='PaidOut' 
                     ]; //EDGE-176688 | Added ProdSpec,oneoff fields //EDGE-200765 Added cscfga__Product_Basket__r.name field and !=Active condition            
            Decimal total_one_off_charge = 0.00;
            Decimal total_recurring_charge = 0.00;
            Decimal total_ETC_charge = 0.00;
            Decimal rcCharge = 0.00;
            Decimal total_recurring_charge_incGST = 0.00;
            Double sumOfNoFaultRedemption = 0.00;	
            String paymentType = ''; //EDGE-204960 	
            //EDGE-186680
            map_PCVSGSTInc = RF_ProductBasketDataHandler.getGSTIncPriceforPC(basketId, false);
            for (cscfga__Product_Configuration__c prodSpec: pcList) {
                //EDGE-176688 - Start ,EDGE-191284 added for AM
                if (prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId) || prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(AMDeviceProdSpecId) || prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare)) {
                    if (!(prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare))){ 
                        //if (prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId) || prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(AMDeviceProdSpecId)) {
                        for (cscfga__Attribute__c attribute: prodSpec.cscfga__Attributes__r) {	
                            if (attribute.Name == paymentTypeStringAttr) {	
                                paymentType = attribute.cscfga__Value__c;	
                            }	
                        }
                        for (cscfga__Attribute__c attribute: prodSpec.cscfga__Attributes__r) {
                            if (attribute.Name.equals(paymentTypeStringAttr) && attribute.cscfga__Value__c.equals(oneOffPaymentTypeValue) && (prodSpec.subType__c == null || prodSpec.subType__c != 'No Fault Return')) {
                                total_one_off_charge += prodSpec.cscfga__One_Off_Charge__c;                                
                            }
                            //EDGE-204960 Start 	
                            else if (paymentType != oneOffPaymentTypeValue && attribute.Name.equals('RC') && prodSpec.subType__c == 'No Fault Return' &&	
                                     attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != '') {	
                                         Decimal charges = decimal.valueOf(attribute.cscfga__Value__c) * (-1);	
                                         total_one_off_charge += charges;	
                                     } else if (paymentType == oneOffPaymentTypeValue && attribute.Name.equals('OC') && prodSpec.subType__c == 'No Fault Return' &&	
                                                attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != '') {	
                                                    Decimal charges = decimal.valueOf(attribute.cscfga__Value__c) * (-1);	
                                                    total_one_off_charge += charges;	
                                                }
                            if (paymentType == oneOffPaymentTypeValue && attribute.Name.equals('RedeemFundCopy') && prodSpec.subType__c == 'No Fault Return' &&	
                                attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != '') {	
                                    Decimal charges = decimal.valueOf(attribute.cscfga__Value__c);	
                                    System.debug('charges == ' + charges + ' prodSpec id == ' + prodSpec.Id);	
                                    total_one_off_charge += charges;	
                                    System.debug('total_one_off_charge in Purchase  == ' + total_one_off_charge + '');	
                                }	
                            //EDGE-204960 End	
                        }
                        if (prodSpec.subType__c != 'No Fault Return') {
                            if (map_PCVSGSTInc.containsKey(prodSpec.id)) {
                                total_recurring_charge_incGST += map_PCVSGSTInc.get(prodSpec.id);
                            } else {
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(prodSpec);
                                total_recurring_charge_incGST += ProductBasketDataHandler.calculateGSTIncludedPrice(rcCharge);
                            }
                            total_recurring_charge += rcCharge;
                        }
                    }
                    else {                        
                        if(System.Label.excludeAppleCareCancel == 'false')
                            total_one_off_charge += prodSpec.cscfga__One_Off_Charge__c;
                        else{
                            if(prodSpec.type__c!='Cancel'){
                                total_one_off_charge += prodSpec.cscfga__One_Off_Charge__c;
                            }
                        }                   
                    }
                }
                //EDGE-176688 - End               
                //DN: keep here?
                else if (prodSpec.cscfga__Parent_Configuration__c == null) { 
                    if(prodSpec.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID || prodSpec.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID)
                        total_one_off_charge += prodSpec.cscfga__total_one_off_charge__c*prodSpec.cscfga__Quantity__c;
                    else   
                        total_one_off_charge += prodSpec.cscfga__total_one_off_charge__c;
                    //EDGE-186680 - start
                    if (map_PCVSGSTInc.containsKey(prodSpec.id)) {
                        total_recurring_charge_incGST += map_PCVSGSTInc.get(prodSpec.id);
                    } else {
                        total_recurring_charge_incGST += ProductBasketDataHandler.calculateGSTIncludedPrice(prodSpec.cscfga__total_recurring_charge__c);
                    }
                    //EDGE-186680 - end
                    total_recurring_charge += prodSpec.cscfga__total_recurring_charge__c;
                    
                }
                for (cscfga__Attribute__c attr: prodSpec.cscfga__Attributes__r) {
                    if (prodSpec.cscfga__Parent_Configuration__c == null) { // added if condition for defect 188062
                        
                        //DN: 'EarlyTerminationCharge' can be set as custom metadata?
                        if (attr.name.equals('EarlyTerminationCharge') && attr.cscfga__Value__c != '0.00' && string.isNotEmpty(attr.cscfga__Value__c)) { //EDGE 188062 - added condition for new charges table as well
                            total_ETC_charge = total_ETC_charge + decimal.valueof(attr.cscfga__Value__c);
                        }
                    }
                }
            }
            sumOfNoFaultRedemption = 0 - sumOfNoFaultRedemption;	
            //EDGE-200765 Start
            if (!pcList.isEmpty()) {
                String basketName = pcList[0].cscfga__Product_Basket__r.name;
                Double sumOfBasketRedemption = 0;
                sumOfBasketRedemption = BasketRedemptionHelper.getBasket(basketName);                
                total_one_off_charge = total_one_off_charge - sumOfBasketRedemption;
            } //EDGE-200765 End
            row.put('ExternalId', String.valueOf(externalID));
            //DN: proposed code simplification below:
            /*
if (total_ETC_charge> 0) {
row.put('GSTExcl_Total_Onceoff_Charges', total_one_off_charge + total_ETC_charge);
row.put('GSTIncl_Total_Onceoff_Charges', calculateGSTIncludedPrice(total_one_off_charge + total_ETC_charge));
} else {
row.put('GSTExcl_Total_Onceoff_Charges', total_one_off_charge);
row.put('GSTIncl_Total_Onceoff_Charges', calculateGSTIncludedPrice(total_one_off_charge));
}

*/
            total_one_off_charge = (total_ETC_charge > 0) ? (total_one_off_charge + total_ETC_charge) : total_one_off_charge;
            row.put('GSTExcl_Total_Onceoff_Charges', total_one_off_charge);
            row.put('GSTIncl_Total_Onceoff_Charges', ProductBasketDataHandler.calculateGSTIncludedPrice(total_one_off_charge));                     
            row.put('GSTExcl_Total_Recurring_Charges', total_recurring_charge);
            row.put('GSTIncl_Total_Recurring_Charges', total_recurring_charge_incGST);
            //EDGE-171311 - Start           
            //DN: proposed code simplification below:
            /*

if ((decimal)(row.get('GSTExcl_Total_Onceoff_Charges')) <0)
row.put('GSTExcl_Total_Onceoff_Charges', '(' + (decimal)(row.get('GSTExcl_Total_Onceoff_Charges')) * -1 + ')');
if ((decimal)(row.get('GSTIncl_Total_Onceoff_Charges')) <0)
row.put('GSTIncl_Total_Onceoff_Charges', '(' + (decimal)(row.get('GSTIncl_Total_Onceoff_Charges')) * -1 + ')');
if ((decimal)(row.get('GSTExcl_Total_Recurring_Charges')) <0)
row.put('GSTExcl_Total_Recurring_Charges', '(' + (decimal)(row.get('GSTExcl_Total_Recurring_Charges')) * -1 + ')');
if ((decimal)(row.get('GSTIncl_Total_Recurring_Charges')) <0)
row.put('GSTIncl_Total_Recurring_Charges', '(' + (decimal)(row.get('GSTIncl_Total_Recurring_Charges')) * -1 + ')');

*/    
            //DN: put in a list and iterate
            
            
            List<String> chargeList = new List<String>{'GSTExcl_Total_Onceoff_Charges','GSTIncl_Total_Onceoff_Charges','GSTExcl_Total_Recurring_Charges', 'GSTIncl_Total_Recurring_Charges'};
                for (String currCharge : chargeList) {
                    if ((decimal)(row.get(currCharge)) < 0)
                        row.put(currCharge, '(' + (decimal)(row.get(currCharge)) * -1 + ')');
                }            
            //EDGE-171311 - End
            rows.add(row);
        } catch (Exception e) {
            C2O_Utilities.createException(e);
        }  
        System.debug('####Rows****'+ rows);
        return rows;
    }
    //Method to populate New-Services table in summary section of quote/orderform
    public List <Map<String, Object>> getSummaryForNewServices(String basketId) {
        List <Map<String, Object>> rows = new List <Map<String, Object>>();
        ProductBasketDataHandler util = new ProductBasketDataHandler();      
        Double sumOfBasketRedemption = 0;
        Integer extId = 0;        
        String paymentTypeStringAttr = 'PaymentTypeString'; //EDGE-176688    
        //String paymentTypeStringAttr = Label.Payment_Type_String;                                     
        String oneOffPaymentTypeValue = 'Purchase'; //EDGE-176688          
        //String oneOffPaymentTypeValue = Label.Oneoff_Payment_Type;
        String paymentTypeShadowAttr = 'PaymentTypeShadow'; // DPG-4690-Mahima                        
        try {
            Integer externalID = 1;
            //EDGE-117967 : Capture POS redemption information in Quotes
            String basketName = '';
            if (basketId.length()> 0) {
                List <cscfga__Product_Basket__c> basketNameList = [select name from cscfga__Product_Basket__c where id =: basketId];
                for (Integer i = 0; i <basketNameList.size(); i++) {
                    basketName = basketNameList[i].name;                    
                }
            }
            sumOfBasketRedemption = BasketRedemptionHelper.getBasket(basketName);
            sumOfBasketRedemption = 0 - sumOfBasketRedemption;            
            Set<String> offers = ProductBasketDataHandler.getOffersInBasket(basketId);            
            
            //List<Map<String,Object>> rows = new List<Map<String,Object>>();
            
            Map<String, Object> row = new Map<String, Object>();
            //EDGE-117738 Start
            //EDGE-141462 : EDGE-123791_New services is not coming in Order Summary section for Mac Order of CMP and NGUC,
            // so the filter added Type__c='New'
            //parentProdcList = [SELECT id,cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,Offer_Reference__r.Offer_Spec_Id__c,cscfga__Product_Configuration__c.Name, cscfga__Quantity__c, cssdm__solution_association__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId and (name IN :parentPCs or cscfga__Product_Family__c IN :productFamilies ) and Type__c='New'];
            // Query filter change
            parentProdcList = [SELECT id, Quantity_Product_Configuration__c, subtype__c, cscfga__Product_Definition__r.product_Specification__c, cscfga__Parent_Configuration__c, Marketable_Offer__r.Offer_ID__c, cscfga__total_one_off_charge__c, TotalGSTInclusiveTOC__c, type__c, cscfga__total_recurring_charge__c, TotalGSTInclusiveTRC__c, cscfga__total_contract_value__c, cscfga__One_Off_Charge__c, cscfga__Product_Family__c, Offername__c, Offer_Reference__r.Name, Offer_Reference__r.Offer_Spec_Id__c, cscfga__Product_Configuration__c.Name, cscfga__Quantity__c, cssdm__solution_association__c, (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Value__c FROM cscfga__Attributes__r)
                               from cscfga__Product_Configuration__c
                               where cscfga__Product_Basket__c =: basketId
                               and cscfga__Product_Definition__r.product_Specification__c IN: productSpecCodes
                               and(Type__c = 'New'
                                   OR Type__c = 'CHOWN') AND (cscfga__Parent_Configuration__c= null OR cscfga__Product_Definition__r.product_Specification__c =: ngemDeviceCare)
                              ]; //cscfga__Parent_Configuration__c==null added by sunil for Prod Incident INC000094305738 //EDGE-176688 - Removing Parent Config nullcheck to enable AMDeviceCare// EDGE-209790 added chown check
            
            //EDGE-210438(ngUC qty fix) - Added Quantity_Product_Configuration__c
            // Query filter change end            
            //EDGE-117738
            Decimal total_one_off_charge_exGST = 0.00;
            Decimal total_one_off_charge_incGST = 0.00; // Moved as per OneDeclarationPerLine SCA Rule
            Decimal total_recurring_charge_exGST = 0.00; //Moved as per OneDeclarationPerLine SCA Rule
            Decimal total_recurring_charge_incGST = 0.00; //Moved as per OneDeclarationPerLine SCA Rule
            for (String offer: offers) {              
                total_one_off_charge_exGST = 0.00;
                total_one_off_charge_incGST = 0.00;
                total_recurring_charge_exGST = 0.00;
                total_recurring_charge_incGST = 0.00;
                Integer cnt = 0; //Added as part of DPG-1311
                for (cscfga__Product_Configuration__c pc2: parentProdcList) { //EDGE-117738 Added parentProdcList
                    Map<Id, Decimal> mapCommittedDataCount = new Map<Id, Decimal>();
                    Map<Id, Id> mapCommittedDataSolnToPCMap = new Map<Id, Id>();
                    //EDGE-140420 END
                    if (pc2.Offername__c != null && (pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId) || pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(AMDeviceProdSpecId) || pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemAccProdSpecId) || pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare))) {
                    if (!(pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare))) {                            for (cscfga__Attribute__c attribute: pc2.cscfga__Attributes__r) {
                                //Updated By Mahima for DPG-4690 added paymentTypeShadowAttr
                                if ((attribute.Name.equals(paymentTypeStringAttr) || attribute.Name.equals(paymentTypeShadowAttr)) && attribute.cscfga__Value__c.equals(oneOffPaymentTypeValue)) {                                    
                                    total_one_off_charge_exGST += pc2.cscfga__One_Off_Charge__c;
                                    total_one_off_charge_incGST += ProductBasketDataHandler.calculateGSTIncludedPrice(pc2.cscfga__One_Off_Charge__c);                                
                                }
                            }
                        }
                        
                        //DN: simplify condition
                        else{
                            total_one_off_charge_exGST += pc2.cscfga__One_Off_Charge__c;
                            total_one_off_charge_incGST += ProductBasketDataHandler.calculateGSTIncludedPrice(pc2.cscfga__One_Off_Charge__c);                    
                        }
                    }
                    //EDGE-176688 - End
                    //DN: keep here?
                    else if (pc2.Offername__c != null && (ProductBasketDataHandler.getOfferFamily(pc2.Marketable_Offer__r.Offer_ID__c)).equalsIgnoreCase(offer) && pc2.cscfga__Parent_Configuration__c == null) {                        
                        // EDGE-210438(ngUC qty fix) Start
                        if (pc2.cscfga__Product_Definition__r.product_Specification__c == DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID || pc2.cscfga__Product_Definition__r.product_Specification__c == DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID) {
                            total_one_off_charge_exGST += pc2.cscfga__total_one_off_charge__c * pc2.Quantity_Product_Configuration__c;
                            total_one_off_charge_incGST += ProductBasketDataHandler.calculateGSTIncludedPrice(pc2.cscfga__total_one_off_charge__c * pc2.Quantity_Product_Configuration__c);
                        } // EDGE-210438(ngUC qty fix) End	
                        else if (offer != null && offer == IoTConnectivity) {	
                            total_one_off_charge_exGST += pc2.cscfga__total_one_off_charge__c * pc2.Quantity_Product_Configuration__c;	
                            total_one_off_charge_incGST += ProductBasketDataHandler.calculateGSTIncludedPrice(pc2.cscfga__total_one_off_charge__c * pc2.Quantity_Product_Configuration__c);	
                        }
                        else {
                            total_one_off_charge_exGST += pc2.cscfga__total_one_off_charge__c;                            
                            total_one_off_charge_incGST += ProductBasketDataHandler.calculateGSTIncludedPrice(pc2.cscfga__total_one_off_charge__c); //EDGE-162365 Defect Fix
                            total_recurring_charge_exGST += pc2.cscfga__total_recurring_charge__c;
                        }                       
                        cnt++; //Added as part of DPG-1311
                    }
                }                
                row.put('Offer_Name', offer);                
                row.put('ExternalId', String.valueOf(externalID));
                externalID++;
                row.put('Total_Once_Off', total_one_off_charge_exGST);               
                row.put('GSTIncl_Total_Onceoff_Charges', total_one_off_charge_incGST); //EDGE-162365                
                //DPG - 597
                if (offer != null && !(offer == Label.IoTOfferName) || !(offer == IoTConnectivity)){ //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021)                 
                    row.put('Total_Recurring_Charges', total_recurring_charge_exGST);
                    row.put('GSTIncl_Total_Recurring_Charges', ProductBasketDataHandler.calculateGSTIncludedPrice(total_recurring_charge_exGST));
                }
                //Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan - no need to show RC in order form
                /* else
{
row.put('Total_Recurring_Charges',cnt*Decimal.ValueOf(Label.IoTRecurCharge)); //Added as part of DPG-1311
row.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(cnt*Decimal.ValueOf(Label.IoTRecurCharge))); //Added as part of DPG-1311
} */
                row.put('Term', '36 Months');
                //EDGE-117967 : Capture POS redemption information in Quotes               
                row.put('BasketRedeemAmtQuote', (sumOfBasketRedemption)); //EDGE-197766: Modified
                row.put('GSTInclBasketRedeemAmtQuote', sumOfBasketRedemption * 1.1); //EDGE-197766: Modified
                rows.add(row);
                //EDGE-117967 : Capture POS redemption information in Quotes
                extId = externalID;
                row = new Map<String, Object>();
            }
            //EDGE-117967 : Fetch Redemption amount in Quotes for summarised view 
            if (sumOfBasketRedemption != 0) {
                extId++;
                row.put('Offer_Name', System.Label.Telstra_Enterprise_Plus_Fund);
                row.put('ExternalId', String.valueOf(extId));
                row.put('Total_Once_Off', (sumOfBasketRedemption)); //EDGE-197766: Modified
                row.put('GSTIncl_Total_Onceoff_Charges', sumOfBasketRedemption * 1.1); //EDGE-197766: Modified
                row.put('Total_Recurring_Charges', 0.00);
                row.put('GSTIncl_Total_Recurring_Charges', 0.00);
                rows.add(row);
            }
        } catch (Exception e) {
            C2O_Utilities.createException(e);
        }
		System.debug('####Rows**** '+rows);          
        return rows;
    }
    //Method to bring data for table 'Changes to Existing Services' in Summary section of Quote/Orderform
    public List<Map<String,Object>> getSummaryForChangesToExisting(String basketID){
        //Map to maintain different types of orders in basket - Transition,Change,Cancel
        //EDGE-16462
        ProductBasketDataHandler util = new ProductBasketDataHandler();        
        Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
        String ngemCarePDName = 'Mobile Device Care';
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        try{
            List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];
            for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){
                if(ngemSpec.ProductCategory__c=='NGEM'){
                    map_PDvsSecId.put(ngemSpec.Label,ngemSpec);
                }
            }
            //EDGE-164623 End 
            //EDGE-123791,EDGE-123792: Changed Order Type 'Change' to 'Change Commercial Configuration', EDGE-210438 Changed 'Change Commercial Configuration' to 'Change service Configuration'
            Map<String,List<Map<String,Object>>> summaryOfOrder =new Map<String,List<Map<String,Object>>>{DataHandlerConstants.modifyChangeType => new List<Map<String,Object>>() , 'Transition to Connected Workplace' => new List<Map<String,Object>>(),'Transition to Corporate Mobile Plus' => new List<Map<String,Object>>(), 'Transition to Adaptive Collaboration'=> new List<Map<String,Object>>(),'Transition to Adaptive Mobility' => new List<Map<String,Object>>(),'Cancel' => new List<Map<String,Object>>()};        
                Double sumOfNoFaultRedemption = 0.0;
            //query to get PCR for IP-site 
            //EDGE-80772 : Rewritten for Solution Console retrofit
            //EDGE-110648 : Defect fix for Modify of CMP           
            //EDGE-127780 Start
            List<cscfga__Product_Configuration__c> planTCPCList = new List<cscfga__Product_Configuration__c>();
            //EDGE-148534 Modified below query
            planTCPCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN (:mobileSubscription,:internetSite) AND cscfga__Product_Basket__c = :basketID AND Type__c='Cancel'];
            //EDGE-148534 Start
            if(basketID == null)
            {
                return rows;
            }  
            //EDGE-148534  End
            
            Map<Id,String> map_PCvsETCAttrib = new Map<Id,String>(); 
            for(cscfga__Product_Configuration__c pc:planTCPCList)
            {
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r)
                {
                    if(attribute.name=='EarlyTerminationCharge')
                    {
                        map_PCvsETCAttrib.put(pc.id,attribute.cscfga__Value__c);
                    }
                }
            }  
            //EDGE-127780 End  
            List<String> parentPCs = new list<String>{'Unified Communication','IP Site','MDM Tenancy','Next Generation Voice','Enterprise Mobility'};
                //EDGE-165326 added Product Family | Refactoring for this to be taken as part of utility method for EDGE-135349
                /*List<cscfga__Product_Configuration__c> pcrlist = Database.query('select id,Marketable_Offer__r.Offer_ID__c,csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c,cscfga__One_Off_Charge__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,'+
'cscfga__unit_one_off_charge__c,cscfga__Product_Family__c,'+
'name,cscfga__Product_Basket__r.name,cscfga__Contract_Term__c,'+
'Type__c,OfferName__c,Offer_Reference__r.Name,'+
'csordtelcoa__Replaced_Product_Configuration__c,'+
'csordtelcoa__Replaced_Subscription__r.Name,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r),'+//EDGE-148722 - Added attributes inner query
'(select id,name from attachments where name like \'%Transition%\')'+
' from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=\''+String.escapeSingleQuotes(basketID) +'\'  and cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes AND Type__c NOT IN (\'Active\')');
*/
                List<cscfga__Product_Configuration__c> pcrlist = [select id,Marketable_Offer__r.Offer_ID__c,csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c,cscfga__One_Off_Charge__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,
                                                                  cscfga__unit_one_off_charge__c,cscfga__Product_Family__c,
                                                                  subtype__c,name,cscfga__Product_Basket__r.name,cscfga__Contract_Term__c,
                                                                  Type__c,OfferName__c,Offer_Reference__r.Name,
                                                                  csordtelcoa__Replaced_Product_Configuration__c,
                                                                  csordtelcoa__Replaced_Subscription__r.Name,
                                                                  (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r),//EDGE-148722 - Added attributes inner query
                                                                  (SELECT id,name from attachments WHERE name like '%Transition%')
                                                                  from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketID and cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes AND Type__c NOT IN ('Active')];
            
            
            //query to get body of all TransitionJSON for basket 
            //String soqlQueryAttachment = 'SELECT Id,name,body,ParentId FROM Attachment WHERE ParentId IN(SELECT Id FROM cscfga__Product_Configuration__c where cscfga__Product_Basket__c=\''+ String.escapeSingleQuotes(basketID) +'\') and name like \'%Transition%\'';                
            List<Attachment> queryAtt=[SELECT Id,name,body,ParentId FROM Attachment WHERE ParentId IN(SELECT Id FROM cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketID) and name like '%Transition%'];
            Map<id,string> pcrWithAttachment = new Map<id,string> ();
            // EDGE-155245 Added flag for transition
            boolean isTransition;
            //for(Attachment att:Database.query(soqlQueryAttachment)){
            for(Attachment att:queryAtt){
                pcrWithAttachment.put(att.ParentId,att.body.tostring());
                isTransition = true;
            }
            String tempOffername='';
            String CMPConfig= System.Label.ProductSpecificationMobile;//EDGE - 117740
            //Manoj : EDGE-117738
            List < String > productSpecNgUcList = Label.ProductSpecificationNgUc.split(',');       
            Boolean contractExists = ProductBasketDataHandler.checkifContractExistsForAccount(basketID,'');
            Map<id,String> caseStatusMap = ProductBasketDataHandler.getCaseStatusMap(basketID);
            Set<String> offers = new Set<String>();
            Map<String,Object> row = null;
            Integer externalId = 1;
            String oneOffPaymentTypeValue = 'Purchase';	
            String repaymentPaymentTypeValue = 'Hardware Repayment';	
            String paymentType = '';	
            
            //EDGE-80772 : Rewritten for Solution Console retrofit -Start
            for(cscfga__Product_Configuration__c prConfigRequest:pcrlist){
                row = new Map<String,Object>();             
                //check if the PC are of modify-type
                if((prConfigRequest.type__c=='New' && contractExists==true)||(prConfigRequest.type__c=='Modify'|| prConfigRequest.csordtelcoa__Replaced_Product_Configuration__c!=null)){
                    //EDGE-165831 - Chnaged method parameter
                    tempOffername = (String.valueOf(prConfigRequest.Marketable_Offer__r.Offer_ID__c)==null?prConfigRequest.csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c:String.valueOf(prConfigRequest.Marketable_Offer__r.Offer_ID__c));
                    //EDGE-165831 end
                    tempOffername = ProductBasketDataHandler.getOfferFamily(tempOffername);
                    row.put('Existing_Service',tempOffername);
                    //end EDGE-67629   
                    if(prConfigRequest.type__c=='Cancel'){
                        row.put('Order_Type','Cancel');                    
                        if(caseStatusMap.get(prConfigRequest.id)!=null){                        
                            row.put('GSTExcl_TotalETC','Waived'); 
                            row.put('GSTIncl_TotalETC','Waived'); 
                        }
                        else{
                            //Manoj : EDGE : 63432 : 05/Feb/2019 : Start 
                            /*row.put('GSTExcl_TotalETC','$'+prConfigRequest.cscfga__unit_one_off_charge__c); 
row.put('GSTIncl_TotalETC','$'+calculateGSTIncludedPrice(prConfigRequest.cscfga__unit_one_off_charge__c)); */
                            //EDGE-148722 Start
                            //EDGE-204960  Start
                            for(cscfga__Attribute__c attribute:prConfigRequest.cscfga__Attributes__r) {
                                if(attribute.name == 'PaymentTypeString'){
                                    paymentType = attribute.cscfga__Value__c;
                                    break;
                                }
                            }
                            //EDGE-204960  End
                            for(cscfga__Attribute__c attribute:prConfigRequest.cscfga__Attributes__r) {
                                if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){                                
                                    if(attribute.name.equals(etcAttr) && attribute.cscfga__Value__c != null && prConfigRequest.cscfga__Product_Definition__r.product_Specification__c!=deviceProdSpecificationId && prConfigRequest.subType__c != 'No Fault Return'){ //EDGE-174805 added overridden null check. No changes in Test Class
                                        row.put('GSTExcl_TotalETC','$'+string.valueOf(attribute.cscfga__Value__c));
                                        if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                        row.put('GSTIncl_TotalETC','$'+string.valueOf(attribute.cscfga__Value__c));
                                        }
                                        else{
                                        row.put('GSTIncl_TotalETC','$'+string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c))));
                                        }
                                        
                                    }
                                    //EDGE-204960  Start 
                                    else if(prConfigRequest.subType__c == 'No Fault Return' && paymentType.equals(oneOffPaymentTypeValue) 
                                            && attribute.name.equals('OC') && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != ''/* DIGI-6250 Starts*/ && double.valueof(attribute.cscfga__Value__c) != 0 /*DIGI-6250 Ends*/){//display one month charges in case of HRO- no fault return
                                                
                                                double existingETC = (decimal.valueOf(attribute.cscfga__Value__c)*(-1));
                                                row.put('GSTExcl_TotalETC','$'+string.valueOf(existingETC));
                                                if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                                row.put('GSTIncl_TotalETC','$'+string.valueOf(existingETC));
                                                }
                                                else{
                                                row.put('GSTIncl_TotalETC','$'+string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                                }
                                                
                                            }
                                    else if(prConfigRequest.subType__c == 'No Fault Return' && paymentType.equals(repaymentPaymentTypeValue) 
                                            && attribute.name.equals('RC') && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != ''/*DIGI-6250 Starts*/ && double.valueof(attribute.cscfga__Value__c) != 0 /*DIGI-6250 Ends*/){//display one month charges in case of HRO- no fault return
                                                
                                                double existingETC = (decimal.valueOf(attribute.cscfga__Value__c)*(-1));
                                                row.put('GSTExcl_TotalETC','$'+string.valueOf(existingETC));
                                                if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                                row.put('GSTIncl_TotalETC','$'+string.valueOf(existingETC));
                                                }
                                                else{
                                                row.put('GSTIncl_TotalETC','$'+string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                                }
                                            }
                                    
                                    else if((prConfigRequest.subType__c != null && prConfigRequest.subType__c.equals('No Fault Return') ) && paymentType.equals(oneOffPaymentTypeValue) && attribute.name.equals('RedeemFundCopy') 
                                            && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != '' /*DIGI-6250 Starts*/ && double.valueof(attribute.cscfga__Value__c) != 0 /*DIGI-6250 Ends*/){ 
                                                
                                                sumOfNoFaultRedemption = sumOfNoFaultRedemption +Double.valueOf(attribute.cscfga__Value__c);
                                                double existingETC = double.valueOf(attribute.cscfga__Value__c); 
                                                row.put('GSTExcl_TotalETC','$'+string.valueOf(existingETC));
                                                if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                                row.put('GSTIncl_TotalETC','$'+string.valueOf(existingETC));
                                                }
                                                else{
                                                row.put('GSTIncl_TotalETC','$'+string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                                }
                                            } 
                                    //EDGE-204960  End
                                }
                                //EDGE-148722 End
                            }         
                            //Manoj : EDGE : 63432 : 05/Feb/2019 : End
                        }
                        offers.add(tempOffername); //EDGE-173365
                        summaryOfOrder.get('Cancel').add(row);
                        
                    }
                    else{
                        //EDGE-147912 | Excluding PaidOut details // EDGE-155245 excluded Transition pc                     
                        // refactor
                        if((!(ngUCAcceUCDSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && prConfigRequest.cscfga__unit_one_off_charge__c!=0)) && prConfigRequest.type__c!='PaidOut' && isTransition != true){
                            //EDGE-123791,EDGE-123792: Changed Order Type 'Change' to 'Change Commercial Configuration',EDGE-210438 Changed 'Change Commercial Configuration' to 'Change service Configuration'
                            row.put('Order_Type',DataHandlerConstants.modifyChangeType);
                            row.put('GSTExcl_TotalETC','$0.00');
                            row.put('GSTIncl_TotalETC','$0.00');
                            //EDGE-123791,EDGE-123792: Changed Order Type 'Change' to 'Change Commercial Configuration',
                            offers.add(tempOffername); //EDGE-173365
                            summaryOfOrder.get(DataHandlerConstants.modifyChangeType).add(row);//EDGE-210438 Changed 'Change Commercial Configuration' to 'Change service Configuration'
                        }
                    }    
                    row.put('ExternalId', String.valueOf(externalId));
                    rows.add(row);
                    externalId++;
                }else if(prConfigRequest.type__c=='New'){    //EDGE-80772 : Rewritten for Solution Console retrofit - End
                    for(attachment attachment:prConfigRequest.attachments){
                        ReplicatorGetServiceDataObject serviceObjDTO = ReplicatorGetServiceDataObject.parse(pcrWithAttachment.get(prConfigRequest.id));
                        // EDGE - 117740 - Transitin fro Brand New account
                        Map<String,Object> newTransrow = new Map<String,Object>();
                        // filter change
                        if(lstEMSpecCodes.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && prConfigRequest.cscfga__Product_Definition__r.product_Specification__c == CMPConfig){
                            newTransrow .put('Existing_Service',String.valueOf(CMPOffer));
                            offers.add(String.valueOf(CMPOffer));
                            newTransrow.put('Order_Type',CMPordertype );
                            //EDGE-150587 - ETC changed from Waived to NA- Not available
                            newTransrow.put('GSTExcl_TotalETC','NA- Not available');
                            newTransrow.put('GSTIncl_TotalETC','NA- Not available');
                            newTransrow.put('ExternalId', String.valueOf(externalId));
                            rows.add(newTransrow);
                            externalId++;
                            summaryOfOrder.get(CMPordertype).add(newTransrow);
                        }
                        // EDGE-117738 Transition nguc,EDGE-210438 Fetch value from DataHandlerConstants
                        if((prConfigRequest.cscfga__Product_Family__c==DataHandlerConstants.ngUCPlan) && productSpecNgUcList.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c)){
                            newTransrow.put('Existing_Service',String.valueOf(ngUCOffer));
                            offers.add(String.valueOf(ngUCOffer));
                            newTransrow.put('Order_Type',ngUCordertype );
                            newTransrow.put('GSTExcl_TotalETC','NA - Not Applicable');//EDGE-210438
                            newTransrow.put('GSTIncl_TotalETC','NA - Not Applicable');//EDGE-210438  
                            newTransrow.put('ExternalId', String.valueOf(externalId));
                            rows.add(newTransrow);
                            externalId++;
                            summaryOfOrder.get(ngUCordertype).add(newTransrow);
                        }
                        // end
                        if(serviceObjDTO.site!=null){
                            for(ReplicatorGetServiceDataObject.SiteDTO siteObj : serviceObjDTO.site)
                            {
                                for(ReplicatorGetServiceDataObject.ProductDTO prod: siteObj.productList)
                                {
                                    Map<String,Object> newrow = new Map<String,Object>();                           
                                    if(prod.checkValue){
                                        // filter change
                                        if(lstIPSitesSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c)){//EDGE - 117740
                                            newrow.put('Existing_Service',String.valueOf(prod.Product_Type));
                                            offers.add(String.valueOf(prod.Product_Type));
                                            newrow.put('Order_Type','Transition to Connected Workplace');
                                            //EDGE-150587 - ETC changed from Waived to NA- Not available
                                            newrow.put('GSTExcl_TotalETC','NA- Not available');
                                            newrow.put('GSTIncl_TotalETC','NA- Not available');   
                                            newrow.put('ExternalId', String.valueOf(externalId));
                                            rows.add(newrow);
                                            externalId++;
                                            summaryOfOrder.get('Transition to Connected Workplace').add(newrow);
                                        }
                                    }
                                }
                            }
                        }                    
                    }                
                }
                // Changed for 117740 - Start for existing CMP.
                if(prConfigRequest.type__c=='New'){                
                    for(attachment attachment:prConfigRequest.attachments){
                        Map<String,Object> newrow = new Map<String,Object>();
                        // EDGE-165831 - Query Filter Change
                        if(lstEMSpecCodes.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && prConfigRequest.cscfga__Product_Definition__r.product_Specification__c == CMPConfig){
                            newrow.put('Existing_Service',String.valueOf(CMPOffer));
                            offers.add(String.valueOf(CMPOffer));
                            newrow.put('Order_Type',CMPordertype );
                            //EDGE-150587 - ETC changed from waived to NA- Not available
                            newrow.put('GSTExcl_TotalETC','NA- Not available');
                            newrow.put('GSTIncl_TotalETC','NA- Not available');
                            newrow.put('ExternalId', String.valueOf(externalId));
                            rows.add(newrow);
                            externalId++;
                            summaryOfOrder.get(CMPordertype).add(newrow);
                        }
                        //NGUC Transition : Manoj : EDGE-117738 Transition Start,EDGE-210438 - fetching value from DataHandlerConstants
                        if((prConfigRequest.cscfga__Product_Family__c==DataHandlerConstants.ngUCPlan) && productSpecNgUcList.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c)){
                            newrow.put('Existing_Service',String.valueOf(ngUCOffer));
                            offers.add(String.valueOf(ngUCOffer));
                            newrow.put('Order_Type',ngUCordertype );
                            newrow.put('GSTExcl_TotalETC','NA - Not Applicable');//EDGE-210438
                            newrow.put('GSTIncl_TotalETC','NA - Not Applicable');//EDGE-210438 
                            newrow.put('ExternalId', String.valueOf(externalId));
                            rows.add(newrow);
                            externalId++;
                            summaryOfOrder.get(ngUCordertype).add(newrow);
                        }
                        //NGUC Transition : Manoj : End                
                    }                
                } // Changed for 117740 - End
            }
            //EDGE-173365 --- Start
            List<Legacy_Service__c> legacySrvLst = [SELECT Id FROM Legacy_Service__c WHERE Product_Basket__c=:basketID AND Product_Type__c='Enterprise Mobility' AND Select__c = TRUE];
            if(legacySrvLst != null && legacySrvLst.size()>0){
                Map<String,Object> newAMTransRow = new Map<String,Object>();
                newAMTransRow.put('Existing_Service',String.valueOf(AMSCMPOffer));
                newAMTransRow.put('Order_Type',AMSCMPOffertype);
                newAMTransRow.put('GSTExcl_TotalETC','N/A');
                newAMTransRow.put('GSTIncl_TotalETC','N/A');
                newAMTransRow.put('ExternalId', String.valueOf(externalId));
                externalId++;
                offers.add(String.valueOf(AMSCMPOffer));
                rows.add(newAMTransRow);
                summaryOfOrder.get(AMSCMPOffertype).add(newAMTransRow); 
            }
            //EDGE-173365 --- End    
            rows=ProductBasketDataHandler.groupByOrderTypeAndExistingService(summaryOfOrder,offers);        
            //EDGE-164623
            decimal totalVal=0;
            for(cscfga__Product_Configuration__c prConfigRequest:pcrlist){
                if(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){
                    for(cscfga__Attribute__c attribute:prConfigRequest.cscfga__Attributes__r) {
                        if(attribute.name.equals(RedeemFund) && attribute.cscfga__Value__c != '0.00' && string.isNotEmpty(attribute.cscfga__Value__c) )
                        {
                            totalVal = totalVal + decimal.valueof(attribute.cscfga__Value__c);
                        } 
                    }
                }
            }   
            if(totalVal > 0){
                totalVal = 0 - totalVal;
                Map<String,Object> appleCareOneFund = new Map<String,Object>();
                appleCareOneFund.put('Existing_Service',System.Label.Telstra_Enterprise_Plus_Credit);
                appleCareOneFund.put('ExternalId', String.valueOf(externalId));              
                appleCareOneFund.put('GSTExcl_TotalETC',string.valueOf(totalVal));     //EDGE-197766: Modified          
                appleCareOneFund.put('GSTIncl_TotalETC',string.valueOf((totalVal*1.1).setScale(2))); //EDGE-197766: Modified
                rows.add(appleCareOneFund);
                externalId++;
            }
            //EDGE-164623 End 
            //EDGE-155059 Start
            String basketName = pcrlist[0].cscfga__Product_Basket__r.name;//Changed logic for fetching basketname as per review comments for EDGE-155059
            Double sumOfBasketRedemption=0;
            sumOfBasketRedemption = BasketRedemptionHelper.getBasket(basketName);        
            if(sumOfBasketRedemption != 0){
                Map<String,Object> rowRdeem = new Map<String,Object>();
                sumOfBasketRedemption = 0 - sumOfBasketRedemption;
                rowRdeem.put('Existing_Service',System.Label.Telstra_Enterprise_Plus_Fund);
                rowRdeem.put('ExternalId', String.valueOf(externalId));             
                rowRdeem.put('GSTExcl_TotalETC',sumOfBasketRedemption);      //EDGE-197766: Modified                    
                rowRdeem.put('GSTIncl_TotalETC',(sumOfBasketRedemption*1.1).setScale(2)); //EDGE-197766: Modified          
                rows.add(rowRdeem);
                externalId++;
            }
            //EDGE-204960  Start
            /*sumOfNoFaultRedemption = 0 - sumOfNoFaultRedemption;*/
            if(sumOfNoFaultRedemption > 0){
                Map<String,Object> rowRdeem = new Map<String,Object>();               
                rowRdeem.put('Existing_Service',System.Label.Telstra_Enterprise_Plus_Fund_Credit);
                rowRdeem.put('ExternalId', String.valueOf(externalId));             
                rowRdeem.put('GSTExcl_TotalETC',sumOfNoFaultRedemption);      //EDGE-197766: Modified                    
                rowRdeem.put('GSTIncl_TotalETC',(sumOfNoFaultRedemption*1.1).setScale(2)); //EDGE-197766: Modified          
                rows.add(rowRdeem);
                externalId++;
            }
            //EDGE-204960  End
            //EDGE-155059 End
            
            //Changes End- EDGE-44968
        }
        catch(Exception e){
            C2O_Utilities.createException(e);
        }
        System.debug('####Rows**** '+rows); 
        return rows;
    }
    //Method to populate new service table with recurring charge
    public List<Map<String,Object>> getSummaryForNewServicesRCRF(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        ProductBasketDataHandler util = new ProductBasketDataHandler();
        Integer extId=0;
        try{
            Integer externalID=1;
            Set<String> offers = ProductBasketDataHandler.getOffersInBasket(basketId);            
            Map<String,Object> row = new Map<String,Object>();
            Map<String,Decimal> mapOfOffervsCLIDiscount=new Map<String,Decimal>();
            Map<String,Decimal> mapOfOffervsatrrPrice=new Map<String,Decimal>();
            //EDGE-121387, EDGE-133760
            Map<String,cscfga__Product_Configuration__c> mapOfpcIdvsPCs=new Map<String,cscfga__Product_Configuration__c>();
            Map<String,List<Charge_Line_Item__c>> mapOfOfferVsCLI = new Map<String,List<Charge_Line_Item__c>>(); 
			List<cscfga__Product_Configuration__c> parentProdcList = [SELECT id,Name,Quantity_Product_Configuration__c,Marketable_Offer__r.Offer_ID__c,cscfga__discounts__c,cscfga__total_one_off_charge__c,cscfga__Parent_Configuration__c,cscfga__recurring_charge_line_discount_value__c,cscfga__recurring_charge_product_discount_value__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,Offer_Reference__r.Offer_Spec_Id__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Recurring_Charge__c,subType__c,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.type__c, cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.id,cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r) from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId AND cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes AND (Type__c='New' OR Type__c = 'CHOWN') AND subType__c !=:subtypeVal]; //EDGE-176688 | Added ProdSpec field //EDGE-209790 added CHOWN check
            //EDGE-166406 Start
            Map<Id,Decimal> map_PCVSGSTIncprice;
            map_PCVSGSTIncprice = RF_ProductBasketDataHandler.getGSTIncPriceforPC(basketId,false);
            Map<Id,Decimal> map_PCVSGSTIncpriceIncDisc;
            map_PCVSGSTIncpriceIncDisc = RF_ProductBasketDataHandler.getGSTIncPriceforPC(basketId,true);
            //EDGE-166406 End
            Boolean isDiscountUpdatedOnPC=False;            
            if(parentProdcList!=null && !parentProdcList.isEmpty()){
                for(cscfga__Product_Configuration__c pc:parentProdcList){                    
                    if(pc.Offername__c!=null){
                        //EDGE-121387, EDGE-133760
                        mapOfpcIdvsPCs.put(pc.Id,pc);
                    }
                    //EDGE-140501,EDGE-142033 Checking if Strategic solution is implemented
                    if(pc.cscfga__Parent_Configuration__c == null && pc.cscfga__recurring_charge_line_discount_value__c !=null && pc.cscfga__recurring_charge_line_discount_value__c > 0){
                        isDiscountUpdatedOnPC=True;
                    }
                }
            }
            Map<String,Double> mapOfListPrice;
            //EDGE-140501,EDGE-142033 Getting list price from Product Configuration using discount value (Strategic solution)
            mapOfListPrice=ProductBasketDataHandler.getListPriceUsingDiscount(basketId,parentProdcList);                
            Decimal monthly_RC_Promotions_incGST=0.00;
            Decimal monthly_RC_Promotions_exGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
            Decimal total_recurring_charge_exGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
            Decimal total_recurring_charge_incGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
            
            for(String offer:offers){
                total_recurring_charge_exGST = 0.00;
                total_recurring_charge_incGST = 0.00;
                monthly_RC_Promotions_incGST = 0.00;
                monthly_RC_Promotions_exGST = 0.00;   
                Integer cnt=0;
                for(cscfga__Product_Configuration__c pc2:parentProdcList){
                    Decimal rcCharge = 0.00; //EDGE-176688
                    if(pc2.Offername__c!=null && (ProductBasketDataHandler.getOfferFamily(pc2.Marketable_Offer__r.Offer_ID__c)).equalsIgnoreCase(offer)){
                        //EDGE-185178 - Commented CMP Offer check                   
                        if(pc2.cscfga__Parent_Configuration__c == null){
                            //EDGE-176688 - Start
                            rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                            total_recurring_charge_exGST += rcCharge;
                            //EDGE-176688 - End
                            //EDGE-166406 Start
                            if(map_PCVSGSTIncprice.containsKey(pc2.id)){
                                total_recurring_charge_incGST+=map_PCVSGSTIncprice.get(pc2.id);                              
                            }
                            else{
                                //EDGE-176688 - Start
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                total_recurring_charge_incGST+=ProductBasketDataHandler.calculateGSTIncludedPrice(rcCharge);                               
                                //EDGE-176688 - End
                            }
                        }
                        //EDGE-166406 End
                        if(mapOfListPrice!=null && !mapOfListPrice.isEmpty() && mapOfListPrice.get(pc2.Id)!=null){
                            Double monthlyRCPromotions=mapOfListPrice.get(pc2.Id);
                            if(monthlyRCPromotions>0){
                                monthly_RC_Promotions_exGST+=monthlyRCPromotions;
                            }else{
                                //EDGE-176688 - Start
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                monthly_RC_Promotions_exGST+=rcCharge;                        
                                //EDGE-176688 - End
                            }
                            //EDGE-166406 Start
                            if(map_PCVSGSTIncpriceIncDisc.containsKey(pc2.id)){
                                monthly_RC_Promotions_incGST+=map_PCVSGSTIncpriceIncDisc.get(pc2.id);                                
                            }
                            else{
                                //EDGE-181157 Defect Fix Start 
                                if(monthlyRCPromotions>0){
                                    monthly_RC_Promotions_incGST+=ProductBasketDataHandler.calculateGSTIncludedPrice(monthlyRCPromotions);                                
                                }//EDGE-181157 Defect Fix End
                                else{
                                    //EDGE-176688 - Start
                                    rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                    monthly_RC_Promotions_incGST+=ProductBasketDataHandler.calculateGSTIncludedPrice(rcCharge);                                //EDGE-176688 - End
                                }
                            }
                        }else{
                            if(pc2.cscfga__Parent_Configuration__c == null){// EDGE-158690 - Added if to skip child products
                                //EDGE-176688 - Start
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                monthly_RC_Promotions_exGST+=rcCharge;                                
                                //EDGE-176688 - End
                                //EDGE-166406 Start
                                if(map_PCVSGSTIncpriceIncDisc.containsKey(pc2.id)){
                                    monthly_RC_Promotions_incGST+=map_PCVSGSTIncpriceIncDisc.get(pc2.id);                                
                                }
                                else{
                                    //EDGE-176688 - Start
                                    rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                    monthly_RC_Promotions_incGST+=ProductBasketDataHandler.calculateGSTIncludedPrice(rcCharge);                                    
                                    //EDGE-176688 - End
                                }
                                //EDGE-166406 End
                            }
                        }
                        cnt++;
                    }
                }
                row.put('Offer_Name',offer);
                row.put('ExternalId', String.valueOf(externalID));
                externalID++;
                row.put('MonthlyRCPromotionsExclGST',total_recurring_charge_exGST);                
                row.put('MonthlyRCPromotionsInclGST',total_recurring_charge_incGST.setScale(2));//EDGE-166406
                if(offer != null && ( !(offer == Label.IoTOfferName) || !(offer == IoTConnectivity)) ){ //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021              
                    row.put('Total_Recurring_Charges',monthly_RC_Promotions_exGST);
                    //row.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(monthly_RC_Promotions_exGST));
                    row.put('GSTIncl_Total_Recurring_Charges',monthly_RC_Promotions_incGST.setScale(2));//EDGE-166406
                }
                row.put('Term','36 Months');
                //EDGE-171311 - Start
                /* if((decimal)(row.get('MonthlyRCPromotionsExclGST')) < 0)
row.put('MonthlyRCPromotionsExclGST','('+(decimal)(row.get('MonthlyRCPromotionsExclGST'))*-1+')');
if((decimal)(row.get('MonthlyRCPromotionsInclGST')) < 0)
row.put('MonthlyRCPromotionsInclGST','('+(decimal)(row.get('MonthlyRCPromotionsInclGST'))*-1+')');
if((decimal)(row.get('Total_Recurring_Charges')) < 0)
row.put('Total_Recurring_Charges','('+(decimal)(row.get('Total_Recurring_Charges'))*-1+')');
if((decimal)(row.get('GSTIncl_Total_Recurring_Charges')) < 0)
row.put('GSTIncl_Total_Recurring_Charges','('+(decimal)(row.get('GSTIncl_Total_Recurring_Charges'))*-1+')');*/
                
                List<String> rcCharge = new List<String>{'MonthlyRCPromotionsExclGST', 'MonthlyRCPromotionsInclGST', 'Total_Recurring_Charges', 'GSTIncl_Total_Recurring_Charge'};
                    for (String currCharge : rcCharge) {
                        if ((decimal)(row.get(currCharge)) < 0)
                            row.put(currCharge, '(' + (decimal)(row.get(currCharge)) * -1 + ')');
                    }
                //EDGE-171311 - End                 
                // Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan  
if(offer != null && (offer == Label.IoTOfferName || offer == IoTConnectivity)){ //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021	
                    row.put('MonthlyRCPromotionsExclGST','Not Applicable');	
                    row.put('MonthlyRCPromotionsInclGST','Not Applicable');	
                    row.put('Total_Recurring_Charges','Not Applicable');	
                    row.put('GSTIncl_Total_Recurring_Charges','Not Applicable');
                }             
                rows.add(row); 
                extId = externalID; 
                row = new Map<String,Object>();
            }
        }
        catch(Exception e){
            C2O_Utilities.createException(e);
        }        
        return rows;
    }
    //Method to populate New-Services table in summary section of DOP quote/orderform
    public List<Map<String,Object>> getDOPServices(String basketId, Map<String,String> subfilters){
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        ProductBasketDataHandler util = new ProductBasketDataHandler();
        Map<String,List<cscfga__Product_Configuration__c> > map_DeviceModelvsPC = new Map<String,List<cscfga__Product_Configuration__c> >();
        Map<String, String> map_DeviceModelVsPriceItem = new Map<String, String>();
        Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
        //EDGE-117967 : Capture POS redemption information in Quotes
        Map<String, String> map_DeviceWithRedeemAmount = new Map<String, String>();
        Integer externalId=1;
        List<cscfga__Product_Configuration__c> devicePCList = new List<cscfga__Product_Configuration__c>();
        try{
            //EDGE-117967 : Capture POS redemption information in Quotes
            if(basketId.length()>0){
                //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
                for(cscfga__Attribute__c attr : [Select cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name,cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Id=:basketId and (name ='RedeemFund')]){
                    
                    if(attr.cscfga__Product_Configuration__c != null && attr.cscfga__Value__c !=null){
                        map_DeviceWithRedeemAmount.put(attr.cscfga__Product_Configuration__c,attr.cscfga__Value__c); 
                    }                                    
                }                                     
            }   
            // EDGE-165831 - Filter Change
            // EDGE-* EDGE-169456-Add cscfga__One_Off_Charge__c field in SOQL query
            devicePCList =[SELECT id,name,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__One_Off_Charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN:lstDeviceSpecCode AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null AND Marketable_Offer__r.Offer_ID__c=:dopId];//EDGE-154662 Added Markatable offer's offer id check
            
            //map parent-pc with attributes of mobility-plan, message-bank and device
            for(cscfga__Product_Configuration__c pc:devicePCList) {
                if(map_DeviceModelvsPC.get(pc.Name) == null) {
                    map_DeviceModelvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());
                }
                map_DeviceModelvsPC.get(pc.Name).add(pc);
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                    if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {
                        map_DeviceModelVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
                        map_PriceItemvsBasketsnaphotFields.put(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c);
                    }
                }
            }
            
            List<String> attrIdList = map_DeviceModelVsPriceItem.values();
            String priceItemQuery = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
                ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(priceItemQuery));
            
            //Changes start for EDGE-132158
            for(cscfga__Product_Configuration__c pc:devicePCList) {
                Map<STRing,Object> newRow = new Map<String,Object>(); 
                //EDGE-117967 : Capture POS redemption information in Quotes
                String productModuleName = '';               
                if(map_DeviceWithRedeemAmount != null){
                    String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);
                    //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
                    if(redeemAmt != '0.00'){
                        productModuleName = pc.Name+'#';
                    }else{
                        productModuleName = pc.Name;
                    }
                }     
                newRow.put('Product_Module_Name',productModuleName);
                newRow.put('ExternalId', externalID++);
                Decimal qty = 1;
                qty = pc.Quantity_Product_Configuration__c;
                newRow.put('Quantity',qty);
                cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_DeviceModelVsPriceItem.get(pc.name));
                if(priceItemRecord!=null) {
                    newRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                    newRow.put('Term',priceItemRecord.cspmb__Contract_Term__c);
                    //EDGE-169456 start -changed the variable priceItemRecord to pc
                    newRow.put('Rate',pc.cscfga__One_Off_Charge__c);
                    newRow.put('Total_Once_Off',qty*pc.cscfga__One_Off_Charge__c);
                    Decimal totalOnceOff = (qty*pc.cscfga__One_Off_Charge__c);
                    //EDGE-169456 End
                    Decimal totalOnceOffGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalOnceOff);
                    newRow.put('GSTIncl_Total_Onceoff_Charges',totalOnceOffGSTIncl);
                }
                rows.add(newRow);
            }
            //Changes end for EDGE-132158
        }
        catch(Exception e)
        {
            C2O_Utilities.createException(e);
        }
        return rows;
    }
}