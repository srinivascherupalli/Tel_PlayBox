global with sharing class CreateAddressAndContactRelationship implements Database.Batchable<sObject>{
	global final String Query; 
    global Integer recordsProcessed = 0;
    
    global CreateAddressAndContactRelationship(String q){ 
        query=q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts){ 
        try{
             	List<cscrm__Contact_Address_Relationship__c> ContactAddressRelationships =new List<cscrm__Contact_Address_Relationship__c>(); 
        		for(Contact contact : contacts){	        
                    List<cscrm__Address__c> addresses =new List<cscrm__Address__c>(); 
                    Integer contactAddressRelCount = [SELECT count() from cscrm__Contact_Address_Relationship__c WHERE cscrm__Contact__c =: contact.id];
                    system.debug('Total :'+contactAddressRelCount);
                    if(contactAddressRelCount <= 0){
                     	cscrm__Address__c address = new cscrm__Address__c();
                        address.Locality__c = contact.MailingCity;
                        address.cscrm__Country__c = contact.MailingCountry;
                        address.cscrm__Zip_Postal_Code__c = contact.MailingPostalCode;
                        address.cscrm__State_Province__c = contact.MailingState;
                        address.cscrm__Street_Name__c = contact.MailingStreet;
                        address.latitude__c = String.valueOf(contact.MailingLatitude);
                        address.longitude__c = String.valueOf(contact.MailingLongitude);
                        address.Source_System__c = 'Maxim';
                        
                        cscrm__Address__c addressOther = new cscrm__Address__c();
                        addressOther.Locality__c = contact.OtherCity;
                        addressOther.cscrm__Country__c = contact.OtherCountry;
                        addressOther.cscrm__Zip_Postal_Code__c = contact.OtherPostalCode;
                        addressOther.cscrm__State_Province__c = contact.OtherState;
                        addressOther.cscrm__Street_Name__c = contact.OtherStreet;
                        addressOther.latitude__c = String.valueOf(contact.OtherLatitude);
                        addressOther.longitude__c = String.valueOf(contact.OtherLongitude);
                        addressOther.Source_System__c = 'Maxim';
                        
                        addresses.add(address);                    
                        addresses.add(addressOther);
                        insert addresses;     
                        
                        cscrm__Contact_Address_Relationship__c contactAddressRelationship = new cscrm__Contact_Address_Relationship__c();
                        contactAddressRelationship.cscrm__Address_Type__c = 'Office Address';
                        contactAddressRelationship.cscrm__Contact__c = contact.Id;
                        contactAddressRelationship.cscrm__Address__c = address.Id;
                        contactAddressRelationship.cscrm__Active__c = true;
                        ContactAddressRelationships.add(contactAddressRelationship);
                        
                        cscrm__Contact_Address_Relationship__c contactAddressRelationshipOther = new cscrm__Contact_Address_Relationship__c();
                        contactAddressRelationshipOther.cscrm__Address_Type__c = 'Home Address';
                        contactAddressRelationshipOther.cscrm__Contact__c = contact.Id;
                        contactAddressRelationshipOther.cscrm__Address__c = addressOther.Id;
                        contactAddressRelationshipOther.cscrm__Active__c = true;
                        ContactAddressRelationships.add(contactAddressRelationshipOther);
                        
                        recordsProcessed = recordsProcessed + 1;   
                    }
                } 
             	System.debug(recordsProcessed + ' records processed successfully!');
               	insert ContactAddressRelationships; 
				// Create Address 
        }catch(Exception e){
            Logger.getLogger(CreateAddressAndContactRelationship.class).debug(e);
            Logger.exitLogger();
            System.debug(e.getMessage());
        }
    } 
    
    global void finish(Database.BatchableContext BC){ 
        System.debug(recordsProcessed + ' records processed successfully!');
    } 
}