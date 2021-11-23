public class C2O_OpportunityTeamRoleTriggerHelper {
	/* 	Method Description	: Method on TeamMember Update, invoked after Update 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppIdSet (Purple to non-purple), 
        					  oppIdSet1 (non-purple to purple),
        					  finalOppUpdate (final map),
        Output Result		: Calls updateOppIndividualTelstra Method to update Purple individual value
	*/
    
    public static void oppIdCheck(set<Id> oppIdSet, set<Id> oppIdSet1, map<Id,String> finalOppUpdate){
        try{
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
        } catch(Exception Ex){
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage());
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }
    }
    
    
    /* 	Method Description	: Method To Update Purple Individual Checkbox On Opportunity Record To False 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppIdSet1 (Set of Opportunity Id's),
        Output Result		: Returns if Opportunity Team member has any purple individual checked.  
	*/
    
    public static map<Id,String> oppTelstraIndividualCheck(set<Id> oppIdSet1){
        try{
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
        } catch(Exception Ex){
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage());
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
            return null;
        }        
    }
    
    /* 	Method Description	: Method To Update Purple Individual Checkbox On Opportunity Record. This Method will Update Purple Individual to True/False. 
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oppIdMap(Opportunity Id Map)
        Output Result		: Updates Purple Individual to True/False
	*/
    public static void updateOppIndividualTelstra(map<Id,String> oppIdMap){
        try{
            list<Opportunity> oppLst = new list<Opportunity>(); 
            list<Opportunity> oppToUpdate = new list<Opportunity>();
            if(oppIdMap!=null &&!oppIdMap.isEmpty()){ 
                oppLst =  [SELECT Id FROM Opportunity WHERE Id IN: oppIdMap.keySet()]; 
            }
            
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
                
                if(!oppToUpdate.isEmpty()){
                    update oppToUpdate;
                }
            }
            
        } catch (DmlException ex) {
            system.debug('DmlException:::: OpportunityTeamRoleTelstraPurple :::: updateOppIndividualTelstra Method'+ Ex.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage());
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }
    }
    
    /* 	Method Description	: Method on TeamMember delete, invoked after delete
        Sprint Details		: Sprint-20.01,EDGE-3264
        Input Param   		: oldMapOppTeams (Old Opp Team Member record Map),
        Output Result		: call updateOppIndividualTelstra to Update purple individual
	*/
    
    public static void updateOppOnTeamMemDeletePurpleRole(set<Id> oppIdPurple){
        try{
            map<Id,String> finalOppUpdate = new map<Id,String>();
            if(!oppIdPurple.isEmpty()){
                finalOppUpdate = oppTelstraIndividualCheck(oppIdPurple); 		        
            }
            if(!finalOppUpdate.isEmpty()){
                updateOppIndividualTelstra(finalOppUpdate);
            }
        }catch(Exception Ex){
            system.debug('Exception:::: OpportunityTeamRoleTelstraPurple :::: updateOppOnTeamMemDeletePurpleRole Method'+ Ex.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', Ex.getMessage());
            inputLogMap.put('LoggingLevel.INFO', Ex.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }
    }
}