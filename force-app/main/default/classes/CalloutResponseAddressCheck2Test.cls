/*
*   Test class for CalloutResponseAddressCheck2 - that handles the Callout Responses for Address Check via basket
*/
@isTest
public class CalloutResponseAddressCheck2Test {
    @isTest
    private static void dummyTesting() {
         //Create Custom Setting for basket stages
        List<CustomConfigurationOptions__c> configOptionsList = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Submitted';
        configOptions.External_Id__c = '9ExternalIdtest';
        configOptions.Name = 'Submitted';
        configOptionsList.add(configOptions);
        
        CustomConfigurationOptions__c configOptions1 = new CustomConfigurationOptions__c();
        configOptions1.Enrichment_Basket_Stage__c = 'Cancelled';
        configOptions1.External_Id__c = '9ExternalIdtest1';
        configOptions1.Name = 'CancelBasket';
        configOptionsList.add(configOptions1);
        
        CustomConfigurationOptions__c configOptions2 = new CustomConfigurationOptions__c();
        configOptions2.Enrichment_Basket_Stage__c = 'Draft';
        configOptions2.External_Id__c = '9ExternalIdtest2';
        configOptions2.Name = 'Draft';
        configOptionsList.add(configOptions2);
        
        CustomConfigurationOptions__c configOptions3 = new CustomConfigurationOptions__c();
        configOptions3.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        configOptions3.External_Id__c = '9ExternalIdtest3';
        configOptions3.Name = 'CommercialConfiguration';
        configOptions3.Opportunity_Stage__c='Develop';
        configOptionsList.add(configOptions3);
        
        CustomConfigurationOptions__c configOptions4 = new CustomConfigurationOptions__c();
        configOptions4.Enrichment_Basket_Stage__c = 'Quote';
        configOptions4.External_Id__c = '9ExternalIdtest4';
        configOptions4.Name = 'Quote';
        configOptions4.Opportunity_Stage__c='Propose';
        configOptionsList.add(configOptions4);
        
        insert configOptionsList;
        
            //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='test123';
        insert acc;
        System.assertNotEquals(null,acc);
        //Create address
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        cscrm__Address__c addrs2 = new cscrm__Address__c();
        addrs2.Address_ID__c = '111';
        addrs2.Name = 'Test Address';
        addrs2.cscrm__Account__c = acc.id;
        lstAddress.add(addrs2);
        insert lstAddress;
        
        //Create site
        cscrm__Site__c siteobj1 = new cscrm__Site__c();
        siteobj1.Name = 'Test Site1';
        siteobj1.cscrm__Account__c = acc.id;
        siteobj1.cscrm__Installation_Address__c = lstAddress[0].Id;
        siteobj1.Status__c = 'Active';
        siteobj1.Legacy__c = true;
        insert siteobj1;
        
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;

        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;

        insert pbe;

        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        //opp.IsActiveAccount__c = true;
        insert opp;
        System.assertNotEquals(null,opp);

        //Create Basket
        cscfga__Product_Basket__c prodBasket  = ProductTestFactory.buildEmptyBasket();
        prodBasket.csbb__Account__c = acc.id;
        prodBasket.cscfga__Opportunity__c = opp.id;
        prodBasket.Name = 'basket1';
        insert prodBasket ;
                       
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='Enable_GetSiteReplicatorV2';
        csSite.value__c='True';
        insert csSite;
        
        //prod config
        List<cscfga__Product_Configuration__c> configList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
        cscfga__Product_Configuration__c config1= ProductTestFactory.buildProductConfig(pd.Id);
        config1.name= 'IP Site';
        config1.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config1);
        cscfga__Product_Configuration__c config= ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'Connected Workplace';
        config.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config);
        insert configList;
        
        //Prod config req
        /*List<csbb__Product_Configuration_Request__c> pcrList=new List<csbb__Product_Configuration_Request__c>();
        csbb__Product_Configuration_Request__c  pcr=ProductTestFactory.buildConfigRequest(prodBasket.id,config.id);                     
        pcr.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200240912750","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"'+acc.id+'","name":"BERESFORD RD NSW","hiddenParam1":"240912750","selectedPcrs":""}';
        pcrList.add(pcr); 
        insert pcrList;*/
        
        //create subscription
        //List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = 'Connected Workplace';
        IpVpnsubs.Site__c=siteobj1.id;
        //lstSubs.add(IpVpnsubs);
        update IpVpnsubs;
        
        //csbb.CalloutResponseManagerExt cext=new CalloutResponseManagerExt();
        CalloutResponseAddressCheck2 adC = new CalloutResponseAddressCheck2();
        Map<String, Object> inputMap = new Map<String, Object>();
        //String addressResponse = getCustomerSiteReplicator_withSuccess();
        String addressResponse = getCustomerSiteReplicator_V2();
        adC.basketId =prodBasket.id;   
        inputMap.put('addressResponseRaw',addressResponse);
        inputMap.put('httpStatusCode',200);
        inputMap.put('context','{calloutServiceMethodName=AddressCheck2_GetAddresses, calloutServiceMethodType=address}');
        Map<String, Object> outputMap = adC.processResponseRaw(inputMap);
        System.assert(outputMap!=null);
        ReplicatorGetSiteDataObject getSiteDTO = new ReplicatorGetSiteDataObject();
        getSiteDTO=ReplicatorGetSiteDataObject.parse(getCustomerSiteReplicator_withSuccess());
            List<Map<String, Object>> siteRecordList2 = new List<Map<String, Object>>();
        List<Map<String, Object>> siteRecordList3 = new List<Map<String, Object>>();
        List<Map<String, Object>> siteRecordList4= new List<Map<String, Object>>();
        Set<cscrm__Site__c> siteSet= new Set<cscrm__Site__c>(); 
        siteSet.add(siteobj1);
        siteRecordList2=adC.getSiteFromReplicatorResponse(getSiteDTO,prodBasket.id);
        siteRecordList2=adC.getSiteFromReplicatorResponse(getSiteDTO,adC.basketId);
        siteRecordList3=adC.markDuplicateReplicatorSites(adC.basketId,siteRecordList2);
        siteRecordList4=adC.getUniqueSiteResponse(siteSet,siteRecordList3);
        System.assertEquals(1, adC.getDynamicRequestParameters(new Map<String, Object>()).size());
        //sqC.runBusinessRules('');
        //System.assert(adC.canOffer(new Map<String, String>(), new Map<String, String>(), new csbb.CalloutProduct.ProductResponse()) != null); 
        
        system.debug('adC.basketId'+adC.basketId);
        System.assertequals(adC.basketId,prodBasket.id);                    
    }
     @isTest
    private static void runTestMethodOnCalloutResponseAddressCheck2() {
         //Create Custom Setting for basket stages
        List<CustomConfigurationOptions__c> configOptionsList = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Submitted';
        configOptions.External_Id__c = '9ExternalIdtest';
        configOptions.Name = 'Submitted';
        configOptionsList.add(configOptions);
        
        CustomConfigurationOptions__c configOptions1 = new CustomConfigurationOptions__c();
        configOptions1.Enrichment_Basket_Stage__c = 'Cancelled';
        configOptions1.External_Id__c = '9ExternalIdtest1';
        configOptions1.Name = 'CancelBasket';
        configOptionsList.add(configOptions1);
        
        CustomConfigurationOptions__c configOptions2 = new CustomConfigurationOptions__c();
        configOptions2.Enrichment_Basket_Stage__c = 'Draft';
        configOptions2.External_Id__c = '9ExternalIdtest2';
        configOptions2.Name = 'Draft';
        configOptionsList.add(configOptions2);
        
        CustomConfigurationOptions__c configOptions3 = new CustomConfigurationOptions__c();
        configOptions3.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        configOptions3.External_Id__c = '9ExternalIdtest3';
        configOptions3.Name = 'CommercialConfiguration';
        configOptions3.Opportunity_Stage__c='Develop';
        configOptionsList.add(configOptions3);
        
        CustomConfigurationOptions__c configOptions4 = new CustomConfigurationOptions__c();
        configOptions4.Enrichment_Basket_Stage__c = 'Quote';
        configOptions4.External_Id__c = '9ExternalIdtest4';
        configOptions4.Name = 'Quote';
        configOptions4.Opportunity_Stage__c='Propose';
        configOptionsList.add(configOptions4);
        
        insert configOptionsList;
        
            //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='212';
        insert acc;
        System.assertNotEquals(null,acc);
        //Create address
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        cscrm__Address__c addrs2 = new cscrm__Address__c();
        addrs2.Address_ID__c = '111';
        addrs2.Name = 'Test Address';
        addrs2.cscrm__Account__c = acc.id;
        lstAddress.add(addrs2);
        insert lstAddress;
        
        //Create site
        cscrm__Site__c siteobj1 = new cscrm__Site__c();
        siteobj1.Name = 'Test Site1';
        siteobj1.cscrm__Account__c = acc.id;
        siteobj1.cscrm__Installation_Address__c = lstAddress[0].Id;
        siteobj1.Status__c = 'Active';
        siteobj1.Legacy__c = true;
        insert siteobj1;
        
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;

        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;

        insert pbe;

        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        //opp.IsActiveAccount__c = true;
        insert opp;
        System.assertNotEquals(null,opp);

        //Create Basket
        cscfga__Product_Basket__c prodBasket  = ProductTestFactory.buildEmptyBasket();
        prodBasket.csbb__Account__c = acc.id;
        prodBasket.cscfga__Opportunity__c = opp.id;
        prodBasket.Name = 'basket1';
        insert prodBasket ;
                       
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='Enable_GetSiteReplicatorV2';
        csSite.value__c='True';
        insert csSite;
        
        //prod config
        List<cscfga__Product_Configuration__c> configList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
        cscfga__Product_Configuration__c config1= ProductTestFactory.buildProductConfig(pd.Id);
        config1.name= 'IP Site';
        config1.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config1);
        cscfga__Product_Configuration__c config= ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'Connected Workplace';
        config.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config);
        insert configList;
        CalloutResponseAddressCheck2 adC = new CalloutResponseAddressCheck2();
       adC.basketId =prodBasket.id;  
       Map<String, Object> inputMap = new Map<String, Object>();
        String addressResponse = '{"response":'+getCustomerSiteReplicator_V2()+'}';
        inputMap.put('addressResponseRaw',addressResponse);
        inputMap.put('httpStatusCode',200);
        inputMap.put('context','{calloutServiceMethodName=AddressCheck2_GetAddresses, calloutServiceMethodType=address}');
        Map<String, Object> outputMap = adC.processResponseRaw(inputMap);
        System.assert(outputMap!=null);
        System.assertEquals(1, adC.getDynamicRequestParameters(new Map<String, Object>()).size());
        System.assert(adC.canOffer(new Map<String, String>(), new Map<String, String>(), new csbb.CalloutProduct.ProductResponse()) != null);                     
        adC.runBusinessRules('');
    }
        @isTest
    private static void runTestMethodOnCalloutResponseAddressCheck2Success() {
        CalloutResponseAddressCheck2 adC = new CalloutResponseAddressCheck2();
       
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='Enable_GetSiteReplicatorV2';
        csSite.value__c='False';
        insert csSite;
        
        Map<String, Object> inputMap = new Map<String, Object>();
        String addressResponse = '{"response":'+getCustomerSiteReplicator_withSuccess()+'}';
        inputMap.put('addressResponseRaw',addressResponse);
        inputMap.put('httpStatusCode',200);
        inputMap.put('context','{calloutServiceMethodName=AddressCheck2_GetAddresses, calloutServiceMethodType=address}');
        Map<String, Object> outputMap = adC.processResponseRaw(inputMap);
        System.assert(outputMap!=null);
        System.assertEquals(1, adC.getDynamicRequestParameters(new Map<String, Object>()).size());
        System.assert(adC.canOffer(new Map<String, String>(), new Map<String, String>(), new csbb.CalloutProduct.ProductResponse()) != null);                     
        adC.runBusinessRules('');
    }
    
    public static String getCustomerSiteReplicator_withSuccess(){
    
    String jsonString ='{"CIDN":"212","Enterprise_Id":"553","Error_Code":"","Error_Description":"","Site":[{"ADBoR_ID":"111","Media_Type":"NBN","Site_Nick_Name":"Melbourne CBD","Address_No_From":"22","Address_No_To":"25","Suffix_From":"","Suffix_To":"","Street_Name":"Lonsdale","Street_Type":"Street","Loc_Name":"","ADBoR_Postcode":"3000","State":"","Name":"","Sub1_CodeSet_Abbrev":"","Sub1_Descriptor_1":"","Sub1_Descriptor_2":"","Sub2_CodeSet_Abbrev":"","Sub2_Descriptor_1":"","Sub2_Descriptor_2":"","Sub3_CodeSet_Abbrev":"","Sub3_Descriptor_1":"","Sub3_Descriptor_2":"","Sub4_CodeSet_Abbrev":"","Sub4_Descriptor_1":"","Sub4_Descriptor_2":"","Disconnection_Date":"","LastReplicator_UpdateDate":"","In_Flight_Order":"","RFS_Site":"","RFS_Date":"","Serviceability":"","NBN_Access_Type":"","Disconnect_Wave":"","Address_Status":"","NBN_Location_Id":"","Site_Composition":"","Complex_Site_Flag":"","Migration_Flag":"","Order_Stability_Date":"","Service_Class":"","Notes":"","Error_Description":"","Contact":[{"Site_Contact_First_Name":"Ben","Site_Contact_Last_Name":"Smith","Site_Contact_Telephone":"1356789078","Site_Contact_Mobile":"1456764532","Site_Contact_Fax":"","Site_Contact_Email":"ben.smith@gmail.com"},{"Site_Contact_First_Name":"Asoka","Site_Contact_Last_Name":"Perara","Site_Contact_Telephone":"1323145678","Site_Contact_Mobile":"1453627869","Site_Contact_Fax":"","Site_Contact_Email":"asoka.perara@yahoo.com"}]},{"ADBoR_ID":"1143","Media_Type":"NBN","Site_Nick_Name":"Sydney CBD","Address_No_From":"33","Address_No_To":"45","Suffix_From":"","Suffix_To":"","Street_Name":"Opera","Street_Type":"Road","Loc_Name":"","ADBoR_Postcode":"2000","State":"","Name":"","Sub1_CodeSet_Abbrev":"","Sub1_Descriptor_1":"","Sub1_Descriptor_2":"","Sub2_CodeSet_Abbrev":"","Sub2_Descriptor_1":"","Sub2_Descriptor_2":"","Sub3_CodeSet_Abbrev":"","Sub3_Descriptor_1":"","Sub3_Descriptor_2":"","Sub4_CodeSet_Abbrev":"","Sub4_Descriptor_1":"","SUB4_DESCRIPTOR_2":"","Disconnection_Date":"","LastReplicator_UpdateDate":"","In_Flight_Order":"","RFS_Site":"","RFS_Date":"","Serviceability":"","NBN_Access_Type":"","Disconnect_Wave":"","Address_Status":"","NBN_Location_Id":"","Site_Composition":"","Complex_Site_Flag":"","Migration_Flag":"","Order_Stability_Date":"","Service_Class":"","Notes":"","Error_Description":"","Contact":[{"Site_Contact_First_Name":"Nikki","Site_Contact_Last_Name":"Wilson","Site_Contact_Telephone":"1234567893","Site_Contact_Mobile":"1423567894","Site_Contact_Fax":"","Site_Contact_Email":"nikki.smith@gmail.com"}]}]}';
        
        return jsonString;
    }
    
    public static String getCustomerSiteReplicator_V2(){
    
    String jsonString ='{"addressList":[{"addressCharacteristics":[{"value":"","name":"Address_No_From"},{"value":"","name":"Address_No_To"},{"value":"","name":"Suffix_From"},{"value":"","name":"Suffix_To"},{"value":"ROKEBY","name":"Street_Name"},{"value":"RD","name":"Street_Type"},{"value":"SUBIACO","name":"Locality_Name"},{"value":"6008","name":"Postcode"},{"value":"WA","name":"State"},{"value":"","name":"Property_Name"},{"value":"Unknown","name":"NBN_Loc_Id"}],"replicatorUpdateDateTime":"2019-05-02 21:06:18.69","addressValue":"200028791","addressType":"ADBOR_ID"},{"addressCharacteristics":[{"value":"","name":"Address_No_From"},{"value":"","name":"Address_No_To"},{"value":"","name":"Suffix_From"},{"value":"","name":"Suffix_To"},{"value":"GRALLINA","name":"Street_Name"},{"value":"WAY","name":"Street_Type"},{"value":"TAPPING","name":"Locality_Name"},{"value":"6065","name":"Postcode"},{"value":"WA","name":"State"},{"value":"","name":"Property_Name"},{"value":"Unknown","name":"NBN_Loc_Id"}],"replicatorUpdateDateTime":"2019-05-02 21:06:12.92","addressValue":"201193892","addressType":"ADBOR_ID"},{"addressCharacteristics":[{"value":"","name":"Address_No_From"},{"value":"","name":"Address_No_To"},{"value":"","name":"Suffix_From"},{"value":"","name":"Suffix_To"},{"value":"BOURKE","name":"Street_Name"},{"value":"ST","name":"Street_Type"},{"value":"DOCKLANDS","name":"Locality_Name"},{"value":"3008","name":"Postcode"},{"value":"VIC","name":"State"},{"value":"","name":"Property_Name"},{"value":"Unknown","name":"NBN_Loc_Id"}],"replicatorUpdateDateTime":"2019-05-02 21:06:12.92","addressValue":"419600150","addressType":"ADBOR_ID"},{"addressCharacteristics":[{"value":"","name":"Address_No_From"},{"value":"","name":"Address_No_To"},{"value":"","name":"Suffix_From"},{"value":"","name":"Suffix_To"},{"value":"DERWENT","name":"Street_Name"},{"value":"ST","name":"Street_Type"},{"value":"BELLERIVE","name":"Locality_Name"},{"value":"7018","name":"Postcode"},{"value":"TAS","name":"State"},{"value":"","name":"Property_Name"},{"value":"Unknown","name":"NBN_Loc_Id"}],"replicatorUpdateDateTime":"2019-05-02 21:06:12.92","addressValue":"50780148","addressType":"ADBOR_ID"}],"correlationId":"@@CORRELATIONID@@","cidn":"111"}';        
        return jsonString;
    }
}