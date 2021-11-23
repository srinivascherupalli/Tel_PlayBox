/*
    AUTHOR : Lok Jackson
    DESCRIPTION : Helper Class for UserTerritory2AssociationTriggerHandler, used to handle Account and Opportunity assignment to Territory Owner
*/

public without sharing class UserTerritory2AssociationTriggerHelper  {

	// Build a map of Portfolio Codes to UserId of the Owner where the owner is what has been inserted or updated, the call async method to perform assignment
	public static void AssignAccountsAndOpportunities(List<UserTerritory2Association> newAssociations){
		Map<String, Id> portToOwnerMap = new Map<String, Id>();
		Map<Id, UserTerritory2Association> associationMap = new Map<Id, UserTerritory2Association>(newAssociations);
		// Loop through all inserted/updated relatinoships, but only map those that are of type Owner
		for(UserTerritory2Association uta : [select Territory2.Name, UserId, RoleInTerritory2 from UserTerritory2Association where Id in :associationMap.keySet() and Territory2.Territory2Model.state = 'Active']){
			if(uta.RoleInTerritory2 == 'Owner'){
				portToOwnerMap.put(uta.Territory2.Name, uta.UserId);
			}
		}
		AsyncAssignAccountsAndOpportunities(portToOwnerMap);
	}

	// Based on a map of port codes to owners, reassign Accounts and Open Opportunities within that Portfolio to the new Portfolio Owner
	// Needs to be @future to avoid mixed DML errors caused by updates to setup objects and standard ibjects within same context
	@future
	private static void AsyncAssignAccountsAndOpportunities(Map<String, Id> portToOwnerMap){

		List<Account> accountUpdateList = new List<Account>();
		for(Account a : [select OwnerId, Portfolio_Code__c from Account where Portfolio_Code__c in : portToOwnerMap.keySet()]){
			a.OwnerId = portToOwnerMap.get(a.Portfolio_Code__c);
			accountUpdateList.add(a);
		}
		update accountUpdateList;

		List<Opportunity> opportunityUpdateList = new List<Opportunity>();
		for(Opportunity o : [select OwnerId, Account.Portfolio_Code__c from Opportunity where Account.Portfolio_Code__c in : portToOwnerMap.keySet() and IsClosed = false]){
			o.OwnerId = portToOwnerMap.get(o.Account.Portfolio_Code__c);
			opportunityUpdateList.add(o);
		}
		//Commenting below update for Bypassing the Opportunity owner change to account owner as new functionality has been implemented.
		//update opportunityUpdateList;
	}
}