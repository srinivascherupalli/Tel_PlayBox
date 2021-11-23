/**
*  Purpose          :   This class is used to update service specifications attachment under Services which are initiated through Step.
*  
*  Author          :   Gaurang Maheshwari
* 
*  Created Date    :   16 June 2020
* 
*  Current Version :   V_1.0
* 
*  Revision Log    :   V_1.0 - Gaurang Maheshwari (16 June 2020) - Created/Optimised
  
  Prajakta        10/11/2020       EDGE-174930
*/
global with sharing class Orchestration_UpdateSrvcSpecToInProgress extends Orchestration_AbstractStepHandler {
    
    private List<CSPOFA__Orchestration_Step__c> stepList= new List<CSPOFA__Orchestration_Step__c>();
  
  private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    
    private Map<Id, Orchestration_AttachmentWrapper> mapServiceAttachment = new Map<Id, Orchestration_AttachmentWrapper>();
    
    public override List<SObject> process(List<SObject> data){
        
        try {
            if(Orchestration_LimitsUtility.areLimitsViolated()){        
                system.debug('stopping execution as limit breached.....');
                return null;
            }
            
            stepList= getStepList(data);
      getRelatedServiceIds(stepList);
      
      for(Attachment specAttachment : [SELECT Id, Name, body, ParentId FROM Attachment WHERE ParentId IN :serviceIds AND name =: OrchestratorConstants.DataOrchestrationNames.service]) {
                mapServiceAttachment.put(specAttachment.ParentId, new Orchestration_AttachmentWrapper(specAttachment.Id, specAttachment.body));
                
            }
            for(CSPOFA__Orchestration_Step__c step : stepList) {

                try {
          if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c == null ) {
            stepResults.put(step.Id, new stepResult('Error: Step do not have a related service record', OrchestratorConstants.OrchestratorStep.Error));
            continue;
          }
                    //Check if any limits hit then return execution
                    if(Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()){        
                        break;
                    }
          
          if(mapServiceAttachment.containsKey(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c)) {
                        Attachment UpdatedServSpec = new Attachment( Id = mapServiceAttachment.get(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c).attchId); 
                        String attbody = mapServiceAttachment.get(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c).attchBody.toString();
             // EDGE-174930 start
              Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(attbody);
              Map<String,String>statusMap; String currentStatus;
             if (results.containsKey('specifications')) {
                List<Object> lstSpecifications = (List<Object>) results.get('specifications');
                system.debug('lstSpecifications:'+lstSpecifications);
                Map<String, Object> specificationAttributes = new Map<String, Object>();
                for (Object specification : lstSpecifications) {
                            
                    specificationAttributes = (Map<String, Object>) specification;
                    system.debug('specificationAttributes:'+specificationAttributes);
                    Map<String, Object> tempAttMap = new Map<String, Object>();
                    String target;
                    if (specificationAttributes.containsKey(OrchestratorConstants.ServiceSpecificationKey.Attributes)) {
                    Map<String, Object> attributesMap = (Map<String, Object>) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Attributes);
                    system.debug('attributesMap:'+attributesMap);
                    target = String.valueOf(attributesMap.get(OrchestratorConstants.ServiceSpecificationKey.TargetSystem));
                    }
                   /* if (specificationAttributes.containsKey('attributes')) {
                    tempAttMap = (Map<String, Object>) specificationAttributes.get('attributes');
                    }*/
                   // system.debug('tempAttMap:'+tempAttMap);
                
                    if (!String.IsBlank(target) && target.equals('FULFILMENT')) {
                        for(String spec :specificationAttributes.keyset()){
                           if ((specificationAttributes.containsKey('status') )) {
                                
                                currentStatus= (String)specificationAttributes.get('status');
                                system.debug('currentStatus:'+currentStatus);
                           }
                        }
                    }
                }       
            }   
                
            if(currentStatus!='Complete'){              // EDGE-174930 end
             system.debug('inside if');
            String udtattbody = Orchestration_Utility.updateSpecStatus(attbody, 'status', Label.MO_status_in_progress);
            if(udtattbody!= '' && udtattbody != 'false'){
              UpdatedServSpec.Body = Blob.valueOf(udtattbody);
              sObjectsToUpdate.put(UpdatedServSpec.Id, UpdatedServSpec);
              stepRelationship.put(UpdatedServSpec.Id, step.Id);
              
            }}
           else{
              stepResults.put(step.Id, new stepResult('Success - No update required as no spec found for status update', OrchestratorConstants.OrchestratorStep.Complete));
            }  
            
          }  else {

                        stepResults.put(step.Id, new StepResult('Success: No specication JSON attachment found', OrchestratorConstants.OrchestratorStep.Complete));
                    }  
            }  catch(Exception ex) {

                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }

            if(sObjectsToUpdate.size() > 0) {

                updateObjects();
            }
    } catch(Exception ex) {
            for(CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) data) {
                    
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        return processStepResults(stepList, stepResults);
    }
  
  public override void updateObjects() {
    //Updating all the records including orders and subscription
    Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
    //Storing the records
    for (Database.SaveResult rslt : updateResult) {
      //stepRelationship will contain only subscription therefore avoiding updated order records
      //if(stepRelationship.containsKey(rslt.getId())){
      if (rslt.isSuccess()) {
        stepResults.put(stepRelationship.get(rslt.getId()),  new stepResult('Success: specification statuses updated', OrchestratorConstants.OrchestratorStep.Complete));
      } else {
        //record updation failed there related step updated
        stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to process records as DML failed', OrchestratorConstants.OrchestratorStep.Error));
      }
    }
  }
}