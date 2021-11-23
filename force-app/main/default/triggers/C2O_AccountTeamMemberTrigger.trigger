/********************************************************************************
* Class Name  : C2O_AccountTeamMemberTrigger
* Description : C2O_AccountTeamMemberTrigger executes logic on Account Team Member on before insert/update,after insert/update.   
* Created By  : Sri (Team SFO)

********************************************************************************/
trigger C2O_AccountTeamMemberTrigger on AccountTeamMember (before insert, before update,after insert, after update) {
    new C2O_AccountTeamMemberTriggerHandler().run(); 

}