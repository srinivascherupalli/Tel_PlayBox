public class NumberServSpecDTO {
    
    public String schemaId{get;set;}
    public Attribute attributes{get;set;}
    
    public class Attribute{
        public String FNN {get;set;}
        public String rangeFrom {get;set;}
        public String rangeTo {get;set;}
        public String status {get;set;}
        public String listCode {get;set;}
    }
    public static NumberServSpecDTO parse(String jsonString) {
    return (NumberServSpecDTO) System.JSON.deserialize(jsonString, NumberServSpecDTO.class);
  }
}