/*
 * Description: Test class for EASTAddressSearchController
 * Author: Sooraj George
 * Date: 4-Aug-2016
 * */
@isTest
public class EASTAddressSearchControllerTest {
    
   // private static String searchURL = '/v1/address-search/addresses?';
   	private Id aid;
    
    @testSetup 
	static void setup() {
		EnvironmentVariable.put('tcm_access_token', '1234');
		EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6');
        EnvironmentVariable.put('okapi_east_url', '/v2/address-search/addresses?');
		EnvironmentVariable.put('okapi_client_id', '1234');
		EnvironmentVariable.put('okapi_client_secret', '1234');
		EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
	}
	
    
    static testMethod void testToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        EASTAddressSearchController east = new EASTAddressSearchController();
        String token = EASTAddressSearchController.getToken(EnvironmentVariable.get('okapi_token_url'));
        System.assert(token == 'lFYpKM2LkokcsbzQFKfsMTiPeFcA');
        Test.stopTest();
    }

    static testMethod void testGetAddresses() {
        Test.startTest();
        EASTAddressSearchController east = new EASTAddressSearchController();
       
    	east.setsearchString('95 richmond');
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        east.runSearch();
        east.setselectedId('240088459');
        east.getselectedAddress();
        east.selectRow();
        
        Account a = TestUtil.createAccount('Test Account');
        insert a;
        east.objId = a.Id;
        east.objType = 'account';
        east.saveAddress();
        system.assert(east != null);
        Test.stopTest();
       
    }

}