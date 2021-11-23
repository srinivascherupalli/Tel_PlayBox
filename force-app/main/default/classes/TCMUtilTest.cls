@isTest
public class TCMUtilTest {
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
        EnvironmentVariable.put('MockEndpoint','https://mocksandbox.getsandbox.com');
    }
    
    Static void TCMDataObjectTest(){
        TCMDataObject  dataobj =  new TCMDataObject();
		TCMDataObject.Customer datacust = new TCMDataObject.Customer();
        datacust.cac = 'test1';
        datacust.customerType = 'Sole Trader';
        
    }
    
    static testMethod void isCustomerSoleTradertest(){
        TCMDataObject  dataobj =  new TCMDataObject();
		TCMDataObject.Customer datacust = new TCMDataObject.Customer();
        datacust.cac = 'test1';
        datacust.customerType = 'Sole Trader';
        boolean returnval = TCMUtil.isCustomerSoleTrader(datacust);
        system.assertEquals(True,TCMUtil.isCustomerSoleTrader(datacust));
    }
    
    static testmethod void mapContactToRequestWithRelationTest(){
     	Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.Birthdate = Date.newInstance(2007, 2,10);
        insert c;
        
        // Create Address
        cscrm__Address__c add = TestUtil.createAddress();
        insert add;
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Pref_Comm_Method__c = 'B2B';
        insert a;
        
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        // Add Address to Account
        TestUtil.addAddressToAccount(a.Id, add.Id);
        update a;
        
        TCMDataObject.Contact tcmcon = TCMUtil.mapContactToRequestWithRelation(c,'Created', 'Full Authority','Business');
         system.assertNotEquals(null, tcmcon)  ;

    }
    
    static testmethod void mapCustomerToRequestTest(){
     	Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.Birthdate = Date.newInstance(2007, 2,10);
        insert c;
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Pref_Comm_Method__c = 'B2B';
        insert a;
        // Create Address
        cscrm__Address__c add = TestUtil.createAddress();
          insert add;
        system.debug('add++'+add);
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        AccountContactRelation acr =[SELECT AccountId,ContactId,Id,Roles FROM AccountContactRelation where  AccountId=:a.Id];
        acr.Roles = Constants.DEFAULT_CONTACT_ROLE;
        update acr;
        
        AccountContactRelation acr1= TCMUtil.createAccountContactRelationship(a.Id, c.Id,'Full Authority','Business');
        // Add Address to Account
        TestUtil.addAddressToAccount(a.Id, add.Id);
        update a;
        AccountContactRelation acrUpdated= TCMUtil.updateAccountContactRelationship(acr1.Id,'Sales','Residential');
        TCMDataObject.Customer tcmcus = TCMUtil.mapCustomerToRequest(a,'Created', true);
        
        TCMDataObject.Customer tcmcust = TCMUtil.mapCustomerToRequest(a,'Created', false);
        List<AccountContactRelation> acrList =TCMUtil.checkAccountContactRelationshipExistList(c.Id,a.Id,'Full Authority');
        AccountContactRelation acrCheck =TCMUtil.checkAccountContactRelationshipExist(c.Id,a.Id,'Full Authority');
        cscrm__Account_Address_Relationship__c adrCheck = TCMUtil.checkAccountAddressRelationshipExist(add.Id,a.Id,'Street');
        system.assertNotEquals(null, tcmcust)  ;

    }
    
    static testmethod void mapCustomerDataToAccounttest(){
        TCMDataObject  dataobj =  new TCMDataObject() ;
        TCMDataObject.Customer datacust = new TCMDataObject.Customer()  ;
        TCMDataObject.CustomerAccount custAcc =  new  TCMDataObject.CustomerAccount();
        custAcc.lastName= 'Testlastname' ;
		custAcc.firstName = '';
        custAcc.birthDate = '';
        custAcc.phoneNumber = '';
        custAcc.driverLicenseNumber = '';
        custAcc.driverLicenseState = '';
        custAcc.fraudFlag = '';
        custAcc.vipFlag = '';
        custAcc.effectiveRetiredDate = '';
        datacust.abnOverride= '1234566' ;
        custAcc.abn= '12345678' ;
        datacust.parentSourceSystem= 'SFDC' ;
        custAcc.acn= '23456' ;
        custAcc.accountUuid=  '98562365';
        datacust.businessUnit= 'test' ;
        datacust.marketSegment= 'testmarket' ;
        datacust.servicingOrgUnit= 'test' ;
        custAcc.preferredMethod=  'B2B';
        datacust.cidn= '12345678' ;
        datacust.cac=  '5685788';
        datacust.accountStatus= 'Active' ;
        datacust.description= 'testdescription' ;
        custAcc.emailAddress= 'test@test.com' ;
        custAcc.faxNumber= '1234566' ;
        datacust.accountStatus= 'Active' ;
        datacust.primaryIndustryIndicator=  '123456';
        datacust.languagePreference= 'English' ;
		datacust.CustomerAccount = custAcc;
        
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.Birthdate = Date.newInstance(2007, 2,10);
        insert c;
        
        // Create Address
        cscrm__Address__c add = TestUtil.createAddress();
        insert add;
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Pref_Comm_Method__c = 'B2B';
        insert a;
        
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        // Add Address to Account
        TestUtil.addAddressToAccount(a.Id, add.Id);
        update a;
        
       Account acc =  TCMUtil.mapCustomerDataToAccount(datacust, a);
        cscrm__Address__c addr = TCMUtil.getAddressesByExternalId(add.Id);
         system.assertNotEquals(null, acc)  ;     
    }
    
     static testmethod void mapContactDataToContactTest(){
        TCMDataObject.Contact tcmcon =  new TCMDataObject.Contact();
         tcmcon.Id = '1234567';
      	tcmcon.title= 'Mr' ;
        tcmcon.firstName= 'Testname' ;
        tcmcon.middleName= 'testMiddle' ;
        tcmcon.lastName= 'testlastmane' ;
        tcmcon.birthDate=  '1999-01-01T23:01:01-08:00';
        TCMDataObject.ContactDetails homecon =  new TCMDataObject.ContactDetails();    
        homecon.emailAddress=  'test@test.com';
        homecon.phoneNumber= '1234567890' ;
        homecon.faxNumber= '123456' ; 
        tcmcon.homeContact = homecon;
        TCMDataObject.ContactDetails workcon =  new TCMDataObject.ContactDetails();  
        workcon.emailAddress=  'test@test.com';
        workcon.phoneNumber= '1234567890' ;
        workcon.faxNumber= '123456' ;   
        tcmcon.workContact = workcon;
        tcmcon.preferredMethod= 'B2B' ;
        
        TCMDataObject.Identification idet =  new TCMDataObject.Identification();
        TCMDataObject.DriverLicense driver =  new TCMDataObject.DriverLicense();
        
        driver.driversLicenseNo= '1234667' ;
        driver.state= 'AU' ;  
        idet.driverLicense = driver;
        tcmcon.identification = idet;
        tcmcon.status=  'Active';
        tcmcon.jobDescription= 'jobderscription' ;
        tcmcon.jobTitle=  'jobttile';
        tcmcon.languagePreference=  'English';
        Contact con11;
        
        Contact con = TCMUtil.mapContactDataToContact(tcmcon, con11); 
        system.assertNotEquals(null, con)  ; 
    }
    
     static testmethod void mapContactDataToContact1Test(){
         Account a = TestUtil.createAccount('Sample Account');
         a.Account_UUID__c = '123467';
         a.Pref_Comm_Method__c = 'B2B';
         insert a;
         List<TCMDataObject.Contact1> tcmConList = new List<TCMDataObject.Contact1>();
         TCMDataObject.Contact1 tcmcon =  new TCMDataObject.Contact1();
         tcmcon.Id = '1234567';
      	tcmcon.title= 'Mr' ;
        tcmcon.firstName= 'Testname' ;
        tcmcon.middleName= 'testMiddle' ;
        tcmcon.lastName= 'testlastmane' ;
        tcmcon.birthDate=  '1999-01-01T23:01:01-08:00';
        tcmcon.mergeStatus = '';
        tcmcon.onlineFlag = '';
        tcmcon.eventAction = '';
		tcmcon.contactId = '';
		tcmcon.lastVerifiedDate = '';
		tcmcon.notes = '';
		tcmcon.numberInHousehold = '';
		tcmcon.occupation = '';
		tcmcon.timeZone = '';
		tcmcon.jobDescription = '';
        tcmcon.lastUpdated = '';
		tcmcon.sendDateTime = '';
		tcmcon.parentSourceSystemAction = '';
		tcmcon.contactType = '';
		tcmcon.contactUsage = ''; 
        TCMDataObject.ContactDetails homecon =  new TCMDataObject.ContactDetails();    
        homecon.emailAddress=  'test@test.com';
        homecon.phoneNumber= '1234567890' ;
        homecon.faxNumber= '123456' ; 
        tcmcon.homeContact = homecon;
        TCMDataObject.ContactDetails workcon =  new TCMDataObject.ContactDetails();  
        workcon.emailAddress=  'test@test.com';
        workcon.phoneNumber= '1234567890' ;
        workcon.faxNumber= '123456' ;   
        tcmcon.workContact = workcon;
        tcmcon.preferredMethod= 'B2B' ;
        
        TCMDataObject.Identification idet =  new TCMDataObject.Identification();
        TCMDataObject.DriverLicense driver =  new TCMDataObject.DriverLicense();
        
        driver.driversLicenseNo= '1234667' ;
        driver.state= 'AU' ;  
        idet.driverLicense = driver;
        tcmcon.identification = idet;
        tcmcon.status=  'Active';
        tcmcon.jobDescription= 'jobderscription' ;
        tcmcon.jobTitle=  'jobttile';
        tcmcon.languagePreference=  'English';
        TCMDataObject.CustomerAccounts custAcc =  new  TCMDataObject.CustomerAccounts();
        custAcc.accountUUID = '123467';
         tcmcon.customerAccounts = custAcc;
        TCMDataObject.ContactRelationship cr = new TCMDataObject.ContactRelationship();
         cr.contactType='Full Authority';
         tcmcon.customerAccounts.contactRelationship=cr;
        Contact con11;
        Contact con = TCMUtil.mapContactDataToContact(tcmcon, con11); 
         tcmConList.add(tcmcon);
        List<AccountContactRelation> acrList=TCMUtil.checkAndCreateAccountContactRelationships(tcmConList,a.Id); 
        system.assertNotEquals(null, con);  
         
    }
    
    static testmethod void mapAddressDataToAddresstest(){
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
       	c.Birthdate = Date.newInstance(2007, 2,10);
        insert c;
               
        // Create Account
            Account a = TestUtil.createAccount('Sample Account');
          	a.Pref_Comm_Method__c = 'B2B';
            insert a;
        // Create Address
        cscrm__Address__c add = TestUtil.createAddress();
        //add.cscrm__Account__c = a.ID;
        insert add;
        
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        // Add Address to Account
        TestUtil.addAddressToAccount(a.Id, add.Id);
        update a;
        cscrm__Account_Address_Relationship__c addR= TCMUtil.createAccountAddressRelationship(a.Id, add.Id,'Primary Address');
        cscrm__Account_Address_Relationship__c updateaddR= TCMUtil.updateAccountAddressRelationship(addR.Id);
        List<TCMDataObject.Address> tcmAddresses = new List<TCMDataObject.Address>();
        TCMDataObject.Address addss =  new TCMDataObject.Address();
		addss.addressId = '1323457';
        addss.state ='AU';
        addss.postalCode = '235647';
        addss.streetName = 'streetname';
         addss.streetType = 'typee';
         addss.streetNumberStart = '25687';
         addss.streetNumberEnd = '568799';
         addss.locality = 'pune';
         addss.country = 'India';
        addss.streetNumberEndSuffix='';
		addss.internationalPostcode='';
		addss.internationalState='';
		addss.deliveryPointId='';
		addss.registeredPlan='';
		addss.locality='';
		addss.streetTypeCode='';
		addss.streetTypeSuffix='';
		addss.streetTypeSuffixCode='';
        addss.subAddress = new TCMDataObject.SubAddress();
        
         addss.subAddress.buildingName = '';
        addss.subAddress.propertyName = '';
        addss.subAddress.numberStart = '';
        addss.subAddress.numberEnd = '';
        addss.subAddress.privateStreetName = '';
        addss.subAddress.privateStreetType = '';
        addss.subAddress.details = new List<TCMDataObject.Detail>();
        TCMDataObject.Detail detailItem = new TCMDataObject.Detail();
        detailItem.detailType = '';
        detailItem.value = '';
        addss.subAddress.details.add(detailItem);
        addss.subAddress.addressLines = new List<String>();
        addss.subAddress.addressLines.add('testAddress1');
        addss.subAddress.addressLines.add('testAddress2');
        addss.subAddress.addressLines.add('testAddress3');
             
        cscrm__Address__c  addres = TCMUtil.mapAddressDataToAddress(addss, null, a);
        tcmAddresses.add(addss);
        List<cscrm__Account_Address_Relationship__c>  adrList1 = TCMUtil.checkAndCreateAccountAddressRelationships(tcmAddresses,a.Id);
        List<cscrm__Account_Address_Relationship__c>  adrList2 = TCMUtil.checkAccountAddressRelationshipExistList(add.Id,a.Id,'Street');
        system.assertNotEquals(null, addres); 
    }
    
    static testmethod void getAccountByAccountIdtest(){
        Account a = TestUtil.createAccount('Sample Account');
        a.Pref_Comm_Method__c = 'B2B';
        insert a;
        String ids = String.valueOf( a.id);
           
        Account acc = TCMUtil.getAccountByAccountId(ids);
        system.assertNotEquals(null, acc); 
    }
    
    static testmethod void getAccountByUUIDtest(){
        Account a = TestUtil.createAccount('Sample Account');
        a.Account_UUID__c ='2354687';
        a.Pref_Comm_Method__c = 'B2B';
        insert a;
        String ids = String.valueOf( a.id);
           
        Account acc = TCMUtil.getAccountByUUID('2354687');
        system.assertNotEquals(null, acc);
    }
    
    static testmethod void getAccountByCustomerIdtetst(){
        Account a = TestUtil.createAccount('Sample Account');
        a.Customer_ID__c ='2354687';
        a.Pref_Comm_Method__c = 'B2B';
        insert a;
        String ids = String.valueOf( a.id);
           
        Account acc = TCMUtil.getAccountByCustomerId('2354687');
        system.assertNotEquals(null, acc);
    }
    
    static testmethod void getContactByUUIdtest(){
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.Birthdate = Date.newInstance(2007, 2,10);
        c.UUID__c = '123456';
        insert c;
        
        
        Contact acc = TCMUtil.getContactByUUId('123456');
        system.assertNotEquals(null, acc);
    }
    
    static testmethod void getContactBySalesforceContactIdtest(){
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.UUID__c = '123456';
        c.Birthdate = Date.newInstance(2007, 2,10);
        insert c;
        String ids = String.valueOf( c.id);
        
        Contact acc = TCMUtil.getContactBySalesforceContactId(ids);
        system.assertNotEquals(null, acc);
    }
    
    static testmethod void getContactsByExternalIdListtest(){
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.Birthdate = Date.newInstance(2007, 2,10);
        c.UUID__c = '123456';
       
        insert c;
        String ids = String.valueOf( c.id);
        list<String> externalid =  new list<String>{ids};
         Map<String,Contact> acc = TCMUtil.getContactsByExternalIdList(externalid);
        system.assertNotEquals(null, acc);
    }
    
    
    static testmethod void getAccountsByContIdtest(){
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.Birthdate = Date.newInstance(2007, 2,10);
        insert c;
        
        // Create Account
        Account a = TestUtil.createAccount('Sample Account');
        a.Pref_Comm_Method__c = 'B2B';
        insert a;
        
        // Add Contact to Account
        TestUtil.addContactToAccount(a.Id, c.Id);
        update a;
        
        List<AccountContactRelation> acccontat = TCMUtil.getAccountsByContId(c.id);
        system.assertNotEquals(null, acccontat);
    }
    
    static testmethod void FaultTest(){
         Account a = TestUtil.createAccount('Sample Account');
        a.Pref_Comm_Method__c = 'B2B';
        a.Customer_ID__c='900000';
        insert a;
        TCMDataObject.Fault fault =  new TCMDataObject.Fault();
        fault.faultCode = '100';
        fault.faultString='error message';
        fault.faultActor='actor';
        fault.serverName='TCM';
        fault.processId='pid123';
        fault.threadId='T1234';
        fault.programName='pName';
        fault.programLocation='Location';
        fault.timestamp='';
        fault.initiatingEntityId='';
        fault.programStatusCode='';
        fault.programStatusDescription='';
        fault.programFaultId='';
        fault.programFaultDescription='';
        fault.faultCategory='';
        fault.entityName='';
        fault.entityValue='900000';
        Exception__c exp = TCMUtil.mapRequestToException(fault);
         system.assertNotEquals(null, exp);
            
}
    
 }