/*
 * Modified By : Team Hawaii
 * Date : 3/6/2020
 * Jira : P2OB-6527 & P2OB-6037
 * Description : Added  only @TestVisible on the private variables as this variable needs to make true to cover update logic in test class
 * Modified Date : Team Hawaii(P2OB-6527 & P2OB-6037)-19/6/2020 Remove 'updateListOfPartnerSuperUser' method call as update operation is already completed in before
 *                 update operation and additioanally it consuming one dml operation.
 * Updates : 
 * 1. 07-09-2020 : Team Hawaii : P2OB-7962 - Removing call to UserTriggerHelperPRM.updatePartnerRole from AfterUpdate and PhoenixGlobalUtil.findPartnerRole from after insert.  
*/
public with sharing class UserTriggerHandler {
    
    private static list<User> setUserList = new list<User>();
    public void OnBeforeInsert(User[] newUsers) {
        System.debug('OnBeforeInsert:' + newUsers);
        //EDGE-76045-Adding Super user access if contact's partner role is Sales Manager
        //UserTriggerHelperPRM.UpdateUserToSuperUser(newUsers);
    }
    public void OnAfterInsert(User[] newUsers, map<ID,User> newUsersMap) {
        System.debug('OnAfterInsert:' + newUsers);
       

        UserTriggerHelperPRM.AddUserToOnshoreGroup(newUsersMap,null);//EDGE-28313  
        //TBTCUserTrigger.addUserToTBTCGroup(newUsersMap,null); //EDGE-120951 //Commented the code as now we are using Process builder to add Roles to Group.
        //UserTriggerHelperPRM.ShareAccountContactsforPRM(newUsersMap,null);
        //if(system.isBatch() == false && system.isFuture() == false && !system.isQueueable() && !system.isScheduled()){
        UserTriggerHelper.assignCSPermissionSet(newUsersMap,null); //assign permission sets to active partner users. EDGE 27228
        // }
        //UserTriggerHelperPRM.UpdatePRMRemainingLicenses(newUsers,null,newUsersMap,null,null);
      
        if(StaticUtilForRecursion.runOnceUserRoleupdate()){
         //P2OB-7962 : Removed call to findPartnerRole after user-insert 
            /*Map<string,string> contactupdateMap = PhoenixGlobalUtil.findPartnerRole(newUsers);          
           map<string,string> finalMap= new map<string,string>();           
            for(User objuser : newUsers){
              finalMap.put(objuser.contactid,contactupdateMap.get(objuser.id));
              }*/  
            //P2OB-7962 : Replaced parameter finalMap with null 
           UserTriggerHelperPRM.UpdatePRMRemainingLicenses(newUsers,null,newUsersMap,null,null);
        }   
      
    }
    public void OnBeforeUpdate(User[] oldUsers, map<ID, User> oldUsersMap,
                               User[] updatedUsers, map<ID, User> updatedUsersMap) {
                                   System.debug('OnBeforeUpdate: old ' + oldUsers);
                                   System.debug('OnBeforeUpdate: updated ' + updatedUsers);
                                   setUserList = UserTriggerHelper.getListOfPartnerSuperUser(oldUsers, oldUsersMap, updatedUsers, updatedUsersMap);
                                   if(StaticUtilForRecursion.runOnceContactRoleupdate()){} //to avoid recusrion as contact updates again trigger user update
                                      // UserTriggerHelperPRM.UpdateContactRole(updatedUsers,oldUsersMap);
                                 
                                   // UserTriggerHelperPRM.UpdatePRMRemainingLicenses(updatedUsers,oldUsers,updatedUsersMap,oldUsersMap);
                              }
    public void OnAfterUpdate(User[] oldUsers, map<ID, User> oldUsersMap,
                              User[] updatedUsers, map<ID, User> updatedUsersMap) {
                                  System.debug('OnAfterUpdate: old ' + oldUsers);
                                  System.debug('OnAfterUpdate: updated ' + updatedUsers);                             
                                  UserTriggerHelperPRM.AddUserToOnshoreGroup(updatedUsersMap,oldUsersMap); //EDGE-28313
                                  
                                  // UserTriggerHelperPRM.ShareAccountContactsforPRM(updatedUsersMap,oldUsersMap);
                                  //if(system.isBatch() == false && system.isFuture() == false && !system.isQueueable() && !system.isScheduled()){
                                  UserTriggerHelper.assignCSPermissionSet(updatedUsersMap,oldUsersMap); //assign permission sets to active partner users. EDGE 27228
                                  
                                  //}
                                  if(StaticUtilForRecursion.runOnceUserRoleupdate()){
                                //P2OB-7962 : Removed call to updateRole after user-update      
                                //Map<string,string> contactupdateMap=UserTriggerHelperPRM.updatePartnerRole(updatedUsers,updatedUsersMap);   
                                UserTriggerHelperPRM.UpdatePRMRemainingLicenses(updatedUsers,oldUsers,updatedUsersMap,oldUsersMap,null);  
                                  }   
                              }
    public void onAfterDelete(User[] deletedAccounts, Map<ID,User> deletedUsersMap){
        system.debug('OnAfterDelete: old '+ deletedUsersMap);
    }
    
    // Hawaii - Added @TestVisible as test class is not able to cover update logic 
    @TestVisible
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
} //UserTriggerHandler close