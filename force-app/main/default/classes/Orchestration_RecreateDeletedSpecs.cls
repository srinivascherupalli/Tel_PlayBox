/**================================================================
 * Appirio, Inc
 * Name: Orchestration_RecreateDeletedSpecs
 * Description: Gets all the Attachments of the order's services and adds some spec to the attachment
 * Created Date: May 19, 2020
 * Created By: Martand Atrey
 1. Prajakta 19/05/2021   Bulk Fix/partial processing 
 ==================================================================*/

 global with sharing class Orchestration_RecreateDeletedSpecs extends Orchestration_AbstractStepHandler {
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
  private Map<Id, Set<string>> stepServiceMap = new Map<Id, Set<String>>(); //Bulk Fix
    private Map<Id, Orchestration_AttachmentWrapper> attchmap;
    //private Map<Id, Attachment> currentAttchmap;
    private Id incompleteStepId;
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
  private Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
  private  Set<String> toSkipsvcid = new Set<String>(); //Bulk Fix


    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            return null;
        }
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            //system.debug('exception not found a---???'+stepList[0].CSPOFA__Orchestration_Process__r.Order__r.Name);
            //Order Id Vs LIst Of Services
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
            attchmap = new Map<Id, Orchestration_AttachmentWrapper>();
            //currentAttchmap = new Map<Id, Attachment>();
            List<Id> originServiceIds = new List<Id>();
            Map<Id, List<csord__Service__c>> orderServiceRelationMap = new Map<Id, List<csord__Service__c>>();
            system.debug('heap check + CPU Check '+limits.getHeapSize()+'=='+limits.getCpuTime());
      
      for(CSPOFA__Orchestration_Step__c step1 : stepList) //Bulk Fix
            {
        processedRecordIds = getProcessedRecords(step1);
                    if (processedRecordIds != null) {
                        processedIds.put(step1.Id, processedRecordIds);
            if(processedRecordIds != null  ){
              if(processedRecordIds.serviceIds != null){
                toSkipsvcid.addAll(processedRecordIds.serviceIds);
              }
              
            }
            
                    }
            }
      
      
            if (!orderIds.isEmpty()) {
                serviceMap = new Map<Id, csord__Service__c>(
                    [
                        SELECT
                            Id,
                            Name,
                            csord__Order__c,
                            csordtelcoa__Product_Configuration__c,
                            csordtelcoa__Replaced_Service__c,
                            toBeCancelled__c,
                            csord__Status__c,
                            csord__Order_Request__c,
                            csordtelcoa__Service_Number__c,
                            csord__Subscription__c,
                            csordtelcoa__Replaced_Service__r.csord__Status__c,
                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,
                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c,
                            CreatedDate
                        FROM csord__Service__c
                        WHERE csord__Order__c IN :orderIds AND csordtelcoa__Replaced_Service__c != null AND (Id NOT IN : toSkipsvcid)

                    ]
                );
            }

            if (!serviceMap.isEmpty()) {
                //Create map of order vs List of service and collect all the replaced services
                for (csord__Service__c service : serviceMap.Values()) {
                    originServiceIds.add(service.csordtelcoa__Replaced_Service__c);
                    if (orderServiceRelationMap.get(service.csord__Order__c) == null) {
                        orderServiceRelationMap.put(service.csord__Order__c, new List<csord__Service__c>{ service });
                    } else {
                        orderServiceRelationMap.get(service.csord__Order__c).add(service);
                    }
                }
            } else {
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    stepResults.put(step.Id, new stepResult('Success - No Updation as no services found.', OrchestratorConstants.OrchestratorStep.Complete));
                }
                return processStepResults(stepList, stepResults);
            }
            system.debug('heap check + CPU Check 2 '+limits.getHeapSize()+'=='+limits.getCpuTime());
            // //Create a Map of step vs Order
            // for(CSPOFA__Orchestration_Step__c step : stepList){
            //     stepRelationship.put(step.CSPOFA__Orchestration_Process__r.Order__c, step.Id,);
            // }

            //Create a map of service vs Attachment
            for (Attachment newAtt : [
                SELECT ID, name, body, parentId
                FROM Attachment
                WHERE (parentId IN :serviceMap.keySet() OR parentId IN :originServiceIds) AND name = :OrchestratorConstants.DataOrchestrationNames.service
            ]) {
                attchmap.put(newAtt.parentId, new Orchestration_AttachmentWrapper(newAtt.Id, newAtt.body));
                /*if (serviceMap.keySet().contains(newAtt.parentId)) {
                    currentAttchmap.put(newAtt.parentId, newAtt);
                }*/
            }
            system.debug('heap check + CPU Check 3 '+limits.getHeapSize()+'=='+limits.getCpuTime());
            serviceMap.clear();
            originServiceIds.clear();
            system.debug('heap check + CPU Check 4 '+limits.getHeapSize()+'=='+limits.getCpuTime());
            //CHANGED If Attachment Empty Dont Process the Steps
            if (!attchmap.isEmpty()) {
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    try {
                        //system.debug('exception not found b---???');
                        //system.debug('exception not found---???'+step.CSPOFA__Orchestration_Process__r.Order__r.Name);
                        if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                            //Updating steps as Error since no proper data linked to step
                            stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
                            //Check the next step
                            continue;
                        }

                        Id orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
                        if (!Orchestration_LimitsUtility.areLimitsViolated()) {
                            //Populate all the record Ids that are processed already
                            /*Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);

                            if (processedRecordIds != null) {
                                processedIds.put(step.Id, processedRecordIds);
                            }*/
              
                            incompleteStepId = recreateDeletedSpecs(step.Id, orderServiceRelationMap.get(orderId));
                            
                            if (incompleteStepId != null) {
                                break;
                            } else if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepResults.put(
                                    step.Id,
                                    new stepResult('Success - No update required as no services found with deleted specs', OrchestratorConstants.OrchestratorStep.Complete)
                                );
                            }
                        } else {
                            break;
                        }
                    } catch (exception ex) {
                        //system.debug('exception found---???'+ex.getMessage());
                        stepResults.put(
                            step.Id,
                            new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                        );
                    }
                }
            } else {
                for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                    stepResults.put(step.Id, new stepResult('Success - There are No Attachments', OrchestratorConstants.OrchestratorStep.Complete));
                    return processStepResults(stepList, stepResults);
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(
                    step.Id,
                    new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                );
            }
        }

        if (!sObjectsToUpdate.isEmpty() || !stepServiceMap.isEmpty()) {
            updateObjects();
        }
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    public Id recreateDeletedSpecs(Id stepId, List<csord__Service__c> services) {
        if (services != null) {
            //CHANGED Removed the AttMap condition to main LOOP
            for (csord__Service__c srv : services) {
                if (!Orchestration_LimitsUtility.areLimitsViolated() && !hasDMLRowsLimitExceeded()) {
                    if (srv.csordtelcoa__Replaced_Service__c != null && attchmap.get(srv.csordtelcoa__Replaced_Service__c) != null && attchmap.get(srv.id) != null) {
                        //System.debug(attchmap.get(srv.Id).Id +  '===>attchmap.get(srv.Id).Id');
                        //System.debug(processedIds.get(stepId).attachmentIds.contains(attchmap.get(srv.Id).Id) +  '===>processedIds.get(stepId).attachmentIds.contains(attchmap.get(srv.Id).Id)');

                        if (
                            !(processedIds.get(stepId) != null &&
                            processedIds.get(stepId).attachmentIds != null &&
                            processedIds.get(stepId).attachmentIds.contains(attchmap.get(srv.Id).attchId)) &&
              !(processedIds.get(stepId)!= null && processedIds.get(stepId).serviceIds!= null &&  processedIds.get(stepId).serviceIds.contains(srv.id))
                        ) {
                            //Get The Attachment of the origin Service
                            String serviceattachmentstr = attchmap.get(srv.csordtelcoa__Replaced_Service__c).attchBody.toString();
                            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
                            List<Object> lstSpecifications = (List<Object>) results.get(OrchestratorConstants.ServiceSpecificationKey.Specifications);
                            List<Object> deletedListSpecifications = new List<Object>();
                            Set<String> newSpecSet = new Set<String>();
                            /*List<CS_SpecificationDTO.ServiceSpecification> subSpecCurrent = new List<CS_SpecificationDTO.ServiceSpecification>();
                        subSpecCurrent.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(currentAttchmap.get(srv.Id)),'FULFILMENT'));
                        subSpecCurrent.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(currentAttchmap.get(srv.Id)),'BILLING'));
                        subSpecCurrent.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(currentAttchmap.get(srv.Id)),'ASSURANCE'));
                        for(CS_SpecificationDTO.ServiceSpecification specs :subSpecCurrent){
                            newSpecSet.add(specs.guid);
                        }*/
                            //get Attachment of the current Service
                            String newServiceAttachmentStr = attchmap.get(srv.id).attchBody.toString();
                            Map<String, Object> updatedResults = (Map<String, Object>) JSON.deserializeUntyped(newServiceAttachmentStr);
                            List<Object> newlstSpecifications = (List<Object>) updatedResults.get(OrchestratorConstants.ServiceSpecificationKey.Specifications);
                            if (newlstSpecifications != null) {
                                for (Object specification : newlstSpecifications) {
                                    Map<String, Object> specificationAttributes = (Map<String, Object>) specification;
                                    newSpecSet.add((String) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Guid));
                                }
                            }
                            if (lstSpecifications != null) {
                                string EDMSpecToSuppressInRTB = srv.csordtelcoa__Product_Configuration__c != NULL && srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != NULL && srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c != NULL ? srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c:'';
                                for (Object specification : lstSpecifications) {
                                    string code = '';
                                    string guid = '';
                                    string name = '';
                                    Map<String, Object> specificationAttributes = (Map<String, Object>) specification;
                                    guid = (String) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Guid);
                                    name = (String) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Name);
                                    if (!newSpecSet.contains(guid) && !EDMSpecToSuppressInRTB.contains(name)) {
                                    deletedListSpecifications.add(specification);
                                    }                                    
                                     
                                }
                            }

                            if (deletedListSpecifications.isEmpty()) {
                                    if (!stepServiceMap.containsKey(stepId)) {
                                    stepServiceMap.put(stepId, new Set<String>{ srv.Id }); //Bulk Fix
                                    } else {
                                    stepServiceMap.get(stepId).add(srv.Id); }//Bulk Fix
                                   
                                   if (!stepRelationshipMap.containsKey(stepId)) {
                                     stepRelationshipMap.put(stepId,  new Set<Id>{ srv.Id });
                                   } else {
                                   stepRelationshipMap.get(stepId).add(srv.id);}
                                  
                                continue;
                            }

                            for (Object deletedSpec : deletedListSpecifications) {
                                Map<String, Object> specificationAttributes = (Map<String, Object>) deletedSpec;
                                specificationAttributes.put(OrchestratorConstants.ServiceSpecificationKey.Status, OrchestratorConstants.ServiceSpecsStatus.DisconnectPending);
                                specificationAttributes.put(OrchestratorConstants.ServiceSpecificationKey.ProductConfigurationId, srv.csordtelcoa__Product_Configuration__c);
                                newlstSpecifications.add((Object) specificationAttributes);
                            }
                            updatedResults.put(OrchestratorConstants.ServiceSpecificationKey.Specifications, newlstSpecifications);
                            String updatednewServiceattachmentstr = JSON.serializePretty(updatedResults);
                            Attachment UpdatedServSpec = new Attachment(Id = attchmap.get(srv.Id).attchId );
                            UpdatedServSpec.Body = Blob.valueOf(updatednewServiceattachmentstr);
                            sObjectsToUpdate.put(UpdatedServSpec.Id, UpdatedServSpec);
                            if (!stepRelationshipMap.containsKey(stepId)) {
                                stepRelationshipMap.put(stepId, new Set<Id>{ UpdatedServSpec.Id });
                stepServiceMap.put(stepId, new Set<String>{ srv.Id }); //Bulk Fix
                            } else {
                                stepRelationshipMap.get(stepId).add(UpdatedServSpec.Id);
                stepServiceMap.get(stepId).add(srv.Id); //Bulk Fix
                            }
                        }
                    }
                } else {
                    return stepId;
                }
            }
        } else {
            //Update the step with Status Success when no services were found under Order
            stepResults.put(stepId, new stepResult('Success: No Updation as no services found.', OrchestratorConstants.OrchestratorStep.Complete));
        }
        return null;
    }

    public override List<sObject> getStepList(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();

        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT
                ID,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                JSON__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
                CSPOFA__Orchestration_Process__r.cspofa__account__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                CSPOFA__Orchestration_Process__r.Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        //system.debug(stepList[0].CSPOFA__Orchestration_Process__r.Name);
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                OrderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }

            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);
            }
        }

        //Check if attachments is required
        if (stepIds.size() > 0) {
            getAttachmentList(stepIds);
        }

        return stepList;
    }

    //Generic Method implemented in AbstractStepHandler
    /*public override void updateObjects() {
        //Updating all the records including orders and subscription
        Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        //Storing the records
        for (Database.SaveResult rslt : updateResult) {
            String stepId = stepRelationship.get(rslt.getId());

            if (processedIds.get(stepId) == null) {
                processedIds.put(stepId, new Orchestration_ProcessedRecords());
            }
            if (processedIds.get(stepId).attachmentIds == null) {
                processedIds.get(stepId).attachmentIds = new Set<String>();
            }

            if (rslt.isSuccess()) {
                //This will add the success IDs to the Wrapper
                processedIds.get(stepId).attachmentIds.add(rslt.getId());

                if (incompleteStepId != null && incompleteStepId.equals(stepId)) {
                    stepResults.put(
                        stepId,
                        new stepResult('Partial Success: Partial Records processed', OrchestratorConstants.OrchestratorStep.InProgress, processedIds.get(stepId))
                    );
                } else {
                    stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                }
            } else {
                //record updation failed there related step updated
                if (stepResults.containsKey(stepId)) {
                    stepResults.get(stepId).status = OrchestratorConstants.OrchestratorStep.Error;
                    stepResults.get(stepId).message = 'Error: Unable to process records.';
                } else {
                    stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, processedIds.get(stepId)));
                }
            }
        }
    }*/
    public override void updateObjects() {
        //Updating all the records including orders and subscription
        Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        //Storing the records
        List<Id> attachmentSuccessIds = new List<Id>();
        List<String> skipIds = new List<String>();
        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                attachmentSuccessIds.add(rslt.getId());
            }
        }
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the attachmentIds Set
            perStepSuccessIds.attachmentIds = new Set<String>();
             perStepSuccessIds.serviceIds = new Set<String>();
            Boolean isFailed = false;

            if(!stepServiceMap.isEmpty() && stepId!= null &&  stepServiceMap.get(stepId)!= null){
            skipIds.addAll(stepServiceMap.get(stepId));}


            for (Id recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                if (attachmentSuccessIds.contains(recId)) {
                    perStepSuccessIds.attachmentIds.add(recId);
                }
                else if (!(attachmentSuccessIds.contains(recId) || skipIds.contains(recId)) ) {
                    ////Partial Proccessing - added check for skipIds as well
                    //Failure
                    isFailed = true;
                }
                
            }
      
            if(!stepServiceMap.isEmpty() && stepId!= null &&  stepServiceMap.get(stepId)!= null){ // Bulk Fix
      
                List<string> serId = new List<string>(stepServiceMap.get(stepId));
        perStepSuccessIds.serviceIds.addAll(serId);
      }
              System.debug('incompleteStepId '+incompleteStepId);
            System.debug('stepId '+stepId);
            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }

            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).attachmentIds != null) {
                perStepSuccessIds.attachmentIds.addAll(processedIds.get(stepId).attachmentIds);
            }

        if (processedIds.containsKey(stepId) && processedIds.get(stepId).serviceIds != null) { //Bulk Fix
                perStepSuccessIds.serviceIds.addAll(processedIds.get(stepId).serviceIds);
            }

            if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
            }
        }
    }
}