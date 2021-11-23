/*****************************************************************************
@Author: Nitesh
@CreateDate: 23/08/2018
@ModifiedByandDate: 
@Description: This Class is SOC Utility for finding duplicate CaseTeamMember record
*******************************************************************************/
public with sharing class soc_Utility {
    
   public static  CaseTeamRole role = [select Id from CaseTeamRole where Name = 'SOC Case View Access' limit 1];

    public static CaseTeamMember addCaseMember(String caseId , String ownerId){
        
        if([select count() from CaseTeamMember where ParentId=:caseId And MemberId=:ownerId]==0){
        	CaseTeamMember newMember=new CaseTeamMember(ParentId = caseId, MemberId = ownerId, TeamRoleId = role.Id);
            return newMember;
        }       
        return null;
        
     }
    
}