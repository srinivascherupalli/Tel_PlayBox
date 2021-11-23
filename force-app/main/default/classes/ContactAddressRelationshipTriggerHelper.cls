/****************************************************************************
@Author: Shambo Ray
@CreateDate: 27/06/2018
@Story: EDGE-17468
@Description: Uset wants the Contact to have only 1 Primary Home address and 1 Primary Office Address so that the information is communicated to TCM
********************************************************************************/
public without sharing class ContactAddressRelationshipTriggerHelper {
    public static Boolean hasManageFiredFromContactAddress=false;
    //For updating or inserting address details in Force.com database
    public void updatePrimaryAndActiveAddress(List<cscrm__Contact_Address_Relationship__c> newList){
        Boolean flag=false;
        List<Id> contactIdList=new List<Id> ();
        for(cscrm__Contact_Address_Relationship__c csAdd:newList){
            contactIdList.add(csAdd.cscrm__Contact__c);
        }
        List<Contact> contactList=getContactAndRelatedAddresses(contactIdList);
        validateHomeAndOfficeAddresses(newList,contactList);
    }
    //To retrieve related addresses of contact
    private List<Contact> getContactAndRelatedAddresses(List<Id> contactIdList){
        return [select id,name,(select id,Primary__c,cscrm__Contact__c,source_system__c,cscrm__Active__c,cscrm__Address__c,cscrm__Address_Type__c from cscrm__Contact_Address_Relationships__r where cscrm__Active__c=true and Primary__c=true) from contact where id in: contactIdList];
    }
    //Main method to validate unique active and primary Home/Office addresses
    private void validateHomeAndOfficeAddresses(List<cscrm__Contact_Address_Relationship__c> newList,List<Contact> contactList){
        List<String> addressTypeList=new List<String> ();
        Boolean hasActivatedHomeAddress=false;
        Boolean hasActivatedOfficeAddress=false;
        Map<Id,List<cscrm__Contact_Address_Relationship__c>> contactToAddressMap= new Map<Id,List<cscrm__Contact_Address_Relationship__c>>();
        Map<Id,Boolean> hasPrimaryHomeAddress=new Map<Id,Boolean>();
       	Map<Id,Boolean> hasPrimaryOfficeAddress=new Map<Id,Boolean>();
        checkHasPrimaryOrActiveAddresses(contactList,contactToAddressMap,hasPrimaryHomeAddress,hasPrimaryOfficeAddress);
        for(cscrm__Contact_Address_Relationship__c conAdd:newList){
            if(contactToAddressMap.get(conAdd.cscrm__Contact__c)!=null && !contactToAddressMap.get(conAdd.cscrm__Contact__c).isEmpty()){
                for(cscrm__Contact_Address_Relationship__c conAddRelations:contactToAddressMap.get(conAdd.cscrm__Contact__c)) {
                    addressTypeList.add(conAddRelations.cscrm__Address_Type__c);
                }
            }
            if(!addressTypeList.isEmpty()
               && !addressTypeList.contains('Home Address')
               && conAdd.cscrm__Address_Type__c!=null
               && 'Home Address'.contains(conAdd.cscrm__Address_Type__c)
               && !hasActivatedHomeAddress
               && conAdd.Primary__c 
               && conAdd.cscrm__Active__c){
                   hasActivatedHomeAddress=true;
               }
            if(!addressTypeList.isEmpty()
               && !addressTypeList.contains('Office Address')
               && conAdd.cscrm__Address_Type__c!=null
               && 'Office Address'.contains(conAdd.cscrm__Address_Type__c)
               && !hasActivatedOfficeAddress
               && conAdd.Primary__c 
               && conAdd.cscrm__Active__c){
                   hasActivatedOfficeAddress=true;
               }
            else if(!addressTypeList.isEmpty()
                    && addressTypeList.contains('Home Address')
                    && conAdd.cscrm__Address_Type__c!=null
                    && hasPrimaryHomeAddress.get(conAdd.cscrm__Contact__c)!=null
                    && hasPrimaryHomeAddress.get(conAdd.cscrm__Contact__c)
                    && 'Home Address'.contains(conAdd.cscrm__Address_Type__c)
                    && conAdd.Primary__c 
                    && conAdd.cscrm__Active__c){
                        conAdd.addError('Active Primary Home Address already present for the Contact. Modify existing active primary home address and retry.');
                    }
            else if(!addressTypeList.isEmpty()
                    && addressTypeList.contains('Office Address')
                    && conAdd.cscrm__Address_Type__c!=null
                    && hasPrimaryOfficeAddress.get(conAdd.cscrm__Contact__c)!=null
                    && hasPrimaryOfficeAddress.get(conAdd.cscrm__Contact__c)
                    && 'Office Address'.contains(conAdd.cscrm__Address_Type__c)
                    && conAdd.Primary__c 
                    && conAdd.cscrm__Active__c){
                        conAdd.addError('Active Primary Office Address already present for the Contact. Modify existing active primary home address and retry.');
                    }
        }
    }
    //This Method To Check that the existing addresses of contact of type 'Home' or 'Office' is active or primary
    private void checkHasPrimaryOrActiveAddresses(List<Contact> contactList,Map<Id,List<cscrm__Contact_Address_Relationship__c>> contactToAddressMap,Map<Id,Boolean> hasPrimaryHomeAddress,Map<Id,Boolean> hasPrimaryOfficeAddress){
        if(!contactList.isEmpty()){
            for(Contact contacts:contactList){
                if(contacts.cscrm__Contact_Address_Relationships__r !=null
                   && !contacts.cscrm__Contact_Address_Relationships__r.isEmpty()){
                       contactToAddressMap.put(contacts.Id,contacts.cscrm__Contact_Address_Relationships__r);
                       for(cscrm__Contact_Address_Relationship__c conAdds:contacts.cscrm__Contact_Address_Relationships__r){
                           if(conAdds.cscrm__Address_Type__c!=null && 'Home Address'.contains(conAdds.cscrm__Address_Type__c)){
                               hasPrimaryHomeAddress.put(contacts.id, true);
                           }else if(conAdds.cscrm__Address_Type__c!=null && 'Office Address'.contains(conAdds.cscrm__Address_Type__c)){
                               hasPrimaryOfficeAddress.put(contacts.id, true);
                           }
                       }
                   }
            }
        }
    }
    //Sending Manage Request for Contact's primary and activate address
    public void sendManageContactAddress(Map<Id,cscrm__Contact_Address_Relationship__c> oldcontactAddressMap,Map<Id,cscrm__Contact_Address_Relationship__c> newcontactAddressMap){
        ContactTriggerHandler cth = new ContactTriggerHandler();
        FieldUpdateIdentifier fui = new FieldUpdateIdentifier(cscrm__Contact_Address_Relationship__c.SobjectType);
        Map<id, sobject> matches = fui.identifyUpdatesToMonitoredFields(newcontactAddressMap, oldcontactAddressMap);
        Map<Id,Contact> contactMap = getContactMap(newcontactAddressMap.values());
        Interface_Activation__c iActivation = Interface_Activation__c.getValues('Manage Contact Create');
        List<ManageContactDAO> manageContactsCreateEventTrigger = new List<ManageContactDAO>();
        List<ManageContactDAO> manageContactsUpdateEventTrigger = new List<ManageContactDAO>();
        if(matches!=null && !matches.isEmpty()){
            for(Id ids : matches.keySet()){
                if(!contactMap.isEmpty()){
                    Contact contacts=contactMap.get(newcontactAddressMap.get(ids).cscrm__Contact__c);
                    if(String.isBlank(contacts.UUID__c)
                       && isCreateEventEnabled(iActivation)){
                           ManageContactDAO mcDAO = new ManageContactDAO(contacts,ManageContactHandler.EVENT_ACTION_CREATE);
                           manageContactsCreateEventTrigger.add(mcDAO);
                       } else if(String.isNotBlank(contacts.UUID__c) && 
                                 System.UserInfo.getUserName() != IntegrationSettings__c.getInstance().Integration_API_User__c){
                                     ManageContactDAO mcDAO = new ManageContactDAO(contacts,ManageContactHandler.EVENT_ACTION_UPDATE);
                                     manageContactsUpdateEventTrigger.add(mcDAO);
                                 }
                }
            }
        }
        if(!hasManageFiredFromContactAddress){
            cth.sendManageEvent(manageContactsCreateEventTrigger);
            cth.sendManageEvent(manageContactsUpdateEventTrigger);
            hasManageFiredFromContactAddress=true;
        }
    }
    public void sendManageContactAddressForCreate(Map<Id,cscrm__Contact_Address_Relationship__c> newcontactAddressMap){
        ContactTriggerHandler cth = new ContactTriggerHandler();
        Map<Id,Contact> contactMap = getContactMap(newcontactAddressMap.values());
        Interface_Activation__c iActivation = Interface_Activation__c.getValues('Manage Contact Create');
        List<ManageContactDAO> manageContactsCreateEventTrigger = new List<ManageContactDAO>();
        List<ManageContactDAO> manageContactsUpdateEventTrigger = new List<ManageContactDAO>();
        for(ID ids:newcontactAddressMap.keySet()){
            if(!contactMap.isEmpty() && newcontactAddressMap.get(ids).Primary__c && newcontactAddressMap.get(ids).cscrm__Active__c){
                Contact contacts=contactMap.get(newcontactAddressMap.get(ids).cscrm__Contact__c);
                if(String.isBlank(contacts.UUID__c)
                   && isCreateEventEnabled(iActivation)){
                       ManageContactDAO mcDAO = new ManageContactDAO(contacts,ManageContactHandler.EVENT_ACTION_CREATE);
                       manageContactsCreateEventTrigger.add(mcDAO);
                   } else if(String.isNotBlank(contacts.UUID__c) && 
                             System.UserInfo.getUserName() != IntegrationSettings__c.getInstance().Integration_API_User__c){
                                 ManageContactDAO mcDAO = new ManageContactDAO(contacts,ManageContactHandler.EVENT_ACTION_UPDATE);
                                 manageContactsUpdateEventTrigger.add(mcDAO);
                             }
            }
        }
        if(!hasManageFiredFromContactAddress){
            cth.sendManageEvent(manageContactsCreateEventTrigger);
            cth.sendManageEvent(manageContactsUpdateEventTrigger);
            hasManageFiredFromContactAddress=true;
        }
    }
    //Create Event Enabled
    private Boolean isCreateEventEnabled(Interface_Activation__c iActivation){
        return (iActivation!=null && iActivation.Status__c) ? true : false;
    }
    //Querying Related Addresses of Contact
    private Map<Id,Contact> getContactMap(List<cscrm__Contact_Address_Relationship__c> newcontactAddressList){
        List<Id> idList=new List<Id>();
        for(cscrm__Contact_Address_Relationship__c contactAddresses:newcontactAddressList){
            if(contactAddresses.Primary__c && contactAddresses.cscrm__Active__c && contactAddresses.cscrm__Address_Type__c!=null &&('Home Address'.contains(contactAddresses.cscrm__Address_Type__c)||'Office Address'.contains(contactAddresses.cscrm__Address_Type__c))){
                 idList.add(contactAddresses.cscrm__Contact__c);
            } 
        }
        Map<Id,Contact> contactMap=new Map<Id,Contact>([SELECT Id, IsDeleted, MasterRecordId, AccountId, LastName, FirstName, Salutation, MiddleName, Name, RecordTypeId, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone, ReportsToId, Email, Title, Department, AssistantName, LeadSource, Birthdate, Description, OwnerId, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastCURequestDate, LastCUUpdateDate, LastViewedDate, LastReferencedDate, EmailBouncedReason, EmailBouncedDate, IsEmailBounced, PhotoUrl, Jigsaw, JigsawContactId, APTPS_Role__c, cscrm__Address__c, cscrm__Birth_Certificate_Authority__c, cscrm__Birth_Certificate_Country__c, cscrm__Birth_Certificate_Date__c, cscrm__Birth_Certificate_Number__c, cscrm__Concession_Number__c, cscrm__Concession_Type__c, cscrm__Concession__c, cscrm__Current_Employer_Name__c, cscrm__Current_Employer_Phone__c, cscrm__Drivers_License_Country__c, cscrm__Drivers_License_Expiry_Date__c, cscrm__Drivers_License_Number__c, cscrm__External_ID__c, cscrm__National_Health_Card_Expiry_Date__c, cscrm__National_Health_Card_Number__c, cscrm__Occupation__c, cscrm__Paperless_Billing__c, cscrm__Pasport_Expiry_Date__c, cscrm__Passport_Country__c, cscrm__Passport_Issue_Date__c, cscrm__Passport_Number__c, cscrm__Previous_Address__c, cscrm__Residential_Status__c, cscrm__Social_Security_Card_Number__c, cscrm__Student_Card_Authority__c, cscrm__Student_Card_Country__c, cscrm__Student_Card_Expiry_Date__c, cscrm__Student_Card_Number__c, cscrm__Time_at_Current_Address__c, cscrm__Time_at_Current_Employment__c, cscrm__Time_at_Previous_Address__c, cscrm__Time_at_Previous_Employment__c, Contact_Status__c, Driver_License_Id__c, HomePhone__c, Home_Email__c, Home_Fax__c, Imported__c, Language_Preference__c, LastCURequestDate__c, Mailing_Address_Ext__c, Merge_Status__c, Mobile_Phone_Number__c, NPS_Contact__c, No_Mktg_Mail__c, No_SMS__c, No_Telemarketing__c, Not_Campaign_able__c, Online_Flag__c, Other_Address_Ext__c, Pref_Comm_Method__c, Product_Contact__c, Send_Create_Event__c, UUID__c, accountUuid__c, addressId__c, country__c, eNews__c, eOffers__c, lastVerifiedDate__c, numberInHousehold__c, Driver_Licence_State__c, AFL_A_League_NRL_Teams__c, Contact_Verified__c, Has_Reviewed__c, Hobbies_and_Interests__c, Is_Lead_Originated__c, LinkedIn_Profile__c, Merge_Lock__c, Notes__c, Occupation__c, Other_Sports_Teams__c, ParentSourceSystemAction__c, Prefered_Name__c, ReferenceMessage__c, Skip_Validation__c, Source_System__c, TCM_Last_Updated_Datetime__c, Contact_Change_Declaration__c, Contact_Role__c, Sales_Contact__c, Onboarding_Status__c, Event_Preferences__c, Sales_Contact_Status__c, P_Number__c, timeZone__c FROM Contact WHERE id IN:idList]);
      	return contactMap;
    } 
    //Publishing Events to Microservice
    public void publishCreateEvents(List<cscrm__Contact_Address_Relationship__c> newList,String event){
        //Dynamic Binding
        PublishEvents publishIntface = PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newList,EventConstants.BUSINESS_ENTITY_CONTACT,event);
        publishIntface.createEvent(); 
    }
}