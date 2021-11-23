/********************************************************************************
* Class Name    :   SFO_TeamMemberUtil
* Description   :   SFO_TeamMemberUtil contains methods which are used for get the respective TeamMember details
* Test class    :   SFO_TeamMemberUtilTest
* Created By    :   Sri (Team SFO)   
* Last modified :   DIGI-22590 :: Sprint 21.13

********************************************************************************/
public class SFO_TeamMemberUtil {
    /*
    @Method Name: getAccountTeamMembers
    @Description: DIGI-12760, Sprint 21.12
				  To get AccountTeamMembers for the given accounts with the given role 
    @Author		: Sri (Team SFO)
    */
    public static List<AccountTeamMember> getAccountTeamMembers(Set<Id> setAccountIds, String role){
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        if(setAccountIds.isEmpty()){
            return atms; //if setAccountIds is empty simpley return empty list no need of running query
        }
        if(role <> null && role <> '' ){
            //if role is not empty filter based on the given role
	        atms = [select id, userId, user.name, TeamMemberRole, AccountId from AccountTeamMember where AccountId =:setAccountIds and TeamMemberRole =:role];
        }else{
            //if role is empty return only account related team members
	        atms = [select id, userId, user.name, TeamMemberRole, AccountId from AccountTeamMember where AccountId =:setAccountIds];
        }
        return atms;
    }

}