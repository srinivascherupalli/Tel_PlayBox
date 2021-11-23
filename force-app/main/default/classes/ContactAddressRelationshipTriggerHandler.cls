/****************************************************************************
@Author: Shambo Ray
@CreateDate: 24/04/2018
@Description: ContactAddressRelationshipTriggerHandler for Microservices.
********************************************************************************/
public without sharing class ContactAddressRelationshipTriggerHandler{
    private ContactAddressRelationshipTriggerHelper cth= null;
    public ContactAddressRelationshipTriggerHandler(){
        cth=new ContactAddressRelationshipTriggerHelper();
    }
    public void onAfterInsert(Map<Id,cscrm__Contact_Address_Relationship__c> oldMap,Map<Id,cscrm__Contact_Address_Relationship__c> newMap, List<cscrm__Contact_Address_Relationship__c> newList){
        cth.sendManageContactAddressForCreate(newMap);
        cth.publishCreateEvents(newList,EventConstants.UPDATE_OPERATION);
    }
    public void onAfterUpdate(Map<Id,cscrm__Contact_Address_Relationship__c> oldMap,Map<Id,cscrm__Contact_Address_Relationship__c> newMap,List<cscrm__Contact_Address_Relationship__c> newList){
        cth.sendManageContactAddress(oldMap,newMap);
        cth.publishCreateEvents(newList,EventConstants.UPDATE_OPERATION);
    }    
    public void onBeforeUpdate(List<cscrm__Contact_Address_Relationship__c> newList){
        cth.updatePrimaryAndActiveAddress(newList);
    }
    public void onBeforeInsert(List<cscrm__Contact_Address_Relationship__c> newList){
        cth.updatePrimaryAndActiveAddress(newList);
    }
    
}