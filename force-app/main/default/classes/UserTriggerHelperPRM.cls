/*
 * Modifications :  
 * 1. P2OB-6753 - Hawaii - 05/06/2020 - Commented the code as business do not want the license calculation
 * 2. P2OB-7962 - Hawaii - 03/09/2020 - 1. Modifed method UpdatePRMRemainingLicenses to run without contact-role update , 2.Removed method updatePartnerRole  
*/

public without sharing class UserTriggerHelperPRM {
    
    /**
 * Description: Adding user to Onshore public group  EDGE-28313
 *
 * @param      newuserMap  The newuser map
 */
//Method for adding users to OnShoreGroup based on account Address
    public static void addUserToOnshoreGroup(map<id, user> newuserMap,map<id, user> olduserMap) {

        map<ID, User> newpartnerUsersMap = new map<ID, User>();
        List<GroupMember> GMlist = new List<GroupMember>();
        Set<Id> result = new Set<Id>();
        Group OnShoreGroup = new Group();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        Logger2 logger = Logger2.getLogger('UserTriggerHelperPRM');
        try {
            for (user U : newuserMap.values()) {
           
                //if (U.isActive && (U.usertype == PRMConstants.PRM_USER_TYPE_POWER_PARTNER || U.usertype == PRMConstants.PRM_USER_TYPE_PARTNER) )
               if (U.isActive && (  (olduserMap==null && (U.usertype == PRMConstants.PRM_USER_TYPE_POWER_PARTNER || U.usertype == PRMConstants.PRM_USER_TYPE_PARTNER)) ||(olduserMap!=null && olduserMap.containskey(U.id) && ((olduserMap.get(U.id).usertype!=PRMConstants.PRM_USER_TYPE_POWER_PARTNER && U.usertype == PRMConstants.PRM_USER_TYPE_POWER_PARTNER) ||(olduserMap.get(U.id).usertype!=PRMConstants.PRM_USER_TYPE_PARTNER && U.usertype == PRMConstants.PRM_USER_TYPE_PARTNER)))))  
               { 
                    newpartnerUsersMap.put(U.ID, U);
                }
            }
            if (newpartnerUsersMap.values().size() > 0) {
                Map<id, user> userMap = new map<id, user>([select id, accountid, contact.account.Partner_Account_Location__c,Contact.MailingCountry  from user  where id IN: newpartnerUsersMap.keyset()]);
                OnShoreGroup = [Select Id from Group where DeveloperName = :PRMConstants.PRM_PUBLICGROUP_PARTNER_ONSHORE limit 1];
                for (GroupMember m : [Select Id, UserOrGroupId, GroupId, Group.type
                                      From GroupMember
                                      Where GroupId = :OnShoreGroup.id]) {
                    if (((String)m.UserOrGroupId).startsWith(userType))
                        result.add(m.UserOrGroupId);
                }
                //meaningful variable
                system.debug('newpartnerUsersMap.values()' + newpartnerUsersMap.values());
                for (User U : newpartnerUsersMap.values()) {
                    if ( !result.contains(U.id) && userMap.containsKey(U.id) && userMap.get(U.id) != null && userMap.get(U.id).Contact.MailingCountry == 'Australia') {
                        GroupMember GM = new GroupMember();
                        GM.GroupId = OnShoreGroup.id;
                        GM.UserOrGroupId = U.Id;
                        GMList.add(GM);
                    }
                }
                if (!GMList.isEmpty()) {
                    system.debug('GMList' + GMList);
                    insert GMList;
                }
            }
        } catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
      logger.exitLogger();
        } 

}

    public static void UpdatePRMRemainingLicenses(User[] newUsers, User[] oldUsers, map<id, user> newuserMap, map<id, user> userOldMap,map<string,string> Contactupdatemap) {
        set<id> sAccountId = new set<Id>();
        set<id> sProfileIds = new set<id>();
        system.debug('newUsers ===>' + newUsers);
        Logger2 logger = Logger2.getLogger('UserTriggerHelperPRM');
        try{
        if (!newUsers.isEmpty()) {
            map<id,Profile> mpUserProfileNames = new map<id,Profile>();
            for(User Obj:newUsers){
                if(obj.ProfileId != null)
                    sProfileIds.add(obj.ProfileId);
            }
            if(!sProfileIds.isEmpty()){
                mpUserProfileNames = new map<id,profile>([Select id,Name from Profile where id in:sProfileIds]);
            }
            for (User obj : newUsers) {
                system.debug('AccountID ===>' + obj.AccountId);
                if (obj.AccountId != null && obj.profileId != null && !mpUserProfileNames.isEmpty()&& mpUserProfileNames.containsKey(obj.profileId) && mpUserProfileNames.get(obj.profileId)!= null && (mpUserProfileNames.get(obj.profileId).Name== PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA||mpUserProfileNames.get(obj.profileId).Name==PRMConstants.PRM_PROFILE_PRM_Admin_Australia)){ // have to check the profiles with the PRM profiles
                //only execute, if new user is created for PRm and is active || is Active flag is getting changed
                   if ( (userOldMap==null && obj.isActive ) || ( userOldMap!=null && userOldMap.get(obj.Id).isActive!= obj.isActive)) // have to check the profiles with the PRM profiles
                      sAccountId.add(obj.AccountId);
                  }
               }
        }
        system.debug('sAccountId ====>' + sAccountId);
        
            //added as part of merge to fix the multiple enque job 
            List<AccountShare> lstShare = ShareAccountContactsforPRM(newuserMap,userOldMap);
            
         //P2OB-7962 : Removed Check for '|| Contactupdatemap!=null' from below IF condition    
         if((!sAccountId.isEmpty() || lstShare.size()>0  )  && !test.isRunningTest() /*&& Limits.getQueueableJobs()==0*/){
           system.debug('Contactupdatemap'+Contactupdatemap);
             System.enqueueJob(new QueueableRmngLicenseonAccount(sAccountId,lstShare,Contactupdatemap));//UpdateLicenses(sAccountId);
        }
        }catch(Exception ex){
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            logger.exitLogger();
        }
    }
    
    public static List<AccountShare> ShareAccountContactsforPRM(map<id,user> newuserMap,map<id,user> OldMap)
{
 Try{
   List<User> lstUsers = newuserMap.Values();
   Logger2 logger = Logger2.getLogger('UserTriggerHelperPRM');
   set<id> sProfileId = new set<id>();
         for(User obj: lstUsers){
            sProfileId.add(obj.ProfileId);
        }
    map<id,Profile> mpProfile = new map<id,Profile>([select id,Name from Profile where id in:sProfileId]);
   if(OldMap == null){//For After Insert
        return PhoenixGlobalUtil.AccountSharebasedOnPRMAccess(lstUsers);
     
        
   }else{//For After update
        
       List<User> lstUsersToUpdate = new List<User>();
       for(User obj:lstUsers){
          If(obj.ProfileId != null && mpProfile.containsKey(obj.ProfileId) &&  (mpProfile.get(obj.ProfileId).Name == PRMConstants.PRM_PROFILE_PRM_Admin_Australia || mpProfile.get(obj.ProfileId).Name == PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA)&& obj.ProfileId != OldMap.get(obj.id).ProfileId){
                    lstUsersToUpdate.add(obj);
          }
      }
        return PhoenixGlobalUtil.AccountSharebasedOnPRMAccess(lstUsersToUpdate);
   }

}Catch(Exception ex){
       system.debug('errorrr ===>'+ex.getMessage());    
}
 return null;
}
@future
  public static void UpdateLicenses(set<id> sAccountId) {
    Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
    map<Id, Account> mpAccounts = new map<Id, Account>();
    List<Account> lstAccountsToUpdate = new List<Account>();
    
    AggregateResult[] groupedResults  = [SELECT AccountId, count(id)
                                         FROM User
                                         where AccountId in:sAccountId
                                         and isActive = true and AccountId != null  GROUP BY AccountId];
    system.debug('groupedResults ====>' + groupedResults);
    map<object, object> mpLicense = new map<object, object>();
    for (AggregateResult agr : groupedResults) {
      mpLicense.put(agr.get('AccountId'), agr.get('expr0'));
    }
    
    lstAccountsToUpdate = [select id, RecordtypeId,Users_on_Account__c,PRM_Remaining_License__c, PRM_License_Limit__c
                           from Account
                           where id in:sAccountId
                           and RecordTypeId = :partnerAccRecID];
    
    system.debug('lstAccountsToUpdate ====>' + lstAccountsToUpdate);
    system.debug('mpLicense ====>' + mpLicense);
    
    if (!lstAccountsToUpdate.isEmpty()) {
      for (Account obj : lstAccountsToUpdate) {
        system.debug('mpLicenseidd ====>' + mpLicense.containsKey(obj.id));
        if (!mpLicense.isEmpty() && mpLicense.containsKey(obj.id) && mpLicense.get(obj.id) != null) {
            /*P2OB-6753 - Hawaii - Commented the code as business do not want the license calculation 
            if(obj.PRM_License_Limit__c != null && obj.PRM_License_Limit__c >0)
                obj.PRM_Remaining_License__c = obj.PRM_License_Limit__c - Integer.ValueOf(mpLicense.get(obj.id));
            else
                obj.PRM_Remaining_License__c = Integer.ValueOf(mpLicense.get(obj.id));*/
                
                obj.Users_on_Account__c = Integer.ValueOf(mpLicense.get(obj.id));              
        }
      }
      system.debug('lstAccountsToUpdateFinal ====>' + lstAccountsToUpdate);
      if (!lstAccountsToUpdate.isEmpty())
        update lstAccountsToUpdate;
    }
  }
    
     /**
        Description: Updating Contact Role on Contact if user is changed to Super User 
        US: EDGE-74065
   
    public static void UpdateContactRole(list<user> usrlist,map<id, user> olduserMap) {
        list<contact> conlist= new list<contact>();
         Logger2 logger = Logger2.getLogger('UserTriggerHelperPRM.UpdateContactRole');
            try {
                    for(user u:usrlist)
                    {
                        
                        if(u.isPRMSuperuser==true && olduserMap.get(u.id).isPRMSuperuser!=u.isPRMSuperuser && u.Contactid!= null)
                        {//EDGE-88445 PartnerRole__c updated to Partner_Role__c (multi picklist field) by Saran
                            conlist.add(new contact(id=u.Contactid,Partner_Role__c=PRMConstants.PRM_PartnerRole_Partner_Sales_manager));

                            system.debug('contactid');
                        }                   
                    }
                    
                    system.debug('conlist'+conlist);

                    if(conlist.size()>0){
                        update conlist;
                    }
                }
            
            catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            logger.exitLogger();
        } 

}  */
    
   /**
        Description: Updating user as Super user if the correcponding Contact Partner Role is SalesManager 
        US: EDGE-74065
    
public static void updateUserToSuperUser(List<user> userlist){        
        Logger2 logger = Logger2.getLogger('UserTriggerHelperPRM.updateUserToSuperUser');
        try{ 
            Id ContactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
            set<id> sContacts = new set<id>();            
                for(user objuser:userlist){  
                  sContacts.add(objuser.contactid);
                }               

                map<id,contact> contactmap= new map<id,contact>([select id,Partner_Role__c from contact where id in :sContacts and recordtypeid=:ContactRecTypeId]);
                
                for(user objuser:userlist){ 
                    if(objuser.contactid!=null && contactmap.containskey(objuser.contactid) && contactmap.get(objuser.contactid).Partner_Role__c==PRMConstants.PRM_PartnerRole_Partner_Sales_manager){
                            objuser.isPRMSuperuser=true;
                    }
        
                }       
        }Catch(Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            logger.exitLogger();            
        }
}  */
    
 /**    US: EDGE-88445 added by Saran
        Description: To avoid Mixed DML we are passing the result map values to update 
 */ 
    
    //@future
    public static void futureUpdates(map<string,string> futureMap){
      
        list<contact> conList = new list<contact>();
        Logger2 logger = Logger2.getLogger('UserTriggerHelperPRM.futureUpdates');
        try{ 
        for(String ContactId : futureMap.keyset()){
            Contact c = new Contact(Id = ContactId,partner_role__c = futureMap.get(ContactId));
            conList.add(c);
            }
                system.debug('conlist'+conlist);
                if(conlist.size()>0){
                      update conlist; 
                 } system.debug('conlist '+conlist);           
            }Catch(Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            logger.exitLogger();            
        }
    }
    
}//UserTriggerHelperPRM close