public class OneFundRedemptioncreditRequestDTO {

	public class InvoiceItem {
		public Integer lineItemReasonCode;
		public String chargeType;
		public Integer invoiceLineNumber;
		public Integer invoiceTransactionId;
		public double creditAmount;
	}

	public String instanceId;
	public String adjustmentType;
	public Integer ariaInvoiceNumber;
	public String comments;
	public String currencyCode;
	public String caseReferenceNumber;
	public String productId;
  //Added chargeId and externalRateId as part of EDGE-157138
    public String chargeId;
    public String externalRateId;
	public adjustmentTarget adjustmentTarget;
	

	public class adjustmentTarget {
		public List<InvoiceItem> invoiceItem;
	}

	
	public static OneFundRedemptioncreditRequestDTO parse(String json) {
		return (OneFundRedemptioncreditRequestDTO) System.JSON.deserialize(json, OneFundRedemptioncreditRequestDTO.class);
	}
}