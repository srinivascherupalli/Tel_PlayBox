/**
 * Description : DTO class for Reschedule Appointment Request for Site
 */
public class AppointmentRescheduleRequestDTO {
    public Data data {get;set;}
    
    public class Data {
        public String startDate {get;set;}
        public String endDate {get;set;}
        public String searchType {get;set;}
        public String rescheduleReason {get;set;}
    }
    public static AppointmentRescheduleRequestDTO parse(String json) {
		return (AppointmentRescheduleRequestDTO) System.JSON.deserialize(json, AppointmentRescheduleRequestDTO.class);
	}
}