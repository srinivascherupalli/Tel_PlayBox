public with sharing class ContactEditNameController {
    @AuraEnabled
	public contact con;
    @AuraEnabled
    public static ContactEditNameController getContactRecord1(Id ContactId){
        ContactEditNameController cr = new ContactEditNameController();
		cr.con = [SELECT Name,firstname,middlename,lastname,Salutation  FROM Contact where id = :ContactId];
		system.debug(cr);
		return cr;
    }
    
    @AuraEnabled
    public static Phoenix_Configurations__c getRecordTypeId(){
        
        return Phoenix_Configurations__c.getInstance();
    }
}