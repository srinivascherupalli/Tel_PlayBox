/*
    AUTHOR : Lok Jackson
    DESCRIPTION : Handler for UserTerritory2AssociationTrigger, initial implementation only covers After Insert and After Update - to be extended as needed for other events
*/

public class UserTerritory2AssociationTriggerHandler  {

    public void OnAfterInsert(UserTerritory2Association[] newAssociations){
    	//Call helper to assign Accounts and Opportunities related to the Territory if insert is of role type 'Owner'
        UserTerritory2AssociationTriggerHelper.AssignAccountsAndOpportunities(newAssociations);
    }

    public void OnAfterUpdate(UserTerritory2Association[] oldAssociations, Map<ID, UserTerritory2Association> oldAssociationsMap, UserTerritory2Association[] updatedAssociations, Map<ID, UserTerritory2Association> updateAssociationsMap){
    	//Call helper to assign Accounts and Opportunities related to the Territory if update has made role type 'Owner'
        UserTerritory2AssociationTriggerHelper.AssignAccountsAndOpportunities(updatedAssociations);
    }

}