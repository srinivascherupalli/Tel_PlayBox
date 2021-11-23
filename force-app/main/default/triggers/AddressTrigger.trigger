trigger AddressTrigger on cscrm__Address__c (before insert,before update,after insert, after update) {   
    AddressTriggerHandler handler = new AddressTriggerHandler();
	if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(trigger.new);
    } 
//EDGE -122626. Kalashree Borgaonkar. Fix for Address status  
    if((Trigger.isUpdate ||Trigger.isInsert )  && Trigger.isBefore){
         handler.onBeforeInsertUpdate(trigger.new);
    }  
}