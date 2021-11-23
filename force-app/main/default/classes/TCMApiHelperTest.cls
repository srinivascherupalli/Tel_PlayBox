/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TCMApiHelperTest {
    
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
    }
    
    static testMethod void testToken() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = TCMApiHelper.getToken();
        System.assertEquals(token,'lFYpKM2LkokcsbzQFKfsMTiPeFcA','Check Token');
        Test.stopTest();
    }
    
    static testMethod void testEASTToken() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = TCMApiHelper.getEASTToken();
        System.assertEquals((token!=null),true,'Check Token');
        Test.stopTest();
    }
    
    static testMethod void testTCMToken() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = TCMApiHelper.getTCMToken();
        System.assertEquals((token!=null),true,'Check Token');
        Test.stopTest();
    }
    
    static testMethod void testContactToken() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = TCMApiHelper.getTCMContactToken();
        System.assertEquals((token!=null),true,'Check Token');
        Test.stopTest();
    }
    
    static testMethod void testGetTokenRequest() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final HttpRequest tokenRequest = TCMApiHelper.getTokenRequest('TCMCUSTOMER');
        System.assertEquals((tokenRequest!=null),true,'Check Token');
        Test.stopTest();
    }
    
    static testMethod void testHandleResponse() {
        //public static HttpResponse handleResponse(HttpResponse res, String endpoint, String params) 
        //handleTokenResponse
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final HttpResponse res1 = new HttpResponse();
        res1.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        final HttpResponse res = TCMApiHelper.handleResponse(res1, 'tcm_contactEndpoint', '520A4E0E-0F82-4122-AE88-7E57130F7511?include=customer-accounts');
        System.assert(res != null,'Response');
        Test.stopTest();    
    }
    
    static testMethod void testHandleTokenResponse() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final HttpResponse res1 = new HttpResponse();
        res1.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        final String res = TCMApiHelper.handleTokenResponse(res1, 'tcm_contactEndpoint', '520A4E0E-0F82-4122-AE88-7E57130F7511?include=customer-accounts');
        System.assert(res != null,'Response');
        Test.stopTest();    
    }
    
    static testMethod void test401() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6/test401';
        final HttpResponse res = TCMApiHelper.callout(url, token);
        System.debug(res.getStatusCode());
        System.assertEquals(res.getStatusCode() ,401,'Status code');
        System.assert(res.getBody() != null,'Response');
        final JSON2TCMErrorObject err = JSON2TCMErrorObject.parse(res.getBody());
        System.debug(err);
        System.assertEquals(err.status,'401','Error');
        Test.stopTest();
    }
    
    static testMethod void testGetCustomerAccountById() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts/10000002126';
        final HttpResponse res = TCMApiHelper.callout(url, token);
        System.assert(res.getBody() != null,'');
        JSON2TCMCustomerObject o = JSON2TCMCustomerObject.parse(res.getBody());
        //System.assert(o.data.address[0].addressId == '414960537');
        Test.stopTest();
    }
    
    static testMethod void testGetCustomerAccountIncludeContact() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts/10000002126?include=contacts';
        final HttpResponse res = TCMApiHelper.callout(url, token);
        System.assert(res.getBody() != null);
        final JSON2TCMCustomerContactObject o = JSON2TCMCustomerContactObject.parse(res.getBody());
        System.assertEquals(o.data.contacts[0].workContact.phoneNumber, '+610349403943','Work Phone');
        Test.stopTest();
    }
    
   static testMethod void testGetCustomerByLastnameABN() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts?abn=10000000000&lastName=AARATHY SD multi';
        final HttpResponse res = TCMApiHelper.callout(url, token);
        System.assert(res.getBody() != null);
        final JSON2TCMCustomerListObject o = JSON2TCMCustomerListObject.parse(res.getBody());
        System.assertEquals(o.data[0].address[1].locality , 'ARECIBO','Address');
        Test.stopTest();
    }
    
    static testMethod void tetGetContactsByNameBirthDate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts?lastName=ARUN&birthDate=1982-08-18&firstName=VENKATESH';
        final HttpResponse res = TCMApiHelper.callout(url, token);
        System.assert(res.getBody() != null);
        final JSON2TCMContactObject o = JSON2TCMContactObject.parse(res.getBody());
        System.assertEquals(o.data[0].customerAccounts[1].lastName ,'ARUNTESTING','Last name');
        Test.stopTest();
    }
    
      static testMethod void tetGetContactCustomers() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        final String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        final String url = 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts/520A4E0E-0F82-4122-AE88-7E57130F7511?include=customer-accounts';
        final HttpResponse res = TCMApiHelper.callout(url, token);
        System.assert(res.getBody() != null);
        final JSON2TCMContactCustomerObject o = JSON2TCMContactCustomerObject.parse(res.getBody());
        System.assertEquals(o.data.customerAccounts[0].accountUuid , '72891852-47BA-4d69-9741-F939FE022017','UUID');
        Test.stopTest();
    }
}