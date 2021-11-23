/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   18/02/2020
Jira Number         :   P2OB-4164
Desc                :   This is controller for lightning component 'OpportunityTeamMemberComponent'.It contains logic for displaying
opportunity team member and creation of new team member.
modified date       :   1/02/2021,24/06/2021                              
modified by         :   Sravanthi (Team SFO) P2OB-11378 Sprint : 21.02 , Srikanth (Team SFO) P2OB-13741 Sprint 21.09                                
***********************************************************************/
public without sharing class AddOpptyTeamController {
    
    /**
    * Param         : OpptyId - Id of Opportunity associated with team member 
    * Return        : List<OpportunityTeamMember> - List of existing team member associated with opportunity
    * Description   : This method returns all team member associated with opportunity
    */
    @auraEnabled
    public static List<OpportunityTeamMember> displayTeam(String OpptyID) {
        List<OpportunityTeamMember> listOfUsers = new List<OpportunityTeamMember>();
        if(String.isNotBlank(OpptyID)){
            listOfUsers = [select id,UserId,User.Name, OpportunityAccessLevel,OpportunityId,TeamMemberRole from OpportunityTeamMember where OpportunityId = :OpptyID];
        }
        return listOfUsers;
    }
    
    /**
    * Param         : OpptyId - Id of Opportunity associated with team member
    userId_selected - Id of User
    * Return        : Boolean
    * Description   : This method check if user selected for adding into team member is in offshore public group if
    account is offshore restricted
    */
    @AuraEnabled 
    public static boolean checkUserValidation(String OpptyID,String userId_selected){
        Set<Id> roleids = new set<id>();
        if(String.isNotBlank(OpptyID)){
            Opportunity opp = [Select id,Account.APTPS_Off_Shore_Restricted__c from Opportunity where id =:OpptyID limit 1];
            User userRole = [SELECT Id,UserRoleId from user where id =:userId_selected limit 1];
            //Check if account is offshore_restricted
            if(opp!=null && opp.Account!=null && opp.Account.APTPS_Off_Shore_Restricted__c){
                roleids=GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName);
                if(roleids!=null && roleids.size()>0){
                    system.debug('GroupMembership.groupUserId'+GroupMembership.groupUserId);
                    system.debug('GroupMembership.groupUserId'+userId_selected);
                    if(roleids.contains(userRole.UserRoleId)||(GroupMembership.groupUserId!=null && GroupMembership.groupUserId.contains(Id.valueOf(userId_selected))))
                    {	
                        System.debug('role check');
                        //Disable save button and show error
                        return true;
                    }
                    else{
                        //Enable Save button and do not show error
                        System.debug('role not found');
                        return false;
                    }                    	               
                }
            }  
        }
        //Enable Save button and do nt show error
        return false;
    }
    
    /**
    * Param         : OpptyId - Id of Opportunity associated with team member
    LoggedinUserId - Id of logged in User
    * Return        : String - Error Message
    * Description   : This method returns error msg if user trying to add team member is either not the owner of account or in account team 
    associated with opportunity		
    * Modified      : Sravanthi (Team SFO) P2OB-11378 Sprint : 21.02 To display the component for internal opportunity owners
    */
    @AuraEnabled
    public static String checkCondition(String OpptyID,String LoggedinUserId) {
        String msg = '';
        if(String.isNotBlank(OpptyID) && String.isNotBlank(LoggedinUserId)){
            List<Opportunity> oppDetails = [Select id,OwnerId,Owner.Name,AccountId,Account.OwnerId from Opportunity where Id =:OpptyID];
            Set<Id> ownerId = new Set<Id>();
            Set<Id> userId = new Set<Id>();
            Set<Id> accountId = new Set<Id>();
            if(oppDetails.size() > 0 && oppDetails != Null){
                for(Opportunity opp: oppDetails){
                    ownerId.add(opp.OwnerId);
                    userId.add(opp.Account.OwnerId);
                    if(opp.AccountId != Null){
                        accountId.add(opp.AccountId);
                    }
                }
            }
            
            List<User> UserDetails;
            if(ownerId.size() > 0){
                UserDetails = new List<User>([Select id,ContactId,UserType from User where Id IN: ownerId]);
            }
            
            List<AccountTeamMember> accTeamMember;
            if(accountId.size() > 0){
                accTeamMember = new List<AccountTeamMember>([Select id,UserId,AccountId from AccountTeamMember where AccountId IN:accountId]);
            }
            
            if(accTeamMember != Null && accTeamMember.Size() > 0){
                for(AccountTeamMember accTeamMem : accTeamMember){
                    userId.add(accTeamMem.UserId);
                }
            }
            
            if(UserDetails != Null && UserDetails.size() > 0){
                for(User use : UserDetails){
                    //P2OB-11378 STARTS -- Sets Error Message as long the logged in internal user is not Opportunity owner
                    if(use.ContactId == Null && String.valueOf(use.Id) != LoggedinUserId){
                        String errormessage = 'Not an Owner'; //'Only the opportunity owner can make changes to the opportunity team. Please contact '+oppDetails[0].Owner.Name+' to make any changes needed';
                        msg = errormessage; 
                    }
                    //P2OB-11378 ENDS 
                    else if(use.ContactId != Null && userId.size() > 0 && !userId.contains(LoggedinUserId.substring(0, 15))){
                        msg = Label.PRM_Opportunity_Team_Member_Insufficient_Access;
                    }
                }
            }
        }
        return msg;
    }
    
    /**
    * Param         : OppTeamId - Id of existing team member record
    OppId - Id of Opportunity associated with team member
    * Return        : List<OpportunityTeamMember> 
    * Description   : This method delete team member record when user click on delete icon				  
    */
    @AuraEnabled
    public static List<OpportunityTeamMember> deleteTeamMember(String OppTeamId,String OppId)
    {
        OpportunityTeamMember delTeamMember=[Select Id from OpportunityTeamMember where id=:OppTeamId];
        delete delTeamMember;
        return displayTeam(OppId);
    }
    
    /**
    * Param         : teamMemberList - Team member record that needs to create
    updateMemberList - Existing team member record that needs to update
    * Return        : void
    * Description   : This method update existing team member record if user has changed team member role or access level and create
    New record if user want to create.			  
    */
    @AuraEnabled
    public static void saveTeamMember(List<OpportunityTeamMember> teamMemberList,List<OpportunityTeamMember> updateMemberList){
        List<OpportunityTeamMember> teamMemberListToUpsert = new List<OpportunityTeamMember>();
        if(teamMemberList != Null && teamMemberList.size() > 0){
            teamMemberListToUpsert.addAll(teamMemberList);
        }
        if(updateMemberList != Null && updateMemberList.size() > 0){
            teamMemberListToUpsert.addAll(updateMemberList);
        }

        if(teamMemberListToUpsert.size() > 0){
            upsert teamMemberListToUpsert;
        }
    }
    
    /**
    * Param         : objObject - Object Api Name
    fld - Picklist field Api Name associated with object
    * Return        : List<String>
    * Description   : This method returns all picklist values associated with field		  
    */
    @AuraEnabled
    public static List<String> getselectOptions(sObject objObject, string fld) {
        
        List<String> allOpts = new list<String> ();
        
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        List <Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        
        allOpts.sort();
        return allOpts;
    }
    /**
    * Param         : OpptyId - Id of Opportunity associated with team member
                        userId - Id of logged in User 
    * Return        : TeamList -- inner class contacins both list of existing opp team and user default team
    * Description   : This method returns all existing opp team and user default team for provided opp & user
    * JIRA          : P2OB-11748 ,P2OB-11378 TEAM SFO
    */
    @AuraEnabled
    public static TeamList getUserDefaultTeam(Id userId ,Id OppId){
        TeamList response =new TeamList();
        
        if(userId != null){
            response.userTeamMemberList =[SELECT UserId,User.Name, TeamMemberRole, OpportunityAccessLevel, Id FROM UserTeamMember WHERE OwnerId =: userId];
            
        }
        if(oppId != null){
            response.oppTeamMemberList =[SELECT UserId,User.Name, TeamMemberRole, OpportunityAccessLevel, Id FROM OpportunityTeamMember WHERE OpportunityId =: oppId];
        }
        
        return response;
    }
    /**
    * Param         : userId - Id of logged in User , accId -- account Id of opp , oppId
    * Return        : TeamList -- userType -- logged in user type, accTeamMemberList --account team members , oppTeamMemberList -- existing opp team list
    * Description   : This method returns logged in user type , returns account team members for the provided opp ID
    * JIRA          : P2OB-11748 ,P2OB-11378 TEAM SFO , P2OB-12585 TEAM SFO
    */
    @AuraEnabled
    public static TeamList getAccDataUserType(Id userId , Id accId , Id oppId){
        TeamList response =new TeamList();
        if(userId != null){
            response.userType = [SELECT UserType FROM User WHERE Id = : userId LIMIT 1].UserType;
        }
        if(accId != null){
            response.accTeamMemberList =[SELECT Id, TeamMemberRole,OpportunityAccessLevel, UserId,User.Name,User.IsActive FROM AccountTeamMember WHERE AccountId =: accId];
        }
        if(oppId != null){
            response.oppTeamMemberList=displayTeam(oppId);
        }
        return response;
    }
    /**
    * Param         : userId - Id of logged in User 
    * Return        : string -- logged in user type
    * Description   : This method deletes provided opp team members.
    * JIRA          : P2OB-12585 TEAM SFO
    */
    @AuraEnabled
    public static void deleteAllTeamMember(List<Id> OppTeamIdList)
    {
        
        if(OppTeamIdList != null && OppTeamIdList.size() > 0){
            List<OpportunityTeamMember> delTeamMemberlist = [Select Id from OpportunityTeamMember where id IN :OppTeamIdList];
            delete delTeamMemberlist;
        }
    }
    /**
     * class Name : TeamList
     * To Store response values for UserTeamMember & OpportunityTeamMember
     * JIRA       : P2OB-11748 ,P2OB-11378 P2OB-12585 TEAM SFO
     */
    public class TeamList {
        @AuraEnabled
        public List<OpportunityTeamMember>  oppTeamMemberList {get;set;}
        @AuraEnabled
        public List<UserTeamMember>  userTeamMemberList {get;set;}
        @AuraEnabled
        public List<AccountTeamMember>  accTeamMemberList {get;set;}
        @AuraEnabled
        public String  userType {get;set;}
        public TeamList(){
            oppTeamMemberList = new List<OpportunityTeamMember>();
            userTeamMemberList = new List<UserTeamMember>();
            accTeamMemberList = new List<AccountTeamMember>();
        }
    }
    

    /*
    @Method Name: removeMeFromOppTeam
    @Description: P2OB-13741, Sprint 21.09
				  To remove current user as a OpportunityTeamMember/AccountTeamMember
    @Author		: Sri, Srav (Team SFO)
    */
    @AuraEnabled
    public static String removeMeFromOppTeam(String opportunityId,String accTeamMemberId ) {

        String result = '';
        AddMeToOpportunityTeam.flowInputs flowIP = new AddMeToOpportunityTeam.flowInputs();
        flowIP.methodExecution = 'OppTeamMemberRemoval';
        flowIP.oppId = opportunityId;
        flowIP.userId = UserInfo.getUserId();
        if(accTeamMemberId <> ''){
            flowIP.accTeamMemberToDeleteYes = 'Yes';
            flowIP.accTeamMemberID = accTeamMemberId;
            
        }

        List<AddMeToOpportunityTeam.flowInputs> flowIPs = new List<AddMeToOpportunityTeam.flowInputs>();
        flowIPs.add(flowIP);

        AddMeToOpportunityTeam.invokeFromAddToTeamMember(flowIPs);

        return result;

    }

    /*
    @Method Name: updateOppTeam
    @Description: P2OB-13741, Sprint 21.09
				  To add user as a OpportunityTeamMember
    @Author		: Sri, Srav (Team SFO)
    */
    @AuraEnabled
    public static String updateOppTeam(String opportunityId,String selectedRole) {
        String result = 'updateOppTeam';
        AddMeToOpportunityTeam.flowInputs flowIP = new AddMeToOpportunityTeam.flowInputs();
        try{
            flowIP.methodExecution = 'oppTeamMemberCreate';
            flowIP.oppId = opportunityId;
            flowIP.userId = UserInfo.getUserId();
            flowIP.teamMemberRole = getRoleApiName(selectedRole);
            flowIP.oppAccessLevel = checkUserHasEditAccess(opportunityId);
    
            List<AddMeToOpportunityTeam.flowInputs> flowIPs = new List<AddMeToOpportunityTeam.flowInputs>();
            flowIPs.add(flowIP);
    
            AddMeToOpportunityTeam.invokeFromAddToTeamMember(flowIPs);
        }
        catch(Exception ex){
            system.debug('Exception:::: AddOpptyTeamController :::: updateOppTeam Method'+ ex.getMessage());
            return result;
        }

        return result;

    }

    /*
    @Method Name: checkUserHasEditAccess
    @Description: P2OB-13741, Sprint 21.09
				  To check whether user HasEditAccess or not in given record
    @Author		: Sri, Srav (Team SFO)
    */
    public static Boolean checkUserHasEditAccess(String opportunityId){
        Boolean hasEditAccess = false;
        try {
            hasEditAccess = [select RecordId,HasEditAccess from UserRecordAccess where RecordId =:opportunityId and UserId =:UserInfo.getUserId() limit 1 ].HasEditAccess;
                
        } catch (Exception ex) {
            system.debug('Exception:::: AddOpptyTeamController :::: checkUserHasEditAccess Method'+ ex.getMessage());
            return hasEditAccess;
        }
        return hasEditAccess;
    }

    /*
    @Method Name: getRoleApiName
    @Description: P2OB-13741, Sprint 21.09
				  To get OpportunityTeamMember's TeamMemberRole picklistvalue api name for the given picklistvalue
    @Author		: Sri, Srav (Team SFO)
    */
    public static String getRoleApiName(String roleLabel){
        String roleName;
        Schema.DescribeFieldResult descResult = OpportunityTeamMember.TeamMemberRole.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = descResult.getPicklistValues();
        for(Schema.PicklistEntry pe:picklistEntries){
            if(pe.getLabel() == roleLabel){
                roleName = pe.getValue();
            }
        }
        
        return roleName;
    }
}