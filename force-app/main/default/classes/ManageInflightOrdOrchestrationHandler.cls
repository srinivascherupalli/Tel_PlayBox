/*************************************************************************************
Name: ManageInflightOrdOrchestrationHandler
Description: This class created as part of EDGE-170463, to create orchestration process for Inflight orders
************************************************************************************/

public with sharing class ManageInflightOrdOrchestrationHandler{
    
public static void createOrchestrationProcess(List<String> orderIds){
   List<String> orchestrationProcessesList = new List<String>{
    OrchestratorConstants.OrchesTemplateName.inflightOrderTemplate
  };    
Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = Orchestration_Utility.getOrchestrationTemplates(orchestrationProcessesList);   
List<CSPOFA__Orchestration_Process__c> inflightOrchesList = new List<CSPOFA__Orchestration_Process__c>();

if(orderIds != null && orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.inflightOrderTemplate) != null){
    For(Id orderId : orderIds){
        CSPOFA__Orchestration_Process__c inflightOrches = new CSPOFA__Orchestration_Process__c();
        inflightOrches.CSPOFA__State__c = OrchestratorConstants.OrcehstrationProcessState.Active;
        inflightOrches.Order__c = orderId;
        inflightOrches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.inflightOrderTemplate).id;
        inflightOrchesList.add(inflightOrches);
    }
}
    
if(!inflightOrchesList.isEmpty() && inflightOrchesList.size() > 0){
        Database.insert(inflightOrchesList);

}   
    
}

}