@isTest
public class CustomerCreationControllerTest {
    
    @testSetup 
	static void setup() {
		EnvironmentVariable.put('tcm_access_token', '1234');
		EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6');
        EnvironmentVariable.put('okapi_east_url', '/v2/address-search/addresses?');
		EnvironmentVariable.put('okapi_client_id', '1234');
		EnvironmentVariable.put('okapi_client_secret', '1234');
		EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
	}
	
	static testMethod void createCustomerSuccessWithResult() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        CustomerCreationController custCont = new CustomerCreationController();
        
        Account acc = TestUtil.createAccount('My account');
        acc.ABN__c = '12345';
        acc.ACN__c = '12345';
        
        custCont.account = acc;
        custCont.getAccount();

        custCont.contact = TestUtil.createContact('first', 'last');
        custCont.getContact();
        
    	custCont.searchString = '95 richmond';
        custCont.runSearch();
        
        custCont.selectedBillingAddressId = '240088459';
        custCont.selectBillingAddress();
        custcont.copyAddress = false;
        custCont.copyTheAddress();
        
        custCont.selectedMailingAddressId = '240088459';
        custCont.selectBillingAddress();
        custCont.selectMailingAddress();
        custcont.copyAddress = true;
        custCont.copyTheAddress();
        
        custCont.createCustomer();
        custCont.validateABN();
        custCont.validateACN();
        System.assertEquals( (custCont.contact !=null), true, 'msg');
        Test.stopTest();
    }
    
    static testMethod void createCustomerUnsuccessfulWithoutresult() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        CustomerCreationController custCont = new CustomerCreationController();
        
        Account acc = TestUtil.createAccount('My account');
        acc.ABN__c = '12345';
        acc.ACN__c = '12345';
        
        custCont.getAccount();
        custCont.account = acc;
        custCont.getAccount();

        custCont.getContact();
        custCont.contact = TestUtil.createContact('first', 'last');
        custCont.getContact();
        
    	custCont.searchString = 'exception';
        custCont.runSearch();
        
        custCont.selectedBillingAddressId = '240088459';
        custCont.selectBillingAddress();
        custcont.copyAddress = false;
        custCont.copyTheAddress();
        
        custCont.selectedMailingAddressId = '240088459';
        custCont.selectMailingAddress();
        custcont.copyAddress = true;
        custCont.copyTheAddress();
        
        custCont.createCustomer();
        custCont.validateABN();
        custCont.validateACN();
        System.assertEquals( (custCont.contact !=null), true, 'msg');
        Test.stopTest();
    }

}