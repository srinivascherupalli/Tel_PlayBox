//DIGI-25050
public class FetchPayoutDetailsSyncRespDto {

	public class ChargesDetails {
		public String instanceId;
		public String durationUnit;
		public Integer durationRemaining;
		public Integer chargeRemaining;
		public Integer units;
		public String taxTreatment;
		public String validTill;
	}

	//public Integer code;
	//public Integer status;
	public String message;
	public Long billingAccountNumber;
	public String subscriptionId;
	public List<ChargesDetails> chargesDetails;

	
	public static FetchPayoutDetailsSyncRespDto parse(String json) {
		return (FetchPayoutDetailsSyncRespDto) System.JSON.deserialize(json, FetchPayoutDetailsSyncRespDto.class);
	}
}