@isTest( SeeAllData = false)
private class AuthenticationManagerTest
{  
      @testSetup static void setup() 
      {
        amdocs_integration_configuration__c aic = new amdocs_integration_configuration__c();
        String SId = '12345';
        aic.endpoint__c = 'https://realendpoint:8080/loginService';
        aic.client_id__c = SId;
        aic.client_secret__c = SId;
        aic.grant_type__c = SId;
        aic.scope__c = SId;
        aic.enable_mocks__c = true;
        aic.method__c = 'POST';
        aic.mock_endpoint__c = 'https://getsandbox.com/mocksandbox';
        insert aic; 
        
        
    }
    @isTest static void test_withMocksSettingandCachValue() 
    {
        Cache.Org.put('AMDOCS','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String Token  = AuthenticationManager.getOauthToken('AMDOCS');   
        Test.stopTest();      
        System.assertEquals('lFYpKM2LkokcsbzQFKfsMTiPeFcA',Token  );
    }
    @isTest static void test_withMocksSettingEnabled() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String Token  =AuthenticationManager.getOauthToken('AMDOCS');
        System.assertEquals('lFYpKM2LkokcsbzQFKfsMTiPeFcA',Token  );
        Test.stopTest();
    }    
}