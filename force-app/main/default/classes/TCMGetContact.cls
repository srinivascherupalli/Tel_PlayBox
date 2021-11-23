/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
*/
public without sharing class TCMGetContact {

 	/**
     * Description : Create Contact object and update AccountContactRelation object for the created contact. 
     */
    public void createContacts(JSON2TCMCustomerContactObject customerContact, Account tcmCustomer){
    	System.debug('TCMGetContact - Creating Contact/AccountContactRelation for : '  + tcmCustomer.CIDN__c );
        try{
            if(tcmCustomer != null && customerContact != null && customerContact.data != null 
               && customerContact.data.contacts != null && !customerContact.data.contacts.isEmpty()){
                   List<Contact>  tcmContactList = new List<Contact>();
                   for(JSON2TCMCustomerContactObject.Contacts contact : customerContact.data.contacts){
                       Contact tcmCustomerContact = getContact(contact, tcmCustomer);
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
        }catch(Exception e){
        	System.debug('TCMGetContact - Exception while creating Contact/AccountContactRelation : ' + e.getMessage());
        	throw new TCMException.TCMContactCreationException(e.getMessage());
        }
    }

    public Contact getContact(JSON2TCMCustomerContactObject.Contacts contact, Account tcmCustomer){
    	System.debug('TCMGetContact - Building contact object : ' + contact.id);
        Contact tcmCustomerContact = new Contact();
        tcmCustomerContact.AccountId = tcmCustomer.Id;
        tcmCustomerContact.LastName = contact.LastName;
        tcmCustomerContact.MiddleName = contact.MiddleName;
        tcmCustomerContact.Salutation = contact.title;
        tcmCustomerContact.FirstName = contact.firstName;
        if(contact.birthDate != null && String.isNotBlank(contact.birthDate)){
            tcmCustomerContact.Birthdate = Date.valueOf(contact.birthDate);    
        }
        tcmCustomerContact.UUID__c = contact.id;
        tcmCustomerContact.Contact_Status__c= contact.status;
        tcmCustomerContact.Imported__c = true;
        tcmCustomerContact.Pref_Comm_Method__c=contact.preferredMethod;
        //tcmCustomerContact.jobTitle__c = contact.jobTitle;
        //tcmCustomerContact.Job_Description__c = contact.jobDescription;
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
        if(contact.customerAccounts != null){
            tcmCustomerContact.Phone_Opt_In__c = TCMCustomerContactHelper.validateField(contact.customerAccounts.phoneOptIn);
            tcmCustomerContact.MMS_Opt_In__c = TCMCustomerContactHelper.validateField(contact.customerAccounts.mmsOptIn);
            tcmCustomerContact.Direct_Mail_Opt_In__c = TCMCustomerContactHelper.validateField(contact.customerAccounts.directMailOptIn);
            tcmCustomerContact.Email_Opt_In__c = TCMCustomerContactHelper.validateField(contact.customerAccounts.emailOptIn);
            tcmCustomerContact.Face_to_Face_Opt_In__c = TCMCustomerContactHelper.validateField(contact.customerAccounts.faceToFaceOptIn);
            tcmCustomerContact.SMS_Opt_In__c = TCMCustomerContactHelper.validateField(contact.customerAccounts.smsOptIn);
        }
        return tcmCustomerContact;
    }
	
	public List<AccountContactRelation> updateAccountContactRelationship(Account tcmCustomer, List<Contact> contacts, JSON2TCMCustomerContactObject customerContact){
		System.debug('TCMGetContact - Building AccountContactRelation objects for CIDN : ' + tcmCustomer.CIDN__c);
		Set<Id> contactIds = new Set<Id>();
        Map<String,String> contactMap = new Map<String,String>();
        Map<String,AccountContactRelation> accRMap = new Map<String,AccountContactRelation>();
        List<AccountContactRelation> relationShipToUpdate = new List<AccountContactRelation>();
        for(Contact contactId : contacts){
            if(contactId.Id != null){
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
                            String acrEndDate = contact.customerAccounts.contactRelationship.endDate;
                            String contactType = contact.customerAccounts.contactRelationship.contactType;
                            if(acrEndDate != null && String.isNotBlank(acrEndDate)){
                                acr.Relationship_End_Date__c=Date.valueof(contact.customerAccounts.contactRelationship.endDate);
                            }
                            if(contactType != null && String.isNotBlank(contactType)){
                                acr.Contact_Type__c=contactType;
                                relationShipToUpdate.add(acr);
                            }
                        }
                        
                    }
                }
            }
        }
        return relationShipToUpdate;
	}    

}