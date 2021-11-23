public class FNNSearchResponseDTO {

	public Integer status;
	public Integer code;
	public String time_x;
	public String correlationId;
	public String path;
	public String method;
	public String responseCode;
    public String message;
	public Data data;
	//public List<Errors> errors {get;set;} 

	public class Data {
		public String requestedQuantity;
		public String returnedQuantity;
		public List<Resources> resources;
		public String ageOut {get;set;}
	}

	public class Resources {
		public String resourceType {get;set;}
		public String resourceId {get;set;}
		public String countryCode {get;set;}
		public String countryName{get;set;}
		public String nationalDestinationCode{get;set;}
		public String startRange {get;set;}
		public String endRange {get;set;}
		public String poolName {get;set;}
		public String premiumType {get;set;}
		public String providedToKey {get;set;}
		public String activityStatus {get;set;}
		public String resourceState {get;set;}
		public String ageOut {get;set;}
		public String ageOutDate {get;set;}
	}
	/*public class Errors {
		
		public String system_Z {get;set;} 
		public String code {get;set;} 
		public String message {get;set;}
    }*/
	
	public static FNNSearchResponseDTO parse(String json) {
        json = json.replace('time', 'time_x');
        //json = json.replace('system', 'system_Z');
		return (FNNSearchResponseDTO) System.JSON.deserialize(json, FNNSearchResponseDTO.class);
	}
}