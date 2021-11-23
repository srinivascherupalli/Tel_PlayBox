@isTest
public class ContactTriggerForFieldIdentifierTest {
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
         
        Interface_Activation__c iActivation=new Interface_Activation__c(name='Manage Contact');
        iActivation.Status__c=false;
        insert iActivation;
		Interface_Activation__c iActivation2=new Interface_Activation__c(name='Manage Customer');
        iActivation2.Status__c=false;
        insert iActivation2;
        IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
        iSettings.EnableManageInterfaces__c=true;
        insert iSettings;
     	List<sObject> ls = Test.loadData(Account.sObjectType, 'TCM_Account');
		List<sObject> con=Test.loadData(Contact.sobjectType, 'TCM_Contact');
     }
     static testMethod void testfieldidentifiermethod(){
        Test.startTest();
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        system.runAs(admin){
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        List<Contact> ls=[select id,birthdate from Contact where firstName='firstName'];
        List<Monitored_Field__mdt> objectTypeFields = [select Id, Field_API_Name__c,QualifiedApiName,DeveloperName,Object_Field_Monitor__r.DeveloperName,Object_Field_Monitor__r.Active__c from Monitored_Field__mdt where Object_Field_Monitor__r.DeveloperName='Contact' and Object_Field_Monitor__r.Active__c=true and test_data__c=true];
        if(objectTypeFields!=null && objectTypeFields.size()!=0){
            TestDataCheck.datacheck=true;
        }
        else
            TestDataCheck.datacheck=false;
        ls[0].birthdate=Date.newInstance(1994, 12, 12);
        update ls;
        system.assertNotEquals(Null, ls[0].birthdate);    
        }
        Test.stopTest();
    }
}