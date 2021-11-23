/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to handle the JSON response object
    INTERFACE:	/v1/customer-self-management/tcm/customer-accounts?abn={abn}&acn={acn}&firstName={firstName}&lastName={lastName}&birthDate={birthdate}&cac={cac}&cidn={cidn}
*/

public class JSON2TCMCustomerDataObject {
	
	public class Contacts {
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String href {get;set;}
		@AuraEnabled public String title {get;set;}
		@AuraEnabled public String firstName {get;set;}
		@AuraEnabled public String middleName {get;set;}
		@AuraEnabled public String lastName {get;set;}
		@AuraEnabled public String birthDate {get;set;}
		@AuraEnabled public String endDate {get;set;}
		@AuraEnabled public String contactType {get;set;}
		@AuraEnabled public String contactUsage {get;set;}
		@AuraEnabled public String preferredMethod {get;set;}
		@AuraEnabled public HomeContact homeContact {get;set;}
		@AuraEnabled public HomeContact workContact {get;set;}
	}


	public class HomeContact {
		@AuraEnabled public String emailAddress {get;set;}
		@AuraEnabled public String faxNumber {get;set;}
		@AuraEnabled public String phoneNumber {get;set;}
		@AuraEnabled public String mobileNumber {get;set;}
	}
	
	public class Details {
		@AuraEnabled public String detailType {get;set;} 
		@AuraEnabled public String detailTypeCode {get;set;} 
		@AuraEnabled public String value {get;set;} 
	}
	
	public class Address {
		@AuraEnabled public String isPrimary {get;set;} 
		@AuraEnabled public String status {get;set;} 
		@AuraEnabled public String statusCode {get;set;} 
		@AuraEnabled public String addressType {get;set;} 
		@AuraEnabled public String addressTypeCode {get;set;} 
		@AuraEnabled public String country {get;set;} 
		@AuraEnabled public String state {get;set;} 
		@AuraEnabled public String postCode {get;set;} 
		@AuraEnabled public String addressId {get;set;} 
		@AuraEnabled public String streetName {get;set;} 
		@AuraEnabled public String streetType {get;set;} 
		@AuraEnabled public String streetTypeCode {get;set;} 
		@AuraEnabled public String streetTypeSuffix {get;set;} 
		@AuraEnabled public String streetTypeSuffixCode {get;set;} 
		@AuraEnabled public String streetNumberStart {get;set;} 
		@AuraEnabled public String streetNumberStartSuffix {get;set;} 
		@AuraEnabled public String streetNumberEnd {get;set;} 
		@AuraEnabled public String streetNumberEndSuffix {get;set;} 
		@AuraEnabled public String internationalPostCode {get;set;} 
		@AuraEnabled public String internationalState {get;set;} 
		@AuraEnabled public String deliveryPointId {get;set;} 
		@AuraEnabled public String registeredPlan {get;set;} 
		@AuraEnabled public String locality {get;set;} 
		@AuraEnabled public String additionalInfo {get;set;} 
		@AuraEnabled public SubAddress subAddress {get;set;} 
		@AuraEnabled public List<String> addressLines {get;set;} 
	}
	
	@AuraEnabled public String id {get;set;} 
	@AuraEnabled public String href {get;set;} 
	@AuraEnabled public String cidn {get;set;} 
	@AuraEnabled public String cac {get;set;} 
	@AuraEnabled public String title {get;set;} 
	@AuraEnabled public String firstName {get;set;} 
	@AuraEnabled public String lastName {get;set;} 
	@AuraEnabled public String birthDate {get;set;} 
	@AuraEnabled public String abn {get;set;} 
	@AuraEnabled public String acn {get;set;} 
	@AuraEnabled public String phoneNumber {get;set;} 
	@AuraEnabled public String faxNumber {get;set;} 
	@AuraEnabled public String emailAddress {get;set;} 
	@AuraEnabled public String accountUuid {get;set;} 
	@AuraEnabled public String businessUnit {get;set;} 
	@AuraEnabled public String customerManagedFlag {get;set;} 
	@AuraEnabled public String customerType {get;set;} 
	@AuraEnabled public String marketSegment {get;set;} 
	@AuraEnabled public String priorityAssistFlag {get;set;} 
	@AuraEnabled public String accountStatus {get;set;} 
	@AuraEnabled public List<Address> address {get;set;} 
	@AuraEnabled public List<Contacts> contacts {get;set;}
	
	public class SubAddress {
		@AuraEnabled public String buildingName {get;set;} 
		@AuraEnabled public String propertyName {get;set;} 
		@AuraEnabled public String numberStart {get;set;} 
		@AuraEnabled public String numberEnd {get;set;} 
		@AuraEnabled public String privateStreetName {get;set;} 
		@AuraEnabled public String privateStreetType {get;set;} 
		@AuraEnabled public String privateStreetTypeCode {get;set;} 
		@AuraEnabled public List<Details> details {get;set;} 
	}
}