public class EDISSingleErrorResponseDTO {
	public Integer code {get;set;}
	public String message {get;set;}
    public String res_time {get;set;}
    public String correlationId {get;set;}
	public List<ErrorObject> errors {get;set;}
    public EDISSingleRequestDTO request {get;set;}
	public String respondTo {get;set;}
	
	public class ErrorObject {
		public Integer code {get;set;}
		public String message {get;set;}
	}
	
	public static EDISSingleErrorResponseDTO parse(String json) {
        return (EDISSingleErrorResponseDTO) System.JSON.deserialize(json, EDISSingleErrorResponseDTO.class);
    }
}