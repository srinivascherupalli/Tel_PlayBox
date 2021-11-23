/**=============================================================================================================================
Class : TransitionServiceObserverHelperTest
===============================================================================================================================*/
@isTest
public with sharing class TransitionServiceObserverHelperTest {
    @testsetup static void TransitionServicesCreationTestDataSetup()
    {
        // CREATE  ACCOUNT
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
        cscfga__Product_Configuration__c config2= ProductTestFactory.buildProductConfig(pd.Id);
        config2.name= 'Next Generation Voice';
        config2.cscfga__Product_Basket__c = prodBasket.Id;
        configList.add(config2);
        insert configList;
        csbb__Product_Configuration_Request__c  pcr=ProductTestFactory.buildConfigRequest(prodBasket.id,config.id);             
        pcr.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200240912750","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"0012O000003Tlgj","name":"BERESFORD RD NSW","hiddenParam1":"240912750","selectedPcrs":""}';
        insert pcr; 
        csbb__Product_Configuration_Request__c  pcr2=ProductTestFactory.buildConfigRequest(prodBasket.id,config1.id);               
        pcr2.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200240912750","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"0012O000003Tlgj","name":"BERESFORD RD NSW","hiddenParam1":"240912750","selectedPcrs":""}';
        insert pcr2;
        
        //subscription and service
        csord__Subscription__c sub1 = [select id,csordtelcoa__Product_Configuration__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :Testorder2.id limit 1];
        sub1.csordtelcoa__Product_Configuration__c = config.Id;
        update sub1;
        csord__Service__c  serv1=[select id,csord__Subscription__c,csordtelcoa__Product_Configuration__c,csord__Order__c from csord__Service__c limit 1];
        serv1.name='IP Site';
        serv1.csord__Subscription__c=sub1.id;
        serv1.csordtelcoa__Product_Configuration__c=config1.id;
        update serv1;
        
        //nguc Subscription and service
        csord__Subscription__c sub2 = [select id,csordtelcoa__Product_Configuration__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where csord__Order__r.csord__Primary_Order__c = :Testorder2.id limit 1];
        sub2.csordtelcoa__Product_Configuration__c = config.Id;
        update sub2;
        csord__Service__c  serv2=[select id,csord__Subscription__c,csordtelcoa__Product_Configuration__c,csord__Order__c from csord__Service__c limit 1];
        serv2.name='IP Site';
        serv2.csord__Subscription__c=sub2.id;
        serv2.csordtelcoa__Product_Configuration__c=config2.id;
        update serv2;
        //EDGE-154518 - Changed Role from Primary to prime
        //EDGE-156658 - Added gdn association role.
        string TransitionJSONData='{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[],"Service_Type":"Voice","Service_Id":"0893490044","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false},{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[],"Service_Type":"Voice","Service_Id":"0893490045","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":"gdn"}],"disableCheck":null,"checkValue":false}],"Product_Type":"PSTN","disableCheck":null,"checkValue":true},{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"0893457399","Services_From":"0893457334","disableCheck":null,"checkValue":false},{"Services_To":"0893457332","Services_From":"0893457300","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"0893457333","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"In Dial","Association_Role":"prime"}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN2DID","disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"402260799"}],"serviceCount":1,"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICE476dadf94c4f78f9cb","CIDN":"8873362089"}';
        ReplicatorGetServiceDataObject_V2 obj1 = ReplicatorGetServiceDataObject_V2.parse(TransitionJSONData);
        Attachment att=new Attachment();       
        att.Name =  'TransitionJSONData.json';
        att.ParentId =config2.id;
        Blob body = Blob.valueOf(TransitionJSONData);
        att.Body = body;
        insert att;
        
        string TransitionDataNguc='{"CIDN":"6867443938","Correlation_Id":"caf18f80ff7424d9ee","Error_Code":"", "Error_Description":"", "productList":[{"checkValue":null,"disableCheck":null,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"PSTN","site":[ {"ADBOR_Id":"50485531","Error_Code":null,"Error_Description":null,"linkedSiteId":"","serviceList":[{"checkReserved":false,"checkValue":false,"disableCheck":null,"EligibilityReason":null,"EligibilityStatus":null,"groupType":[{"checkValue":false,"disableCheck":null,"groupId":"0360000891","service":[{"accountDetails":null,"calling_line_identifier":null,"contract_term":null,"devices":null,"directory_listing":null,"Eligibility_status":null,"eligibilityReason":null,"eligibilityStatus":null,"idd":null,"imsi_number":null,"international_roaming":null,"message_bank":null,"plan_name":null,"Reason":null,"replicatorUpdateDateTime":"2019-11-21 05:02:18.71","Reserve_status":null,"service_association_role":"","Service_Id":"0360000891","service_status":null,"service_type":"voice","service_type_code":null,"serviceExtensions":[{"checkReserved":false,"eligibilityReason":null,"eligibilityStatus":null,"Reason":null,"Reserve_status":null,"serviceExtensionFrom":"0360000200","serviceExtensionTo":"0360000240"}],"sim_serial_number":null}],"transitionId":null}],"Service_Type":"voice"}],"siteName":null}]},{"checkValue":null,"disableCheck":null,"eligibilityReason":null,"eligibilityStatus":null,"Product_Type":"ISDN30","site":[{"ADBOR_Id":"50485996","Error_Code":null,"Error_Description":null,"linkedSiteId":"A_END_ADDRESS","serviceList":[{"checkReserved":true,"checkValue":false,"disableCheck":null,"EligibilityReason":null,"EligibilityStatus":null,"groupType":[{"checkValue":true,"disableCheck":null,"groupId":"0360000652","service":[{"accountDetails":null,"calling_line_identifier":null,"contract_term":null,"devices":null,"directory_listing":null,"Eligibility_status":"Eligible","eligibilityReason":null,"eligibilityStatus":null,"idd":null,"imsi_number":null,"international_roaming":null,"message_bank":null,"plan_name":null,"Reason":null,"replicatorUpdateDateTime":"2019-05-06 17:41:50.573","Reserve_status":"Completed","service_association_role":null,"Service_Id":"0360000652","service_status":null,"service_type":null,"service_type_code":null,"serviceExtensions":[{"checkReserved":true,"eligibilityReason":null,"eligibilityStatus":null,"Reason":null,"Reserve_status":"Completed","serviceExtensionFrom":"0360000200","serviceExtensionTo":"0360000240"}],"sim_serial_number":null}],"transitionId":"8da747ba-698f-49c5-bac9-1d600ed46479"}],"Service_Type":null}],"siteName":null}]}],"serviceCount":0,"Source_System_Id":"Replicator"}"}';
        TransitionDataDTO obj2 = TransitionDataDTO.parse(TransitionDataNguc);
        Attachment att2=new Attachment();       
        att2.Name =  'TransitionDataNguc.json';
        att2.ParentId =config2.id;
        Blob body2 = Blob.valueOf(TransitionDataNguc);
        att2.Body = body2;
        insert att2;
        
    }
    @isTest
    private static void testTransitionServiceRecord() {
        Test.startTest();
        List<csord__Subscription__c> sublst = [select id,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c];
        List<String> SubscriptionIds = new List<String>();
        for(csord__Subscription__c sub : sublst)
        {
           SubscriptionIds.add(sub.Id);   
        }
        TransitionServicesCreationObserverHelper.createLegacyServices(SubscriptionIds);
        
        System.assertEquals('SubscriptionIds','SubscriptionIds');
        Test.stopTest();
    }
    //EDGE-149573 - Added to check Specs created
    @isTest
    private static void testTransitionServiceRecord1() {
        Test.startTest();
        List<csord__Subscription__c> sublst = [select id,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Product_Configuration__c from csord__Subscription__c];
        List<String> SubscriptionIds = new List<String>();
        for(csord__Subscription__c sub : sublst)
        {
           SubscriptionIds.add(sub.Id);   
        }
        TransitionServicesCreationObserverHelper.createLegacyServices(SubscriptionIds);
        Attachment att = [SELECT Id,name,body,ParentID FROM Attachment where name = 'ServiceSpecifications.json' limit 1];
        Test.stopTest();
        System.assertEquals(true, att.body.toString().contains('NextGenerationVoiceProductInstanceID'));
        //EDGE-152029 - Added Asserts to validate transtionId attribute Name contains in the serviceSpecifiation file.
        System.assertEquals(true, att.body.toString().contains('transitionId'));
        System.assertEquals(false, att.body.toString().contains('Transition ID'));
    }
    //EDGE-151668
    @isTest
    private static void testTransitionServiceRecord2() {
        Test.startTest();
        List<csord__Subscription__c> sublst = [select id,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c];
        List<String> SubscriptionIds = new List<String>();
        for(csord__Subscription__c sub : sublst)
        {
           SubscriptionIds.add(sub.Id);   
        }
        TransitionServicesCreationObserverHelper.createLegacyServices(SubscriptionIds);
        Attachment attachment = [SELECT Id,body,Name,ParentID FROM Attachment LIMIT 1];
        Test.stopTest();
        System.assertEquals(false,attachment.body.toString().contains('0360000652'));
        System.assertEquals(true, attachment.body.toString().contains('0893457333'));
        //EDGE-156658 - Added gdn association role.
        System.assertEquals(true, attachment.body.toString().contains('0893490045'));
    }
}