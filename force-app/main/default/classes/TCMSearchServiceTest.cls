@isTest
public class TCMSearchServiceTest {
    
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
        //EnvironmentVariable.put('certificate_name','http://mocksandbox.getsandbox.com/managebilling/rest/validate');
  }
    
    static testMethod void testCallout1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6/test401';
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final HttpResponse resp = TCMSearchService.callout(url, token);
        System.assertEquals(resp!=null, true,'Response');
        Test.stopTest();
    }
    
    static testMethod void testCallout() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts';
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final HttpResponse resp = TCMSearchService.callout(url, token);
        System.assertEquals(resp!=null, true,'Response');
        Test.stopTest();
    }
    
    static testMethod void test401() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6/test401';
        final HttpResponse res = TCMSearchService.callout(url, token);
        System.debug(res.getStatusCode());
        System.assert(res.getStatusCode() == 401);
        System.assert(res.getBody() != null);
        final JSON2TCMErrorObject err = JSON2TCMErrorObject.parse(res.getBody());
        System.debug(err);
        System.assertEquals(err.status ,'401','Error');
        Test.stopTest();
    }
}