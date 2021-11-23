global with sharing class CancelSubscriptionOrcestratorUtil {

    /*
    *   After evaluating the relationships between subscriptions will Activate the orchestration processes
    *   which are connected to subscriptions without any child subscriptions or connected to subscriptions with
    *   status cancelled 
    */    
    global class ActivateChildProcesses implements CSPOFA.ExecutionHandler {
        public List<SObject> process(List<sObject> steps) {
            List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>)steps;
            List<SObject> result = new List<sObject>();
            Set<Id> processIds = new Set<Id>();
            List<CSPOFA__Orchestration_Process__c> allToActiveOrchProcessList = new List<CSPOFA__Orchestration_Process__c>();
            
            if(!stepList.isEmpty()) {
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                   processIds.add(step.CSPOFA__Orchestration_Process__c);
                }
                System.debug('YY processIds : '+processIds);
                //Get the parent orchestration processes
                Map<Id, CSPOFA__Orchestration_Process__c> parentOrchProcessMap = new Map<Id, CSPOFA__Orchestration_Process__c>([SELECT Overall_Cancellation_Status__c, has_Inactive_Children__c,
                                                                                                                                CSPOFA__State__c, CSPOFA__Status__c, CSPOFA__Process_On_Hold__c
                                                                                                                                FROM CSPOFA__Orchestration_Process__c
                                                                                                                                WHERE Id IN :processIds]);
                
                System.debug('YY parentOrchProcessMap : '+parentOrchProcessMap);
                //Get the inactive child orchestration processes
                List<CSPOFA__Orchestration_Process__c> inActiveChildOrchProcessList = [SELECT CSPOFA__State__c, CSPOFA__Status__c, csordtelcoa__Subscription__c, Parent_Orchestration_Process__c,
                                                                                       CSPOFA__Process_On_Hold__c
                                                                                       FROM CSPOFA__Orchestration_Process__c 
                                                                                       WHERE Parent_Orchestration_Process__c IN :parentOrchProcessMap.keySet()
                                                                                       AND CSPOFA__State__c =: Constants.orchestrationProcess_STATE_INACTIVE
                                                                                       /* AND Name = '??' */];
                
                System.debug('YY inActiveChildOrchProcessList : '+inActiveChildOrchProcessList);
                //Build a list of SubscriptionIds related to inactive child processes
                List<Id> subIds = new List<Id>();
                for(CSPOFA__Orchestration_Process__c childOrch : inActiveChildOrchProcessList) {
                    subIds.add(childOrch.csordtelcoa__Subscription__c);
                }
                System.debug('YY Subscription Ids: ' + subIds);
                Map<Id, csord__Subscription__c> relatedSubscriptionMap = new Map<Id, csord__Subscription__c>([SELECT Id, Parent_Subscription__c, (SELECT Id FROM Subscriptions__r WHERE csord__Status__c != :Constants.subscriptionStatus_Cancel)
                                                                                                              FROM csord__Subscription__c
                                                                                                              WHERE Id IN : subIds]);
                
                System.debug('YY relatedSubscriptionMap: ' + relatedSubscriptionMap);
                //Create a Map of parent orchestration process to List of inactive child ochestration processes
                Map<Id, List<CSPOFA__Orchestration_Process__c>> parentProcessToInactiveChildProcessesMap = new Map<Id, List<CSPOFA__Orchestration_Process__c>>();
                for(CSPOFA__Orchestration_Process__c childProcess : inActiveChildOrchProcessList) {
                    Id parentProcessId = childProcess.Parent_Orchestration_Process__c;
                    List<CSPOFA__Orchestration_Process__c> inactiveChildList = new List<CSPOFA__Orchestration_Process__c>();
                    if(parentProcessToInactiveChildProcessesMap.keySet().contains(parentProcessId)) {
                        inactiveChildList = new List<CSPOFA__Orchestration_Process__c>(parentProcessToInactiveChildProcessesMap.get(parentProcessId));
                    }
                    
                    inactiveChildList.add(childProcess);
                    parentProcessToInactiveChildProcessesMap.put(parentProcessId, inactiveChildList);
                }
                
                System.debug('YY parentProcessToInactiveChildProcessesMap: ' + parentProcessToInactiveChildProcessesMap);
                
                //Set 'Has Inactive Children' and 'Overall Cancellation Status' fields on the parent ochestration processes
                for(Id pId : parentProcessToInactiveChildProcessesMap.keySet()) {
                    CSPOFA__Orchestration_Process__c parentOrchProcess = parentOrchProcessMap.get(pId);
                    List<CSPOFA__Orchestration_Process__c> inactiveChildList = new List<CSPOFA__Orchestration_Process__c>(parentProcessToInactiveChildProcessesMap.get(pId));
                    if(inactiveChildList.isEmpty()) {
                        parentOrchProcess.has_Inactive_Children__c = 'No';
                    }
                    else {
                        parentOrchProcess.Overall_Cancellation_Status__c = Constants.orchestrationProcessPending;
                        
                        //Activate child processes related to subscriptions which do not have dependent subscriptions or which's 
                        //dependent subscriptions are all already cancelled
                        List<CSPOFA__Orchestration_Process__c> activeOrchProcessList = CancelSubscriptionOrcestratorUtil.activateChildProcesses(inactiveChildList, relatedSubscriptionMap);
                        System.debug('YY ActiveOrchProcessList: ' + activeOrchProcessList);
                        allToActiveOrchProcessList.addAll(activeOrchProcessList);
                        System.debug('YY AllToActiveOrchProcessList: ' + allToActiveOrchProcessList);
                        if(inactiveChildList.size() > activeOrchProcessList.size()) {                           
                            parentOrchProcess.has_Inactive_Children__c = 'Yes';
                        }
                        else {
                            parentOrchProcess.has_Inactive_Children__c = 'No';
                        }
                    }
                }
                
                //Save the parent and child process field changes
                System.debug('YY AllToActiveOrchProcessList: ' + allToActiveOrchProcessList);
                System.debug('YY ParentOrchProcesses: ' + parentOrchProcessMap.values());
                List<CSPOFA__Orchestration_Process__c> allOrchProcessesToUpdate = new List<CSPOFA__Orchestration_Process__c>();
                allOrchProcessesToUpdate.addAll(parentOrchProcessMap.values());
                allOrchProcessesToUpdate.addAll(allToActiveOrchProcessList);
                update allOrchProcessesToUpdate;
            }
            
            
            //Mark the steps as complete
            result = OrchestratorStepUtility.setOrchestratorStepValues(stepList, Constants.orchestrationProcessComplete);
            return result;
        }               
    }
    
    private static List<CSPOFA__Orchestration_Process__c> activateChildProcesses(List<CSPOFA__Orchestration_Process__c> orchProcess, Map<Id, csord__Subscription__c> relatedSubscriptions) {
        List<CSPOFA__Orchestration_Process__c> toBeActiveProcessList = new List<CSPOFA__Orchestration_Process__c>(); 
        
        for(CSPOFA__Orchestration_Process__c inactiveOrchProcess : orchProcess) {
            System.debug('YY InactiveOrchProcess: ' + inactiveOrchProcess);
            csord__Subscription__c relatedSubscription = relatedSubscriptions.get(inactiveOrchProcess.csordtelcoa__Subscription__c);
            System.debug('YY RelatedSubscription: ' + relatedSubscription);
            
            if(relatedSubscription != null) {
                List<csord__Subscription__c> dependentSubscriptionList = new List<csord__Subscription__c>(relatedSubscription.Subscriptions__r);
                System.debug('YY Dependent Subscription List: ' + dependentSubscriptionList);
                
                if(dependentSubscriptionList.isEmpty()) {
                    inactiveOrchProcess.CSPOFA__Process_On_Hold__c = FALSE;
                    inactiveOrchProcess.CSPOFA__State__c = Constants.orchestrationProcessActive;
                    toBeActiveProcessList.add(inactiveOrchProcess);
                }
            }
        }
        
        return toBeActiveProcessList;       
    }
}