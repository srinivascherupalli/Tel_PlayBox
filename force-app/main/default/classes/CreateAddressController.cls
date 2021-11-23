//EDGE - 49257
//Author - Kalashree Borgaonkar
//Pop-up functionality for contact-address relationship
public without sharing class  CreateAddressController {
   
     @AuraEnabled
        public static String saveNewContact(String addressType, String contact, String address,Boolean active,Boolean primary){
        
			cscrm__Contact_Address_Relationship__c contactAddressRelationship = new cscrm__Contact_Address_Relationship__c();
            contactAddressRelationship.cscrm__Address_Type__c = addressType;
            contactAddressRelationship.cscrm__Contact__c = contact;
            contactAddressRelationship.cscrm__Address__c = address;
            contactAddressRelationship.cscrm__Active__c = active;
            contactAddressRelationship.Primary__c = primary;
            return AddressAndSiteObjectUtility.contactAddressRelSaveUtility(contactAddressRelationship);
       
    }
    @AuraEnabled
    public static sObject getAddressType(String address){
        sObject AddressType;       
		AddressType = Database.query('select cscrm__Address_Type__c from cscrm__Address__c where Id = : address'); 
        return AddressType;
    }

	@AuraEnabled
    public static String getAddressNameSFDC(String addressId){
        String addressName = '';
        try{
            if(!String.isEmpty(addressId)){
            	cscrm__Address__c addressRecord = [SELECT Street_Number_Start_calc__c, Street_Number_End_calc__c, cscrm__Street_Name__c, Street_Type_calc__c, Locality__c FROM cscrm__Address__c WHERE Id =:addressId];
                String streetNumberStart = (null != String.valueOf(addressRecord.Street_Number_Start_calc__c)? String.valueOf(addressRecord.Street_Number_Start_calc__c) : '');
                String streetNumberEnd = (null != String.valueOf(addressRecord.Street_Number_End_calc__c)? String.valueOf(addressRecord.Street_Number_End_calc__c) : '');
                String streetName = (null != String.valueOf(addressRecord.cscrm__Street_Name__c)? String.valueOf(addressRecord.cscrm__Street_Name__c) : '');
                String streetType = (null != String.valueOf(addressRecord.Street_Type_calc__c)? String.valueOf(addressRecord.Street_Type_calc__c) : '');
                String locality = (null != String.valueOf(addressRecord.Locality__c)? String.valueOf(addressRecord.Locality__c) : '');
                addressName = streetNumberStart + ' ' + streetNumberEnd + ' ' + streetName + ' ' + streetType + ' ' + ' ' + locality;
            }
            
            return addressName;
        }catch(Exception e){
            system.debug('Exception while getting address details :'+e.getMessage());
        }
        
        return addressName;
    }
    
    @AuraEnabled
   public static sObject getParentContact(String contactId){
        Contact contactRecord = New Contact();
        try{
            if(!String.isEmpty(contactId)){
                Contact contactDetails =Database.query('SELECT Id, Name FROM Contact WHERE ID =:contactId');
                contactRecord = contactDetails;
               }
            return contactRecord;
        }catch(Exception e){
            system.debug('Exception while loading account details :'+e.getMessage());
        }
        return contactRecord;
    }
    
     @AuraEnabled
    public static List<SelectOptionz> getContactAddressTypesController(){
        return AddressAndSiteObjectUtility.getContactAddressTypes();
    }
     @AuraEnabled
    public static Boolean hasAddress(String addressType,String contact){ 
       //system.debug('contact'+contact);
        List<cscrm__Contact_Address_Relationship__c> accAddressRelationship = [SELECT Id, cscrm__Contact__c, cscrm__Address_Type__c FROM cscrm__Contact_Address_Relationship__c WHERE cscrm__Contact__c = :contact AND cscrm__Address_Type__c = :addressType AND cscrm__Active__c=true AND primary__c=true];
        return accAddressRelationship.isEmpty();
    }
}