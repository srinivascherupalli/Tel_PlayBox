public with sharing class AppointmentReserveErrorDTO {
	
	public class Error{
		@AuraEnabled public Integer status {get; set;}
		@AuraEnabled public Integer code {get; set;}
		@AuraEnabled public String message {get; set;}
		@AuraEnabled public String dtime {get; set;} //time is reserved keyword
		@AuraEnabled public String correlationId {get; set;}
		@AuraEnabled public List<ErrorCodes> errors;
	}

	public class ErrorCodes{
		@AuraEnabled public String code {get; set;}
		@AuraEnabled public String message {get; set;}
	}
	
	public static AppointmentReserveErrorDTO.Error parse(String json){
		String jsonStr = json.replace('time', 'dtime');
		System.debug(jsonStr);
		return (AppointmentReserveErrorDTO.Error) System.JSON.deserialize(jsonStr, AppointmentReserveErrorDTO.Error.class);
	}
}