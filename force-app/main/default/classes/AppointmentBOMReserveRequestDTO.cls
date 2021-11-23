/* Description: Request DTO class for Appointment BOM Reserve EDGE-66238
       Author: Aishwarya Yeware
     */

    public class AppointmentBOMReserveRequestDTO {
        
        public String correlationId {get;set;}
        public Data data {get;set;}
        
        
        public class Data {
            public String transactionReferenceID {get;set;} 
            public Appointment appointment {get;set;}
        }

        public class Appointment {
            public String appointmentCategory {get;set;} 
            public String appointmentType {get;set;} 
            public String appointmentSubType {get;set;} 
            public List<Contacts> contacts {get;set;} 
            public RelatedParty relatedParty {get;set;} 
            public Note note {get;set;} 
            public AppointmentExtendedDetails appointmentExtendedDetails {get;set;} 
        }
        
        public class Contacts {
            public String fullName {get;set;} 
            public String givenName {get;set;} 
            public String familyName {get;set;} 
            public String phoneNumber {get;set;} 
            public String role {get;set;} 
        }

        public class RelatedParty {
            public String name {get;set;} 
            public String role {get;set;} 
            public String type {get;set;}
        }

        public class Note {
            public String text {get;set;}
        }
        
        public class AppointmentExtendedDetails {
            public String extensionType {get;set;} 
            public String extensionName {get;set;} 
            public String extensionNameQualifier {get;set;} 
            public String extensionValue {get;set;} 
            public String extensionValueQualifier {get;set;} 
        }
        
        public static AppointmentBOMReserveRequestDTO parse(String json) {
            return (AppointmentBOMReserveRequestDTO) System.JSON.deserialize(json, AppointmentBOMReserveRequestDTO.class);
        }
       
    }