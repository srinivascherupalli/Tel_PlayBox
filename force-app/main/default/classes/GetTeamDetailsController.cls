/*******************************************************************
Created By          :   Sravanthi
Created Date        :   26-August-2021
Story               :   TEAM SFO Sprint 21.12 DIGI-8926
Desc                :   Used for teams functionality              
***********************************************************************/
public without sharing class GetTeamDetailsController {
    /*
    @Method Name	: 	getAccTeam
    @Description	: 	Fetches account team, users default account team 
    @Author			:	SFO Team (Sravanthi)
    @Story          :   TEAM SFO Sprint 21.12 DIGI-8926
    */
    @AuraEnabled
    public static TeamsListWrapper getAccTeam(Id AccountId ,Id userId){
        TeamsListWrapper teamsLists ;
        List<AccountTeamMember> accTeamList ;
        List<UserAccountTeamMember > defTeamList ;
        Map<id,Boolean> userOffshoreMap;
        try {
            Account acc = [SELECT id,APTPS_Off_Shore_Restricted__c,OwnerId FROM Account WHERE id =:AccountId LIMIT 1];
            if(acc.APTPS_Off_Shore_Restricted__c){
                
                userOffshoreMap = GroupMembership.isOffshoreRestrictedUser( new List<id>{userId});
            }
            Boolean hasAdminPermission = FeatureManagement.checkPermission('System_Administrator');
            Boolean hasOpsPermission = FeatureManagement.checkPermission('Operations_Permission');
            
            if(userOffshoreMap != null && !userOffshoreMap.isEmpty() && userOffshoreMap.get(userId)){
                teamsLists= new TeamsListWrapper(null,null,true,false);
            }
            
            else{
                accTeamList=[SELECT Id, AccountAccessLevel, TeamMemberRole,UserId,User.Name
                             FROM AccountTeamMember
                             WHERE AccountId  = :AccountId];
                defTeamList = [SELECT AccountAccessLevel,Id,OwnerId,TeamMemberRole,UserId,User.Name  
                               FROM UserAccountTeamMember 
                               WHERE OwnerId = :userId];
                teamsLists= new TeamsListWrapper(defTeamList,accTeamList,false,false);
            }
         
            if(hasAdminPermission || hasOpsPermission || acc.OwnerId == userId){
                teamsLists.loggedInUserAccOwnerOrAdmin =true;
            }
            System.debug(Limits.getQueries()+'Queries');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return teamsLists;
    }
    
    /*
    @Method Name	: 	saveAccTeam
    @Description	: 	deletes and saves the account team members  
    @Author			:	SFO Team (Sravanthi)
    @Story          :   TEAM SFO Sprint 21.12 DIGI-8926
    */
    @AuraEnabled
    public static string saveAccTeam(List<AccountTeamMember> saveteamList , List<AccountTeamMember> teamMemToDeleteList,List<Id> userIdssaveList,Id AccountId){
        String returnMessage;
        try {
            Account acc =[SELECT id ,Name,APTPS_Off_Shore_Restricted__c,CIDN__c FROM Account WHERE Id =:AccountId LIMIT 1];
            String usersNames = getUserNames(acc.APTPS_Off_Shore_Restricted__c,userIdssaveList);
            
            if(usersNames != null){
                System.debug(Limits.getQueries());
                returnMessage = usersNames + ' '+System.label.AccountTeamOffshoreUserSaveError;
            }
            else{
                if(teamMemToDeleteList != null && !teamMemToDeleteList.isEmpty()){
                    delete teamMemToDeleteList;
                }
                if(saveteamList != Null && !saveteamList.isEmpty()){
                    upsert saveteamList;
                    
                }
                returnMessage ='success';
                
                sendChatter(teamMemToDeleteList,userIdssaveList,acc.Name,acc.CIDN__c);
            }
            System.debug(Limits.getQueries()+'Queries');
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnMessage;
    }
    /*
    @Method Name	: 	getUserNames
    @Description	: 	Checks if save users are offshore restricted if so returns string of the users
    @Author			:	SFO Team (Sravanthi)
    @Story          :   TEAM SFO Sprint 21.12 DIGI-8926
    */
    public static string getUserNames(Boolean isOffshoreAccount,List<Id> userIdssaveList){
        String usersNames;
        if(isOffshoreAccount){
            Map<id,Boolean> offshoreCheckMap;
            List<Id> offuserIdList = new List<Id>();
            String[] tmp1 = new String[]{};
                Map<id,user> userMap;
            
            if(userIdssaveList != null && !userIdssaveList.isEmpty()){
                offshoreCheckMap  = GroupMembership.isOffshoreRestrictedUser(userIdssaveList);
            } 
            if(offshoreCheckMap!=null && !offshoreCheckMap.isEmpty()){
                for(Id userId : offshoreCheckMap.KeySet()){
                    if(offshoreCheckMap.containskey(userId) && offshoreCheckMap.get(userId)){
                        offuserIdList.add(userId);
                    }
                }
            }
            
            if(offuserIdList!= null && !offuserIdList.isEmpty()){
                userMap = new Map<id,user>([SELECT id , name FROM User WHERE Id in : offuserIdList]);
            }
            if(userMap!=null && !userMap.isEmpty()){
            for(User u : userMap.values()){
                tmp1.add(u.Name);
            }}
            if(!tmp1.isempty()){
                usersNames=string.join(tmp1,',');
            }
        }
        return usersNames;
    }
    /*
    @Method Name	: 	sendChatter
    @Description	: 	Sends Chatters to users when they have been added or removed from AccountTeamMember
    @Author			:	SFO Team (Sravanthi)
    @Story          :   TEAM SFO Sprint 21.12 DIGI-8926
    */
    public static void sendChatter(List<AccountTeamMember> deleteList,List<Id> saveUserList,String accountName,String accountCIDN){
        
        C2O_ChatterUtil.ChatterFeedInfo feedInfo;
        List<C2O_ChatterUtil.ChatterFeedInfo> listOfchatterFeeds = new List<C2O_ChatterUtil.ChatterFeedInfo>();
        String chatterMsgAdd =System.label.AccountTeamChatterAddMessage+' '+accountName+'( CIDN : '+accountCIDN+' ) .';
        String chatterMsgDelete=System.label.AccountTeamChatterRemovedMessage+' '+accountName+'( CIDN : '+accountCIDN+' ) .';
        if(deleteList != null && !deleteList.isEmpty()){
            for(AccountTeamMember accteam : deleteList){
                if(UserInfo.getUserId() != accteam.UserId){
                    feedInfo = new C2O_ChatterUtil.ChatterFeedInfo(accteam.userId, new set<Id>{}, chatterMsgDelete);
                listOfchatterFeeds.add(feedInfo);
                    
                }
            }
            
        }
        if(saveUserList != null && !saveUserList.isEmpty()){
            for(Id accteam :saveUserList){
                if(UserInfo.getUserId() != accteam){
                    feedInfo = new C2O_ChatterUtil.ChatterFeedInfo(accteam, new set<Id>{}, chatterMsgAdd);
                listOfchatterFeeds.add(feedInfo);
                    
                }
            }
        }
        
        if (!listOfchatterFeeds.isEmpty() ) {
            System.enqueueJob(new C2O_ChatterUtil.InvokeBulkChatterFeedQueueable(listOfchatterFeeds));
        }
    }
    public class TeamsListWrapper {
        @AuraEnabled public List<UserAccountTeamMember> userdefaultAccTeam;
        @AuraEnabled public List<AccountTeamMember> existingAccTeam;
        @AuraEnabled public Boolean OffshoreRestrictedUser;
        @AuraEnabled public Boolean loggedInUserAccOwnerOrAdmin;
        

        public TeamsListWrapper(List<UserAccountTeamMember> userdefaultAccTeamLst,List<AccountTeamMember> existingAccTeamLst,Boolean isOffshoreUser,Boolean UserAccOwnerOrAdmin){
            userdefaultAccTeam = userdefaultAccTeamLst;
            existingAccTeam = existingAccTeamLst;
            OffshoreRestrictedUser = isOffshoreUser;
            loggedInUserAccOwnerOrAdmin =UserAccOwnerOrAdmin;
        }
    }

}