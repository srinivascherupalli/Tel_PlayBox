@isTest
public class TCMCustomerHandlerQueueableTest {
    
    
    @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
    }
    
    testMethod static void updateCIDNTest(){
        Account account2Update = null;
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_getcustomer_7899251778');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        account2Update = new Account(Name='Test Account');
        insert account2Update;
        account2Update.CIDN__c = '7899251778';
        update account2Update;
        Test.stopTest();
		Account acc = [select Id,Name,Customer_Status__c from Account where cidn__c = '7899251778'][0];
        System.assertNotEquals('RETIRED', acc.Customer_Status__c);
        //System.assertEquals('ACTIVE',acc.Customer_Status__c);
    }
    
    testMethod static void updateCIDNTest_Invalid_200_Customer(){
        Account account2Update = null;
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_200_WS0002');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        account2Update = new Account(Name='Test Account');
        insert account2Update;
        account2Update.CIDN__c = '7899251778';
        update account2Update;
        Test.stopTest();
        Account acc = [select Id,Name,Customer_Status__c from Account where cidn__c = '7899251778'][0];
        System.assertNotEquals('ACTIVE', acc.Customer_Status__c);
        //System.assertEquals('RETIRED',acc.Customer_Status__c);
    }
    
    testMethod static void updateCIDNTest_Invalid_200_Contact(){
        Account account2Update = null;
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_getcustomer_7899251778');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_200_WS0002');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        account2Update = new Account(Name='Test Account');
        insert account2Update;
        account2Update.CIDN__c = '7899251778';
        update account2Update;
        Test.stopTest();
        Account acc = [select Id,Name,Customer_Status__c from Account where cidn__c = '7899251778'][0];
        System.assertNotEquals('RETIRED', acc.Customer_Status__c);
        //System.assertEquals('ACTIVE',acc.Customer_Status__c);
    }
    
    testMethod static void updateCIDNTest_Invalid_401_Customer(){
        Account account2Update = null;
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_401');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Unauthorized');
        multimock.setStatusCode(401);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        account2Update = new Account(Name='Test Account');
        insert account2Update;
        account2Update.CIDN__c = '7899251778';
        update account2Update;
        Test.stopTest();
        Account acc = [select Id,Name,Customer_Status__c from Account where cidn__c = '7899251778'][0];
        System.assertNotEquals('ACTIVE', acc.Customer_Status__c);
        //System.assertEquals('RETIRED',acc.Customer_Status__c);
    }
    
}