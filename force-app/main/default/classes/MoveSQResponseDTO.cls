/*
 * DTO for Move SQ response
 */
public class MoveSQResponseDTO {
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
		public String fnnServiceabilityIndicator;
		public String reason;
		public String code;
	}

	public class Data {
		public List<NumberDetails> numberDetails;
	}

	public class ErrorDetails {
		public String fullNationalNumber;
		public String message;
		public String code;
	}
	
	public static MoveSQResponseDTO parse(String json) {
		String jsonString = json.replace('"time"', '"responseTime"');
		return (MoveSQResponseDTO) System.JSON.deserialize(jsonString, MoveSQResponseDTO.class);
	}
}