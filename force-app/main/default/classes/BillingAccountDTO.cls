public class BillingAccountDTO{
  public BillingAccount billingAccount {get;set;}

  public class BillingAccount {
    public Long billingAccountNumber {get;set;}
	public string accountType {get;set;}
	public string status {get;set;}
	public boolean writeOff {get;set;} 
    public Integer billCycleDay {get;set;}
    public Integer paymentTerms {get;set;}
    public BillingContact billingAccountOwner {get;set;}
    public BillingAddress billingAddress {get;set;}
    public string language{get;set;}
    public string currencyCode{get;set;}
    public string rouCode{get;set;}
    public String companyName {get;set;}
      public boolean retentionFlag {get;set;}
  }

  public class BillingAddress {
    public String address {get;set;}
    public String locality {get;set;}
    public String postcode {get;set;}
    public String state {get;set;}
    public String country {get;set;}
  }

  public class BillingContact {
    public String firstName {get;set;}
    public String lastName {get;set;}
    public String companyName {get;set;}
    public String abn{get;set;}
  }

  public static BillingAccountDTO parse(String json) {
    return (BillingAccountDTO) System.JSON.deserialize(json, BillingAccountDTO.class);
  }
}