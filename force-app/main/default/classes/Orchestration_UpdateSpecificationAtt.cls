/**================================================================
* Appirio, Inc
* Name: Orchestration_UpdateSpecificationAtt
* Description: Update the Specifications in the Attachments
* Created Date: May 22, 2020
* Created By: Martand Atrey
Sr.No.    Developer Name        Date          Description
    1         Martand Atrey  29/05/2020      commented the unused Methods = CPEDeliveryDateHelper.modifyCPEDeliveryDate(subscription.Id) AND CPEDeliveryDateUpdateForMAC_V2.addCPEAttr(serviceIds);
    2         Gnana          26/02/2021      EDGE-170545 - Added logic to process Inflight Orders
    3.        Ankit Goswami  07/04/2021      EDGE-204030-Associate Business calling to device
    4.		  Gnana          08/06/2021      EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
==================================================================*/

global with sharing class Orchestration_UpdateSpecificationAtt extends Orchestration_AbstractStepHandler {
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    private Id incompleteStepId;
    private final Integer workingDays = 10;
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>();
    private Map<Id, csord__Service__c> userTypeServiceMap = new Map<Id, csord__Service__c>();
    private Map<Id, Id> serviceIdToAccountIdMap = new Map<Id, Id>();
    private Map<Id, Integer> accountIdQuantityMap = new Map<Id, Integer>();
    //private Map<Id, Orchestration_AttachmentWrapper> serviceSpecAttachmentMap = new Map<Id, Orchestration_AttachmentWrapper>();
    private Map<Id, List<Orchestration_AttachmentWrapper>> orderAttachmentMap = new Map<Id, List<Orchestration_AttachmentWrapper>>();

    public override List<sObject> process(List<sObject> data) {
        List<SObject> sobjList=new List<SObject>();// Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //return null;// Commented as part of EDGE-222326
			return sobjList;// Added as part of EDGE-222326
        }

        Set<Id> oppIdSet = new Set<Id>();
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        //Map<Id, List<Id>> orderAccountIdMap =  new Map<Id, List<Id>();
        Set<Id> accountIds = new Set<Id>();
        //Variables for getTotalFixedUsersOnAccount
        String userType = '%' + System.label.UserfixedSeatName + '%';

        //Collect init Data
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
            //getRelatedOrderIds(stepList);
            //EDGE-170545 adding starts
            Set<Id> baseOrderSet = new Set<Id>();
            Set<Id> inflightOrderSet = new Set<Id>();
            for(CSPOFA__Orchestration_Step__c step1 : stepList) 
            {
                if(step1.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Inflight Orchestration Process') 
                {
                    inflightOrderSet.add(step1.CSPOFA__Orchestration_Process__r.Order__c);    
                }
                else if(step1.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Order Fulfilment Process')
                {
                    baseOrderSet.add(step1.CSPOFA__Orchestration_Process__r.Order__c);
                }
            }
            //EDGE-170545 adding ends

            for (csord__Order__c order : [SELECT ID, Scenario_Type__c, csord__Account__c, csordtelcoa__Opportunity__c, csord__Order_Request__c FROM csord__Order__c WHERE Id IN :orderIds]) {
                if (order.csordtelcoa__Opportunity__c != null) {
                    oppIdSet.add(order.csordtelcoa__Opportunity__c);
                    accountIds.add(order.csord__Account__c);
                }
            }

            if (oppIdSet.isEmpty()) {
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    stepResults.put(step.Id, new StepResult('Success: No Opportunities Found.', OrchestratorConstants.OrchestratorStep.Complete));
                }
                return processStepResults(stepList, stepResults);
            }

            if (Governor_Limits__c.getInstance().CWP_Activated__c) {
                //CWP Limit

                //Get All User Type Services for calculation of Fixed Seat
                userTypeServiceMap = new Map<Id, csord__Service__c>(
                    [
                        SELECT
                            id,
                            name,
                            csord__Subscription__r.csord__Account__c,
                            csord__Subscription__r.name,
                            csord__Subscription__r.Site__c,
                            csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c,
                            csord__Subscription__c,
                            csord__Order__c,
                            csord__Subscription__r.csord__Order_Request__c,
                            csord__Order__r.csordtelcoa__Opportunity__c,
                            csord__Order__r.csord__Account__c
                        FROM csord__Service__c
                        WHERE name LIKE :userType AND csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c != null AND csord__Subscription__r.csord__Account__c IN :accountIds AND csordtelcoa__Replacement_Service__c = null
                        ORDER BY CreatedDate DESC
                    ]
                );

                for (csord__Service__c service : userTypeServiceMap.values()) {
                    if (accountIdQuantityMap.containsKey(service.csord__Subscription__r.csord__Account__c)) {
                        Integer i = accountIdQuantityMap.get(service.csord__Subscription__r.csord__Account__c) + Integer.valueOf(service.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c);
                        accountIdQuantityMap.put(service.csord__Subscription__r.csord__Account__c, i);
                    } else {
                        accountIdQuantityMap.put(service.csord__Subscription__r.csord__Account__c, Integer.ValueOf(service.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c));
                    }
                }
            }

            servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__r.csordtelcoa__Opportunity__c, csord__Order__c, csord__Subscription__c, csord__Subscription__r.orderversion__c,csord__Order__r.Fulfilment_Order_Version__c FROM csord__Service__c WHERE csord__Order__r.csordtelcoa__Opportunity__c IN :oppIdset]);
            Set<Id> serviceIds = new Set<Id>();
            for (csord__Service__c service : servicesMap.values()) {
                if ((inflightOrderSet.contains(service.csord__Order__c)) && (service.csord__Subscription__r.orderversion__c == service.csord__Order__r.Fulfilment_Order_Version__c))
                {
                    serviceIds.add(service.Id);
                } 
                
                else if( baseOrderSet.contains(service.csord__Order__c))
                {
                    serviceIds.add(service.Id);
                }
            }
            
            //Get all attachments related to each process
            for (Attachment att : [SELECT id, name, body, parentId FROM Attachment WHERE parentId IN :serviceIds AND name = 'ServiceSpecifications.json']) {
                Id orderId = servicesMap.get(att.ParentId).csord__Order__c;
                if (orderAttachmentMap.containsKey(orderId)) {
                    orderAttachmentMap.get(orderId).add(new Orchestration_AttachmentWrapper(att.Id, att.Name, att.Body, att.ParentId));
                } else {
                    orderAttachmentMap.put(orderId, new List<Orchestration_AttachmentWrapper>{ new Orchestration_AttachmentWrapper(att.Id, att.Name, att.Body, att.ParentId) });
                }
            }

            oppIdSet = accountIds = null;

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
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
                     Map<String, String> specificationGUIDPCMap = new Map<String, String>();//Added As part of EDGE-204030
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    Set<String> tempAttId = new Set<String>();
                    if (processedRecordIds != null && processedRecordIds.attachmentIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                        tempAttId = processedRecordIds.attachmentIds;
                    }
                    List<Orchestration_AttachmentWrapper> attWrapperList = new List<Orchestration_AttachmentWrapper>();

                    if (orderAttachmentMap.containsKey(orderId)) {
                        for (Orchestration_AttachmentWrapper attWrapper : orderAttachmentMap.get(orderId)) {
                            csord__Service__c service = servicesMap.get(attWrapper.ParentId);
                            if (!tempAttId.contains(attWrapper.attchId)) {
                                attWrapperList.add(attWrapper);
                            }
                            CS_ServiceSpecificationV3 servSpecs = (CS_ServiceSpecificationV3) system.JSON.deserialize(attWrapper.attchBody.toString(), CS_ServiceSpecificationV3.class);

                            for (CS_ServiceSpecificationV3.ServiceSpecifications specification : servSpecs.specifications) {
                                // now get attributes for this specification.
                                string code = specification.Code;
                                string guid = specification.Guid;
                                
                                String specificationKeyForMap = code + '-' + service.csord__Subscription__c;
                                specificationGUIDMap.put(specificationKeyForMap, guid);
                                specificationKeyForMap = code + '-' + service.csord__Order__r.csordtelcoa__Opportunity__c;
                                specificationGUIDOppMap.put(specificationKeyForMap, guid);
                                //Added As part of EDGE-204030 || start
                                string pcId = (specification.productConfigurationId).substring(0, 15);
                                string specificationKeyForPCMap=code +'::'+pcId ;
                                specificationGUIDPCMap.put(specificationKeyForPCMap, guid);
                                //Added As part of EDGE-204030 || End
                            }
                        }
                    }
                    //Added null check
                    if(orderAttachmentMap != null && orderAttachmentMap.get(OrderId) != null){
                    orderAttachmentMap.get(OrderId).clear();
                    }

                    if ((!specificationGUIDMap.isEmpty() || !specificationGUIDOppMap.isEmpty()) && !attWrapperList.isEmpty()) {
                        incompleteStepId = updateSpecsAttibutes(step.Id, attWrapperList, specificationGUIDMap, specificationGUIDOppMap,specificationGUIDPCMap); //Added specificationGUIDPCMap As part of EDGE-204030 || start
                    } else {
                        stepResults.put(step.Id, new stepResult('Success - No update required', OrchestratorConstants.OrchestratorStep.Complete));
                    }

                    if (incompleteStepId != null) {
                        break;
                    } else if (!stepRelationshipMap.containsKey(step.Id)) {
                        stepResults.put(step.Id, new stepResult('Success - No update required', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) data) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        if (!sObjectsToUpdate.isEmpty()) {
            updateObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) data, stepResults);
    }

    public Id updateSpecsAttibutes(Id stepId, List<Orchestration_AttachmentWrapper> attWrapperList, Map<String, String> specificationGUIDMap, Map<String, String> specificationGUIDOppMap,Map<String, String> specificationGUIDPCMap) {
        Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
        //update children with parent guids and update through attsMapToUpdate
        for (Orchestration_AttachmentWrapper attWrapper : attWrapperList) {
            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                return stepId;
            }
            String serviceattachmentstr = attWrapper.attchBody.toString();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
            List<Object> lstSpecifications = (List<Object>) results.get('specifications');
            Boolean attachmentChanged = false;
            if (lstSpecifications != null) {
                for (Object specification : lstSpecifications) {
                    Map<String, String> additionalAttrs = new Map<String, String>();
                    Map<String, Object> specificationAttributesMap = (Map<String, Object>) specification;
                    string code = (String) specificationAttributesMap.get('code');
                    //Update the Fixed Seat
                    if (code.contains('DMCAT_ProductSpecification_000163') && serviceIdToAccountIdMap.containsKey(attWrapper.ParentId) && accountIdQuantityMap.containsKey(serviceIdToAccountIdMap.get(attWrapper.ParentId))) {
                        // now get attributes for this specification.
                        additionalAttrs.put('TotalNumberOfUsers', String.valueOf(accountIdQuantityMap.get(serviceIdToAccountIdMap.get(attWrapper.parentId))));
                    }

                    Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributesMap.get('attributes');

                    //Create the Relationship
                    for (String currAtt : attributesPropertyInSpecification.keySet()) {
                        if (currAtt != null && currAtt != '' && attributesPropertyInSpecification.get(currAtt) instanceof String) {
                            String currentAttributeValue = (String) attributesPropertyInSpecification.get(currAtt);
                             
                            if (currentAttributeValue != null && currentAttributeValue != '' && currentAttributeValue.contains('DMCAT_ProductSpecification')) {
                                csord__Service__c service = servicesMap.get(attWrapper.parentId);
                                String specificationKeyForMap = currentAttributeValue + '-' + service.csord__Subscription__c;
                                String specificationKeyForOppMap = currentAttributeValue + '-' + service.csord__Order__r.csordtelcoa__Opportunity__c;
                                //Added As part of EDGE-204030 || start
                                set<string>pcKey=specificationGUIDPCMap.keyset();
                                if (specificationGUIDPCMap.containsKey(currentAttributeValue) && specificationGUIDPCMap.get(currentAttributeValue) != null && specificationGUIDPCMap.get(currentAttributeValue) != '' && pcKey.contains(currentAttributeValue)) {
                                     additionalAttrs.put(currAtt, specificationGUIDPCMap.get(currentAttributeValue));
                                } /*Added As part of EDGE-204030 || end*/ else if (specificationGUIDMap.get(specificationKeyForMap) != null && specificationGUIDMap.get(specificationKeyForMap) != '') {
                                    additionalAttrs.put(currAtt, specificationGUIDMap.get(specificationKeyForMap));
                                } else if (specificationGUIDOppMap.get(specificationKeyForOppMap) != null && specificationGUIDOppMap.get(specificationKeyForOppMap) != '') {
                                    additionalAttrs.put(currAtt, specificationGUIDOppMap.get(specificationKeyForOppMap));
                                }
                            }
                        }
                    }
                    // Add to update if Additional Attibutes added
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
                attWrapper.attchBody = blob.valueOf(JSON.serialize(results));
                sObjectsToUpdate.put(attWrapper.attchId, new Attachment(Id = attWrapper.attchId, Body = attWrapper.attchBody));
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
              CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
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