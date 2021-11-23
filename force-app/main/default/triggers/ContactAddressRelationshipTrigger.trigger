/****************************************************************************
@Author: Shambo Ray
@CreateDate: 24/04/2018.
@Description: ContactAddressRelationshipTrigger object for Microservices.
********************************************************************************/
trigger ContactAddressRelationshipTrigger on cscrm__Contact_Address_Relationship__c (after insert,after update,before insert,before update) {    
    
    ContactAddressRelationshipTriggerHandler car=new ContactAddressRelationshipTriggerHandler();
    if(EnvironmentalSettings.isTriggerDisabled('ContactAddressRelationshipTrigger')){
        return;
    }
    if(Trigger.isbefore && Trigger.isinsert){
        car.onBeforeUpdate(Trigger.new);
    }
    if(Trigger.isbefore && Trigger.isupdate){
        car.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isafter && Trigger.isinsert){
    	car.onAfterInsert(Trigger.oldMap,Trigger.newMap,Trigger.new);
    }
    if(Trigger.isafter && Trigger.isupdate){
        car.onAfterUpdate(Trigger.oldMap,Trigger.newMap,Trigger.new);
	}
}