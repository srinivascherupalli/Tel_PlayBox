/*****************************************************************************
@Name: CampaignMemberTrigger
@Author: Team SFO (Prathyusha , Sravanthi)
@CreateDate: 29/07/2019
@Description: EDGE-98344:CampaignMemberTrigger to implement history tracking on campaign member.
*******************************************************************************/
trigger CampaignMemberTrigger on CampaignMember (after insert, before update, before delete) {
    if(EnvironmentalSettings.isTriggerDisabled('CampaignMemberTrigger')){
        return;
    }
	CampaignMemberTriggerHandler handler=new CampaignMemberTriggerHandler();
    if(Trigger.isAfter && Trigger.isInsert){
        handler.afterInsert(Trigger.new, Trigger.old, Trigger.oldMap);    
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        handler.beforeUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        handler.beforeDelete(Trigger.old, Trigger.oldMap);
    }
    
}