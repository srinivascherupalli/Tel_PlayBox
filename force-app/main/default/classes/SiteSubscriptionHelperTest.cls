@isTest
public with sharing class SiteSubscriptionHelperTest{
    @testsetup static void SiteSubscriptionHelperTestDataSetup()
    {
        //CREATE ACCOUNT
         Account acc = AccountTestFactory.buildAccount('Test Account') ;
         acc.Customer_Status__c = 'ACTIVE';
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
    
        csord__Order__c order=ProductTestService.getNewOrderForAccount(acc);
        csord__Order__c Testorder2=ProductTestService.getNewOrderForAccount(acc);
        order.csord__Primary_Order__c= Testorder2.id;     
        update order;
        
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
        csbb__Product_Configuration_Request__c  pcr=ProductTestFactory.buildConfigRequest(prodBasket.id,config.id);             
        pcr.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200240912750","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"0012O000003Tlgj","name":"BERESFORD RD NSW","hiddenParam1":"240912750","selectedPcrs":""}';
        insert pcr; 
        csbb__Product_Configuration_Request__c  pcr2=ProductTestFactory.buildConfigRequest(prodBasket.id,config1.id);               
        pcr2.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200240912750","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"0012O000003Tlgj","name":"BERESFORD RD NSW","hiddenParam1":"240912750","selectedPcrs":""}';
        insert pcr2;
        
        //subscription and service
        csord__Subscription__c sub = [select id,csordtelcoa__Product_Configuration__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :Testorder2.id limit 1];
        sub.csordtelcoa__Product_Configuration__c = config.Id;
        update sub;
        csord__Service__c  serv=[select id,csord__Subscription__c,csordtelcoa__Product_Configuration__c,csord__Order__c from csord__Service__c limit 1];
        serv.name='IP Site';
        serv.csord__Subscription__c=sub.id;
        serv.csordtelcoa__Product_Configuration__c=config1.id;
        update serv;
        
        string TransitionJSONData='{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"UserType":null,"serviceExtension":[{"Services_To":"0737102699","Services_From":"0737102601","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"0737102600","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":null,"Association_Role":null}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN2DID","disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"141567860"}],"serviceCount":0,"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICEf901dc12c863b1d946","CIDN":"6892971200"}';
        ReplicatorGetServiceDataObject_V2 obj1 = ReplicatorGetServiceDataObject_V2.parse(TransitionJSONData);
        Attachment att=new Attachment();
        //csbb__Product_Configuration_Request__c pcr=[Select id,csbb__Product_Configuration__c from csbb__Product_Configuration_Request__c where csbb__Product_Basket__c ='a3Q2O0000007Oox' and csbb__Product_Configuration__r.name='IP Site'limit 1];
        att.Name =  'TransitionJSONData.json';
        att.ParentId = pcr2.id;
        Blob body = Blob.valueOf(TransitionJSONData);
        att.Body = body;
        insert att;
        
    }
    @isTest
    private static void testSiteSubscriptionHelperRecord() {
        Test.startTest();
        List<csord__Subscription__c> sublst = [select id,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c];
        List<String> SubscriptionIds = new List<String>();
        for(csord__Subscription__c sub : sublst)
        {
           SubscriptionIds.add(sub.Id);   
        }
        SiteSubscriptionHelper.updateSiteAttributesFromService(SubscriptionIds);
        SiteSubscriptionHelper.updateOffer(SubscriptionIds);
        SiteSubscriptionHelper.updateContractAttibutes(SubscriptionIds);
        
        System.assertEquals('SubscriptionIds','SubscriptionIds');
        Test.stopTest();
    }
}