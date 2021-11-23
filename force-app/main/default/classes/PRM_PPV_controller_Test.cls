/**
* Description : Test Methods for covering class PRM_PPV_controller              
* Jira        : P2OB - 11853
* Author      : Team Hawaii : Ritika Jaiswal
* Date        : 15-Jan-2020 
**/

@isTest
public class PRM_PPV_controller_Test {
    
    public static testMethod void test_retrieveContactData(){ 
        Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
        insert customerAccount;
        Id contactRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(); 
        List<Contact> testContacts = PRMTestUtility.createContact(1, contactRectypeId, customerAccount[0].Id);
        insert testContacts;
        Test.startTest();
        List<Contact> contactList = PRM_PPV_controller.retrieveContactData('', customerAccount[0].id);
        Test.stopTest();
        System.assert(contactList != null && contactList.size()>= 0);
        
    }
}