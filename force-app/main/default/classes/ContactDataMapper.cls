public with sharing class ContactDataMapper {

	public static List<Contact> getContacts(String emailId) {
		return [ select id from Contact
	             where email in ( :emailId ) ];
	}
	
	public static List<AccountContactRelation> getAuthorizedAccounts(String contactId, String CIDN) {
		return [ select id, ContactId, AccountId, Roles
	                from AccountContactRelation
	                where roles in ( :system.label.LegalLessee, :system.label.FullAuthority ) and
	                contactId = :contactId
	                and AccountId in (
	                    select id from Account where cidn__c in ( :CIDN )
	                )
	    ];
	}
}