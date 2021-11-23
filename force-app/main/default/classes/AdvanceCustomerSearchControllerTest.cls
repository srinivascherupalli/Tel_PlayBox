/****************************************************************************
@Author: Nilesh Dethe
@CreateDate: 08/08/2018
@Story: EDGE-31363
@Description: Test coverage class for AdvanceCustomerSearchController server side controller of AdvanceCustomerSearch lightning component which is created under EDGE-31363.
@Covering Class: AdvanceCustomerSearchController
@ChangeLog: v1: Created
********************************************************************************/
@isTest(seeAllData=false)
public class AdvanceCustomerSearchControllerTest {
	//EDGE-31363  
    @testSetup static void setup() {
        Test.loadData(Account.sObjectType, 'CustomerSearchAccounts');
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
        
        Control_Manage_Invocation__c cmi = new Control_Manage_Invocation__c();
        cmi.Name ='GetContactInfo';
        cmi.GetContactInfo__c = True;
        insert cmi;
    }
    
    //EDGE-31363
    private static HttpResponse res() {
        HttpResponse resp = new HttpResponse();
        resp.setStatus('OK');
        resp.setStatusCode(200);
        resp.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        return resp;
    }
	
    //EDGE-31363
    private static string getSearchCriteria(string inputCustName, string inputAbn, string inputAcn, string inputCidn){
        return '{"customerName" : "'+inputCustName +'","abn" : "'+ inputAbn+'","acn" : "'+ inputAcn+'","cidn" : "'+inputCidn+'"}';
    }    
    
    //EDGE-31363
    static testMethod void searchCustomerInSFDCTest(){
        Test.startTest();
        //Verify that the accounts are getting created
        system.assert([SELECT Count() FROM Account]>0);
        
        //Verify search customer by cutomer name - positive case
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCustNameResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('Test Acc1','','',''));
        system.assert(!searchByCustNameResponse.lstCustomer.isEmpty());
        
        //Verify search customer by ABN only
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByABNResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('','10000000000','',''));
        system.assert(!searchByABNResponse.lstCustomer.isEmpty());
        
        //Verify search customer by ACN only
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByACNResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('','','879765256',''));
        system.assert(!searchByACNResponse.lstCustomer.isEmpty());
        
        //Verify search customer by ACN only
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCIDNResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('','','','12345678'));
        system.assert(!searchByCIDNResponse.lstCustomer.isEmpty());
        
        //Verify search customer by Customer Name and ABN 
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCustNameAndABNRes = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('Test Acc2','10000000000','',''));
        system.assert(!searchByCustNameAndABNRes.lstCustomer.isEmpty());
        
        //Verify search customer by Customer Name and ACN 
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCustNameAndACNRes = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('Test Acc1','','879765256',''));
        system.assert(!searchByCustNameAndACNRes.lstCustomer.isEmpty());
        
        Test.stopTest();
    }
    
    //EDGE-31363
    static testMethod void searchCustomerInTCMTest(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        //Verify search customer by cutomer name - positive case
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCustNameResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('Smith','','',''));
        system.assert(!searchByCustNameResponse.lstCustomer.isEmpty());
        
        //Verify search customer by ABN only
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByABNResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('','10000000000','',''));
        system.assert(!searchByABNResponse.lstCustomer.isEmpty());
        
        //Verify search customer by ACN only
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByACNResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('','','123456',''));
        system.assert(!searchByACNResponse.lstCustomer.isEmpty());
        
        //Verify search customer by CIDN only
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCIDNResponse = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('','','','3891261368'));
        system.assert(!searchByCIDNResponse.lstCustomer.isEmpty());
        
        //Verify search customer by Customer Name and ABN 
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCustNameAndABNRes = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('abc','10000000000','',''));
        system.assert(!searchByCustNameAndABNRes.lstCustomer.isEmpty());
        
        //Verify search customer by Customer Name and ACN 
        AdvanceCustomerSearchController.CustomerPagerWrapper searchByCustNameAndACNRes = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('abc','','123456',''));
        system.assert(!searchByCustNameAndACNRes.lstCustomer.isEmpty());
        
        //Verify search customer TCM exceptions
        AdvanceCustomerSearchController.CustomerPagerWrapper searchCustException = AdvanceCustomerSearchController.searchCustomer(1.0, 5, getSearchCriteria('78106902','','649410310064160616',''));
        system.assert(!searchCustException.lstCustomer.isEmpty());
        
        //EDGE-32689: Test coverage for createCase method.
        AdvanceCustomerSearchController.createCase(JSON.serialize(searchByCustNameResponse.lstCustomer));
        //system.assert([SELECT count() FROM Case] > 0);
    }
    
    static testmethod void loggedInAsSysAdminTest(){
        Boolean isSysAdmin = AdvanceCustomerSearchController.loggedInAsSysAdmin();
        system.assert(isSysAdmin);
    }
}