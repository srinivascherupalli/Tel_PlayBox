public class EDISSingleRequestDTO {
    public String correlationId {get;set;}
    public String path {get;set;}
    public String method {get;set;}
    public EDISReqDTO data {get;set;}
    
    public class EDISReqDTO{
        public String type {get;set;}
        public CustomerDetails customerDetails {get;set;}
        public ListingDetails listingDetails {get;set;}
        public ServiceOrderDetails serviceOrderDetails {get;set;}
        public CustomerContactAddress customerContactAddress {get;set;}
        // orderOriginIdentifier
        
    }
    
    public class CustomerDetails{
        public String customerID {get;set;}
        public String customerType {get;set;}
        public String familyName {get;set;}
        public String givenNames {get;set;}
		public String registeredCompanyName {get;set;}
		public String customerTitle {get;set;}
        public String customerContactGivenNames {get;set;}
        public String customerContactFamilyName {get;set;}
        public String contactPosition {get;set;}
        public String contactFNN {get;set;}
        public String contactEmail {get;set;}
    } 
    
	public class ListingDetails{
        public String familyOrEntityName {get;set;}
        public String organizationName {get;set;}
        public String givenNames {get;set;}
        public String listingFNN {get;set;}
		public String actionCode {get;set;}
		public String subactionCode {get;set;}
        public String reasonCode {get;set;}
    }
	
	public class ServiceOrderDetails{
        public String listCode {get;set;}
        public String orderType {get;set;}
        public String orderStatus {get;set;}
        public String serviceType {get;set;}
		public String orderID {get;set;}
		public String originatingSystem {get;set;}
		public String portFlag {get;set;}
		public String productName {get;set;}
		public String telstraAddressId {get;set;}
		public String soCreationTimestamp {get;set;}
		public String telstraCommitmentDate {get;set;}
		public String provisionCompletionDate {get;set;}
		public String temporaryServiceIndicator {get;set;}
		public String interimServiceIndicator {get;set;}
		public String alternateAddressFlag {get;set;}
		public String originalFNN {get;set;}
		public String originalFamilyName {get;set;}
		public String originalGivenNames {get;set;}
		public String originalAddressIdentifier {get;set;}
		public String lineItemStatus {get;set;}
        public String originalFamilyOrEntityName {get;set;}
    }
	
	public class CustomerContactAddress{
        public String ccaIdentifier {get;set;}
        public String ccaOverseasAddressLine1 {get;set;}
        public String ccaOverseasAddressLine2 {get;set;}
        public String ccaOverseasAddressLine3 {get;set;}
		public String ccaOverseasAddressCountryCode {get;set;}
	}
	
	public static EDISSingleRequestDTO parse(String json) {
        return (EDISSingleRequestDTO) System.JSON.deserialize(json, EDISSingleRequestDTO.class);
    }

}