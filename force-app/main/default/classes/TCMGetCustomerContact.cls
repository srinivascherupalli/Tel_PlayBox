/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
* LastModifiedBy: Amar Chakka (SFO)
* Last Modified Sprint: SFO Sprint 20.16, P2OB-9994.
* Description: While Inserting Contact via TCM Advanced Search Button,  Mapping ContactType field from TCM http Response to Authority Field.
*/
public class TCMGetCustomerContact {

    public List<String> contactUUIDs{get;private set;}
    
 	/**
     * Description : Create Contact object and update AccountContactRelation object for the created contact. 
     */
    public void createContacts(JSON2TCMCustomerContactObject customerContact, Account tcmCustomer){
    	System.debug('TCMGetCustomerContact - Creating Contact/AccountContactRelation for : '  + tcmCustomer.CIDN__c );
        try{
            if(tcmCustomer != null && customerContact != null && customerContact.data != null 
               && customerContact.data.contacts != null && !customerContact.data.contacts.isEmpty()){
                   List<Contact>  tcmContactList = new List<Contact>();
                   for(JSON2TCMCustomerContactObject.Contacts contact : customerContact.data.contacts){
                       Contact tcmCustomerContact = getContact(contact, tcmCustomer.Id);
                       tcmContactList.add(tcmCustomerContact);
                   }
                   if(!tcmContactList.isEmpty()){
                       upsert tcmContactList UUID__c;
                       List<AccountContactRelation> accRList = updateAccountContactRelationship(tcmCustomer, tcmContactList, customerContact);
                       if(!accRList.isEmpty()){
                           update accRList;
                       } 
                   }
               }
        }catch(DmlException e){
        	System.debug('TCMGetCustomerContact - Exception while creating Contact/AccountContactRelation : ' + e.getMessage());
        	throw new TCMException.TCMContactCreationException(e.getMessage(),e);
        }
    }

    //GetCustomerContact-Mapping Contact fields from TCM to SFDC
    public Contact getContact(JSON2TCMCustomerContactObject.Contacts contact, Id tcmCustomerId){
    	System.debug('TCMGetCustomerContact - Building contact object : ' + contact.id);
        Contact tcmCustomerContact = new Contact();
        tcmCustomerContact.AccountId = tcmCustomerId;
        tcmCustomerContact.LastName = contact.LastName;
        tcmCustomerContact.MiddleName = contact.MiddleName;
        tcmCustomerContact.Salutation = contact.title;
        tcmCustomerContact.FirstName = contact.firstName;
        tcmCustomerContact.Birthdate = validateDateField(contact.birthDate);    
        tcmCustomerContact.UUID__c = contact.id;
        //Added Below Line As part of Sprint 20.16 P2OB-9994. While Inserting Contact Mapping Contact Type field from TCM to Authority Field. 
        tcmCustomerContact.Authority__c = validateStringField(contact.customerAccounts.contactRelationship.contactType, null);
        // End of changes made by SFO Sprint 20.16 P2OB-9994
        //tcmCustomerContact.Contact_Status__c= contact.status;
        tcmCustomerContact.Imported__c = true;
        tcmCustomerContact.Pref_Comm_Method__c=contact.preferredMethod;
        if(contact.homeContact!=null){
            tcmCustomerContact.Home_Email__c=contact.homeContact.emailAddress;
            tcmCustomerContact.Home_Fax__c = TCMCustomerContactHelper.formatNumber(contact.homeContact.faxNumber);
            tcmCustomerContact.HomePhone=TCMCustomerContactHelper.formatNumber(contact.homeContact.mobileNumber);
            tcmCustomerContact.HomePhone__c = TCMCustomerContactHelper.formatNumber(contact.homeContact.phoneNumber);
        }
        if(contact.workContact != null){
            tcmCustomerContact.Email = contact.workContact.emailAddress;
            tcmCustomerContact.MobilePhone = TCMCustomerContactHelper.formatNumber(contact.workContact.mobileNumber);
            tcmCustomerContact.Fax = TCMCustomerContactHelper.formatNumber(contact.workContact.faxNumber);
            tcmCustomerContact.Phone = TCMCustomerContactHelper.formatNumber(contact.workContact.phoneNumber);
        }
		tcmCustomerContact.Language_Preference__c = 'English';
        return tcmCustomerContact;
    }
	
	public List<AccountContactRelation> updateAccountContactRelationship(Account tcmCustomer, List<Contact> contacts, JSON2TCMCustomerContactObject customerContact){
        System.debug('TCMGetCustomerContact - Building AccountContactRelation objects for CIDN : ' + tcmCustomer.CIDN__c);
        Set<Id> contactIds = new Set<Id>();
        contactUUIDs = new List<String>();
        Map<String,String> contactMap = new Map<String,String>();
        Map<String,AccountContactRelation> accRMap = new Map<String,AccountContactRelation>();
        List<AccountContactRelation> relationShipToUpdate = new List<AccountContactRelation>();
        for(Contact contactId : contacts){
            if(contactId.Id != null){
                contactUUIDs.add(contactId.UUID__c);
                contactIds.add(contactId.Id);
                contactMap.put(contactId.UUID__c, contactId.Id);
            }
        }
        List<AccountContactRelation> accRMapList = [SELECT Id, accountId, contactId, Contact_Type__c, Contact_Usage__c, Relationship_End_Date__c FROM AccountContactRelation where accountId = :tcmCustomer.Id and contactId IN :contactIds ];
        if(!accRMapList.isEmpty()){
            for(AccountContactRelation acRelation : accRMapList){
                accRMap.put(acrelation.ContactId, acRelation);
            }
            for(JSON2TCMCustomerContactObject.Contacts contact : customerContact.data.contacts){
                if(contact.customerAccounts != null && contact.customerAccounts.contactRelationship != null && contact.id != null){
                    String contId = contactMap.get(contact.id);
                    if(contId != null){
                        AccountContactRelation acr = accRMap.get(contId);
                        if(acr != null){
                                acr.Opt_Out_SMS_MMS__c = TCMCustomerContactHelper.validateOptInFields(contact.customerAccounts.mmsOptIn) && TCMCustomerContactHelper.validateOptInFields(contact.customerAccounts.smsOptIn) ? true : false;
                                acr.Opt_Out_Emails__c = TCMCustomerContactHelper.validateOptInFields(contact.customerAccounts.emailOptIn);
                                acr.Opt_Out_Face_to_Face__c = TCMCustomerContactHelper.validateOptInFields(contact.customerAccounts.faceToFaceOptIn);
                                acr.Opt_Out_Telemarketing__c = TCMCustomerContactHelper.validateOptInFields(contact.customerAccounts.phoneOptIn);
                                acr.Opt_Out_Direct_Mail_White_Mail__c = TCMCustomerContactHelper.validateOptInFields(contact.customerAccounts.directMailOptIn);
                                acr.Relationship_End_Date__c=validateDateField(contact.customerAccounts.contactRelationship.endDate);
                                acr.Roles= validateStringField(contact.customerAccounts.contactRelationship.contactType, null);
                                acr.Contact_Usage__c= validateStringField(contact.customerAccounts.contactRelationship.contactUsage, null);
 				                acr.Job_Title__c = contact.jobTitle;
				                //acr.Job_Description__c = contact.jobDescription;
                                acr.Relationship_Verified_Date__c = validateDateField(contact.customerAccounts.contactRelationship.verifiedDate);
                                acr.Relationship_Expiry_Date__c = validateDateField(contact.customerAccounts.contactRelationship.expiryDate);
                                relationShipToUpdate.add(acr);
                        }
                    }
                }
            }
        }
        return relationShipToUpdate;
	}    
    
	private String validateStringField(String value, String defaultValue){
        return (value != null && String.isNotBlank(value)) ? value : defaultValue;
    }
    
    private Date validateDateField(String value){
        return (value != null && String.isNotBlank(value)) ? Date.valueOf(value) : null;
    }
    
}