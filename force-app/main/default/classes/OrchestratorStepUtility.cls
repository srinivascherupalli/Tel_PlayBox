global class OrchestratorStepUtility {
    
    /*
    *   Given a list of CSPOFA__Orchestration_Step__c object records will set the status of ALL steps to the provided stepStatus and return the updated in-memory list.
    */
    public static List<CSPOFA__Orchestration_Step__c> setOrchestratorStepValues(List<CSPOFA__Orchestration_Step__c> stepList, String stepStatus) {
        for(CSPOFA__Orchestration_Step__c step: stepList) {
            step.CSPOFA__Status__c = stepStatus;
        }
        return stepList;
   }
}