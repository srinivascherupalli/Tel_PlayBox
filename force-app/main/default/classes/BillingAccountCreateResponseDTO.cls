public class BillingAccountCreateResponseDTO {
    	public String correlationId {get;set;}
    	public String status {get;set;}
    	public String code {get;set;}
    	public String message {get;set;}
    	
    	public static BillingAccountCreateResponseDTO parse(String json) {
		return (BillingAccountCreateResponseDTO) System.JSON.deserialize(json, BillingAccountCreateResponseDTO.class);
	}

}