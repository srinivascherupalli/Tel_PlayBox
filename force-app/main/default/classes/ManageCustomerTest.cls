@isTest
public class ManageCustomerTest {
    
  @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint','https://mocksandbox.getsandbox.com');
        final Account acc = TestUtil.createAccount('My Account crossref');
        //acc.Customer_ID__c = '987654321';
        acc.Customer_Status__c='SUSPECT';
        acc.Pref_Comm_Method__c='Fax';
        acc.Fax='12345';
        insert acc;
    }
    
    static testMethod void sendCreate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
         //Account acc=[select id from account where fax='12345'][0];
        ManageCustomer.send([select id from account where fax='12345'][0].id, false); 
        System.assertEquals(1, [SELECT count() from Account WHERE fax = '12345'],'Account');
        Test.stopTest();
    }
    
    static testMethod void sendUpdate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        ManageCustomer.send([select id from account where fax='12345'][0].id, false);    
        System.assertEquals(1, [SELECT count() from Account WHERE fax = '12345'],'Account');
        Test.stopTest();
    }
    
    static testMethod void sendCrossReference() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        ManageCustomer.send([select id from account where fax='12345'][0].id, true); 
        System.assertEquals(1, [SELECT count() from Account WHERE fax = '12345'],'Account');
        Test.stopTest();
    }
    
    static testMethod void sendCrossReferencemocks() {
        Test.startTest();
        final IntegrationSettings__c is = new IntegrationSettings__c();
        is.EnableMocks__c = true;
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        ManageCustomer.send([select id from account where fax='12345'][0].id, true); 
        System.assertEquals(1, [SELECT count() from Account WHERE fax = '12345'],'Account');
        Test.stopTest();
    }
}