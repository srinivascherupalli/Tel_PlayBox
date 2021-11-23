/*
 * Created by: Ivan Aerlic
 */
public Without Sharing class ATF_TeamTokyoUserHandler extends ATF_AbstractDomainHandler{
    public override void handleBeforeUpdate(Map<Id,sObject> oldMap){
        //Set the activation date on updated records that are going from inactive to active
    	//EDGE-115099
        for(User user:(List<User>)Trigger.New){
            if(user.isActive && !((User)oldMap.get(user.Id)).isActive){
                user.Activation_Date__c = System.today();
            }
        }    
    }
    
    /*
     * This method deletes package license, permission set and permission set license assignment
     * when user is deactivated
     * 
     * Created by: Apratim Khobragade 
	*/
    public override void handleAfterUpdate(Map<Id,SObject> oldMap) {
        List<Id> deactivatedUserIds = new List<Id>();
        
        //Consider users which are deactivated
        for(User u : (List<User>) Trigger.New) {
            if(!u.isActive) {
                deactivatedUserIds.add(u.Id);
            }
        }
        System.debug('deactivatedUserIds:' + deactivatedUserIds);
        //Delete associated package license
        Database.delete([SELECT Id FROM UserPackageLicense WHERE UserId IN :deactivatedUserIds], false);
        //Delete associated permission sets
        Database.delete([SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.isOwnedByProfile = false AND AssigneeId IN :deactivatedUserIds], false);
        //Delete associated permission set license
        Database.delete([SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId IN :deactivatedUserIds], false);
    }
}