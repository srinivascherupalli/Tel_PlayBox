//Last Modified : updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
@isTest
public class SyncUpContactTCMBatch_Test{
    @testSetup 
    static void setup() {
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
    }
    static List<Contact>getContactList(Integer num){
     Account acc = TestUtil.createAccount('Sample Account'+num);
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0;i<num;i++){
        Contact cont = TestUtil.createContact('Joe', 'Bloggs'+i);
        if(i<10){
            cont.MobilePhone = '044567800'+i;
                }else{
            cont.MobilePhone = '04456780'+i;
                }
            cont.lastname='abc';
        cont.UUID__c = 'D26A5DC2-F907-4a69-9D87-FFBC8DAFBF3'+i;
        cont.AccountId = acc.id;
        
        contactList.add(cont);
        }
        return contactList;
    }
    static List<cscrm__Contact_Address_Relationship__c>getContactAddrList(List<Contact> contactList,cscrm__Address__c address1){
        List<cscrm__Contact_Address_Relationship__c> contactAddrList = new List<cscrm__Contact_Address_Relationship__c>();
        Integer i = 0;
       
        for(Contact cont: contactList){
            cscrm__Contact_Address_Relationship__c contrel = new cscrm__Contact_Address_Relationship__c();
            contrel.cscrm__Contact__c = cont.id;
            contrel.cscrm__Address__c = address1.id;
            contrel.cscrm__Active__c = true;
            contrel.cscrm__Address_Type__c = 'Home Address';
            contrel.Primary__c = true;
        
            if (i == 0){
                contrel.cscrm__End_Date__c = Date.today();
                i = i+1;
            }
  
            contactAddrList.add(contrel);
        }
        return contactAddrList;
    }
    @isTest
    static void positiveTest(){
  
        List<Contact> contactList = getContactList(15);
        insert contactList;
        System.assertEquals(contactList.size(), 15);    
        cscrm__Address__c address1 = new cscrm__Address__c();
        address1.Address_ID__c = '123';
        address1.cscrm__Street__c  = '150 TEST ROAD TEST';
        address1.cscrm__Address_Type__c ='Property With Number';
        address1.AddressCorrection__c = true;
        insert address1;
        
        List<cscrm__Contact_Address_Relationship__c> contactAddrList = getContactAddrList(contactList,address1);
        insert contactAddrList;
        System.assertEquals(contactAddrList.size(), 15);    
        Test.startTest();
        try{
            SyncUpContactTCMBatch invokeSyncObj = new SyncUpContactTCMBatch();
            Test.setMock(HttpCalloutMock.class, new SyncUpMockHttpResponseGenerator());
            Database.executeBatch(invokeSyncObj,15);
        }catch(Exception e){
              System.debug('Exception: '+e) ;
        }
        Test.stopTest();
    }
    @isTest
    static void negativeTest(){
        List<Contact> contactList = getContactList(15);
        insert contactList;
        System.assertEquals(contactList.size(), 15);  
        cscrm__Address__c address1 = new cscrm__Address__c();
        address1.Address_ID__c = '123';
        address1.cscrm__Street__c  = '150 TEST ROAD TEST';
        address1.cscrm__Address_Type__c ='Property With Number';
        address1.AddressCorrection__c=true;
        insert address1;
        
        List<cscrm__Contact_Address_Relationship__c> contactAddrList = getContactAddrList(contactList,address1);
        insert contactAddrList;
        System.assertEquals(contactAddrList.size(), 15);    
        Test.startTest();
        try{
            SyncUpContactTCMBatch invokeSyncObj = new SyncUpContactTCMBatch();
            Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
            Database.executeBatch(invokeSyncObj,15);
        }catch(Exception e){
              System.debug('Exception:'+e) ;
        }
        Test.stopTest();
    }
    static testMethod void testManageContactTCM(){
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

}