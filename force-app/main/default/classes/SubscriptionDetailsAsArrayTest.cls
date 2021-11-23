/******************************************************************
EDGE          -149915
Class         -SubscriptionDetailsAsArrayTest
Description   -Test Class for SubscriptionDetailsAsArray Class
Author        -Dheeraj Bhatt
*******************************************************************/
@IsTest
public class SubscriptionDetailsAsArrayTest {
    @testsetup 
    public static void dataSetup(){
        
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        
        List<cscfga__Product_Definition__c> pdList=new List<cscfga__Product_Definition__c>();
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Mobile Subscription';
        productDefinition.cscfga__Description__c = 'Mobile Subscription';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        pdList.add(productDefinition);
        
        cscfga__Product_Definition__c productDefinition2 = new cscfga__Product_Definition__c();
        productDefinition2.Name = 'Enterprise Mobility';
        productDefinition2.cscfga__Description__c = 'Enterprise Mobility';
        productDefinition2.product_Specification__c = 'DMCAT_Offer_000646';
        pdList.add(productDefinition2);
            
        insert pdList;
        
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.Remaining_Term__c  = 24;
        productConfig.cscfga__Product_Basket__c=basket.id;
        pcList.add(productConfig);
        
        cscfga__Product_Configuration__c productConfig2 = new cscfga__Product_Configuration__c();
        productConfig2.cscfga__Product_Definition__c = productDefinition2.Id;
        productConfig2.ConfigurationType1__c='SolutionComponent';
        productConfig2.Remaining_Term__c  = 24;
        productConfig2.cscfga__Product_Basket__c=basket.id;
        pcList.add(productConfig2);
        insert pcList;
        
        
        
        Id RecordTypeIdOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted with Appointment').getRecordTypeId();
        csord__Order_Request__c orderRequest=new csord__Order_Request__c();
        
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification1';
        ord.Name = 'test sec order';
        ord.csord__Order_Request__c=orderRequest.id;
        ord.RecordTypeId=RecordTypeIdOrder;
        ord.Scenario_Type__c='';
        ord.csordtelcoa__Opportunity__c=opp.id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.csord__Order__c = ord.id;
        subs.csordtelcoa__Product_Configuration__c=productConfig.id;
        subs.csordtelcoa__Subscription_Number__c='SN-000172208';
        subs.serviceMSISDN__c='61459812342';
        
        insert subs;
        
        csord__Subscription__c solutionSubscription=new csord__Subscription__c();
        solutionSubscription.name  = 'test subs';
        solutionSubscription.csord__Identification__c = 'test identity';
        solutionSubscription.csord__Status__c = 'Pending';
        solutionSubscription.csord__Order__c = ord.id;
        solutionSubscription.Parent_Subscription__c=subs.id;
        solutionSubscription.csordtelcoa__Product_Configuration__c=productConfig2.id;
        subs.csordtelcoa__Subscription_Number__c='SN-000172209';
        insert solutionSubscription;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service1';
        serv.csord__Identification__c  = 'test identify1';
        serv.csordtelcoa__Service_Number__c = '4';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Failed';
        serv.csord__Order__c = ord.id;
        serv.Appointment_Required__c='true';
        serv.Scenario_Type__c ='Port Out Reversal';
        serv.NetworkServiceId__c='NW-1234';
        serv.serviceMSISDN__c='61459812342';
        insert serv;
        
        string serviceNumber=[SELECT csordtelcoa__Service_Number__c from csord__Service__c WHERE Id =: serv.id ].csordtelcoa__Service_Number__c;
        string subscriptionNumber=[SELECT csordtelcoa__Subscription_Number__c from csord__Subscription__c WHERE Id =: subs.id ].csordtelcoa__Subscription_Number__c;
        
        List<Number__c> numberList=new List<Number__c>(); 
        Number__c num= new Number__c(Service_Id__c=serviceNumber,Service_Number__c='61459812342',Type__c='FNN', Mobile__c='Fixed',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        numberList.add(num);
        
        Number__c num1= new Number__c(Service_Number__c='61459812345',Type__c='FNN', Mobile__c='Fixed',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        numberList.add(num1);
         Number__c num2= new Number__c(Service_Id__c=serviceNumber,Subscription_number__c=subscriptionNumber,Service_Number__c='61459812346',Type__c='FNN', Mobile__c='Fixed',Sim_Serial_Number__c='1234567890125',IMSI__c='1234567890123',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        numberList.add(num2);
        insert numberList;
        
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"null_chrgOC","productConfigurationId":"a3T2O000000932lUAA","name":"Mobile Access_Billing","instanceId":"","guid":"d9a9b4eb-f6c3-e8a8-d1be-2c80e297f39e","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing","attributes":{"__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O000000932lUAA","name":"Unified Communication Site_Fulfilment","instanceId":"","guid":"96ef7588-4e55-7906-41cc-205f994a031f","endDate":"","description":"","code":"DMCAT_ProductSpecification_000104_Fulfilment","attributes":{"PrimaryAccessProductInstanceID":"","DMCAT_ProductSpecification_000104_CPEDeliveryDate":"","ServiceTypeProductInstanceID":"DMCAT_ProductSpecification_000083_Fulfilment","UCEnterpriseProductInstanceID":"DMCAT_ProductSpecification_000087_Fulfilment","RedundantAccessProductInstanceID":"","CustomerPreferredName":"","CustomerFacingServiceId":"","__targetSystem":"FULFILMENT"},"additionalAttributes":{"UCEnterpriseProductInstanceID":"14f630f6-97bc-e5b0-881c-e0adc99bc249","ServiceTypeProductInstanceID":"84155b82-d397-ce83-41a1-aa89bdd3adb5"}},{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O0000009339UAA","name":"Voice Numbers_Fulfilment","instanceId":"","guid":"01c9cf4e-1682-b8e2-86d3-8a8381795cb7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000109_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"null_chrgOC","productConfigurationId":"a3T2O0000009339UAA","name":"Voice Numbers_Billing","instanceId":"","guid":"815eb403-7178-7684-09a5-86b18ffc9c84","endDate":"","description":"","code":"DMCAT_ProductSpecification_000109_Billing","attributes":{"__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"a4e2O0000004IsnQAE","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
        Asset newAsset= TestDataFactory.generateAsset('apple iphone 7',solutionSubscription.id,null,system.today(),system.today(), 1.0,acc.id,'test123456');
        newAsset.Status='Active';
        Insert newAsset;
        
        Asset newAsset1= TestDataFactory.generateAsset('apple iphone 7',subs.id,null,system.today(),system.today(), 1.0,acc.id,'test123457');
        newAsset1.Status='InActive';
        newAsset1.csordtelcoa__Replaced_Asset__c=newAsset.id;
        newAsset1.parentId=newAsset.id;
        Insert newAsset1;
        
    }
    
    
    @isTest public static void testApiWithSubscriptionNumber(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String Correlation = 'SN-000004523';     
        req.requestURI = '/v2/subscription-details/SN-000004523';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        SubscriptionDetailsAsArray.getSubscriptionDetails();
        system.assertNotEquals(null,res);
        Test.stopTest();
    }
    @isTest public static void testApiWithServiceNetworkIdNumber(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String Correlation = 'SN-000004523';     
        req.requestURI = '/v2/subscription-details/NW-1234';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        SubscriptionDetailsAsArray.getSubscriptionDetails();
        system.assertNotEquals(null,res);
        Test.stopTest();
    }
    @isTest public static void testApiWithFNN(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String Correlation = 'SN-000004523';     
        req.requestURI = '/v2/subscription-details/61459812342';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        SubscriptionDetailsAsArray.getSubscriptionDetails();
        system.assertNotEquals(null,res);
        Test.stopTest();
    }
     @isTest public static void testApiWithFNN2(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI = '/v2/subscription-details/61459812346';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        SubscriptionDetailsAsArray.getSubscriptionDetails();
        system.assertNotEquals(null,res);
        Test.stopTest();
    }
    @isTest public static void errorApiTest(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String Correlation = 'SN-000004523';     
        req.requestURI = '/v2/subscription-details/SVC-123';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        SubscriptionDetailsAsArray.getSubscriptionDetails();
        system.assertNotEquals(null,res);
        Test.stopTest();
    }
}