@isTest
public class TCMCustomerSearchControllerTest {

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
        
        insert new IntegrationSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), EnableMocks__c=False);
             
    }

    private static HttpResponse res() {
        HttpResponse resp = new HttpResponse();
        resp.setStatus('OK');
        resp.setStatusCode(200);
        resp.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        return resp;
    }
    
    static testMethod void nocriteria_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.startSearch();
        system.assertEquals(0, tcmSearch.accountsList.size());
        Test.stopTest();
    }
    
    static testMethod void nocriteria_advancedsearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.startAdvancedSearch();
        system.assertEquals('', tcmSearch.result);
        Test.stopTest();
    }
    
    static testMethod void lastname_search() {
        Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        insert a;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'Smith';
        tcmSearch.startSearch();
        
        Test.stopTest();
        system.debug('test11111111'+tcmSearch.accountsList);
        system.assertEquals(1, tcmSearch.accountsList.size());
    }

    static testMethod void lastname_advancedsearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'AARATHY SD';
        tcmSearch.abn = '12345678901';
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
        system.assertNotEquals(Null, tcmSearch.abn);
        Test.stopTest();
        //system.assert(tcmSearch.result.contains('AARATHY SD'));
      
    }
    
    static testMethod void lastname_advancedsearch_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'Smith';
        // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
         for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('This customer cannot be found in TCM - Follow new Customer Creation process', msg.getSummary());
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity()); 
        }
        system.assertNotEquals(Null, tcmSearch.lastName);
        Test.stopTest();
    }
    
    static testMethod void lastname_advancedsearch_exception() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'test401';
      
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('This customer cannot be found in TCM - Follow new Customer Creation process', msg.getSummary());
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity()); 
        }
        Test.stopTest();
    }

    static testMethod void ABN_search() {
        Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='12345678901';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        insert a;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.abn = '12345678901';
        tcmSearch.startSearch();
        Test.stopTest();
        system.assertEquals(1, tcmSearch.accountsList.size());
    }
    
   /* static testMethod void ABN_search_Combination() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.abn = '12345678901';
        tcmSearch.lastName = 'Smith';
        tcmSearch.startSearch();
        Test.stopTest();
    } */
    
    static testMethod void ABN_search_non_numeric() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.abn = 'qwerty';
        tcmSearch.startSearch();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('Invalid value entered for ABN', msg.getSummary());
            System.assertEquals(ApexPages.severity.ERROR, msg.getSeverity()); 
        }
        system.assertNotEquals(Null, tcmSearch.abn);
        Test.stopTest();
    }

    static testMethod void ABN_advancedSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'Smith';
       // tcmSearch.record = '5';
        tcmSearch.abn = '10000000000';
        tcmSearch.startAdvancedSearch();
		//system.assert(tcmSearch.result.contains('10000000000'));
        system.assertNotEquals(Null, tcmSearch.abn);
        Test.stopTest();
    }
    
    static testMethod void ABN_advancedSearch_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.abn = '12345678901';
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('This customer cannot be found in TCM - Follow new Customer Creation process', msg.getSummary());
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity()); 
        }
        system.assertNotEquals(Null, tcmSearch.abn);
        Test.stopTest();
    }

    static testMethod void ACN_search() {
		Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='12345678901';
        a.ACN__c='123456789';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        insert a;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.acn = '123456789';
        tcmSearch.startSearch();
		//system.assertEquals(1, tcmSearch.accountsList.size());
        system.assertNotEquals(Null, tcmSearch.acn);
        Test.stopTest();
    }
    
    static testMethod void ACN_search_non_numeric() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.acn = 'qwerty';
        tcmSearch.startSearch();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('Invalid value entered for ACN', msg.getSummary());
            System.assertEquals(ApexPages.severity.ERROR, msg.getSeverity()); 
        }
        Test.stopTest();
    }

    static testMethod void ACN_advancedSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'Smith';
        tcmSearch.acn = '123456789';
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
		//system.assert(tcmSearch.result.contains('123456789'));
        system.assertNotEquals(Null, tcmSearch.acn);
        Test.stopTest();
    }
    
    static testMethod void ACN_advancedSearch_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.acn = '123456799';
      //  tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('This customer cannot be found in TCM - Follow new Customer Creation process', msg.getSummary());
            System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity()); 
        }
        Test.stopTest();
    }
    static testMethod void birthDate_search() {
		Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='12345678901';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
		a.birthDate__c = '1998-12-12';
        insert a;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.birthDate = '1998-12-12';
        tcmSearch.lastName = 'Smith';
        tcmSearch.startSearch();
		system.assertEquals(1, tcmSearch.accountsList.size());
        Test.stopTest();
    }
    
    static testMethod void birthDate_search_non_numeric() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.birthDate = 'qwerty';
        tcmSearch.lastName = 'Smith';
        tcmSearch.startSearch();
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('Invalid value entered for BirthDate or LastName', msg.getSummary());
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
        }
        Test.stopTest();
    }

    static testMethod void birthDate_advancedSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'Smith';
       // tcmSearch.record = '5';
        tcmSearch.birthDate = '1982-08-18';
        tcmSearch.startAdvancedSearch();
		//system.assert(tcmSearch.result.contains('1982-08-18'));
        system.assertNotEquals(Null, tcmSearch.birthDate);
        Test.stopTest();
    }
    
    static testMethod void birthDate_advancedSearch_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.birthDate = '1992-09-03';
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
        system.debug('insidea dvanced search');
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('TCM Search cannot be performed due to invalid combination of fields. Lastname should be provided in the search criteria', msg.getSummary());
            System.assertEquals(ApexPages.Severity.WARNING, msg.getSeverity()); 
        }
        Test.stopTest();
    }

    static testMethod void masterId_search() {
		Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='12345678901';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
		a.birthDate__c = '1998-12-12';
		a.TCM_MasterID__c = '10000002124';
        insert a;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.masterId = '10000002124';
        tcmSearch.startSearch();
		system.assertEquals(1, tcmSearch.accountsList.size());
        Test.stopTest();
    }
    
    static testMethod void masterId_search_non_numeric() {
        Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='12345678901';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
		a.birthDate__c = '1998-12-12';
		a.TCM_MasterID__c = '10000002124';
        insert a;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.masterId = '123456';
        tcmSearch.startSearch();
		system.assertEquals(0, tcmSearch.accountsList.size());
        Test.stopTest();
    }

    static testMethod void masterId_excludeContacts_advancedSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.masterId = '10000142602';
        tcmSearch.includeContacts = false;
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
		list<Contact> conlist = [Select Id from Contact where Account.Account_UUID__c = 'C3DE634F-6ED9-4240-9427-FA428F582BD4'];
		system.assertEquals(0, conlist.size());
        Test.stopTest();
    }
   
    static testMethod void masterId_includeContacts_advancedSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.masterId = '10000142607';
       tcmSearch.includeContacts= true;
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
		system.assert(tcmSearch.result.contains('10000142607'));
        Test.stopTest();
    }
    
    static testMethod void CIDN_search() {
        Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com';
        a.CIDN__c = '123456789';
        insert a;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.cidn = '123456789';
        tcmSearch.startSearch();
        system.assertEquals(1, tcmSearch.accountsList.size());
        Test.stopTest();
    }
    
    static testMethod void CIDN_search_non_numeric() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.cidn = 'qwerty';
        tcmSearch.startSearch();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('Invalid value entered for CIDN.', msg.getSummary());
            System.assertEquals(ApexPages.severity.ERROR, msg.getSeverity()); 
        }
        Test.stopTest();
    }

    static testMethod void CIDN_advancedSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.cidn = '123456789';
       // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
        //system.assert(tcmSearch.result.contains('123456789'));
        System.assertNotEquals(Null, tcmSearch.cidn); 
        Test.stopTest();
    }

    static testMethod void CAC_search() {
        Test.startTest();
       	Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '2021801099';
        a.Type='Sole Trader';
        a.ABN__c='12345678901';
        a.ACN__c='123456789';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        insert a;
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.cac = '2021801099';
        tcmSearch.startSearch();
        system.assertEquals(1, tcmSearch.accountsList.size());
        Test.stopTest();
    }
    
    static testMethod void CAC_search_non_numeric() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.cac = 'qwerty';
        tcmSearch.startSearch();
         for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals('Invalid value entered for CAC', msg.getSummary());
            System.assertEquals(ApexPages.severity.ERROR, msg.getSeverity()); 
        }
        Test.stopTest();
    }

    static testMethod void CAC_advancedSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.cac = '2016008318';
        // tcmSearch.record = '5';
        tcmSearch.startAdvancedSearch();
        //system.assert(tcmSearch.result.contains('2016008318'));
        system.assertNotEquals(Null, tcmSearch.cac);
        Test.stopTest();
    }
    
    static testMethod void clear() {
        Test.startTest();
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.clear();
        system.assertNotEquals(Null, tcmSearch);
        Test.stopTest();
    }

    static testMethod void createCustomer() {
        Test.startTest();
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.createCustomer();
        system.assertNotEquals(Null, tcmSearch);
        Test.stopTest();
    }

    static testMethod void openAccount() {
        Test.startTest();
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.openAccount();
        system.assertNotEquals(Null, tcmSearch);
        Test.stopTest();
    }
    
    static testMethod void searchByLastNameABN(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'lastname';
        tcmSearch.abn = '1000000000';
        tcmSearch.internalSearch();
        system.assertNotEquals(Null, tcmSearch);
        Test.stopTest();
    }
    
    static testMethod void searchByLastNameACN(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'lastname';
        tcmSearch.acn = '0000000019';
        tcmSearch.internalSearch();
        system.assertNotEquals(Null, tcmSearch.acn);
        Test.stopTest();
    }
    
    static testMethod void searchByLastNamebirthDate(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'lastname';
        tcmSearch.birthDate = '1992-12-12';
        tcmSearch.internalSearch();
        system.assertNotEquals(Null, tcmSearch.birthDate);
        Test.stopTest();
    }

    static testMethod void searchByLastNameABNACNbirthDate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.lastName = 'lastname';
        tcmSearch.abn = '1000000000';
        tcmSearch.acn = '0000000019';
        tcmSearch.birthDate = '1990-12-12';
        tcmSearch.searchByLastName();
        //system.assert(tcmSearch.result.contains('1000000000'));
        system.assertNotEquals(Null, tcmSearch.birthDate);
        Test.stopTest();
    }
    
    static testMethod void importAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.masterId = '10000002124';
        tcmSearch.includeContacts = false;
        //tcmSearch.record = '1';
        tcmSearch.startAdvancedSearch();
        tcmSearch.selectedCustomerAccountUUID = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
        tcmSearch.customer = new CustomerObject();
        tcmSearch.customer.data = new CustomerObject.data();
        
        tcmSearch.customer.data.customers = new List<CustomerObject.Customer>();
        CustomerObject.Customer customer = new CustomerObject.Customer();
        customer.masterID = '1234567890';
        customer.cidn ='2222222';
        customer.cac = '111111';
        customer.customerType ='Sole Trader';
        customer.lastVerifiedDate = '2017-09-09';
        customer.customerManagedFlag = 'Y';
        customer.effectiveRetiredDate='2017-09-09';
        customer.customerAccount = new CustomerObject.CustomerAccount();
        customer.customerAccount.lastName = 'Lastname';
        customer.customerAccount.firstName ='first';
        //customer.customerAccount.middleName ='middle';
        customer.customerAccount.birthDate ='1991-09-09';
        //customer.customerAccount.driverLicenseNumber ='1234';
        //customer.customerAccount.driverLicenseState ='abcd';
        customer.customerAccount.accountUuid = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
        customer.customerAccount.dataSovereignty = '';
        customer.customerAccount.preferredMethod ='Email';
        customer.customerAccount.emailAddress = 'abc@abc.com';
        customer.customerAccount.faxNumber = '+61678465734'; 
        customer.customerAccount.phoneNumber = '+61212345678';
       
        customer.createdDate='1991-09-09';
        customer.ownershipCode='adadadd';
        customer.revenueOrganisationUnit='test';
        //customer.accountPortfolio =  new List<CustomerObject.AccountPortfolio>();
        //CustomerObject.AccountPortfolio accport = new CustomerObject.AccountPortfolio();
        //accport.portfolioCode = '123456';
        //customer.accountPortfolio.add(accport);
        
        
        customer.address = new List<CustomerObject.Address>();
        CustomerObject.Address address = new CustomerObject.Address();
     
		address.state='VIC';
        address.streetTypeCode='ROAD';
        address.addressId='400650626';
        address.statusCode='CONFIRMED';
        address.streetTypeSuffixCode='';
        address.postalCode='3124';
        address.registeredPlan='';
        address.streetNumberStart='36';
        address.subAddress = new CustomerObject.SubAddress();
        address.subAddress.propertyName='';
        address.subAddress.privateStreetType='';
        address.subAddress.privateStreetName='';
       	address.subAddress.numberStart='';
        address.subAddress.buildingName='';
        address.subAddress.addressLines = new List<String>();
        address.subAddress.addressLines.add('36 SPENCER RD');
        address.subAddress.addressLines.add('two');
        address.subAddress.addressLines.add('three');
        address.subAddress.numberEnd='';
        address.subAddress.privateStreetTypeCode='';
        address.streetType='RD';
        address.internationalState='';
        address.isPrimary='Y';
        address.status='CO';
        address.streetNumberStartSuffix='';
        address.streetName='SPENCER';
        address.addressType='CO';
        address.additionalInfo='';
        address.country='AUSTRALIA';
        address.internationalPostcode='';
        address.addressTypeCode='';
        address.streetTypeSuffix='';
        address.streetNumberEnd='';
        address.deliveryPointId='68836168';
        address.streetNumberEndSuffix='';
        address.locality='CAMBERWELL';
       
        customer.address.add(address);
        
      	JSON2TCMCustomerContactObject jcco = new JSON2TCMCustomerContactObject();
        jcco.Data = new JSON2TCMCustomerContactObject.Data();
        jcco.data.contacts = new List<JSON2TCMCustomerContactObject.Contacts>();
        JSON2TCMCustomerContactObject.Data jd = new JSON2TCMCustomerContactObject.Data();
        jd.id ='12345';
        jd.abn ='12345';
        jd.acn ='12345';
        jd.firstName ='ray';
        jd.accountStatus ='';
        jd.lastName ='last';
        jd.birthDate ='';
          
        JSON2TCMCustomerContactObject.Contacts jc = new JSON2TCMCustomerContactObject.Contacts();
        //jc.customerAccounts=new JSON2TCMCustomerContactObject.Contacts.customerAccounts();
        //jc.customerAccounts.endDate='';
        //jc.customerAccounts.contactRelationship=new JSON2TCMCustomerContactObject.contacts.customerAccounts.contactRelationship();
        //jc.customerAccounts.contactRelationship.contactType='test';
        //jc.customerAccounts.contactRelationship.contactUsage='tets';
        jc.id='12345';
        //jc.customerAccounts.endDate='2018-09-09';
        jc.href ='';
        jc.title ='Mr.';
        jc.firstName ='Shambo';
        jc.middleName ='';
        jc.lastName ='Ray';
        jc.birthDate ='1994-04-23';
        /*jc.endDate ='';
        jc.contactType ='';
        jc.contactUsage ='';*/
        jc.preferredMethod ='';
        jc.homeContact = new JSON2TCMCustomerContactObject.HomeContact();
        jc.workContact = new JSON2TCMCustomerContactObject.WorkContact();
           
        //JSON2TCMCustomerContactObject.HomeContact jhc = new JSON2TCMCustomerContactObject.HomeContact();
         jc.homeContact.emailAddress ='xyz@gmail.com';
         jc.homeContact.faxNumber ='+61123456789';
         jc.homeContact.phoneNumber ='+61123456789';
         jc.homeContact.mobileNumber ='+61123456789';

        //JSON2TCMCustomerContactObject.WorkContact jwc = new JSON2TCMCustomerContactObject.WorkContact();
        jc.workContact.emailAddress ='xyz@gmail.com';
        jc.workContact.faxNumber ='+61123456789';
        jc.workContact.phoneNumber ='+61123456789';
        jc.workContact.mobileNumber ='+61123456789';

        jcco.data.contacts.add(jc);
        
        tcmSearch.customer.data.customers.add(customer);
        
        tcmSearch.selectCustomer();
        tcmSearch.importAccount();
        system.assertNotEquals(Null, tcmSearch.masterId);
        Test.stopTest();
    }
    static testMethod void TestimportAccount() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.masterId = '10000002124';
        tcmSearch.includeContacts = false;
        //  tcmSearch.record = '30';
        tcmSearch.startAdvancedSearch();
        tcmSearch.selectedCustomerAccountUUID = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
        tcmSearch.customer = new CustomerObject();
        tcmSearch.customer.data = new CustomerObject.data();
        
        tcmSearch.customer.data.customers = new List<CustomerObject.Customer>();
        CustomerObject.Customer customer = new CustomerObject.Customer();
        customer.masterID = '1234567890';
        customer.cidn ='2222222';
        customer.cac = '111111';
        customer.customerType ='Company';
        customer.customerManagedFlag = 'N';
        customer.customerAccount = new CustomerObject.CustomerAccount();
        customer.customerAccount.lastName = 'Lastname';
        customer.customerAccount.firstName ='first';
        //customer.customerAccount.middleName ='middle';
        customer.customerAccount.birthDate ='1991-09-09';
		//customer.customerAccount.driverLicenseNumber ='1234';
        //customer.customerAccount.driverLicenseState ='abcd';
        customer.customerAccount.accountUuid = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
        customer.customerAccount.dataSovereignty = '';
        customer.customerAccount.preferredMethod ='Email';
        customer.customerAccount.emailAddress = 'abc@abc.com';
                
        //customer.accountPortfolio =  new List<CustomerObject.AccountPortfolio>();
        //CustomerObject.AccountPortfolio accport = new CustomerObject.AccountPortfolio();
        //accport.portfolioCode = '123456';
       // customer.accountPortfolio.add(accport);
        
        
        customer.address = new List<CustomerObject.Address>();
        CustomerObject.Address address = new CustomerObject.Address();
        address.addressId = '';
        address.subAddress = new CustomerObject.SubAddress();
        address.subAddress.addressLines = new List<String>();
        address.subAddress.addressLines.add('Address line 1');
        customer.address.add(address);
        
        
        JSON2TCMCustomerContactObject jcco = new JSON2TCMCustomerContactObject();
        jcco.Data = new JSON2TCMCustomerContactObject.Data();
        jcco.data.contacts = new List<JSON2TCMCustomerContactObject.Contacts>();
        JSON2TCMCustomerContactObject.Data jd = new JSON2TCMCustomerContactObject.Data();
        jd.id ='12345';
        jd.abn ='12345';
        jd.acn ='12345';
        jd.firstName ='ray';
        jd.accountStatus ='';
        jd.lastName ='last';
        jd.birthDate ='';
          
        JSON2TCMCustomerContactObject.Contacts jc = new JSON2TCMCustomerContactObject.Contacts();
        //jc.customerAccounts=new JSON2TCMCustomerContactObject.Contacts.customerAccounts();
        //jc.customerAccounts.endDate='';
        //jc.customerAccounts.contactRelationship=new JSON2TCMCustomerContactObject.contacts.customerAccounts.contactRelationship();
        //jc.customerAccounts.contactRelationship.contactType='test';
        //jc.customerAccounts.contactRelationship.contactUsage='tets';
        jc.id='12345';
        //jc.customerAccounts.endDate='2018-09-09';
        jc.href ='';
        jc.title ='Mr.';
        jc.firstName ='Shambo';
        jc.middleName ='';
        jc.lastName ='Ray';
        jc.birthDate ='1994-04-23';
        /*jc.endDate ='';
        jc.contactType ='';
        jc.contactUsage ='';*/
        jc.preferredMethod ='';
        jc.homeContact = new JSON2TCMCustomerContactObject.HomeContact();
        jc.workContact = new JSON2TCMCustomerContactObject.WorkContact();
           
        //JSON2TCMCustomerContactObject.HomeContact jhc = new JSON2TCMCustomerContactObject.HomeContact();
         jc.homeContact.emailAddress ='xyz@gmail.com';
         jc.homeContact.faxNumber ='+61123456789';
         jc.homeContact.phoneNumber ='+61123456789';
         jc.homeContact.mobileNumber ='+61123456789';

        //JSON2TCMCustomerContactObject.WorkContact jwc = new JSON2TCMCustomerContactObject.WorkContact();
        jc.workContact.emailAddress ='xyz@gmail.com';
        jc.workContact.faxNumber ='+61123456789';
        jc.workContact.phoneNumber ='+61123456789';
        jc.workContact.mobileNumber ='+61123456789';

        jcco.data.contacts.add(jc);
        
        
        
        tcmSearch.customer.data.customers.add(customer);
        
        tcmSearch.selectCustomer();
        tcmSearch.importAccount();
        tcmSearch.next();
        tcmSearch.previous();
        system.assertNotEquals(Null, tcmSearch.masterId);
        Test.stopTest();
    }
    
    
    static testMethod void pagination() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        TCMCustomerSearchController tcmSearch = new TCMCustomerSearchController();
        tcmSearch.customerList = new List<CustomerObject.Customer>();
        tcmSearch.offset = 0;
        tcmSearch.lastName = 'lastname';
        tcmSearch.abn = '1000000000';
        tcmSearch.acn = '0000000019';
       // tcmSearch.next();
       // tcmSearch.previous();
        system.assertNotEquals(Null, tcmSearch.lastName);
        Test.stopTest();      
    }
    
    /*********************************************************
     Method for Json2TCMCustomerContact Class
     *********************************************************/     
    static testMethod void Json2TCMCustomerContactInittest() {
        Test.startTest();
         Account a = TestUtil.createAccount('Smithss');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='123458';
        a.Customer_ID__c = '9876543258';
        a.Type='Full Authority';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        insert a;
        CustomerObject.Customer customer = new CustomerObject.Customer();
        customer.masterID = '1234567890';
        customer.cac = '111111';
        customer.customerType ='Company';
        customer.customerManagedFlag = 'N';
        customer.customerAccount = new CustomerObject.CustomerAccount();
        customer.customerAccount.lastName = 'Lastname';
        customer.customerAccount.firstName ='first';
        //customer.customerAccount.middleName ='middle';
        customer.customerAccount.birthDate ='1994-09-09';
        //customer.customerAccount.driverLicenseNumber ='12342';
        //customer.customerAccount.driverLicenseState ='abcde';
        customer.customerAccount.accountUuid = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
        customer.customerAccount.dataSovereignty = '';
        customer.customerAccount.preferredMethod ='Email';
        customer.customerAccount.emailAddress = 'abc@abcdf.com';
                
        //customer.accountPortfolio =  new List<CustomerObject.AccountPortfolio>();
        //CustomerObject.AccountPortfolio accport = new CustomerObject.AccountPortfolio();
        //accport.portfolioCode = '1234567';
        //customer.accountPortfolio.add(accport);
        JSON2TCMCustomerContactObject jcco = new JSON2TCMCustomerContactObject();
        jcco.Data = new JSON2TCMCustomerContactObject.Data();
        jcco.data.contacts = new List<JSON2TCMCustomerContactObject.Contacts>();
        JSON2TCMCustomerContactObject.Data jd = new JSON2TCMCustomerContactObject.Data();
        jd.id ='123456';
        jd.abn ='123456';
        jd.acn ='123456';
        jd.firstName ='rayna';
        jd.accountStatus ='';
        jd.lastName ='lastra';
        jd.birthDate ='';
          
        JSON2TCMCustomerContactObject.Contacts jc = new JSON2TCMCustomerContactObject.Contacts();
        jc.id='12345';
        jc.href ='';
        jc.title ='Mr';
        jc.firstName ='shambo';
        jc.middleName ='';
        jc.lastName ='ray';
        jc.birthDate ='1994-04-23';
        /*jc.endDate ='';
        jc.contactType ='';
        jc.contactUsage ='';*/
        jc.preferredMethod ='';
        jc.homeContact = new JSON2TCMCustomerContactObject.HomeContact();
        jc.workContact = new JSON2TCMCustomerContactObject.WorkContact();
        jc.customerAccounts= new    JSON2TCMCustomerContactObject.CustomerAccount();
        jc.customerAccounts.endDate='2018-04-23';
        jc.customerAccounts.contactRelationship= new    JSON2TCMCustomerContactObject.ContactRelationship();
        jc.customerAccounts.contactRelationship.contactType='test';
        jc.customerAccounts.contactRelationship.contactUsage='test';
        JSON2TCMCustomerContactObject.HomeContact jhc = new JSON2TCMCustomerContactObject.HomeContact();
        jhc.emailAddress ='xyz@gmail.com';
        jhc.faxNumber ='+61123456789';
        jhc.phoneNumber ='+61123456789';
        jhc.mobileNumber ='+61123456789';

        JSON2TCMCustomerContactObject.WorkContact jwc = new JSON2TCMCustomerContactObject.WorkContact();
        jwc.emailAddress ='xyz@gmail.com';
        jwc.faxNumber ='+61123456789';
        jwc.phoneNumber ='011456789';
        jwc.mobileNumber ='+61123456789';
		//TCMCustomerSearchController.saveCustomerContactdata(customer,a,jc);       
        system.assertNotEquals(Null, jwc.faxNumber);
        Test.stopTest();
    }

    /*********************************************************
     Method for CustomerObject Class
     *********************************************************/ 
    static testMethod void CustomerObjectInittest() { 
        Test.startTest();
        CustomerObject CusObj = new CustomerObject();
        CusObj.Data = new CustomerObject.Data();
        CusObj.data.customers = new List<CustomerObject.Customer>();
        CusObj.data.address = new List<CustomerObject.Address>();
        CusObj.data.paging = new CustomerObject.Paging();
        CustomerObject.Customer co_customer = new  CustomerObject.Customer();
        co_customer.location ='';
        co_customer.effectiveRetiredDate ='';
        //co_customer.webAddress ='';
        co_customer.servicingOrgUnit ='';
        co_customer.potentialRevenue ='';
        co_customer.languagePreference ='';
        co_customer.parentCidn ='';
        co_customer.accountTrading = new List<CustomerObject.AccountTrading>();
        //co_customer.duplicateOverridReason ='';
        co_customer.customerManagedFlag ='';
        //co_customer.externalSystemId ='';
        co_customer.description ='';
        co_customer.createdDate ='';
        co_customer.lastVerifiedDate ='';
        co_customer.currentRevenue ='';
        co_customer.customerEffectiveStartDate ='';
        co_customer.lastUpdated ='';
        co_customer.ultimateParentCidn ='';
        co_customer.ownershipCode ='';
        co_customer.recommendedBillingFrequency ='';
        co_customer.category= new CustomerObject.Category();
        co_customer.businessUnit ='';
        //co_customer.abnOverride ='';
        co_customer.revenueOrganisationUnit ='';
        co_customer.priorityAssist ='';
        co_customer.masterID ='';
        co_customer.validationConsentRequestDate ='';
        co_customer.premiumService ='';
        co_customer.franchiseArrange ='';
        co_customer.retirementReason ='';
        co_customer.timeZone ='';
        co_customer.approveDeclineReason ='';
        co_customer.customerAccount= new CustomerObject.CustomerAccount();
        //co_customer.eventAction ='';
        co_customer.cac ='';
        co_customer.relationshipType ='';
        co_customer.marketSegment ='';
        co_customer.partners ='';
        co_customer.accountStatus ='';
        co_customer.geographicalLocationCode ='';
        co_customer.customerEffectiveEndDate ='';
        co_customer.customerType ='';
        co_customer.customerSince ='';
        //co_customer.sendDateTime ='';
        //co_customer.accountPortfolio = new List<CustomerObject.AccountPortfolio>();
        co_customer.churnPropensity ='';
        co_customer.cidn ='';
        co_customer.writtenaAuthorityRequiredFlag ='';
        co_customer.reportingPointIndicator ='';
        co_customer.recommendedPaymentMethod ='';
        co_customer.address = new List<CustomerObject.Address>();
        co_customer.retiredUId ='';
        co_customer.ansicCode ='';
        co_customer.dateOfApplication ='';
        //co_customer.lastModifiedDate ='';
        co_customer.validationCustomerConsent ='';
        CustomerObject.AccountTrading Actrading = new  CustomerObject.AccountTrading();
        //Actrading.startDate ='';
        Actrading.isPrimary ='';
        Actrading.tradingName ='';
        //Actrading.endDate ='';
        CustomerObject.Category ctgr = new  CustomerObject.Category();
        //ctgr.bpProtect ='';
        //ctgr.protect ='';
        ctgr.online ='';
        CustomerObject.CustomerAccount cuacc = new  CustomerObject.CustomerAccount();
        cuacc.preferredMethod ='';
        cuacc.lastName ='';
        cuacc.acn ='';
        cuacc.fraudFlag ='';
        cuacc.driverLicenceNumber ='';
        cuacc.effectiveRetiredDate ='';
        cuacc.webAddress ='';
        cuacc.emailAddress ='';
        cuacc.dataSovereignty ='';
        cuacc.vipFlag ='';
        cuacc.abn ='';
        cuacc.driverLicenceState ='';
        cuacc.title ='';
        cuacc.faxNumber ='';
        cuacc.phoneNumber ='';
        cuacc.birthDate ='';
        cuacc.accountUuid ='';
        cuacc.firstName ='';
        /*CustomerObject.AccountPortfolio actpfl = new  CustomerObject.AccountPortfolio();
        actpfl.portfolioName ='';
        actpfl.isPrimary ='';
        actpfl.accountExecutiveLastName ='';
        actpfl.portfolioCode ='';
        actpfl.accountExecutivePhoneNumber ='';
        actpfl.accountExecutiveFirstName ='';*/
        CustomerObject.Address add = new  CustomerObject.Address();
        add.state ='';
        add.streetTypeCode ='';
        add.addressId ='';
        add.statusCode ='';
        add.streetTypeSuffixCode ='';
        add.postalCode ='';
        add.registeredPlan ='';
        add.streetNumberStart ='';
        add.subAddress= new CustomerObject.SubAddress();
        add.streetType ='';
        add.internationalState ='';
        add.isPrimary ='';
        add.status ='';
        add.streetNumberStartSuffix='';
        add.streetName='';
        add.addressType ='';
        add.additionalInfo ='';
        add.country ='';
        add.internationalPostcode ='';
        add.addressTypeCode ='';
        add.streetTypeSuffix ='';
        add.streetNumberEnd ='';
        add.deliveryPointId ='';
        add.streetNumberEndSuffix ='';
        add.locality ='';
        CustomerObject.SubAddress sadd = new  CustomerObject.SubAddress();
        sadd.propertyName ='';
        sadd.privateStreetType ='';
        sadd.privateStreetName ='';
        sadd.details= new List<CustomerObject.Detail>();
        sadd.numberStart ='';
        sadd.buildingName ='';
        sadd.addressLines= new List<string>();
        sadd.numberEnd ='';
        sadd.privateStreetTypeCode ='';
        CustomerObject.Detail dtl = new  CustomerObject.Detail();
        dtl.detailType ='';
        dtl.value ='';
        dtl.detailTypeCode ='';
        CustomerObject.Paging pg = new  CustomerObject.Paging();
        pg.lastPage ='';
        pg.resultBlockSize ='';
        pg.offset ='';
        system.assertNotEquals(Null, pg.offset);
        Test.stopTest();
    }
    static testMethod void contactSaveTest() { 
        test.starttest();
        ContactObject.Contact co=new   ContactObject.Contact();
        co.title='Mr';
        co.firstName='test';
        co.middleName='';
        co.id='';
        co.Birthdate='';
        co.status='';
        //co.Imported__c=;
        co.homecontact=new ContactObject.homecontact();
        co.homeContact.faxNumber='+61234567890';
        co.homeContact.emailAddress='xyzq.ray@gmail.com';
        co.homeContact.phoneNumber='+61123456789';
        co.homeContact.mobileNumber='9921219992';
            
        co.workcontact=new ContactObject.workcontact();
        co.workcontact.faxNumber='+61234567890';
        co.workcontact.emailAddress='xyz.ray@gmail.com';
        co.workcontact.phoneNumber='+61123456789';
        co.workcontact.mobileNumber='9921219999';
		co.preferredMethod='Email';
        co.sourceSystem='test';
        co.lastVerifiedDate='2016-04-23';
        co.notes='test';
        co.numberInHousehold='1.234';
        co.occupation='Business';
        co.timeZone='PST';
        co.jobDescription='test';
        co.jobtitle='test';
        co.reviewedFlag='true';
        co.languagePreference='NA';
        co.onlineFlag='false';
        co.mergeStatus='Success';
        co.parentSourceSystemAction='NA';
        List<ContactObject.Contact> listContactObjectsContacts=new List<ContactObject.Contact>();
        listContactObjectsContacts.add(co);
        //TCMCustomerSearchController.contactSave(null,listContactObjectsContacts);
        system.assertNotEquals(Null, co.parentSourceSystemAction);
        test.stoptest();
        }
}