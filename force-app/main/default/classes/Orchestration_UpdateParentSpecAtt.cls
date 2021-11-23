/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateParentSpecAtt
 * Description: Class to update Attachments with some additionalattributes
 * Created Date: June 16, 2020
 * Created By: Martand Atrey
 * Sr.No.    Developer Name        Date          Description
    1.        Gnana          08/06/2021      EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
 ==================================================================*/
global with sharing class Orchestration_UpdateParentSpecAtt extends Orchestration_AbstractStepHandler {
  private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
  private Id incompleteStepId;
  private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
  private Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>();
  // private Map<Id, Orchestration_AttachmentWrapper> serviceSpecAttachmentMap = new Map<Id, Orchestration_AttachmentWrapper>();
  private Map<Id, List<Orchestration_AttachmentWrapper>> orderAttachmentMap = new Map<Id, List<Orchestration_AttachmentWrapper>>();

  public override List<sObject> process(List<sObject> steps) {
    List<SObject> sobjList=new List<SObject>();// Added as part of EDGE-222326
    if (Orchestration_LimitsUtility.areLimitsViolated()) {
      system.debug('stopping execution as limit breached.....');
      //return null;// Commented as part of EDGE-222326
      return sobjList;// Added as part of EDGE-222326
    }
    Set<Id> oppIdSet = new Set<Id>();
    List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
    System.debug('before main block ' + limits.getCPUTime() + '  ' + limits.getHeapSize());
    try {
      stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
      getRelatedOrderIds(stepList);
      for (csord__Order__c order : [SELECT ID, Scenario_Type__c, csord__Account__c, csordtelcoa__Opportunity__c, csord__Order_Request__c FROM csord__Order__c WHERE Id IN :orderIds AND csordtelcoa__Opportunity__c != null]) {
        if (order.csordtelcoa__Opportunity__c != null) {
          oppIdSet.add(order.csordtelcoa__Opportunity__c);
        }
      }

            if (oppIdSet.isEmpty()) {
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    stepResults.put(step.Id, new StepResult('Success: No Opportunities Found.', OrchestratorConstants.OrchestratorStep.Complete));
                }
                return processStepResults(stepList, stepResults);
            }

            //For CreateRelationShip
            servicesMap = new Map<Id, csord__Service__c>(
                [
                    SELECT Id, csord__Order__r.csordtelcoa__Opportunity__c, csord__Order__c, csord__Subscription__c
                    FROM csord__Service__c
                    WHERE csord__Order__r.csordtelcoa__Opportunity__c IN :oppIdset
                ]
            );
/* 
            for (csord__Service__c service : servicesMap.values()) {
                //Store Order vs Services
                 if (orderServiceMap.containsKey(service.csord__Order__c)) {
                    orderServiceMap.get(service.csord__Order__c).add(service.Id);
                } else {
                    orderServiceMap.put(service.csord__Order__c, new Set<Id>{ service.Id });
                } 
            } */

            //Get all attachments for processing
            for (Attachment att : [
                SELECT id,Name , body, parentId
                FROM Attachment
                WHERE parentId IN :servicesMap.keySet() AND name = :OrchestratorConstants.DataOrchestrationNames.service
            ]) {
                Id orderId = servicesMap.get(att.ParentId).csord__Order__c;
               // serviceSpecAttachmentMap.put(att.ParentId, new Orchestration_AttachmentWrapper(att.Id, att.Name, att.Body, att.ParentId));

                if (orderAttachmentMap.containsKey(orderId)) {
                    orderAttachmentMap.get(orderId).add(new Orchestration_AttachmentWrapper(att.Id, att.Name, att.Body, att.ParentId));
                } else {
                    orderAttachmentMap.put(orderId, new List<Orchestration_AttachmentWrapper>{ new Orchestration_AttachmentWrapper(att.Id, att.Name, att.Body, att.ParentId) });
                } 
            }

            System.debug('===> Starting Main Process');
            System.debug('after main block '+limits.getCPUTime()+'  '+limits.getHeapSize());

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have Order.', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    if (step.CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c == null) {
                        stepResults.put(step.Id, new stepResult('Success: Order do not have Opportunity.', OrchestratorConstants.OrchestratorStep.Complete));
                        continue;
                    }

                    Id orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    Map<String, String> specificationGUIDMap = new Map<String, String>();
                    Map<String, String> specificationGUIDOppMap = new Map<String, String>();
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    Set<String> tempAttId = new Set<String>();
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                        tempAttId = processedRecordIds.attachmentIds;
                    }
                    List<Orchestration_AttachmentWrapper> attWrapperList = new List<Orchestration_AttachmentWrapper>();


                    System.debug('before data for block '+limits.getCPUTime()+'  '+limits.getHeapSize());
                    for (Orchestration_AttachmentWrapper attWrapper : orderAttachmentMap.get(orderId)) {
                        csord__Service__c service = servicesMap.get(attWrapper.ParentId);
                        if(!tempAttId.contains(attWrapper.attchId)){
                            attWrapperList.add(attWrapper);
                        }
                        CS_ServiceSpecificationV3 servSpecs = (CS_ServiceSpecificationV3) system.JSON.deserialize(attWrapper.attchBody.toString(),CS_ServiceSpecificationV3.class);                        

                        for (CS_ServiceSpecificationV3.ServiceSpecifications specification : servSpecs.specifications) {
                            // now get attributes for this specification.
                            string code = specification.Code;
                            string guid = specification.Guid;

                            String specificationKeyForMap = code + '-' + service.csord__Subscription__c;
                            specificationGUIDMap.put(specificationKeyForMap, guid);

                            specificationKeyForMap = code + '-' + service.csord__Order__r.csordtelcoa__Opportunity__c;
                            specificationGUIDOppMap.put(specificationKeyForMap, guid);
                        }
                    }
                    orderAttachmentMap.get(orderId).clear();
                                        System.debug('after data for block '+limits.getCPUTime()+'  '+limits.getHeapSize());


                //    (processedRecordIds != null && processedIds.get(stepId).attachmentIds != null);
                //     tempAttProcessedIds = processedIds.get(step.Id)

                    if ((!specificationGUIDMap.isEmpty() || !specificationGUIDOppMap.isEmpty()) && !attWrapperList.isEmpty()) {
                        incompleteStepId = updateSpecsAttibutes(step.Id, attWrapperList, specificationGUIDMap, specificationGUIDOppMap);
                    } else {
                        stepResults.put(step.Id, new stepResult('Success - No update required', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                    if (incompleteStepId != null) {
                        break;
                    } else if (!stepRelationshipMap.containsKey(step.Id)) {
                        stepResults.put(step.Id, new stepResult('Success - No update required', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                } catch (Exception ex) {
                    System.debug('ex.getLineNumber() ' + ex.getLineNumber());
                    stepResults.put(
                        step.Id,
                        new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                    );
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
        System.debug('sObjectsToUpdate data for block '+limits.getCPUTime()+'  '+limits.getHeapSize() + sObjectsToUpdate.values().size());
        if (!sObjectsToUpdate.isEmpty()) {
            updateObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    public Id updateSpecsAttibutes(Id stepId, List<Orchestration_AttachmentWrapper> attWrapperList, Map<String, String> specificationGUIDMap, Map<String, String> specificationGUIDOppMap) {
        Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
        //update children with parent guids and update through attsMapToUpdate
        System.debug('before dml method for block %%%%%'+limits.getCPUTime()+'  '+limits.getHeapSize());
        for (Orchestration_AttachmentWrapper attWrapper : attWrapperList) {

                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                    return stepId;
                }

                String serviceattachmentstr = attWrapper.attchbody.toString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
                List<Object> lstSpecifications = (List<Object>) results.get('specifications');
                Boolean attachmentChanged = false;
                if (lstSpecifications != null) {
                    for (Object specification : lstSpecifications) {
                        Map<String, String> additionalAttrs = new Map<String, String>();

                        Map<String, Object> specificationAttributesMap = (Map<String, Object>) specification;
                        Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributesMap.get('attributes');

                        //Create the Relationship
                        for (String currAtt : attributesPropertyInSpecification.keySet()) {
                            if (currAtt != null && currAtt != '' && attributesPropertyInSpecification.get(currAtt) instanceof String) {
                                String currentAttributeValue = (String) attributesPropertyInSpecification.get(currAtt);
                                if (currentAttributeValue != null && currentAttributeValue != '' && currentAttributeValue.contains('DMCAT_ProductSpecification')) {
                                    csord__Service__c service = servicesMap.get(attWrapper.parentId);
                                    String specificationKeyForMap = currentAttributeValue + '-' + service.csord__Subscription__c;
                                    String specificationKeyForOppMap = currentAttributeValue + '-' + service.csord__Order__r.csordtelcoa__Opportunity__c;
                                    if (specificationGUIDMap.get(specificationKeyForMap) != null && specificationGUIDMap.get(specificationKeyForMap) != '') {
                                        additionalAttrs.put(currAtt, specificationGUIDMap.get(specificationKeyForMap));
                                    } else if (specificationGUIDOppMap.get(specificationKeyForOppMap) != null && specificationGUIDOppMap.get(specificationKeyForOppMap) != '') {
                                        additionalAttrs.put(currAtt, specificationGUIDOppMap.get(specificationKeyForOppMap));
                                    }
                                }
                            }
                        }
                        if (!additionalAttrs.isEmpty()) {
                            //this check is added here to see if the attachment updation is required.
                            if (hasDMLRowsLimitExceeded()) {
                                return stepId;
                            }
                            attachmentChanged = true;

                            if (specificationAttributesMap.get('additionalAttributes') != null) {
                                Map<String, Object> tempAdditionalAttMap = (Map<String, Object>) specificationAttributesMap.get('additionalAttributes');
                                tempAdditionalAttMap.putall(additionalAttrs);
                                specificationAttributesMap.put('additionalAttributes', tempAdditionalAttMap);
                            } else {
                                specificationAttributesMap.put('additionalAttributes', additionalAttrs);
                            }
                        }
                    }
                }
                if (attachmentChanged) {
                    attWrapper.attchbody = Blob.valueOf(JSON.serialize(results));
                    sObjectsToUpdate.put(attWrapper.attchId, new Attachment(Id = attWrapper.attchId, Body = attWrapper.attchbody));
                    if (!stepRelationshipMap.containsKey(stepId)) {
                        stepRelationshipMap.put(stepId, new Set<Id>{ attWrapper.attchId });
                    } else {
                        stepRelationshipMap.get(stepId).add(attWrapper.attchId);
                    }
                }
        }
        return null;
    }

    public override void updateObjects() {
        //Updating all the records including orders and subscription
        Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        //Storing the records
        List<Id> attachmentSuccessIds = new List<Id>();
        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                attachmentSuccessIds.add(rslt.getId());
            }
        }
        System.debug('uodateblock data for block '+limits.getCPUTime()+'  '+limits.getHeapSize() + sObjectsToUpdate.values().size());
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the attachmentIds Set
            perStepSuccessIds.attachmentIds = new Set<String>();
            Boolean isFailed = false;

            for (Id recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                if (attachmentSuccessIds.contains(recId)) {
                    perStepSuccessIds.attachmentIds.add(recId);
                } else {
                    //Failure
                    isFailed = true;
                }
            }

            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }

            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).attachmentIds != null) {
                perStepSuccessIds.attachmentIds.addAll(processedIds.get(stepId).attachmentIds);
            }

            if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
            }
        }
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
                CSPOFA__Orchestration_Process__r.Order__c,
                CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];

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
}