@isTest
private class OauthLoginTest {
    
    @testSetup static void setup() {
        amdocs_integration_configuration__c aic = new amdocs_integration_configuration__c();
        aic.endpoint__c = 'https://realendpoint:8080/loginService';
        aic.client_id__c = '12345';
        aic.client_secret__c = '12345';
        aic.grant_type__c = '12345';
        aic.scope__c = '12345';
        aic.enable_mocks__c = true;
        aic.method__c = 'POST';
        aic.mock_endpoint__c = 'https://getsandbox.com/mocksandbox';
        insert aic; 
        
        EnvironmentVariable__c ev = new EnvironmentVariable__c();
        ev.name = 'massl_certificate_name';
        ev.Value__c = 'abc';
        east_integration_configuration__c eic = new east_integration_configuration__c();
        eic.endpoint__c = 'https://realendpoint:8080/loginService';
        eic.client_id__c = '12345';
        eic.client_secret__c = '12345';
        eic.grant_type__c = '12345';
        eic.scope__c = '12345';
        eic.enable_mocks__c = true;
        eic.method__c = 'POST';
        eic.enable_mocks__c = true;
        eic.mock_endpoint__c = 'https://getsandbox.com/mocksandbox';
        insert eic; 
    }
    
    @isTest static void test_withMocksSettingEnabled() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String token = OauthLogin.getAMDOCSToken();
        Test.stopTest();
        System.assertNotEquals(null, token);
    }
    
    @isTest static void testEast(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String token = OauthLogin.getToken('EAST');
        Test.stopTest();
        System.assertNotEquals(null, token);
    }
    
    @isTest static void tesIsMockt(){
        Test.startTest();
        Boolean token = OauthLogin.isMock('EAST');
        Test.stopTest();
        System.assertNotEquals(null, token);
    }
    
    @isTest static void testReplicator(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String token = OauthLogin.getToken(ReplicatorLegacyAssetService.GETSERVICE_EVENT);
        Test.stopTest();
        System.assertNotEquals(null, token);
    }
}