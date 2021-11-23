/********************************************************************************************
@Class Name                 :   OpportunityTeamRoleTelstraPurple
@Description                :   Sprint-20.01,P2OB-3264
@Date                       :   09th Jan, 2020
@Author                     :   Team SFO(Amar Chakka,Sravanthi Velagapudi)
@Version                    :   1.0
@Comments                   :   This Class updates Purple individual value on opportunity to either True Or False
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 updating API version to 50.
*********************************************************************************************/
public with sharing class OpportunityTeamRoleTelstraPurple {
    
    /* 	Method Description	: Method on TeamMember Insert, invoked after Insert from OpportunityTeamTriggerHandler. 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppTeamMemNew(List of newly inserted opportunity team members)
        Output Result		: Calls updateOppIndividualTelstra Method to update Purple individual value
    */
    public void updateOppOnTeamMemInsertPurpleRole(list<OpportunityTeamMember> oppTeamMemNew){
        try{
            map<Id,String> finalOppUpdate = new map<Id,String>();
            for(OpportunityTeamMember oppTeamMem : oppTeamMemNew){
                if(oppTeamMem.TeamMemberRole == Label.Telstra_Purple && !finalOppUpdate.containsKey(oppTeamMem.OpportunityId)){
                    finalOppUpdate.put(oppTeamMem.OpportunityId,Label.Telstra_Purple);
                }
            }
            if(!finalOppUpdate.isEmpty()){
                updateOppIndividualTelstra(finalOppUpdate);
            }
        }
        catch(Exception Ex){
            system.debug('Exception:::: OpportunityTeamRoleTelstraPurple :::: updateOppOnTeamMemInsertPurpleRole Method'+ Ex.getMessage());
        }
    }
    
    /* 	Method Description	: Method To Update Purple Individual Checkbox On Opportunity Record. This Method will Update Purple Individual to True/False. 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppIdMap(Opportunity Id Map)
        Output Result		: Updates Purple Individual to True/False
	*/
    public void updateOppIndividualTelstra(map<Id,String> oppIdMap){
        list<Opportunity> oppLst = new list<Opportunity>(); 
        list<Opportunity> oppToUpdate = new list<Opportunity>();
        oppLst =  [SELECT Id FROM Opportunity WHERE Id IN: oppIdMap.keySet()]; 
        if(!oppLst.isEmpty()){
            for(Opportunity purpleOpp : oppLst){
                if(oppIdMap.get(purpleOpp.id) == Label.Telstra_Purple){
                    purpleOpp.Purple_individual__c = True;
                }
                else if(oppIdMap.get(purpleOpp.id) == Label.nonTelstraPurple){
                    purpleOpp.Purple_individual__c = False;
                }     
                oppToUpdate.add(purpleOpp);
            } 
            try{
                if(!oppToUpdate.isEmpty()){
                    update oppToUpdate;
                }
            }
            catch (DmlException ex) {
                system.debug('DmlException:::: OpportunityTeamRoleTelstraPurple :::: updateOppIndividualTelstra Method'+ Ex.getMessage());
                
            }
        }
    }
    
    /* 	Method Description	: Method on TeamMember Update, invoked after Update 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppTeamMemNew (OldOpportunityTeamMember), 
                              oldMapOppTeams (OldOpportunityTeamMemberMap),
                              newOppTeams (NewOpportunityTeamMember),
                              newMapOppTeams (NewOpportunityTeamMemberMap)
        Output Result		: Calls updateOppIndividualTelstra Method to update Purple individual value
	*/
    public void updateOppOnTeamMemUpdatePurpleRole(list<OpportunityTeamMember> oppTeamMemNew, Map<Id,OpportunityTeamMember> oldMapOppTeams,List<OpportunityTeamMember> newOppTeams,Map<Id,OpportunityTeamMember> newMapOppTeams){
        try{
            set<Id> oppIdSet = new set<Id>();//Old team role is not purple and new team role is purple
            set<Id> oppIdSet1 = new set<Id>();//Old team role is  purple and new team role is not purple
            map<Id,String> finalOppUpdate = new map<Id,String>();
            
            for(OpportunityTeamMember oppTeamMem : newOppTeams){
                String oldTeamRole=oldMapOppTeams.get(oppTeamMem.Id).TeamMemberRole;
                if(oppTeamMem.TeamMemberRole != oldTeamRole){
                    if(oldTeamRole != Label.Telstra_Purple && oppTeamMem.TeamMemberRole == Label.Telstra_Purple){
                        oppIdSet.add(oppTeamMem.OpportunityId);
                        finalOppUpdate.put(oppTeamMem.OpportunityId,Label.Telstra_Purple);
                    }
                    
                    else if(oldTeamRole == Label.Telstra_Purple && oppTeamMem.TeamMemberRole != Label.Telstra_Purple){ 
                        oppIdSet1.add(oppTeamMem.OpportunityId);
                    }
                }
                
            }
            oppIdCheck(oppIdSet, oppIdSet1, finalOppUpdate);
            
        }catch(Exception Ex){
            system.debug('Exception:::: OpportunityTeamRoleTelstraPurple :::: updateOppOnTeamMemUpdatePurpleRole Method'+ Ex.getMessage());
        }
    }
    
    /* 	Method Description	: Method on TeamMember Update, invoked after Update 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppIdSet (Purple to non-purple), 
        					  oppIdSet1 (non-purple to purple),
        					  finalOppUpdate (final map),
        Output Result		: Calls updateOppIndividualTelstra Method to update Purple individual value
	*/
    
    public void oppIdCheck(set<Id> oppIdSet, set<Id> oppIdSet1, map<Id,String> finalOppUpdate){
        if(!oppIdSet1.isEmpty() ){
            for(id oppid :oppIdSet1){
                if(!oppIdSet.isEmpty() && oppIdSet.contains(oppid)){
                    oppIdSet1.remove(oppid);
                }
            }
            finalOppUpdate.putAll(oppTelstraIndividualCheck(oppIdSet1));
        }
        if(!finalOppUpdate.isempty()){
            updateOppIndividualTelstra(finalOppUpdate);
        }
    }
    
    /* 	Method Description	: Method To Update Purple Individual Checkbox On Opportunity Record To False 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppIdSet1 (Set of Opportunity Id's),
        Output Result		: Returns if Opportunity Team member has any purple individual checked.  
	*/
    
    public map<Id,String> oppTelstraIndividualCheck(set<Id> oppIdSet1){
    
        map<Id, OpportunityTeamMember> oppTeamMemMap = new map<Id, OpportunityTeamMember>();
        map<Id,String> nonTelstraPurpleOppList = new map<Id,String>();

        for(OpportunityTeamMember oppTeamMem : [SELECT Id, TeamMemberRole, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN: oppIdSet1 AND TeamMemberRole =: Label.Telstra_Purple]){
            oppTeamMemMap.put(oppTeamMem.OpportunityId, oppTeamMem);
        }
        
        for(id oppId : oppIdSet1){
            if(!oppTeamMemMap.containsKey(oppId)){ 
                nonTelstraPurpleOppList.put(oppId ,Label.nonTelstraPurple);
            }
        }
        return nonTelstraPurpleOppList;
    }
    
    /* 	Method Description	: Method on TeamMember delete, invoked after delete
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oldMapOppTeams (Old Opp Team Member record Map),
        Output Result		: call updateOppIndividualTelstra to Update purple individual
	*/
    
    public void updateOppOnTeamMemDeletePurpleRole(Map<Id,OpportunityTeamMember> oldMapOppTeams){
        try{
            map<Id,String> finalOppUpdate = new map<Id,String>();
            set<Id> oppIdPurple = new set<Id>();
            
            for(OpportunityTeamMember oppTemMem : oldMapOppTeams.values()){
                if(oppTemMem.TeamMemberRole == Label.Telstra_Purple){
                    oppIdPurple.add(oppTemMem.OpportunityId);
                }
            }
            if(!oppIdPurple.isEmpty()){
                finalOppUpdate=oppTelstraIndividualCheck(oppIdPurple); 		        
            }
            if(!finalOppUpdate.isEmpty()){
                updateOppIndividualTelstra(finalOppUpdate);
            }
        }catch(Exception Ex){
            system.debug('Exception:::: OpportunityTeamRoleTelstraPurple :::: updateOppOnTeamMemDeletePurpleRole Method'+ Ex.getMessage());
        }
    }
    
    
}