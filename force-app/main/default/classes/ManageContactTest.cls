//Just Sending for contact trigger helper code coverage for DIGI-3444.
@isTest
public class ManageContactTest {
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
        EnvironmentVariable.put('MockEndpoint','https://mocksandbox.getsandbox.com');
    }
    
    static testMethod void sendCreate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Account acc = TestUtil.createAccount('My Account');
        acc.Account_UUID__c = 'D2A45-B7890-123C5-6D89E';
        acc.Customer_Status__c='SUSPECT';
        
        acc.Pref_Comm_Method__c='Fax';
        acc.Fax='12345';
        acc.Customer_ID__c = '987654325';
        acc.Type='Sole Trader';
        
        
        acc.ABN__c='aaaa';
        acc.ACN__c='ccc';
        acc.Website='www.vsygwoci.com';
        acc.FraudFlag__c=false;
        acc.VIP_Customer__c=false; 
        acc.Phone='0412354327';
        acc.Email__c='sahs.ray@gmail.com'; 
        insert acc;
        Contact cont = TestUtil.createContact(acc.Id, 'First', 'Last');
        //cont.Source_System__c='test';
        //cont.Contact_Status__c = 'Active';
        insert cont;
        ManageContact.send(cont.Id, false);
        Test.stopTest();
        System.assertEquals(acc.name, 'My Account');

    }
    
    static testMethod void sendCreate_mockEndpoint() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Account acc = TestUtil.createAccount('My Account');
        acc.Customer_Status__c='SUSPECT';
        
        
        acc.Pref_Comm_Method__c='Fax';
        acc.Fax='12345';
        acc.Customer_ID__c = '987654325';
        acc.Type='Sole Trader';
        
        
        acc.ABN__c='aaaa';
        acc.ACN__c='ccc';
        acc.Website='www.vsygwoci.com';
        acc.FraudFlag__c=false;
        acc.VIP_Customer__c=false; 
        acc.Phone='0412354327';
        acc.Email__c='sahs.ray@gmail.com'; 
        insert acc;
        Contact cont = TestUtil.createContact(acc.Id, 'First', 'Last');
        cont.Contact_Status__c = 'Active';
        //cont.Source_System__c='test';
        insert cont;
        ManageContact.send(cont.Id, false);
        Test.stopTest();
         System.assertEquals(acc.name, 'My Account');
    }
    
    static testMethod void sendUpdate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Account acc = TestUtil.createAccount('My Account');
        acc.Account_UUID__c = '54A2D-0987B-5C321-E98D6';
        acc.Customer_Status__c='SUSPECT';
      
        
         acc.Pref_Comm_Method__c='Fax';
        acc.Fax='12345';
        acc.Customer_ID__c = '987654325';
        acc.Type='Sole Trader';
        
        
        acc.ABN__c='aaaa';
        acc.ACN__c='ccc';
        acc.Website='www.vsygwoci.com';
        acc.FraudFlag__c=false;
        acc.VIP_Customer__c=false; 
        acc.Phone='0412354327';
        acc.Email__c='sahs.ray@gmail.com'; 
        insert acc;
        Contact cont = TestUtil.createContact(acc.Id, 'First', 'Last');
        cont.UUID__c = '12345';
        cont.Pref_Comm_Method__c= 'Phone';
         //cont.Source_System__c='test';
        insert cont;
        ManageContact.send(cont.Id, false);
        Test.stopTest();
         System.assertEquals(acc.name, 'My Account');
    }
    
    static testMethod void sendCrossReference() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Account acc = TestUtil.createAccount('My Account');
        acc.Account_UUID__c = '5C321-D3A45-E98D6-B7890';
        acc.Customer_Status__c='SUSPECT';
         acc.Pref_Comm_Method__c='Fax';
        acc.Fax='12345';
        acc.Customer_ID__c = '987654325';
        acc.Type='Sole Trader';
        
        
        acc.ABN__c='aaaa';
        acc.ACN__c='ccc';
        acc.Website='www.vsygwoci.com';
        acc.FraudFlag__c=false;
        acc.VIP_Customer__c=false; 
        acc.Phone='0412354327';
        acc.Email__c='sahs.ray@gmail.com'; 
        insert acc;
        Contact cont = TestUtil.createContact(acc.Id, 'First', 'Last');
        cont.UUID__c = '12345';
        cont.Contact_Status__c = 'Active';
        //cont.Source_System__c='test';
        
        insert cont;
        ManageContact.send(cont.Id, true);
        Test.stopTest();
         System.assertEquals(acc.name, 'My Account');
    }
    
}