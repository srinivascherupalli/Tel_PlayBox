/**
     * Description : DTO class for Slot Availability Request for Site
     * Authors: Jawahar, Ravi, Ila
     * EDGE: 66237, 66466, 66475, 70303, 66469
     */
    public class AppointmentSearchResponseDTO {

        public class AvailableSlots {
            public String slotID{get;set;}
            //public List<String> slotID{get;set;}
            public String slotType{get;set;}
            public String startDate{get;set;}
            public String endDate{get;set;}
        }

        public Integer status;
        public Datetime timing;
        public String correlationId;
        public String path;
        public String method;
        public String message;
        public String code;
        public Data data;
        public Errors errors;

        public class CauseEvent {
            public String eventReason;
            public Datetime eventStartDate;
            public Datetime eventEndDate;
            public Integer estimatedDuration;
        }

        public class Data {
            public String transactionReferenceID;
            public String callingSystemID;
            public List<AvailableSlots> availableSlots{get;set;}
            public CauseEvent causeEvent;
            public Integer estimatedDuration;
        }
        
        public class Errors {
                public String message;
                public String code;

        }
        
        public static AppointmentSearchResponseDTO parse(String json) {
             String jsonString = json.replace('"time"', '"timing"');
            return (AppointmentSearchResponseDTO) System.JSON.deserialize(jsonString, AppointmentSearchResponseDTO.class);
        }
    }