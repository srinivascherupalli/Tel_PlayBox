trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (after insert, after update,after delete,before insert) {
    /*
     * 18.11 Edge-15882 Start
     * @Author: SFO Team,Murali Nunna
       @CreateDate: 09/08/2018
     * */
    OpportunityTeamTriggerHandler otmh=new OpportunityTeamTriggerHandler();
    if(trigger.isAfter && Trigger.isInsert){
        otmh.onAfterInsert(Trigger.new);
    }
    if(trigger.isAfter && Trigger.isUpdate){
        otmh.onAfterUpdate(Trigger.Old,Trigger.OldMap,Trigger.new,Trigger.newMap);
    }
     if(trigger.isAfter && Trigger.isDelete){
         otmh.onAfterDelete(Trigger.OldMap);
    }
    /*
     * 18.11 Edge-15882 End
     * */
    
    if(trigger.isbefore && Trigger.isinsert){
         //Sprint 19.03 Edge-63675, SFO Team : Subani Shaik
        otmh.onBeforeInsert(Trigger.new);
    }

}