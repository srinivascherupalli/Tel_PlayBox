public with sharing class OnceOffChargeResponseDTO {

	@AuraEnabled
	public List<OrderDetails> orderDetails;
    
   @AuraEnabled	
   public List<InvoiceLineAttributes> invoiceLineAttributes;
	
	public class OrderDetails {
	
		@AuraEnabled
		public String orderNumber {get; set;}
		@AuraEnabled
		public String orderDate {get; set;}
		@AuraEnabled
		public String uniqueId {get; set;}
		@AuraEnabled
		public String quantity {get; set;}
		@AuraEnabled
		public Double excludingGSTcostFmtd {get; set;}
		@AuraEnabled
		public Double includingGSTcostFmtd{get; set;}
		@AuraEnabled
		public long chargeIdentifier{get; set;}
         @AuraEnabled
        public Integer invoiceTransactionId {get;set;} 
        @AuraEnabled
        public List<InvoiceLineAttributes> invoiceLineAttributes {get;set;} 

	}
    
    public class InvoiceLineAttributes {
         @AuraEnabled
        public Integer invoiceTransactionId {get;set;} 
        
    }
    
	public static OnceOffChargeResponseDTO parse(String json) {
		json = json.replace('date', 'orderDate');
		json = json.replace('deviceId','uniqueId');
		json = json.replace('amountExGST', 'excludingGSTcostFmtd');
		json = json.replace('amountIncGST', 'includingGSTcostFmtd');
		return (OnceOffChargeResponseDTO) System.JSON.deserialize(json, OnceOffChargeResponseDTO.class);
	}
}