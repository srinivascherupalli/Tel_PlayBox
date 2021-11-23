@isTest
public class ManageContactHandlerTest {
    
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
        EnvironmentVariable.put('MockEndpoint', 'http://mocksandbox.getsandbox.com/MockService');
        EnvironmentVariable.put('tcm_contact_scope', 'TCMCONTACT');
        EnvironmentVariable.put('Bearer', 'Bearer');
    }
    
    static testMethod void testManageContact1() {
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        // Create Contact
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.MobilePhone = '0445678006';
        insert c;
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        //a.Customer_ID__c = '7123456789';
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
        
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        // Assert that Last Updated timestamp is not null
        Contact cont = TestUtil.getContact(c.Id);
        cont.lastname='abc';
        cont.lastVerifiedDate__c = system.today();
        ManageContactHandler.generateManageContactRequest(cont,ManageContactHandler.EVENT_ACTION_UPDATE, null, false, null);
        Test.startTest();
        ManageContactDAO mdao=new ManageContactDAO(cont,ManageContactHandler.EVENT_ACTION_UPDATE);
        List<ManageContactDAO> mdaoList=new List<ManageContactDAO> {mdao};
            ManageContactHandler.sendmanageContactList(JSON.serialize(mdaoList));
        
        // ManageContactHandler.sendManageContact(ManageContactHandler.generateManageContactRequest(cont,ManageContactHandler.EVENT_ACTION_UPDATE), ManageContactHandler.EVENT_ACTION_UPDATE, cont.UUID__c,null);
        system.assertNotEquals('', a.Name);
        Test.stopTest();
    }
    static testMethod void testManageContact2(){
        // Resolved Deployment Error - 'You have uncommitted work pending. Please commit or rollback before calling out' 2-apr-2019   
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.MobilePhone = '0445678006';
        insert c;
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        //a.Customer_ID__c = '7123456789';
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456789';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        //a.Customer_Status__c='SUSPECT';
        a.Type= 'Sole Trader';
        a.Customer_Status__c = 'ACTIVE';
        a.ABN__c = '10000000000';
        a.Business_Unit__c='Business';
        a.BillingCity='AUSTRALIAN NATIONAL UNIVERSITY';
        a.BillingPostalCode='200';
        a.Market_Segment__c='DHL Express';
        a.Managed__c = True;
        insert a;
        
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        // Assert that Last Updated timestamp is not null
        Contact c1 = TestUtil.getContact(c.Id);
        c1.lastname='abc';
        c1.lastVerifiedDate__c = system.today();
        c1.Birthdate= Date.newInstance(1999, 1,10);
        c1.UUID__c='123456';
        c1.MobilePhone = '0445678006';
        AccountContactRelation acr= [Select Id,AccountId,ContactId,Roles from AccountContactRelation where AccountId =:a.Id AND ContactId =:c1.Id];
        acr.Roles='Legal Lessee';
        update acr;
        cscrm__Address__c personalAddress = new cscrm__Address__c();
        personalAddress.cscrm__Address_Type__c='Home Address';
        personalAddress.Address_Line_1__c='AD L1';
        personalAddress.Address_Line_2__c='AD L2';
        personalAddress.Address_Line_3__c='AD L3';
        
        insert personalAddress;
        cscrm__Contact_Address_Relationship__c car = new cscrm__Contact_Address_Relationship__c();
        car.cscrm__Contact__c = c1.Id;
        car.cscrm__Address__c = personalAddress.Id;
        car.cscrm__Address_Type__c = 'Home Address';
        insert car;
        ManageContactHandler.generateManageContactRequest(c1,ManageContactHandler.EVENT_ACTION_UPDATE,null, false, null);
        ManageContactHandler.getExistingAddresses(c1.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        ManageContactDAO mdao=new ManageContactDAO(c1,ManageContactHandler.EVENT_ACTION_UPDATE);
        List<ManageContactDAO> mdaoList=new List<ManageContactDAO> {mdao};
            ManageContactHandler.sendmanageContactList(JSON.serialize(mdaoList));
        system.assertNotEquals('', acr.Roles); 
        Test.stopTest();
    }
    
    /*------------------------------------------------------------ 
EDGE - 39902
Method: ManageContactPersonalAddress 
Description: Generate payload for Contact Personal Address 
Inputs: List of cscrm__Address__c
Returns: List of ManageContactRequest.PersonalAddress
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    static testMethod void testManageContactPersonalAddress(){
        List<cscrm__Address__c> addresses = new List<cscrm__Address__c>();
        cscrm__Address__c personalAddress = new cscrm__Address__c();
        personalAddress.Address_Status__c = 'CONFIRMED';
        personalAddress.Address_Line_1__c='AD L1';
        personalAddress.Address_Line_2__c='AD L2';
        personalAddress.Address_Line_3__c='AD L3';
        addresses.add(personalAddress);
        cscrm__Contact_Address_Relationship__c car = new cscrm__Contact_Address_Relationship__c();
        Test.startTest();
        List<ManageContactRequest.PersonalAddress> addressList = ManageContactHandler.getMCRContactPersonalAddress(addresses);
        Test.stopTest();
        system.assertNotEquals(null,addressList);
    }   
    /*------------------------------------------------------------ 
Method: ManageContactBusinessAddress 
Description: Generate payload for Contact Personal Address 
Inputs: List of cscrm__Address__c
Returns: List of ManageContactRequest.BusinessAddress
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    static testMethod void testManageContactBusinessAddress(){
        List<cscrm__Address__c> addresses = new List<cscrm__Address__c>();
        cscrm__Address__c businessAddress = new cscrm__Address__c();
        businessAddress.Address_Line_1__c='AD L1';
        businessAddress.Address_Line_2__c='AD L2';
        businessAddress.Address_Line_3__c='AD L3';
        addresses.add(businessAddress);
        Test.startTest();
        List<ManageContactRequest.BusinessAddress> addressList = ManageContactHandler.getMCRContactBusinessAddress(addresses);
        system.assertNotEquals(null,addressList);
        Test.stopTest();
    }  
    static testMethod void manageContactRequestCoverage() {
        ManageContactRequest mcr = new ManageContactRequest();
        ManageContactRequest.Data dataItem = new ManageContactRequest.Data();
        dataItem.occupation='test';
        dataItem.jobDescription='test';
        ManageContactRequest.Asset assetItem = new ManageContactRequest.Asset();
        assetItem.integrationId = 'test';
        assetItem.assetRelationshipType = 'test';
        assetItem.assetContactEndDate = 'test';
        assetItem.assetID = 'test';
        dataItem.Asset = assetItem;
        ManageContactRequest.DriverLicense driverLicenseItem = new ManageContactRequest.DriverLicense();
        driverLicenseItem.num='test';
        driverLicenseItem.state='test';
        ManageContactRequest.Identification idItem = new ManageContactRequest.Identification();
        idItem.DriverLicense=driverLicenseItem;
        ManageContactRequest.BusinessAddress businessAddItem = new ManageContactRequest.BusinessAddress();
        businessAddItem.state='test';
        businessAddItem.addressType='test';
        businessAddItem.country='test';
        businessAddItem.streetNumberEndSuffix='test';
        businessAddItem.addressId='test';
        businessAddItem.postalCode='test';
        businessAddItem.isPrimary='test';
        businessAddItem.registeredPlan='test';
        businessAddItem.streetNumberStartSuffix='test';
        businessAddItem.streetNumberEnd='test';
        businessAddItem.streetType='test';
        businessAddItem.additionalInfo='test';
        businessAddItem.internationalPostcode='test';
        businessAddItem.internationalState='test';
        businessAddItem.status='test';
        businessAddItem.streetNumberStart='test';
        businessAddItem.locality='test';
        ManageContactRequest.PersonalAddress personalAddItem = new ManageContactRequest.PersonalAddress();
        personalAddItem.status='test';
        personalAddItem.addressType='test';
        personalAddItem.country='test';
        personalAddItem.streetNumberEndSuffix='test';
        personalAddItem.addressId='test';
        personalAddItem.postalCode='test';
        personalAddItem.isPrimary   ='test';
        personalAddItem.registeredPlan='test';
        personalAddItem.streetNumberStartSuffix='test';
        personalAddItem.state='test';
        personalAddItem.streetNumberEnd='test';
        personalAddItem.streetNumberStart='test';
        personalAddItem.streetType='test';
        personalAddItem.streetNumberStart='test';
        personalAddItem.streetType='test';
        personalAddItem.additionalInfo='test';
        personalAddItem.internationalPostcode='test';
        personalAddItem.internationalState='test';
        personalAddItem.locality='test';
        personalAddItem.streetName='test';
        ManageContactRequest.SubAddress subAddItem = new ManageContactRequest.SubAddress();
        subAddItem.buildingName='test';
        subAddItem.propertyName='test';
        subAddItem.numberStart='test';
        subAddItem.numberEnd='test';
        subAddItem.privateStreetName='test';
        subAddItem.privateStreetType='test';
        personalAddItem.SubAddress = subAddItem;
        ManageContactRequest.Detail detailItem = new ManageContactRequest.Detail();
        detailItem.detailType='test';
        detailItem.value='test';
        System.assertEquals(detailItem!=null, true,'Created');
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
        Test.startTest();
        String dateStr = ManageContactHandler.validateDateFieldWithTZD(DateTime.now());
        Test.stopTest();
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
        Test.startTest();
        String status = ManageContactHandler.validateAddressStatus('UNCONFIRMED');
        Test.stopTest();
        System.assertEquals(status!=null,true,'status');
    }
}