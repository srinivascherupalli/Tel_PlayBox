/**
* @Story  : EDGE-207465
* @Author : Pooja Gupta
* @Description : Test class for ordInjAPIUpdateServices
* @Date : 19/Apr/2021
*
*/
@isTest
public class ordInjAPIUpdateServicesTest {
    @TestSetup 
    static void dataSetup()
    {
        profile testProfile = [SELECT Id FROM Profile WHERE Name='OrderInjection Integration'];  
        user testUser = new User(
            Alias = 'standT', 
            Email='test_standarduser@testorg.com',
            emailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            localeSidKey='en_US', 
            ProfileId = testProfile.Id,
            timeZoneSidKey='America/Los_Angeles',
            userName = 'ABCD'+String.valueOf(Date.today()) +'@gmail.com');  
        insert testUSer;  
        
        
        system.runAs(testUser){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'TNow_Order_Injection'];
            insert new PermissionSetAssignment(AssigneeId = testUSer.id, PermissionSetId = ps.Id);
            
            Account testAccount = new Account();
            testAccount.Name = 'testAccount';
            testAccount.Customer_Status__c = 'ACTIVE';
            testAccount.CIDN__c = '123456'; 
            testAccount.cscfga__Active__c='Yes';
            insert testAccount;
            List<csord__Subscription__c> subslist=new List<csord__Subscription__c>();
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            testSubscription.Name = 'TestSubsforTest';
            testSubscription.csord__Account__c = testAccount.Id;
            testSubscription.csord__Identification__c = 'test';
            testSubscription.csordtelcoa__Subscription_Number__c = 'SN-000552601';
            testSubscription.csord__Status__c = 'Active';
            subslist.add(testSubscription);
            csord__Subscription__c testSubscription4 = new csord__Subscription__c();
            testSubscription4.Name = 'TestSubsforTest4';
            testSubscription4.csord__Account__c = testAccount.Id;
            testSubscription4.csord__Identification__c = 'test';
            testSubscription4.csordtelcoa__Subscription_Number__c = 'SN-000552602';
            testSubscription4.csord__Status__c = 'Suspended';
            subslist.add(testSubscription4);
            insert subslist;
            
            csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
            insert ordReq;
            
            csord__Order__c testOrder = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
            testOrder.telstra_ord_Start_DateTime__c=System.now(); //EDGE-182667
            testOrder.csord__Order_Request__c = ordReq.Id;
            insert testOrder; 
            
            TLS_Session__c session  = new TLS_Session__c();
            session.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d';
            session.TLS_PayLoad__c = '{"validateData": "Success","createOrder": "Success", "Order_Request__c" : "'+ordReq.Id+'", "Order_Number__c" :"ON00071362", "orderId" : "'+testOrder.Id+'",  "AccountId__c":"'+ testAccount.CIDN__c +'","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '","services": [ { "Subscription_Number__c": "' + subslist[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subslist[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            insert session;
        }
    }
    
    @isTest
    public static void positiveValidationTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/updateServices';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d"}';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        res = ordInjAPIUpdateServices.updateServices(req);
        Test.stopTest();
        system.assertNotEquals(null,res);
    }
    
    @isTest
    public static void negativeValidationTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/updateServices';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":""}';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        res = ordInjAPIUpdateServices.updateServices(req);
        Test.stopTest();
        system.assertNotEquals(null,res);
    }
    
     @isTest
    public static void negativeUpdateServiceTest(){
        TLS_Session__c session   = [select id from TLS_Session__c session LIMIT 1];
        User owner = [Select id from USer Limit 1];
        List<csord__Subscription__c> subs = [select id , Name , csordtelcoa__Subscription_Number__c from csord__Subscription__c];
        session.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"9822237458","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.id + '","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subs[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
        update session;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/updateServices';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d"}';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        res = ordInjAPICreateOrder.createOrder(req);
        Test.stopTest();
        system.assertNotEquals(null,res);
    }
}