/*
    AUTHOR : Vineeth Batreddy
    DESCRIPTION : This class maintains the request data model for NotifyContact.
*/

global class NotifyContactRequest {
    
    public  Data data { get; set; }
    
	public class Asset
    {
        public string integrationId { get; set; }
        public string assetRelationshipType { get; set; }
        public string assetContactEndDate { get; set; }
        public string assetId { get; set; }
    }

    public class HomeContact
    {
        public string phoneNumber { get; set; }
        public string mobileNumber { get; set; }
        public string emailAddress { get; set; }
        public string faxNumber { get; set; }
    }

    public class WorkContact
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

    public class Detail
    {
        public string detailType { get; set; }
        public string value { get; set; }
        public string detailTypeCode { get; set; }
    }

    public class SubAddress
    {
        public string buildingName { get; set; }
        public string propertyName { get; set; }
        public string numberStart { get; set; }
        public string numberEnd { get; set; }
        public string privateStreetName { get; set; }
        public string privateStreetType { get; set; }
        public List<Detail> details { get; set; }
        public List<String> addressLines { get; set; }
    }

    public class BusinessAddress
    {
        public string status { get; set; }
        public string addressType { get; set; }
        public string addressTypeCode { get; set; }
        public string country { get; set; }
        public string streetNumberEndSuffix { get; set; }
        public string addressId { get; set; }
        public string postalCode { get; set; }
        public string isPrimary { get; set; }
        public string registeredPlan { get; set; }
        public string streetNumberStartSuffix { get; set; }
        public string state { get; set; }
        public string streetNumberEnd { get; set; }
        public string streetNumberStart { get; set; }
        public string streetType { get; set; }
        public string streetTypeSuffix { get; set; }
        public string additionalInfo { get; set; }
        public string internationalPostcode { get; set; }
        public string internationalState { get; set; }
        public string locality { get; set; }
        public string streetName { get; set; }
        public SubAddress subAddress { get; set; }
    }

    public class PersonalAddress
    {
        public string status { get; set; }
        public string addressType { get; set; }
        public string addressTypeCode { get; set; }
        public string country { get; set; }
        public string streetNumberEndSuffix { get; set; }
        public string addressId { get; set; }
        public string postalCode { get; set; }
        public string isPrimary { get; set; }
        public string registeredPlan { get; set; }
        public string streetNumberStartSuffix { get; set; }
        public string state { get; set; }
        public string streetNumberEnd { get; set; }
        public string streetNumberStart { get; set; }
        public string streetType { get; set; }
        public string streetTypeSuffix { get; set; }
        public string additionalInfo { get; set; }
        public string internationalPostcode { get; set; }
        public string internationalState { get; set; }
        public string locality { get; set; }
        public string streetName { get; set; }
        public SubAddress subAddress { get; set; }
    }

    public class ContactRelationship
    {
        public string endDate { get; set; }
        public string contactType { get; set; }
        public string contactUsage { get; set; }
        public string verifiedDate { get; set; }
        public string expiryDate { get; set; }
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
    }

    public class Data
    {
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
        public String externalSystemId {get; set; }
        public List<Asset> asset { get; set; }
        public HomeContact homeContact { get; set; }
        public WorkContact workContact { get; set; }
        public Identification identification { get; set; }
        public List<BusinessAddress> businessAddress { get; set; }
        public List<PersonalAddress> personalAddress { get; set; }
        public List<CustomerAccounts> customerAccounts { get; set; }
    }

}