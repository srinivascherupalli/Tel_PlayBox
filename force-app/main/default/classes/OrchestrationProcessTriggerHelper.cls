public with sharing class OrchestrationProcessTriggerHelper {

    /*
     * Implement the logic needed to rollup the cancellation status of all the child processes
     * whenever the status(CSPOFA__Status__c) field is updated to Complete on an Orchestration Process
     */
    public static void rollupCancellationStatus(CSPOFA__Orchestration_Process__c[] oldRecords, 
                                                Map<ID, CSPOFA__Orchestration_Process__c> oldMap, 
                                                CSPOFA__Orchestration_Process__c[] updatedRecords, 
                                                Map<ID, CSPOFA__Orchestration_Process__c> updatedMap) {

        System.debug('oldRecords = ' + oldRecords);
        

        // We are only interested in child records with a parent, filter out the rest and add the parents to a list for processing
        List<CSPOFA__Orchestration_Process__c> filteredRecords = new List<CSPOFA__Orchestration_Process__c>();
        List<Id> parentList = new List<Id>();

        for (CSPOFA__Orchestration_Process__c op : oldRecords) {
            if (op.CSPOFA__Process_Type__c == 'Cease' && op.Parent_Orchestration_Process__c != null) {
                filteredRecords.add(op);
                parentList.add(op.Parent_Orchestration_Process__c);
            }
        }
        System.debug('filteredRecords = ' + filteredRecords);
        System.debug('parentList = ' + parentList);
        
        // Exit the method if no parents exist
        if (parentList.isEmpty()) {
            return;
        }

        // Get the children records from the parents that meet specific criteria
        List<CSPOFA__Orchestration_Process__c> childList = [SELECT Id, Parent_Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__State__c 
                                                            FROM CSPOFA__Orchestration_Process__c
                                                            WHERE Parent_Orchestration_Process__r.Id IN : parentList
                                                            AND CSPOFA__State__c = : Constants.orchestrationProcessActive
                                                            AND CSPOFA__Status__c IN : Constants.incompleteOrchestrationProcessStatuses];
        System.debug('childList = ' + childList);        

        // Build a map of the parent and children
        Map<String,List<CSPOFA__Orchestration_Process__c>> mapParentVsChildren = new Map<String,List<CSPOFA__Orchestration_Process__c>>();
        for (CSPOFA__Orchestration_Process__c op : childList) {
            if(mapParentVsChildren.containsKey(op.Parent_Orchestration_Process__c)) {
                List<CSPOFA__Orchestration_Process__c> children = mapParentVsChildren.get(op.Parent_Orchestration_Process__c);
                children.add(op);
            }
            else {
                List<CSPOFA__Orchestration_Process__c> children  = new List<CSPOFA__Orchestration_Process__c>();
                children.add(op);
                mapParentVsChildren.put(op.Parent_Orchestration_Process__c, children);
            }
        }
        System.debug('mapParentVsChildren = ' + mapParentVsChildren);

        // Main logic to determine parent updates
        Map<Id,String> mapParentToUpdate = new Map<Id,String>();
        for (CSPOFA__Orchestration_Process__c op : filteredRecords)
        {
            List<CSPOFA__Orchestration_Process__c> children = new List<CSPOFA__Orchestration_Process__c>(mapParentVsChildren.get(op.Parent_Orchestration_Process__c));
            System.debug('children = ' + children);

            // If all child records have the state = active and the status = complete
            // Set the parent overall cancellation status to complete
            if (children.isEmpty()) {
                mapParentToUpdate.put(op.Parent_Orchestration_Process__c, Constants.orchestrationProcessComplete);
            }
            
            // If all child records have the state = active and the status != complete
            // Set the parent overall cancellation status to pending                
            else {
                mapParentToUpdate.put(op.Parent_Orchestration_Process__c, Constants.orchestrationProcessPending);
            }
            System.debug('mapParentToUpdate = ' + mapParentToUpdate);
        }

        // DML
        List<CSPOFA__Orchestration_Process__c> opList = [SELECT Id FROM CSPOFA__Orchestration_Process__c WHERE Id IN : mapParentToUpdate.keySet()];
        System.debug('opList = ' + opList);
        for (CSPOFA__Orchestration_Process__c op : opList) {
                op.Overall_Cancellation_Status__c = mapParentToUpdate.get(op.Id);
        }
        update opList;
    }
}