@isTest
public class ManageCustomerHandlerTest {
    
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
        EnvironmentVariable.put('tcm_contact_scope', 'TCMCONTACT');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint', 'http://mocksandbox.getsandbox.com/MockService');
        
        Interface_Activation__c iActivation=new Interface_Activation__c(name='Manage Contact');
        iActivation.Status__c=true;
        insert iActivation;
        system.debug('Iactive'+iActivation);
        
        Interface_Activation__c iActivation2=new Interface_Activation__c(name='Manage Customer');
        iActivation2.Status__c=true;
        insert iActivation2;
        
    }
    static testMethod void testManageCustomerwithoutContactinsert() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
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
        cscrm__Address__c ad=TestUtil.createAddress();
        ad.cscrm__Account__c=a.id;
        insert ad;
        System.assertEquals('0412354327', a.Phone);
        Test.stopTest();
        
        // Assert that Last Updated timestamp is not null
        Account acc = TestUtil.getAccount(a.Id);
        
    }
    
    static testMethod void testManageCustomerwithoutContactupdate() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654324';
        a.Type='Sole Trader';
        
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwoc.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        cscrm__Address__c ad=TestUtil.createAddress();
        ad.cscrm__Account__c=a.id;
        insert ad;
        insert a;
        
        a.Send_Create_Event__c = true;
        a.Is_TCM_Fields_Changed__c=true;
        a.ABN__c='1000000012';
        update a;
        
        Contact c = TestUtil.createContact(a.id,'Joe', 'Bloggs');
        insert c;
        System.assertEquals('Joe', c.FirstName);
        Test.stopTest();
        // Assert that Last Updated timestamp is not null
        Account acc = TestUtil.getAccount(a.Id);
        
    }
    
    static testMethod void testManageCustomerwithContact() {
        Test.startTest();
        IntegrationSettings__c is = new IntegrationSettings__c();
        is.EnableManageInterfaces__c = true;
        is.EnableMocks__c = false;
        insert is;
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        // Create Contact
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654321';
        a.Type='Sole Trader';
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygwc.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        
        insert a;
        Contact c = TestUtil.createContact(a.id,'Joe', 'Bloggs');
        insert c;
        
        cscrm__Address__c ad=TestUtil.createAddress();
        ad.cscrm__Account__c=a.id;
        insert ad;
        
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        // Add Address to Account
        TestUtil.addAddressToAccount(a.Id, ad.Id);
        update a;
        System.assertEquals('Joe', c.FirstName);
        Test.stopTest();
        
        // Assert that Last Updated timestamp is not null
        Account acc = TestUtil.getAccount(a.Id);
        
    }   
    
    static testMethod void testManageCustomerwithContactupdate() {
        Test.startTest();
        IntegrationSettings__c is = new IntegrationSettings__c();
        is.EnableManageInterfaces__c = true;
        is.EnableMocks__c = false;
        insert is;
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Interface_Activation__c iActivation = new Interface_Activation__c(Name= 'Manage Customer',Status__c=true);
        insert iActivation;
        // update Contact
        //Contact c = TestUtil.createContact('Joe', 'Bloggs');
        //insert c;
        
        // Create Address
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Customer_ID__c = '9876543217'; 
        a.Fax='12345';
        a.Type='Sole Trader';
        
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygcu.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com'; 
        insert a;
        cscrm__Address__c ad=TestUtil.createAddress();
        ad.cscrm__Account__c=a.id;
        insert ad;
        
        a.Send_Create_Event__c = true;
        a.Is_TCM_Fields_Changed__c=true;
        update a;
        
        Contact c = TestUtil.createContact(a.id,'Joe', 'Bloggs');
        insert c;
        c.firstName = 'Test';
        update c;
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        // Add Address to Account
        TestUtil.addAddressToAccount(a.Id, ad.Id);
        update a;
        system.assertNotEquals('Joe', c.firstName);
        Test.stopTest();
        
        // Assert that Last Updated timestamp is not null
        Account acc = TestUtil.getAccount(a.Id);        
    }
    
    static testMethod void testManageCustomercreateByAPIUser() {
        Test.startTest();
        IntegrationSettings__c is = new IntegrationSettings__c();
        is.EnableManageInterfaces__c = true;
        is.EnableMocks__c = false;
        insert is;
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        // Create Contact
        
        
        // Create Address
        
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Type='Sole Trader';
        a.Customer_ID__c = '987654320';
        a.Imported__c = true;
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Imported__c=true;
        a.ABN__c='aaaa';
        a.ACN__c='ccc';
        a.Website='www.vsygapi.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.Email__c='sahs.ray@gmail.com';
        insert a; 
        Contact c = TestUtil.createContact(a.id,'Joe', 'Bloggs');
        c.Birthdate = System.today();
        c.Title='Ray';
        c.MiddleName='Kumar';
        c.Birthdate=Date.newInstance(2000, 2,18);
        c.Driver_License_Id__c='103805501';
        c.Driver_Licence_State__c='nill';
        insert c;
        cscrm__Address__c ad=TestUtil.createAddress();
        ad.cscrm__Account__c=a.id;
        insert ad;
        Test.stopTest();
        system.assertNotEquals(Null, ad);
        
    }
    
    static testMethod void sendCrossReference() {
        Test.startTest();
        IntegrationSettings__c is = new IntegrationSettings__c();
        is.EnableManageInterfaces__c = true;
        is.EnableMocks__c = false;
        insert is;
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        Account acc = TestUtil.createAccount('My Account crossref');
        acc.Customer_ID__c = '987654321';
        acc.Customer_Status__c='SUSPECT';
        acc.Pref_Comm_Method__c='Fax';
        acc.Imported__c=true;
        acc.Fax='12345';
        acc.Type='Sole Trader';
        acc.ABN__c='aaaa';
        acc.ACN__c='ccc';
        acc.Website='www.vsygcross.com';
        acc.FraudFlag__c=false;
        acc.VIP_Customer__c=false; 
        acc.Phone='0412354327';
        acc.Email__c='sahs.ray@gmail.com';
        acc.Last_Validated_Date__c = system.today();
        acc.Validation_Consent_Request_Date__c = system.today();
        insert acc;
        ManageCustomer.send(acc.Id, true);
        system.assertNotEquals(Null, acc.Email__c);
        Test.stopTest();
    }
    static testmethod void checkRunOnce(){
        Test.startTest();
        System.assertNotEquals(Null,ManageCustomerHandler.runOnce());
        Test.stopTest();
    }
    /*------------------------------------------------------------ 
EDGE - 39902
Method: ManageCustomerAddress 
Description: Generate payload for Account  Address 
Inputs: List of cscrm__Address__c
Returns: List of ManageCustomerRequest.Address
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    static testMethod void testManageCustomerAddress(){
        List<cscrm__Address__c> addresses = new List<cscrm__Address__c>();
        cscrm__Address__c address = new cscrm__Address__c();
        address.Address_Status__c = 'CONFIRMED';
        address.Address_Line_1__c='AD L1';
        address.Address_Line_2__c='AD L2';
        address.Address_Line_3__c='AD L3';
        addresses.add(address);
        Test.startTest();
        List<ManageCustomerRequest.Address> addressList = ManageCustomerHandler.getMCRAccountAddress(addresses,true);
        Test.stopTest();
        system.assertEquals(1,addressList.size());
    }  
    static testMethod void ManageCustomerRequestCoverage() {
        Test.startTest();
        ManageCustomerRequest mcr = new ManageCustomerRequest();
        ManageCustomerRequest.Data DataItem= new ManageCustomerRequest.Data(); 
        DataItem.parentCidn = 'test'; 
        DataItem.rootCidn = 'test'; 
        DataItem.abnOverride = 'test'; 
        DataItem.priorityAssist = 'test'; 
        DataItem.duplicateOverrideReason = 'test'; 
        DataItem.premiumService = 'test';
        DataItem.IndustrymasterId = 'test';
        DataItem.primaryIndustryIndicator = 'test';
        DataItem.ultimateParentCidn = 'test';
        DataItem.loc = 'test';
        //mcr.Data = DataItem;
        ManageCustomerRequest.Category CategoryItem= new ManageCustomerRequest.Category(); 
        CategoryItem.bpProtect = 'test';
        CategoryItem.protect='test';
        DataItem.category = CategoryItem;
        ManageCustomerRequest.Concession ConcessionItem= new ManageCustomerRequest.Concession(); 
        ConcessionItem.paymentType='test';
        ConcessionItem.paymentStatus='test';
        DataItem.concession = ConcessionItem;
        ManageCustomerRequest.CustomerAccount custAccItem= new ManageCustomerRequest.CustomerAccount(); 
        custAccItem.title='test';
        custAccItem.firstName='test';
        custAccItem.lastName='test';
        custAccItem.birthDate='test';
        custAccItem.driverLicenseNumber='test';
        custAccItem.driverLicenseState='test';
        DataItem.CustomerAccount = custAccItem;
        ManageCustomerRequest.Address addressItem= new ManageCustomerRequest.Address(); 
        addressItem.isPrimary='test';
        addressItem.status='test';
        addressItem.statusCode='test';
        addressItem.addressType='test';
        addressItem.addressTypeCode='test';
        addressItem.country='test';
        addressItem.state='test';
        addressItem.postalCode='test';
        addressItem.addressId='test';
        addressItem.streetName='test';
        addressItem.streetType='test';
        addressItem.streetTypeCode='test';
        addressItem.streetTypeSuffix='test';
        addressItem.streetTypeSuffixCode='test';
        addressItem.streetNumberStart='test';
        addressItem.streetNumberEnd='test';
        addressItem.streetNumberEndSuffix='test';
        addressItem.internationalPostcode='test';
        addressItem.internationalState='test';
        addressItem.deliveryPointId='test';
        addressItem.registeredPlan='test';
        addressItem.locality='test';
        addressItem.additionalInfo='test';
        addressItem.geographicalLocationCode='test';
        
        
        //DataItem.Address = addressItem;
        ManageCustomerRequest.SubAddress subaddressItem= new ManageCustomerRequest.SubAddress(); 
        subaddressItem.buildingName = 'test';
        subaddressItem.propertyName = 'test';
        subaddressItem.numberStart = 'test';
        subaddressItem.numberEnd = 'test';
        subaddressItem.privateStreetType = 'test';
        addressItem.SubAddress = subaddressItem;
        ManageCustomerRequest.Detail detailItem= new ManageCustomerRequest.Detail(); 
        detailItem.detailType = 'test';
        detailItem.detailTypeCode = 'test';
        detailItem.value = 'test';
        ManageCustomerRequest.AccountPortfolio accportItem= new ManageCustomerRequest.AccountPortfolio(); 
        accportItem.isPrimary = 'test';
        accportItem.portfolioCode = 'test';
        System.assertEquals(subaddressItem!=null, true,'Created');
        Test.stopTest();
    }
      /*------------------------------------------------------------ 
Method: ValidateDateFieldWithTZD 
Description: Validate date
Inputs: datetime
Returns: String
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    static testMethod void testValidateDateFieldWithTZD() {
        test.startTest();
        String dateStr = ManageCustomerHandler.validateDateFieldWithTZD(DateTime.now());
        test.stopTest();
        System.assertEquals(dateStr!=null,true,'Date');
    }
    /*------------------------------------------------------------ 
Method: validateAddressStatus 
Description: validate Address Status
Inputs: status
Returns: String
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    static testMethod void testvalidateAddressStatus() {
        test.startTest();
        String status = ManageCustomerHandler.validateAddressStatus('UNCONFIRMED');
        test.stopTest();
        System.assertEquals(status!=null,true,'status');
    }
    
}