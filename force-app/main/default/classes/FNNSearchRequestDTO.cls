public class FNNSearchRequestDTO {
	public Data data {get;set;}
	public class Data {
		public String activityName {get;set;}	
		public String resourceType {get;set;}
		public String searchType {get;set;}	
		public String pattern {get;set;}	
		public String patternType {get;set;}	
		public Integer quantity {get;set;}
        public String premiumType {get;set;} //EDGE-138110 
		public String nationalDestinationCode {get;set;}
        //EDGE-100661 starts
        public String addressId {get;set;}
        public String geoParam {get;set;}
        public String geoParamValue {get;set;}
        //EDGE-100661 ends
        public String ageOut {get;set;} //Added as a part of production incident
	}
	public static FNNSearchRequestDTO parse(String json) {
		return (FNNSearchRequestDTO) System.JSON.deserialize(json, FNNSearchRequestDTO.class);
	}
}