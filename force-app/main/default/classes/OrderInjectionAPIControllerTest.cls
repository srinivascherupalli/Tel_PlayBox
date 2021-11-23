/**
* @Story  : EDGE-209789
* @Author : Pooja Gupta
* @Description : Test class for OrderInjectionAPIController
* @Date : 14/Apr/2021
*
*/
@isTest
public class OrderInjectionAPIControllerTest {
     @TestSetup static void dataSetup() 
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
            
            List<csord__Service__c> servlist=new List<csord__Service__c>();
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='User - Fixed Seat';
            serv1.csord__Identification__c  = 'testIdentify_2';
            serv1.csord__Subscription__c = testSubscription.Id;
            serv1.serviceMSISDN__c = '61474703087';
            servlist.add(serv1);

            csord__Service__c serv2 = new csord__Service__c();
            serv2.name ='User - Fixed Seat';
            serv2.csord__Identification__c  = 'testIdentify_2';
            serv2.csord__Subscription__c = testSubscription4.Id;
            serv2.serviceMSISDN__c = '61474703088';
            servlist.add(serv2);
            insert servlist;
            
            TLS_Session__c session  = new TLS_Session__c();
            session.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d';
            session.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"'+ testAccount.Id +'","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '","services": [ { "Subscription_Number__c": "' + subslist[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subslist[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            insert session;
            
            //Gokul -createBasket
            TLS_Session__c session2  = new TLS_Session__c();
            session2.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d2';
            session2.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"'+ testAccount.Id +'","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2","Service MSIDN":"61474703088","code":"200","description":"Validation successful for all the services","ActionType__c":"Opportunity Less Basket","Reason__c":"","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '","services": [ { "Subscription_Number__c": "' + subslist[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subslist[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            insert session2;

            TLS_Session__c session3  = new TLS_Session__c();
            session3.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d3';
            session3.TLS_PayLoad__c = '{"validateData": "Success","Order_Rec_Id": "2736929377","basketEnrichment":"Success","AccountId__c":"'+ testAccount.Id +'","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2","Service MSIDN":"61474703088","code":"200","description":"Validation successful for all the services","ActionType__c":"Opportunity Less Basket","Reason__c":"","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '","services": [ { "Subscription_Number__c": "' + subslist[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subslist[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            insert session3;
        }
    }
    
@isTest
    public static void apiCreateOrderTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/createOrder';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d"}';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        OrderInjectionAPIController.doPost();
        Test.stopTest();
        system.assertNotEquals(null,res);
    }

    //DIGI-16926-Start
    @isTest
    public static void apicreateBasketTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/createBasket';//Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2"}';//Gokul-Ameer CreateBasket
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        OrderInjectionAPIController.doPost();
        Test.stopTest();
        system.assertNotEquals(null,res);
    }
      //By DIGI-16926-ENd  
      //DIGI-475-Start
    @isTest
    public static void SubmitOrderTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/submitOrder';//Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d3"}';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        OrderInjectionAPIController.doPost();
        Test.stopTest();
        system.assertNotEquals(null,res);
    }
      //By DIGI-475-ENd  

      //DIGI-9360-Start  
     @isTest
      public static void PollAsyncProcStatusTest(){
          RestRequest req = new RestRequest(); 
          RestResponse res = new RestResponse();    
          req.requestURI = '/services/apexrest/v1/orderInjectionAPI/PollAsyncProcStatus';//Request URL
          req.httpMethod = 'POST';//HTTP Request Type
          req.addHeader('Content-Type', 'application/json'); 
          string jsonMsg = '{"CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2"}';
          req.requestBody = Blob.valueOf(jsonMsg);
          RestContext.request = req;
          RestContext.response= res;
          Test.startTest();
          OrderInjectionAPIController.doPost();
          Test.stopTest();
          system.assertNotEquals(null,res);
      }
      //DIGI-9360-ENd  
      
    @isTest
    public static void testAPIDataValidator(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Test.startTest();
            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/validateData'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            User owner = [Select id from USer Limit 1];

            List<csord__Subscription__c> subs = 
                [select id , Name , csordtelcoa__Subscription_Number__c 
                from csord__Subscription__c];

            List<csord__Service__c> servs = [Select id,serviceMSISDN__c from  csord__Service__c];

            String jsonInputData = '{"AccountId__c":"9822237458","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.id + '","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subs[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            req.requestBody = Blob.valueOf(jsonInputData);
            RestContext.request = req;
            RestContext.response = res;
            OrdInjAPIDataValidator ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            res = ordInjAPIDataValidatorObj.validateData(req);

            String jsonInputData3 = '{"AccountId__c":"9822237458","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.id + '","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subs[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            req.requestBody = Blob.valueOf(jsonInputData);
            OrderInjectionAPIController.doPost();

            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/nothing'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            OrderInjectionAPIController.doPost();

        Test.stopTest();
        system.assertNotEquals(null,res);
    }
}