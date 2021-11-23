public class NumberNCSMobilityDTO {
    public List <Configuration> configurations {get;set;}
    public Schema schema {get;set;}
	public class Schema {
        public String name {get;set;}
        public String id {get;set;}
		public List<Attribute> attributes {get;set;}        
    }
	public class Attribute{
        public Boolean showInUI {get;set;}
        public Boolean required {get;set;}
		public String type {get;set;}
        public String name {get;set;}
    }
    public class Configuration{
        public String guid {get;set;}
        public String MobileNumber {get;set;}
        public String Status {get;set;}
        public String listCode {get;set;}
    }

    public static NumberNCSMobilityDTO parse(String jsonString) {
       //return (NumberNCSMobilityDTO) System.JSON.deserialize(jsonString, NumberNCSMobilityDTO.class);
        return (NumberNCSMobilityDTO) System.JSON.deserialize(jsonString.replace('"GUID"', '"GUID1"'), NumberNCSMobilityDTO.class);

	}
}