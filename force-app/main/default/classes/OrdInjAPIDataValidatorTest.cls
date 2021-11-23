@isTest
public class OrdInjAPIDataValidatorTest {    
    @future
    public static void insertUser() {
        profile testProfile = [SELECT Id FROM Profile WHERE Name='OrderInjection Integration'];  
        
        User testUser = new User(
            Alias = 'standT', 
            Email='test_standarduser@testorg.com',
            emailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            localeSidKey='en_US', 
            ProfileId = testProfile.Id,
            isActive = True,
            FederationIdentifier = '12534',
            timeZoneSidKey='America/Los_Angeles',
            userName = 'ABCD'+String.valueOf(Date.today()) +'@gmail.com');  
        insert testUSer;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'TNow_Order_Injection'];
        insert new PermissionSetAssignment(AssigneeId = testUSer.id, PermissionSetId = ps.Id);
        
    }
    @TestSetup static void dataSetup()
    {
        OrdInjAPIDataValidatorTest.insertUser();
        User testUser = [Select id from User Limit 1];

        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        testAccount.Account_Status__c = 'ACTIVE';
        testAccount.CIDN__c = '123456'; 
        testAccount.cscfga__Active__c='Yes';
        insert testAccount;

        System.runAs(testUser){
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

            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='User - Fixed Seat';
            serv1.csord__Identification__c  = 'testIdentify_2';
            serv1.csord__Subscription__c = testSubscription.Id;
            serv1.serviceMSISDN__c = '61474703087';
            insert serv1;

            csord__Service__c serv2 = new csord__Service__c();
            serv2.name ='User - Fixed Seat';
            serv2.csord__Identification__c  = 'testIdentify_2';
            serv2.csord__Subscription__c = testSubscription4.Id;
            serv2.serviceMSISDN__c = '61474703088';
            insert serv2;
        }
    }
    
    @isTest  
    public static void testAPIDataValidator(){  // 400 and 422
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Test.startTest();
            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/validateData'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            User owner = [Select id, FederationIdentifier from User Limit 1];

            List<csord__Subscription__c> subs = 
                [select id , Name , csordtelcoa__Subscription_Number__c 
                from csord__Subscription__c];

            List<csord__Service__c> servs = [Select id,serviceMSISDN__c from  csord__Service__c];

            String jsonInputData = '{"AccountId__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.FederationIdentifier + '","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subs[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            req.requestBody = Blob.valueOf(jsonInputData);
            
            System.debug('Check subs ' + JSON.serialize(subs));
            RestContext.request = req;
            RestContext.response = res;
            OrdInjAPIDataValidator ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            res = ordInjAPIDataValidatorObj.validateData(req);

            String jsonInputData1 = '{"AccountId__c":"123456","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.FederationIdentifier + '","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subs[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            req.requestBody = Blob.valueOf(jsonInputData1);
            RestContext.request = req;
            RestContext.response = res;
            ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            res = ordInjAPIDataValidatorObj.validateData(req);
            System.assertNotEquals(null,res);
        
            String jsonInputData2 = '{"AccountId__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.FederationIdentifier + '","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"" }, { "Subscription_Number__c": "' + subs[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"" } ]}';
            req.requestBody = Blob.valueOf(jsonInputData2);
            RestContext.request = req;
            RestContext.response = res;
            ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            res = ordInjAPIDataValidatorObj.validateData(req);
            System.assertNotEquals(null,res);

            String jsonInputData3 = '{"AccountId__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.FederationIdentifier + '","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' + subs[1].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            req.requestBody = Blob.valueOf(jsonInputData);
            OrderInjectionAPIController.doPost();

            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/nothing'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            OrderInjectionAPIController.doPost();

        Test.stopTest();
        System.debug('response ' + JSON.serialize(res));
    }
    @isTest  
    public static void testAPIDataValidator1(){  // 200
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Test.startTest();
            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/validateData'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            User owner = [Select id,FederationIdentifier from User Limit 1];

            List<csord__Subscription__c> subs = 
                [select id , Name , csordtelcoa__Subscription_Number__c 
                from csord__Subscription__c];

            List<csord__Service__c> servs = [Select id,serviceMSISDN__c from  csord__Service__c];


            String jsonInputData1 = '{"AccountId__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"12534","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            system.debug('json data'+jsonInputData1);
        	req.requestBody = Blob.valueOf(jsonInputData1);
            RestContext.request = req;
            RestContext.response = res;
            OrdInjAPIDataValidator ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            res = ordInjAPIDataValidatorObj.validateData(req);
        	system.debug('result from validationContoller'+res);
            System.assertNotEquals(null,res);
       

            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/nothing'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            OrderInjectionAPIController.doPost();

        Test.stopTest();
        System.debug('response ' + JSON.serialize(res));
    }
     @isTest  
    public static void testAPIDataValidator2(){  // 200
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Test.startTest();
            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/validateData'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            User owner = [Select id,FederationIdentifier from User Limit 1];

            List<csord__Subscription__c> subs = 
                [select id , Name , csordtelcoa__Subscription_Number__c 
                from csord__Subscription__c];

            List<csord__Service__c> servs = [Select id,serviceMSISDN__c from  csord__Service__c];


            String jsonInputData1 = '{"AccountId__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"TON Connect","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"12534","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            system.debug('json data 2'+jsonInputData1);
        	req.requestBody = Blob.valueOf(jsonInputData1);
            RestContext.request = req;
            RestContext.response = res;
            OrdInjAPIDataValidator ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            res = ordInjAPIDataValidatorObj.validateData(req);
        	system.debug('result from validationContoller'+res);
            System.assertNotEquals(null,res);
       

            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/nothing'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            OrderInjectionAPIController.doPost();

        Test.stopTest();
        System.debug('response ' + JSON.serialize(res));
    }
    
    @isTest  
    public static void testAPIDataValidator3(){  // 200
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Test.startTest();
            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/validateData'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 

            User owner = [Select id,FederationIdentifier from User Limit 1];

            List<csord__Subscription__c> subs = 
                [select id , Name , csordtelcoa__Subscription_Number__c 
                from csord__Subscription__c];

            List<csord__Service__c> servs = [Select id,serviceMSISDN__c from  csord__Service__c];


            String jsonInputData1 = '{"AccountId__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"TON Disconnect","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"12534","services": [ { "Subscription_Number__c": "' + subs[0].csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
            system.debug('json data 2'+jsonInputData1);
        	req.requestBody = Blob.valueOf(jsonInputData1);
            RestContext.request = req;
            RestContext.response = res;
            OrdInjAPIDataValidator ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            res = ordInjAPIDataValidatorObj.validateData(req);
        	system.debug('result from validationContoller'+res);
            System.assertNotEquals(null,res);
       

            req.requestURI = '/services/apexrest/v1/orderInjectionAPI/nothing'; 
            req.httpMethod = 'POST';
            req.addHeader('Content-Type', 'application/json'); 
            OrderInjectionAPIController.doPost();

        Test.stopTest();
        System.debug('response ' + JSON.serialize(res));
    }
}