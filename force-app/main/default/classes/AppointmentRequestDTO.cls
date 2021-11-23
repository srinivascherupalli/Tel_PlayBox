//US: EDGE-66239/66226
    //Author: Ila Anmol Verma
    //Description: Generate appointment pre requisite for BOM 

    public class AppointmentRequestDTO {
        
        public String correlationId {get;set;}
        public Data data {get;set;}
        
        public class Data {
            public String callingSystemID {get;set;}
            public String ruleSetID {get;set;}
            public String notEarlierThanDate {get;set;}
            public String transactionType {get;set;}
            public String state {get;set;}
            public String locationType {get;set;}
            public String complexityBand {get;set;}
            public String transactionReferenceID {get;set;}
            public List<TransactionProducts> transactionProducts {get;set;}
        }

        public class TransactionProducts {
            public String productAction {get;set;}
            public String productID {get;set;}
            public String productInstanceID {get;set;}
            public String parentProductInstanceID {get;set;}
            public List<ProductParameters> productParameters {get;set;}
        }

        public class ProductParameters {
            public String parameterName {get;set;}
            public String parameterValue {get;set;}
        }

        public static AppointmentRequestDTO parse(String json) {
            return (AppointmentRequestDTO) System.JSON.deserialize(json, AppointmentRequestDTO.class);
        }
    }