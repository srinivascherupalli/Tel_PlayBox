public class SimRequestDTO {
    
    public List<String> simSerialNumbers;
	public Boolean imsiRequired;
	public Attributes attributes;

	public class Attributes {
		public Boolean allRequired;
		public List<String> names;
	}

	
	public static SimRequestDTO parse(String json) {
		return (SimRequestDTO) System.JSON.deserialize(json, SimRequestDTO.class);
	}

}