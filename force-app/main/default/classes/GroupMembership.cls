/*****************************************************************************
@Name: GroupMembership 
@Author: SFO Team (Alok,Murali Nunna,Subani) (19.03 Edge-63675)
@Description: Retrieve all Roles and Internal Subordinate Roles Ids available in a public group

5 June 2020 - Karan jugtawat - P2OB-6365.
2 Sep  2021	- Sravanthi	- DIGI-8926
*******************************************************************************/

public without sharing class  GroupMembership { 
    public static Set<Id> groupUserId=null;
    public static Map<ID, UserRole> IdRoleMap = new Map<ID, UserRole>() ;
    /* Inputs : groupName
* return Set<Id>
* @Description: Return Set of role ids added in the group ,it's generic method any where we can use.
* */
    public static Set<Id> getRoleIdsFromGroup(String groupName){ 
        Set<Id> roleIds = new Set<Id>(); // Contains all roles and role subordinates associated with specified group
        Set<Id> groupMemberIds = new Set<Id>();
        if(groupName!=null && !String.isBlank(groupName) && !String.isEmpty(groupName)){
            // Retriveing all group member of EnterpriseoffShore Group
            for(GroupMember m : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember Where Group.DeveloperName =: groupName]) {
                groupMemberIds.add(m.UserOrGroupId);
                if(String.valueOf(m.UserOrGroupId).startsWith('005')){
                    groupUserId=new Set<Id>();
                    groupUserId.add(m.UserOrGroupId);
                }
            }        
            if(groupMemberIds != null && !groupMemberIds.isEmpty()){            
                Set<Id> subRoleIds = new Set<Id>();
                //Retriveing all group  of EnterpriseoffShore Group members(i.e groups)
                for(Group g : [SELECT Name, RelatedId, Type, Id From Group WHERE Id IN : groupMemberIds]){
                    if(g.Type == 'Role'){
                        roleIds.add(g.RelatedId);    
                    }else if(g.Type == 'RoleAndSubordinatesInternal'){
                        roleIds.add(g.RelatedId);
                        subRoleIds.add(g.RelatedId);
                    }
                }                
                if(subRoleIds != null && !subRoleIds.isEmpty()){
                    roleIds.addAll(getAllSubRoleIds(subRoleIds));    
                }                
            }
        }
        return roleIds;    
    }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {        
        Set<ID> currentRoleIds = new Set<ID>();
        if(roleIds!=null && roleIds.size()>0){
            for(UserRole userRole :[select Id from UserRole where ParentRoleId IN : roleIds AND ParentRoleID != null limit 40000]){
                currentRoleIds.add(userRole.Id);
            }
        }
        if(currentRoleIds.size()>0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }        
        return currentRoleIds;  
    }    
    
    /*	Sprint 19.03 , EDGE-63675
* Date : 28/02/2019
* @Description: This Method is to check whether Oppteam Member User is a part of Enterprise OffShore Public group 
*/    
    public void accountOffShoreCheckErrorMessage(List<opportunity> newOppsList,List<OpportunityTeamMember> newOppTeamMemList){
        try{
            Set<Id> oppsIdSet = new Set<Id>();
            Set<Id> userIds = new Set<id>();
            Map<Id,Id> oppTeamRoleMap = new Map<Id,Id>();
            if(newOppTeamMemList!=null && newOppTeamMemList.size()>0){
                for (OpportunityTeamMember oppTeam :newOppTeamMemList){
                    userIds.add(oppTeam.UserId);
                    oppsIdSet.add(oppTeam.OpportunityId);
                }
            }
            if(newOppsList!=null && newOppsList.size()>0){
                for (Opportunity opp : newOppsList) {
                    userIds.add(opp.ownerid);
                    oppsIdSet.add(opp.id);                
                }
            }
            if(userids.size()>0){            
                for (user u : [Select Id,UserRoleId from user Where Id IN :userIds]) {
                    oppTeamRoleMap.put(u.Id,u.UserRoleId);     
                }
            }   
            if(oppsIdSet!= null && !oppsIdSet.isEmpty() && oppsIdSet.size()>0){
                List<Opportunity> listOpprtunities=[Select Id,Opportunity.Account.APTPS_Off_Shore_Restricted__c from opportunity Where Id IN : oppsIdSet and Opportunity.Account.APTPS_Off_Shore_Restricted__c =True];           
                if(listOpprtunities!= null && !listOpprtunities.isEmpty() && listOpprtunities.size()>0){        		             
                    Set<Id> roleids=GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName);
                    if(roleids!=null && roleids.size()>0){
                        if(newOppTeamMemList!=null && newOppTeamMemList.size()>0){
                            for(OpportunityTeamMember oppTeamMem :newOppTeamMemList){
                                if(roleids.contains(oppTeamRoleMap.get(oppTeamMem.userid)) || (groupUserId!=null && groupUserId.contains(oppTeamMem.userid))){
                                    oppTeamMem.AddError(System.Label.OffshoreRestrictedRoleErrorOppTeamInsert);
                                }
                            }
                        }                    
                        if(newOppsList!=null && newOppsList.size()>0){
                            for(Opportunity opp : newOppsList){
                                if(roleids.contains(oppTeamRoleMap.get(opp.ownerid))|| (groupUserId!=null && groupUserId.contains(opp.ownerid))){
                                    opp.AddError(System.Label.OffshoreRestrictedRoleErrorOppOwnerupdate);
                                }
                            }
                        }
                    }
                }  
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->GroupMembership  Class,accountOffShoreCheckErrorMessage Method'+ Ex.getMessage());
        }
    }
    
    //P2OB-9770 : Karan : Populate Head of Busiess(HOB) field on case with recordtype CBS & COVID_19_Financial_Hardship
    public static void filterCaseToPopulateHOB(List<case> caseList, List<String> caseRecordtypeIDs){
        List<Case> caseToUpdateHeadOfBusiness = new List<Case>();
        if(caseList ==null || caseList.size()==0)
            return;
        
        For(Case cs:caseList){
            If( !String.isEmpty(UserInfo.getUserRoleId()) &&
               cs.AccountId != null &&
               caseRecordtypeIDs.contains(cs.RecordTypeId)){
                   caseToUpdateHeadOfBusiness.add(cs);
               }
        }
        if(caseToUpdateHeadOfBusiness.size()!=0)
            getUserRole(caseToUpdateHeadOfBusiness);
        
    }
    //P2OB-9770 : Karan : Populate Head of Busiess(HOB) field on case with recordtype CBS & COVID_19_Financial_Hardship
    public static void getUserRole(List<case> caseList){
        List<String> finalParentRoleList = null;
        List<Id> custoLabelRolesID =null;
        List<User> usrList =null;
        List<Case> caseUpdate =null;
        Map<case,String> caseRoleMap =null;
        Map<Id,Account> accountOnCaseMap = null;
        
        if(caseList ==null && caseList.size()==0 && String.isEmpty(UserInfo.getUserRoleId()) ) return;
        
        //Getting Account record mentioned in Case Record
        Set<Id> accountIdSet = new Set<Id>();
        for(Case cs: caseList){
            accountIdSet.add(cs.accountID);
        }
        If(accountIdSet.size()==0) return;
        accountOnCaseMap =new Map<Id,Account>([Select Id, APTPS_Tier__c from Account where Id in : accountIdSet]);
         
        //getting Role's Developer name from Custom:Label
        String rolesFromCustomLabel = System.Label.Covid_Hardship_Case_Role_Mapping;
        if(String.isBlank(rolesFromCustomLabel))
            return;
        finalParentRoleList = rolesFromCustomLabel.split(',');
        if(finalParentRoleList ==null || finalParentRoleList.size()==0)
            return;
        custoLabelRolesID = new List<Id>();
        //Getting all the roles in org and storing it in MAP
        IdRoleMap = new Map<ID, UserRole>([SELECT Id, DeveloperName,ParentRoleId FROM UserRole Limit 5000]);
        //Storing the roleID of the roles we got from customLabel
        For(UserRole ur:IdRoleMap.values()){
            if(custoLabelRolesID!=null && custoLabelRolesID.size()==2  ){break;}
            if(finalParentRoleList.contains(ur.DeveloperName)){custoLabelRolesID.add(ur.Id);}
        }
        If(custoLabelRolesID !=null && custoLabelRolesID.size()==0)
            return;
        //creating a map of case and user to store  case and which role user to populate on that case
        caseRoleMap = new Map<case,String>();
        //Getting the details of the case on which we need to populate the Head of buisness field
        //Also populating the caseRoleMap from it
        for(Case c: caseList){
            //Excluding head of buisness field population for 'BCS Solutions' Team' AND 'Sales Holding' roles
            String curretUserRole = IdRoleMap.get(UserInfo.getUserRoleId()).DeveloperName;
            If(curretUserRole=='Sales_Holding' ||
               curretUserRole=='BCS_Solutions'){continue;}
            
            UserRole HeadofBuisnessRole = fetchParentRole(UserInfo.getUserRoleId(),custoLabelRolesID);
            if(HeadofBuisnessRole==null){continue;}
            String parentRoleOfUser = IdRoleMap.get(HeadofBuisnessRole.ParentRoleId).developerName;
            If((accountOnCaseMap.get(c.AccountId).APTPS_Tier__c=='Enterprise & Government' && parentRoleOfUser == 'Large_Enterprise_Government_Sales') ||
               (accountOnCaseMap.get(c.AccountId).APTPS_Tier__c=='Mid-market' && parentRoleOfUser == 'Business_Customer_Sales')){
                   caseRoleMap.put(c, HeadofBuisnessRole.id);
               }
        }
        If(caseRoleMap!=null && caseRoleMap.keySet().size()==0){return;}
        //Getting the list of users to populate the head of buisness field on case based on caseRoleMap
        usrList = [Select Id, Name, UserRoleId from User 
                   where UserRoleId != null
                   ANd UserRoleId = : caseRoleMap.values()];
        If(usrList!=null && usrList.size()==0){return;}
        //populating the head of buisness field from the caseRoleMap
        for (case cs : caseRoleMap.keySet()){
            for (User usr: usrList){
                if(usr.UserRoleId ==caseRoleMap.get(cs)){
                    cs.salesup_Head_of_business__c = usr.name;
                }
            }
        }   
    }
    //Karan jugtawat : P2OB-6365 : to Traverce the role based on the parent role id provided in the 2nd parameter.
    private static UserRole fetchParentRole(ID roleId, List<id> idIncustomLabel ){
        for(UserRole ur :IdRoleMap.values()){
            if(ur.id == roleId ){
                if(idIncustomLabel.contains(ur.ParentRoleId)){
                    return ur;
                }
                else{
                    return fetchParentRole(ur.ParentRoleId,idIncustomLabel);
                }
            }
        }
        return null;
    }
    
    /*
    @Method Name	: 	isOffshoreRestrictedUser
    @Description	: 	Checks if the users are present in offshore public groups.
	@return			:   returns map of user ids against boolean , if boolean is true its offshore user, else onshore
    @Author			:	SFO Team (Sravanthi)
    */
    public static Map<id,Boolean> isOffshoreRestrictedUser(List<Id> userIdList) {
        Map<id,Boolean> userOffshoreMap = new Map<id,Boolean>();
        Map<Id,Id> oppTeamRoleMap = new Map<Id,Id>();
        
        if(userIdList!=null && !userIdList.isEmpty()){
            GroupMembership gm=new GroupMembership();
            Set<Id> roleids=GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName);
            
            
                   
                for (user u : [Select Id,UserRoleId from user Where Id IN :userIdList]) {
                    oppTeamRoleMap.put(u.Id,u.UserRoleId);     
                }
            
            if(roleids!=null && !roleids.isEmpty() ){
                Set<Id> groupUserId = GroupMembership.groupUserId;
                for(Id u : userIdList){
                    if(roleids.contains(oppTeamRoleMap.get(u)) || (groupUserId!=null && groupUserId.contains(u))){
                        userOffshoreMap.put(u,true);
                    }
                    else{
                        userOffshoreMap.put(u,false);
                    }
                }
            }
        }
        return userOffshoreMap;
    }
}