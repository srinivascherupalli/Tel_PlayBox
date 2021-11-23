/*****************************************************************
@Name: EnableProductTypeSelection
@Description: EDGE-134166: Enable Opp Product Type selection at time of Opportunity creation
******************************************************************/
public without sharing class EnableProductTypeSelection {
    
    //invocable method to be called from Process Builder - Enable Product Type Selection 
    @InvocableMethod
    public static void assignPermissionSetGroupInvocable(List<Account> accountList){
        Id accountId;
        for(Account acc : accountList){
             accountId = acc.id;
            } 
        assignPermissionSetGroup(accountId);
    }
    
    //method to fetch contacts related to the account and assign the permission set group to users
    @future
    public static void assignPermissionSetGroup(Id accountId){
         
        System.debug('accountId:' +accountId);
        // get map of contacts associated to the account
        map<id,contact> contactMap = new Map<Id,Contact>();
        contactMap = new Map<Id,contact>([Select Id, Name, accountid, Account.CWP_Eligible_Partner__c from Contact where accountid =:accountId]);
        System.debug('contactMap:' +contactMap);
        manageCWPPermissions(contactMap);
            } 
    
    //Method to check CWP status of accounts to assign permission set
    public static void manageCWPPermissions(map<id,contact> contactMap){
        System.debug('in assignCWPPermissionSet method');
        map<id,Contact> contactIdsForAssignment=new map<id,Contact>();
        map<id,Contact> contactIdsForRemoval=new map<id,Contact>();
        for(contact c:contactMap.values()){
            if(c.Account.CWP_Eligible_Partner__c==true)
            {
                contactIdsForAssignment.put(c.id,c);
                assignCWPPermissions(contactIdsForAssignment);
            }
            else{
                contactIdsForRemoval.put(c.id,c);
                removeCWPPermissions(contactIdsForRemoval);
            }
            System.debug('contactIdsForAssignment:' +contactIdsForAssignment);
        }
    }
    
   
    // Method to assign Permission Set Group to partner contacts
    public static void assignCWPPermissions(map<id,Contact> cntids){
        System.debug('in assignCWPPermissions method');
        String PRMUser = PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA;
        String PRMAdmin = PRMConstants.PRM_PROFILE_PRM_Admin_Australia;
        String PermissionsetGroup = PRMConstants.Enabled_to_sell_Modular_Products;
        List<User> cwpEnabledUserList = new List<User>();
         //Fetching Permissionset group Name  
        PermissionSetGroup psGroupName = [SELECT Id,DeveloperName,MasterLabel FROM PermissionSetGroup 
                                  where (DeveloperName =:PermissionsetGroup or DeveloperName ='Enabled_to_sell_Modular_Products_Test') and status='Updated' limit 1]; 
        System.debug('psGroupName:' +psGroupName);
        
         //Fetch the user records from the collected contacts
        list<user> UserList = [select id, Name, Profile.Name from user 
                               where contactid IN :cntids.keySet() AND Isactive=true AND ID NOT IN (SELECT AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE PermissionSetGroupId = :psGroupName.Id)];
        System.debug('UserList:' +UserList);
        /*                     
        // check if PS group is already assigned to the user
        List<PermissionSetAssignment> lstcurrentUserPerSet =   [SELECT Id, PermissionSetGroupId,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE PermissionSetGroupId = :psGroupName.Id AND AssigneeId IN :UserList];
*/
     //   for(PermissionSetAssignment ps : lstcurrentUserPerSet){
        for(User u : UserList){
           // if(((u.Profile.Name == PRMUser) || (u.Profile.Name == PRMAdmin)) && (u.Id != ps.AssigneeId)){
            if((u.Profile.Name == PRMUser) || (u.Profile.Name == PRMAdmin) ){
               cwpEnabledUserList.add(u); 
            }
          } 
       // }
        
       System.debug('cwpEnabledUserList:' +cwpEnabledUserList);
        
        //Insert Permissions if CWP Enabled users
        list<PermissionSetAssignment> insertPSAList = new list<PermissionSetAssignment>(); 
        if(!cntids.isEmpty())
        {       
          for(user eachUser : cwpEnabledUserList){ 
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetGroupId = psGroupName.id, 
                                                                          AssigneeId = eachUser.id);
                system.debug('persetAssignmnt'+psa);
                insertPSAList.add(psa);                  
                                 
        }
            System.debug('insertPSAList:' +insertPSAList);
            System.debug('insertPSAList.size():' +insertPSAList.size());
            if(insertPSAList.size()>0){
                database.insert(insertPSAList,true);
            }
        } 
}
    //method to remove permission set group if account is not CWP enabled 
     public static void removeCWPPermissions(map<id,Contact> cntids){
        System.debug('in removeCWPPermissions method');
         String PermissionsetGroup = PRMConstants.Enabled_to_sell_Modular_Products;
         //fetch permission set group name to be assigned
        PermissionSetGroup psGroupName = [SELECT Id,DeveloperName,MasterLabel FROM PermissionSetGroup 
                                  where DeveloperName =:PermissionsetGroup];
        System.debug('psGroupName:' +psGroupName);
        List<PermissionSetAssignment> deletePSAList = new list<PermissionSetAssignment>();
        list<user> cwpDisabledUserList = [select id, Name from user where contactid =: cntids.keySet()];
        System.debug('cwpDisabledUserList:' +cwpDisabledUserList);
         
        //List of users for whom permission set group assignment needs to removed
        deletePSAList = [SELECT Id FROM PermissionSetAssignment
                         WHERE AssigneeId IN :cwpDisabledUserList 
                         AND PermissionSetGroupId =: psGroupName.id] ;
         System.debug('deletePSAList:' +deletePSAList);
         System.debug('deletePSAList size:' +deletePSAList.size());
         if(deletePSAList.size()>0)
         delete deletePSAList;
       }
    
    /* To Check if the permission set is already assigned to user*/ 
  /*  public static boolean validatePermission(list<user> cwpEnabledUserList, String PSGroupId){
        system.debug('PSGroupId==' + PSGroupId);
        List<PermissionSetAssignment> lstcurrentUserPerSet =   [SELECT Id, PermissionSetGroupId,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId IN :cwpEnabledUserList
                                                                AND PermissionSetGroupId != :PSGroupId];        
        system.debug('lstcurrentUserPerSet==' + lstcurrentUserPerSet);
        system.debug(lstcurrentUserPerSet.isEmpty());
        system.debug(lstcurrentUserPerSet.size());
        if(lstcurrentUserPerSet.isEmpty()){
            return true;
        }
        else{
            return false;
        }
       // return lstcurrentUserPerSet.isEmpty()?true:false;    
    } */
    }