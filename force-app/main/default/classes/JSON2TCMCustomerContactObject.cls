/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to handle the JSON response object
    INTERFACE:  /v1/customer-self-management/tcm/customer-accounts/{id}?include=contacts
*/
public class JSON2TCMCustomerContactObject {
  public class Contacts {
    public String id {get;set;}
    public String href {get;set;}
    public String title {get;set;}
    public String firstName {get;set;}
    public String middleName {get;set;}
    public String lastName {get;set;}
    public String birthDate {get;set;}
    public String status {get;set;}
	public String jobTitle {get;set;}
	public String jobDescription {get;set;}
    /*public String endDate {get;set;}
    public String contactType {get;set;}
    public String contactUsage {get;set;}*/
    public String preferredMethod {get;set;}
	public CustomerAccount customerAccounts { get; set; }
    public HomeContact homeContact {get;set;}
    public Workcontact workContact {get;set;}    
  }

  public Data data {get;set;}
  public class WorkContact
    {
         public String faxNumber { get; set; }
         public String phoneNumber { get; set; }
         public String emailAddress { get; set; }
         public String mobileNumber { get; set; }
    }

  public class HomeContact {
    public String emailAddress {get;set;}
    public String faxNumber {get;set;}
    public String phoneNumber {get;set;}
    public String mobileNumber {get;set;}
  }

  public class Data {
    public String id {get;set;}
    public String href {get;set;}
    public String abn {get;set;}
    public String acn {get;set;}
    public String firstName {get;set;}
    public String accountStatus {get;set;}
    public String lastName {get;set;}
    public String birthDate {get;set;}
    public List<Contacts> contacts {get;set;}
  }
  
  public class ErrorMessage{
    public String message {get;set;}
    public String status {get;set;}
    public String code {get;set;}
  }
  
    
    public class CustomerAccount
    {
        public String mmsOptIn { get; set; }
        public String id { get; set; }
        public String lastName { get; set; }
        public String phoneOptIn { get; set; }
        public String emailOptIn { get; set; }
        public String businessUnit { get; set; }
        public ContactRelationship contactRelationship { get; set; }
        public String faceToFaceOptIn { get; set; }
        public String directMailOptIn { get; set; }
        public String dataSovereignty { get; set; }
        public String accountUuid { get; set; }
        public String smsOptIn { get; set; }
		public String endDate {get;set;}
    }

    public class ContactRelationship
    {
       public String contactUsage { get; set; }
       public String contactType { get; set; }
       public String endDate { get; set; }
       public String verifiedDate { get; set; }
       public String expiryDate { get; set; }
    }

  public static JSON2TCMCustomerContactObject parse(String jsonString) {
    return (JSON2TCMCustomerContactObject) System.JSON.deserialize(jsonString, JSON2TCMCustomerContactObject.class);
  }
}