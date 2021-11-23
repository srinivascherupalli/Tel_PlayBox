@isTest
public class CreateAddressAndContactRelationshipTest {
	@testSetup 
    static void setup() {
        List<Contact> contacts = new List<Contact>();
        // insert 10 accounts
        for (Integer i=0;i<70;i++) {
            contacts.add(new Contact(LastName='Last Name'+i,MailingCity='New York', MailingCountry='USA', MailingState='MH',MailingStreet='DP', MailingLatitude=1.10, MailingLongitude=10.10, MailingPostalCode='123',
                                     OtherCity='Home City', OtherCountry='USA', OtherState='MH',OtherStreet='DP', OtherLatitude=1.10, OtherLongitude=10.10, OtherPostalCode='123'));
        }
        insert contacts;
    }

    static testmethod void test() {        
        
        String q = 'SELECT Id,MailingLatitude,MailingLongitude,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet, OtherAddress,OtherCity,OtherCountry,OtherGeocodeAccuracy,OtherLatitude,OtherLongitude,OtherPhone,OtherPostalCode,OtherState,OtherStreet FROM Contact ' ; 
		Integer i = [SELECT count() FROM Contact];
        system.debug('TEST TOTAL :'+i);
        Test.startTest();
        Database.executeBatch(new CreateAddressAndContactRelationship(q)); 
        Test.stopTest();

        // after the testing stops, assert records were updated properly
        System.assertEquals(70, [select count() from cscrm__Contact_Address_Relationship__c where cscrm__Address_Type__c = 'Office Address']);
        System.assertEquals(70, [select count() from cscrm__Contact_Address_Relationship__c where cscrm__Address_Type__c = 'Home Address']);
    }
}