public class BillingSpecDTO {
    //public String correlationId {get;set;}
    //public String sourceSystem {get;set;}
    public Long billingAccountNumber {get;set;}
    public String productActionType {get;set;}
    public DateTime effectiveDate {get; set;}
    public ProductOfferingDataObject productOffering {get;set;}
    public List<BillingOrderItemDataObject> orderItems {get;set;}
	public List<additionalBillInfo> additionalBillInfo {get;set;}
    
    public class additionalBillInfo {
        public String value;
        public String name;
    }
    
    public class services {
        public String id;
    }
	
    public class ProductOfferingDataObject {
        public String productId {get;set;}
        public String invoiceDefinition {get;set;}
        public String productInstanceId {get;set;}
		public String description {get;set;}
    }
	public class BillingOrderItemDataObject {
        public String productInstanceId {get;set;}
        public String serviceInstanceId {get;set;} 
        public String parentProductInstanceId {get;set;}
        public String productId {get;set;}
        public String billingSpecId {get;set;}
        public String productActionType {get;set;}
        public DateTime effectiveDate {get;set;}
        public Integer units {get;set;}
        public Decimal unitPrice {get;set;}
        public String description {get;set;}
        public String frequency {get;set;}
        public String currencyCode {get;set;}
        public String billInAdvance {get;set;}
        public String prorateType {get;set;}
        public String usageRatePlanId {get;set;}
        public List<services> services {get;set;}
    }
    
     public static BillingSpecDTO parse(String json) {
		return (BillingSpecDTO) System.JSON.deserialize(json, BillingSpecDTO.class);
	}
}