public without sharing class NewContactRelController {
    //private NewContactRelController(){}
    
    @AuraEnabled
    public static String saveNewAddressRel(String addressType, String contact, String address,Boolean active,Boolean primary){
            cscrm__Contact_Address_Relationship__c contactAddressRelationship = new cscrm__Contact_Address_Relationship__c();
            contactAddressRelationship.cscrm__Address_Type__c = addressType;
            contactAddressRelationship.cscrm__Contact__c = contact;
            contactAddressRelationship.cscrm__Address__c = address;
            contactAddressRelationship.cscrm__Active__c = active;
            contactAddressRelationship.Primary__c = primary;
            return AddressAndSiteObjectUtility.contactAddressRelSaveUtility(contactAddressRelationship);
        
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