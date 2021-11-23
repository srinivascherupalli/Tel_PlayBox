trigger AccountAddressRelationshipTrigger on cscrm__Account_Address_Relationship__c (before insert,before update,before delete,after insert,
                                                        after update,after delete, after undelete) {

    AccountAddressRelationshipTriggerHandler handler = new AccountAddressRelationshipTriggerHandler();

	if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);     
    } else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new);
    }
}