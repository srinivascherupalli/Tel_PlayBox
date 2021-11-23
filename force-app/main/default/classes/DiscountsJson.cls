public class DiscountsJson {

    public List<Discounts> discounts {get;set;} 
    
    public class CustomData {
        public Boolean promotion {get;set;} 
    }
    
    public class Discounts {
        public String source {get;set;} 
        public String version {get;set;} 
        public String discountPrice {get;set;} 
        public String discountCharge {get;set;} 
        public Double amount {get;set;} 
        public String type_x {get;set;} // in json: type
        public String chargeType {get;set;} 
        public Integer duration {get;set;} 
        public String recordType {get;set;} 
        public CustomData customData {get;set;} 
        public String description {get;set;} 
    }
    
    
    public static DiscountsJson parse(String json) {
        String jsonstring = json.replace('"type"', '"type_x"');
        return (DiscountsJson) System.JSON.deserializeStrict(jsonstring, DiscountsJson.class);
    }
    
}