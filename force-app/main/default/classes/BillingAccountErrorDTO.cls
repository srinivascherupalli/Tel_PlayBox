public class BillingAccountErrorDTO {

    public String code {get;set;}
    public String message {get;set;}
    public List<Errors> errors {get;set;}
    public String correlationId {get;set;}
    public String status {get;set;}

    public class Errors {
        public String code {get;set;}
        public String field {get;set;}
        public String message {get;set;}
    }

    public static BillingAccountErrorDTO parse(String json) {
        return (BillingAccountErrorDTO) System.JSON.deserialize(json, BillingAccountErrorDTO.class);
    }
}