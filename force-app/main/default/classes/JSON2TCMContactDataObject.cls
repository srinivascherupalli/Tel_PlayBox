/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to handle the JSON response object
    INTERFACE:	/v1/customer-self-management/tcm/contacts/{id}?include=customer-accounts
*/

public class JSON2TCMContactDataObject {
    public class CustomerAccounts {
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String href {get;set;}
		@AuraEnabled public String accountUuid {get;set;}
		@AuraEnabled public String lastName {get;set;}
		@AuraEnabled public ContactRelationship contactRelationship {get;set;}
	}

	public class HomeContact {
		@AuraEnabled public String emailAddress {get;set;}
		@AuraEnabled public String faxNumber {get;set;}
		@AuraEnabled public String phoneNumber {get;set;}
		@AuraEnabled public String mobileNumber {get;set;}
	}

	public class DriverLicense {
		@AuraEnabled public String id_number {get;set;}
		@AuraEnabled public String state {get;set;}
	}

	public class Identification {
		@AuraEnabled public DriverLicense driverLicense {get;set;}
	}

	@AuraEnabled public String id {get;set;}
	@AuraEnabled public String href {get;set;}
	@AuraEnabled public String title {get;set;}
	@AuraEnabled public String firstName {get;set;}
	@AuraEnabled public String middleName {get;set;}
	@AuraEnabled public String lastName {get;set;}
	@AuraEnabled public String birthDate {get;set;}
	@AuraEnabled public String status {get;set;}
	@AuraEnabled public String onlineFlag {get;set;}
	@AuraEnabled public String preferredMethod {get;set;}
	@AuraEnabled public HomeContact homeContact {get;set;}
	@AuraEnabled public HomeContact workContact {get;set;}
	@AuraEnabled public Identification identification {get;set;}
	@AuraEnabled public List<CustomerAccounts> customerAccounts {get;set;}

	public class ContactRelationship {
		@AuraEnabled public String endDate {get;set;}
		@AuraEnabled public String contactType {get;set;}
		@AuraEnabled public String contactUsage {get;set;}
	}
}