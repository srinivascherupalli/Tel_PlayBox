//DIGI-30045
public class PayoutDetailsforChownReqDto {

	public class ChargesDetails {
		public String subscriptionId;
		public String instanceId;
	}

	public List<BillingAccounts> billingAccounts;

	public class BillingAccounts {
    public Long billingAccountNumber;
		public List<ChargesDetails> chargesDetails;
	}

	
	public static PayoutDetailsforChownReqDto parse(String json) {
		return (PayoutDetailsforChownReqDto) System.JSON.deserialize(json, PayoutDetailsforChownReqDto.class);
	}
}