@isTest
public with sharing class ManagePIMSInterfaceTest {

     @testSetup static void setup() 
      {
      UserRole r = [SElect id from UserRole where Name=: 'CEO'];
      profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
      
      User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
                insert uSysAdmin;
                system.runAs(uSysAdmin){            
       
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
        
        
        }
    }

    @isTest 
    public static void test_withMocksSettingandCachValue() 
    {
        Cache.Org.put('AMDOCS','lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        String Token  = AuthenticationManager.getOauthToken('AMDOCS');
        System.debug('tttt' + Token);
        
        Test.stopTest();
        
        System.assertEquals('lFYpKM2LkokcsbzQFKfsMTiPeFcA',Token  );
    }
    //Resolved issue Role issue
    static testMethod void testManagePIMSInterface() {
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
        Account ac = new Account(name ='Telecom') ;
        insert ac; 

        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active');
        insert con;
        
        id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        User u1 = new User(alias = 'test123', email='test12356@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username='test12356@noemail.com');
        
        insert u1;

                
        String msRequest = '{'+
            '  \"userPid\": \"\",'+
            '  \"userFirstName\": \"Nikita\",'+
            '  \"userLastName\": \"Tiwa\",'+
            '  \"userEmail\": \"abc@telstra.com\",'+
            '  \"orgName\": \"abc\",'+
            '  \"isPDUA\": \"false\",'+
            '  \"isDeactivate\": \"false\",'+
            ' \"pimsAPIType\": \"MANAGEORG\",'+
            ' \"pageObjectID\": \"con.id\",'+
            '  \"mobileNumber\": \"0419111000\"'+
            '}';
            
        String msRequest2 = '{'+
            '  \"userPid\": \"\",'+
            '  \"userFirstName\": \"Nikita\",'+
            '  \"userLastName\": \"Tiwa\",'+
            '  \"userEmail\": \"abc@telstra.com\",'+
            '  \"orgName\": \"abc\",'+
            '  \"isPDUA\": \"false\",'+
            '  \"isDeactivate\": \"false\",'+
            ' \"pimsAPIType\": \"MANAGEUSER\",'+
            ' \"pageObjectID\": \"con.id\",'+
            '  \"mobileNumber\": \"0419111000\"'+
            '}';
            
        //String pimsCallhandler = 'AMDOCS';
        //String token = AuthenticationManager.getOauthToken(pimsCallhandler); 
        //token = 'abcd1234';
        
        RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/ManageContactStatus';  
        req.httpMethod = 'GET';
        String reqBody =  '{'+
            '  \"userPid\": \"\",'+
            '  \"userFirstName\": \"Nikita\",'+
            '  \"userLastName\": \"Tiwa\",'+
            '  \"userEmail\": \"abc@telstra.com\",'+
            '  \"orgName\": \"abc\",'+
            '  \"isPDUA\": \"false\",'+
            '  \"isDeactivate\": \"false\",'+
            ' \"pimsAPIType\": \"MANAGEORG\",'+
            ' \"pageObjectID\": \"con.id\",'+
            '  \"mobileNumber\": \"0419111000\"'+
            '}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        HTTPResponse hres = new HTTPResponse();

        WrapperMSPIMSParams.WrapperPageParameters pageParams = ManagePIMSController.parsePageParams(msRequest);
        ContinuationController.WrapperState wrap = new ContinuationController.WrapperState();
       //wrap.request = req.requestURI;
        //wrap.pageParams = pageParams; 
        
        test.starttest();
        //ManagePIMSInterface.callPIMSMicroservice(msRequest,pimsCallhandler, HTTP_METHOD, payLoadURI,pageParams);
        //ManagePIMSInterface.callPIMSMicroservice(req.requestURI, pimsCallhandler, req.httpMethod, reqBody,pageParams);
        //ManagePIMSInterface.parsePIMSResponse(hres, wrap);
        ManagePIMSInterface.callPIMSMicroservice(JSON.serialize(msRequest),
                       'AMDOCS',
                       'POST',
                       con.LastName,
                       pageParams);
                   
        object result1=ManagePIMSInterface.callPIMSMicroservice(JSON.serialize(msRequest2),
                       'AMDOCS',
                       'POST',
                       con.LastName,
                       pageParams); 
        ManagePIMSInterface.inactivateUsers(new Set<string>{con.id});
        //ManagePIMSInterface.parseUserData();
       
        STring uniqueid=ManagePIMSInterface.generateUniqueId();
        //Map<String,String> mp = ManagePIMSInterface.getApiDefaults();
        test.stoptest();
        
      System.assert(null != uniqueid);

}
    }
}