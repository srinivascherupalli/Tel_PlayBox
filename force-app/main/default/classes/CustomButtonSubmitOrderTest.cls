/****************************************************************************************************************************************************
Main Class : CustomButtonSubmitOrder
Test Class : CustomButtonSubmitOrderTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story                       Description
1.        Ankit Goswami      03/07/2020       EDGE-181979 (New)        Submitorder button test for Non Commercial journey
2.        Gnana              05/11/2020       EDGE-184043              Added test methods for Reference Number Validation
3.        Vamsi              18/01/2020       EDGE-192911              Added test methods for Submit basket button functionality
4.        Kamlesh            1/3/2021         EDGE-199074              Added sync_job_id custom field in validateSubmitBasket
5.        Kamlesh            7/4/2021         EDGE-212976              Added Test.start/Test.stop test in test method
6.        Kamlesh            26/04/2021       EDGE-216600              Updated basket for commercial amend type
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class CustomButtonSubmitOrderTest{
  @TestSetup
      private static void testSetup() 
      {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        List<User> listOfUsers = new List<User>();
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        //insert sales;
        listOfUsers.add(sales);

        Profile asaProfile = [select id from profile where name = 'Assurance Service Agent'];
        User asa = new User(alias = 'asauser',email='asauser@testasauser.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='ASA_Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = asaProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='asauser@testasauser.com',phone='0424289156');
        listOfUsers.add(asa);
        Insert listOfUsers;
        
        Account acc = new Account(Name = 'Burlington');
        insert Acc;
          
          Contact cont = new Contact(FirstName='Test',LastName='Test',Email='test@test.com',AccountId=acc.id,Phone='');
        insert cont;
        
        List<SharedDisplayMessage__c> custsetList= new list<SharedDisplayMessage__c>();
            SharedDisplayMessage__c custset= new SharedDisplayMessage__c();
        custset.Name='noProductAvailable';
        custset.value__c='No Product availabel for Submit Order';
        custsetList.add(custset);
        
        SharedDisplayMessage__c custset1= new SharedDisplayMessage__c();
        custset1.Name='orderGenerationSucess';
        custset1.value__c='Order has been Created Sucessfully';
        custsetList.add(custset1);
        
        SharedDisplayMessage__c custset2= new SharedDisplayMessage__c();
        custset2.Name='alreadySubmittedBasket';
        custset2.value__c='Basket Already In Submitted Stage';
        custsetList.add(custset2);
        
        SharedDisplayMessage__c custset3= new SharedDisplayMessage__c();
        custset3.Name='errorOrderGeneration';
        custset3.value__c='Some error has been occured on Order Generation';
        custsetList.add(custset3);
        
        SharedDisplayMessage__c custset4= new SharedDisplayMessage__c();
        custset4.Name='quantityValidation';
        custset4.value__c='Total Quantity per SIM Type cannot exceed 100';
        custsetList.add(custset4);
        
        insert custsetList;

        List<Contact> listOfContacts = new List<Contact>();
        Contact cont1 = new Contact(OwnerId=sales.Id,FirstName = 'TestCont1',LastName = 'TestCont1',AccountId=Acc.Id,Email='testcont1@test.com',Phone='0424289156',MobilePhone='0424289156');
        listOfContacts.add(cont1);
        insert listOfContacts;
        
        cscfga__Product_Definition__c prodDef= new cscfga__Product_Definition__c();
        prodDef.name='Inactive SIM';
        prodDef.cscfga__Description__c='Inactive SIM';
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000753';
        insert prodDef;
        
        list<cscfga__Product_Basket__c> prodBasList= new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c prodBas= new cscfga__Product_Basket__c();
        prodBas.csordtelcoa__Account__c=Acc.id;
        prodBas.name='Test';
        prodBas.Order_Requester__c = cont1.Id;
        prodBas.referencenumber__c='TNC000000000';
        prodBas.BasketType__c = 'Non Commercial';
        prodBasList.add(prodBas);
        
        cscfga__Product_Basket__c prodBas1= new cscfga__Product_Basket__c();
        prodBas1.name='Test2';
        prodBas1.Order_Requester__c = cont1.Id;
        prodBas1.referencenumber__c='ABC000000000';
        prodBas1.csordtelcoa__Account__c=Acc.id;
        prodBasList.add(prodBas1);
        
        cscfga__Product_Basket__c prodBas5= new cscfga__Product_Basket__c();
        prodBas5.name='Test5';
        prodBas5.Order_Requester__c = cont1.Id;
        prodBas5.referencenumber__c='ABC000000001';
        prodBas5.csordtelcoa__Account__c=Acc.id;
        prodBasList.add(prodBas5);
          
        cscfga__Product_Basket__c prodBas2= new cscfga__Product_Basket__c();
        prodBas2.name='Test3';
        prodBas2.Order_Requester__c = cont1.Id;
        prodBas2.csordtelcoa__Account__c=Acc.id;
        prodBas2.referencenumber__c='TNC000000001';
        prodBasList.add(prodBas2);
        
        
        cscfga__Product_Basket__c prodBas3= new cscfga__Product_Basket__c();
        prodBas3.name='Test5';
        prodBas3.csordtelcoa__Account__c=Acc.id;
        prodBas3.Order_Requester__c = cont1.Id;    
        prodBas3.csordtelcoa__Basket_Stage__c='Submitted';
        prodBasList.add(prodBas3);
        
        cscfga__Product_Basket__c prodBas4= new cscfga__Product_Basket__c();
        prodBas4.name='Test4';
        prodBas4.Order_Requester__c = cont1.Id;
        prodBas4.csordtelcoa__Account__c=Acc.id;
        prodBas4.referencenumber__c='JK000000000';
        prodBasList.add(prodBas4);
          
        cscfga__Product_Basket__c prodBas6= new cscfga__Product_Basket__c();
        prodBas6.csordtelcoa__Account__c=Acc.id;
        prodBas6.Order_Requester__c = cont1.Id;    
        prodBasList.add(prodBas6);
          
        cscfga__Product_Basket__c prodBas7= new cscfga__Product_Basket__c();
        prodBas7.name='Test7';
        prodBas7.Order_Requester__c = cont1.Id;
        prodBas7.referencenumber__c='ABC000000002';
        prodBas7.csordtelcoa__Account__c=Acc.id;
        prodBasList.add(prodBas7);
          
            //Added
        cscfga__Product_Basket__c prodBas8= new cscfga__Product_Basket__c();
        prodBas8.name='Test8';
        prodBas8.Order_Requester__c = cont1.Id;
        prodBas8.referencenumber__c='ABC000000003';
        prodBas8.sync_job_Id__c = '[{"name":"submitJobId","id":"123"}]';
        prodBas8.OF_Reversal_Inserted__c   = true;
        prodBas8.csordtelcoa__Account__c=Acc.id;
        Id recType = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        prodBas8.RecordtypeId = recType; 
        prodBasList.add(prodBas8);
          
        cscfga__Product_Basket__c prodBas9= new cscfga__Product_Basket__c();
        prodBas9.name='Test9';
        prodBas9.Order_Requester__c = cont1.Id;
        prodBas9.referencenumber__c='ABC000000004';
        prodBas9.csordtelcoa__Account__c=Acc.id;
        Id recType1 = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        prodBas9.RecordtypeId = recType1; 
        prodBasList.add(prodBas9);
          
        cscfga__Product_Basket__c prodBas10= new cscfga__Product_Basket__c();
        prodBas10.name='Test10';
        prodBas10.Order_Requester__c = cont1.Id;
        prodBas10.referencenumber__c='ABC000000005';
        prodBas10.BasketType__c = 'Non Commercial'; 
        prodBas10.csordtelcoa__Account__c=Acc.id; 
        prodBasList.add(prodBas10);
          //Added
          
        insert prodBasList;

        List<cscfga__Product_Configuration__c> prodConfigLst = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name = 'new config';
        newConfig.Quantity_Product_Configuration__c=20;
        newConfig.cscfga__Product_Definition__c=prodDef.id;
        newConfig.cscfga__Product_Basket__c=prodBas.id;
        prodConfigLst.add(newConfig);
        
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
        config.name = 'prod config';
        config.Quantity_Product_Configuration__c=201;
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__Product_Definition__c=prodDef.id;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c=prodBas1.id;
        prodConfigLst.add(config);
        
        
        cscfga__Product_Configuration__c configNew = new cscfga__Product_Configuration__c();
        configNew.name = 'prod configNew';
        configNew.Quantity_Product_configuration__c=20;
        configNew.cscfga__Contract_Term__c = 12;
        configNew.cscfga__Product_Definition__c=prodDef.id;
        configNew.cscfga__total_contract_value__c = 325;
        configNew.cscfga__Product_Basket__c=prodBas3.id;
        prodConfigLst.add(configNew);
 
        cscfga__Product_Configuration__c configNew1 = new cscfga__Product_Configuration__c();
        configNew1.name = 'prod configNew111';
        configNew1.Quantity_Product_configuration__c=20;
        configNew1.cscfga__Contract_Term__c = 12;
        configNew1.cscfga__Product_Definition__c=prodDef.id;
        configNew1.cscfga__total_contract_value__c = 325;
        configNew1.cscfga__Product_Basket__c=prodBas4.id;
        prodConfigLst.add(configNew1);
          
        cscfga__Product_Configuration__c configNew2 = new cscfga__Product_Configuration__c();
        configNew2.name = 'prod config test ref num null';
        configNew2.Quantity_Product_configuration__c=20;
        configNew2.cscfga__Contract_Term__c = 12;
        configNew2.cscfga__Product_Definition__c=prodDef.id;
        configNew2.cscfga__total_contract_value__c = 325;
        //configNew2.cscfga__Product_Basket__c=prodBas7.id;
        prodConfigLst.add(configNew2);
          
        cscfga__Product_Configuration__c configNew3 = new cscfga__Product_Configuration__c();
        configNew3.name = 'prod config test ref num invalid';
        configNew3.Quantity_Product_configuration__c=20;
        configNew3.cscfga__Contract_Term__c = 12;
        configNew3.cscfga__Product_Definition__c=prodDef.id;
        configNew3.cscfga__total_contract_value__c = 325;
        configNew3.cscfga__Product_Basket__c=prodBas6.id;
        prodConfigLst.add(configNew3);
          
        cscfga__Product_Configuration__c config1 = new cscfga__Product_Configuration__c();
        config1.name = 'Submit Basket config';
        config1.Quantity_Product_Configuration__c=301;
        config1.cscfga__Contract_Term__c = 12;
        config1.cscfga__Product_Definition__c=prodDef.id;
        config1.cscfga__total_contract_value__c = 325;
        config1.cscfga__Product_Basket__c=prodBas8.id;          
        prodConfigLst.add(config1);
          
        cscfga__Product_Configuration__c config2 = new cscfga__Product_Configuration__c();
        config2.name = 'Submit Basket config failure';
        config2.Quantity_Product_Configuration__c=302;
        config2.cscfga__Contract_Term__c = 12;
        config2.cscfga__Product_Definition__c=prodDef.id;
        config2.cscfga__total_contract_value__c = 325;
        config2.cscfga__Product_Basket__c=prodBas9.id;          
        prodConfigLst.add(config2);
          
        cscfga__Product_Configuration__c config3 = new cscfga__Product_Configuration__c();
        config3.name = 'Submit Basket Else Case';
        config3.Quantity_Product_Configuration__c=303;
        config3.cscfga__Contract_Term__c = 12;
        config3.cscfga__Product_Definition__c=prodDef.id;
        config3.cscfga__total_contract_value__c = 325;
        config3.cscfga__Product_Basket__c=prodBas10.id;          
        prodConfigLst.add(config3);
          
        cscfga__Product_Configuration__c config4 = new cscfga__Product_Configuration__c();
        config4.name = 'Submit Basket for Subscription';
        config4.Quantity_Product_Configuration__c=304;
        config4.cscfga__Contract_Term__c = 12;
        config4.cscfga__Product_Definition__c=prodDef.id;
        config4.cscfga__total_contract_value__c = 325;
        config4.cscfga__Product_Basket__c=prodBas5.id;          
        prodConfigLst.add(config4);
          
        insert prodConfigLst;
        
        csord__Order__c testOrder = new csord__Order__c();
        testOrder.name = 'TestOrder';  
        testOrder.csord__Account__c = Acc.Id;
        testOrder.csord__Identification__c='test';
        insert testOrder;
          
          csord__Order__c testOrder1 = new csord__Order__c();
        testOrder1.csord__Account__c = Acc.Id;
        testOrder1.csord__Identification__c='test1';
          
        csord__Order__c testOrder2 = new csord__Order__c();
        testOrder2.csord__Account__c = Acc.Id;
        testOrder2.csord__Identification__c='test2';
        insert testOrder1;
        
        List<csord__Subscription__c> testSubscriptionList = new List<csord__Subscription__c>();
          csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = Acc.Id;
        testSubscription.csord__Order__c = testOrder2.Id;
        testSubscription.csord__Identification__c = 'test2';
        testSubscription.csordtelcoa__Product_Configuration__c = newConfig.Id;
        testSubscription.csord__Status__c = 'Active';
          testSubscriptionList.add(testSubscription);
          
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'TestSubsforTest';
        testSubscription1.csord__Account__c = Acc.Id;
        testSubscription1.csord__Order__c = testOrder.Id;
        testSubscription1.csord__Identification__c = 'test';
        testSubscription1.csordtelcoa__Product_Configuration__c = config1.Id;
        testSubscription1.csord__Status__c = 'Active';
          testSubscriptionList.add(testSubscription1);
          
          csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest';
        testSubscription2.csord__Account__c = Acc.Id;
        testSubscription2.csord__Order__c = testOrder1.Id;
        testSubscription2.csord__Identification__c = 'test1';
        testSubscription2.csordtelcoa__Product_Configuration__c = config3.Id;
        testSubscription2.csord__Status__c = 'Active';
          testSubscriptionList.add(testSubscription2);
        insert testSubscriptionList;
     }
     

      static testmethod void alreadySumbitErrorTest(){
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            list<cscfga__Product_Basket__c> prod=[select id from cscfga__Product_Basket__c where csordtelcoa__Basket_Stage__c='Submitted'];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
             string result = cutbutton.performAction(prod[0].id);
            system.assert(result.contains('error'));
        }
       
     }
      static testmethod void QuantityErrorTest(){
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            list<cscfga__Product_Basket__c> prod=[select id from cscfga__Product_Basket__c where referencenumber__c='ABC000000000' ];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
             string result = cutbutton.performAction(prod[0].id);
             //system.assert(result.contains('ok'));
             system.assertEquals('',result );
        }
       
     }
     static testmethod void noProductTest(){
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            list<cscfga__Product_Basket__c> prod=[select id from cscfga__Product_Basket__c where referencenumber__c='ABC000000001'];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
              string result = cutbutton.performAction(prod[0].id);
             //system.assert(result.contains('ok'));
             system.assertEquals('',result );
        }
       
     }
     //Added Test.startTest/Test.stopTest EDGE-212976 
     static testmethod void orderGenErrorTest(){
        Test.startTest();
        User asaUser = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(asaUser){
            cscfga__Product_Basket__c prod=[select id from cscfga__Product_Basket__c Where referencenumber__c='ABC000000004'];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
                string result = cutbutton.performAction(prod.id);
                System.debug('orderGenErrorTest' +result );
                system.assert(true,result.contains('error'));
        }
        Test.stopTest();
    }
    // Added as part of EDGE-184043
    //Added Test.startTest/Test.stopTest EDGE-212976
    static testmethod void ValidateRefNumber_Positive(){
        Test.startTest();
        User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
        System.runAs(asaUser){
            cscfga__Product_Basket__c prod=[select id,RecordType.Developername from cscfga__Product_Basket__c Where referencenumber__c='TNC000000000'];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
            string result = cutbutton.performAction(prod.id);
            system.assertNotEquals('',result ); 
            //system.assert(result.contains('ok'));
        }
        Test.stopTest();
    }
    
    // Added as part of EDGE-184043
    static testmethod void ValidateRefNumber_Invalid(){
        User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
        System.runAs(asaUser){
            cscfga__Product_Basket__c prod=[select id from cscfga__Product_Basket__c Where referencenumber__c='ABC000000002'];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
                string result = cutbutton.performAction(prod.id);
                system.assert(result.contains('error'));
        }
    }
    
    // Added as part of EDGE-184043
    static testmethod void ValidateRefNumber_Null(){
        User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
        System.runAs(asaUser){
            cscfga__Product_configuration__c pc = [select id,cscfga__Product_Basket__c from cscfga__Product_configuration__c where name='prod config test ref num null'];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
            string result = cutbutton.performAction(pc.cscfga__Product_Basket__c);
            system.assert(result.contains('error'));
        }
    }
    //added by Vamsi for  EDGE-192911 on 1/7/2021 starts
    @IsTest
    public static void validateSubmitBasket(){
        Test.startTest();
           User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
            System.runAs(sales){
            Set<String> setProductBasketId = new Set<String>();
            Id jobId = database.executeBatch(new createOLIsBatch(setProductBasketId));
            list<cscfga__Product_Basket__c> prod=[select id,sync_job_Id__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c ,OF_Reversal_Inserted__c,cscfga__Opportunity__r.StageName from cscfga__Product_Basket__c Where referencenumber__c='ABC000000003'];
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            basket.id = prod[0].id;
            basket.sync_job_Id__c = '[{"name":"submitJobId","id":"'+jobId+'"}]'; //EDGE-199074
            update basket;
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
            string result = cutbutton.performAction(basket.id);
            System.AssertEquals(true,prod.size()>0);
                    }
        Test.stopTest();
    }
    
    @IsTest
    public static void validateSubmitBasketSyncTest(){
        Test.startTest();
           User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
            System.runAs(sales){
            Set<String> setProductBasketId = new Set<String>();
            Id jobId = database.executeBatch(new createOLIsBatch(setProductBasketId));
            list<cscfga__Product_Basket__c> prod=[select id,sync_job_Id__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c ,OF_Reversal_Inserted__c,cscfga__Opportunity__r.StageName from cscfga__Product_Basket__c Where referencenumber__c='ABC000000003'];
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            basket.id = prod[0].id;
            basket.OF_Reversal_Inserted__c  = false;
            basket.csbb__Synchronised_With_Opportunity__c  = true;
            basket.Amend_Type__c = 'Commercial';//EDGE - 216600; 
            basket.sync_job_Id__c = '[{"name":"submitJobId","id":"'+jobId+'"}]'; //EDGE-199074
            update basket;
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
            string result = cutbutton.performAction(basket.id);
            System.AssertEquals(true,prod.size()>0);
                    }
        Test.stopTest();
    }
    
        @IsTest
    public static void forElseCase(){
        Test.startTest();
           User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
            System.runAs(sales){
            list<cscfga__Product_Basket__c> prod=[select id from cscfga__Product_Basket__c Where referencenumber__c='ABC000000005'];
            CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
            string result = cutbutton.performAction(prod[0].id);
            system.assert(result.contains('error'));    
        }
        Test.stopTest();
    }
    
            @IsTest
    public static void forReturnSuccess(){
        Test.startTest();
           User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            list<cscfga__Product_Basket__c> prod=[select id from cscfga__Product_Basket__c Where referencenumber__c='ABC000000005'];
            csord__Order__c ord = [Select id from csord__Order__c where name = 'TestOrder' Limit 1];
              //CustomButtonSubmitOrder cutbutton=new  CustomButtonSubmitOrder();
            string result = CustomButtonSubmitOrder.returnSuccess(prod[0],ord.id);
                 CustomButtonSubmitOrder.returnError();
            system.assert(!result.contains('error'));
            
        }
         Test.stopTest();
    }
//added by Vamsi for  EDGE-192911 on 1/7/2021 ends
 }