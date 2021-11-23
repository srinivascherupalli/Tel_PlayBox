/*****************************************************************************
@Author: Nilima Borse
@CreateDate: 21-Feb-2020
@ModifiedByandDate: 
@Description:  This class contains logic to change the access to Read only when Case
assigned from Queue to User through Omni Channel.
@References
Story:P2OB-4968
<Tech Story> Change Channel Care Case Team Member's access to Read only when Case
assigned from Queue to User through Omni Channel
*******************************************************************************/
public without sharing class Salesup_ChannelCareAgentWorkHandler {
     /**
    * This method will get called from Process builders - 1.salesup Assign Child requests to Parent
    * 2.salesup_Assign_certitude_to_onshore_offshore_queue.
    * Nilima B :: P2OB-4968 :: 21-Feb-2020
    * Karan J  :: P2OB-7352 :: 30-Jun-2020 :: added CPE record type in query for performing avction on CPE record also.

    * Sandeep Soni  :: P2OB-9532 :: 06-Nov-2020 :: added CBS record type, We have added CBS record type check also so whenever CBS case owner will change this apex will call and update case owner from read/write to readonly.

    */
    @InvocableMethod
    public static void handleChannelCareRequest(List<Id> workItemIds) {
        system.debug('InvocableMethod>>>>handleRequest');
        system.debug('workItemIds>>>>'+workItemIds);
        if(workItemIds != null && workItemIds.size() > 0){
            if(String.valueOf(workItemIds[0].getSobjectType())=='Case'){
               resolveAccesses(workItemIds);              
            }
        }
    }
    
    /**
    * Once the channel care case is assign to user through omni channel then after 2 hours the case team access will change
    * to Read only from Read/Write
    * Nilima B :: P2OB-4968 :: 21-Feb-2020
    * Karan J ::
    */
    public static void resolveAccesses(List<Id> caseIdLIst){
    

        Map<id,Case> caseIdMap = new Map<Id, Case>();    
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();
        List<CaseTeamMember> tmToUpdate = new List<CaseTeamMember>();

        
        for(Case caseRec : [Select  Id,OwnerId, RecordTypeId, RecordType.DeveloperName,Owner.Name From Case Where Id IN :caseIdLIst AND (RecordType.DeveloperName = 'salesup_Sales_Child_Support' OR RecordType.DeveloperName = 'CPE_Requests' OR RecordType.DeveloperName = 'CBS')]){
            caseIdMap.put(caseRec.Id, caseRec);
        }
        if(caseIdMap!= null){
        for(CaseTeamMember ctm : [Select TeamRoleId,ParentId,TeamRole.Name From CaseTeamMember Where ParentId IN : caseIdMap.keySet()]){
            if(caseIdMap!=null && caseIdMap.containsKey(ctm.ParentId) && ctm.ParentId != null && caseIdMap.get(ctm.ParentId).RecordType.DeveloperName=='CBS'){
                if(ctm.TeamRole.Name=='Sales Rep'){
                     caseTeamMemberList.add(ctm);
                }
            }else{
                caseTeamMemberList.add(ctm);
            }
        }
        system.debug('caseTeamMemberList='+caseTeamMemberList);
        
        List<CaseTeamRole> lstCaseTeamRole = [Select Id,Name From CaseTeamRole Where Name = 'SOC Case View Access' LIMIT 1];
        system.debug('lstCaseTeamRole='+lstCaseTeamRole);
        
        
        if(caseTeamMemberList.size() > 0){
            for(CaseTeamMember member : caseTeamMemberList){
              member.TeamRoleId = lstCaseTeamRole[0].Id;
                tmToUpdate.add(member);
            }            
        }
        system.debug('tmToUpdate='+tmToUpdate);        
        if(tmToUpdate.size() > 0)
            update tmToUpdate;   
    
    }    
        
    }    
}