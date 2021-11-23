/*
    AUTHOR : Lok Jackson
    DESCRIPTION : Called from the finish method of the BatchAccountAssignment Apex CBatch Class
    				Reassigns open Opportunities based on Portfolio Owner in the Active Territory Model
					
*/

global Without sharing class BatchOpportunityAssignment implements Database.Batchable<SObject> {

	private Map<String, Id> portCodeOwnerMap;

	global BatchOpportunityAssignment() {
		portCodeOwnerMap = new Map<String,Id>();
		for(UserTerritory2Association portOwners : [select UserId, Territory2.Name from UserTerritory2Association where Territory2.Territory2Model.State = 'Active' and RoleInTerritory2 = 'Owner' order by LastModifiedDate ASC]){
			portCodeOwnerMap.put(portOwners.Territory2.Name, portOwners.UserId);
		}
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator('SELECT Id, Name, OwnerId, Portfolio_Code__c FROM Opportunity WHERE Portfolio_Code__c != null AND IsClosed = FALSE');
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Opportunity> scope) {
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
    	for(Opportunity o : scope){ 
    		Id oppOwnerId = portCodeOwnerMap.get(o.Portfolio_Code__c);
    		if(oppOwnerId != null){
				o.OwnerId = oppOwnerId;
        		oppsToUpdate.add(o); 
        	}
    	} 
    	update oppsToUpdate; 
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}
}