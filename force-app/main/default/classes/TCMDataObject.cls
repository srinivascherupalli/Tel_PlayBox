public with sharing class TCMDataObject {
    
    public class Customer {
        public String cac {get; set;}
        public String eventAction {get; set;}
        public String cidn {get; set;}
        public String parentCidn {get; set;}
        public String rootCidn {get; set;}
        public String webAddress {get; set; }
        public String dataSovereignty {get; set;}
        public String ownershipCode {get; set;}
        public String abnOverride {get; set;}
        public String businessUnit {get; set;}
        public String customerManagedFlag {get; set;}
        public String customerType {get; set;}
        public String marketSegment {get; set;}
        public String priorityAssist {get; set;}
        public String accountStatus {get; set;}
        public String lastModifiedDate {get; set;}
        public String location {get; set;}
        public String churnpropensity {get; set;}
        public String customerSince {get; set;}
        public String description {get; set;}
        public String franchiseArrange {get; set;}
        public String languagePreference {get; set;}
        public String retiredUId {get; set;}
        public String retirementReason {get; set;}
        public String servicingOrgUnit {get; set;}
        public String timeZone {get; set;}
        public String writtenaAuthorityRequiredFlag {get; set;}
        public String geographicalLocationCode {get; set;}
        public String effectiveRetiredDate {get; set;}
        public String lastVerifiedDate {get; set;}
        public String createdDate {get; set;}
        public String duplicateOverridReason {get; set;}
        public String revenueOrganisationUnit {get; set;}
        public String potentialRevenue {get; set;}
        public String currentRevenue {get; set;}
        public String partners {get; set;}
        public String premiumService {get; set;}
        public String approveDeclineReason {get; set;}
        public String recommendedPaymentMethod {get; set;}
        public String recommendedBillingFrequency {get; set;}
        public String validationCustomerConsent {get; set;}
        public String validationConsentRequestDate {get; set;}
        public String customerEffectiveStartDate {get; set;}
        public String relationshipType {get; set;}
        public String reportingPointIndicator {get; set;}
        public String customerEffectiveEndDate {get; set;}
        public String ansicCode {get; set;}
        public String primaryIndustryIndicator {get; set;}
        public String masterID {get; set;}
        public String mergeStatus {get; set;}
        public String retagFlag {get; set;}
        public String dateOfApplication {get; set;}
        public String lastUpdated {get; set;}
        public String sourceSysOperation {get; set;}
        public String parentSourceSystem {get; set;}
        public String sendDateTime {get; set;}
        public String portfolioCode {get; set;}
        public String externalSystemId {get; set; }
        public String ultimateParentCidn {get; set; }
        public Category category {get; set;}
        public CreditSituation creditSituation {get; set;}
        public Concession concession {get; set;}
        public CustomerAccount customerAccount {get; set;}
        public List<Address> address {get; set;}
        public List<AccountTrading> accountTrading {get; set;}
        public List<AccountPortfolio> accountPortfolio { get; set; }
    }

    public class AccountPortfolio {
        public string portfolioName { get; set; }
        public string isPrimary { get; set; }
        public string accountExecutiveLastName { get; set; }
        public string portfolioCode { get; set; }
        public string accountExecutivePhoneNumber { get; set; }
        public string accountExecutiveFirstName { get; set; }
    }

    public class Contact {
        public string id { get; set; }
        public string title { get; set; }
        public string firstName { get; set; }
        public string middleName { get; set; }
        public string lastName { get; set; }
        public string birthDate { get; set; }
        public string status { get; set; }
        public string mergeStatus { get; set; }
        public string onlineFlag { get; set; }
        public string preferredMethod { get; set; }
        public string eventAction { get; set; }
        public string contactId { get; set; }
        public string lastVerifiedDate { get; set; }
        public string notes { get; set; }
        public string numberInHousehold { get; set; }
        public string occupation { get; set; }
        public string timeZone { get; set; }
        public string jobDescription { get; set; }
        public string jobTitle { get; set; }
        public string reviewedFlag { get; set; }
        public string languagePreference { get; set; }
        public string lastUpdated { get; set; }
        public String sendDateTime { get; set; }
        public String parentSourceSystemAction { get; set; }
        public String contactType {get;set;}
        public String contactUsage {get;set;}
        
        public String href {get;set;}
        public String endDate {get;set;}
         
        public List<Asset> asset { get; set; }
        public ContactDetails homeContact { get; set; }
        public ContactDetails workContact { get; set; }
        public Identification identification { get; set; }
        public List<Address> businessAddress { get; set; }
        public List<Address> personalAddress { get; set; }
        public List<CustomerAccounts> customerAccounts { get; set; }
    }
	
    public class Contact1 {
        public string id { get; set; }
        public string title { get; set; }
        public string firstName { get; set; }
        public string middleName { get; set; }
        public string lastName { get; set; }
        public string birthDate { get; set; }
        public string status { get; set; }
        public string mergeStatus { get; set; }
        public string onlineFlag { get; set; }
        public string preferredMethod { get; set; }
        public string eventAction { get; set; }
        public string contactId { get; set; }
        public string lastVerifiedDate { get; set; }
        public string notes { get; set; }
        public string numberInHousehold { get; set; }
        public string occupation { get; set; }
        public string timeZone { get; set; }
        public string jobDescription { get; set; }
        public string jobTitle { get; set; }
        public string reviewedFlag { get; set; }
        public string languagePreference { get; set; }
        public string lastUpdated { get; set; }
        public String sendDateTime { get; set; }
        public String parentSourceSystemAction { get; set; }
        public String contactType {get;set;}
        public String contactUsage {get;set;}
        
        public String href {get;set;}
        public String endDate {get;set;}
         
        public List<Asset> asset { get; set; }
        public ContactDetails homeContact { get; set; }
        public ContactDetails workContact { get; set; }
        public Identification identification { get; set; }
        public List<Address> businessAddress { get; set; }
        public List<Address> personalAddress { get; set; }
        public CustomerAccounts customerAccounts { get; set; }
    }
    
    public class Category {
        public String online {get; set;}
        public String bpProtect {get; set;}
        public String protect {get; set;}
    }

    public class CreditSituation {
        public String creditLimit {get; set;}
        public String creditManagementStatus {get; set;}
        public String creditRating {get; set;}
    }

    public class Concession {
        public String concessionAuthority {get; set;}
        public String concessionNumber {get; set;}
        public String concessionType {get; set;}
        public String paymentType {get; set;}
        public String paymentStatus {get; set;}
        public String validConcessionFlag {get; set;}
        public String lastValidatedDate {get; set;}
        public String bypassConcessionValidation {get; set;}
        public String validationResultOverride {get; set;}
    }

    public class CustomerAccount {
        public String title {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String birthDate {get; set;}
        public String phoneNumber {get; set;}
        public String faxNumber {get; set;}
        public String emailAddress {get; set;}
        public String abn {get; set;}
        public String acn {get; set;}
        public String webAddress {get; set;}
        public String driverLicenseNumber {get; set;}
        public String driverLicenseState {get; set;}
        public String fraudFlag {get; set;}
        public String vipFlag {get; set;}
        public String accountUuid {get; set;}
        public String preferredMethod {get; set;}
        public String dataSovereignty {get; set;}
        public String effectiveRetiredDate {get; set; }
    }

    public class Address {
        public String isPrimary {get; set;}
        public String status {get; set;}
        public String statusCode {get; set;}
        public String addressType {get; set;}
        public String exchange {get; set;}
        public String addressTypeCode {get; set;}
        public String country {get; set;}
        public String state {get; set;}
        public String postalCode {get; set;}
        public String addressId {get; set;}
        public String streetName {get; set;}
        public String streetType {get; set;}
        public String streetTypeCode {get; set;}
        public String streetTypeSuffix {get; set;}
        public String streetTypeSuffixCode {get; set;}
        public String streetNumberStart {get; set;}
        public String streetNumberStartSuffix {get; set;}
        public String streetNumberEnd {get; set;}
        public String streetNumberEndSuffix {get; set;}
        public String internationalPostcode {get; set;}
        public String internationalState {get; set;}
        public String deliveryPointId {get; set;}
        public String registeredPlan {get; set;}
        public String locality {get; set;}
        public String additionalInfo {get; set;}
        public String geographicalLocationCode {get; set;}
        public String lastUpdatedDateTime {get; set;}
        public SubAddress subAddress {get; set;}
    }

    public class SubAddress {
        public String buildingName {get; set;}
        public String propertyName {get; set;}
        public String numberStart {get; set;}
        public String numberEnd {get; set;}
        public String privateStreetName {get; set;}
        public String privateStreetType {get; set;}
        public String privateStreetTypeCode {get; set;}
        public List<Detail> details {get; set;}
        public List<String> addressLines {get; set;}
    }

    public class Detail {
        public String detailType {get; set;}
        public String detailTypeCode {get; set;}
        public String value {get; set;}
    }

    public class AccountTrading {
        public String isPrimary {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String tradingName {get; set;}
        public String lastUpdatedDateTime {get; set;}
    }

    public class Asset
    {
        public string integrationId { get; set; }
        public string assetRelationshipType { get; set; }
        public string assetContactEndDate { get; set; }
        public string assetId { get; set; }
    }

    public class ContactDetails
    {
        public string phoneNumber { get; set; }
        public string mobileNumber { get; set; }
        public string emailAddress { get; set; }
        public string faxNumber { get; set; }
    }  

    public class DriverLicense
    {
        public string driversLicenseNo { get; set; }
        public string state { get; set; }
    }

    public class Identification
    {
        public DriverLicense driverLicense { get; set; }
    }   

    public class ContactRelationship
    {
        public string endDate { get; set; }
        public string contactType { get; set; }
        public string contactUsage { get; set; }
    }

    public class CustomerAccounts
    {
        public string accountUUID { get; set; }
        public string mmsOptIn { get; set; }
        public string smsOptIn { get; set; }
        public string emailOptIn { get; set; }
        public string faceToFaceOptIn { get; set; }
        public string phoneOptIn { get; set; }
        public string directMailOptIn { get; set; }
        public string marketClass { get; set; }
        public string businessUnit { get; set; }
        public string dataSovereignty { get; set; }
        public ContactRelationship contactRelationship { get; set; }
        public String customerCode { get; set; }
    }

    public class Fault{
        public String faultcode {get;set;} 
        public String faultString {get;set;}
        public String faultActor {get;set;}
        public String serverName {get;set;}
        public String processId {get;set;}
        public String threadId {get;set;}
        public String programName {get;set;}
        public String programLocation {get;set;}
        public String timestamp {get;set;}
        public String initiatingEntityId {get;set;}
        public String programStatusCode {get;set;}
        public String programStatusDescription {get;set;}
        public String programFaultId {get;set;}
        public String programFaultDescription {get;set;}
        public String faultCategory {get;set;}
        public String entityName {get;set;}
        public String entityValue {get;set;}
    }

    public class FaultData{
        public Fault fault {get;set;}  
    }

    public class StatusRequest {
        public FaultData data {get;set;}  
    }

}