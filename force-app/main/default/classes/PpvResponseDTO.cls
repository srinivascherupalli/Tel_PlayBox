public with sharing class PpvResponseDTO {
public class Errors {
		public String fields;
		public String message;
		public Integer code;
	}

	public Integer status;
	public Integer code;
	public String responseCode;
	public String correlationId;
	public String timeStamp;
	public String path;
	public String method;
	public Data data;
	public List<Errors> errors;

	public class Data {
		public String externalId;
		public String resourceId;
	}

	
	public static PpvResponseDTO parse(String json) {
		return (PpvResponseDTO) System.JSON.deserialize(json, PpvResponseDTO.class);
	}
}