//US: EDGE-66239/66226
    //Author: Ila Anmol Verma
    //Description: Generate appointment pre requisite for BOM 

    public class AppointmentResponseDTO {

        public Integer status {get;set;}
        public String resTime {get;set;}
        public String correlationId {get;set;}
        public String path {get;set;}
        public String method {get;set;}
        public String code {get;set;}
        public String message{get;set;}
        public Data data {get;set;}
        
        public class Data {
            public String transactionReferenceID {get;set;}
            public String callingSystemID {get;set;}
            public String bomID {get;set;}
            public Integer numberOfAppointmentsRequired {get;set;}
            public List<RequiredAppointments> requiredAppointments {get;set;}
        }
        public class RequiredAppointments {
            public Integer arrayItemNumber {get;set;}
            public String appointmentCategory {get;set;}
            public String appointmentType {get;set;}
            public String appointmentSubType {get;set;}
            public String suggestedStartDate {get;set;}
            public String minimumStartDate {get;set;}
            public List<Dependencies> dependencies {get;set;}
            public List<BaseRuleProducts> baseRuleProducts {get;set;}
        }

        public class Dependencies {
            public Integer dependentArraryItemNumber {get;set;}
            public Integer leadTimeDaysApplied {get;set;}
        }

        public class BaseRuleProducts {
            public String productID {get;set;}
            public String productInstanceID {get;set;}
        }
        
        public static AppointmentResponseDTO parse(String json) {
            return (AppointmentResponseDTO) System.JSON.deserialize(json.replace('time', 'resTime'), AppointmentResponseDTO.class);
        }
    }