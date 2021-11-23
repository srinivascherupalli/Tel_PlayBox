/**================================================================
* Name: Orchestration_UpdSubsData_Handler
* Description: Class to update subscription details from platformcache to database
* ================================================================*/
global with sharing class Orchestration_UpdSubsData_Handler implements Orchestration_StepInterface{
    private List<CSPOFA__Orchestration_Step__c> stepList= new List<CSPOFA__Orchestration_Step__c>();
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
    private final List<String> orchestrationProcessesList = new List<String>{
        OrchestratorConstants.OrchesTemplateName.svcFulfillmentProvision,
            OrchestratorConstants.OrchesTemplateName.svcFulfillmentActivation,
            OrchestratorConstants.OrchesTemplateName.autoCompleteSubsTemplate,
            OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate
            };
                private Map<String, Price_Schedule_Discount_Association__c> psdaTobeInserted = new Map<String, Price_Schedule_Discount_Association__c>();
    private Map<Id, Charge_Line_Item__c> chargeLineItemToUpdate = new Map<Id, Charge_Line_Item__c>();
    private Map<Id, Discount_Line_Item__c> discountLineItemToUpdate = new Map<Id, Discount_Line_Item__c>();
    private Map<Id, Price_Schedule_Line_Item__c> priceSchedLineItemToUpdate = new Map<Id, Price_Schedule_Line_Item__c>();
    private Map<Id, Tier_Line_Item__c> tierLineItemToUpdate = new Map<Id, Tier_Line_Item__c>();
    private Map<Id, csord__Subscription__c> subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
    private Map<Id, Billing_Account__c> billingAccountsToUpdate = new Map<Id, Billing_Account__c>();
    private List<SObject> sObjectsToInsert = new List<SObject>();
    private Map<Id, Number__c> numbersToUpdate = new Map<Id, Number__c>();
    private set<Id> cacheNotUpdated = new set<Id>();
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    list<CSPOFA__Orchestration_Process__c> subOrchesProcess =  new list<CSPOFA__Orchestration_Process__c>();
    // Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = CS_OrchUtils.getorchesTemplates();
    
    private String IncompleteStepId = '';
    private Set<String>subsNumbers=new Set<String>();
    private Set<Id>billAccId=new Set<Id>();
    private Set<Id>subscriptionIds=new Set<Id>();
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    public void processUpdate(String payload){
        // stepList= (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
        List<csord__Subscription__c>subscriptionList= new List<csord__Subscription__c>();
        
        Map<String, Object> mapOfPayload = (Map<String, Object>)JSON.deserializeUntyped(payload);
        Id subscriptionId=(Id)mapOfPayload.get('subscriptionId');
        String orchestrationName = String.valueOf(mapOfPayload.get('OrchName'));
        system.debug('orchestrationName '+orchestrationName);
        Id stepId = (Id)mapOfPayload.get('StepId');
        // getRelatedSubscriptionIds(stepList);
        try{
            //system.debug('subscriptionIds '+subscriptionIds);
            
            subscriptionIds.add(subscriptionId);
            Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = Orchestration_Utility.getOrchestrationTemplates(orchestrationProcessesList);
            system.debug('orchesTemplates '+orchesTemplates);
            List<csord__Subscription__c>subDBList = [SELECT Id,LastModifiedDate,Billing_Account__c, csordtelcoa__Subscription_Number__c from csord__Subscription__c where Id =:subscriptionId];
            List<Charge_Line_Item__c> chrListDB=[SELECT Id, LastModifiedDate,status__c, serviceId__r.csord__Subscription__c, chargeType__c, BusinessID__c, CorrelationId__c, serviceId__r.Scenario_Type__c, billingSpecIdentifier__c, serviceId__r.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c, serviceId__c FROM Charge_Line_Item__c WHERE serviceId__r.csord__Subscription__c =:subscriptionId];
            /*List<Discount_Line_Item__c>discountListDB=[];
List<Price_Schedule_Line_Item__c>pschListDB=[];
List<Price_Schedule_Discount_Association__c>psdaListDB=[];
List<Tier_Line_Item__c>tierListDB=[];*/
            List<csord__Subscription__c> subList = Coms_PlatformCacheUtil.getListOfSubscriptionFromCache(subscriptionIds);
            
            
            
            
            
            
           
            //getPriceScheduleLineItem
            system.debug('DBtimestamp '+subDBList);
            system.debug('PCTimestamp '+subList);
            if(subList.size()> 0)
                subscriptionList.addAll(subList);
            
            // for(CSPOFA__Orchestration_Step__c step : stepList) {
            for (csord__Subscription__c subDB: subDBList){
                for(csord__Subscription__c sub: subscriptionList){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    
                    // if(sub.isCacheUpdated__c == true){
                    if (subDB.LastModifiedDate <= sub.Platform_Cache_Timestamp__c){
                        //sub.isCacheUpdated__c=false;
                        subscriptionsToUpdate.put(sub.Id,sub);
                        stepRelationship.put(sub.Id, stepId);
                    }
                    else{
                        //call orchestration process again
                        //String subfulfilmentprocess =step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name; //'Subscription Fulfillment Process_Provision';
                        cacheNotUpdated.add(sub.Id);                    
                        
                    } 
                   // }                  
                    
                    //}
                }   
                subsNumbers.add(subDB.csordtelcoa__Subscription_Number__c);
                    billAccId.add(subDB.Billing_Account__c);
            }
            //update charge line item
            List<Charge_Line_Item__c> chrgList = Coms_PlatformCacheUtil.getListOfChargeLineItem(subscriptionIds);
            system.debug('chrgList '+chrgList);
            system.debug('chrListDB '+chrListDB);
            for (Charge_Line_Item__c chrgDB: chrListDB){
                for(Charge_Line_Item__c chrg: chrgList){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                  //   if(chrg.isCacheUpdated__c == true){
                    if (chrgDB.LastModifiedDate <= chrg.Platform_Cache_Timestamp__c){
                        //chrg.isCacheUpdated__c=false;
                        chargeLineItemToUpdate.put(chrg.Id,chrg);
                        stepRelationship.put(chrg.Id, stepId);
                    }
                    else{
                        cacheNotUpdated.add(subscriptionId);
                        
                    } 
                   // }
                    
                    
                }   
            }
            //insert discount line item
            List<Discount_Line_Item__c>discountListCache=Coms_PlatformCacheUtil.getListOfDiscountLineItem(subscriptionIds);
            if(discountListCache.size()>0){
                
                for(Discount_Line_Item__c disItem:discountListCache){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    discountLineItemToUpdate.put(disItem.Id,disItem);
                }
            }
            //insert price schedule line item
            List<Price_Schedule_Line_Item__c>pschListCache=Coms_PlatformCacheUtil.getPriceScheduleLineItem(subscriptionIds);
            if(pschListCache.size()>0){
                for(Price_Schedule_Line_Item__c pschItem:pschListCache){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    priceSchedLineItemToUpdate.put(pschItem.Id,pschItem);
                }
            }
            //insert tier line item
            List<Tier_Line_Item__c>tierListCache=Coms_PlatformCacheUtil.getListOfTierLineItem(subscriptionIds);
            if(tierListCache.size()>0){
                for(Tier_Line_Item__c tierItem:tierListCache){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    tierLineItemToUpdate.put(tierItem.Id,tierItem);
                }
            }
            //insert price schedule association
            List<Price_Schedule_Discount_Association__c>psdaListCache=Coms_PlatformCacheUtil.getListOfPriceScheduleDiscountAssocItem(subscriptionIds);
            if(psdaListCache.size()>0){
                for(Price_Schedule_Discount_Association__c psdaItem:psdaListCache){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    psdaTobeInserted.put(psdaItem.Id,psdaItem);
                }
            }
            //insert number
            system.debug('subsNumbers '+subsNumbers);
            List<Number__c>numListDB=[SELECT id, LastModifiedDate,name, Service_Number__c, Status__c, Subscription_number__c, Product_ID__c FROM Number__c WHERE Subscription_number__c IN :subsNumbers]; //and Mobile__c != 'Fixed'];
            List<Number__c>numListCache=Coms_PlatformCacheUtil.getNumberListFromCache(subscriptionIds);
            system.debug('numListCache '+numListCache);
            system.debug('numListDB '+numListDB);
            for (Number__c numItemDB: numListDB){
                for(Number__c numItem: numListCache){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                   // if(numItem.isCacheUpdated__c == true){
                    if (numItemDB.LastModifiedDate <= numItem.Platform_Cache_Timestamp__c){
                       // numItem.isCacheUpdated__c=false;
                        numbersToUpdate.put(numItem.Id,numItem);
                        stepRelationship.put(numItem.Id, stepId);
                    }
                    else{
                        cacheNotUpdated.add(subscriptionId);
                        
                    } 
                    //}
                    
                    
                }   
            }
        /*    List<Billing_Account__c>billAccCacheList=new List<Billing_Account__c>();//Coms_PlatformCacheUtil.getListOfBillingAccount(subscriptionIds);
            List<Billing_Account__c>billAccListDB=[SELECT id, name,Status__c,isUpdated__c FROM Billing_Account__c where Id IN :billAccId];
            for (Billing_Account__c billItemDB: billAccListDB){
                for(Billing_Account__c billItem: billAccCacheList){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                  //   if(billItem.isCacheUpdated__c == true){
                    if (billItemDB.LastModifiedDate <= billItem.Platform_Cache_Timestamp__c){
                      //  billItem.isCacheUpdated__c=false;
                        billingAccountsToUpdate.put(billItem.Id,billItem);
                        stepRelationship.put(billItem.Id, stepId);
                    }
                    else{
                        cacheNotUpdated.add(subscriptionId);
                        
                    } 
                  //  }                   
                }   
            }*/
             system.debug('cachenotupdated '+orchesTemplates.get(orchestrationName));
            if(cacheNotUpdated!=null){
                for(Id subsId:cacheNotUpdated){
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    CSPOFA__Orchestration_Process__c subscriptionOrches = new CSPOFA__Orchestration_Process__c() ;
                    subscriptionOrches = createOrchestrationProcess(orchesTemplates.get(orchestrationName).id,subsId);
                    //subOrchesProcess.add(subscriptionOrches); 
                    sObjectsToInsert.add(subscriptionOrches);
                    stepRelationship.put(subsId, stepId);
                }
            }
            
            //}
            
        }
        catch(exception e){
            system.debug('Failed in Update Subscription Data step'+e);
            //for (CSPOFA__Orchestration_Step__c step : stepList) {
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + e.getMessage() + ' on line ' + e.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
            //  stepResults.put(stepId, new stepResult('Error: ' + e.getMessage() + ' on line ' + e.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, e.getStackTraceString()));
            //}
        }
        // if(sObjectsToInsert.size()>0)
        //insert subOrchesProcess;
        insertOrchestrationProcess();
        //else if(sObjectsToUpdate.size()>0)
        //updateObjectsFromPlatformCache();
        updateObjects(); //commented for test coverage
        updateStepStatus();
        // else
        // for (CSPOFA__Orchestration_Step__c step : stepList) {
        //  stepResults.put(step.Id, new stepResult('Success: No Records to process', OrchestratorConstants.OrchestratorStep.Complete));
        // }
        //return processStepResults((List<CSPOFA__Orchestration_Step__c>) stepList, stepResults);
    }
    
    //Method to re-instantiate the orchestration process to get the latest data from DB
    public void insertOrchestrationProcess(){
        if(sObjectsToInsert.size() > 0){
            Database.SaveResult[] insertRslt = Database.insert(sObjectsToInsert, false);
            for (Database.SaveResult rslt : insertRslt) {                
                if (rslt.isSuccess()) {
                    system.debug('Success: Created Orchestration process'+rslt.getId());
                    mapStepDetails.put(stepRelationship.get(rslt.getId()),new CSPOFA__Orchestration_Step__c(Id=stepRelationship.get(rslt.getId()),CSPOFA__Message__c='Success: Created Orchestration process.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                    //stepResults.put(stepRelationship.get(rslt.getId()),           
                    //   new stepResult('Success: Created Orchestration process', OrchestratorConstants.OrchestratorStep.Complete)
                    //  );
                } else {
                    system.debug('Error: Unable to create orcestration process' +rslt.getId());
                    //record updation failed there related step updated
                    mapStepDetails.put(stepRelationship.get(rslt.getId()),new CSPOFA__Orchestration_Step__c(Id=stepRelationship.get(rslt.getId()),CSPOFA__Message__c='Error: Unable to create orchestration process.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                    // stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to create orchestration process', OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        }
    }
    /*  public void updateObjectsFromPlatformCache() {
List<Id> subsSuccessIds = new List<Id>();
List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();

if (sObjectsToUpdate.size() > 0) {           
Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);            
for (Database.SaveResult rslt : updateResult) {                
if (rslt.isSuccess()) {
mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Subscription records updated',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
//stepResults.put(stepRelationship.get(rslt.getId()),           
//               new stepResult('Success: Subscription records updated', OrchestratorConstants.OrchestratorStep.Complete)
//               );
} else {
//record updation failed there related step updated
mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: Unable to update records to database',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
//stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to update records to database', OrchestratorConstants.OrchestratorStep.Error));
}
}
}       
}*/
    
     public void updateObjects() {
        //Success DML order Ids
        List<Id> successIds = new List<Id>();
        //List<Id> subscriptionSuccessIds = new List<Id>();
        //List<Id> billingAccSuccessIds = new List<Id>();
        //List<Id> cLISuccessIds = new List<Id>();
        //List<Id> dSLISuccessIds = new List<Id>();
        //List<Id> pSLISuccessIds = new List<Id>();
        //List<Id> tLISuccessIds = new List<Id>();
        List<Id> numbersSuccessIds = new List<Id>();
        //Updating all the subscription records
        //system.debug('subscriptionsToUpdate===>>>'+subscriptionsToUpdate);
        if (subscriptionsToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(subscriptionsToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //subscriptionSuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        //system.debug('billingAccountsToUpdate===>>>'+billingAccountsToUpdate);
        /*if (billingAccountsToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(billingAccountsToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //billingAccSuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }*/
        //Updating all the order records
        if (chargeLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(chargeLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //cLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (discountLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(discountLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //dSLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (priceSchedLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(priceSchedLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //pSLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (tierLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(tierLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //tLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        if (psdaTobeInserted.size() > 0) {
            Database.SaveResult[] updateResult = Database.insert(psdaTobeInserted.values(), false);
            //allResult.addAll(updateResult);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //tLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (numbersToUpdate.size() > 0) {
            system.debug('inside if:');
            List<Database.SaveResult> updateResult = Database.update(numbersToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    numbersSuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        system.debug('numbersSuccessIds'+numbersSuccessIds);
        system.debug('successIds'+successIds);
        //Iteration over each step, processed Id check is not required
        for (Id stepId : stepRelationship.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the orderids Set
            perStepSuccessIds.numberIds = new Set<String>();
            Boolean isFailed = false;
            // for (Id recId : stepRelationship.get(stepId)) {
            if(numbersSuccessIds.size()>0 && numbersSuccessIds.contains(stepRelationship.get(stepId))){
                perStepSuccessIds.numberIds.add(stepRelationship.get(stepId));
                system.debug('inside if568');
            }else if (successIds.size() > 0 && !successIds.contains(stepRelationship.get(stepId))){
                //Failure
                isFailed = true;
                system.debug('isFailed571'+isFailed);
            }
            // }
            String errorMessage = 'Error: Unable to process records';
            if (mapStepDetails.containsKey(stepId)) {
                CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
                // stepResult sr = stepResults.get(stepId);
                if (stepDetails.CSPOFA__Status__c == OrchestratorConstants.OrchestratorStep.Error) {
                    isFailed = true;errorMessage = stepDetails.CSPOFA__Status__c;
                    system.debug('isFailed579'+isFailed);
                    
                }
            }
            if (!isFailed){// && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                if(mapStepDetails!=null && mapStepDetails.containsKey(stepId)){
                    CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
                    stepDetails.CSPOFA__Message__c = 'Success: Records processed';
                    stepDetails.CSPOFA__Status__c = OrchestratorConstants.OrchestratorStep.Complete;
                }else{
                    //Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
                    mapStepDetails.put(stepRelationship.get(stepId), new CSPOFA__Orchestration_Step__c(Id=stepRelationship.get(stepId),CSPOFA__Message__c='Success: Records processed', CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                }
                //move to next step
                continue;
            }
            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).numberIds != null) {
                perStepSuccessIds.numberIds.addAll(processedIds.get(stepId).numberIds);
            }
            String serializedIds = JSON.serialize(perStepSuccessIds, true);
            if (!isFailed ){//&& !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                if(mapStepDetails!=null && mapStepDetails.containsKey(stepId)){
                    CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
                    stepDetails.CSPOFA__Message__c = 'Success: Partial records processed';                   
                    stepDetails.CSPOFA__Status__c = OrchestratorConstants.OrchestratorStep.InProgress;                    
                    stepDetails.JSON__c = serializedIds;
                }else{
                    mapStepDetails.put(stepRelationship.get(stepId), new CSPOFA__Orchestration_Step__c(Id=stepRelationship.get(stepId),CSPOFA__Message__c='Success: Partial records processed', CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress, JSON__c=serializedIds));
                }
            } else {
                if(mapStepDetails!=null && mapStepDetails.containsKey(stepId)){
                    CSPOFA__Orchestration_Step__c stepDetails = mapStepDetails.get(stepId);
                    stepDetails.CSPOFA__Message__c = errorMessage;                    
                    stepDetails.CSPOFA__Status__c = OrchestratorConstants.OrchestratorStep.Error;                    
                    stepDetails.JSON__c = serializedIds;
                }else{
                    mapStepDetails.put(stepRelationship.get(stepId), new CSPOFA__Orchestration_Step__c(Id=stepRelationship.get(stepId),CSPOFA__Message__c=errorMessage, CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error, JSON__c=serializedIds));
                }
            }
        }
    }
    public static CSPOFA__Orchestration_Process__c createOrchestrationProcess(Id templateid,Id SubscriptionId){        
        CSPOFA__Orchestration_Process__c orches;
        if(templateid!=null){
            orches  = new CSPOFA__Orchestration_Process__c();            
            orches.CSPOFA__State__c = 'Active';            
            if(SubscriptionId!=null){
                orches.csordtelcoa__Subscription__c = SubscriptionId;}            
            orches.CSPOFA__Orchestration_Process_Template__c =templateid;
        }        
        return orches;
    }
    public void updateStepStatus(){
        //CSPOFA__Orchestration_Step__c step = [Select id,CSPOFA__Message__c,CSPOFA__Status__c from CSPOFA__Orchestration_Step__c where id=:stepid];
        List<Database.SaveResult> updateResult = Database.update(mapStepDetails.values(), false);
      // step.CSPOFA__Message__c= msg;
       // step.CSPOFA__Status__c=stepStatus; 
        //update step;
        for(Database.SaveResult result: updateResult){
            if (result.isSuccess()) {
                System.debug('Successfully updated step status ==> ' + result );
            } else {
                for(Database.Error err : result.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage()); 
                }
            }
        }
    }
}