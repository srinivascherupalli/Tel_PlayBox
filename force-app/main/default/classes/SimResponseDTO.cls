public class SimResponseDTO {
    
    public class Errors {
		public String simNumber;
		public String message;
		public String code;
	}

	public Integer status;
	public Integer code;
	public String resTime;
	public String correlationId;
	public String path;
	public String method;
	public String responseCode;
	public String message;
	public String requestId;
	public List<Errors> errors;
	public Data data;

	public class Characteristics {
		public String name;
		public String value;
	}

	public class Data {
		public List<Resources> resources;
	}

	public class Resources {
		public String resourceId;
		public String resourceType;
		public String resourceState;
		public List<Characteristics> characteristics;
	}

	
	public static SimResponseDTO parse(String json) {
		return (SimResponseDTO) System.JSON.deserialize(json, SimResponseDTO.class);
	}

}