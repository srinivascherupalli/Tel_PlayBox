public class PortInSQResponseDTO {
	public Integer status;
	public Data data;
	public Errors errors;
    public String code;
	public String message;
	public String correlationId;
	public String Error_Code;
	public String Error_Description;
	public String responseTime;
	
	public class Errors {
		public List<ErrorDetails> errorDetails;
	}

	public class NumberDetails {
		public String fullNationalNumber;
		public String fnnPortabilityIndicator;
		public String reason;
		public String code;
		public String portInType;
		public String fnnServiceabilityIndicator;
	}

	public class Data {
		public List<NumberDetails> numberDetails;
	}

	public class ErrorDetails {
		public String fullNationalNumber;
		public String message;
		public String code;
	}

	public static PortInSQResponseDTO parse(String json) {
		String jsonString = json.replace('"time"', '"responseTime"');
		return (PortInSQResponseDTO) System.JSON.deserialize(jsonString, PortInSQResponseDTO.class);
	}
}