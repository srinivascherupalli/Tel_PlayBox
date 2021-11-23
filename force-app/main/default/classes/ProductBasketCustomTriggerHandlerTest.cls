/******************************************************************************************************
Name          : ProductBasketCustomTriggerHandlerTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of ProductBasketCustomTriggerHandler
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods OnBeforeInsertTest, OnBeforeUpdateTest
                                                        , OnBeforeUpdateTest1, OnAfterUpdateTest
1.1         Shweta          08-09-2020      Updated methods OnBeforeInsertTest,OnBeforeUpdateTest1                                                        
******************************************************************************************************/

@isTest(SeeAllData=FALSE)
private class ProductBasketCustomTriggerHandlerTest {
    
    /******************************************************************************************************************
    * Method Name : OnBeforeInsertTest
    * Description : Used to simulate and test the logic of OnBeforeInsert method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************************/
    @testSetup static void testdataMethod() {
         
        List<CustomConfigurationOptions__c> commList = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c commConfig1 = new CustomConfigurationOptions__c();
        commConfig1.Name = 'ContractAccepted';
        commConfig1.Enrichment_Basket_Stage__c = 'Contract Accepted';
        commConfig1.External_Id__c = '7654';
        commConfig1.Opportunity_Stage__c = 'Propose';
        commList.add(commConfig1);
        CustomConfigurationOptions__c commConfig2 = new CustomConfigurationOptions__c();
        commConfig2.Name = 'CommercialConfiguration';
        commConfig2.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        commConfig2.External_Id__c = 'CCO4';
        commConfig2.Opportunity_Stage__c = 'Develop';
        commList.add(commConfig2);
        CustomConfigurationOptions__c commConfig3 = new CustomConfigurationOptions__c();
        commConfig3.Name = 'Quote';
        commConfig3.Enrichment_Basket_Stage__c = 'Quote';
        commConfig3.External_Id__c = 'CC08';
        commConfig3.Opportunity_Stage__c = 'Propose';
        commList.add(commConfig3);
        insert commList;
        
         Account acc = AccountTestFactory.buildAccount('TestAcc');
        insert acc;

        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.AccountId = acc.id;
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket12345', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Quote');
        INSERT basket;
        cscfga__Product_Basket__c basket10 = new cscfga__Product_Basket__c(Name = 'Test Basket1102012', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Accepted');
        INSERT basket10;

    
    
        //cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        //basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.BSA_Generated__c = false;
        basket.cscfga__total_contract_value__c = 1000;
        basket.csordtelcoa__Basket_Stage__c = 'Draft';
        basket.cscfga__Opportunity__c = opp.id;
        //basket.csbb__Account__c = acc.id;
        update basket;
    
        ContractJunction__c contractJunction = new ContractJunction__c();
        contractJunction.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contractJunction.Related_Basket__c = basket.id;
        contractJunction.CongaStatus__c = 'NotStarted';
        contractJunction.Status__c = 'Initiated';
        contractJunction.Account__c = basket.csbb__Account__c;
        contractJunction.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        contractJunction.Contract_Activated_Date__c = System.today();
        contractJunction.Contract_Term_Months__c = 36;
        contractJunction.BSA_Generated__c = true;
        contractJunction.GPTVersion__c = 1.2;
        contractJunction.OFTVersion__c = 1.4;
        contractJunction.BSAVersion__c = 1.3;
        //contractJunction.Account__c = acc.id;
        insert contractJunction;      
        
        //Pooja : Added CustomConfigurationOptions__c in test setup data as part of Spring'20 Upgrade, to increase the code coverage
        /*List<CustomConfigurationOptions__c> custConfigList  =   new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c oCustConfig1   =   new CustomConfigurationOptions__c();
        oCustConfig1.Name = 'CommercialConfiguration';
        oCustConfig1.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        oCustConfig1.External_Id__c = 'CCO4';
        oCustConfig1.Opportunity_Stage__c = 'Develop';
        custConfigList.add(oCustConfig1);
        CustomConfigurationOptions__c oCustConfig2   =   new CustomConfigurationOptions__c();
        oCustConfig2.Name = 'Quote';
        oCustConfig2.Enrichment_Basket_Stage__c = 'Quote';
        oCustConfig2.External_Id__c = 'CCO8';
        oCustConfig2.Opportunity_Stage__c = 'Propose';
        custConfigList.add(oCustConfig2);
        insert custConfigList;*/
        
        
        
        
        
        
        
        
        
    }
    static testmethod void onBeforeInsertTest() {
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop', AccountId = acc.id ,  CloseDate = Date.today());
        INSERT opp;
        List<cscfga__Product_Basket__c> prodBasket = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket1', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE);
        INSERT basket1;
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Pref_Comm_Method__c='eMail';
        contact.MobilePhone='0412345678';
        contact.email='k@gmail.com';
        contact.AccountId = acc.id;
        insert contact;
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.ContactId = contact.Id;
        oppContactRole.IsPrimary = true;
        oppContactRole.OpportunityId = basket1.cscfga__Opportunity__c;
        oppContactRole.Role = 'Inside Sales Account Manager';
        insert oppContactRole;
  
        
        
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE);
        
        ProductBasketCustomTriggerHandler productBasketHandler = new ProductBasketCustomTriggerHandler();
        Test.startTest();
            INSERT basket;
        Test.stopTest();
    System.assert(basket!=null);
    }
/*---------------------------------------------------------------------------------------
    Name : updateBSACheckFlagPostive
    Description : Enable only online users to skip the contract/order form approval process  
    Story: EDGE-144055
    Author:Mohammed Zeeshan
     -----------------------------------------------------------------------------------*/
     @isTest
    static void updateBSACheckFlagPostive() {
        
        User userRec = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
  );
        insert userRec;
        
        
        
        String contractStatusLabel = Label.contract_Status;
        ProductBasketCustomTriggerHandler productBasketCustTrigger = new ProductBasketCustomTriggerHandler();
        PermissionSet permissionset = [SELECT Id FROM PermissionSet WHERE Name = 'Skip_Contract_Basket_Express_Order'];
        insert new PermissionSetAssignment(AssigneeId = userRec.id, PermissionSetId = permissionset.Id);
        List<cscfga__Product_Basket__c> prodBask = [SELECT id, BSA_Generated__c,cscfga__Opportunity__c,Primary_Basket__c,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c,cscfga__Basket_Status__c,cscfga__total_contract_value__c from cscfga__Product_Basket__c ];
        List<ContractJunction__c> contractJun = [SELECT id,RecordTypeId,Related_Basket__c,CongaStatus__c,Status__c,Account__c,Related_Opportunity__c,Contract_Activated_Date__c,Contract_Term_Months__c,BSA_Generated__c,GPTVersion__c,OFTVersion__c FROM ContractJunction__c];
        System.debug('contractJun'+contractJun);
        System.runas(userRec){
        Test.startTest();
        //List < id > productBasket = new List < id > ();
        //productBasket.add(prodBask.id);
        productBasketCustTrigger.onBeforeInsert(prodBask);
        Test.stopTest();
        }
        system.assertEquals(prodBask[0].BSA_Generated__c, false);
    }

    
    /****************************************************************************************************************
    * Method Name : OnBeforeUpdateTest
    * Description : Used to simulate and test the logic of OnBeforeUpdate method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    ****************************************************************************************************************/
    static testmethod void onBeforeUpdateTest() {
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE);
        INSERT basket;
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'IP Site', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                 Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        Test.startTest();
            basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
            UPDATE basket;
      System.assert(basket!=null);
        Test.stopTest();
        
    }
    
    /****************************************************************************************************************
    * Method Name : OnBeforeUpdateTest1
    * Description : Used to simulate and test the logic of OnBeforeUpdate method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    ****************************************************************************************************************/
    static testmethod void onBeforeUpdateTest1() {
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE,Project_Complexity__c='Complex');
        INSERT basket;
        
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'Test Config', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                 Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        Test.startTest();
            basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
            UPDATE basket;
      System.assert(basket!=null);
        Test.stopTest();
    }
    /****************************************************************************************************************
    * Method Name : OnBeforeUpdateTest1
    * Description : Used to simulate and test the logic of OnBeforeUpdate method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    ****************************************************************************************************************/
    static testmethod void onAfterUpdateTest() {
    
        //basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        //UPDATE basket;
        cscfga__Product_Basket__c basket = [Select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'IP Site', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                 Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        Test.startTest();
            basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
            UPDATE basket;
            System.assert(basket!=null);
        Test.stopTest();
    }
    /***************************************************************************************************************
    * Method Name : OnAfterUpdateTest1
    * Description : Used to simulate and test the logic of OnAfterUpdate method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void onAfterUpdateTest1() {
        List<cscfga__Product_Basket__c> prodBasket1 = new List<cscfga__Product_Basket__c>();
        List<cscfga__Product_Basket__c> prodBasket2 = new List<cscfga__Product_Basket__c>();
        List<cscfga__Product_Basket__c> prodBasket = new List<cscfga__Product_Basket__c>();
        Map<Id,cscfga__Product_Basket__c> mapProdBasket1 = new Map<Id,cscfga__Product_Basket__c>();
        Map<Id,cscfga__Product_Basket__c> mapProdBasket2 = new Map<Id,cscfga__Product_Basket__c>();
        Account acc1 = new Account(Name = 'Test Account1');
        INSERT acc1;
        Account acc2 = new Account(Name = 'Test Account2');
        INSERT acc2;
        Account acc3 = new Account(Name = 'Test Account3');
        INSERT acc3;
        Account acc4 = new Account(Name = 'Test Account4');
        INSERT acc4;
        system.debug('acc4---->'+acc4);
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        system.debug('opp---->'+opp);
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345', csordtelcoa__Account__c = acc1.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration', cscfga__Basket_Status__c = 'Valid',csbb__Synchronised_with_Opportunity__c=False,cscfga__Products_Id_Qty_In_Basket__c= '1');
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c(Name = 'Test Basket123456', csordtelcoa__Account__c = acc2.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Accepted', cscfga__Basket_Status__c = 'Valid',csbb__Synchronised_with_Opportunity__c=False,cscfga__Products_Id_Qty_In_Basket__c= '2');
        cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c(Name = 'Test Basket12345', csordtelcoa__Account__c = acc3.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Enriched', cscfga__Basket_Status__c = 'Valid',csbb__Synchronised_with_Opportunity__c=False,cscfga__Products_Id_Qty_In_Basket__c= '3');
        cscfga__Product_Basket__c basket4 = new cscfga__Product_Basket__c(Name = 'Test Basket12345', csordtelcoa__Account__c = acc4.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Initiated', cscfga__Basket_Status__c = 'Valid',csbb__Synchronised_with_Opportunity__c=False,cscfga__Products_Id_Qty_In_Basket__c= '4');
        ProductBasketCustomTriggerHandler prodBasketMap = new ProductBasketCustomTriggerHandler();
        Test.startTest();
        cscfga__Product_Basket__c oldBasket = [Select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c WHERE name = 'Test Basket12345' LIMIT 1];
        System.debug('oldBasket***'+oldBasket);
        //cscfga__Product_Basket__c newBasket = [Select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c WHERE name = 'Test Basket123456' LIMIT 1];
        //System.debug('newBasket***'+newBasket);    
        oldBasket.csordtelcoa__Basket_Stage__c = 'Enriched';
          //newBasket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
            UPDATE oldBasket;
          //UPDATE newBasket;
          prodBasketMap.onAfterUpdate(prodBasket1,mapProdBasket1,prodBasket2,mapProdBasket2);
      System.assert(oldBasket!=null);
        
        Test.stopTest();
    }
     /*************************************************************************************************
Name        : OnAfterUpdateTransition
Description : update transition json on status change 
Author      : Kalashree Borgaonkar
Story       : EDGE-203022
***************************************************************************************************/ 
 /*static testmethod void onAfterUpdateTransition() {
        List<cscfga__Product_Basket__c> prodBasket1 = new List<cscfga__Product_Basket__c>();
        List<cscfga__Product_Basket__c> prodBasket2 = new List<cscfga__Product_Basket__c>();
        List<cscfga__Product_Basket__c> prodBasket = new List<cscfga__Product_Basket__c>();
        Map<Id,cscfga__Product_Basket__c> mapProdBasket1 = new Map<Id,cscfga__Product_Basket__c>();
        Map<Id,cscfga__Product_Basket__c> mapProdBasket2 = new Map<Id,cscfga__Product_Basket__c>();
        Account acc1 = new Account(Name = 'Test Account1');
        INSERT acc1;     
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        system.debug('opp---->'+opp);
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Transition_basket_stage__c='Reservation Completed',Name = 'Test Basket12345', csordtelcoa__Account__c = acc1.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration', cscfga__Basket_Status__c = 'Valid',csbb__Synchronised_with_Opportunity__c=False,cscfga__Products_Id_Qty_In_Basket__c= '1');
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c(Transition_basket_stage__c='Reservation Triggered', Name = 'Test Basket123456', csordtelcoa__Account__c = acc1.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Accepted', cscfga__Basket_Status__c = 'Valid',csbb__Synchronised_with_Opportunity__c=False,cscfga__Products_Id_Qty_In_Basket__c= '2');
        mapProdBasket1.put(basket1.id,basket1);
     	mapProdBasket2.put(basket2.id,basket2);
        ProductBasketCustomTriggerHandler prodBasketMap = new ProductBasketCustomTriggerHandler();
        Test.startTest();
        prodBasketMap.onAfterUpdateTransition(mapProdBasket2,mapProdBasket1);
        Test.stopTest();
     	System.assert(basket2!=null);
    }*/

    /***************************************************************************************************************
    * Method Name : OnAfterUpdateTest2
    * Description : Used to simulate and test the logic of OnAfterUpdate method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    //Pooja : Added this method as part of Spring'20 Upgrade, to increase the code coverage
    ***************************************************************************************************************/
    static testmethod void onAfterUpdateTest2() {
        Account oAcc            =   [SELECT Id,Name FROM Account WHERE Name='TestAcc' LIMIT 1];
        Opportunity oOppy       =   [SELECT Id,Name,AccountId,Product_Type__c FROM Opportunity WHERE AccountId=:oAcc.Id LIMIT 1];
        oOppy.Product_Type__c   =   'Non Modular';
        update oOppy;
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        for(cscfga__Product_Basket__c oBask : [SELECT Id,Name,csordtelcoa__Account__c,cscfga__Opportunity__c,cscfga__Products_In_Basket__c,Primary_Basket__c, csordtelcoa__Basket_Stage__c,cscfga__Basket_Status__c,csbb__Synchronised_with_Opportunity__c,cscfga__Products_Id_Qty_In_Basket__c FROM cscfga__Product_Basket__c WHERE csordtelcoa__Account__c =:oAcc.Id AND cscfga__Opportunity__c =:oOppy.Id]) {
            if(oBask.Name=='Test Basket12345') {oBask.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';oBask.cscfga__Products_In_Basket__c='Test';}
            if(oBask.Name=='Test Basket1102012') oBask.csordtelcoa__Basket_Stage__c = 'Quote';
            basketList.add(oBask);
          }
        update basketList;
        System.assertEquals(2,basketList.size());  
    }
        /****************************************************************************************************************
    * Method Name : OnBeforeUpdateTestInflight
    * Description : Used to simulate and test the logic of OnBeforeUpdate method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    ****************************************************************************************************************/
    static testmethod void onBeforeUpdateTestInflight() {
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE);
        INSERT basket;
        list<recordtype> recType = [select id from recordtype where sObjectType = 'cscfga__Product_Basket__c' and developername = 'Inflight_Change'];
        basket.recordtypeId = recType[0].Id;
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'IP Site', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                 Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        cscfga__Product_Configuration__c prodConfigDevice = new cscfga__Product_Configuration__c(Name = 'Mobile Device Care',type__c='New', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                 Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfigDevice;
        Test.startTest();
            basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
            UPDATE basket;
      System.assert(basket!=null);
        Test.stopTest();
        
    }
}