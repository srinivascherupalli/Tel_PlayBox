public class EDISSingleResponseDTO {
    public Integer code {get;set;}
    public String res_time {get;set;}
    public String correlationId {get;set;}
    public EDISDataDTO data {get;set;}
	public EDISSingleRequestDTO request {get;set;}
	public String respondTo {get;set;}
	
	public class EDISDataDTO {
		public String result {get;set;}
	}
	
	public static EDISSingleResponseDTO parse(String json) {
        return (EDISSingleResponseDTO) System.JSON.deserialize(json, EDISSingleResponseDTO.class);
    }

}