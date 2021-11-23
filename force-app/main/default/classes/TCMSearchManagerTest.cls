@isTest
private class TCMSearchManagerTest {
  
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
	EnvironmentVariable.put('tcm_contact_scope', 'TCMCONTACT');
    EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
  }
  
    static testMethod void testToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String token = TCMSearchManager.getToken();
        System.assert(token == 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.stopTest();
    }
    
    static testMethod void testTCMToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String token = TCMSearchManager.getTCMToken();
        Test.stopTest();
    }
    
    static testMethod void testContactToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String token = TCMSearchManager.getTCMContactToken();
        Test.stopTest();
    }
    
    static testMethod void testGetTokenRequest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        HttpRequest tokenRequest = TCMSearchManager.getTokenRequest('TCMCUSTOMER');
        Test.stopTest();
    }
    
    static testMethod void testHandleResponse() {
      Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        HttpResponse res1 = new HttpResponse();
        res1.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        HttpResponse res = TCMSearchManager.handleResponse(res1, 'tcm_contactEndpoint', '520A4E0E-0F82-4122-AE88-7E57130F7511?include=customer-accounts');
        System.assert(res != null);
        Test.stopTest();     
    }
    
    static testMethod void testHandleTokenResponse() {
      Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        HttpResponse res1 = new HttpResponse();
        res1.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        String res = TCMSearchManager.handleTokenResponse(res1, 'tcm_contactEndpoint', '520A4E0E-0F82-4122-AE88-7E57130F7511?include=customer-accounts');
        System.assert(res != null);
        Test.stopTest();     
    }
    
}