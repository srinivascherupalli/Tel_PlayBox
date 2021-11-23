/*-------------------------------------------------------- 
EDGE-123565
Class: OneFundChargesRequestDTO
Description: Created for generating OneFund charges request
Author:Tejes
--------------------------------------------------------*/
public with sharing class OneFundChargesRequestDTO {
    public class ChargeTarget {
		public Long billingAccountNumber;
        public String subscriptionId;
	}
	 public class customerReferences {
		public String name;
        public String value;
	}
	public String instanceId;
	public String productId;
	public String description;
	public Decimal unitPrice;
	public Integer units;
	public String currencyCode;
	public String effectiveDate;
	public String billingSpecId;
	public String taxTreatment;
    //Added chargeId and externalRateId as part of EDGE-157138
    public String chargeId;
    public String externalRateId;
	public ChargeTarget chargeTarget;
    public List<customerReferences> customerReferences; //Added optional field as part of EDGE-149471


	public static OneFundChargesRequestDTO parse(String json) {
		return (OneFundChargesRequestDTO) System.JSON.deserialize(json, OneFundChargesRequestDTO.class);
	}
}