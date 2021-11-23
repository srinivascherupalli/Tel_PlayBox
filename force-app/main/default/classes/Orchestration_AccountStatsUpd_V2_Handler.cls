/**================================================================
*  Name: Orchestration_AccountStatsUpd_V2_Handler
* Description: Handler class to update the account status to Acquired if subscription is sent for billing successfully
* Created Date: 
* Created By: 
==================================================================*/
global with sharing class Orchestration_AccountStatsUpd_V2_Handler implements Orchestration_StepInterface{
    //extends Orchestration_AbstractStepHandler{
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    private Set<Id>OrderIds = new Set<Id>();
    private Set<Id>subscriptionIds = new Set<Id>();     
    protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
    
    public void processUpdate(String payload) {
        
        try {
            Map<Id,csord__Subscription__c> subscriptionMap = new Map<Id,csord__Subscription__c>();
            Map<String, Object> mapPayload = (Map<String, Object>)JSON.deserializeUntyped(payload);
            List<Object> reqs = (List<Object>)mapPayload.get('subscriptionIds');
            Id currentSubsRec= (Id)mapPayload.get('Current');
            Id stepId = (Id)mapPayload.get('StepId');
           /* for(integer i=0;i<reqs.size();i++){
                Id str=(Id)reqs[i];          
                subscriptionIds.add(str);
                
            }*/
            subscriptionIds.add(currentSubsRec);
            system.debug('subscriptionIds### '+subscriptionIds);
            //subscriptionList=Coms_PlatformCacheUtil.getSubscriptionFromCache(OrderId,subscriptionIds);//get subscription from platformcache
            
            List<csord__Subscription__c>subscriptionList = Coms_PlatformCacheUtil.getListOfSubscriptionFromCache(subscriptionIds);//get subscription from platformcache
            system.debug('subscriptionList### ' +subscriptionList);
            for(csord__Subscription__c subs: subscriptionList){
                system.debug('Customer_Status### '+subs.csord__Account__r.Customer_Status__c);
                if(subs.csord__Account__r.Customer_Status__c == 'ACTIVE'){                    
                    subscriptionMap.put(subs.Id,subs);
                }
            }
            try {
                system.debug('subscriptionMap### '+subscriptionMap);
                csord__Subscription__c sub = subscriptionMap.get(currentSubsRec); 
                system.debug('sub.csord__Account__c' +sub.csord__Account__c);
                if (sub == null || (sub != null && sub.csord__Account__c != null && sub.csord__Account__r.Customer_Status__c == 'Acquired') ||
                    sObjectsToUpdate.containsKey(sub.csord__Account__c)) {
                        mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: No Updation required.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                        //stepResults.put(step.Id, new stepResult('Success: No Updation required.', OrchestratorConstants.OrchestratorStep.Complete));
                        // continue;
                    } else {
                        //if (!hasDMLRowsLimitExceeded()) {
                        if (!Orchestration_LimitsUtility.areLimitsViolated()){
                            sObjectsToUpdate.put(sub.csord__Account__c, new Account(Id = sub.csord__Account__c, Customer_Status__c = 'Acquired'));
                            stepRelationship.put(sub.csord__Account__c, stepId);
                        }
                        //}
                    }
            } catch (Exception ex) {
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                
                System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            }
            
        } catch (Exception ex) {
            System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
                    }
        if (!sObjectsToUpdate.isEmpty()){
            updateAccObjects();
        }
        updateStepStatus();
       
    }
    //override Method implemented in AbstractStepHandler
    public void updateAccObjects() {
        List<Account> subscriptionList = new List<Account>();
        subscriptionList.add(sObjectsToUpdate.values());
       // Orchestration_PlatformCacheUtility.updatePlatformCache(subscriptionList);
      //  for(Account subs:subscriptionList){
      Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
		//Storing the records
		for (Database.SaveResult rslt : updateResult) {
			//stepRelationship will contain only subscription therefore avoiding updated order records
			//if(stepRelationship.containsKey(rslt.getId())){
			if (rslt.isSuccess()) {
            mapStepDetails.put(stepRelationship.get(rslt.getId()),new CSPOFA__Orchestration_Step__c(Id=stepRelationship.get(rslt.getId()),CSPOFA__Message__c='Success: Account Customer Status updated to Acquired.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
         }
            else {
				//record updation failed there related step updated
				mapStepDetails.put(stepRelationship.get(rslt.getId()), new CSPOFA__Orchestration_Step__c(Id=stepRelationship.get(rslt.getId()),CSPOFA__Message__c='Error: Unable to process records', CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
			}
        }
        
    }
    public void updateStepStatus(){
        //CSPOFA__Orchestration_Step__c step = [Select id,CSPOFA__Message__c,CSPOFA__Status__c from CSPOFA__Orchestration_Step__c where id=:stepid];
        List<Database.SaveResult> updateResult = Database.update(mapStepDetails.values(), false);
        
        for(Database.SaveResult result: updateResult){
            if (result.isSuccess()) {
                System.debug('Successfully updated step status ==> ' + result );
            } else {
                for(Database.Error err : result.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage()); 
                }
            }
        }
    }
}