/****************************************************************************************************************************************************
   Main Class : Model_PriceItem
   Test Class : Model_PriceItemTest
=============================================================================================================================================
   Sr.No.    Developer Name      Date            Story          Sprint               Description
   1.        Aman Soni           03/07/2020      EDGE-148667    20.09(New Class)     To collate all the queries related to Price Item Object
   2.        Aman Soni           03/07/2020      EDGE-154026    20.10                Added getPlanType
   3.        Gitanshu Arora      22/09/2020      EDGE-167424    20.13                Added SIM Type and Technology Type
   4.        Aman Soni           23/11/2020      EDGE-178210    20.16                Added External_Id__c 
   5.        Aman Soni           23/11/2020      EDGE-178210    20.16                Added new methods    
   6.        Krunal Taak         05/01/2021      DPG-3358       20.17                Added new parameter "ItemCode" in "getDeviceType" method and updated Query "AND name = :ItemCode" (Note: ItemCode = Commercial Product Name)
   7.  Vamsi Krishna Vaddipalli   13MAY2021      EDGE-212162    21.07                To fetch SKUId's
   8.        Mahima Gandhe       11/10/2021      DIGI-30629     21.14                added getPlanString method
=========================================================================================================================================
 ******************************************************************************************************************************************************/
public with sharing class Model_PriceItem {

    public String getDeviceType(String offerId, String PlanType, String ItemCode){
        //Added External_Id__c on SOQL for EDGE-178210 by Aman|| Added Charge_Id__c on SOQL for EDGE-140968 by Gnana || DeviceEnrollment__c added as part of EDGE-112367,EDGE-112367 corrected DeviceEnrollment__c to Device_Enrolment__c || Ch-01 - Added check in below query - to check todays' date || Added Device_Care__c field by Aman Soni(EDGE-148667)
        String searchQuery = '';
        if (String.isNotBlank(offerId)) {
            if (String.isNotBlank(PlanType)) {
                if (PlanType != 'Data') {
                    searchQuery = 'select Offer_Type__c,Plan__c,cspmb__Is_Active__c,Check_todays_date__c,type__c,cspmb__Price_Item_Code__c,Commercial_Product_Code__c,Offer_Id__c,ProdSpecId__c,Offer__c,BYO__c, '
                        +'Frequency__c,taxTreatment__c,Unit_Of_Measure__c,Billing_Description__c,id,Plan_Type__c, name,cspmb__recurring_charge__c,cspmb__one_off_charge__c,specId__c, '
                        +'Charge_Id__c,External_Id__c,Sale_Eligibility__c from cspmb__Price_Item__c WHERE Check_todays_date__c = true AND Offer_Id__c = :offerId AND Type__c= '+'\''+'Mobile Handset'+'\' ORDER BY Type__c ASC ';
                } else {
                    searchQuery = 'select Offer_Type__c,Plan__c,cspmb__Is_Active__c,Check_todays_date__c,type__c,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, Offer_Id__c,ProdSpecId__c,Offer__c, '
                        +'BYO__c, Frequency__c,taxTreatment__c,Unit_Of_Measure__c,Billing_Description__c,id,Plan_Type__c, name,cspmb__recurring_charge__c,cspmb__one_off_charge__c, '
                        +'specId__c,Charge_Id__c,External_Id__c,Sale_Eligibility__c from cspmb__Price_Item__c WHERE Check_todays_date__c = true AND Offer_Id__c = :offerId AND (Type__c= '+'\''+'Mobile Broadband'+'\' '
                        +'OR Type__c= '+'\''+'Tablets'+'\''+') ORDER BY Type__c ASC ';
                }
            } else {
                searchQuery = 'select Offer_Type__c,Plan__c,cspmb__Is_Active__c,Check_todays_date__c,type__c,Model__c,Manufacturer__c ,cspmb__Price_Item_Code__c, Commercial_Product_Code__c, Offer_Id__c, '
                    +'ProdSpecId__c,Offer__c,BYO__c, Frequency__c,taxTreatment__c,Unit_Of_Measure__c,Billing_Description__c,id,Plan_Type__c, name,cspmb__recurring_charge__c, '
                    +'cspmb__one_off_charge__c,specId__c,Charge_Id__c,External_Id__c,Sale_Eligibility__c from cspmb__Price_Item__c WHERE Check_todays_date__c = true AND Offer_Id__c = :offerId AND Type__c != null '
                    +'AND Model__c != null AND Manufacturer__c != null AND name = :ItemCode ORDER BY Type__c ASC ';
            }
        }
        return searchQuery;
    }
    public String getManufacturer(String searchValue, String offerId, String deviceTypeString){
        //Added External_Id__c on SOQL for EDGE-178210 by Aman || Added Charge_Id__c on SOQL for EDGE-140968 by Gnana || DeviceEnrollment__c added as part of EDGE-112367,EDGE-112367 corrected DeviceEnrollment__c to Device_Enrolment__c || Ch-01 - Added check in below query - to check todays' date || Added Device_Care__c field by Aman Soni(EDGE-148667) || || Added SIM Type and Technology Type by Gitanshu (EDGE-167424)
        String searchQuery = '';
        if (String.isNotBlank(offerId) && String.isNotBlank(deviceTypeString)) {
            if (String.isEmpty(searchValue)) {
                searchQuery = 'SELECT id, Name, Manufacturer__c,Device_Enrolment__c,Type__c,Check_todays_date__c,'
            +'Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, Frequency__c, Contract_Type__c, billingSubtype__c, ProdSpecId__c, Offer_Id__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,cspmb__Price_Item_Code__c,External_Id__c,Sale_Eligibility__c  FROM cspmb__Price_Item__c '
            + 'WHERE Offer_Id__c = :offerId '
                    + 'AND Type__c= :deviceTypeString '
                    + 'AND Check_todays_date__c=true '
                    + 'ORDER BY Manufacturer__c ASC ';
            }
            else {
                searchQuery = 'SELECT id, Name, Manufacturer__c, Model__c, Device_Enrolment__c,Type__c,Check_todays_date__c,'
            +'Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, Frequency__c, Contract_Type__c, billingSubtype__c, ProdSpecId__c, Offer_Id__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,cspmb__Price_Item_Code__c,External_Id__c,Sale_Eligibility__c  FROM cspmb__Price_Item__c '
            + 'WHERE Manufacturer__c LIKE :searchValue '
                    + 'AND Offer_Id__c = :offerId '
                    + 'AND Type__c= :deviceTypeString '
                    + 'AND Check_todays_date__c=true '
                    + 'ORDER BY Manufacturer__c ASC ';
            }
        }
        return searchQuery;
    }
    public String getModel(String searchValue, String offerId, String selectedManufacturer, String deviceTypeString){
        // Added External_Id__c on SOQL for EDGE-178210 by Aman|| Added Charge_Id__c on SOQL for EDGE-140968 by Gnana || EDGE-112367 added DeviceEnrollment__c,EDGE-112367 corrected DeviceEnrollment__c to Device_Enrolment__c || Check_todays_date__c added as part of EDGE-126960 || EDGE-81077 || deviceTypeString added as part of EDGE-113391 || Added Device_Care__c field by Aman Soni(EDGE-148667) || Added SIM Type and Technology Type by Gitanshu (EDGE-167424)
        String searchQuery='';        
        if(String.isNotBlank(offerId)  && String.isNotBlank(selectedManufacturer) && String.isNotBlank(deviceTypeString)){
            if(String.isEmpty(searchValue)){
                searchQuery = 'SELECT id, name, Manufacturer__c,cspmb__Price_Item_Code__c,Device_Enrolment__c,Model__c, Colour__c, cspmb__Contract_Term__c,Type__c, ChargeType__c, cspmb__One_Off_Charge__c,Check_todays_date__c,'
                    + 'cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,External_Id__c,Sale_Eligibility__c  FROM cspmb__Price_Item__c '
                    + 'WHERE Manufacturer__c =: selectedManufacturer AND Offer_Id__c = :offerId AND Type__c= :deviceTypeString AND Check_todays_date__c=true ORDER BY Model__c ASC ';
            }
            else {
               // String likeValue = '%' + searchValue + '%';
                searchQuery = 'SELECT id, name, Manufacturer__c,cspmb__Price_Item_Code__c,Device_Enrolment__c,Model__c, Colour__c, cspmb__Contract_Term__c,Type__c, ChargeType__c, cspmb__One_Off_Charge__c,Check_todays_date__c,'
                    +'cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,External_Id__c,Sale_Eligibility__c  FROM cspmb__Price_Item__c '
                    + 'WHERE (Model__c LIKE :searchValue OR Sim_Type__c LIKE :searchValue OR Technology_Type__c LIKE :searchValue) AND Manufacturer__c =: selectedManufacturer AND Offer_Id__c = :offerId AND Type__c= :deviceTypeString AND Check_todays_date__c=true '
                + 'ORDER BY Model__c ASC '; 
            }
        }
        return searchQuery;
    }
    public String getColour(String searchValue, String offerId, String selectedManufacturer, String selectedModel){
        String searchQuery = '';
        // Added External_Id__c on SOQL for EDGE-178210 by Aman|| Added Charge_Id__c on SOQL for EDGE-140968 by Gnana || EDGE-112367 added DeviceEnrollment__c,EDGE-112367 corrected DeviceEnrollment__c to Device_Enrolment__c || Check_todays_date__c added as part of EDGE-126960 || EDGE-81077 || Added Device_Care__c field by Aman Soni(EDGE-148667) || Added SIM Type and Technology Type by Gitanshu (EDGE-167424)
        if (String.isNotBlank(offerId) && String.isNotBlank(selectedManufacturer) && String.isNotBlank(selectedModel)) {
            if (String.isEmpty(searchValue)) {
                searchQuery = 'SELECT id, name, Manufacturer__c,Type__c,cspmb__Price_Item_Code__c, Device_Enrolment__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,External_Id__c,Sale_Eligibility__c,Check_todays_date__c  FROM cspmb__Price_Item__c '
                    + 'WHERE Manufacturer__c =:selectedManufacturer AND Model__c =:selectedModel AND Offer_Id__c = :offerId AND Check_todays_date__c=true ORDER BY Colour__c ASC ';
            }
            else {
                //String likeValue = '%' + searchValue + '%';
                searchQuery = 'SELECT id, name, Manufacturer__c,Type__c,cspmb__Price_Item_Code__c,Device_Enrolment__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,External_Id__c,Sale_Eligibility__c,Check_todays_date__c  FROM cspmb__Price_Item__c '
                    + 'WHERE Colour__c LIKE :searchValue AND Manufacturer__c =:selectedManufacturer AND Model__c =:selectedModel AND Offer_Id__c = :offerId '
                    + 'AND Check_todays_date__c=true ORDER BY Colour__c ASC';
            }
        }
        return searchQuery;
    }
    public String getPayType(String offerId, String manufacturerString, String modelString, String colourString){
        //Added External_Id__c on SOQL for EDGE-178210 by Aman|| Added Charge_Id__c on SOQL for EDGE-140968 by Gnana || DeviceEnrollment__c added as part of EDGE-112367,EDGE-112367 corrected DeviceEnrollment__c to Device_Enrolment__c || Ch-01 - Added check in below query - to check todays' date || Added Device_Care__c field by Aman Soni(EDGE-148667) || Added SIM Type and Technology Type by Gitanshu (EDGE-167424)
        String searchQuery = '';
        if (String.isNotBlank(offerId) && String.isNotBlank(manufacturerString) && String.isNotBlank(modelString) && String.isNotBlank(colourString)) {
            searchQuery = 'SELECT id, '
                + 'Name, Manufacturer__c, Model__c, Colour__c, cspmb__Price_Item_Code__c, cspmb__Contract_Term__c,Device_Enrolment__c,'
                +'ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,External_Id__c  '
                + 'FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId AND Manufacturer__c = :manufacturerString AND Model__c = :modelString AND Colour__c = :colourString '
                + ' and Check_todays_date__c = true ORDER BY cspmb__Contract_Term__c ASC ';
        }
        return searchQuery;
    }
    public String getContractTerm(String offerId, String manufacturerString, String modelString, String paymentTypeString, String colourString){
        String searchQuery = '';
        //Added Charge_Id__c on SOQL for EDGE-140968 by Gnana || DeviceEnrollment__c added as part of EDGE-112367,EDGE-112367 corrected DeviceEnrollment__c to Device_Enrolment__c || Ch-01 - Added check in below query - to check todays' date || Added Device_Care__c field by Aman Soni(EDGE-148667) || Added SIM Type and Technology Type by Gitanshu (EDGE-167424)
        if (String.isNotBlank(offerId) && String.isNotBlank(manufacturerString) && String.isNotBlank(modelString) && String.isNotBlank(paymentTypeString) && String.isNotBlank(colourString)) {
            searchQuery = 'SELECT id,Name,cspmb__Price_Item_Code__c, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c,Device_Enrolment__c, '
                +'ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c,Charge_Id__c,Device_Care__c,Sim_Type__c,Technology_Type__c,External_Id__c  '

                + 'FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId AND Manufacturer__c = :manufacturerString AND Model__c = :modelString AND Colour__c = :colourString '
                + ' AND Contract_Type__c = :paymentTypeString AND Check_todays_date__c  = true ORDER BY cspmb__Contract_Term__c ASC ';
        }
        return searchQuery;
    }
    //Added by Aman Soni as a part of EDGE-154026 || Start
    public String getPlanType(String offerId, String offerTypeString){
        //Added External_Id__c on SOQL for EDGE-178210 by Aman  ||Hitesh: added new condition (offerTypeString) to support EDGE-154026
        String searchQuery = '';
        if (String.isNotBlank(offerId)) {
            if (String.isNotBlank(offerTypeString)) {
                searchQuery = 'select Offer_Type__c,Plan__c,cspmb__Is_Active__c,Check_todays_date__c,type__c,'
                    +'  cspmb__Price_Item_Code__c, Commercial_Product_Code__c, Offer_Id__c,ProdSpecId__c,Offer__c,BYO__c, Frequency__c,'
                    +'taxTreatment__c,Unit_Of_Measure__c,Billing_Description__c,id,Plan_Type__c, name,'
                    +' cspmb__recurring_charge__c,cspmb__one_off_charge__c,specId__c,Charge_Id__c,External_Id__c,Sale_Eligibility__c  from cspmb__Price_Item__c  '
                    + 'WHERE Check_todays_date__c = true And Plan__c  != null  '
                    + 'AND Offer_Id__c = :offerId and Offer__c = :offerTypeString';
            } else {
                searchQuery = 'select Offer_Type__c,Plan__c,cspmb__Is_Active__c,Check_todays_date__c,type__c,'
                    +'  cspmb__Price_Item_Code__c, Commercial_Product_Code__c, Offer_Id__c,ProdSpecId__c,Offer__c,BYO__c, Frequency__c,'
                    +'taxTreatment__c,Unit_Of_Measure__c,Billing_Description__c,id,Plan_Type__c, name,'
                    +' cspmb__recurring_charge__c,cspmb__one_off_charge__c,specId__c,Charge_Id__c,External_Id__c,Sale_Eligibility__c  from cspmb__Price_Item__c  '
                    + 'WHERE Check_todays_date__c = true And Plan__c  != null  '
                    + 'AND Offer_Id__c = :offerId';
            }
        }
        return searchQuery;
    }
    //Added by Aman Soni as a part of EDGE-154026 || End
    
    //Created new method to return UC Device Model and added External_Id__c by Aman Soni for EDGE-178210 || Start
    //Edge120919 added Mode__c in below query || AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c in below query || added by shubhi Check_todays_date__c for EDGE-139224
    public String getUCDeviceModel(String offerId){
        //Added External_Id__c on SOQL for EDGE-178210 by Aman 
        String searchQuery = '';
        if (String.isNotBlank(offerId)){
                searchQuery = 'SELECT id,Type__c, Name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c,Charge_Id__c,'
                    +' ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c,'
                    +' taxTreatment__c, Unit_Of_Measure__c,Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c,'
                    +' Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,External_Id__c,'  
                    +' cspmb__Price_Item_Code__c,Commercial_Product_Code__c,rangeFrom__c,rangeTo__c,Plan__c,Check_todays_date__c,Mode__c'
                    +' FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId and Model__c != null AND Check_todays_date__c=true ';
        }
        return searchQuery;
    }
    //Created new method to return UC Device Model and added External_Id__c by Aman Soni for EDGE-178210 || End 
    
    //Created new method to return UC Device Model and added External_Id__c by Aman Soni for EDGE-178210 || Start
    //added Charge_Id__c to lookup for EDGE-121376 || added by shubhi Check_todays_date__c for EDGE-139224 || Edge120919 added Mode__c || AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
    public String getCS_UC_CallingPlan(String offerId){
        //Added External_Id__c on SOQL for EDGE-178210 by Aman 
        String searchQuery = '';
        if (String.isNotBlank(offerId)){
                searchQuery = 'SELECT id,Type__c,Manufacturer__c, Model__c, Colour__c,Name,rangeFrom__c,cspmb__Contract_Term__c,rangeTo__c,'+' ChargeType__c, cspmb__One_Off_Charge__c, Plan__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c,'      +' taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c,Prorate__c,'+' frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c,Offer_Id__c,cspmb__Price_Item_Code__c,'                 +' cspmb__Price_Item_Description__c,Charge_Id__c,Check_todays_date__c,Mode__c,External_Id__c FROM cspmb__Price_Item__c'     +' WHERE Offer_Id__c = :offerId and Plan__c != null AND Check_todays_date__c=true';
        }
        return searchQuery;
    }
    //Created new method to return UC Device Model and added External_Id__c by Aman Soni for EDGE-178210 || End

    //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
    public List<cspmb__Price_Item__c> fetchActiveSKU (Set<String> listOfProducts)
    {
        /*List<String> listOfProducts = new List<String>();
        Set<String> skuIds = new Set<String>();
        
        List<StockProductSpecID__mdt> stockList = [SELECT MasterLabel FROM StockProductSpecID__mdt];

        for(StockProductSpecID__mdt stMdt:stockList){
            
            listOfProducts.add(stMdt.MasterLabel);
        }
        system.debug('listOfPriceItems '+listOfProducts);*/
        List<cspmb__Price_Item__c> listOfPriceItems = [SELECT id,Name,SKU__c,ProdSpecId__c,Check_todays_date__c FROM cspmb__price_item__c WHERE Check_todays_date__c  = true AND ProdSpecId__c IN: listOfProducts ];
        /*for(cspmb__Price_Item__c price : listOfPriceItems)
        {
            skuIds.add(price.SKU__c);
        }
        system.debug('listOfPriceItems '+skuIds);*/
        return listOfPriceItems;
    }
    //Added by Vamsi for EDGE-212162 on 18MAY2021 ends
    
    //Added by Mahima Gandhe as a part of DIGI-30629 || Start
    public String getPlanString(String offerId, String planTypeString){
        //Added External_Id__c on SOQL for EDGE-178210 by Aman  ||Hitesh: added new condition (offerTypeString) to support EDGE-154026
        String searchQuery = '';
        if (String.isNotBlank(offerId)) {
            if (String.isNotBlank(planTypeString)) {
                searchQuery = 'select Offer_Type__c,Plan__c,cspmb__Is_Active__c,Check_todays_date__c,type__c,'
                    +'  cspmb__Price_Item_Code__c, Commercial_Product_Code__c, Offer_Id__c,ProdSpecId__c,Offer__c,BYO__c, Frequency__c,'
                    +'taxTreatment__c,Unit_Of_Measure__c,Billing_Description__c,id,Plan_Type__c, name,'
                    +' cspmb__recurring_charge__c,cspmb__one_off_charge__c,specId__c,Charge_Id__c,External_Id__c,Sale_Eligibility__c  from cspmb__Price_Item__c  '
                    + 'WHERE Check_todays_date__c = true And Plan__c  != null  '
                    + 'AND Offer_Id__c = :offerId and Type__c = :planTypeString';
            } else {
                searchQuery = 'select Offer_Type__c,Plan__c,cspmb__Is_Active__c,Check_todays_date__c,type__c,'
                    +'  cspmb__Price_Item_Code__c, Commercial_Product_Code__c, Offer_Id__c,ProdSpecId__c,Offer__c,BYO__c, Frequency__c,'
                    +'taxTreatment__c,Unit_Of_Measure__c,Billing_Description__c,id,Plan_Type__c, name,'
                    +' cspmb__recurring_charge__c,cspmb__one_off_charge__c,specId__c,Charge_Id__c,External_Id__c,Sale_Eligibility__c  from cspmb__Price_Item__c  '
                    + 'WHERE Check_todays_date__c = true And Plan__c  != null  '
                    + 'AND Offer_Id__c = :offerId';
            }
        }
        return searchQuery;
    }
    //Added by Mahima Gandhe as a part of DIGI-30629 || End
}