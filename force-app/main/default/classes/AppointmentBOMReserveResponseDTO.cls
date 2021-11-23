/*-------------------------------------------------------------------
        Updating this class as per EDGE - 66470, 70304 
        <25-04-2019> <Kalashree Borgaonkar>
        -------------------------------------------------------------------*/
    public class AppointmentBOMReserveResponseDTO {
        public Integer status;
        public String restime;
        public String correlationId;
        public String path;
        public String method;
        public String code;
        public String message;
        //EDGE - 66470, 70304 
        public Request request;
        public List<Errors> errors;
        public Data data;
        

        public class Data {
            public String transactionReferenceID;
            public String callingSystemID;
            public String appointmentCategory;
            public String appointmentID;
            public List<Dependencies> dependencies;
            //EDGE - 66470, 70304, 66451, 66474 
            public String oldAppointmentID;
            public String reservationReference;
            public String reservationConditions;
            public Appointment appointment; 
           
        }
        public class Dependencies{
            public String appointmentCategory;
            public String appointmentType;
            public String appointmentSubType;
            public String suggestedStartDate;
            public String minimumStartDate;
            public String appointmentID;
            public String currentSlotStartDate;
            public String currentSlotEndDate;
            public String rescheduleRequired;
            public String leadTimeDaysApplied;
                
        }
         //EDGE - 66470, 70304 
        public class Appointment {
            public String appointmentCategory;
        }
         //EDGE - 66470, 70304, 66451, 66474
        public class Errors {
            public String message;
            public String code;
        }
         //EDGE - 66470, 70304, 66451, 66474 
        public class Request {
            public String correlationId;
            public Data data;
        }
        
        public static AppointmentBOMReserveResponseDTO parse(String json) {
            return (AppointmentBOMReserveResponseDTO) System.JSON.deserialize(json.replace('time', 'restime'), AppointmentBOMReserveResponseDTO.class);
        }
    }