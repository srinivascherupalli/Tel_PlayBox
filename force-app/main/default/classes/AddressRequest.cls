public class AddressRequest {
    public String correlationId {get;set;}
    public Data data {get;set;}
	public SearchData searchData {get;set;}
    
    public class Data {
        public SearchOptions searchOptions {get;set;}
        public SearchData searchData {get;set;}
        public RequestParams requestParams {get;set;}
    }

    public class SearchOptions {
        public String sortType {get;set;}
        public Integer addressesToSkip {get;set;}
        public Integer addressesToReturn {get;set;}
        public FuzzyOptions fuzzyOptions {get;set;}
        public String addressType {get;set;}
        public List<String> responseFormats {get;set;} 
    }
    
    public class FuzzyOptions {
        public Boolean enabled {get;set;}
    }
    
    public class SearchData {
        public String addressType {get;set;}
        public String addressSubType {get;set;}
        public String unitNumber {get;set;}
        public String postalDeliveryNumber {get;set;}
        public String ruralMailNumber {get;set;}
        public String planNumber {get;set;}
        public String parcelNumber {get;set;}
        public String streetNumber {get;set;}
        public String streetName {get;set;}
        public String streetSuffix {get;set;}
        public String streetType {get;set;}
        public String suburb {get;set;}
        public String state {get;set;}
        public String postcode {get;set;}
        public String addressLine1 {get;set;}
        public String addressLine2 {get;set;}
        public String addressLine3 {get;set;}
    }
    
    public class RequestParams {
        public String adborId {get;set;}
    }
	
	
    public static AddressRequest parse(String json) {
        return (AddressRequest) System.JSON.deserialize(json, AddressRequest.class);
    }
}