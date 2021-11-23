/*
    AUTHOR : Lok Jackson
    DESCRIPTION : Trigger for UserTerritory2Association, calls a handler class to manage orchestration
*/

trigger UserTerritory2AssociationTrigger on UserTerritory2Association (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	//Instaniate handler class
	UserTerritory2AssociationTriggerHandler handler = new UserTerritory2AssociationTriggerHandler();

	//only needed triggers have been implemented below, extend as needed

    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);     
    }

    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old,Trigger.oldMap, Trigger.new, Trigger.newMap);
    }

}