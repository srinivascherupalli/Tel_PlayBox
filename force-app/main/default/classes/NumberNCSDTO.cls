public class NumberNCSDTO {
    public List <Configuration> configurations {get;set;}
    public Schema schema {get;set;}
    public class Attribute{
    	public String startDate {get;set;}    
        public Boolean shownInUI {get;set;}
        public Boolean required {get;set;}
        public String name {get;set;}
    }
    public class Schema {
        public String name {get;set;}
        public String id {get;set;}
		public List<Attribute> attributes {get;set;}        
    }
    public class Configuration{
        public String guid {get;set;}
        public String FNN {get;set;}
        public String rangeFrom {get;set;}
        public String rangeTo {get;set;}
        public String status {get;set;}
        public String listCode {get;set;}
    }

    public static NumberNCSDTO parse(String jsonString) {
		return (NumberNCSDTO) System.JSON.deserialize(jsonString.replace('"GUID"', '"GUID1"'), NumberNCSDTO.class);
	}
}