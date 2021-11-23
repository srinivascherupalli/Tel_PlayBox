/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 18 March 2019
 * Description : Test Class to cover :  SiteSQContractCallout Class
 * Revision :
 * 
 * *****************************************************************************/
@IsTest
public class SiteSQContractCalloutTest {
    @testSetup static void setup(){
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
        System.assertNotEquals(null,lstAddress.Size());
        //Create site
        cscrm__Site__c siteobj1 = new cscrm__Site__c();
        siteobj1.Name = 'Test Site1';
        siteobj1.cscrm__Account__c = acc.id;
        siteobj1.cscrm__Installation_Address__c = lstAddress[0].Id;
        siteobj1.Status__c = 'Active';
        siteobj1.Legacy__c = true;
        insert siteobj1;
        System.assertNotEquals(null,siteobj1);
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
        System.assertNotEquals(null,prodBasket);              
        
        
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
        System.assertNotEquals(null,configList.Size());
        
        //EDGE-80772 : commented for Solution Console retrofit 
        /*List<csbb__Product_Configuration_Request__c> pcrList=new List<csbb__Product_Configuration_Request__c>();
        csbb__Product_Configuration_Request__c  pcr=ProductTestFactory.buildConfigRequest(prodBasket.id,config.id);                     
        pcr.csbb__Optionals__c='{"selectedAddressDisplay":"","site_nick_name_c":null,"Address_Status_c":null,"status_c":"CO","cscrm_floor_c":"","legacy_c":"true","cscrm_installation_address_details_c":"","cscrm_installation_address_r_cscrm_zip_postal_code_c":"2135","cscrm_installation_address_r_cscrm_state_province_c":"NSW","cscrm_installation_address_r_locality_c":"STRATHFIELD","cscrm_installation_address_r_cscrm_street_name_c":"BERESFORD","cscrm_installation_address__r_sub_address_4_type_c":"","cscrm_installation_address_r_sub_address_4_number_c":"","cscrm_installation_address_r_sub_address_3_type_c":"","cscrm_installation_address_r_sub_address_3_number_c":"","cscrm_installation_address_r_sub_address1_type_c":"","cscrm_installation_address_r_sub_address1_number_c":"","cscrm_installation_address_r_sub_address2_type_c":"","cscrm_installation_address_r_sub_address2_number_c":"","cscrm_installation_address_r_streetnumberendsuffix_c":"","cscrm_installation_address__r_streetnumberstartsuffix_c":"","cscrm_installation_address_r_cscrm_street_type_c":"RD","cscrm_installation_address__r_street_number_from_calc_c":"68","cscrm_installation_address_r_street_number_to_c":"72","composite_key_c":"6892971200161152457","site_migration_flag_c":"N","service_class_c":"3","order_stability_date_c":"","site_composition_c":"Legacy","disconnect_wave_c":"10","servicability_c":"Serviceable","in_flight_order_c":"N","disconnection_date_c":"","display_name_c":"","cscrm_installation_address_c":null,"cscrm_account_c":"'+acc.id+'","name":"BERESFORD RD NSW","hiddenParam1":"161152457","selectedPcrs":""}';
        pcrList.add(pcr); 
        insert pcrList;
        */
        //create subscription
        //List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        csord__Subscription__c IpVpnsubs = ProductTestService.getNewSubscriptionForAccount(acc);
        IpVpnsubs.Name = 'Connected Workplace';
        IpVpnsubs.Site__c=siteobj1.id;
        //lstSubs.add(IpVpnsubs);
        update IpVpnsubs;
    }
   
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 21 June 2019
 * Description : test coverage for Success/Positive scenario's of methods : initiateSQService
 
 * *****************************************************************************/
   @isTest 
    static void test_ResponseMethodSuccess() { 
    
       List<cscrm__Site__c> siteList = [Select id,AdborID__c from cscrm__Site__c]; 
       Account acc = [Select Id From Account Limit 1];
         List<String> adbList = new List<String>();
          for(cscrm__Site__c cs : siteList){
             adbList.add(cs.AdborID__c ); 
          }
      Test.StartTest();
      SiteSQContractCallout stCallout = new SiteSQContractCallout();
      Test.setMock(HttpCalloutMock.class, new SiteSqContractCalloutMock());
      Map<String,HttpResponse>  initiateSQService =  stCallout.initiateSQService(adbList,acc.Id);
      System.assertNotEquals(initiateSQService, null);
      
        Test.StopTest(); 
    }
    
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 21 June 2019
 * Description : test coverage for error/negative scenario's of methods : initiateSQService
 
 * *****************************************************************************/
      @isTest 
    static void test_ResponseMethodError() { 
    
       List<cscrm__Site__c> siteList = [Select id,AdborID__c from cscrm__Site__c]; 
       Account acc = [Select Id From Account Limit 1];
         List<String> adbList = new List<String>();
          for(cscrm__Site__c cs : siteList){
             adbList.add(cs.AdborID__c ); 
          }
      Test.StartTest();
      SiteSQContractCallout stCallout = new SiteSQContractCallout();
     
      Map<String,HttpResponse>  initiateSQService =  stCallout.initiateSQService(adbList,acc.Id);
      System.assertEquals(initiateSQService, null);
      
        Test.StopTest(); 
    }
    
        /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 21 June 2019
 * Description : test coverage for success/positive scenario's of methods : callSQService,shouldInitiateSQ
 
 * *****************************************************************************/
    @isTest
    static void callSQServiceTest_Success(){
        //CREATE ACCOUNT
         List<cscrm__Site__c> siteList = [Select id,AdborID__c from cscrm__Site__c]; 
         Account acc = [Select Id From Account Limit 1];
         List<String> adbList = new List<String>();
          for(cscrm__Site__c cs : siteList){
             adbList.add(cs.AdborID__c ); 
          }
        String token = 'nKn4tC4uOTIuWrjtzlvdet7uU5av';
        Test.setMock(HttpCalloutMock.class, new SiteSqContractCalloutMock());
        SiteSQContractCallout stCallout = new SiteSQContractCallout();
       // Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        Test.StartTest();
        Map<String,HttpResponse> callSQServiceMap = stCallout.callSQService(token, adbList,acc.Id); 
        System.assertNotEquals(callSQServiceMap, null);
        Boolean dateResult = stCallout.shouldInitiateSQ(System.Today());
        System.assertNotEquals(dateResult, null);
        Test.StopTest();
        
    }
     
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 21 June 2019
 * Description : test coverage for error/negative scenario's of methods : callSQService,shouldInitiateSQ
 
 * *****************************************************************************/
    @isTest
    static void callSQServiceTest_Error(){
        //CREATE ACCOUNT
         List<cscrm__Site__c> siteList = [Select id,AdborID__c from cscrm__Site__c]; 
         Account acc = [Select Id From Account Limit 1];
         List<String> adbList = new List<String>();
          for(cscrm__Site__c cs : siteList){
             adbList.add(cs.AdborID__c ); 
          }
        String token = 'nKn4tC4uOTIuWrjtzlvdet7uU5av';
       
        SiteSQContractCallout stCallout = new SiteSQContractCallout();
        Test.StartTest();
        Map<String,HttpResponse> callSQServiceMap = stCallout.callSQService(token, adbList,acc.Id); 
        System.assertEquals(callSQServiceMap, null);
        Boolean dateResult = stCallout.shouldInitiateSQ(System.Today());
        System.assertEquals(dateResult, false);
        Test.StopTest();
        
    }
    
      /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 21 June 2019
 * Description : test coverage for Success/positive scenario's of methods : configurableAddress
 
 * *****************************************************************************/
    @isTest
    static void configurableAddressTest_Success(){
        List<cscrm__Site__c> siteList = [Select id,AdborID__c from cscrm__Site__c]; 
        Account acc = [Select Id From Account Limit 1];
         List<String> adbList = new List<String>();
          for(cscrm__Site__c cs : siteList){
             adbList.add(cs.AdborID__c ); 
          }
        SiteSQContractCallout stCallout = new SiteSQContractCallout();
        
        List<String> ConfigurableList = stCallout.getConfigurableAddressIdList(adbList,acc.Id);
        System.assertNotEquals(ConfigurableList, null);
    }
    
      /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 21 June 2019
 * Description : test coverage for Error/Negative scenario's of methods : configurableAddress
 
 * *****************************************************************************/
    
     @isTest
    static void configurableAddressTest_Error(){
        List<cscrm__Site__c> siteList = [Select id,AdborID__c from cscrm__Site__c]; 
        Account acc = [Select Id From Account Limit 1];
         List<String> adbList = new List<String>();
          for(cscrm__Site__c cs : siteList){
             adbList.add(cs.AdborID__c + '11' ); 
          }
        SiteSQContractCallout stCallout = new SiteSQContractCallout();
        
      List<String> ConfigurableList = stCallout.getConfigurableAddressIdList(adbList,acc.Id);
      System.assertEquals(ConfigurableList.Size(), 0);
    }
    
    @isTest
    static void SiteSQContractCalloutTest1(){
        SiteSQContractCallout stCallout = new SiteSQContractCallout('BasketClone');
        
        SiteSQContractCallout stCallout1 = new SiteSQContractCallout('Contract');
        //System.assertEquals(5,stCallout1.configurablePeriod);
        System.assert(stCallout1!=null);
    }

}