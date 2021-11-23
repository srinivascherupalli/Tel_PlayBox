/****************************************************************************
@Author: Aishwarya Yeware
@Story: EDGE-100327
@Description: PpvTrigger 
*********************************************************************************/
trigger PpvTrigger on Customer_Authority_Form__c (before update,after update) {
    //PpvTriggerHandler ppv=new PpvTriggerHandler();
    
    //EDGE-100327Added before update context to the trigger
    if(Trigger.isBefore && Trigger.isUpdate){
        PpvTriggerHandler.onBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }
    //EDGE-100327Added after update context to the trigger
    if(Trigger.isAfter && Trigger.isUpdate){
        //EDGE-144140. Kalashree Borgaonkar. update parent status
        PpvTriggerHandler.updateParentStatus(Trigger.newMap,Trigger.oldMap);
        PpvTriggerHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
        //EDGE-132716. Kalashree Borgaonkar. Initiate PPV callout
        PpvTriggerHandler.onAfterCASigned(Trigger.newMap,Trigger.oldMap);

    }
   
    
}