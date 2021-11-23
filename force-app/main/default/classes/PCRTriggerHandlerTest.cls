/*
===============================================================================================================================
Class : PCRTriggerHandler
Test Class : PCRTriggerHandlerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia 9/4/2018        EDGE-53878 + EDGE-69095(bug fix)

===============================================================================================================================
*/
@isTest
public class PCRTriggerHandlerTest {
    
    @testsetup
    public static void testDataSetup()
    {
        EnvironmentVariable__c cs=new EnvironmentVariable__c();
        cs.name='TransitionClone';
        cs.value__c='2';
        insert cs;        
                //Account
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '2022012339';

        acc.Customer_Status__c='ACTIVE';
        insert acc;
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        
        //Opportunity
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        //prod basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
        //product definition
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Mobility','Mobility');
        insert pd;
        //offer
        cscfga__Configuration_Offer__c offernameCWP= new cscfga__Configuration_Offer__c();
        offernameCWP.name='Connected Workplace';
        offernameCWP.cscfga__Active__c=true;
        offernameCWP.cscfga__Description__c='Connected Workplace';
        insert offernameCWP;
        cscfga__Configuration_Offer__c offernameCWP1= new cscfga__Configuration_Offer__c();
        offernameCWP1.name='Connected Workplace Package';
        offernameCWP.cscfga__Active__c=true;
        offernameCWP.cscfga__Description__c='Connected Workplace Package';
        insert offernameCWP1;
        cscfga__Configuration_Offer__c offernameMobility= new cscfga__Configuration_Offer__c();
        offernameMobility.name='CWP Mobility';
        offernameMobility.cscfga__Active__c=true;
        offernameMobility.cscfga__Description__c='CWP Mobility';
        insert offernameMobility;
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<csbb__Product_Configuration_Request__c> pcrList=new List<csbb__Product_Configuration_Request__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        //Pcs
        for (Integer i=0; i <= 10; i++)
        {           
            if(i<4)
            {
                cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.id);
                config.cscfga__Product_Definition__c = pd.id;
                config.cscfga__Product_Basket__c = basket.id;
                config.cscfga__Description__c = 'test Description '+i;
                config.cscfga__Contract_Term__c = 36;
                config.Commercial_Config__c='Yes';
                config.cscfga__total_one_off_charge__c=100;
                config.cscfga__total_recurring_charge__c=100;
                if (i >= 0 && i<=2)
                {
                    config.name='IP Site';
                    config.Type__c = 'New';
                    config.Offer_Reference__c = offernameCWP.id;
                   
                }  
                if(i == 3)     
                {
                    config.name='V2T Samsung Galaxy S9+ 256GB Black';
                    config.Type__c = 'New';
                    config.Offer_Reference__c =offernameMobility.id;
                    config.cscfga__Product_Family__c='Mobility';
                    config.cscfga__unit_recurring_charge__c = 200;
                }
                if(i == 4)     
                {
                    config.name='Samsung Galaxy S9+ 256GB Black';
                    config.Type__c = 'New';
                    config.Offer_Reference__c =offernameMobility.id;
                    config.cscfga__Product_Family__c='Mobile Device';
                    config.cscfga__unit_recurring_charge__c = 200;
                }
                prodConfigList.add(config);
            }else
            {
                csbb__Product_Configuration_Request__c testProductConfiguration = TestDataFactory.generateProdutConfigurationRequest();
            }
                     
        }
        insert prodConfigList;
        
        csbb__Product_Configuration_Request__c prodConfigReq = ProductTestFactory.buildConfigRequest(basket.Id,prodConfigList[0].Id);
        prodConfigReq.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895123","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';       
        insert prodConfigReq;
        
        csbb__Product_Configuration_Request__c prodConfigReq1 = ProductTestFactory.buildConfigRequest(basket.Id,prodConfigList[3].Id);
        prodConfigReq1.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895123","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';       
        insert prodConfigReq1;
        
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        
        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('CustomerFacingServiceId', 'test12345', prodConfigList[3].id);        
        insert attr0;
        
        system.debug('***prodConfigList***'+prodConfigList);
        system.debug('***prodConfigReq1***'+prodConfigReq1);
        
 
    }
    
    @isTest
    private static void updateRollUpFieldsOnProductBasket_WillSumTotal_WhenAddNewProductToBasket() {
        
        Account acc = AccountTestFactory.buildAccount('TestAcc');

        acc.Customer_Status__c='ACTIVE';
        insert acc;
        Test.startTest();
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        //List<csbb__Product_Configuration_Request__c> pcrs = [SELECT id FROM csbb__Product_Configuration_Request__c WHERE csbb__Product_Basket__c = :basket.id];   
        Map<Id, csbb__Product_Configuration_Request__c> pcrMap= new Map<Id, csbb__Product_Configuration_Request__c>([SELECT id FROM csbb__Product_Configuration_Request__c WHERE csbb__Product_Basket__c = :basket.id]);
        //PCRTriggerHandler.updateRollUpFieldsOnProductBasket(pcrMap.values(),pcrMap);
        System.assertEquals(1, pcrMap.size());
        DELETE [SELECT id FROM csbb__Product_Configuration_Request__c WHERE csbb__Product_Basket__c = :basket.id];
        System.assert(basket.cscfga__total_contract_value__c == null);
        Test.stopTest();
    }
  
    @isTest
    public static void testBasketStageDraftOnDeletionOfPCR()
    {
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        List<csbb__Product_Configuration_Request__c> pcrs = [SELECT id FROM csbb__Product_Configuration_Request__c WHERE csbb__Product_Basket__c = :basket.id];
        
        delete pcrs;
        Test.stopTest();
        cscfga__Product_Basket__c basket1 = [Select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where id=:basket.id];
        System.assertEquals(basket1.csordtelcoa__Basket_Stage__c,'Draft');
        
    }
    

    @isTest static void test_productDefinitionFieldClear() {
        /*cscfga__Product_Definition__c Pd=TestDataFactory.generateProductDefinition();
        Pd.name='Mobility';
        update Pd;*/
        ///added for Edge-91796
        test.startTest();

            List<csbb__Product_Configuration_Request__c> pcrList=[SELECT Id, Name, csbb__Optionals__c,csbb__Product_Configuration__c 
            FROM csbb__Product_Configuration_Request__c ];        

            //update pcrList;
        
        test.stopTest();
        List<csbb__Product_Configuration_Request__c> PRCTestData = [SELECT Id, Name, csbb__Optionals__c,csbb__Product_Configuration__c FROM csbb__Product_Configuration_Request__c WHERE csbb__Product_Configuration__r.name='V2T Samsung Galaxy S9+ 256GB Black'];
        System.assert(PRCTestData[0].csbb__Optionals__c.contains('selectedAddressDisplay'));

    }
     @isTest static void test_productDefinitionFieldClear_2() {
        /*cscfga__Product_Definition__c Pd=TestDataFactory.generateProductDefinition();
        Pd.name='Mobility';
        update Pd;*/
        test.startTest();
        List<csbb__Product_Configuration_Request__c> pcrList=new List<csbb__Product_Configuration_Request__c>();
        csbb__Product_Configuration_Request__c testProductConfiguration1 = TestDataFactory.generateProdutConfigurationRequest();
        testProductConfiguration1.csbb__Product_Configuration__c=null;
        pcrList.add(testProductConfiguration1);        
        update pcrList;
        test.stopTest();
        List<csbb__Product_Configuration_Request__c> PRCTestData = [SELECT Id, Name, csbb__Optionals__c,csbb__Product_Configuration__c FROM csbb__Product_Configuration_Request__c WHERE Id = :testProductConfiguration1.Id];
        ID pcId=null;
        System.assertEquals(testProductConfiguration1.csbb__Product_Configuration__c,pcId);
    }
    @isTest static void test_productDefinitionFieldClear1() {
        /*cscfga__Product_Definition__c Pd=TestDataFactory.generateProductDefinition();
        Pd.name='Mobility';
        update Pd;*/
        test.startTest();
        //List<csbb__Product_Configuration_Request__c> pcrList=new List<csbb__Product_Configuration_Request__c>();
        csbb__Product_Configuration_Request__c testProductConfiguration = TestDataFactory.generateProdutConfigurationRequest();
        //pcrList.add(testProductConfiguration);
        cscfga__Product_Configuration__c pc1=[select id,cscfga__Product_Definition__c from cscfga__Product_Configuration__c where id =:testProductConfiguration.csbb__Product_Configuration__c];
        cscfga__Product_Definition__c Pd1=[Select id,name from cscfga__Product_Definition__c where id=:pc1.cscfga__Product_Definition__c];
        Pd1.Site_Agnostic__c=true;
        update pd1;
        //pcrList.add(testProductConfiguration1);        
        update testProductConfiguration;
        test.stopTest();
        List<csbb__Product_Configuration_Request__c> PRCTestData = [SELECT Id, Name, csbb__Optionals__c FROM csbb__Product_Configuration_Request__c WHERE Id = :testProductConfiguration.Id];
        System.assert(PRCTestData[0].csbb__Optionals__c.contains('selectedAddressDisplay'));

    }
    @isTest static void test_trriggerdisabled(){
        Environment_Configurations__c environmentConfig =New Environment_Configurations__c();    
        environmentConfig.No_Triggers__c = true;
        insert environmentConfig;
        List<csbb__Product_Configuration_Request__c> pcrList=[SELECT Id, Name, csbb__Optionals__c,csbb__Product_Configuration__c 
            FROM csbb__Product_Configuration_Request__c ];        
        update pcrList;
        system.assert(pcrList!=null);        
    }
}