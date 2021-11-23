public class CustomerObject
{	
	@Auraenabled public Data data { get; set; }
    @AuraEnabled public Customer customer { get; set; }

    public class Data {
        @AuraEnabled public List<Customer> customers { get; set; }
        @AuraEnabled public Paging paging { get; set; }
        @AuraEnabled public List<Address> address { get; set; }
    }

    public class Customer {
        @AuraEnabled public string location { get; set; }
        @AuraEnabled public string effectiveRetiredDate { get; set; }
        //@AuraEnabled public string webAddress { get; set; }
        @AuraEnabled public string servicingOrgUnit { get; set; }
        @AuraEnabled public string potentialRevenue { get; set; }
        @AuraEnabled public string languagePreference { get; set; }
        @AuraEnabled public string parentCidn { get; set; }
        @AuraEnabled public List<AccountTrading> accountTrading { get; set; }
       // @AuraEnabled public string duplicateOverridReason { get; set; }
        @AuraEnabled public string customerManagedFlag { get; set; }
        //@AuraEnabled public string externalSystemId { get; set; }
        @AuraEnabled public string description { get; set; }
        @AuraEnabled public string createdDate { get; set; }
        @AuraEnabled public string lastVerifiedDate { get; set; }
        @AuraEnabled public string currentRevenue { get; set; }
        @AuraEnabled public string customerEffectiveStartDate { get; set; }
        @AuraEnabled public string lastUpdated { get; set; }
        @AuraEnabled public string ultimateParentCidn { get; set; }
        @AuraEnabled public string ownershipCode { get; set; }
        @AuraEnabled public string recommendedBillingFrequency { get; set; }
        @AuraEnabled public Category category { get; set; }
        @AuraEnabled public CreditSituation creditsituation{get;set;}
        @AuraEnabled public Concession concession{get;set;}
        @AuraEnabled public string businessUnit { get; set; }
        //@AuraEnabled public string abnOverride { get; set; }
        @AuraEnabled public string mergeStatus{get;set;}
        @AuraEnabled public string revenueOrganisationUnit { get; set; }
        @AuraEnabled public string priorityAssist { get; set; }
        @AuraEnabled public string masterID { get; set; }
        @AuraEnabled public string sourceSysOperation{get;set;}
        @AuraEnabled public string parentSourceSystem{get;set;}
        @AuraEnabled public string validationConsentRequestDate { get; set; }
        @AuraEnabled public string premiumService { get; set; }
        @AuraEnabled public string franchiseArrange { get; set; }
        @AuraEnabled public string retirementReason { get; set; }
        @AuraEnabled public string timeZone { get; set; }
        @AuraEnabled public string approveDeclineReason { get; set; }
        @AuraEnabled public CustomerAccount customerAccount { get; set; }
        //@AuraEnabled public string eventAction { get; set; }
        @AuraEnabled public string cac { get; set; }
        @AuraEnabled public string relationshipType { get; set; }
        @AuraEnabled public string marketSegment { get; set; }
        @AuraEnabled public string partners { get; set; }
        @AuraEnabled public string accountStatus { get; set; }
        @AuraEnabled public string geographicalLocationCode { get; set; }
        @AuraEnabled public string customerEffectiveEndDate { get; set; }
        @AuraEnabled public string customerType { get; set; }
        @AuraEnabled public string customerSince { get; set; }
        //@AuraEnabled public string sendDateTime { get; set; }
		@AuraEnabled public string portfolioCode {get;set;} 
        @AuraEnabled public string churnPropensity { get; set; }
        @AuraEnabled public string cidn { get; set; }
        @AuraEnabled public string writtenaAuthorityRequiredFlag { get; set; }
        @AuraEnabled public string reportingPointIndicator { get; set; }
        @AuraEnabled public string recommendedPaymentMethod { get; set; }
        @AuraEnabled public List<Address> address { get; set; }
        @AuraEnabled public string retiredUId { get; set; }
        @AuraEnabled public string ansicCode { get; set; }
        @AuraEnabled public string dateOfApplication { get; set; }
        //@AuraEnabled public string lastModifiedDate { get; set; }
        @AuraEnabled public string validationCustomerConsent { get; set; }
        @AuraEnabled public String actualRetiredDate {get;set;} 
    }


    public class AccountTrading {
        //@AuraEnabled public string startDate { get; set; }
        @AuraEnabled public string isPrimary { get; set; }
        @AuraEnabled public string tradingName { get; set; }
        //@AuraEnabled public string endDate { get; set; }
    }

    public class Category {
        //@AuraEnabled public string bpProtect { get; set; }
        //@AuraEnabled public string protect { get; set; }
        @AuraEnabled public string online { get; set; }
    }
    
    public class CreditSituation{
        @AuraEnabled public string creditLimit { get; set; }
        @AuraEnabled public string creditManagementStatus { get; set; }
        @AuraEnabled public string creditRating { get; set; }
        
    }
    public class Concession {
        @AuraEnabled public string concessionAuthority { get; set; }
        @AuraEnabled public string concessionNumber { get; set; }
        @AuraEnabled public string concessionType { get; set; }
        @AuraEnabled public string paymentType { get; set; }
        @AuraEnabled public string paymentStatus { get; set; }
        @AuraEnabled public string validConcessionFlag { get; set; }
        @AuraEnabled public string lastValidatedDate { get; set; }
        @AuraEnabled public string bypassConcessionValidation { get; set; }
        @AuraEnabled public string validationResultOverride { get; set; }
        
    }
    public class CustomerAccount {
        @AuraEnabled public string preferredMethod { get; set; }
        @AuraEnabled public string lastName { get; set; }
        @AuraEnabled public string acn { get; set; }
        @AuraEnabled public string fraudFlag { get; set; }
        @AuraEnabled public string driverLicenceNumber { get; set; }
        @AuraEnabled public string effectiveRetiredDate { get; set; }
        @AuraEnabled public string webAddress { get; set; }
        @AuraEnabled public string emailAddress { get; set; }
        @AuraEnabled public string dataSovereignty { get; set; }
        @AuraEnabled public string vipFlag { get; set; }
        @AuraEnabled public string abn { get; set; }
        @AuraEnabled public string driverLicenceState { get; set; }
        @AuraEnabled public string title { get; set; }
        @AuraEnabled public string faxNumber { get; set; }
        @AuraEnabled public string phoneNumber { get; set; }
        @AuraEnabled public string birthDate { get; set; }
        @AuraEnabled public string accountUuid { get; set; }
        @AuraEnabled public string firstName { get; set; }
		//@AuraEnabled public string middleName { get; set; }
        //@AuraEnabled public string driverLicenseNumber{get;set;}
        //@AuraEnabled public string driverLicenseState {get;set;}
        //@AuraEnabled public string endDate {get;set;}
        //@AuraEnabled public String id { get; set; }
        //@AuraEnabled public String phoneOptIn { get; set; }
        //@AuraEnabled public String emailOptIn { get; set; }
        //@AuraEnabled public String businessUnit { get; set; }
        //@AuraEnabled public ContactRelationship contactRelationship { get; set; }
        //@AuraEnabled public String faceToFaceOptIn { get; set; }
        //@AuraEnabled public String directMailOptIn { get; set; }
        //@AuraEnabled public String smsOptIn { get; set; }
      
        
    }

      /**public class ContactRelationship {
         @AuraEnabled public String contactUsage { get; set; }
        @AuraEnabled  public String contactType { get; set; }
         @AuraEnabled public String endDate { get; set; }
    }
    public class WorkContact{
        @AuraEnabled public String faxNumber { get; set; }
        @AuraEnabled public String phoneNumber { get; set; }
        @AuraEnabled public String emailAddress { get; set; }
        @AuraEnabled public String mobileNumber { get; set; }
    }
    public class HomeContact{
        @AuraEnabled public String faxNumber { get; set; }
        @AuraEnabled public String phoneNumber { get; set; }
        @AuraEnabled public String emailAddress { get; set; }
        @AuraEnabled public String mobileNumber { get; set; }
    }**/

    public class Address {
      @AuraEnabled  public string state { get; set; }
      @AuraEnabled public string streetTypeCode { get; set; }
      @AuraEnabled  public string addressId { get; set; }
      @AuraEnabled  public string statusCode { get; set; }
      @AuraEnabled  public string streetTypeSuffixCode { get; set; }
      @AuraEnabled  public string postalCode { get; set; }
      @AuraEnabled  public string registeredPlan { get; set; }
      @AuraEnabled  public string streetNumberStart { get; set; }
      @AuraEnabled  public SubAddress subAddress { get; set; }
      @AuraEnabled public string streetType { get; set; }
      @AuraEnabled  public string internationalState { get; set; }
      @AuraEnabled  public string isPrimary { get; set; }
      @AuraEnabled  public string status { get; set; }
      @AuraEnabled  public string streetNumberStartSuffix { get; set; }
      @AuraEnabled  public string streetName { get; set; }
      @AuraEnabled  public string addressType { get; set; }
      @AuraEnabled  public string additionalInfo { get; set; }
      @AuraEnabled  public string country { get; set; }
      @AuraEnabled  public string internationalPostcode { get; set; }
      @AuraEnabled  public string addressTypeCode { get; set; }
      @AuraEnabled  public string streetTypeSuffix { get; set; }
      @AuraEnabled  public string streetNumberEnd { get; set; }
      @AuraEnabled  public string deliveryPointId { get; set; }
      @AuraEnabled  public string streetNumberEndSuffix { get; set; }
      @AuraEnabled  public string locality { get; set; }
      @AuraEnabled  public String exchange {get;set;} 
    }

    public class SubAddress {
       @AuraEnabled public string propertyName { get; set; }
       @AuraEnabled public string privateStreetType { get; set; }
       @AuraEnabled public string privateStreetName { get; set; }
       @AuraEnabled public List<Detail> details { get; set; }
       @AuraEnabled public string numberStart { get; set; }
       @AuraEnabled public string buildingName { get; set; }
       @AuraEnabled public List<string> addressLines { get; set; }
       @AuraEnabled public string numberEnd { get; set; }
       @AuraEnabled public string privateStreetTypeCode { get; set; }
    }

    public class Detail {
      @AuraEnabled  public string detailType { get; set; }
      @AuraEnabled  public string value { get; set; }
      @AuraEnabled  public string detailTypeCode { get; set; }
    }

    public class Paging {
       @AuraEnabled public string lastPage { get; set; }
       @AuraEnabled public string resultBlockSize { get; set; }
       @AuraEnabled public string offset { get; set; }
    }

}