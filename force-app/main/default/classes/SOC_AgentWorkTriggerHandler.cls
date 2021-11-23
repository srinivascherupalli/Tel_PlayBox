public without sharing class SOC_AgentWorkTriggerHandler {
    
    
    @InvocableMethod
    public static void handleRequest(List<Id> workItemIds) {
        system.debug('InvocableMethod>>>>handleRequest');
        system.debug(workItemIds);
        if(workItemIds != null && workItemIds.size() > 0){
            if(String.valueOf(workItemIds[0].getSobjectType())=='Case'){
               resolveAccesses(workItemIds);
            }
        }
    }
    
    public static void resolveAccesses(List<Id> caseIdLIst){
        system.debug('>>> caseIdList... '+caseIdLIst);
        //system.debug('oldCaseMap=='+oldCaseMap);
        List<CaseTeamMember> caseMemberListToInsert = new List<CaseTeamMember>();
        List<OpportunityShare> oppshareListToInsert = new List<OpportunityShare>();
        List<Case> caseListToUpdate = new List<Case>();
        Set<Id> setParentCaseIds = new Set<Id>();
        List<Id> ownerIdList = new List<Id>();
        Id roleId = [select Id from CaseTeamRole where Name = 'SOC Case View Access' limit 1].Id;
        String conciergeQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'SOC_Queue'].Id;
        String conciergeOffShoreQueueId =[select Id from Group where Type = 'Queue' AND DeveloperNAME = 'soc_SFD_Concierge_Offshore'].Id;
        
        try{
            List<Case> caseList=[select id,ownerId,RecordType.Name , Stage__c, RecordType.DeveloperName ,OpportunityId__c,OpportunityId__r.OwnerId,soc_Support_Request__c from  Case where Id IN : caseIdLIst];
            for(Case cs : caseList){
               
                if(cs.RecordType.DeveloperName == 'soc_Support_Request' || cs.RecordType.DeveloperName == 'soc_Support_Request_without_SOC'){
                    cs.Status = 'In Progress';
                    caseListToUpdate.add(cs);
				}
                
                if(cs.RecordType.DeveloperName == 'soc_Support_Request'){
                    if(!setParentCaseIds.contains(cs.soc_Support_Request__c)) {
                     	setParentCaseIds.add(cs.soc_Support_Request__c);   
                    }                  
				}
                    ownerIdList.add(cs.OwnerId);
                    
                    if(cs.OwnerId != cs.OpportunityId__r.OwnerId){
                        OpportunityShare oppShareObj = new OpportunityShare(OpportunityId=cs.OpportunityId__c,UserOrGroupId =cs.OwnerId,OpportunityAccessLevel = 'Read');
                    	oppshareListToInsert.add(oppShareObj);
                    }
                
            }
            if(caseListToUpdate.size() > 0){
                update caseListToUpdate;
            }
            system.debug('>>> oppshareListToInsert.... '+oppshareListToInsert);
            if(oppshareListToInsert.size() > 0){
                insert oppshareListToInsert;
            }
            
            
            
            List<string> caseTeamUniqueList = new List<string>();
            for(CaseTeamMember csTeam : [select Id, ParentId, MemberId FROM CaseTeamMember 
                                         WHERE ParentId IN : caseIdList AND MemberId IN : ownerIdList]){
                string str = String.valueOf(csTeam.ParentId) + String.valueOf(csTeam.MemberId);
                caseTeamUniqueList.add(str);                          
            }
            
            List<String> caseTeamUniqueListOfParentCase = new List<String>();
            if(setParentCaseIds.size() > 0 && ownerIdList.size() > 0){
                System.debug('setParentCaseIds.size()----->'+setParentCaseIds.size());
                System.debug('ownerIdList.size()----->'+ownerIdList.size());
                for(CaseTeamMember csTeam : [select Id, ParentId, MemberId FROM CaseTeamMember 
                                             WHERE ParentId IN : setParentCaseIds AND MemberId IN : ownerIdList]){
                    
					string str = String.valueOf(csTeam.ParentId) + String.valueOf(csTeam.MemberId);
                    caseTeamUniqueListOfParentCase.add(str);   
                    
                }
            }
            
            for(Case cs : caseList){
                string str = (cs.Id != null && cs.OwnerId != null) ? String.valueOf(cs.Id) + String.valueOf(cs.OwnerId) : '';
                string str1 = (cs.soc_Support_Request__c != null && cs.OwnerId!= null) ? String.valueOf(cs.soc_Support_Request__c) + String.valueOf(cs.OwnerId) : '';
                
                if(!String.isEmpty(str) && !caseTeamUniqueList.contains(str)){
                    CaseTeamMember newMember=new CaseTeamMember(ParentId = cs.Id, MemberId = cs.OwnerId, TeamRoleId = roleId);
                    caseMemberListToInsert.add(newMember);
                }
                
                if(!String.isEmpty(str1) && !caseTeamUniqueListOfParentCase.contains(str1)){
                	CaseTeamMember newMember=new CaseTeamMember(ParentId = cs.soc_Support_Request__c, MemberId = cs.OwnerId, TeamRoleId = roleId);
                    caseMemberListToInsert.add(newMember);
                }
                
            }
            system.debug('caseMemberListToInsert=='+caseMemberListToInsert);
            insert caseMemberListToInsert;
            
        }catch(Exception e){
            System.debug(e);
                       
        }
    }
}