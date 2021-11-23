/**
* @Story  : EDGE-209789
* @Author : Pooja Gupta
* @Description : Test class for ordInjAPICreateOrder
* @Date : 12/Apr/2021
*
*/

@isTest
public class ordInjAPICreateOrderTest {
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
            
            TLS_Session__c session  = new TLS_Session__c();
            session.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d';
            session.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"'+ testAccount.CIDN__c +'","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '"}';
            insert session;

            //Gokul -createBasket
            TLS_Session__c session2  = new TLS_Session__c();
            session2.TLS_CorrelationId__c = '008415e6-f785-66b8-811b-bc94838dde4d2';
            session2.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"'+ testAccount.Id +'","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d2","Service MSIDN":"61474703088","code":"200","description":"Validation successful for all the services","ActionType__c":"Opportunity Less Basket","Reason__c":"","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + testUSer.id + '"}';
            insert session2;
        }
    }
    
    @isTest
    public static void positiveValidationTest(){
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
        res = ordInjAPICreateOrder.createOrder(req);
        Test.stopTest();
        system.assertEquals(true,res!=null);
    }
    
    @isTest
    public static void negativeValidationTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();    
        req.requestURI = '/services/apexrest/v1/orderInjectionAPI/createOrder';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.addHeader('Content-Type', 'application/json'); 
        string jsonMsg = '{"CorrelationId__c":""}';
        req.requestBody = Blob.valueOf(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        res = ordInjAPICreateOrder.createOrder(req);
        Test.stopTest();
        system.assertNotEquals(null,res);
    }
    
    @isTest
    public static void negativeCreateOrderTest(){
        TLS_Session__c session   = [select id from TLS_Session__c session LIMIT 1];
        User owner = [Select id from USer Limit 1];
        Account acc = [SELECT Id,CIDN__c,cscfga__Active__c FROM Account WHERE cscfga__Active__c='Yes' AND CIDN__c='123456' LIMIT 1];
        session.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"9822237458","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + owner.id + '"}';
        update session;
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
        res = ordInjAPICreateOrder.createOrder(req);
        Test.stopTest();
        system.assertNotEquals(null,res);
    }
}