/*******************************************************************
   @Author : Krunal Taak / Ila Verma
   @Description : Lookup Custom class to fetch the Payment Type in MobileAccessory in Adaptive Mobility
   @Release : Sprint 20.16 - DPG-3506

   S.No.  Date         User Story   Owner      Description
   1      15-12-2020   DPG-3506     Krunal T.  Repliacted from Apex class "AdaptiveMobilityAccessoryLookup"
   2.     12-08-2021   DIGI-12691   Sayantan H. Added null check for distinctHROList
   3.     17-08-2021   DIGI-14502   Sayantan H. Removed contract term code
*******************************************************************/

global with sharing class AdaptiveMobilityPaymentTypeLookup extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    {
        return '["OfferId","TypeName","ItemCode","ModelName","PaymentTypeShadow"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {

        String searchValue = '';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
          searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        String offerid = (searchFields.containsKey('OfferId') && searchFields.get('OfferId') != NULL)? searchFields.get('OfferId'):'';
        String DeviceType = (searchFields.containsKey('TypeName') && searchFields.get('TypeName') != NULL)? searchFields.get('TypeName'):'';
        String itemcode = (searchFields.containsKey('ItemCode') && searchFields.get('ItemCode') != NULL)? searchFields.get('ItemCode'):'';
        String modelName = (searchFields.containsKey('ModelName') && searchFields.get('ModelName') != NULL)? searchFields.get('ModelName'):'';
        String paymentTypeShadow = (searchFields.containsKey('PaymentTypeShadow') && searchFields.get('PaymentTypeShadow') != NULL)? searchFields.get('PaymentTypeShadow'):'';
        
        String PaymentTypeLookup = 'PaymentTypeLookup';
        String ContractTerm = 'ContractTerm';

        System.debug('PriceItemManufacturerLookupCustom searchValue2: ' + searchValue);

        String searchQuery;
        String searchPaymentQuery;
        //String searchContractTermQuery;
        String mapkey = 'cspmb__One_Off_Charge__c';
        searchQuery = 'SELECT id,Type__c,Plan_Type__c, Name, Manufacturer__c, Offer_Type__c, BYO__c, Offer__c, cspmb__Is_Active__c, Model__c, Colour__c, cspmb__Contract_Term__c,Charge_Id__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,cspmb__Price_Item_Code__c,Commercial_Product_Code__c,rangeFrom__c,rangeTo__c,Plan__c,Check_todays_date__c,Mode__c FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId AND Model__c = :modelName AND Type__c = :DeviceType AND Check_todays_date__c=true ';
        
        searchPaymentQuery = 'SELECT Id,Name,Offer_ID__c,Product_ID__c,isActive__c,Charge_ID__c,Override_Attribute_Name__c,Override_Attribute_Value__c,Minimum_Value__c,Maximum_Value__c FROM Hardware_Repayment_Metadata__c WHERE Offer_ID__c = :offerId AND Override_Attribute_Name__c = :PaymentTypeLookup AND isActive__c=true ';
        
        //searchContractTermQuery = 'SELECT Id,Name,Offer_ID__c,Product_ID__c,isActive__c,Charge_ID__c,Override_Attribute_Name__c,Override_Attribute_Value__c,Minimum_Value__c,Maximum_Value__c FROM Hardware_Repayment_Metadata__c WHERE Offer_ID__c = :offerId AND Override_Attribute_Name__c = :ContractTerm AND isActive__c=true ';

        List<Hardware_Repayment_Metadata__c> HardwareRepaymentMetadataList = new List<Hardware_Repayment_Metadata__c>();
        /*if (!String.isEmpty(paymentTypeShadow)) {
            System.debug('Inside CT: ' + paymentTypeShadow);
            HardwareRepaymentMetadataList = Database.query(searchContractTermQuery);
        }
        else {*/
            System.debug('Inside PTS' + paymentTypeShadow);
            HardwareRepaymentMetadataList = Database.query(searchPaymentQuery);
        //}

        System.debug('AdaptiveMobilityPaymentTypeLookup searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);
        //Added null check for distinctHROList
        List<Hardware_Repayment_Metadata__c> distinctHROList = new List<Hardware_Repayment_Metadata__c>();
        if(!CommercialProductsList.isEmpty() && CommercialProductsList!=null){
           distinctHROList = getUniqueListByField(CommercialProductsList, HardwareRepaymentMetadataList, mapkey); 
        }
        
        return distinctHROList;
    }

    public List<Hardware_Repayment_Metadata__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, List<Hardware_Repayment_Metadata__c> hroList, String fieldName){
        Map<String, Hardware_Repayment_Metadata__c> itemMap =  new Map<String, Hardware_Repayment_Metadata__c>();
        for (cspmb__Price_Item__c item : pis) {
            for (Hardware_Repayment_Metadata__c hro : hroList) {
                if (fieldName == 'cspmb__One_Off_Charge__c') {
                    if(item.cspmb__One_Off_Charge__c < Integer.valueOf(Label.Pay_Type_Accessory_First_c) && hro.Maximum_Value__c < Integer.valueOf(Label.Pay_Type_Accessory_First_c)){
                        itemMap.put(hro.Override_Attribute_Value__c, hro);
                    }
                    else if((item.cspmb__One_Off_Charge__c >= Integer.valueOf(Label.Pay_Type_Accessory_First_c) && item.cspmb__One_Off_Charge__c <= Integer.valueOf(Label.Pay_Type_Accessory_Second_c)) && (hro.Minimum_Value__c >= Integer.valueOf(Label.Pay_Type_Accessory_First_c) &&hro.Maximum_Value__c <= Integer.valueOf(Label.Pay_Type_Accessory_Second_c))){
                        itemMap.put(hro.Override_Attribute_Value__c, hro);
                    }
                    else if(item.cspmb__One_Off_Charge__c > Integer.valueOf(Label.Pay_Type_Accessory_Second_c) && hro.Minimum_Value__c > Integer.valueOf(Label.Pay_Type_Accessory_Second_c)){
                        itemMap.put(hro.Override_Attribute_Value__c, hro);
                    }
                    else{}
                }
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}