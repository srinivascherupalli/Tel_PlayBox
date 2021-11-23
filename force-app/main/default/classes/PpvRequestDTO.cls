public with sharing class PpvRequestDTO {
public String correlationId;
	public String timestamp;
	public Data data;

	public class Data {
		public String externalId;
		public String portNumber;
		public String prePaidBrand;
	}

	
	public static PpvRequestDTO parse(String json) {
		return (PpvRequestDTO) System.JSON.deserialize(json, PpvRequestDTO.class);
	}
}