public class AppointmentSlotResponseDTO {
    public Data data;
    
    public class Data {
    	public List<AvailableSlot> availableSlots{get;set;}
    	public CauseEvent causeEvent;
    	//public String estimatedDuration;
    	//public String obligatoryCompletionDate;
    	public String visitType;
    	public List<Task> taskItems;
    }
    
    public class AvailableSlot{
    	public String id{get;set;}
    	public String startDate{get;set;}
    	public String endDate{get;set;}
    	//public Period committedPeriod{get;set;}
    }
    /*public class Period{
    	public String startDate;
    	public String endDate;
    }*/
    
    public class CauseEvent{
    	public String reason;
    	public String startDate;
    	public String endDate;
    }
    public class Task {
    	public String id;
    	public List<JobItem> jobItems;
    }
    public class JobItem{
    	public String id;
    	public String technology;
    	public String action;
    	public String resourceType;
    }
    
    public static AppointmentSlotResponseDTO parse(String json) {
		String jsonString = json.replace('"time"', '"responseTime"');
		return (AppointmentSlotResponseDTO) System.JSON.deserialize(jsonString, AppointmentSlotResponseDTO.class);
	}
}