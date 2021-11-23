public class BillingPostSubscriptionResponseDTO {
    	public String correlationId {get;set;}
    	public String status {get;set;}
    	public String code {get;set;}
    	public String message {get;set;}
        public String eventId {get;set;}
    	
    	public static BillingPostSubscriptionResponseDTO parse(String json) {
		return (BillingPostSubscriptionResponseDTO) System.JSON.deserialize(json, BillingPostSubscriptionResponseDTO.class);
	}
}