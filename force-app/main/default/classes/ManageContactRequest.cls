/*
    AUTHOR : Vineeth Batreddy
    DESCRIPTION : This class maintains the request data model for ManageContact.
*/

public class ManageContactRequest
{
    public Data data{set;get;}

    public class Data {
        public String id{set;get;}
        public String title{set;get;}
        public String firstName{set;get;}
        public String middleName{set;get;}
        public String lastName{set;get;}
        public String birthDate{set;get;}
        public String status{set;get;}
        public String onlineFlag{set;get;}
        public String preferredMethod{set;get;}
        public String eventAction{set;get;}
        public String sendDateTime{set;get;}
        public String contactId{set;get;}
        public String lastVerifiedDate{set;get;}
        public String notes{set;get;}
        public String numberInHousehold{set;get;}
        public String occupation{set;get;}
        public String timeZone{set;get;}
        public String jobDescription{set;get;}
        public String jobTitle{set;get;}
        public String reviewedFlag{set;get;}
        public String languagePreference{set;get;}
        public String lastUpdated{set;get;}
        public String externalSystemId{set;get;}
        public Asset asset{set;get;}
        public HomeContact homeContact{set;get;}
        public WorkContact workContact{set;get;}
        public Identification identification{set;get;}
        public List<BusinessAddress> businessAddress{set;get;}
        public List<PersonalAddress> personalAddress{set;get;}
        public CustomerAccounts customerAccounts{set;get;}
    }

    public class Asset {
        public String integrationId{set;get;}
        public String assetRelationshipType{set;get;}
        public String assetContactEndDate{set;get;}
        public String assetID{set;get;}
    }

    public class HomeContact {
        public String phoneNumber{set;get;}
        public String mobileNumber{set;get;}
        public String emailAddress{set;get;}
        public String faxNumber{set;get;}
    }

    public class WorkContact {
        public String phoneNumber{set;get;}
        public String mobileNumber{set;get;}
        public String emailAddress{set;get;}
        public String faxNumber{set;get;}
    }

    public class Identification {
        public DriverLicense driverLicense{set;get;}
    }

    public class DriverLicense {
        public String num{set;get;}
        public String state{set;get;}
    }

    public class BusinessAddress {
        public String status{set;get;}
        public String addressType{set;get;}
        public String country{set;get;}
        public String streetNumberEndSuffix{set;get;}
        public String addressId{set;get;}
        public String postalCode{set;get;}
        public String isPrimary{set;get;}
        public String registeredPlan{set;get;}
        public String streetNumberStartSuffix{set;get;}
        public String state{set;get;}
        public String streetNumberEnd{set;get;}
        public String streetNumberStart{set;get;}
        public String streetType{set;get;}
        public String streetTypeSuffix{set;get;}
        public String additionalInfo{set;get;}
        public String internationalPostcode{set;get;}
        public String internationalState{set;get;}
        public String locality{set;get;}
        public String streetName{set;get;}
        public SubAddress subAddress{set;get;}
    }

    public class PersonalAddress {
        public String status{set;get;}
        public String addressType{set;get;}
        public String country{set;get;}
        public String streetNumberEndSuffix{set;get;}
        public String addressId{set;get;}
        public String postalCode{set;get;}
        public String isPrimary{set;get;}
        public String registeredPlan{set;get;}
        public String streetNumberStartSuffix{set;get;}
        public String state{set;get;}
        public String streetNumberEnd{set;get;}
        public String streetNumberStart{set;get;}
        public String streetType{set;get;}
        public String streetTypeSuffix{set;get;}
        public String additionalInfo{set;get;}
        public String internationalPostcode{set;get;}
        public String internationalState{set;get;}
        public String locality{set;get;}
        public String streetName{set;get;}
        public SubAddress subAddress{set;get;}
    }

    public class SubAddress {
        public String buildingName{set;get;}
        public String propertyName{set;get;}
        public String numberStart{set;get;}
        public String numberEnd{set;get;}
        public String privateStreetName{set;get;}
        public String privateStreetType{set;get;}
        public List<Detail> details{set;get;}
        public List<String> addressLines{set;get;}
    }

    public class Detail {
        public String detailType{set;get;}
        public String value{set;get;}
    }

    public class CustomerAccounts {
        public String accountUuid{set;get;}
        public String customerCode{set;get;}
        public String mmsOptIn{set;get;}
        public String smsOptIn{set;get;}
        public String emailOptIn{set;get;}
        public String faceToFaceOptIn{set;get;}
        public String phoneOptIn{set;get;}
        public String directMailOptIn{set;get;}
        public ContactRelationship contactRelationship{set;get;}
    }

    public class ContactRelationship {
        public String endDate{set;get;}
        public String contactType{set;get;}
        public String contactUsage{set;get;}
        public String verifiedDate{set;get;}
        public String expiryDate{set;get;}
    }

}