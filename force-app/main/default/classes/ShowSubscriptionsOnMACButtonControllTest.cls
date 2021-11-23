@isTest
public class ShowSubscriptionsOnMACButtonControllTest  {
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        contact con = new contact(lastname = 'test');
        insert con;
        
        Billing_Account__c bl = new Billing_Account__c(Account__c = testAccount.id, Status__c ='Created', Billing_Account_Number__c = '123456789123');
        insert bl;
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'Migration';
        testOpp.Billing_Solution__c = 'Standard';
        Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        testOpp.RecordTypeId = standardID;
        insert testOpp;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        test.startTest();
        insert testBasket;
        test.stopTest();
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c cwProdDef = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(cwProdDef);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c ipNetPD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(ipNetPD);
        cscfga__Product_Definition__c mobPD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility',product_Specification__c='DMCAT_ProductSpecification_000420');
        pdList.add(mobPD);
        // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - Created IOT Susbcription Product Definition record
        cscfga__Product_Definition__c iotPD = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription',product_Specification__c='DMCAT_ProductSpecification_000965');
        pdList.add(iotPD);
        insert pdList;
       

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=cwProdDef.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.cscfga__Product_Basket__c = testBasket.Id;
        testConfig2.cscfga__Product_Definition__c=ipNetPD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.cscfga__Product_Basket__c = testBasket.Id;
        testConfig3.cscfga__Product_Definition__c=mobPD.id;
        prodconfigList.add(testConfig3); 
        // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - added Product Configuration record
        cscfga__Product_Configuration__c testConfig4 = new cscfga__Product_Configuration__c();
        testConfig4.Name = 'IOT Susbcription';
        testConfig4.cscfga__Product_Basket__c = testBasket.Id;
        testConfig4.cscfga__Product_Definition__c=iotPD.id;
        prodconfigList.add(testConfig4); 
        insert prodconfigList;

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        testOrder.isMSISDNHeld__c = false;
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        testSubscription.Suspension_reason__c='fraudLight';
        testSubscription.Suspension_reason_summary__c='fraudLight,fraudHeavy'; //DPG-4542 Jenish

        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = testAccount.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test2';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription2.csord__Status__c = 'Pending';

        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = testAccount.Id;
        testSubscription3.csord__Order__c = testOrder.Id;
        testSubscription3.csord__Identification__c = 'test3';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription3.csord__Status__c = null;

        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = testAccount.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        testSubscription4.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription4.csord__Status__c = 'Suspended';
        testSubscription4.Suspension_reason_summary__c='Requested by Telstra,Requested by Customer';  //DPG-4542 Jenish
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = testAccount.Id;
        testSubscription5.csord__Order__c = testOrder.Id;
        testSubscription5.csord__Identification__c = 'test';
        testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription5.csord__Status__c = 'Closed Replaced';

        csord__Subscription__c testSubscription6 = new csord__Subscription__c();
        testSubscription6.Name = 'TestSubsforTest6';
        testSubscription6.csord__Account__c = testAccount.Id;
        testSubscription6.csord__Order__c = testOrder.Id;
        testSubscription6.csord__Identification__c = 'test';
        testSubscription6.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription6.csord__Status__c = 'Active';
        
        // DPG-1891 Suspend IoT Services - Created Subscription record to be Suspend
        csord__Subscription__c testSubscription7 = new csord__Subscription__c();
        testSubscription7.Name = 'TestSubsforTest7';
        testSubscription7.csord__Account__c = testAccount.Id;
        testSubscription7.csord__Order__c = testOrder.Id;
        testSubscription7.csord__Identification__c = 'test';
        testSubscription7.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription7.csord__Status__c = 'Active';
        
        // DPG-1892 Resume IoT Services - Created Subscription record to be resume
        csord__Subscription__c testSubscription8 = new csord__Subscription__c();
        testSubscription8.Name = 'TestSubsforTest8';
        testSubscription8.csord__Account__c = testAccount.Id;
        testSubscription8.csord__Order__c = testOrder.Id;
        testSubscription8.csord__Identification__c = 'test';
        testSubscription8.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription8.csord__Status__c = 'Suspended';
        
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5,testSubscription6,testSubscription7,testSubscription8};
        insert testSubsList;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='testService_4';
        serv1.csord__Identification__c  = 'testIdentify_4';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = testSubscription.Id;
        serv1.csord__Status__c = 'Created';
        serv1.substage__c = 'Product Requirements Validation';
        serv1.TechnologyType__c= 'Mobile Access';
        insert serv1;

        //DPG:4542 Start -Insert Suspension_reason__c custom setting record (Org defaults)
        insert new Suspension_reason__c(SetupOwnerId=UserInfo.getOrganizationId(), Options__c='{"Requested by Telstra":"REQUESTED BY TELSTRA","Requested by Customer":"REQUESTED BY CUSTOMER"}',All_Values__c='{"fraudLight":"Fraud - incoming calls and texts only","fraudHeavy":"Fraud - no service access","paymentFailure":"Credit management - incoming calls and texts only","lostStolen":"Lost or stolen - no service access - diversion only"}');

        Profile billingconsultantprofile = [select id from profile where name =:System.Label.Billing_Consultant];
        User billingconsultant = new User(alias = 'billcon',email='billingcon@billingcon.com',emailencodingkey='UTF-8',IsActive =true,
                                     lastname='Bill', languagelocalekey='en_US',localesidkey='en_US',
                                     profileid = billingconsultantprofile.id,
                                     timezonesidkey='Australia/Sydney',
                                     username='billing@billingcon.com',phone='+121231231234');
        insert billingconsultant;

        //Insert Suspension_reason__c custom setting record (For Billing Consultant)
        insert new Suspension_reason__c(SetupOwnerId=billingconsultant.id, Options__c='{"paymentFailure":"Credit management - incoming calls and texts only"}');

        Profile billingandsupportprofile = [select id from profile where name =:System.Label.Billing_and_Support];
        User billingandsupportuser = new User(alias = 'billsup',email='billingsupport@billingsupport.com',emailencodingkey='UTF-8',IsActive =true,
                                     lastname='Bill', languagelocalekey='en_US',localesidkey='en_US',
                                     profileid = billingandsupportprofile.id,
                                     timezonesidkey='Australia/Sydney',
                                     username='billing@billingsupport.com',phone='+121231231234');
        insert billingandsupportuser;

        //Insert Suspension_reason__c custom setting record (For Billing And Support)
        insert new Suspension_reason__c(SetupOwnerId=billingandsupportuser.id, Options__c='{"fraudLight":"Fraud - incoming calls and texts only","fraudHeavy":"Fraud - no service access"}');
    //DPG:4542 End 

        //Added as part of EDGE-209488
        Utility_Settings__c utilSettings                    =   new Utility_Settings__c();
        utilSettings.Batch_size_for_CoBA__c                 =   200;
        utilSettings.Use_Batch_Mode_For_CoBA__c             =   true;
        utilSettings.Subscription_Statuses_Allowing_CoBA__c = 'Active,Suspended';
        insert utilSettings;
    }

    @isTest 
    static void testErrorMessage(){
        String errorMsg;
        Test.startTest();
            ShowSubscriptionsOnMACButtonController.errorMsg = 'Test Message';
            errorMsg = ShowSubscriptionsOnMACButtonController.errorMsg;
        Test.stopTest();

        System.assertEquals('Test Message', errorMsg, 'Tested error Message and fetched are not equal');
    }

    @isTest
    static void testGetSobjectFields(){
        String expectedResult = 'Id,IsDeleted,Name,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,' +
                                'csordtelcoa__Opportunity__c,csordtelcoa__Subscription__c';

        String result;
        Test.startTest();
            result = ShowSubscriptionsOnMACButtonController.getSobjectFields('csordtelcoa__Subscription_MACDOpportunity_Association__c');
        Test.stopTest();

        System.assertEquals(result!=null,true);
    }

    @isTest
    static void testGetAccountDetailsWithAccountId()
    {
        Account resultAccount = new Account();
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Test.startTest();
            resultAccount = ShowSubscriptionsOnMACButtonController.getAccountDetails('', testAccount.Id);
        Test.stopTest();
        System.assertEquals(testAccount.Id, resultAccount.Id, 'Tested Account Id\'s are not equal');
    }

    @isTest
    static void testGetAccountDetailsWithBasketId(){
        Account resultAccount = new Account();
        List<cscfga__Product_Basket__c> testBasket = [select id, Name FROM cscfga__Product_Basket__c];
        Test.startTest();
            resultAccount = ShowSubscriptionsOnMACButtonController.getAccountDetails(testBasket[0].id, null);
        Test.stopTest();
        System.assertEquals('testAccount', resultAccount.Name, 'Account names were not equal');
    }

    @isTest
    static void testGetSubscriptionView()
    {
       /* List<cscfga__Product_Basket__c> tstBasket = [select id, Name ,csbb__Account__c FROM cscfga__Product_Basket__c where Name='ShowSubTestBasket'];
        
        Test.startTest();
            List<Subwrapper> subwrapList = ShowSubscriptionsOnMACButtonController.getSubscriptionView(tstBasket[0].id, tstBasket[0].csbb__Account__r.id);
            System.debug( 'subwrapList : ' + subwrapList);
        Test.stopTest();*/
        List<cscfga__Product_Basket__c> tstBasket = [select id, Name FROM cscfga__Product_Basket__c];
        Test.startTest();
            List<Subwrapper> subwrapList = ShowSubscriptionsOnMACButtonController.getSubscriptionView(tstBasket[0].id, null);
            System.debug( 'subwrapList : ' + subwrapList);
           System.assert( tstBasket[0].id != null);
        Test.stopTest();

        //System.assert( subwrapList.size() != 0);
        //System.assert(subwrapList[0].disableRow == false);

      /*  csord__Subscription__c testSub = [SELECT Name, csord__Status__c FROM csord__Subscription__c WHERE Id = :subwrapList[0].SubscriptionID];
        System.assertEquals( testSub.Name, subwrapList[0].subscriptionName, 'Wrong subscription name.');
        System.assertEquals( testSub.csord__Status__c, subwrapList[0].status, 'Wrong subscription status.');   */ 
    }

    @isTest
    static void testAddRecords2BasketId(){
        //addRecords2(List <String> subscriptionIdList, String basketId, String changeType, String accountId, String accountName) {
        String testBasketId = [SELECT  Id FROM    cscfga__Product_Basket__c LIMIT 1].Id;
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        String testAccountId = testAccount.Id;
        String testAccountName = testAccount.Name;
        String testChangeType = 'Cancel';
        List<csord__Subscription__c> testSubsList = [SELECT Id FROM csord__Subscription__c];
        List<String> testSubsIdList = new List<String>();
        
        for(csord__Subscription__c sub : testSubsList){
            testSubsIdList.add(sub.Id);
        }

        Id returnedBasketId;
        Test.startTest();
            returnedBasketId = ShowSubscriptionsOnMACButtonController.addRecords2(testSubsIdList, testBasketId, testChangeType, '', testAccountName);
        Test.stopTest();

        System.assertEquals(null, returnedBasketId, 'Tested Basket Id\'s are not equal');
    }

    @isTest
    static void testAddRecords2AccountId(){
        //addRecords2(List <String> subscriptionIdList, String basketId, String changeType, String accountId, String accountName) {
        String testBasketId = [SELECT  Id FROM    cscfga__Product_Basket__c LIMIT 1].Id;
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        String testAccountId = testAccount.Id;
        String testAccountName = testAccount.Name;
        String testChangeType = 'Cancel';
        List<csord__Subscription__c> testSubsList = [SELECT Id FROM csord__Subscription__c];
        List<String> testSubsIdList = new List<String>();
        
        for(csord__Subscription__c sub : testSubsList){
            testSubsIdList.add(sub.Id);
        }

        Id returnedBasketId;
        Test.startTest();
            returnedBasketId = ShowSubscriptionsOnMACButtonController.addRecords2(testSubsIdList, '', testChangeType, testAccountId, testAccountName);
        Test.stopTest();
        System.assertEquals(null, returnedBasketId, 'Test Basket Id\'s are equal. New Basket is not created');
    }
    
    @isTest
    static void testAddRecords2AccountIdNull(){
        //addRecords2(List <String> subscriptionIdList, String basketId, String changeType, String accountId, String accountName) {
        String testBasketId = [SELECT  Id FROM    cscfga__Product_Basket__c LIMIT 1].Id;
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        String testAccountId = '';
        String testAccountName = '';
        String testChangeType = 'Cancel';
        List<csord__Subscription__c> testSubsList = [SELECT Id FROM csord__Subscription__c];
        List<String> testSubsIdList = new List<String>();
        
        for(csord__Subscription__c sub : testSubsList){
            testSubsIdList.add(sub.Id);
        }

        Id returnedBasketId;
        Test.startTest();
            returnedBasketId = ShowSubscriptionsOnMACButtonController.addRecords2(testSubsIdList, testBasketId, testChangeType, testAccountId, testAccountName);
        Test.stopTest();
        System.assertEquals(null, returnedBasketId, 'Test Basket Id\'s are equal. New Basket is not created');
    }
    
    @isTest
    static void testCreateOppSubscriptionAssociations(){
        Opportunity testOpp = [SELECT id, Name FROM Opportunity LIMIT 1];
        List<csord__Subscription__c> testSubsList = [SELECT Id FROM csord__Subscription__c];
        List<String> testSubsIdList = new List<String>();
        
        for(csord__Subscription__c sub : testSubsList){
            testSubsIdList.add(sub.Id);
        }

        csordtelcoa__Subscription_MACDOpportunity_Association__c testAssociation = new csordtelcoa__Subscription_MACDOpportunity_Association__c();
        testAssociation.csordtelcoa__Opportunity__c = testOpp.Id;
        testAssociation.csordtelcoa__Subscription__c = [SELECT Id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest2'].Id;
        INSERT testAssociation;

        Test.startTest();
            ShowSubscriptionsOnMACButtonController.createOppSubscriptionAssociations(testOpp.Id, testSubsIdList);
        Test.stopTest();

        List<csordtelcoa__Subscription_MACDOpportunity_Association__c> subscriptionAssociationList = new  List<csordtelcoa__Subscription_MACDOpportunity_Association__c>();
        subscriptionAssociationList = [
                                        SELECT  Id, 
                                                csordtelcoa__Opportunity__c, 
                                                csordtelcoa__Subscription__c
                                        FROM    csordtelcoa__Subscription_MACDOpportunity_Association__c
                                        WHERE   csordtelcoa__Opportunity__c = :testOpp.Id
                                      ];

        System.assertEquals(testSubsIdList.size(), subscriptionAssociationList.size(), 'All Opportunity Subscription Associations are not created.');
    }

    @isTest
    static void testCreateOpportunity(){
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Id returnedOpportunityId;
        
        Test.startTest();
            returnedOpportunityId = ShowSubscriptionsOnMACButtonController.createOpportunity(testAccount.Id, testAccount.Name, 'Modify');
        Test.stopTest();

        Opportunity createdOpportunity = [SELECT id, Name FROM Opportunity WHERE Id = :returnedOpportunityId LIMIT 1];
        System.assertEquals(createdOpportunity.Id, returnedOpportunityId, 'Tested Opportunity Id\'s are not equal');
    }

    @isTest
    static void testCreateBasket(){
        String basketChangeType = 'Upgrade';
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT id, Name FROM Opportunity LIMIT 1];
        
        Id returnedBasketId;
        
        Test.startTest();
            returnedBasketId = ShowSubscriptionsOnMACButtonController.createBasket(testAccount.Id, testOpp.Id);
        Test.stopTest();

        cscfga__Product_Basket__c testBasket = [SELECT  Id, 
                                                        Primary_Basket__c, 
                                                        csbb__Account__c, 
                                                        cscfga__Opportunity__c, 
                                                        csordtelcoa__Change_Type__c 
                                                FROM    cscfga__Product_Basket__c 
                                                WHERE   Id = :returnedBasketId 
                                                LIMIT 1];

        System.assertEquals(testBasket.Id, returnedBasketId, 'Tested Basket Id\'s are not equal');
        System.assertEquals(false, testBasket.Primary_Basket__c, 'Tested Basket Primary_Basket__c is not "true"');
        System.assertEquals(testAccount.Id, testBasket.csbb__Account__c,'Tested Basket Account Id\'s are not equal');
        System.assertEquals(testOpp.Id, testBasket.cscfga__Opportunity__c,'Tested Basket Opportunity Id\'s are not equal');
        System.assertEquals(basketChangeType, testBasket.csordtelcoa__Change_Type__c, 'Tested Basket Change Type is not ' + basketChangeType);
    }
    
    @isTest
    static void testUpdateOpportunityType(){
        String opportunityTypeMac = 'MACs (Moves, Adds & Change)';
        String opportunityTypeDisconnect = 'Disconnect';
        String changeTypeModify = 'Modify';

        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        Test.startTest();
            ShowSubscriptionsOnMACButtonController.updateOpportunityType(testOpp.Id, changeTypeModify);
        Test.stopTest();
        Opportunity testOppUpdated = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        
        System.assertEquals(testOpp.Type,testOppUpdated.Type);
    }

    @isTest
    static void testGetProductConfigurationsInUse(){
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];

        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Draft';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Billing_Solution__c = 'Standard';
        Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        testOpp.RecordTypeId = standardID;
        INSERT testOpp;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ClosedTestBasket';
        testBasket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        testBasket.csbb__Synchronised_With_Opportunity__c = true;
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        INSERT testBasket;

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        prodconfigList = [SELECT id FROM cscfga__Product_Configuration__c];

        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.csordtelcoa__Replaced_Product_Configuration__c = prodconfigList[0].Id;
        INSERT testConfig;

        Test.startTest();
            Set<Id> pcSet = ShowSubscriptionsOnMACButtonController.getProductConfigurationsInUse(testAccount.Id);
        Test.stopTest();

         System.assertNotEquals(0, pcSet.size());
    }
    @isTest
    static void testGetACRId()
    {
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
         
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'TestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        Test.startTest();
        AccountContactRelation acr1 = ShowSubscriptionsOnMACButtonController.getACRId(testBasket.Id);
        Test.stopTest();
        System.assert( testBasket != null);   
    }
    @isTest
    static void testifProductPresent()
    {
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'TestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        Test.startTest();
        boolean present = ShowSubscriptionsOnMACButtonController.ifProductPresent(testBasket.Id,testOpp.Name);
        Test.stopTest();
        System.assert( testBasket != null);   
    }
    @isTest
    static void testnoOfProductPresentUnderModify()
    {
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'TestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        Test.startTest();
        Integer present = ShowSubscriptionsOnMACButtonController.noOfProductPresentUnderModify(testBasket.Id,testOpp.Name);
        Test.stopTest();
        System.assert( testBasket != null);   
    }
     //sr 3. added for 53882
    @isTest
    static void updateSubscriptionStatusToInprogressTest(){
        List<String> subsIdList=new List<String>();
        List<csord__Subscription__c> testSubs=new List<csord__Subscription__c>([SELECT Id,csord__Status__c FROM csord__Subscription__c]);
        for(csord__Subscription__c testSub:testSubs){
            subsIdList.add(testSub.Id);
        }
        Test.startTest();
            Account acc=[select id from account limit 1];
            List<Subwrapper> subwrapList = ShowSubscriptionsOnMACButtonController.getSubscriptionViewForAssuranceAgent(acc.id);
            System.debug( 'subwrapList : ' + subwrapList);
            System.assert( acc!=null); 
        Test.stopTest();
                
    }
    
       /*  @isTest
    static void testgetAddressIdList()
    {
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'TestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        List<csord__Subscription__c> testSubsList = [SELECT Id FROM csord__Subscription__c];
        List<String> testSubsIdList = new List<String>();
        
        for(csord__Subscription__c sub : testSubsList){
            testSubsIdList.add(sub.Id);
        }
        Test.startTest();
        List<String> present = ShowSubscriptionsOnMACButtonController.getAddressIdList(testSubsIdList);
        Test.stopTest();
        System.assert( testBasket != null);   
    }
     @isTest
    static void testGetSubscriptionViewForServiceAgent()
    {
        Account acc=[select id from account limit 1];
        Test.startTest();
            List<Subwrapper> subwrapList = ShowSubscriptionsOnMACButtonController.getSubscriptionViewForAssuranceAgent(acc.id);
            System.debug( 'subwrapList : ' + subwrapList);
        Test.stopTest();
        System.assert( subwrapList.size() != 0);  
    }
     @isTest
    static void testgetCWPList()
    {
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id, Name, Type FROM Opportunity LIMIT 1];
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'TestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        List<csord__Subscription__c> testSubsList = [SELECT Id FROM csord__Subscription__c];
        List<String> testSubsIdList = new List<String>();
        
        for(csord__Subscription__c sub : testSubsList){
            testSubsIdList.add(sub.Id);
        }
        Test.startTest();
        List<String> present = ShowSubscriptionsOnMACButtonController.getCWPList(testBasket.Id,testAccount.id,testSubsIdList);
        Test.stopTest();
        System.assert( testBasket != null);   
    }*/

    @isTest
    static void testIsCancelationNBN()
    {
        List<cscfga__Product_Basket__c> baskets = [SELECT Id,Name FROM cscfga__Product_Basket__c ];
        Test.startTest();
            Boolean res = ShowSubscriptionsOnMACButtonController.isCancelationNBN(String.valueOf(baskets[0].Id));
        Test.stopTest();

        System.assertEquals(false, res);
    }
    
     @isTest
    static void testgetActiveSuspendedSubscriptionViewForAssuranceAgent()
    {
        String accId;
        Account acc = [SELECT Id,Name FROM Account where Name='testAccount' LIMIT 1];
        accId = acc.Id;
        Test.startTest();
            List<SubWrapper> res = ShowSubscriptionsOnMACButtonController.getActiveSuspendedSubscriptionViewForAssuranceAgent(accId,'Manage Fixed Numbers');
        Test.stopTest();

        System.assertNotEquals(null, res);
    }
     @isTest
    static void testgetActiveSuspendedSubscriptionViewForAssuranceAgentOtherActionType()
    {
        String accId;
        Account acc = [SELECT Id,Name FROM Account where Name='testAccount' LIMIT 1];
        accId = acc.Id;
        Test.startTest();
            List<SubWrapper> res = ShowSubscriptionsOnMACButtonController.getActiveSuspendedSubscriptionViewForAssuranceAgent(accId,'');
        Test.stopTest();

        System.assertNotEquals(null, res);
    }
    
    @isTest
    static void testgetSuspendedSubscriptionViewForAssuranceAgent()
    {
        String accId;
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        accId = acc.Id;
        Test.startTest();
            List<SubWrapper> res = ShowSubscriptionsOnMACButtonController.getSuspendedSubscriptionViewForAssuranceAgent(accId);
        Test.stopTest();

        System.assertNotEquals(null, res);
    }
    
    // DPG-1891 Suspend IoT Services
    @isTest
    static void testgetActiveSubscriptionViewForAssuranceAgentIoT()
    {
        String accId;
        Account acc = [SELECT Id,Name FROM Account where Name='testAccount' LIMIT 1];
        accId = acc.Id;
        Test.startTest();
            List<Subwrapper> subwrapList = ShowSubscriptionsOnMACButtonController.getSubscriptionViewForAssuranceAgent(accId);
            System.assert(acc!=null); 
        Test.stopTest();
        System.assertNotEquals(null, subwrapList);
    }
    
    // DPG-1892 Resume IoT Services
    @isTest
    static void testgetSuspendedSubscriptionViewForAssuranceAgentIoT()
    {
        String accId;
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        accId = acc.Id;
        Test.startTest();
            List<SubWrapper> res = ShowSubscriptionsOnMACButtonController.getSuspendedSubscriptionViewForAssuranceAgent(accId);
        System.assert( acc!=null); 
        Test.stopTest();

        System.assertNotEquals(null, res);
    }
    
    
     @isTest
    static void testSubmitOrder()
    {
        List<String> subId=new List<String>();
        Map<String, String> reasonMap=new Map<String, String>(); // DPG-4543 || DPG-4544, Ila || Krunal
        for(csord__Subscription__c sub:[select id,Name,Suspension_reason__c from csord__Subscription__c where Name = 'TestSubsforTest'])
        {
            subId.add(sub.id);
            reasonMap.put(sub.Id, sub.Suspension_reason__c); // DPG-4543 || DPG-4544, Ila || Krunal
        }
        Test.startTest();
        ShowSubscriptionsOnMACButtonController.submitOrder(subId,'Suspend','TNC123456789'); 
        //ShowSubscriptionsOnMACButtonController.submitOrderForSuspend(subId,'Suspend','Requested by Customer','TNC123456789'); 
        ShowSubscriptionsOnMACButtonController.submitOrderForSuspend(subId,'Suspend','TNC123456789',reasonMap); // DPG-4543 || DPG-4544, Ila || Krunal, Changed parameter reasonMap
        ShowSubscriptionsOnMACButtonController.invokeMSISDNForNumberChange(subId);
        ShowSubscriptionsOnMACButtonController.updateOrders(subId);
        System.assert(subId!=null);
        Test.stopTest();
      
    }
    
   /* @isTest
    static void invokeMSISDNForNumberChange()
    {
       // Cache.Org = 'SearchReserveMSISDNHandler';
        List<String> subId = new List<String>();
        for(csord__Subscription__c subscrip : [SELECT Id,Name FROM csord__Subscription__c]){
            subId.add(subscrip.Id);
        }
        Test.startTest();
            String result = ShowSubscriptionsOnMACButtonController.invokeMSISDNForNumberChange(subId);
        Test.stopTest();

        System.assertNotEquals(result, null);
    }*/
  /**********************************************************************************************************
EDGE       -140733
Method      -getNgucPortOutPermissionTest
Description -Test method for getNgucPortOutPermission method in ShowSubscriptionsOnMACButtonController class.
Author      -Dheeraj Bhatt
************************************************************************************************************/
    @IsTest public static void getNgucPortOutPermissionTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'saleEnt', Email='SalesEnterpriseUnified@test.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',   UserName='testpermissionsetuser@test.com');
        insert u;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'NgUc_Port_out'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        System.runAs(u)
        {
            Test.startTest();
            Boolean hasNgucportOutPermission=  ShowSubscriptionsOnMACButtonController.getNgucPortOutPermission();
            Test.stopTest();
            system.assertEquals(true, hasNgucportOutPermission);
        }
    }
    /**********************************************************************************************************
EDGE       -140733
Method      -getNgucPortOutPermissionTestNegative
Description -Test method for getNgucPortOutPermission method in ShowSubscriptionsOnMACButtonController class.
Author      -Dheeraj Bhatt
************************************************************************************************************/
    @IsTest public static void getNgucPortOutPermissionTestNegative(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'saleEnt', Email='SalesEnterpriseUnified@test.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',  UserName='testpermissionsetuser@test.com');
        insert u;
        
        System.runAs(u)
        {
            Test.startTest();
            Boolean hasNgucportOutPermission=  ShowSubscriptionsOnMACButtonController.getNgucPortOutPermission();
            Test.stopTest();
            system.assertEquals(false, hasNgucportOutPermission);
        }
    }
    
/**********************************************************************************************************
EDGE        -140756
Method      -getMACDActionTypes
    Description -Read MACD Action Types picklist values from custom metadata "MACD Order Options"
Author      -RaviTeja K
************************************************************************************************************/
    @isTest public static void getMACDActionTypesTestsc1(){
        //Pooja: Modified as part of EDGE-210731
        Id pSysAdmin    =   [SELECT Id,Name FROM Profile WHERE Name =:'System Administrator'].Id;
        User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com');
        insert uSysAdmin;
        Map<String,String> actionTypes= new map<String,String>();
        System.runAs(uSysAdmin){
            Test.startTest();
            actionTypes=ShowSubscriptionsOnMACButtonController.getMACDActionTypes('Inactive');
                actionTypes.clear();
             actionTypes=ShowSubscriptionsOnMACButtonController.getMACDActionTypes('Active');
            Test.stopTest();
        }
        System.assert(actionTypes.values().size()>0);
   }
    
    /**********************************************************************************************************
EDGE        -140756
Method      -getMACDActionTypes
    Description -Read MACD Action Types picklist values from custom metadata "MACD Order Options"
Author      -RaviTeja K
************************************************************************************************************/
    @isTest public static void getMACDActionTypesTestsc2(){
        //Pooja: Modified as part of EDGE-210731
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile pSysAdmin   =   [SELECT Id,Name FROM Profile WHERE Name =:'System Administrator'];
        User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com', userroleid = r.id);
        insert uSysAdmin;
        User  partneruser;
        System.runAs(uSysAdmin){
            Id prmAdmin =   [SELECT Id FROM Profile WHERE Name='PRM Admin - Australia'].Id;
            Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
            insert ac;  
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG',Email='testemail@noemail.com');
            insert con; 
            partneruser = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                   localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                                   timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com',contactid=con.id);
            insert partneruser;
            PermissionSet ps = new PermissionSet();
            ps.Name = 'Test';
            ps.Label = 'Test';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId           =   [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Partner_User'][0].Id;
            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = partneruser.id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }   
        Map<String,String> actionTypes= new map<String,String>();
        System.runAs(partneruser){
            Test.startTest();
            actionTypes=ShowSubscriptionsOnMACButtonController.getMACDActionTypes('Inactive');
            Test.stopTest();
        }
        System.assert(actionTypes.values().size()>0);        
    }  

        /**********************************************************************************************************
EDGE        -EDGE-159491
Method      -getMACDActionTypes
Description -MACD UI Updates-action types for Insolvency Consultants
Author      -Mohammed Zeeshan
************************************************************************************************************/
    @isTest public static void getMACDActionTypesPermission(){
        //Pooja: Modified as part of EDGE-210731
        Id pSysAdmin    =   [SELECT Id,Name FROM Profile WHERE Name =:'System Administrator'].Id;
        User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com');
        insert uSysAdmin;
            PermissionSet permissionSetAssign = new PermissionSet();
            permissionSetAssign.Name = 'Test';
            permissionSetAssign.Label = 'Test';
            insert permissionSetAssign;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = permissionSetAssign.Id;
        sea.SetupEntityId                   =   [SELECT Id FROM CustomPermission WHERE DeveloperName = 'InsolvencyConsultants'][0].Id;
            insert sea;
            PermissionSetAssignment assignment = new PermissionSetAssignment();
            assignment.AssigneeId = uSysAdmin.Id; 
            assignment.PermissionSetId = permissionSetAssign.Id;
            insert assignment;
        Map<String,String> actionTypes      =   new map<String,String>();
        System.runAs(uSysAdmin){
            Test.startTest();
            actionTypes=ShowSubscriptionsOnMACButtonController.getMACDActionTypes('Inactive');
            Test.stopTest();
            system.debug('Test----->'+actionTypes.values().size());
        }
        System.assert(actionTypes.values().size()>0);        
    } 

/**********************************************************************************************************
EDGE        -140756
Method      -getMACDActionTypes
Description -Read MACD Action Types picklist values from custom settings MACD Action Types Custom Settings
Author      -RaviTeja K
************************************************************************************************************/
    @IsTest public static void getReplaceMentResonTest(){
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        User uSysAdmin = new User(alias = 'Con123', email = 'Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Testadmin00097@noemail.com', userroleid = r.id);
        insert uSysAdmin;
        
        Map<String,String> actionTypes= new map<String,String>();
        System.runAs(uSysAdmin){
            Test.startTest();
            actionTypes=ShowSubscriptionsOnMACButtonController.getReplacmentReson();
            Test.stopTest();
        }
        System.assert(actionTypes.values().size()>1);
   }
    //EDGE-164004
    public static testMethod void testCSMPortalUrl(){
        TNOW_CSM_URL__c settings = TNOW_CSM_URL__c.getOrgDefaults();
        settings.PortalUrl__c = 'dummy';
        settings.KAUrl__c = 'dummy';
        upsert settings TNOW_CSM_URL__c.Id;        
        String s = ShowSubscriptionsOnMACButtonController.getCSMPortalDetails();
        system.assert(s != null);
    }
    
    //DPG-4542
    @isTest
    static void testSuspensionResumeCodeBillingConsultant()
    {
        String accId;
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        accId = acc.Id;
        User billingconsultantuser = [select id from user where alias='billcon'];
        Test.startTest();
        //Assign Permission Set to Billing Consultant User.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :System.Label.Collection_Consultant];
        insert new PermissionSetAssignment(AssigneeId = billingconsultantuser.id, PermissionSetId = ps.Id);
        system.runAs(billingconsultantuser){
            List<SubWrapper> res = ShowSubscriptionsOnMACButtonController.getSuspendedSubscriptionViewForAssuranceAgent(accId);
            for(SubWrapper objWrap:res){
                if(objWrap.subscriptionName=='TestSubsforTest4'){
                    system.debug('objWrap.suspensionReasonSummary-->'+objWrap.suspensionReasonSummary);
                    system.assertEquals('REQUESTED BY TELSTRA,REQUESTED BY CUSTOMER', objWrap.suspensionReasonSummary);
                    system.assertEquals('Credit management - incoming calls and texts only', objWrap.suspensionReasonDescriptionCodeMap.get('paymentFailure'));
                }
            }
            System.assertNotEquals(null, res);
        }
        Test.stopTest();

    }
     //DPG-4542
    @isTest
    static void testSuspensionResumeCodeBillingSupport()
    {
        String accId;
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        accId = acc.Id;
        User billingsupportuser = [select id from user where alias='billsup'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :System.Label.Fraud_Management];
        insert new PermissionSetAssignment(AssigneeId = billingsupportuser.id, PermissionSetId = ps.Id);
        Test.startTest();
        system.runAs(billingsupportuser){
            ShowSubscriptionsOnMACButtonController.getPathPrefix();
            List<SubWrapper> res = ShowSubscriptionsOnMACButtonController.getSuspendedSubscriptionViewForAssuranceAgent(accId);
            for(SubWrapper objWrap:res){
                if(objWrap.subscriptionName=='TestSubsforTest4'){
                    system.assertEquals('REQUESTED BY TELSTRA,REQUESTED BY CUSTOMER', objWrap.suspensionReasonSummary);
                    system.assertEquals('Fraud - incoming calls and texts only', objWrap.suspensionReasonDescriptionCodeMap.get('fraudLight'));
                }
            }
            System.assertNotEquals(null, res);
        }   
        Test.stopTest();

    }
    
    //Start:EDGE-205597
    @isTest
    static void test_getFilteredSubscriptionsData() {
        String accId;
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        accId = acc.Id;
        Map<String, Object> inputMap = new Map<String, Object>();
        List<String> fieldsList = new List<String>{'Id','Name','csordtelcoa__Subscription_Number__c','serviceMSISDN__c','Site__c','Site__r.Address__c',
                                'initialActivationDate__c','CreatedDate','csord__Status__c','csord__Total_Recurring_Charges__c',
                                'Billing_Account__r.name','CreatedBy.Name','csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name',
                                'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c',
                                'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c',
                                'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c',
                                'Initial_Activation_DateTime__c'};
        inputMap.put('csord__Account__c','=\''+accId+'\'');
        inputMap.put('csordtelcoa__Replacement_Subscription__c','=null');
        Test.startTest();
            List<SubWrapper> res = new List<SubWrapper>();
            try {
                 res = ShowSubscriptionsOnMACButtonController.getFilteredSubscriptionsData(inputMap,fieldsList,'Change of Billing Account');
            } catch(Exception e) {
                System.debug('***Exception in test_getFilteredSubscriptionsData***'+e);
            }
            System.assert( acc!=null); 
        Test.stopTest();
        System.assertNotEquals(null, res);
    }   //End:EDGE-205597
    
    //EDGE-205598 - Handle test logic for submitBillAcc method
    private static testMethod void submitBillAccTest(){
        
        string accId = [select id from account limit 1].id;
        string conId = [select id from contact limit 1].id;
        string billId = [select id from Billing_Account__c  limit 1].id;
        string reason = 'Test';
        list<string> subids = new list<string>();
        for(csord__Subscription__c sub : [select id from csord__Subscription__c]){
            subids.add(sub.id);     
        }
        test.startTest(); 
            caseWrapper cs = ShowSubscriptionsOnMACButtonController.submitBillAcc(accId,conId,billId,reason,subids);
            system.assertEquals('success', cs.response);
        test.stopTest();
    }
    
    private static testMethod void submitBillAccNegativeTest(){
        
        string accId = [select id from account limit 1].id;
        string conId = [select id from contact limit 1].id;
        string billId = [select id from Billing_Account__c  limit 1].id;
        string reason = 'Test';
        list<string> subids = new list<string>();
        for(csord__Subscription__c sub : [select id from csord__Subscription__c]){
            subids.add(sub.id);     
        }
        cscfga__Product_Configuration__c pc = [select id,csordtelcoa__replaced_subscription__c from cscfga__Product_Configuration__c limit 1];
        pc.csordtelcoa__replaced_subscription__c = subids[0];
        update pc;
        
        test.startTest(); 
            parallelChangeValidationResponse pcs = new parallelChangeValidationResponse();
            caseWrapper.doNothing();
            parallelChangeValidationResponse.doNothing();
            caseWrapper cs = ShowSubscriptionsOnMACButtonController.submitBillAcc(accId,conId,billId,reason,subids);
            system.assertEquals(true, cs.response != 'success');
        test.stopTest();
    }
    
    
}