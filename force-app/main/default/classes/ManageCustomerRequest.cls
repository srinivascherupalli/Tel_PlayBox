/*
    AUTHOR : Vineeth Batreddy
    DESCRIPTION : This class maintains the request data model for ManageCustomer.
*/

public class ManageCustomerRequest{
    
	public Data data {set;get;}

    public class Data {
        public String cac {set;get;}
        public String eventAction {set;get;}
        public String externalSystemId {set;get;}
        public String cidn {set;get;}
        public String parentCidn {set;get;}
        public String rootCidn {set;get;}
        public String ownershipCode {set;get;}
        public String abnOverride {set;get;}
        public String businessUnit {set;get;}
        public String customerManagedFlag {set;get;}
        public String sendDateTime {set;get;}
        public String customerType {set;get;}
        public String marketSegment {set;get;}
        public String priorityAssist {set;get;}
        public String accountStatus {set;get;}
        public String lastModifiedDate {set;get;}
        public String location {set;get;}
        public String churnpropensity {set;get;}
        public String customerSince {set;get;}
        public String description {set;get;}
        public String franchiseArrange {set;get;}
        public String languagePreference {set;get;}
        public String retiredUId {set;get;}
        public String retirementReason {set;get;}
        public String servicingOrgUnit {set;get;}
        public String timeZone {set;get;}
        public String writtenaAuthorityRequiredFlag {set;get;}
        public String effectiveRetiredDate {set;get;}
        public String lastVerifiedDate {set;get;}
        public String createdDate {set;get;}
        public String duplicateOverrideReason {set;get;}
        public String revenueOrganisationUnit {set;get;}
        public String potentialRevenue {set;get;}
        public String currentRevenue {set;get;}
        public String partners {set;get;}
        public String premiumService {set;get;}
        public String approveDeclineReason {set;get;}
        public String recommendedPaymentMethod {set;get;}
        public String recommendedBillingFrequency {set;get;}
        public String validationCustomerConsent {set;get;}
        public String validationConsentRequestDate {set;get;}
        public String customerEffectiveStartDate {set;get;}
        public String relationshipType {set;get;}
        public String reportingPointIndicator {set;get;}
        public String customerEffectiveEndDate {set;get;}
        public String ansicCode {set;get;}
        public String IndustrymasterId {set;get;}
        public String primaryIndustryIndicator {set;get;}
        public Category category {set;get;}
        public CreditSituation creditSituation {set;get;}
        public Concession concession {set;get;}
        public CustomerAccount customerAccount {set;get;}
        public List<Address> address {set;get;}
        public List<AccountTrading> accountTrading {set;get;}
        public AccountPortfolio accountPortfolio {set;get;}
        public String dateOfApplication {set;get;}
        public String geographicalLocationCode {set;get;}
        public String lastUpdated {set;get;}
        public String ultimateParentCidn {set;get;}
        public String masterID {set;get;}
        public String loc {set;get;}
    }

    public class Category {
        public String online {set;get;}
        public String bpProtect {set;get;}
        public String protect {set;get;}
    }

    public class CreditSituation {
        public String creditLimit {set;get;}
        public String creditManagementStatus {set;get;}
        public String creditRating {set;get;}
    }

    public class Concession {
        public String concessionAuthority {set;get;}
        public String concessionNumber {set;get;}
        public String concessionType {set;get;}
        public String paymentType {set;get;}
        public String paymentStatus {set;get;}
        public String validConcessionFlag {set;get;}
        public String lastValidatedDate {set;get;}
        public String bypassConcessionValidation {set;get;}
        public String validationResultOverride {set;get;}
    }

    public class CustomerAccount {
        public String title {set;get;}
        public String firstName {set;get;}
        public String lastName {set;get;}
        public String birthDate {set;get;}
        public String phoneNumber {set;get;}
        public String faxNumber {set;get;}
        public String emailAddress {set;get;}
        public String abn {set;get;}
        public String acn {set;get;}
        public String webAddress {set;get;}
        public String driverLicenseNumber {set;get;}
        public String driverLicenseState {set;get;}
        public String fraudFlag {set;get;}
        public String vipFlag {set;get;}
        public String accountUuid {set;get;}
        public String preferredMethod {set;get;}
        public String dataSovereignty {set;get;}
    }

    public class Address {
        public String isPrimary {set;get;}
        public String status {set;get;}
        public String statusCode {set;get;}
        public String addressType {set;get;}
        public String addressTypeCode {set;get;}
        public String country {set;get;}
        public String state {set;get;}
        public String postalCode {set;get;}
        public String addressId {set;get;}
        public String streetName {set;get;}
        public String streetType {set;get;}
        public String streetTypeCode {set;get;}
        public String streetTypeSuffix {set;get;}
        public String streetTypeSuffixCode {set;get;}
        public String streetNumberStart {set;get;}
        public String streetNumberStartSuffix {set;get;}
        public String streetNumberEnd {set;get;}
        public String streetNumberEndSuffix {set;get;}
        public String internationalPostcode {set;get;}
        public String internationalState {set;get;}
        public String deliveryPointId {set;get;}
        public String registeredPlan {set;get;}
        public String locality {set;get;}
        public String additionalInfo {set;get;}
        public String geographicalLocationCode {set;get;}
        public SubAddress subAddress {set;get;}
    }

    public class SubAddress {
        public String buildingName {set;get;}
        public String propertyName {set;get;}
        public String numberStart {set;get;}
        public String numberEnd {set;get;}
        public String privateStreetName {set;get;}
        public String privateStreetType {set;get;}
        public String privateStreetTypeCode {set;get;}
        public List<Detail> details {set;get;}
        public List<String> addressLines {set;get;}
    }

    public class Detail {
        public String detailType {set;get;}
        public String detailTypeCode {set;get;}
        public String value {set;get;}
    }

    public class AccountTrading {
        public String isPrimary {set;get;}
        public String startDate {set;get;}
        public String endDate {set;get;}
        public String tradingName {set;get;}
    }

    public class AccountPortfolio {
        public String isPrimary {set;get;}
        public String portfolioCode {set;get;}
    }

}