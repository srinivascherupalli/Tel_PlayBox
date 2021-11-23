/*****************************************************************************
@Name: OpportunityTeamTriggerHandler
@Author: SFO Team : Murali Nunna , Shaik Subani 
@CreateDate: 09/08/2018
@Description: This Class has logic for Sending the info to sharepoint when OpportunityTeamMember recoed is create/Edit/Remove via Event Object,based on 
              user permissions And To Check Oppo Team Member is in Offshore group for Offshore Accounts and restrict.
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
*******************************************************************************/
public without sharing class OpportunityTeamTriggerHandler {
    OpportunityTeamTriggerHelper oppTeamTriHelper=new OpportunityTeamTriggerHelper();
    
    //Sprint 20.01 Checking Opportunity Team Role for Telstra Purple Opportunities. 
    OpportunityTeamRoleTelstraPurple oppTeamRoleTelPurple = new OpportunityTeamRoleTelstraPurple();
    
    public void onBeforeInsert(List<OpportunityTeamMember> newOppTeams){
        //Sprint 19.03 Edge-63675, SFO Team : Subani Shaik
    	oppTeamTriHelper.offShoreRestrictedRolAndAccountCheck(newOppTeams);
    }
       
    public void onAfterInsert(List<OpportunityTeamMember> newOppTeams){
    	oppTeamTriHelper.createSPEventOnOppTeamMemCreation(newOppTeams);
    	oppTeamRoleTelPurple.updateOppOnTeamMemInsertPurpleRole(newOppTeams); //SFO Sprint 20.01, P2OB-3264
    }
    
    public void onAfterUpdate(List<OpportunityTeamMember> oldOppTeams,Map<Id,OpportunityTeamMember> oldMapOppTeams,List<OpportunityTeamMember> newOppTeams,Map<Id,OpportunityTeamMember> newMapOppTeams){
    	oppTeamTriHelper.createSPEventOnOppTeamMemUpdate(newOppTeams,oldMapOppTeams);
    	oppTeamRoleTelPurple.updateOppOnTeamMemUpdatePurpleRole(oldOppTeams, oldMapOppTeams, newOppTeams, newMapOppTeams);//SFO Sprint 20.01, P2OB-3264
    }
    
    public void onAfterDelete(Map<Id,OpportunityTeamMember> oldMapOppTeams){
    	oppTeamTriHelper.createSPEventOnOppTeamMemRemove(oldMapOppTeams);
    	oppTeamRoleTelPurple.updateOppOnTeamMemDeletePurpleRole(oldMapOppTeams);//SFO Sprint 20.01, P2OB-3264
    }

}