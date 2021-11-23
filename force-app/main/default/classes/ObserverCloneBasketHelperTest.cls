@isTest
public with sharing class ObserverCloneBasketHelperTest {
    @isTest
    private static void TransitionServicesCreationTestDataSetup()
    {
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='test123';
        insert acc;
        System.assertNotEquals(null,acc);
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
        prodBasket .csbb__Account__c = acc.id;
        prodBasket .cscfga__Opportunity__c = opp.id;
        prodBasket .Name = 'basket1';
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
        pcr.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200240912750","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"0012O000003Tlgj","name":"BERESFORD RD NSW","hiddenParam1":"240912750","selectedPcrs":""}';
        pcrList.add(pcr);   
        csbb__Product_Configuration_Request__c  pcr2=ProductTestFactory.buildConfigRequest(prodBasket.id,config1.id);                       pcr2.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200240912750","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"0012O000003Tlgj","name":"BERESFORD RD NSW","hiddenParam1":"240912750","selectedPcrs":""}';
        pcrList.add(pcr2);
        insert pcrList;
        
        Test.startTest();
        ObserverCloneBasketHelper.CreateStiteAndaddresses(pcr.id,'test123','test');
        Test.stopTest();
    }

}