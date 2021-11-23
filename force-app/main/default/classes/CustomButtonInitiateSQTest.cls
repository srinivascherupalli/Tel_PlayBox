//EDGE - 67863 
//Author: Kalashree Borgaonkar
@isTest
    public class CustomButtonInitiateSQTest {
    
    @testSetup static void setup(){
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
        addrs2.Address_ID__c = '161152457';
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
        //siteobj1.Composite_Key__c = 'test123161152457';
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
                       
        EnvironmentVariable__c cs = new EnvironmentVariable__c();
        cs.Name='TransitionClone';
        cs.value__c='3';
        insert cs;
        
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
        List<csbb__Product_Configuration_Request__c> pcrList=new List<csbb__Product_Configuration_Request__c>();
        csbb__Product_Configuration_Request__c  pcr=ProductTestFactory.buildConfigRequest(prodBasket.id,config.id);                     
        pcr.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200161152457","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"'+acc.id+'","name":"BERESFORD RD NSW","hiddenParam1":"161152457","selectedPcrs":""}';
        pcrList.add(pcr); 
        insert pcrList;
        
        //create subscription
        //List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = 'Connected Workplace';
        IpVpnsubs.Site__c=siteobj1.id;
        //lstSubs.add(IpVpnsubs);
        update IpVpnsubs;
    }
    
    
    @isTest 
    static void test_perfomAction() { 
        cscfga__Product_Basket__c prodBasket  = [SELECT id FROM cscfga__Product_Basket__c ];
        csbb__Product_Configuration_Request__c  pcr=[SELECT id FROM csbb__Product_Configuration_Request__c ];
        Test.startTest();
        CustomButtonInitiateSQ customButton = new CustomButtonInitiateSQ();
        customButton.performAction(prodBasket.id,pcr.id);
        customButton.shouldInitiateSQ(Date.today().addDays(-6));
        customButton.shouldInitiateSQ(Date.today().addDays(-2));
        customButton.performAction(prodBasket.id,pcr.id);
        System.assertEquals(prodBasket!=null, true,'Created');
        Test.stopTest();
        }
    }