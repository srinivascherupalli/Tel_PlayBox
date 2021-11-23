@isTest
public class GetProductAPITest {
    
    static RestRequest request = New RestRequest();
    static RestResponse response = new RestResponse();
    
    @testSetup static Void testSetUp()
    {
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;
        
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'SVC-000004394';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        insert serv;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"additionalAttributes" : {"SERVID" : "61474814390"},"attributes" : {"BillofMaterialID" : "{BoMForMobileAccess}","__targetSystem" : "FULFILMENT","ServiceID" : "","ShippingRequired " : "TRUE",     "ExternalAntennaRequired" : "FALSE","IMSI" : "1234","IPVPNProductInstanceId" : "DMCAT_ProductSpecification_000028_Fulfilment","CustomerFacingServiceId" : "1234"},"code" : "DMCAT_ProductSpecification_000263","description" : "","endDate" : "","guid" : "434207c7-7981-4588-4357-c643c351234b","instanceId" : "","name" : "Mobile Access_Fulfilment","productConfigurationId" : "a3T2O0000008yTH","specification" : "null_chrgOC","startDate" : "","status" : "Created","version" : "1"},{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","productConfigurationId" : "a3T2O000000GhjSUAS","name" : "UC Numbers_Fulfilment","metadata" : { },"instanceId" : "", "includeBilling" : false,"guid" : "219ab53a-68eb-a3a6-e477-7302c720a9b9","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000313_Fulfilment","attributes" : {"Number" : [ {"attributes" : {"listCode" : "LE","status" : "RESERVED","rangeTo" : null,"rangeFrom" : null,"FNN" : "0738193230"},"schemaId" : "589544bf-9bc3-f356-0797-f85d9d65eba5"},{"attributes" : {"listCode" : "No Entry Line","status" : "RESERVED","rangeTo" : "738193246","rangeFrom" : "738193245","FNN" : null},"schemaId" : "ce52bbcc-fa77-8d1f-24c8-25231aa51c42"} ],"__targetSystem" : "FULFILMENT","parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment"},"additionalAttributes" : {"parentSpec" : "7da9c15a-31c1-cf3a-806b-1bb843712e18"}}], "legacyAttributes" : [ ],"serviceId" : "'+serv.Id+'"}');

        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
        EnvironmentVariable__c env= new EnvironmentVariable__c();
        env.Name='enableSplunkAttributesInventory';
        env.Value__c='true';
        insert env;
    }
    
    
    static testMethod void testProductDetails()
    {
       // csord__Order__c ordP = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        csord__Service__c srvc = [select id,name,csord__Subscription__c,csordtelcoa__Service_Number__c from csord__service__c where Name ='tst service'limit 1];
                
        String guid = '219ab53a-68eb-a3a6-e477-7302c720a9b9';
        String CorrelationID = srvc.csordtelcoa__Service_Number__c+':'+guid;
        request.requestURI = '/services/apexrest/v1/product-details/'+CorrelationID; //Request URL
        request.httpMethod = 'GET'; //Request Method
        
        Test.startTest();
        testSetUp();
        RestContext.request = request;
        RestContext.response = response; 
        GetProductAPI.getProductDetails();
        Test.stopTest();  
        system.assertNotEquals(null,response);
    } 
    
    static testMethod void testProductDetailsError()
    {
       // csord__Order__c ordP = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        csord__Service__c srvc = [select id,name,csord__Subscription__c,csordtelcoa__Service_Number__c from csord__service__c where Name ='tst service'limit 1];        
        String guid = 'test';
        String CorrelationID = srvc.csordtelcoa__Service_Number__c+':'+guid;
        
        request.requestURI = '/services/apexrest/v1/product-details/'+CorrelationID; //Request URL
        request.httpMethod = 'GET'; //Request Method
        Test.startTest();
        testSetUp();
        RestContext.request = request;
        RestContext.response = response;     
        GetProductAPI.getProductDetails();
        Test.stopTest();  
        system.assertNotEquals(null,response);
    }
    
    static testMethod void testProductDetailsException()
    {
        
        
        csord__Order__c ordP = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        String guid = 'test';
        String CorrelationID = ''+':'+guid;
        
        request.requestURI = '/services/apexrest/v1/product-details/'+CorrelationID; //Request URL
        request.httpMethod = 'GET'; //Request Method
        Test.startTest();
        testSetUp();
        RestContext.request = request;
        RestContext.response = response;     
        GetProductAPI.getProductDetails();
        Test.stopTest();  
        system.assertNotEquals(null,response);
    }
   
    static testMethod void testProductDetailsException2()
    {
        String res = GetServSpecHandler.validateRequest(null);
        system.assertEquals('Invalid',res);
    }
	static testMethod void testProductDetailsException3()
    {
        csord__Order__c ordP = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        String guid = 'testExceptionlog';
        String CorrelationID = ''+':'+guid;
        Test.startTest();
        RestResponse outRes = GetServSpecHandler.generateResponse(null,CorrelationID); 
       	Test.stopTest();
        list<Exception_Log__c> expList = [select id,Error_Description__c from Exception_Log__c];
        system.assertEquals('Attempt to de-reference a null object',expList[0].Error_Description__c);
    }
}