/**
 * @Description : Update Contact owner same as account owner when the contact has only one Account Contact Relationship.
 * @Author : ChandrakanthReddy B 
 * @Story : EDGE-19739
 */
public without sharing class UpdateContactOwner {
   
    private String profileName = null;
    private Boolean isSalesProfile = false;

    public UpdateContactOwner(){
        isSalesProfile = isSalesProfile();
    }

    private Boolean isSalesProfile(){
        String profileEnvVariable = EnvironmentVariable.get('contact-profile');
        //String profileEnvVariable = 'Pilot Enterprise Sales Manager,Pilot Enterprise Sales User,Sales - Enterprise,Sales - Enterprise_offshore,Sales Enterprise B2B,Sales Manager - Enterprise,Sales Manager - Enterprise_offshore,Sales - Small Business';
        List<Profile> profileList=null;
        if(String.isNotBlank(profileEnvVariable)){
            List<String> profiles = profileEnvVariable.split(',');
            profileList = [Select Name from Profile where Id = :UserInfo.getProfileId() and Name in :profiles];
        }
        return (profileList!=null && !profileList.isEmpty())?true:false;
    }
    
    public void updateContactOwnerBeforeInsert(List<Contact> newContacts){
        if(!isSalesProfile){
            Map<Id,Account> accOwnerMap = getAccountOwner(newContacts);
            for(Contact con : newContacts){
                if(accOwnerMap.containsKey(con.AccountId)){
                    con.OwnerId = accOwnerMap.get(con.AccountId).OwnerId;
                }
            }
        }
    }
    
    private Map<Id,Account> getAccountOwner(List<Contact> newContacts){
        Set<Id> accIds = new Set<Id>();
        Map<Id,Account> accOwnerMap = null;
        for(Contact con : newContacts){
            if(con.AccountId != null){
                accIds.add(con.AccountId);
            }
        }
        accOwnerMap = getAccounts(accIds);
        return accOwnerMap;
    }
    
    private Map<Id,Account> getAccounts(Set<Id> accIds){
        return new Map<Id,Account>([SELECT Id,OwnerId FROM Account WHERE Id IN : accIds]);
    }
    
}