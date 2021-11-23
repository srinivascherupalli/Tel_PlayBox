/**
     * Description : DTO class for Slot Availability Request for Site
     * Authors: Jawahar, Ravi
     * EDGE: 66237, 70303, 66469
     */

    public class AppointmentSearchRequestDTO   {


         public class Appointment {
            
            public Place place {get;set;} 
            public String appointmentCategory {get;set;} 
            public String appointmentType {get;set;} 
            public String appointmentSubType {get;set;} 
            public String priority {get;set;} 
            public String searchStartDate {get;set;} 
            public String searchEndDate {get;set;} 

        }
        
        public String correlationId {get;set;} 
        public Data data {get;set;} 
     
        public class Data {
           
            public String transactionReferenceID {get;set;} 
            public String bomID {get;set;} 
            public Appointment appointment {get;set;}
            public Reason reason {get;set;}
     
        }
        
        public class Place {
            public string id {get;set;} 
            public String type {get;set;} // in json: type

        }
        
        public class Reason {
            public String rebookReasonCode {get;set;}
            public String rescheduleReasonCode {get;set;}
            public String note {get;set;}
        }
        
        public static AppointmentSearchRequestDTO parse(String json){
                      return (AppointmentSearchRequestDTO) System.JSON.deserialize(json, AppointmentSearchRequestDTO.class);
                    }
    }