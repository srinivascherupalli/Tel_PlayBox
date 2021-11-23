/********************************************************************************
* Class Name  : C2O_OpportunityTeamMemberTrigger
* Description : C2O_OpportunityTeamMemberTrigger executes logic on Opportunity Team Member on before insert,after insert/update,after delete.   
* Created By  : Uday Dunna 
* Change Log  : Created
********************************************************************************/
trigger C2O_OpportunityTeamMemberTrigger on OpportunityTeamMember(before insert,after insert, after update,after delete) {
    new C2O_OpportunityTeamMemberTriggerHandler().run(); 
}