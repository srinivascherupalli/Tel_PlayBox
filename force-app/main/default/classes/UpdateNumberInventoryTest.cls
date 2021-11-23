@isTest
public with sharing class UpdateNumberInventoryTest {
    @testsetup
    public static void makeData(){
        
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount; 
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'New To Market';
        testOpp.Product_Domain__c = 'FIXED TELEPHONY';
        testOpp.Pricing_Method__c = 'PET';
        testOpp.Billing_Solution__c = 'Non Standard';
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'T-MDM', product_Specification__c='DMCAT_ProductSpecification_000537',cscfga__Description__c = 'Tenancy');
        pdList.add(CW_PD);
        insert pdList;
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'T-MDM';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        insert prodconfigList;
        
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
        
        List<csord__Subscription__c> subslist=new List<csord__Subscription__c>();
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        testSubscription.NetworkServiceId__c = '3c47ad62-0a2f-4080-942d-ff4e037f329a';
        testSubscription.csordtelcoa__Subscription_Number__c = 'SN-000223173';
        subslist.add(testSubscription);
        
        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = testAccount.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        testSubscription4.csord__Status__c = 'Suspended';
        testSubscription4.NetworkServiceId__c = '3c47ad62-0a2f-4080-942d-ff4e037f329b';
        testSubscription4.csordtelcoa__Subscription_Number__c = 'SN-000223173';
        
        subslist.add(testSubscription4);
        insert subslist;
        
        Number_Group__c numberGroup = new Number_Group__c();
        numberGroup.Subscription_Number__c = testSubscription.csordtelcoa__Subscription_Number__c;
        numberGroup.Status__c = 'Reserved';
        numberGroup.Scenario_Type__c = 'Add';
        insert numberGroup;
        
        List<Number__c> numList=new List<Number__c>();
        Number__c fnnNumber1 = Testutil.createNumber('61359816904',testBasket.id,null);
        fnnNumber1.Product_Configuration__c =prodconfigList[0].id;
        fnnNumber1.Type__c='FNN';
        fnnNumber1.Status__c = 'Locked';
        fnnNumber1.Mobile__c='Fixed';
        fnnNumber1.Subscription_number__c = '012_34_567';
        fnnNumber1.Number_Group__c = numberGroup.Id;
        fnnNumber1.Locked_By__c = 'UCDM';
        numList.add(fnnNumber1);
        
        Number__c fnnNumber2 = Testutil.createNumber('61359816905',testBasket.id,null);
        fnnNumber2.Product_Configuration__c =prodconfigList[0].id;
        fnnNumber2.Type__c='FNN';
        fnnNumber2.Status__c = 'Reserved';
        fnnNumber2.Mobile__c='Fixed';
        fnnNumber2.Subscription_number__c =  '012_34_567';
        fnnNumber2.Number_Group__c = numberGroup.Id;
        fnnNumber2.Locked_By__c = 'UCDM';
        
        
        Number__c fnnNumbe3 = Testutil.createNumber('61359816906',testBasket.id,null);
        fnnNumbe3.Product_Configuration__c =prodconfigList[0].id;
        fnnNumbe3.Type__c='FNN';
        fnnNumbe3.Status__c = 'Locked';
        fnnNumbe3.Mobile__c='Fixed';
        fnnNumbe3.Subscription_number__c =  '012_34_567';
        fnnNumbe3.Number_Group__c = numberGroup.Id;
        fnnNumbe3.Locked_By__c = 'UCDM';
        
        numList.add(fnnNumbe3);
        
        Number__c fnnNumber3 = Testutil.createNumber('61359816907',testBasket.id,null);
        fnnNumber3.Product_Configuration__c =prodconfigList[0].id;
        fnnNumber3.Type__c='FNN';
        fnnNumber3.Status__c = 'IN TRANSITION';
        fnnNumber3.Mobile__c='Fixed';
        fnnNumber3.Subscription_number__c =  '012_34_567';
        fnnNumber3.Number_Group__c = numberGroup.Id;
        numList.add(fnnNumber3);
        Number__c fnnNumber4 = Testutil.createNumber('61359816707',testBasket.id,null);
        fnnNumber4.Product_Configuration__c =prodconfigList[0].id;
        fnnNumber4.Type__c='FNN';
        fnnNumber4.Status__c = 'Reserved';
        fnnNumber4.Mobile__c='Fixed';
        fnnNumber4.Subscription_number__c =  '012_34_567';
        fnnNumber4.Number_Group__c = numberGroup.Id;
        fnnNumber4.Locked_By__c = 'UCDM1';
        numList.add(fnnNumber4);
        Number__c fnnNumber5 = Testutil.createNumber('61359816907',testBasket.id,null);
        fnnNumber5.Product_Configuration__c =prodconfigList[0].id;
        fnnNumber5.Type__c='FNN';
        fnnNumber5.Status__c = 'Active';
        fnnNumber5.Mobile__c='Fixed';
        fnnNumber5.Subscription_number__c =  '012_34_567';
        fnnNumber5.Number_Group__c = numberGroup.Id;
        numList.add(fnnNumber5);
        insert numList;
    }
    
    @isTest
    public static void RequestUCDM_CancelNumber(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"3c47ad62-0a2f-4080-942d-ff4e037f329a","actionType":"Cancel","numbers":[{"singleNumbers":["61359816905"],"ranges":[{"startNumber":"61359816906","endNumber":"61359816907"}]}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.addHeader('Source-System', 'ABCD');
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res; 
        NumberInventoryRequest numInventory = (NumberInventoryRequest)JSON.deserialize(jsonstring, NumberInventoryRequest.class);
        UpdateNumberInventory.handleUCDMNumberRequest();
        Test.stopTest();
        System.assertEquals(res.statusCode , 400 , 'Should be failure, Ineligible Status for Cancel');
        
    }
    
    @isTest
    public static void RequestUCDM_CancelNumber_SameSource(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"3c47ad62-0a2f-4080-942d-ff4e037f329a","actionType":"Cancel","numbers":[{"singleNumbers":["61359816905"],"ranges":[{"startNumber":"61359816906","endNumber":"61359816907"}]}]}';
        String JsonMsg=JSON.serialize( jsonstring );
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.addHeader('Source-System', 'UCDM');
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        UpdateNumberInventory.handleUCDMNumberRequest();
        Test.stopTest();
        System.assertEquals(res.statusCode , 400 , 'Should be fail due to same sourcesystem and ineligible status');
        
    }
    
    @isTest
    public static void updateNumberTest(){
        Map<String,List<Number__c>> numbersToProcess = new Map<String,List<Number__c>>();
        List<Number__c> numList = [ SELECT ID,Status__c,Number_Group__c,Service_Number__c,Product_Configuration__c,Number_Range__c, Start_Range__c, End_range__c, Locked_By__c, ReasonForLockUnlock__c FROM Number__c WHERE Locked_By__c = 'UCDM' ];
        // for( Number__c num : numList ) {
        numbersToProcess.put('locked' , numList );
        // }
        NumberInventoryResponse response = UpdateNumberInventoryHelper.updateNumbers( numbersToProcess , 'UCDM');
        System.assertEquals(response.code , '200' , 'Should be success due to same sourcesystem');
        
    }
    
    @isTest
    public static void updateNumberTest_Reserved(){
        Map<String,List<Number__c>> numbersToProcess = new Map<String,List<Number__c>>();
        List<Number__c> numList = [ SELECT ID,Status__c,Number_Group__c,Service_Number__c,Product_Configuration__c,Number_Range__c, Start_Range__c, End_range__c, Locked_By__c, ReasonForLockUnlock__c FROM Number__c WHERE Locked_By__c = 'UCDM' ];
        // for( Number__c num : numList ) {
        numbersToProcess.put('reserved' , numList );
        // }
        NumberInventoryResponse response = UpdateNumberInventoryHelper.updateNumbers( numbersToProcess , 'UCDM');
        System.assertEquals(response.code , '200' , 'Should be success due to same sourcesystem');
        
    }
    
    @isTest
    public static void updateNumberTest_IN_TRANSITION(){
        Map<String,List<Number__c>> numbersToProcess = new Map<String,List<Number__c>>();
        List<Number__c> numList = [ SELECT ID,Status__c,Number_Group__c,Service_Number__c,Product_Configuration__c,Number_Range__c, Start_Range__c, End_range__c, Locked_By__c, ReasonForLockUnlock__c FROM Number__c WHERE Locked_By__c = 'UCDM' ];
        // for( Number__c num : numList ) {
        numbersToProcess.put('in transition' , numList );
        // }
        NumberInventoryResponse response = UpdateNumberInventoryHelper.updateNumbers( numbersToProcess , 'UCDM');
        System.assertEquals(response.code , '200' , 'Should be success due to same sourcesystem');
        
    }
    
    @isTest
    public static void RequestUCDM_CancelNumber_NoNetworkServiceId(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"","actionType":"Cancel","numbers":[{"singleNumbers":["61359816905"],"ranges":[{"startNumber":"61359816906","endNumber":"61359816907"}]}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        UpdateNumberInventory.handleUCDMNumberRequest();
        Test.stopTest();
        System.assertEquals(res.statusCode , 400 , 'Should be Success as it is Cancel with No n/w Id.');
        
    }
    
    @isTest
    public static void RequestUCDM_CancelNumber_InvalidNumbers(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"3c47ad62-0a2f-4080-942d-ff4e037f329a","actionType":"Cancel","numbers":[{"singleNumbers":["12345"],"ranges":[{"startNumber":"11","endNumber":"15"}]}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        //System.assert(false, '!@#$% numInventory : ' + numInventory);
        
        UpdateNumberInventory.handleUCDMNumberRequest();
        Test.stopTest();
        System.assertEquals(res.statusCode , 400 , 'Should be failed due to different sourcesystem');
        
    } 
    
    
    @isTest
    public static void Request_NoRequest(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof('');
        RestContext.request = req;
        RestContext.response= res;
        try{
            UpdateNumberInventoryHelper.logException('test','error','null pointer','error','123 Line');
        }catch(Exception e){
            
        }
        UpdateNumberInventory.handleUCDMNumberRequest();
        
        
        Test.stopTest();
        System.assertEquals(res.statusCode , 400 , 'Should be failed due no request');
        
    }
    @isTest
    public static void RequestUCDM_ActiveNumber(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"3c47ad62-0a2f-4080-942d-ff4e037f329a","actionType":"Activate","numbers":[{"singleNumbers":["61359816707"],"ranges":[{"startNumber":"61359816908","endNumber":"61359816909"}]}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        UpdateNumberInventory.handleUCDMNumberRequest();
        system.assert(res.statusCode == 200);
        Test.stopTest();
        
    }
    @isTest
    public static void RequestUCDM_ActiveNumberNegative(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"3c47ad62-0a2f-4080-942d-ff4e037f329a","actionType":"Activate","numbers":[{"singleNumbers":["61359816907"],"ranges":[{"startNumber":"61359816908","endNumber":"61359816909"}]}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        UpdateNumberInventory.handleUCDMNumberRequest();
        system.assert(res.statusCode == 400);
        Test.stopTest();
        
    }
    @isTest
    public static void testNegative(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"3c47ad62-0a2f-4080-942d-ff4e037f329a","actionType":"Lock","numbers":[{"singleNumbers":["61359816907"],"ranges":[{"startNumber":"61359816908","endNumber":"61359816909"}]}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        UpdateNumberInventory.handleUCDMNumberRequest();
        system.assert(res.statusCode == 400);
        Test.stopTest();
        
    }
     @isTest
    public static void testNetworkServiceIdNull(){
        Test.startTest();
        UpdateNumberInventory num = new UpdateNumberInventory();
        String jsonstring = '{"networkServiceId":"","actionType":"Activate","numbers":[{"singleNumbers":["61359816907"],"ranges":[{"startNumber":"61359816908","endNumber":"61359816909"}]}]}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/number-inventory';  //Request URL
        req.httpMethod = 'POST';	//HTTP Request Type
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        UpdateNumberInventory.handleUCDMNumberRequest();
        system.assert(res.statusCode == 400);
        Test.stopTest();
        
        
    }
    
    
}