@isTest
private class NotifyContactTest {

    @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        /*final ImportTCMCustomerByCIDN importCustomerByCIDN = new ImportTCMCustomerByCIDN();
        ImportTCMCustomerResult importCustomerResult = importCustomerByCIDN.importCustomerAndContactbyCIDN('2830329059',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        */
    }
    
    static testMethod void notifyContactPost(){
        Test.startTest();
        final RestRequest req = new RestRequest();
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyContact';
        System.assertEquals((req!=null), true,'Request');
        Test.stopTest();
    }
    
    /*************************************************************
	EDGE: 67176
	Author: Ila Anmol Verma
	Description: Modified existing test method for custom setting	
	****************************************************************/
    static testMethod void testDoPostCreate() {
        Test.startTest();
        final RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyContact';  
        req.httpMethod = 'POST';
        //String reqBody =  '{"request":{"data":{"id":"906361","title":"Mr","firstName":"Satishh","middleName":"Ravella","lastName":"Chowdary","birthDate":"1992-10-10""status":"Active","mergeStatus":"ok","onlineFlag":"N","preferredMethod":"phone","eventAction":"","contactId":"0030l000002e90m","lastVerifiedDate":"1992-12-19",":"2017-08-21 16:28:00","sendDateTime":"","parentSourceSystemAction":"Updating","externalSystemId":"003","businessAddress":[{"addressStatus":"","addressType":"","buildingName":"","country":"","keyAddressId":"","postalCode":"","state":"","streetType":"","descriptor":"","city":"","streetAddress":"","addressLine1":"","addressLine2":"","addressLine3":"","roleName":"","lastUpdatedDateTime":""}],"personalAddress":[{"addressStatus":"","addressType":"","buildingName":"","country":"","postalCode":"","state":"","streetType":"","toNumber":"","descriptor":"","city":"","streetAddress":"","addressLine1":"","addressLine2":"","addressLine3":"","roleName":"","lastUpdatedDateTime":""}],"account":[{"accountUUID":"001p000000CBTuvAAH",contactUsage":"","customerType":"","mmsOptIn":"","smsOptIn":"","emailOptIn":"","faceToFaceOptIn":"","phoneOptIn":"","directMailOptIn":"","lastUpdatedDateTime":"","contactEndDate":"","contactType":[{"isPrimary":"","contactType":""}]}]}]}}}';
   
        EnvironmentVariable__c tcmUpdate = new EnvironmentVariable__c();
        tcmUpdate.Name='TCMupdate';
        tcmUpdate.Value__c='True';
        insert tcmUpdate;
        RestContext.request = req;
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
        
        final NotifyContactRequest ncr = new NotifyContactRequest();
        ncr.data = new NotifyContactRequest.Data();
        ncr.data.title = 'Mr.';
        ncr.data.firstName = 'Satishh';
        ncr.data.MiddleName = 'Ravella';
        ncr.data.lastName = 'Chowdary';
        ncr.data.contactId = '0030l000002e90m';
        ncr.data.birthDate = '1990-10-10';
        ncr.data.id = '906361';
        ncr.data.status= 'Active';
        ncr.data.eventAction = '';
        ncr.data.lastVerifiedDate = '2014-14-02 16:28:00';
        ncr.data.notes = '';
        ncr.data.numberInHousehold = '5';
        ncr.data.occupation = '';
        ncr.data.timeZone = '';
        ncr.data.reviewedFlag = '';
        ncr.data.lastUpdated = '';
        ncr.data.sendDateTime = '';
        ncr.data.parentSourceSystemAction = '';
        ncr.data.mergeStatus = 'Inactive';
        ncr.data.onlineFlag = 'false';
        ncr.data.preferredMethod ='Fax';
        ncr.data.jobDescription ='Manager';
        ncr.data.jobTitle= 'Associate';
        ncr.data.languagePreference ='English';
        ncr.data.externalSystemId='002';
      
        
        
        ncr.data.customerAccounts = new List<NotifyContactRequest.CustomerAccounts>();
        final NotifyContactRequest.CustomerAccounts customerAccount = new NotifyContactRequest.CustomerAccounts();
        customerAccount.accountUUID = '2345678';
        customerAccount.mmsOptIn = 'true';
        customerAccount.smsOptIn = 'true';
        customerAccount.emailOptIn = 'false';
        customerAccount.faceToFaceOptIn = 'false';
        customerAccount.phoneOptIn = 'true';
        customerAccount.directMailOptIn = 'false';
        customerAccount.marketClass = '';
        customerAccount.businessUnit = '';
        customerAccount.dataSovereignty = '';
        customerAccount.contactRelationship = new NotifyContactRequest.ContactRelationship();
        customerAccount.contactRelationship.contactType = 'Full Authority';
        customerAccount.contactRelationship.contactUsage = 'Business';
        customerAccount.contactRelationship.endDate = '2016-12-12';
        ncr.data.customerAccounts.add(customerAccount);
        
        ncr.data.homeContact = new NotifyContactRequest.HomeContact();
        ncr.data.homeContact.phoneNumber = '';
        ncr.data.homeContact.mobileNumber = '';
        ncr.data.homeContact.emailAddress = '';
        ncr.data.homeContact.faxNumber = '';
        
        ncr.data.workContact = new NotifyContactRequest.workContact();
        ncr.data.workContact.phoneNumber = '';
        ncr.data.workContact.mobileNumber = '';
        ncr.data.workContact.emailAddress = '';
        ncr.data.workContact.faxNumber = '';
        
        ncr.data.identification = new NotifyContactRequest.Identification();
        ncr.data.identification.driverLicense = new NotifyContactRequest.DriverLicense();
        ncr.data.identification.driverLicense.driversLicenseNo = '093033999';
        ncr.data.identification.driverLicense.state = 'VIC';
        
        ncr.data.asset = new List<NotifyContactRequest.Asset>();
        final NotifyContactRequest.Asset assetItem = new NotifyContactRequest.Asset();
        assetItem.integrationId = '';
        assetItem.assetRelationshipType = '';
        assetItem.assetContactEndDate = '';
        assetItem.assetId = '';
        ncr.data.asset.add(assetItem);
        
        ncr.data.businessAddress = new List<NotifyContactRequest.BusinessAddress>();
        final NotifyContactRequest.BusinessAddress businessAddressItem = new NotifyContactRequest.BusinessAddress();
        businessAddressItem.status = 'CONFIRMED';
        businessAddressItem.addressType = 'Street';
        businessAddressItem.country = 'India';
        businessAddressItem.streetNumberEndSuffix = '003';
        businessAddressItem.addressId = 'B11111';
        businessAddressItem.postalCode = '';
        businessAddressItem.isPrimary = 'True';
        businessAddressItem.registeredPlan = '';
        businessAddressItem.streetNumberStartSuffix = '';
        businessAddressItem.state = '';
        businessAddressItem.streetNumberEnd = '';
        businessAddressItem.streetNumberStart = '';
        businessAddressItem.streetType = '';
        businessAddressItem.streetTypeSuffix = '';
        businessAddressItem.additionalInfo = '';
        businessAddressItem.internationalPostcode = '';
        businessAddressItem.internationalState = '';
        businessAddressItem.locality = '';
        businessAddressItem.streetName = '';
        businessAddressItem.subAddress = new NotifyContactRequest.SubAddress();        
        businessAddressItem.subAddress.buildingName = '';
        businessAddressItem.subAddress.propertyName = '';
        businessAddressItem.subAddress.numberStart = '';
        businessAddressItem.subAddress.numberEnd = '';
        businessAddressItem.subAddress.privateStreetName = '';
        businessAddressItem.subAddress.privateStreetType = '';
        businessAddressItem.subAddress.details = new List<NotifyContactRequest.Detail>();
        final NotifyContactRequest.Detail detailItem1 = new NotifyContactRequest.Detail();
        detailItem1.detailType = 'testdetail1';
        detailItem1.value = '1111';
        final NotifyContactRequest.Detail detailItem2 = new NotifyContactRequest.Detail();
        detailItem2.detailType = 'testdetail2';
        detailItem2.value = '2222';
        businessAddressItem.subAddress.details.add(detailItem1);
        businessAddressItem.subAddress.details.add(detailItem2);
        businessAddressItem.subAddress.addressLines = new List<String>();
        businessAddressItem.subAddress.addressLines.add('testbusinessAddress1');
        businessAddressItem.subAddress.addressLines.add('testbusinessAddress2');
        businessAddressItem.subAddress.addressLines.add('testbusinessAddress3');
        ncr.data.businessAddress.add(businessAddressItem);
        ncr.data.personalAddress = new List<NotifyContactRequest.PersonalAddress>();
        final NotifyContactRequest.PersonalAddress personalAddressItem = new NotifyContactRequest.PersonalAddress();
        personalAddressItem.status = 'CONFIRMED';
        personalAddressItem.addressType = 'Street';
        personalAddressItem.country = 'India';
        personalAddressItem.streetNumberEndSuffix = '003';
        personalAddressItem.addressId = 'P11111';
        personalAddressItem.postalCode = '410111';
        personalAddressItem.isPrimary = 'true';
        personalAddressItem.registeredPlan = 'test';
        personalAddressItem.streetNumberStartSuffix = '111';
        personalAddressItem.state = 'testState';
        personalAddressItem.streetNumberEnd = '11';
        personalAddressItem.streetNumberStart = '11';
        personalAddressItem.streetType = 'lane';
        personalAddressItem.streetTypeSuffix = 'ln';
        personalAddressItem.additionalInfo = 'test info';
        personalAddressItem.internationalPostcode = '';
        personalAddressItem.internationalState = '';
        personalAddressItem.locality = 'testLocal';
        personalAddressItem.streetName = '';
        personalAddressItem.subAddress = new NotifyContactRequest.SubAddress();        
        personalAddressItem.subAddress.buildingName = '';
        personalAddressItem.subAddress.propertyName = '';
        personalAddressItem.subAddress.numberStart = '';
        personalAddressItem.subAddress.numberEnd = '';
        personalAddressItem.subAddress.privateStreetName = '';
        personalAddressItem.subAddress.privateStreetType = '';
        personalAddressItem.subAddress.details = new List<NotifyContactRequest.Detail>();
        final NotifyContactRequest.Detail detailItemm1 = new NotifyContactRequest.Detail();
        detailItemm1.detailType = 'testDetail1';
        detailItemm1.value = '1111';
        personalAddressItem.subAddress.details.add(detailItemm1);
        final NotifyContactRequest.Detail detailItemm2 = new NotifyContactRequest.Detail();
        detailItemm2.detailType = 'testDetail2';
        detailItemm2.value = '2222';
        personalAddressItem.subAddress.details.add(detailItemm2);
        personalAddressItem.subAddress.addressLines = new List<String>();
        personalAddressItem.subAddress.addressLines.add('testPersonalAddress1');
        personalAddressItem.subAddress.addressLines.add('testPersonalAddress2');
        personalAddressItem.subAddress.addressLines.add('testPersonalAddress3');
        ncr.data.personalAddress.add(personalAddressItem);
        system.debug('ncr.data.personalAddress++'+ncr.data.personalAddress);
        Test.stopTest();
        system.assertNotEquals(null, NotifyContact.doPost(ncr)) ;
    }
    
    /*************************************************************
	EDGE: 67176
	Author: Ila Anmol Verma
	Description: Modified existing test method for custom setting	
	****************************************************************/
    static testMethod void testDoPostUpdate() {
        Test.startTest();
        EnvironmentVariable__c tcmUpdate = new EnvironmentVariable__c();
        tcmUpdate.Name='TCMupdate';
        tcmUpdate.Value__c='True';
        insert tcmUpdate;
        
        final Account a = TestUtil.createAccount('post_update');
        a.Name ='TestName';
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456782';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
		final Contact c = TestUtil.createContact(a.Id, 'shambo', 'Bloggs');
        c.Birthdate = Date.newInstance(1990, 11,09);
        c.UUID__c = '906361';
        insert c;
        system.debug('C+++'+c.UUID__c);
        system.debug('contact++'+c);
        
                
        //Contact c =[select id,name,accountid,UUID__c from contact where firstname='Joey' and lastname='Bloggs' ][0];
        //Account a=[select id,Account_UUID__c,Customer_ID__c,name from account where name='Something' and Customer_ID__c='7123456789' ][0];
       /* RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyContact';  
        req.httpMethod = 'POST';
        String reqBody = '{"request":{"data":{"contactDetails":[{"contactId":"0030l000002e90m","uuid":"asf23-aewew-saknh-adfgd","title":"Mr","firstName":"Joey","middleName":"Saint","lastName":"Bloggs","dateOfBirth":"11-10-1980","homeEmail":"joe.bloggs@homeemail.com","homeFaxNo":"0395468245","homePhoneNo":"0398769876","homeMobileNo":"0456213869","workPhoneNo":"0385550325","workMobileNo":"0433456113","workFaxNo":"0398213421","workEmail":"joe.bloggs@workemail.com","preferredCommMethod":"Phone","driversLicenseNo":"0933033219","driversLicenseState":"VIC","contactStatus":"Active","lastVerifiedDate":"","notes":"","occupation":"Sales","jobDescription":"Sales General Manager","jobTitle":"General Manager","languagePreference":"English","lastUpdated":"","externalSystemId":"","businessAddress":[{"addressStatus":"","addressType":"","buildingName":"","country":"","keyAddressId":"","postalCode":"","state":"","streetType":"","descriptor":"","city":"","streetAddress":"","addressLine1":"","addressLine2":"","addressLine3":"","roleName":"","lastUpdatedDateTime":""}],"personalAddress":[{"addressStatus":"","addressType":"","buildingName":"","country":"","postalCode":"","state":"","streetType":"","toNumber":"","descriptor":"","city":"","streetAddress":"","addressLine1":"","addressLine2":"","addressLine3":"","roleName":"","lastUpdatedDateTime":""}],"account":[{"accountUUID":"001p000000CBTuvAAH","contactUsage":"","customerType":"","mmsOptIn":"","smsOptIn":"","emailOptIn":"","faceToFaceOptIn":"","phoneOptIn":"","directMailOptIn":"","lastUpdatedDateTime":"","contactEndDate":"","contactType":[{"isPrimary":"","contactType":""}]}]}]}}}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;*/
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
        
        final NotifyContactRequest ncr = new NotifyContactRequest();
        ncr.data = new NotifyContactRequest.Data();
        ncr.data.id = '906361';
        ncr.data.title = 'Mr.';
        ncr.data.firstName = 'Satishh';
        ncr.data.lastName = 'Ravella';
        ncr.data.birthDate = '1990-10-10';
        ncr.data.contactId = '0030l000002e90m';
        ncr.data.status= 'Active';
        system.debug('In test class'+c.UUID__c);
        ncr.data.contactId = c.UUID__c;
        ncr.data.customerAccounts = new List<NotifyContactRequest.CustomerAccounts>();
        final NotifyContactRequest.CustomerAccounts customerAccount = new NotifyContactRequest.CustomerAccounts();
        customerAccount.accountUUID = a.Account_UUID__c;
        customerAccount.mmsOptIn = 'true';
        customerAccount.smsOptIn = 'true';
        customerAccount.emailOptIn = 'false';
        customerAccount.faceToFaceOptIn = 'false';
        customerAccount.phoneOptIn = 'true';
        customerAccount.directMailOptIn = 'false';
        customerAccount.marketClass = '';
        customerAccount.businessUnit = '';
        customerAccount.dataSovereignty = '';
        customerAccount.contactRelationship = new NotifyContactRequest.ContactRelationship();
        customerAccount.contactRelationship.contactType = 'Full Authority';
        customerAccount.contactRelationship.contactUsage = 'Business';
        customerAccount.contactRelationship.endDate = '2016-12-12';
        ncr.data.customerAccounts.add(customerAccount);
        Test.stopTest();
        system.assertNotEquals(null, NotifyContact.doPost(ncr))  ;
        
    }

    /*************************************************************
	JIRA : P2OB-15034
	Author: Ravi Dodiya
	Description: Allow only Contact UUID to be updated as part of NotifyContact Event	
	****************************************************************/
    static testMethod void testDoPostUpdateUUID() {
        Test.startTest();
        EnvironmentVariable__c tcmUpdate = new EnvironmentVariable__c();
        tcmUpdate.Name='TCMupdate';
        tcmUpdate.Value__c='False';
        insert tcmUpdate;
        
        final Account a = TestUtil.createAccount('post_update');
        a.Name ='TestName';
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456782';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
		final Contact c = TestUtil.createContact(a.Id, 'shambo', 'Bloggs');
        c.Birthdate = Date.newInstance(1990, 11,09);
        //c.UUID__c = '906361';
        insert c;
        system.debug('C+++'+c.UUID__c);
        system.debug('contact++'+c);
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
        
        final NotifyContactRequest ncr = new NotifyContactRequest();
        ncr.data = new NotifyContactRequest.Data();
        ncr.data.id = 'TestUUID-012345';
        ncr.data.title = 'Mr.';
        ncr.data.firstName = 'Satishh';
        ncr.data.lastName = 'Ravella';
        ncr.data.birthDate = '1990-10-10';
        ncr.data.contactId = '0030l000002e90m';
        ncr.data.status= 'Active';
        ncr.data.contactId = c.Id;
        ncr.data.customerAccounts = new List<NotifyContactRequest.CustomerAccounts>();
        final NotifyContactRequest.CustomerAccounts customerAccount = new NotifyContactRequest.CustomerAccounts();
        customerAccount.accountUUID = a.Account_UUID__c;
        customerAccount.mmsOptIn = 'true';
        customerAccount.smsOptIn = 'true';
        customerAccount.emailOptIn = 'false';
        customerAccount.faceToFaceOptIn = 'false';
        customerAccount.phoneOptIn = 'true';
        customerAccount.directMailOptIn = 'false';
        customerAccount.marketClass = '';
        customerAccount.businessUnit = '';
        customerAccount.dataSovereignty = '';
        customerAccount.contactRelationship = new NotifyContactRequest.ContactRelationship();
        customerAccount.contactRelationship.contactType = 'Full Authority';
        customerAccount.contactRelationship.contactUsage = 'Business';
        customerAccount.contactRelationship.endDate = '2016-12-12';
        ncr.data.customerAccounts.add(customerAccount);
        NotifyContactResponse response = NotifyContact.doPost(ncr);
        Test.stopTest();
        system.assertEquals('Contact updated', response.Message)  ;

        
    }
    
    /*************************************************************
	JIRA : P2OB-15034
	Author: Ravi Dodiya
	Description: Allow only Contact UUID to be updated as part of NotifyContact Event	
	****************************************************************/
    static testMethod void testDoPostNullUUID() {
        Test.startTest();
        EnvironmentVariable__c tcmUpdate = new EnvironmentVariable__c();
        tcmUpdate.Name='TCMupdate';
        tcmUpdate.Value__c='False';
        insert tcmUpdate;
        
        final Account a = TestUtil.createAccount('post_update');
        a.Name ='TestName';
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456782';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
		final Contact c = TestUtil.createContact(a.Id, 'shambo', 'Bloggs');
        c.Birthdate = Date.newInstance(1990, 11,09);
        //c.UUID__c = '906361';
        insert c;
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
        
        final NotifyContactRequest ncr = new NotifyContactRequest();
        ncr.data = new NotifyContactRequest.Data();
        ncr.data.id = '';
        ncr.data.contactId = c.Id;
        NotifyContactResponse response = NotifyContact.doPost(ncr);
        Test.stopTest();
        system.assertEquals('Contact Missing UUID', response.Message)  ;

        
    }

    static testMethod void testDoGet() {
        test.startTest();
      	final Account a = TestUtil.createAccount('get');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456780';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
		final Contact c = TestUtil.createContact(a.Id, 'Anik', 'Bloggsa');
        c.Birthdate = Date.newInstance(1990, 11,09);
        insert c;
        
        
        
        
        //Contact c =[select id,name,accountid,UUID__c from contact where firstname='Joey' and lastname='Bloggs' ][0];
        system.debug('Contact list'+c);
        final RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyContact/'+c.Id;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
        test.stopTest();
        final Contact cont = NotifyContact.doGet();
        system.assertNotEquals(null, cont);
    }
    
    static testMethod void testDoDelete() {
        test.startTest();
      	final Account a = TestUtil.createAccount('delete');
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456781';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
		final Contact c = TestUtil.createContact(a.Id, 'John', 'Blog');
        c.Birthdate = Date.newInstance(1990, 11,09);
        insert c;
        //Contact c =[select id,name,accountid,UUID__c from contact where firstname='Joey' and lastname='Bloggs' ][0];
        //system.debug('Contact list'+c);
        final RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/NotifyContact/'+c.Id;  
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
        test.stopTest();
        NotifyContact.doDelete();
        system.assertEquals(0,[select count() from contact where firstname='John' and lastname='Blog'],'Notify');
    }
    /*Keeping Dormant
    //EDGE-29842 (AC10)
    static testMethod void testDoPost_updateContactInactive() {
        Test.startTest();
        Account a = TestUtil.createAccount('post_update');
        a.Name ='TestName';
        a.Account_UUID__c = 'accountuuid';
        a.Customer_ID__c = '7123456782';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
		Contact c = TestUtil.createContact(a.Id, 'shambo', 'Bloggs');
        c.Birthdate = Date.newInstance(1990, 11,09);
        c.UUID__c = '906361';
        insert c;
        system.debug('C+++'+c.UUID__c);
        system.debug('contact++'+c);

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        NotifyContactRequest ncr = new NotifyContactRequest();
        ncr.data = new NotifyContactRequest.Data();
        ncr.data.id = '906361';
        ncr.data.title = 'Mr.';
        ncr.data.firstName = 'Satishh';
        ncr.data.lastName = 'Ravella';
        ncr.data.birthDate = '1990-10-10';
        ncr.data.contactId = '0030l000002e90m';
        ncr.data.status= 'Inactive';
        system.debug('In test class'+c.UUID__c);
        ncr.data.contactId = c.UUID__c;
        ncr.data.customerAccounts = new List<NotifyContactRequest.CustomerAccounts>();
        NotifyContactRequest.CustomerAccounts customerAccount = new NotifyContactRequest.CustomerAccounts();
        customerAccount.accountUUID = a.Account_UUID__c;
        customerAccount.mmsOptIn = 'true';
        customerAccount.smsOptIn = 'true';
        customerAccount.emailOptIn = 'false';
        customerAccount.faceToFaceOptIn = 'false';
        customerAccount.phoneOptIn = 'true';
        customerAccount.directMailOptIn = 'false';
        customerAccount.marketClass = '';
        customerAccount.businessUnit = '';
        customerAccount.dataSovereignty = '';
        customerAccount.contactRelationship = new NotifyContactRequest.ContactRelationship();
        customerAccount.contactRelationship.contactType = 'Full Authority';
        customerAccount.contactRelationship.contactUsage = 'Business';
        customerAccount.contactRelationship.endDate = '';
        ncr.data.customerAccounts.add(customerAccount);
        Test.stopTest();
        system.assertNotEquals(null, NotifyContact.doPost(ncr));
    }
    //EDGE-35520 (AC10)
    static testMethod void testDoPost_updateAcrEndDate() {
        Test.startTest();
        Account a = TestUtil.createAccount('post_update');
        a.Name ='TestName';
        a.Account_UUID__c = '1B319C32-80ED-11e8-9950-0021F6B34036';
        a.Customer_ID__c = '7123456782';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.CIDN__c='12345';
        a.Customer_Status__c='SUSPECT';
        insert a;
		Contact c = TestUtil.createContact(a.Id, 'Test', 'ContactLifecycle');
        c.Birthdate = Date.newInstance(1990, 11,09);
        c.UUID__c = '341A6BCD-957C-11e8-A022-0021F6B3ADC7';
        insert c;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        NotifyContactRequest ncr = new NotifyContactRequest();
        ncr.data = new NotifyContactRequest.Data();
        ncr.data.id = '906361';
        ncr.data.title = 'Mr.';
        ncr.data.firstName = 'Satishh';
        ncr.data.lastName = 'Ravella';
        ncr.data.birthDate = '1990-10-10';
        ncr.data.contactId = '0030l000002e90m';
        ncr.data.status= 'Inactive';
        system.debug('In test class'+c.UUID__c);
        ncr.data.contactId = c.UUID__c;
        ncr.data.customerAccounts = new List<NotifyContactRequest.CustomerAccounts>();
        NotifyContactRequest.CustomerAccounts customerAccount = new NotifyContactRequest.CustomerAccounts();
        customerAccount.accountUUID = a.Account_UUID__c;
        customerAccount.mmsOptIn = 'true';
        customerAccount.smsOptIn = 'true';
        customerAccount.emailOptIn = 'false';
        customerAccount.faceToFaceOptIn = 'false';
        customerAccount.phoneOptIn = 'true';
        customerAccount.directMailOptIn = 'false';
        customerAccount.marketClass = '';
        customerAccount.businessUnit = '';
        customerAccount.dataSovereignty = '';
        customerAccount.contactRelationship = new NotifyContactRequest.ContactRelationship();
        customerAccount.contactRelationship.contactType = 'Full Authority';
        customerAccount.contactRelationship.contactUsage = 'Business';
        customerAccount.contactRelationship.endDate = '2018-09-04T01:22:26+10:00'; //end dating ACR
        ncr.data.customerAccounts.add(customerAccount);
        Test.stopTest();
        system.assertNotEquals(null, NotifyContact.doPost(ncr));
    }
 */
}