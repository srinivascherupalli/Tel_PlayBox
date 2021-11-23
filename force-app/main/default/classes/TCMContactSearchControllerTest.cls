@isTest
public class TCMContactSearchControllerTest {
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
    
    static testMethod void search1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMContactSearchController tcmSearch = new TCMContactSearchController();
        tcmSearch.lastName = 'Bourne';
        tcmSearch.firstName = 'Jason';
        tcmSearch.birthDate = '11-11-1981';
        tcmSearch.startSearch();
        System.assertEquals( tcmSearch.lastName,'Bourne','Search' );
        Test.stopTest();
    }
    
    static testMethod void search1_noresult() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMContactSearchController tcmSearch = new TCMContactSearchController();
        tcmSearch.lastName = 'Void';
        tcmSearch.firstName = 'Jason';
        tcmSearch.birthDate = '11-11-1981';
        tcmSearch.startSearch();
        System.assertEquals( tcmSearch.lastName,'Void','Search' );
        Test.stopTest();
    }
    
    static testMethod void search2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMContactSearchController tcmSearch = new TCMContactSearchController();
        tcmSearch.lastName = 'Bourne';
        tcmSearch.firstName = 'Jason';
        tcmSearch.emailAddress = 'jason.bourne@gmail.com';
        System.assertEquals( tcmSearch.lastName,'Bourne','Search' );
        tcmSearch.startSearch();
        Test.stopTest();
    }
    
    static testMethod void search2_noresult() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMContactSearchController tcmSearch = new TCMContactSearchController();
        tcmSearch.lastName = 'Void';
        tcmSearch.firstName = 'Jason';
        tcmSearch.emailAddress = 'jason.void@gmail.com';
        tcmSearch.startSearch();
        System.assertEquals( tcmSearch.lastName,'Void','Search' );
        Test.stopTest();
    }
    
    static testMethod void search3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMContactSearchController tcmSearch = new TCMContactSearchController();
        tcmSearch.uuid = '1234567890';
        tcmSearch.requestLabel = '';
        tcmSearch.startSearch();
        System.assertEquals( tcmSearch.uuid,'1234567890','Search' );
        Test.stopTest();
    }
    
    static testMethod void next() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMContactSearchController tcmSearch = new TCMContactSearchController();
        tcmSearch.contactCustomers = new JSON2TCMContactCustomerObject();
        tcmSearch.next();
        System.assertEquals( tcmSearch.contactCustomers!=null, true,'Contacts');
        Test.stopTest();
    }
    
    static testMethod void previous() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMContactSearchController tcmSearch = new TCMContactSearchController();
        tcmSearch.contacts = new ContactObject();
        tcmSearch.previous();
        System.assertEquals( tcmSearch.contacts!=null, true,'Contacts');
        Test.stopTest();
    }
}