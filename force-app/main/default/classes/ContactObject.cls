public class ContactObject
{
    @AuraEnabled public Data data { get; set; }

    public class Data {
        @AuraEnabled public List<Contact> contacts { get; set; }
		@AuraEnabled public Paging paging { get; set; }
    }

    public class Contact {
		@AuraEnabled public String middleName { get; set; }
        @AuraEnabled public String preferredMethod { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String onlineFlag { get; set; }
        @AuraEnabled public List<CustomerAccount> customerAccounts { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public WorkContact workContact { get; set; }
        @AuraEnabled public String languagePreference { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public Identification identification { get; set; }
        @AuraEnabled public String birthDate { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public HomeContact homeContact { get; set; }
		@AuraEnabled public String sourceSystem { get; set; }
        @AuraEnabled public String lastVerifiedDate { get; set; }
        @AuraEnabled public String notes { get; set; }
        @AuraEnabled public String numberInHousehold { get; set; }
        @AuraEnabled public String occupation { get; set; }
        @AuraEnabled public String timeZone { get; set; }
        @AuraEnabled public String jobDescription { get; set; }
        @AuraEnabled public String jobTitle { get; set; }
        @AuraEnabled public String reviewedFlag { get; set; }
        @AuraEnabled public String mergeStatus { get; set; }
		@AuraEnabled public String lastUpdated {get;set;}
        @AuraEnabled public String parentSourceSystemAction { get; set; }
		@AuraEnabled public List<PersonalAddress> personalAddress {get;set;} 
		@AuraEnabled public List<BusinessAddress> businessAddress {get;set;} 
    }

    public class CustomerAccount {
        @AuraEnabled public String mmsOptIn { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String phoneOptIn { get; set; }
        @AuraEnabled public String emailOptIn { get; set; }
        @AuraEnabled public String businessUnit { get; set; }
        @AuraEnabled public ContactRelationship contactRelationship { get; set; }
        @AuraEnabled public String faceToFaceOptIn { get; set; }
        @AuraEnabled public String directMailOptIn { get; set; }
        @AuraEnabled public String dataSovereignty { get; set; }
        @AuraEnabled public String accountUuid { get; set; }
        @AuraEnabled public String smsOptIn { get; set; }
		@AuraEnabled public String lastUpdated {get;set;}
		@AuraEnabled public String customerCode {get;set;}
    }

    public class ContactRelationship {
        @AuraEnabled public String contactUsage { get; set; }
        @AuraEnabled public String contactType { get; set; }
        @AuraEnabled public String endDate { get; set; }
        @AuraEnabled public String verifiedDate { get; set; }
        @AuraEnabled public String expiryDate { get; set; }
    }

    public class WorkContact {
        @AuraEnabled public String faxNumber { get; set; }
        @AuraEnabled public String phoneNumber { get; set; }
        @AuraEnabled public String emailAddress { get; set; }
        @AuraEnabled public String mobileNumber { get; set; }
    }

    public class Identification {
        @AuraEnabled public DriverLicense driverLicense { get; set; }
    }

    public class DriverLicense {
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String dlNumber { get; set; }
    }

    public class HomeContact {
        @AuraEnabled public String faxNumber { get; set; }
        @AuraEnabled public String phoneNumber { get; set; }
        @AuraEnabled public String emailAddress { get; set; }
        @AuraEnabled public String mobileNumber { get; set; }
    }
    
	public class BusinessAddress {
		@AuraEnabled public String internationalState {get;set;} 
		@AuraEnabled public String isPrimary {get;set;} 
		@AuraEnabled public String status {get;set;} 
		@AuraEnabled public String streetNumberStartSuffix {get;set;} 
		@AuraEnabled public String state {get;set;} 
		@AuraEnabled public String lastUpdated {get;set;} 
		@AuraEnabled public String streetName {get;set;} 
		@AuraEnabled public String addressType {get;set;} 
		@AuraEnabled public String additionalInfo {get;set;} 
		@AuraEnabled public String addressId {get;set;} 
		@AuraEnabled public String country {get;set;} 
		@AuraEnabled public String internationalPostcode {get;set;} 
		@AuraEnabled public String streetTypeSuffix {get;set;} 
		@AuraEnabled public String postalCode {get;set;} 
		@AuraEnabled public String streetNumberEnd {get;set;} 
		@AuraEnabled public String registeredPlan {get;set;} 
		@AuraEnabled public String locality {get;set;} 
		@AuraEnabled public String streetNumberEndSuffix {get;set;} 
		@AuraEnabled public SubAddress subAddress {get;set;} 
		@AuraEnabled public String streetNumberStart {get;set;} 
		@AuraEnabled public String streetType {get;set;} 
	}

	public class PersonalAddress {
		@AuraEnabled public String internationalState {get;set;} 
		@AuraEnabled public String isPrimary {get;set;} 
		@AuraEnabled public String status {get;set;} 
		@AuraEnabled public String streetNumberStartSuffix {get;set;} 
		@AuraEnabled public String state {get;set;} 
		@AuraEnabled public String lastUpdated {get;set;} 
		@AuraEnabled public String streetName {get;set;} 
		@AuraEnabled public String addressType {get;set;} 
		@AuraEnabled public String additionalInfo {get;set;} 
		@AuraEnabled public String addressId {get;set;} 
		@AuraEnabled public String country {get;set;} 
		@AuraEnabled public String internationalPostcode {get;set;} 
		@AuraEnabled public String streetTypeSuffix {get;set;} 
		@AuraEnabled public String postalCode {get;set;} 
		@AuraEnabled public String streetNumberEnd {get;set;} 
		@AuraEnabled public String registeredPlan {get;set;} 
		@AuraEnabled public String locality {get;set;} 
		@AuraEnabled public String streetNumberEndSuffix {get;set;} 
		@AuraEnabled public SubAddress subAddress {get;set;} 
		@AuraEnabled public String streetNumberStart {get;set;} 
		@AuraEnabled public String streetType {get;set;} 
	}
	
	public class SubAddress {
		@AuraEnabled public String propertyName {get;set;} 
		@AuraEnabled public String privateStreetType {get;set;} 
		@AuraEnabled public String privateStreetName {get;set;} 
		@AuraEnabled public List<Details> details {get;set;} 
		@AuraEnabled public String numberStart {get;set;} 
		@AuraEnabled public String buildingName {get;set;} 
		@AuraEnabled public List<String> addressLines {get;set;} 
		@AuraEnabled public String numberEnd {get;set;} 
	}

	public class Details {
		@AuraEnabled public String detailType {get;set;} 
		@AuraEnabled public String value {get;set;} 
	}

    public class Paging {
        @AuraEnabled public string lastPage { get; set; }
        @AuraEnabled public string resultBlockSize { get; set; }
        @AuraEnabled public string offset { get; set; }
    }
    
    public static ContactObject parse(String json) {
        String jsonString = json.replace('"number"', '"dlNumber"');
        return (ContactObject) System.JSON.deserialize(jsonString, ContactObject.class);
    }
}