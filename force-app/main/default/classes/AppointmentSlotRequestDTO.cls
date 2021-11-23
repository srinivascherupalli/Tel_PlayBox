/**
 * Description : DTO class for Slot Availability Request for Site
 */
 public class AppointmentSlotRequestDTO {
    public Data data {get;set;}
    
    public class Data {
        public String startDate {get;set;}
        public String endDate {get;set;}
        public SlotSiteAddress address {get;set;}
        public List<SlotTask> taskItems {get;set;}
        //public Technician technician {get;set;}
    }
    
    public class SlotSiteAddress{
    	public String id {get;set;} 
    	//public Types type {get;set;} 
    }
    
    public class SlotTask{
		public String extTaskReferenceId {get;set;} 
    	//public VisitTypes visitType {get;set;} 
    	//public String serviceType {get;set;}
    	//public String purpose {get;set;}
    	public List<JobItem> jobItems {get;set;}
    	
    }
    public class JobItem{
		//public String extJobReferenceId {get;set;}
		public String technology {get;set;}
    	public String action {get;set;}
    	public String resourceType {get;set;}
    	public String description {get;set;}
    	//public VisitTypes visitType {get;set;}
		//public String serviceType {get;set;}
        public String quantity {get;set;}
    }
    /*public class Technician{
    	public string type {get;set;}
    	public String id {get;set;}
    }
    
    public ENUM VisitTypes {CP,FLD,EXG,RS}
	public ENUM Types {Preferred, Excluded, Required}     
    */
	public static AppointmentSlotRequestDTO parse(String json) {
		return (AppointmentSlotRequestDTO) System.JSON.deserialize(json, AppointmentSlotRequestDTO.class);
	}
 }