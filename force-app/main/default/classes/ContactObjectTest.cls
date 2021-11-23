@isTest
public class ContactObjectTest {

    static testMethod void initialise() {
		ContactObject co = new ContactObject();
        co.data = new ContactObject.Data();
        co.data.contacts = new List<ContactObject.Contact>();
        
        ContactObject.Contact contact = new ContactObject.Contact();
        contact.middleName = '';
        contact.preferredMethod = '';
        contact.lastName = '';
        contact.onlineFlag = '';
        contact.status = '';
        contact.id = '';
        contact.title = '';
        contact.birthDate = '';
        contact.firstName = '';
        contact.languagePreference = '';
        
        contact.workContact = new ContactObject.WorkContact();
        contact.workContact.faxNumber = '';
        contact.workContact.phoneNumber = '';
        contact.workContact.emailAddress = '';
        contact.workContact.mobileNumber = '';
        
        contact.identification = new ContactObject.Identification();
        contact.identification.driverLicense = new ContactObject.DriverLicense();
        contact.identification.driverLicense.state = '';
        contact.identification.driverLicense.dlNumber = '';
        
        contact.homeContact = new ContactObject.HomeContact();
        contact.homeContact.faxNumber = '';
        contact.homeContact.phoneNumber = '';
        contact.homeContact.emailAddress = '';
        contact.homeContact.mobileNumber = '';
        
        contact.customerAccounts = new List<ContactObject.CustomerAccount>();
        ContactObject.CustomerAccount customerAccount = new ContactObject.CustomerAccount();
        customerAccount.mmsOptIn = '';
        customerAccount.id = '';
        customerAccount.lastName = '';
        customerAccount.phoneOptIn = '';
        customerAccount.emailOptIn = '';
        customerAccount.businessUnit = '';
        customerAccount.faceToFaceOptIn = '';
        customerAccount.directMailOptIn = '';
        customerAccount.dataSovereignty = '';
        customerAccount.accountUuid = '';
        customerAccount.smsOptIn = '';
        customerAccount.contactRelationship = new ContactObject.ContactRelationship();
        customerAccount.contactRelationship.contactUsage = '';
        customerAccount.contactRelationship.contactType = '';
        customerAccount.contactRelationship.endDate = '';
		contact.customerAccounts.add(customerAccount);		
        
        co.data.contacts.add(contact);
    }
  
}