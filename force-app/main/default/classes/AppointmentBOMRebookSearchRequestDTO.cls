/**
 * Description : DTO class for Rebook Slot Availability Request for Site
 * Authors: Jawahar, Ila
 * EDGE: 66466, 66475
 */

public class AppointmentBOMRebookSearchRequestDTO   {


     public class Appointment {
        
        
        public String appointmentCategory {get;set;} 
        public String priority {get;set;} 
        public String searchStartDate {get;set;} 
        public String searchEndDate {get;set;} 

    }
    
    public String correlationId {get;set;} 
    public Data data {get;set;} 
 
    public class Data {
       
        public String transactionReferenceID {get;set;} 
        public Appointment appointment {get;set;}
        public Reason reason {get;set;}
 
    }
    
    public class Reason {
        public String rebookReasonCode {get;set;}
        public String note {get;set;}
    }
    
    public static AppointmentBOMRebookSearchRequestDTO   parse(String json){
                  return (AppointmentBOMRebookSearchRequestDTO) System.JSON.deserialize(json, AppointmentBOMRebookSearchRequestDTO.class);
                }
}