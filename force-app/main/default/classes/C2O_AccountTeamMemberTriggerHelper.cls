/********************************************************************************
* Class Name    :   C2O_AccountTeamMemberTriggerHelper
* Description   :   DIGI-12760, Sprint 21.12
                    C2O_AccountTeamMemberTriggerHelper runs logic on AccountTeamMember records which are filtered
                    based on certain filter conditions which are defined in handler
* Test class    :   C2O_AccountTeamMemberTriggerTest
* Created By    :   Sri (Team SFO)   
* Last modified :   DIGI-22590 :: Sprint 21.13
********************************************************************************/
public class C2O_AccountTeamMemberTriggerHelper {
    /***************************************************************************************
* Method Name - checkOpportunityApproverTeamMember
* Description - DIGI-12760, Sprint 21.12
This method is being called from beforeInsert & beforeUpdate 
to validate whether the 
****************************************************************************************/
    public static void checkOpportunityApproverTeamMember(List<AccountTeamMember> newAccTeamMemList){
        String role = Label.ClosureApproverAccountTeamMemRole;
        set<Id> setAccountIds = new set<Id>(); //contains list of accountid's which are from the newaccountteammembers list with role 'Opportunity Approver'
        set<Id> setExisitingAccountIds = new set<Id>(); // contains accountid's which are already having Opportunity Approver role member and which are in setAccountIds too
        //set<Id> setExisitingAccTeamMemIds = new set<Id>(); // contains AccountTeamMember id's which are already having Opportunity Approver role member and which are in setAccountIds too
        map<Id,Id> mapActIdATMId = new map<Id,Id>();

        for(AccountTeamMember atm:newAccTeamMemList){ // loop start
            if(atm.TeamMemberRole == role && !setAccountIds.contains(atm.AccountId) ){
                setAccountIds.add(atm.AccountId);
            }else if(atm.TeamMemberRole == role && setAccountIds.contains(atm.AccountId) ) {
                //this is to verify in the providing list has multiple members with the role Opportunity Approver for the same account
                atm.addError('Opportunity Approver already exists for this account. Please speak with the Account Manager to review the Account Team Roles');
            }
        } // loop end
        
        //query the existing team members for the accounts which are from the newaccountteammembers list with role 'Opportunity Approver'
        if(!setAccountIds.isEmpty()){
            for(AccountTeamMember atmemb:SFO_TeamMemberUtil.getAccountTeamMembers(setAccountIds,role)){ // loop start
                setExisitingAccountIds.add(atmemb.AccountId);
                mapActIdATMId.put(atmemb.AccountId, atmemb.Id);
                //setExisitingAccTeamMemIds.add(atmemb.Id);
            } // loop end
        }
        
        for(AccountTeamMember atmem:newAccTeamMemList){ // loop start
            if(atmem.id == null && atmem.TeamMemberRole == role && setExisitingAccountIds.contains(atmem.AccountId)){
                atmem.addError('Opportunity Approver already exists for this account. Please speak with the Account Manager to review the Account Team Roles');
            }else if(atmem.id <> null && mapActIdATMId.containsKey(atmem.AccountId) && atmem.TeamMemberRole == role && atmem.id <> mapActIdATMId.get(atmem.AccountId)){
                atmem.addError('Opportunity Approver already exists for this account. Please speak with the Account Manager to review the Account Team Roles');
            }
        } // loop end
    }
}