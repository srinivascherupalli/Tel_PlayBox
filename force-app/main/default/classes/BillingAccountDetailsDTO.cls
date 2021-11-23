/**
 * Created Under Edge-20344
 */
public class BillingAccountDetailsDTO {
    public Integer code;
	public Integer status;
	public String message;
	public String correlationId;
	public BillingAccount billingAccount;
    public List<Errors> errors {get;set;}
    public class Errors {
        public String code {get;set;}
        public String field {get;set;}
        public String message {get;set;}
    }
  public class BillingAccount {
		public Long billingAccountNumber;
		public String status;
		public String startDate;
		public Integer billCycleDay;
		public Integer paymentTerms;
		public String rouCode;
		public String currencyCode;
		public String language;

      ///EDGE-147537 Added below three fields

      	public String writtenOffStatus;
		public String writtenOffDate;
        public String companyName;
		public BillingAccountOwner billingAccountOwner;
		public BillingAddress billingAddress;
        public accountBalance accountBalance; //EDGE-147537
	}
    public class BillingAddress {
		public String address;
		public String locality;
		public String postcode;
		public String state;
		public String country;
	}
	public class BillingAccountOwner {
		public String firstName;
		public String lastName;
		public String abn;
		public String companyName;
	}
    //EDGE-147537:Enhancement to the Billing Account details screen to display additional information along with the written information
    public class accountBalance{
        public Double totalBalance;
		public Double writtenOffAmount;
    }
	public static BillingAccountDetailsDTO parse(String json) {
		return (BillingAccountDetailsDTO) System.JSON.deserialize(json, BillingAccountDetailsDTO.class);
	}
}