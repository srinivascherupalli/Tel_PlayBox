@isTest
public class JSON2TCMContactDataObjectTest {

    static testMethod void initialise() {
        JSON2TCMContactDataObject cdo = new JSON2TCMContactDataObject();
        cdo.id = '';
        cdo.href = '';
        cdo.title = '';
        cdo.firstName = '';
        cdo.middleName = '';
        cdo.lastName = '';
        cdo.birthDate = '';
        cdo.status = '';
        cdo.onlineFlag = '';
        cdo.preferredMethod = '';
        cdo.homeContact = new JSON2TCMContactDataObject.HomeContact();
        cdo.homeContact.emailAddress = '';
		cdo.homeContact.faxNumber = '';
		cdo.homeContact.phoneNumber = '';
		cdo.homeContact.mobileNumber = '';
        cdo.workContact = new JSON2TCMContactDataObject.HomeContact();
        cdo.workContact.emailAddress = '';
		cdo.workContact.faxNumber = '';
		cdo.workContact.phoneNumber = '';
		cdo.workContact.mobileNumber = '';
        cdo.identification = new JSON2TCMContactDataObject.Identification();
        cdo.identification.driverLicense = new JSON2TCMContactDataObject.DriverLicense();
        cdo.identification.driverLicense.id_number = '';
		cdo.identification.driverLicense.state = '';
        
        cdo.customerAccounts = new List<JSON2TCMContactDataObject.CustomerAccounts>();
        JSON2TCMContactDataObject.CustomerAccounts ca = new JSON2TCMContactDataObject.CustomerAccounts();
        ca.accountUuid = '';
        ca.href = '';
        ca.id = '';
        ca.lastName = '';
        ca.contactRelationship = new JSON2TCMContactDataObject.ContactRelationship();
        ca.contactRelationship.endDate = '';
        ca.contactRelationship.contactType = '';
        ca.contactRelationship.contactUsage = '';
        cdo.customerAccounts.add(ca);
        system.assertEquals('', cdo.id);
    }
    
}