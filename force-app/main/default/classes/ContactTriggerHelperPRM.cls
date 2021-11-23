/* Added by uday[Team Orlando] on 20-09-2018 as per the US-EDGE-40965
Description : this method will update the user access to Sales Manager 
if the contact Partner_Role__c is changed to Sales Manager 
EDGE-88445 PartnerRole__c updated to Partner_Role__c (multi picklist field) by Saran
*/

/*
 * Modified By : Team Hawaii
 * Date : 3/6/2020
 * Jira : P2OB-6527 & P2OB-6037
 * Description : Remove method 'UpdateUserToSuperUser' and 'toUpdateUserAsSuperUser' as logic is moved to process builder 'Update Contact Owner' for this functionality
 * Modifications : 
 * 1. P2OB-7962 :  Ritika Jaiswal : Team Hawaii : Removing reduntant code for updating partner-role, removed method 'updatePartnerRole'     
*/
public with sharing class ContactTriggerHelperPRM {
    
    //EDGE-61863 Freeze and Unfreeze PDUA User based on Contact onboarding status = Active/Frozen. Added by Ramya
    public static Object freezeUnfreezeUser(List<Id> contactids, Map<Id,contact> newConMap,Map<Id,contact> oldConMap){
        system.debug('in ContactTriggerHelperPRM');
        Map<Id,User> pduaUser = new Map<Id,User>([Select id, contactid,name, profile.name, profileid from User where contactid = :contactids]);  
        Map<Id,user> conusrmap = new Map<Id,user>();
        List<Id> allContacts = new List<Id>();
        List<Id> pduaContacts = new List<Id>();
        List<Id> noAccreditiationUsersFreeze = new List<Id>();
        List<Id> noAccreditiationUsersUnfreeze = new List<Id>();
        
        
        String pname;
        for (user u : pduaUser.values()) {
            conusrmap.put(u.contactid,u);    //add corresponding contact users to map.
        }
        
        for(Contact con:newConMap.values()){
            // collect contacts whose status to be changed to frozen.
            if(oldConMap.get(con.id).Onboarding_Status__c != 'Frozen' && con.Onboarding_Status__c == 'Frozen' ){
                System.debug('in freeze list size:' + allContacts.size());
                allContacts.add(con.id);
            }
            // collect PDUA contacts whose status to be changed to unfrozen. PDUA check included in ManagePIMSController class.       
            if(oldConMap.get(con.id).Onboarding_Status__c == 'Frozen' && con.Onboarding_Status__c != 'Frozen' ){
                //if(oldConMap.get(con.id).Onboarding_Status__c == 'Frozen' && con.Onboarding_Status__c != 'Frozen' && conusrmap.get(con.id)!=null && conusrmap.get(con.id).profile.name==PRMConstants.PRM_PROFILE_PRM_Admin_Australia){
                System.debug('in unfreeze list size:' + pduaContacts.size());
                pduaContacts.add(con.Id);
            } /* 
//Below condition fetches No Acceditiated user and freezes the user     
if(oldConMap.get(con.id).Onboarding_Status__c != 'Inactive' && con.Onboarding_Status__c == 'Inactive' ){
System.debug('in freeze list size:' + noAccreditiationUsersFreeze.size());
noAccreditiationUsersFreeze.add(con.id);
}
//Below condition fetches No Acceditiated user and unfreezes the user     
if(oldConMap.get(con.id).Onboarding_Status__c != 'Active' && con.Onboarding_Status__c == 'Active' ){
System.debug('in freeze list size:' + noAccreditiationUsersUnfreeze.size());
noAccreditiationUsersUnfreeze.add(con.id);
} */
        }
        System.debug('allContacts list size:' + allContacts.size());
        System.debug('pduaContacts list size:' + pduaContacts.size());
        System.debug('in freeze list size:' + noAccreditiationUsersFreeze.size());
        System.debug('in freeze list size:' + noAccreditiationUsersUnfreeze.size());
        
        if(allContacts.size()>0){
            PRMFreezePartnerUser.freezeUsers(allContacts);            //Call PRMFreezePartnerUser Class and pass contacts whose users are to be frozen
        }
        if(pduaContacts.size()>0){
            PRMFreezePartnerUser.unfreezeUsers(pduaContacts);         //Call PRMFreezePartnerUser Class and pass PDUA contacts whose users are to be unfrozen
        }/*
if(noAccreditiationUsersFreeze.size()>0){
PRMFreezePartnerUser.freezeUsers(noAccreditiationUsersFreeze);//Call PRMFreezePartnerUser Class and pass noAccreditiationUsersFreeze to freeze
}if(noAccreditiationUsersUnfreeze.size()>0){
PRMFreezePartnerUser.unfreezeUsers(noAccreditiationUsersUnfreeze);//Call PRMFreezePartnerUser Class and pass noAccreditiationUsersUnfreeze to Unfreeze

}*/
        return null;   
    }
    
}// end of ContactTriggerHelperPRM