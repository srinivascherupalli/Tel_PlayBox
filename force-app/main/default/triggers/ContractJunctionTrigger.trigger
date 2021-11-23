/****************************************************************************
@Author: Maq
@CreateDate: 08/11/2018.
@Description: ContractJunctionTrigger trigger to handle delete event.
@TestCoverageClass: ContractJunctionTriggerTest
@ChangeLog: v1 - Created
********************************************************************************/
trigger ContractJunctionTrigger on ContractJunction__c (after update, before delete,after insert) {
    // Trigger Switch to disable trigger 
    if(EnvironmentalSettings.isTriggerDisabled('ContractJunctionTrigger')) {
        return; 
    }
    ContractJunctionTriggerHandler CJhandler = new ContractJunctionTriggerHandler();
    if(Trigger.isbefore && Trigger.isdelete){
        CJhandler.onBeforeDelete(Trigger.new, Trigger.newMap, Trigger.old,Trigger.oldMap);
    }
    //EDGE-81053 : After update event : 26 july 2019 : Manoj Kumar
     if(Trigger.isUpdate && Trigger.isAfter){
        CJhandler.onAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old,Trigger.oldMap);
        //serviceTermAttachmentPRM.attchCntrUp(Trigger.new);
    }
     //EDGE-207342: After Insert event :28 April 2021 : Rahul Asarma
    if(Trigger.isInsert && Trigger.isAfter){
        CJhandler.onAfterInsert(Trigger.new, Trigger.newMap);
        
    }
}