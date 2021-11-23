/**================================================================
* Appirio, Inc
* Name: Orchestration_CeasePriceScheduleStep
* Description:
* Created Date: July 16, 2020
* Created By: Martand Atrey
==================================================================*/
global with sharing class Orchestration_CeasePriceScheduleStep extends Orchestration_AbstractStepHandler {
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    private Id incompleteStepId;
    private Boolean isSuccess = true;
    
    //records to be updated
    private Map<Id, Charge_Line_Item__c> cliTobeUpdatedMap = new Map<Id, Charge_Line_Item__c>();
    private Map<Id, Discount_Line_Item__c> dliToBeUpdatedMap = new Map<Id, Discount_Line_Item__c>();
    private Map<Id, Price_Schedule_Line_Item__c> pliToBeUpdatedMap = new Map<Id, Price_Schedule_Line_Item__c>();
    private Map<Id, Tier_Line_Item__c> tliToBeUpdatedMap = new Map<Id, Tier_Line_Item__c>();
    
    //Store Records Map
    private Map<Id, List<Charge_Line_Item__c>> subsCLIDisconnectMap = new Map<Id, List<Charge_Line_Item__c>>();
    private Map<Id, List<Charge_Line_Item__c>> subsCLIReplacedMap = new Map<Id, List<Charge_Line_Item__c>>();
    private Map<Id, Set<Tier_Line_Item__c>> pliTLISetMap = new Map<Id, Set<Tier_Line_Item__c>>();
    private Map<Id, List<Price_Schedule_Line_Item__c>> chargeLineToPriceLineMap = new Map<Id, List<Price_Schedule_Line_Item__c>>();
	private Map<Id, List<Discount_Line_Item__c>> chargeLineItemToDiscountLineMap = new Map<Id, List<Discount_Line_Item__c>>();
    //Custom Sets for difff Data
    private Set<Id> servicesSet = new Set<Id>();
    private Set<Id> clisNotPublishedIdSet = new Set<Id>();
    private Map<Id, Id> replacedServiceIdMap = new Map<Id, Id>();
    
    //Store Parent Children Relationship
    private Map<Id, Set<Id>> subsServiceMap = new Map<Id, Set<Id>>();
    private Map<Id, Blob> serviceAttachmentMap = new Map<Id, Blob>();
    
    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            system.debug('stopping execution as limit breached.....');
            return null;
        }
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        Map<Id, Charge_Line_Item__c> chargeLineItemDisconnectMap = new Map<id, Charge_Line_Item__c>();
        Map<Id, Charge_Line_Item__c> chargeLineItemReplacedServMap = new Map<id, Charge_Line_Item__c>();
        
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
			set<Id> clidToInactive = new set<Id>();
            getRelatedSubscriptionIds(stepList);
            //Fetching Services where status contains 'Disconnect' and matches passed subscription ids
            for (csord__Service__c serv : [SELECT Id, csordtelcoa__Replaced_Service__c,csord__Subscription__c FROM csord__Service__c WHERE csord__Subscription__c IN :subscriptionIds AND csord__Status__c LIKE '%Disconnect%']) {
                if (serv.csordtelcoa__Replaced_Service__c != null) {
                    replacedServiceIdMap.put(serv.csordtelcoa__Replaced_Service__c, serv.csord__Subscription__c);
                }
                servicesSet.add(serv.Id);
                
            }
            
            for (Charge_Line_Item__c cli : [SELECT Id, Name, billingSpecIdentifier__c, Status__c, serviceId__c, chargeType__c, serviceId__r.csord__Subscription__c, BusinessID__c FROM Charge_Line_Item__c WHERE serviceId__c IN :servicesSet OR serviceId__c IN :replacedServiceIdMap.keyset()]) {
                if(servicesSet.contains(cli.serviceId__c)){
                    if (subsCLIDisconnectMap.containsKey(cli.serviceId__r.csord__Subscription__c)) {
                        subsCLIDisconnectMap.get(cli.serviceId__r.csord__Subscription__c).add(cli);
                    } else {
                        subsCLIDisconnectMap.put(cli.serviceId__r.csord__Subscription__c, new List<Charge_Line_Item__c>{ cli });
                    }
                }else if(replacedServiceIdMap.containsKey(cli.serviceId__c)){
                    clidToInactive.add(cli.Id);
                    if (subsCLIReplacedMap.containsKey(replacedServiceIdMap.get(cli.serviceId__c))) {
                        subsCLIReplacedMap.get(replacedServiceIdMap.get(cli.serviceId__c)).add(cli);
                    } else {
                        subsCLIReplacedMap.put(replacedServiceIdMap.get(cli.serviceId__c), new List<Charge_Line_Item__c>{ cli });
                    }			
                }
            }
            
            for(Price_Schedule_Line_Item__c psliRec:  [SELECT Id, status__c,chargeInstance__c, (SELECT Id, Status__c FROM Tier_Line_Items__r WHERE Status__c != :Label.ReadyToInactive) FROM Price_Schedule_Line_Item__c WHERE chargeInstance__c IN :clidToInactive ]){
                if(!chargeLineToPriceLineMap.containsKey(psliRec.chargeInstance__c)){
                    chargeLineToPriceLineMap.put(psliRec.chargeInstance__c, new List<Price_Schedule_Line_Item__c>{psliRec});
                }else{
                    chargeLineToPriceLineMap.get(psliRec.chargeInstance__c).add(psliRec);
                }
            }
            
            for(Discount_Line_Item__c dliRec:  [SELECT Id, status__c,chargeInstance__c FROM Discount_Line_Item__c WHERE Status__c != :Label.ReadyToInactive AND chargeInstance__c IN :clidToInactive ]){
                if(!chargeLineItemToDiscountLineMap.containsKey(dliRec.chargeInstance__c)){
                    chargeLineItemToDiscountLineMap.put(dliRec.chargeInstance__c, new List<Discount_Line_Item__c>{dliRec});
                }else{
                    chargeLineItemToDiscountLineMap.get(dliRec.chargeInstance__c).add(dliRec);
                }
            }
            
            
            //get all attachments and create their map.
            for (Attachment att : [SELECT ID, Body, ParentId FROM Attachment WHERE ParentId IN :servicesSet AND name = 'ServiceSpecifications.json']) {
                serviceAttachmentMap.put(att.ParentId, att.Body);
            }
            
            /**
* Iterate Over All steps
*/
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an associated subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    
                    //Get the Subscription
                    Id subId = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c;
                    
                    if (subsCLIDisconnectMap.containsKey(subId) || subsCLIReplacedMap.containsKey(subId)) {
                        //get All CLI and update the details
                        incompleteStepId = updateLineItemsStatus(step.Id, subId);
                    } else {
                        //Updating steps as Complete since no CLI data linked to Sub
                        stepResults.put(step.Id, new stepResult('Completed: Step do not have Charge Line Items', OrchestratorConstants.OrchestratorStep.Complete));
                        //Check the next step
                        continue;
                    }
                    
                    if (incompleteStepId != null) {
                        break;
                    } else if (!stepRelationshipMap.containsKey(step.Id)) {
                        stepResults.put(step.Id, new stepResult('Success - No update required.', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        
        if ((!cliTobeUpdatedMap.isEmpty() || !pliTobeUpdatedMap.isEmpty() || !dliTobeUpdatedMap.isEmpty() || !tliTobeUpdatedMap.isEmpty() || !eventsToPublish.isEmpty())) {
            if (!eventsToPublish.isEmpty()) {
                publishObject(null);
            }
            processDMLOperations();
        }
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    
    //Update the Status of all the lines items (DLI CLI PLI TLI) to 'Ready to Inactive'
    private Id updateLineItemsStatus(Id stepId, Id subId) {
        Boolean LimitsHit = false;
        Map<Id, Map<String, String>> servTOCodeGUIDMap = new Map<Id, Map<String, String>>();
        if (subsCLIReplacedMap.get(subId) != null) {
            for (Charge_Line_Item__c cli : subsCLIReplacedMap.get(subId)) {
                Id result = processCLIandChildRecords(stepId, cli);
                if (result != null) {
                    return result;
                }
            }
        }
        
        String corelationId = IntegrationRecordHandlerUtil.getCorrelationId();
        boolean containsTieredCharges = false, createEvent = false;
        //udpate the CLI Status to EventPublished and Billing Spec and Correlation Id
        if (subsCLIDisconnectMap.get(subId) != null) {
            /*if (subsServiceMap.get(subId) != null) {
                servTOCodeGUIDMap = Orchestration_Utility.getServiceTOCodeGUIDMap(subsServiceMap.get(subId), serviceAttachmentMap);
            }*/
            //System.debug(servTOCodeGUIDMap + '===>servTOCodeGUIDMap');
            for (Charge_Line_Item__c cli : subsCLIDisconnectMap.get(subId)) {
                if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
                    LimitsHit = true;
                    break;
                }
				
				Boolean tobeUpdated = false;
				if (cli.billingSpecIdentifier__c == null && serviceAttachmentMap.containsKey(cli.serviceId__c)) {
					tobeUpdated = getServiceTOCodeGUIDMap(cli, serviceAttachmentMap.get(cli.serviceId__c));
				}
				
				if(cli.status__c != 'Event Published' ){
					createEvent = true;
					cli.CorrelationId__c = corelationId;
					cli.status__c = 'Event Published';
					if (!containsTieredCharges && String.isNotBlank(cli.chargeType__c) && cli.chargeType__c.equalsIgnoreCase(Label.TieredRecurring)) {
						containsTieredCharges = true;
					}
						
				}
				if(tobeUpdated || createEvent){
					cliTobeUpdatedMap.put(cli.Id, cli);
					if (!stepRelationshipMap.containsKey(stepId)) {
						stepRelationshipMap.put(stepId, new Set<Id>{ cli.id });
					} else {
						stepRelationshipMap.get(stepId).add(cli.Id);
					}
				}
				System.debug(stepRelationshipMap + '===>stepRelationshipMap');	
                
            }
        }
        
        if (createEvent) {
            PriceScheduleEvent__e priceSchEvent = new PriceScheduleEvent__e(eventType__c = 'Request', CorrelationId__c = corelationId, containsTieredCharges__c = containsTieredCharges);
            eventsToPublish.add(priceSchEvent);
        }
        
        return LimitsHit ? stepId : null;
    }
    
    private Id processCLIandChildRecords(Id stepId, Charge_Line_Item__c cli) {
        
        
        if (!hasDMLRowsLimitExceeded()) {
            if (cli.status__c != Label.ReadyToInactive) {
                cli.status__c = Label.ReadyToInactive;
                cliTobeUpdatedMap.put(cli.Id, cli);
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new Set<Id>{ cli.id });
                } else {
                    stepRelationshipMap.get(stepId).add(cli.Id);
                }
            }
        }else{
            return stepId;
        }
        for (Discount_Line_Item__c dli : chargeLineItemToDiscountLineMap.get(cli.Id)) {
            
            if (!hasDMLRowsLimitExceeded()) {
                dli.Status__c = Label.ReadyToInactive;
                dliToBeUpdatedMap.put(dli.Id, dli);
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new Set<Id>{ dli.Id });
                } else {
                    stepRelationshipMap.get(stepId).add(dli.Id);
                }
                
            }else{
                return stepId;
            }
        }
        for (Price_Schedule_Line_Item__c psli : chargeLineToPriceLineMap.get(cli.Id)) {
            
            if (!hasDMLRowsLimitExceeded()) {
                if (psli.status__c != Label.ReadyToInactive) {
                    psli.status__c = Label.ReadyToInactive;
                    pliToBeUpdatedMap.put(psli.Id, psli);
                    if (!stepRelationshipMap.containsKey(stepId)) {
                        stepRelationshipMap.put(stepId, new Set<Id>{ psli.Id });
                    } else {
                        stepRelationshipMap.get(stepId).add(psli.Id);
                    }
                }
            }else{
                return stepId;
            }
            
            for (Tier_Line_Item__c tli : psli.Tier_Line_Items__r) {
                if (!hasDMLRowsLimitExceeded()) {
                    tli.status__c = Label.ReadyToInactive;
                    tliToBeUpdatedMap.put(tli.Id, tli);
                    if (!stepRelationshipMap.containsKey(stepId)) {
                        stepRelationshipMap.put(stepId, new Set<Id>{ tli.Id });
                    } else {
                        stepRelationshipMap.get(stepId).add(tli.Id);
                    }
                }else{
                    return stepId;
                }
            }
            
        }
        return null;
    }
    
    //override getStepList to fetch necessry field from steps
    public override List<sObject> getStepList(List<sObject> steps) {
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT ID, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Account__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];
        
        return stepList;
    }
    
    //TODO update the Update Objects method
    public void processDMLOperations() {
        Database.SaveResult[] allResult = new List<Database.SaveResult>();
        
        //Storing the records
        List<Id> allSuccessIds = new List<Id>();
        
        //Updating all the CLI records
        if (!cliTobeUpdatedMap.isEmpty()) {
            allResult = Database.update(cliTobeUpdatedMap.values(), false);
        }
        
        for (Database.SaveResult rslt : allResult) {
            if (rslt.isSuccess()) {
                allSuccessIds.add(rslt.getId());
            }
        }
        
        //Updating all the CLI records
        if (!dliTobeUpdatedMap.isEmpty()) {
            allResult = Database.update(dliTobeUpdatedMap.values(), false);
        }
        for (Database.SaveResult rslt : allResult) {
            if (rslt.isSuccess()) {
                allSuccessIds.add(rslt.getId());
            }
        }
        
        //Updating all the CLI records
        if (!tliTobeUpdatedMap.isEmpty()) {
            allResult = Database.update(tliTobeUpdatedMap.values(), false);
        }
        
        for (Database.SaveResult rslt : allResult) {
            if (rslt.isSuccess()) {
                allSuccessIds.add(rslt.getId());
            }
        }
        
        //Updating all the CLI records
        if (!pliTobeUpdatedMap.isEmpty()) {
            allResult = Database.update(pliTobeUpdatedMap.values(), false);
        }
        for (Database.SaveResult rslt : allResult) {
            if (rslt.isSuccess()) {
                allSuccessIds.add(rslt.getId());
            }
        }
        
        for (Id stepId : stepRelationshipMap.keySet()) {
            Boolean isFailed = false;
            for (Id recId : stepRelationshipMap.get(stepId)) {
                //Failure check
                if (!allSuccessIds.contains(recId)) {
                    isFailed = true;
                }
            }
            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }
            
            //If the Records were partially Processed or Error
            if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error));
            }
        }
    }
    
    public override void publishObject(List<Orchestration_CallOutResponse> respList) {
        //High value events are queued therefore async
        List<Database.SaveResult> result = EventBus.publish(eventsToPublish);
        /* for (Database.SaveResult res : result) {
if (!res.isSuccess()) {
isSuccess = false;
break;
}
} */
    }
	
	public boolean getServiceTOCodeGUIDMap(Charge_Line_Item__c cli, Blob attBody) {
        Map<String, String> CodetoGuidMap = new Map<String, String>();
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(attBody.toString()), 'BILLING');
        for (CS_SpecificationDTO.ServiceSpecification spec : srvspecList) {
            String code = 'DMCAT_' + spec.code.split('Billing_')[1];
            CodetoGuidMap.put(code, spec.guid);
        }
        if (CodetoGuidMap != null && !CodetoGuidMap.isEmpty() && CodetoGuidMap.containsKey(cli.BusinessID__c)) {
            cli.billingSpecIdentifier__c = CodetoGuidMap.get(cli.BusinessID__c);
            return true;
        }
        return false;
    }
    
    public override boolean hasDMLRowsLimitExceeded() {
        boolean dmlRowsExceeded = true;
        if ((eventsToPublish.size() + cliTobeUpdatedMap.values().size() + dliToBeUpdatedMap.size() + pliToBeUpdatedMap.size() + tliToBeUpdatedMap.size()) <= (Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c) - Limits.getDMLRows() - 1)) {
            return false;
        }
        return dmlRowsExceeded;
    }
}