@isTest
public class ManageCustomerStatusTest {
    
    static testMethod void testDoPostwithAccount() {
        
        final Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '7000000001';
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        insert a;
        
        final ManageCustomerStatusRequest mcsr = new ManageCustomerStatusRequest();
        mcsr.data = new ManageCustomerStatusRequest.Data();
        mcsr.data.fault = new ManageCustomerStatusRequest.Fault();
        mcsr.data.fault.entityValue = a.Customer_ID__c;
        
        final ManageCustomerStatusResponse mcr = ManageCustomerStatus.doPost(mcsr);
        System.assertEquals('Success',mcr.Status); 
        
    }
    
    static testMethod void testDoPost_withoutAccount() {
        
        final Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '7000000001';
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '7000000001';
        insert a;
        
        final ManageCustomerStatusRequest mcsr = new ManageCustomerStatusRequest();
        mcsr.data = new ManageCustomerStatusRequest.Data();
        mcsr.data.fault = new ManageCustomerStatusRequest.Fault();
        mcsr.data.fault.entityValue = a.Id;
        
        final ManageCustomerStatusResponse mcr =ManageCustomerStatus.doPost(mcsr);
        System.assertEquals('Success',mcr.Status); 
        
    }
    
    static testMethod void testDoPostnullRequest() {
        
        final Account a = TestUtil.createAccount('My Awesome Account');
        a.Customer_ID__c = '7000000001';
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '7000000001';
        insert a;
        
        final ManageCustomerStatusRequest mcsr = null;
        
        final ManageCustomerStatusResponse mcr = ManageCustomerStatus.doPost(mcsr);
         System.assertEquals('Success',mcr.Status);
    }
}