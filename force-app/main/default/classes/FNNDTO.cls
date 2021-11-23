public class FNNDTO
{
	@AuraEnabled
    public FNNDataObject data {get;set;}
    
	public class FNNDataObject {
        @AuraEnabled
        public String geoParam {get;set;}
		@AuraEnabled
        public String geoParamValue {get;set;}
		@AuraEnabled
        public String addressId	{get;set;}
		@AuraEnabled
        public String type {get;set;}
		@AuraEnabled
        public Integer quantity {get;set;}
		@AuraEnabled
        public String pattern {get;set;}
		@AuraEnabled
        public String searchType {get;set;}
		@AuraEnabled
        public String systemId {get;set;}		
		@AuraEnabled
        public String poolName {get;set;}
		@AuraEnabled
        public String activityName {get;set;}
		@AuraEnabled
        public String searchStatus {get;set;}
		@AuraEnabled
        public List<CategoryTypeDataObject> categoryType {get;set;}
		@AuraEnabled
        public List<String> serviceIds {get;set;}
	}
		
	public class CategoryTypeDataObject	{
		@AuraEnabled
        public String value {get;set;}
	}
    
    //public ENUM GeoParam 		{ESA, SZU, DISTRICT, ZONE, REGION, COUNTRY}
	//public ENUM Type 			{REGULAR, PREMIUM}
    //public ENUM SearchType 	{PHONEWORD,SEQUENTIAL_VALUES, RANDOMIZATION, RANDOM, CONTINUOUS}
    //public ENUM PoolName 		{PREPAID, POSTPAID, SATELLITE, NETWORK, HSDPA, FOREIGN_CARRIER, SCREENING_SECURITY}//,4GFW, BULK}
	//public ENUM ActivityName 	{DIRECT_HOLD, LOCK, RESERVE, HOLD}
	//public ENUM SearchStatus 	{AVAILABLE}
	//public ENUM CategoryType 	{TELSTRA_NUMBERS, EXTERNAL_NUMBERS, GOLD, SILVER, REGULAR}
	
	public static FNNDTO parse(String json) {
		return (FNNDTO) System.JSON.deserialize(json, FNNDTO.class);
	}
	
}