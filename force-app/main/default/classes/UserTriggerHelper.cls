/*
 * Modified By : Team Hawaii
 * Date : 3/6/2020
 * Jira : P2OB-6527 & P2OB-6037
 * Description : Modified this class as without sharing.When partner user try to update partner contact role it updates 'IsPrmSuperUser',
 *               Which fires this node to update Partner_Super_User__c checkbox but as partner user does not have access to this user 
 *               it fails.
 * Modified Date : Team Hawaii(P2OB-6527 & P2OB-6037)-19/6/2020 Remove 'updateListOfPartnerSuperUser' method as this method performing only extra dml.
 * Updates : 
 * 1. 07-09-2020 : Team Hawaii : P2OB-7962- Modified method assignCSPermissionSet to run on change of isActive field of User
*/
public without sharing class UserTriggerHelper {
    
    //get partner super users and update PartnerSuperUser Flag if partner is logged as super user.
    public static list<User> getListOfPartnerSuperUser(User[] oldUsers,map<ID,User> oldUsersMap, User[] updatedUsers,
                                           map<ID,User> updatedUsersMap){
          list <user> updateUserList = new list <user>();
                                                       list<contact> conlist= new list<contact>();

          if(UserTriggerHandler.runOnce()){
              for(User updatedUser: updatedUsersMap.values()){
                  User oldUser = oldUsersMap.get(updatedUser.id);
                  system.debug('oldValue '+oldUser.IsPrmSuperUser +' New Value:'+updatedUser.IsPrmSuperUser);
                  if (oldUser.IsPrmSuperUser!=updatedUser.IsPrmSuperUser)
                  {
                      User syncUser = updatedUsersMap.get(updatedUser.id);
                      syncUser.Partner_Super_User__c = updatedUser.IsPrmSuperUser;
                     // EDGE-88445 PartnerRole__c updated to Partner_Role__c (multi picklist field) by Saran
                      conlist.add(new contact(id=updatedUser.Contactid,Partner_Role__c=PRMConstants.PRM_PartnerRole_Partner_Sales_manager));
                      updateUserList.add(syncUser);
                  }
              }
              
          }  
           
        return updateUserList;
    }
    
    //Assign CS and Partner permission sets to active partner users. EDGE 27228
    //P2OB-7962 : Adding condition to run permission-set assignment method only for users updated as active/inactive
    public static void assignCSPermissionSet(map<id,user> userMap, 
                                            map<id,user> userOldMap){
       //assignPermissionSets(userIds);
         Set<Id> setContactId = new Set<Id>();
      for (User eachUser : userMap.values()) {
        if (eachUser.Contactid != null && userOldMap==null )
            setContactId.add(eachUser.contactId);
        else if (eachUser.Contactid != null && (userOldMap.get(eachUser.id)!=null && eachUser.isActive != userOldMap.get(eachUser.id).isActive)) {
            setContactId.add(eachUser.contactId);
        }
      }                                          
      if(setContactId!= null && setContactId.size() > 0)                                          
      	PhoenixGlobalUtil.manageUserPartnerPermSet(setContactId,label.PRM_PARTNER_ACTIVE_PERMMISIONSETS); //EDGE 24598,EDGE 27228: Ramya    
    }
   
}