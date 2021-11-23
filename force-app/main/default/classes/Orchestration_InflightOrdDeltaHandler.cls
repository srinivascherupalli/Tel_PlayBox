/**================================================================
* Name: Orchestration_InflightOrdDeltaHandler
* Description: EDGE-170463 : Delta processing for Inflight order
* Created Date: Jan 01, 2021
* Created By: Pawan Devaliya
* Sr.No.      Developer Name      Date          Story Description
  1.    Gnana               19/01/2021    EDGE-170546 : Logic added to put participated Subscription's Fullfilment Process to on hold.
  2.    Gnana              08/02/2021    EDGE-195797 : Logic added to update Subscription Status
  3.    Gnana             10/03/2021    Added tlogic o update Service Orch Process OnHold flag
==================================================================*/
global with sharing class Orchestration_InflightOrdDeltaHandler extends Orchestration_AbstractStepHandler {  
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Integer orchProcessLimit = Orchestration_LimitsUtility.getOrchestrationProcessLimit();
    
    private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
    private Map<Id, List<sObject>> sObjectsToInsertMap = new Map<Id, List<sObject>>();
    
    private Map<Id, List<csord__Subscription__c>> ordIdSubsMap = new Map<Id, List<csord__Subscription__c>>();
    private Map<Id, csord__Subscription__c> subMap = new Map<Id, csord__Subscription__c>();
    private Map<Id, csord__Subscription__c> subsToUpdate = new Map<Id, csord__Subscription__c>();
    private Map<Id, CSPOFA__Orchestration_Process__c> orchMap = new Map<Id, CSPOFA__Orchestration_Process__c>();
    private Map<Id, CSPOFA__Orchestration_Process__c> servOrchMap = new Map<Id, CSPOFA__Orchestration_Process__c>();
    private Map<Id, List<CSPOFA__Orchestration_Process__c>> subsOrchMap = new Map<Id, List<CSPOFA__Orchestration_Process__c>>();
    private Map<Id, List<CSPOFA__Orchestration_Process__c>> servicesOrchMap = new Map<Id, List<CSPOFA__Orchestration_Process__c>>();
    private Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
    private Map<Id, List<csord__Service__c>> subsToServiceMap = new Map<Id, List<csord__Service__c>>();
    private String IncompleteStepId = null;
    
    private Map<Id, Attachment> servSpecAttMap = new Map<Id, Attachment>();
    private Map<Id, Orchestration_AttachmentWrapper> serviceToAttachWrapperMap = new Map<Id, Orchestration_AttachmentWrapper>();
    private Map<Id, Attachment> attachmentsToUpdate = new Map<Id, Attachment>();
    private Map<Id, csord__Subscription__c> updateSubMap = new Map<Id, csord__Subscription__c>();
    private Map<Id, csord__service__c> updateSvcMap = new Map<Id, csord__service__c>();
    private Map<Id, CSPOFA__Orchestration_Process__c> updateOrchMap = new Map<Id, CSPOFA__Orchestration_Process__c>();    
    private Map<Id, csord__Order__c> updateOrderMap = new Map<Id, csord__Order__c>();    
    
    private final List<String> orchestrationProcessesList = new List<String>{
        OrchestratorConstants.OrchesTemplateName.serviceTemplate,
            OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate
            };
    
    //Main Process
    public override List<SObject> process(List<SObject> steps) {
        System.debug('Inside inflight order delta handler...'+orchestrationProcessesList);
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            return null;
        }
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            getRelatedOrderIds(stepList);
            Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = Orchestration_Utility.getOrchestrationTemplates(orchestrationProcessesList);
            //Exit with complete if there are No templates found
            if (orchesTemplates.isEmpty()) {
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    stepResults.put(step.Id, new StepResult('Error: No Orchestration Process Templates found.', OrchestratorConstants.OrchestratorStep.Error));
                }
                return processStepResults(stepList, stepResults);
            }
            runDataCollectionSOQLs();
            System.debug('ordIdSubsMap...'+ordIdSubsMap.values());
            System.debug('subsOrchMap...'+subsOrchMap.values());
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    //Check for data issue - order should be present
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null || ordIdSubsMap == null || (ordIdSubsMap.keyset()!=null && !ordIdSubsMap.containskey(step.CSPOFA__Orchestration_Process__r.order__c))) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order or subscriptions', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    if (!hasDMLRowsLimitExceeded()) {
                        CSPOFA__Orchestration_Process__c orchProcess = step.CSPOFA__Orchestration_Process__r;
                        if(ordIdSubsMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)){
                            csord__Order__c ord = new csord__Order__c(Id=step.CSPOFA__Orchestration_Process__r.Order__c);
                            ord.csord__Status2__c = 'Amend Pending';
                            updateOrderMap.put(ord.Id, ord);
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new List<String>{ord.Id});
                            }else {
                                stepRelationshipMap.get(step.Id).add(ord.Id);
                            }
                            for(csord__Subscription__c subscription :ordIdSubsMap.get(step.CSPOFA__Orchestration_Process__r.Order__c)){
                                if((String.isBlank(subscription.Action_Type__c) || (subscription.Action_Type__c !=null && !subscription.Action_Type__c.contains('Rollback'))) && (subscription.orderversion__c == step.CSPOFA__Orchestration_Process__r.Order__r.Fulfilment_Order_Version__c)){
                                    if(subsOrchMap.containsKey(subscription.Id)){
                                        for(CSPOFA__Orchestration_Process__c orch : subsOrchMap.get(subscription.Id)){
                                            orch.CSPOFA__Process_On_Hold__c = true;
                                            updateOrchMap.put(orch.Id, orch);
                                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                                stepRelationshipMap.put(step.Id, new List<String>{orch.Id});
                                            }else {
                                                stepRelationshipMap.get(step.Id).add(orch.Id);
                                            }
                                        }
                                        
                                        for (csord__service__c service : subsToServiceMap.get(subscription.Id)) {
                                            System.debug('servicesOrchMap.get(service.Id)...'+servicesOrchMap.get(service.Id));
                                            if(servicesOrchMap.get(service.Id) != null){
                                                for(CSPOFA__Orchestration_Process__c orch : servicesOrchMap.get(service.Id)){
                                                    orch.CSPOFA__Process_On_Hold__c = true;
                                                    updateOrchMap.put(orch.Id, orch);
                                                    if (!stepRelationshipMap.containsKey(step.Id)) {
                                                        stepRelationshipMap.put(step.Id, new List<String>{orch.Id});
                                                    }else {
                                                        stepRelationshipMap.get(step.Id).add(orch.Id);
                                                    }
                                                }
                                            }
                                            
                                            if (serviceToAttachWrapperMap != null && serviceToAttachWrapperMap.containskey(service.Id)) {
                                                String serviceattachmentstr = serviceToAttachWrapperMap.get(service.Id).attchBody.toString();
                                                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
                                                List<Object> lstSpecifications = (List<Object>) results.get(OrchestratorConstants.ServiceSpecificationKey.Specifications);
                                                List<Object> updatedSpecificationList = new List<Object>();
                                                boolean isStatusChanged = false;
                                                for (Object specification : lstSpecifications) {
                                                    Map<String, Object> specificationObject = (Map<String, Object>) specification;
                                                    if(service.changeType__c == 'New' || service.changeType__c == 'Port Out Reversal' || service.changeType__c == 'Port In' || service.changeType__c == 'Transition' || service.changeType__c == 'Transition with Inactive Sim'){specificationObject.put('status', 'Created'); isStatusChanged = true;}
                                                    else if(service.changeType__c == 'Modify '){specificationObject.put('status', 'Modified'); isStatusChanged = true;}
                                                    else if(Service.toBeCancelled__c == 'true'){specificationObject.put('status', 'Disconnect Pending'); isStatusChanged = true;}
                                                    updatedSpecificationList.add((Object) specificationObject);
                                                }
                                                if (isStatusChanged && !updatedSpecificationList.isEmpty()) {
                                                    results.put(OrchestratorConstants.ServiceSpecificationKey.Specifications, updatedSpecificationList);
                                                    String updatednewServiceattachmentstr = JSON.serializePretty(results);
                                                    Attachment UpdatedServSpec = new Attachment(Id = serviceToAttachWrapperMap.get(service.Id).attchId);
                                                    UpdatedServSpec.Body = Blob.valueOf(updatednewServiceattachmentstr);attachmentsToUpdate.put(UpdatedServSpec.Id, UpdatedServSpec);
                                                    if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new List<Id>{ UpdatedServSpec.Id });} else {stepRelationshipMap.get(step.Id).add(UpdatedServSpec.Id);}
                                                }
                                            }
                                            
                                            if(service.csordtelcoa__Cancelled_By_Change_Process__c == true){
                                                if(service.csord__Status__c == 'Amend Rejected'){
                                                    service.csord__Status__c = 'Cancelled';
                                                    updateSvcMap.put(service.Id, service);
                                                    if (!stepRelationshipMap.containsKey(step.Id)) {
                                                        stepRelationshipMap.put(step.Id, new List<Id>{ service.Id });
                                                    } else {
                                                        stepRelationshipMap.get(step.Id).add(service.Id);
                                                    }
                                                }
                                                else{
                                                    service.csord__Status__c = 'Cancellation Pending';
                                                    updateSvcMap.put(service.Id, service);
                                                    if (!stepRelationshipMap.containsKey(step.Id)) {
                                                        stepRelationshipMap.put(step.Id, new List<Id>{ service.Id });
                                                    } else {
                                                        stepRelationshipMap.get(step.Id).add(service.Id);
                                                    }
                                                }
                                            }
                                            else if(service.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null && service.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c == service.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c){
                                                service.csord__Status__c = 'Amend Pending';
                                                updateSvcMap.put(service.Id, service);
                                                if (!stepRelationshipMap.containsKey(step.Id)) {
                                                    stepRelationshipMap.put(step.Id, new List<Id>{ service.Id });
                                                } else {
                                                    stepRelationshipMap.get(step.Id).add(service.Id);
                                                }
                                            }
                                            else{
                                                service.csord__Status__c = 'Pending';
                                                updateSvcMap.put(service.Id, service);
                                                if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new List<Id>{ service.Id });
                                                } else {
                                                    stepRelationshipMap.get(step.Id).add(service.Id);
                                                }
                                            } 
                                        }
                                    }
                                    
                                    if(subscription.csordtelcoa__Cancelled_By_Change_Process__c == true){
                                        if(subscription.csord__Status__c == 'Amend Rejected'){
                                            subscription.csord__Status__c = 'Cancelled';
                                            updateSubMap.put(subscription.Id, subscription);
                                            if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                            } else {
                                                stepRelationshipMap.get(step.Id).add(subscription.Id);
                                            }
                                        }
                                        else{
                                            subscription.csord__Status__c = 'Cancellation Pending';
                                            updateSubMap.put(subscription.Id, subscription);
                                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                                stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                            } else {
                                                stepRelationshipMap.get(step.Id).add(subscription.Id);
                                            }
                                        }
                                    }
                                    else if(subscription.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != NULL && subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c == subscription.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c){subscription.csord__Status__c = 'Amend Pending';updateSubMap.put(subscription.Id, subscription);
                                        if (!stepRelationshipMap.containsKey(step.Id)) {
                                            stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                        } else {
                                            stepRelationshipMap.get(step.Id).add(subscription.Id);
                                        }    
                                    }
                                    else{
                                        subscription.csord__Status__c = 'Pending';
                                        updateSubMap.put(subscription.Id, subscription);
                                        if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                        } else {
                                            stepRelationshipMap.get(step.Id).add(subscription.Id);
                                        }
                                    }
                                    if(subscription.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c == null){
                                        createOrchForNewSubsSvc(step.Id, subscription.Id);
                                    }
                                }
                                
                                if( subscription.Action_Type__c != null && subscription.Action_Type__c.contains('Rollback')){
                                    Integer servicesPaidOutCount = 0;
                                    Integer servicesPayOutCount = 0;
                                    Integer servicesConnectedCount = 0;
                                    Integer servicesDisconnectedCount = 0;
                                    
                                    for (csord__service__c service : subsToServiceMap.get(subscription.Id)) {
                                        if(servicesOrchMap.get(service.Id) != null){
                                            for(CSPOFA__Orchestration_Process__c orch : servicesOrchMap.get(service.Id)){
                                                orch.CSPOFA__Process_On_Hold__c = false;
                                                updateOrchMap.put(orch.Id, orch);
                                                if (!stepRelationshipMap.containsKey(step.Id)) {
                                                    stepRelationshipMap.put(step.Id, new List<String>{orch.Id});
                                                }else {
                                                    stepRelationshipMap.get(step.Id).add(orch.Id);
                                                }
                                            }
                                        }

                                        if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
                                            //terminate the loop
                                            IncompleteStepId = step.Id;break;
                                        }
                                        
                                        if (service.csord__status__c == 'Paid Out') {servicesPaidOutCount += 1;
                                            
                                        } else if (service.csord__status__c == 'Connected' || service.Action_Type__c == 'PayOut') {
                                            servicesConnectedCount += 1; 
                                            if (service.Action_Type__c == 'PayOut') {
                                                servicesPayOutCount += 1;
                                            }
                                        } else if (service.csord__status__c == 'Disconnected') {servicesDisconnectedCount += 1; 
                                        }
                                    }
                                    System.debug('servicesPaidOutCount...'+servicesPaidOutCount);
                                    System.debug('servicesConnectedCount...'+servicesConnectedCount);
                                    System.debug('servicesDisconnectedCount...'+servicesDisconnectedCount);
                                    System.debug('subs service size...'+subsToServiceMap.get(subscription.Id).size());
                                    //if( subscription.Action_Type__c != null && subscription.Action_Type__c.contains('Rollback')){
                                    if (subsToServiceMap.get(subscription.Id).size() == (servicesConnectedCount + servicesDisconnectedCount + servicesPaidOutCount)) {
                                        //EDGE-195797  : If all the services on subscription are Paid Out, Connected/PayOut Or Disconnected then moving subscription to Provisioned
                                        if (subscription.csord__Status__c != 'Provisioned') {
                                            subscription.csord__Status__c = 'Provisioned';
                                            updateSubMap.put(subscription.Id, subscription);
                                            if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                            } else {
                                                stepRelationshipMap.get(step.Id).add(subscription.Id);
                                            }
                                        }
                                    }
                                    else{
                                        if (subscription.csord__Status__c != 'Provisioning In Progress') {subscription.csord__Status__c = 'Provisioning In Progress';updateSubMap.put(subscription.Id, subscription);
                                            if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                            } else {stepRelationshipMap.get(step.Id).add(subscription.Id);
                                            }
                                        }
                                    }
                                    if(subsOrchMap.containsKey(subscription.Id)){
                                        for(CSPOFA__Orchestration_Process__c orch : subsOrchMap.get(subscription.Id)){
                                            orch.CSPOFA__Process_On_Hold__c = false;
                                            updateOrchMap.put(orch.Id, orch);
                                            if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new List<String>{orch.Id});
                                            }else {
                                                stepRelationshipMap.get(step.Id).add(orch.Id);
                                            }
                                        }
                                    }
                                    //}
                                }
                            }
                        }
                    }
                    else{
                        IncompleteStepId = step.Id;
                        break;
                    }
                   
                    if (IncompleteStepId == null || IncompleteStepId != step.Id) {
                        if (processedIds.get(step.Id) == null || processedIds.get(step.Id).subsIds.isempty() && processedIds.get(step.Id).attachmentIds.isempty()) {
                            stepResults.put(step.Id, new stepResult('Success - No update required as no data needed any update for this step', OrchestratorConstants.OrchestratorStep.Complete));
                        } else {stepResults.put(step.Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));}
                    }
                    
                    
                }catch (Exception ex) {
                    System.debug('Exception...'+ex.getMessage() + ex.getLineNumber() +ex.getStackTraceString());
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));}
            }
        } catch (Exception ex) {for (CSPOFA__Orchestration_Step__c step : stepList) {stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));}}
        
        //Update the soBjects (Order)
        if (!updateSvcMap.isEmpty() ||!updateOrchMap.isEmpty() || !updateSubMap.isEmpty() || !updateOrderMap.isEmpty()) {
            System.debug('updateSubMap..'+updateOrderMap);
            updateObjects();
        }
        return processStepResults(stepList, stepResults);
    }
    
    
    //Generic Method implemented in AbstractStepHandler
    public override void updateObjects() {
        
List<sObject> sObjectsToInsertList = new List<sObject>();
//Success DML Order Ids
List<Id> ordSuccessIds = new List<Id>();
//Success DML subscription Ids
List<Id> subsSuccessIds = new List<Id>();
//Success DML service Ids
List<Id> serviceSuccessIds = new List<Id>();
//Success DML orchestration Ids
List<Id> orchSuccessIds = new List<Id>();
//Success DML attachment  Ids
List<Id> attchSuccessIds  = new List<Id>();

List<Database.SaveResult> updateResult = new List<Database.SaveResult>();

// Updating Order records
if(updateOrderMap.size()>0){
    updateResult = Database.update(updateOrderMap.values(), false);

    //Storing the subscription success Ids
    for (Database.SaveResult rslt : updateResult) {
        if (rslt.isSuccess()) {
            ordSuccessIds.add(rslt.getId());
        }
    }
}
  //Updating all the subscription records
if (updateSubMap.size() > 0) {
    updateResult = Database.update(updateSubMap.values(), false);

    //Storing the subscription success Ids
    for (Database.SaveResult rslt : updateResult) {
        if (rslt.isSuccess()) {
            subsSuccessIds.add(rslt.getId());
        }
    }
}

if (attachmentsToUpdate.size() > 0) {
    updateResult = Database.update(attachmentsToUpdate.values(), false);

    //Storing the subscription success Ids
    for (Database.SaveResult rslt : updateResult) {if (rslt.isSuccess()) {attchSuccessIds.add(rslt.getId());
        }
    }
}

//Updating all the service records
if (updateSvcMap.size() > 0) {
    updateResult = Database.update(updateSvcMap.values(), false);

    //Storing the service success Ids
    for (Database.SaveResult rslt : updateResult) {if (rslt.isSuccess()) {serviceSuccessIds.add(rslt.getId());
        }
    }
}

        //Updating all the orchestration records
if (updateOrchMap.size() > 0) {
    updateResult = Database.update(updateOrchMap.values(), false);

    //Storing the orchestration success Ids
    for (Database.SaveResult rslt : updateResult) {
        if (rslt.isSuccess()) {
            orchSuccessIds.add(rslt.getId());
        }
    }
}

//Iteration over each step
for (Id stepId : stepRelationshipMap.keySet()) {
    Boolean isFailed = false;
    Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
    //Initializing the attachmentIds Set
    perStepSuccessIds.subsIds = new Set<String>();
    perStepSuccessIds.skipRecordsIds = new Set<String>();

    for (Id recId : stepRelationshipMap.get(stepId)) {
      if (!(ordSuccessIds.contains(recId) || subsSuccessIds.contains(recId) || serviceSuccessIds.contains(recId) || orchSuccessIds.contains(recId) || attchSuccessIds.contains(recId))) {
          System.debug('recId :'+recId);
            //Failure
            isFailed = true;
        }
    }

    if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
        stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
         if(sObjectsToInsertMap.containsKey(stepId)){
            sObjectsToInsertList.addAll(sObjectsToInsertMap.get(stepId));
        }
        //move to next step
        continue;
    }
    if (processedIds.containsKey(stepId)) {
        if (processedIds.get(stepId).skipRecordsIds != null) {perStepSuccessIds.skipRecordsIds.addAll(processedIds.get(stepId).skipRecordsIds);
        }

    //Adding the previous stored ids - error/partial processed case
        if (processedIds.get(stepId).attachmentIds != null) {perStepSuccessIds.attachmentIds.addAll(processedIds.get(stepId).attachmentIds);
        }
    //added for cpu time out issue
        if (processedIds.get(stepId).subsIds != null) {perStepSuccessIds.subsIds.addAll(processedIds.get(stepId).subsIds);
        }
    }
    if (!isFailed && !String.isBlank(IncompleteStepId) && IncompleteStepId.equals(stepId)) {
        stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress));
    } else {
        System.debug(isFailed +' - '+IncompleteStepId);
        stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error));
    }     
}
   if (sObjectsToInsertList.size() > 0){insert sObjectsToInsertList;

    } 
    }  

    public override List<sObject> getStepList(List<sObject> steps) {
        return [
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
            CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c,
            CSPOFA__Orchestration_Process__r.Order__r.Fulfilment_Order_Version__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
    }
    
    private void runDataCollectionSOQLs(){
        List<String> subsIdList = new List<String>();
        List<String> servIdList = new List<String>();
        
        String subQuery = 'SELECT Id, Name, csord__Status__c,';
        subQuery += 'csord__Order__c, ';
        subQuery += 'orderversion__c, ';
        subQuery += 'Action_Type__c, csordtelcoa__Cancelled_By_Change_Process__c, ';
        subQuery += 'csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,'; 
        subQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c,';    
        subQuery += 'csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c';   
        subQuery += ' FROM csord__Subscription__c Where csord__Order__c IN: orderIds';   
        
        subMap = new Map<Id, csord__Subscription__c>((List<csord__Subscription__c>) Database.query(subQuery));
        
        for(csord__Subscription__c sub :subMap.values()){
            subsIdList.add(sub.Id);
            if(!ordIdSubsMap.containsKey(sub.csord__Order__c)){
                ordIdSubsMap.put(sub.csord__Order__c, new List<csord__Subscription__c>{sub});
            } else {
                ordIdSubsMap.get(sub.csord__Order__c).add(sub);
            }
        }
        
        String orchName = 'Subscription Fulfilment Process';
        String orchQuery = 'SELECT Id, Name, csordtelcoa__Subscription__c';
        orchQuery += ' FROM CSPOFA__Orchestration_Process__c Where csordtelcoa__Subscription__c IN :subsIdList AND CSPOFA__Orchestration_Process_Template__r.Name = :orchName'; 
        orchMap = new Map<Id, CSPOFA__Orchestration_Process__c>((List<CSPOFA__Orchestration_Process__c>) Database.query(orchQuery));
        for(CSPOFA__Orchestration_Process__c orch :orchMap.values()){
            if(!subsOrchMap.containsKey(orch.csordtelcoa__Subscription__c)){
                subsOrchMap.put(orch.csordtelcoa__Subscription__c, new List<CSPOFA__Orchestration_Process__c>{orch});
            } else {
                subsOrchMap.get(orch.csordtelcoa__Subscription__c).add(orch);
            }
        }
        
        // Added below query as part of EDGE-195797 - Start
        String servQuery = 'SELECT Id, Name, csord__Status__c,';
        servQuery += 'toBeCancelled__c, csord__Subscription__c,';
        servQuery += 'csord__Subscription__r.csord__Status__c,';
        servQuery += 'Action_Type__c, csordtelcoa__Cancelled_By_Change_Process__c,';
        servQuery += 'csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,'; 
        servQuery += 'csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c,'; 
        servQuery += 'changeType__c,'; 
        servQuery += 'csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c';
        servQuery += ' FROM csord__Service__c WHERE csord__Subscription__c IN :subsIdList';
        
        serviceMap = new Map<Id, csord__Service__c>((List<csord__Service__c>) Database.query(servQuery));
        
        for (csord__Service__c serv : serviceMap.values()) {
            servIdList.add(serv.Id);
            if (subsToServiceMap.containsKey(serv.csord__Subscription__c)) {
                subsToServiceMap.get(serv.csord__Subscription__c).add(serv);
            } else {
                subsToServiceMap.put(serv.csord__Subscription__c, new List<csord__Service__c>{ serv });
            }
        }
        // Added query as part of EDGE-195797 - End
        
        // Added query as part of EDGE-170545 - Start
        String servSpecJSON = OrchestratorConstants.DataOrchestrationNames.service;
        String servSpecAttQuery = 'SELECT Id, Name, body, parentId';
        servSpecAttQuery += ' FROM Attachment WHERE parentId IN :servIdList AND Name = :servSpecJSON';
        servSpecAttMap = new Map<Id, Attachment>((List<Attachment>) Database.query(servSpecAttQuery));
        for (Attachment att : servSpecAttMap.values()) {
            serviceToAttachWrapperMap.put(att.parentId, new Orchestration_AttachmentWrapper(att.Id, att.body));
        }
        // Added query as part of EDGE-170545 - End
        
        String servOrchName = 'Service Fulfilment Process';
        String servOrchQuery = 'SELECT Id, Name, csordtelcoa__Service__c';
        servOrchQuery += ' FROM CSPOFA__Orchestration_Process__c Where csordtelcoa__Service__c IN :servIdList AND CSPOFA__Orchestration_Process_Template__r.Name = :servOrchName'; 
        servOrchMap = new Map<Id, CSPOFA__Orchestration_Process__c>((List<CSPOFA__Orchestration_Process__c>) Database.query(servOrchQuery));
        for(CSPOFA__Orchestration_Process__c orch :servOrchMap.values()){
            if(!servicesOrchMap.containsKey(orch.csordtelcoa__Service__c)){
                servicesOrchMap.put(orch.csordtelcoa__Service__c, new List<CSPOFA__Orchestration_Process__c>{orch});
            } else {
                servicesOrchMap.get(orch.csordtelcoa__Service__c).add(orch);
            }
        }
        
        system.debug('servicesOrchMap...'+servicesOrchMap);
        
    } 
    public void createOrchForNewSubsSvc(Id stepId, Id subscriptionId)
    {
         List<String> orchestrationProcessesList1 = new List<String>{
        OrchestratorConstants.OrchesTemplateName.serviceTemplate,
            OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate
            };
        Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = Orchestration_Utility.getOrchestrationTemplates(orchestrationProcessesList1 );
    for (csord__service__c service : subsToServiceMap.get(subscriptionId)) {
        if(service.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c == null){
            //create orchestration process for services
            CSPOFA__Orchestration_Process__c orchesSvc = new CSPOFA__Orchestration_Process__c();
            orchesSvc.CSPOFA__State__c = OrchestratorConstants.OrcehstrationProcessState.Active;
            orchesSvc.csordtelcoa__Service__c = service.Id;
            orchesSvc.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.serviceTemplate).id;
            if (!sObjectsToInsertMap.containsKey(stepId)) {
                sObjectsToInsertMap.put(stepId, new List<sObject>{ orchesSvc });
            } else {
                sObjectsToInsertMap.get(stepId).add(orchesSvc);
            }            
        }  
    }
    
   //create orchestration process for subscriptions
            CSPOFA__Orchestration_Process__c subOrches = new CSPOFA__Orchestration_Process__c();
            subOrches.CSPOFA__State__c = OrchestratorConstants.OrcehstrationProcessState.Active;
            subOrches.csordtelcoa__Subscription__c  = subscriptionId;
            subOrches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate).id;
            if (!sObjectsToInsertMap.containsKey(stepId)) {sObjectsToInsertMap.put(stepId, new List<sObject>{ subOrches });
            } else {
                sObjectsToInsertMap.get(stepId).add(subOrches);
            } 

    
    }

}