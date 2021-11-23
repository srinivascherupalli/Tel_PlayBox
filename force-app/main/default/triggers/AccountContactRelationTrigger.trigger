/**
* Trigger ON ACR object  For EDGE-38 AC2
* @Description : EDGE 38. Custom Invoking Manage Interface Dynamically
* @Author : Shambo Ray
* @Date : 01/01/2018
* @Story : EDGE-38 : Invoking Manage Interface Dynamically

Update : DIGI 4057 : Team SFO : Chhaveel : Added before delete to the trigger
**/
trigger AccountContactRelationTrigger on AccountContactRelation (before update,before insert,after insert,after update,before delete) {
    
    if(EnvironmentalSettings.isTriggerDisabled('AccountContactRelationTrigger')){
        return;
    }
    
    AccountContactRelationshipTriggerHandler acrHandler = new AccountContactRelationshipTriggerHandler();
    
    if(Trigger.isafter && Trigger.isinsert){
        acrHandler.onAfterInsert(Trigger.newMap); 
    }
    if(Trigger.isafter && Trigger.isUpdate){
        acrHandler.onAfterUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
    }
    if(Trigger.isbefore && Trigger.isinsert){
        acrHandler.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isbefore && Trigger.isUpdate){
        acrHandler.onBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }
    if(Trigger.isbefore && Trigger.isDelete){
        acrHandler.onBeforeDelete(Trigger.oldMap);
    }
    
}