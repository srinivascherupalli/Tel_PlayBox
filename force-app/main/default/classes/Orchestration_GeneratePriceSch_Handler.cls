/**================================================================
 * Name: Orchestration_GeneratePriceSch_Handler
 * Created Date: 
 * Created By: 
 ==================================================================*/
global with sharing class Orchestration_GeneratePriceSch_Handler implements Orchestration_StepInterface{
private Map<Id, Charge_Line_Item__c> cliTobeUpdatedMap = new Map<Id, Charge_Line_Item__c>();
  private Map<String, Price_Schedule_Line_Item__c> psliTobeInserted = new Map<String, Price_Schedule_Line_Item__c>();
  private Map<String, Tier_Line_Item__c> tliTobeInserted = new Map<String, Tier_Line_Item__c>();
  private Map<String, Price_Schedule_Discount_Association__c> psdaTobeInserted = new Map<String, Price_Schedule_Discount_Association__c>();
  private Map<String, Set<String>> stepRelationshipMap = new Map<String, Set<String>>();
  private Map<Id, Id> subsToStepMap = new Map<Id, Id>();
  private Map<Id, List<Price_Schedule_Discount_Association__c>> psliPSDAtoBeInsertedMap = new Map<Id, List<Price_Schedule_Discount_Association__c>>();
  private Map<Id, List<Tier_Line_Item__c>> psliTLItoBeInsertedMap = new Map<Id, List<Tier_Line_Item__c>>();
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
  private Id incompleteStepId;
    protected List<SObject> eventsToPublish = new List<SObject>();
    private static Integer count =0;
    private static Integer psdaCnt=0;
    private static Integer tliCnt=0;

  private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();

  private Set<Id> inProgressStepList = new Set<Id>();

  //Stpre the Data Map
  private Map<Id, Set<Id>> subChargeLineItemMap = new Map<Id, Set<Id>>();
  private Map<Id, Charge_Line_Item__c> cliMap = new Map<Id, Charge_Line_Item__c>();
  private Map<Id, List<PricingMSResponseObject__c>> cliToPriceResponseMap = new Map<Id, List<PricingMSResponseObject__c>>();
  private Map<Id, Set<Id>> cliModifySet = new Map<id, Set<Id>>(); /* changed to private */
  Set<Id> cliNewSet = new Set<Id>();
  private Map<Id, Set<Id>> subsServiceMap = new Map<Id, Set<Id>>();
  private Set<Id> servicesSet = new Set<Id>();
    Set<Id> subscriptionIds=new Set<Id>();

  private Map<Id, Blob> serviceAttachmentMap = new Map<Id, Blob>();
    private Map<Id, Orchestration_Technical__c> technicalObjMap = new Map<Id, Orchestration_Technical__c>();
    

  public void processUpdate(String payload) {
    
          List<Orchestration_Technical__c>technicalObjList=new List<Orchestration_Technical__c>();
     
      List<Charge_Line_Item__c> chargeObjList = new List<Charge_Line_Item__c>();

      try {
          Map<String, Object> mapOfPayload = (Map<String, Object>)JSON.deserializeUntyped(payload);
         // List<Object> reqs = (List<Object>)mapOfPayload.get('subscriptionIds');
          String currentSubsRec= String.ValueOf(mapOfPayload.get('Current'));
          
          ////processedIds=(Map<Id, Orchestration_ProcessedRecords>)mapOfPayload.get('ProcessedIds');
          
          Id stepId = (Id)mapOfPayload.get('StepId');
          Id currentId = (Id)currentSubsRec;
          /*for(integer i=0;i<reqs.size();i++){
              String str=(String)reqs[i];
              system.debug(str);
              subscriptionIds.add(str);
          } */
          subscriptionIds.add(currentId);
          //Get the Subscription
            Set<Id>subId = new Set<Id>();
            subId.add(currentId);
            system.debug('SubId### '+subId);          
            List<csord__Subscription__c>subList = Coms_PlatformCacheUtil.getListOfSubscriptionFromCache(subId);
            system.debug('subList### '+subList);
          
        chargeObjList=Coms_PlatformCacheUtil.getListOfChargeLineItem(subscriptionIds);
          system.debug('chargeobjlist '+ chargeObjList);
        for(Charge_Line_Item__c chrgItem:chargeObjList) {
            system.debug('serviceId__r.csord__Subscription__c '+chrgItem.serviceId__r.csord__Subscription__c);
        cliMap.put(chrgItem.Id, chrgItem);
        }
          Object processedRecord = mapOfPayload.get('ProcessedIds');
               String prRecords = JSON.serialize(processedRecord);
               Orchestration_ProcessedRecords processedRecordIds =  (Orchestration_ProcessedRecords) JSON.deserialize(prRecords, Orchestration_ProcessedRecords.class);
        //  Orchestration_ProcessedRecords processedRecordIds = (Orchestration_ProcessedRecords)mapOfPayload.get('ProcessedIds');
        if (processedRecordIds != null) {
              processedIds.put(stepId,processedRecordIds);
          }
      System.debug('cliMap### '+cliMap);
      //Fetching Services where status contains 'Disconnect' and matches passed subscription ids
      for (Charge_Line_Item__c cli : cliMap.values()) {
        servicesSet.add(cli.serviceId__c);

        if (subChargeLineItemMap.containsKey(cli.serviceId__r.csord__Subscription__c)) {
          subChargeLineItemMap.get(cli.serviceId__r.csord__Subscription__c).add(cli.Id);
        } else {
          subChargeLineItemMap.put(cli.serviceId__r.csord__Subscription__c, new Set<Id>{ cli.Id });
        }

        if (subsServiceMap.containsKey(cli.serviceId__r.csord__Subscription__c)) {
          subsServiceMap.get(cli.serviceId__r.csord__Subscription__c).add(cli.serviceId__c);
        } else {
          subsServiceMap.put(cli.serviceId__r.csord__Subscription__c, new Set<Id>{ cli.serviceId__c });
        }

        //divide CLIs to New and Modify for different Operations
        if (cli.serviceId__r.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c == null && cli.serviceId__r.Scenario_Type__c == null) {
          if (cli.status__c != Label.Pricing_Records_Created) {
            cliNewSet.add(cli.Id);
          }
        } else if ((cli.serviceId__r.Scenario_Type__c == null || !cli.serviceId__r.Scenario_Type__c.equalsIgnoreCase('Replace SIM') || !cli.serviceId__r.Scenario_Type__c.equalsIgnoreCase('Change of Mobile Number')) && (cli.Status__c != 'Event Published' || cli.Status__c != Label.Pricing_Records_Created)) {
          Id tmpStepId = subsToStepMap.get(cli.serviceId__r.csord__Subscription__c);
          if (cliModifySet.containsKey(tmpStepId)) {
            cliModifySet.get(tmpStepId).add(cli.id);
          } else {
            cliModifySet.put(tmpStepId, new Set<Id>{ cli.Id });
          }
        }
          system.debug('cliNewSet '+cliNewSet);
      }

      //Query All Pricing MS response Object and populate the map of Sub vs PricingMS
      for (PricingMSResponseObject__c pricingMS : [SELECT Id, CLI_Instance_ID__c, CorrelationId__c, ResponsePayload__c FROM PricingMSResponseObject__c WHERE CLI_Instance_ID__c IN :cliNewSet]) {
       // if (cliMap.get(pricingMS.CLI_Instance_ID__c).CorrelationId__c == pricingMS.CorrelationId__c) {
          if (cliToPriceResponseMap.containsKey(pricingMS.CLI_Instance_ID__c)) {
            cliToPriceResponseMap.get(pricingMS.CLI_Instance_ID__c).add(pricingMS);
          } else {
            cliToPriceResponseMap.put(pricingMS.CLI_Instance_ID__c, new List<PricingMSResponseObject__c>{ pricingMS });
          }
        //}
      }
      System.debug('===> clitpPric' + cliToPriceResponseMap);

      //get all attachments and create their map.
      //retrieve technical object -append TO at the end of correlation id
      system.debug('serviceSet### '+servicesSet);
        technicalObjList = Coms_PlatformCacheUtil.getListofTechnicalObjectFromCache(servicesSet);
        for(Orchestration_Technical__c techObjItem: technicalObjList){
            //if(techObjItem.name=='ServiceSpecifications.json'){
           // if(techObjItem.Field_5__c!=null){
            if(techObjItem.Service__c!=null){
                technicalObjMap.put(techObjItem.Service__c,techObjItem);
            }
        }
     
      System.debug('===> Data Collected');
     
        try {
           System.debug('===> Step Processing');

          
            for(csord__Subscription__c subscription: subList){//= step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r;
                
                if (subscription.csordtelcoa__Replaced_Subscription__c == null) {
                    //Process for the records which are New
                    System.debug('===> NEW ' +subChargeLineItemMap.get(subscription.Id));
                    
                    incompleteStepId = processRecordsforNEW(stepId, subChargeLineItemMap.get(subscription.Id));
                } else {
                    System.debug('===> Modify '+subscription.Id);
                    //process for the Records which have a replaced Sub i.e they are modified.
                    incompleteStepId = processRecordsForModify(stepId, subChargeLineItemMap.get(subscription.Id) /*cliModifySet.get(subscription.Id)*/);
                }
                
                if (incompleteStepId != null) {
                    // break;
                } else if (!stepRelationshipMap.containsKey(stepId)) {
                    mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success - No update required.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                    //stepResults.put(step.Id, new stepResult('Success - No update required.', OrchestratorConstants.OrchestratorStep.Complete));
                }
            }
        } catch (Exception ex) {
          System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));

          //stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
        }
      //}
    } catch (Exception ex) {
      System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
      //for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
      //  stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
     // }
    }

    if ((!cliTobeUpdatedMap.isEmpty() || !psliTobeInserted.isEmpty() || !tliTobeInserted.isEmpty() || !psdaTobeInserted.isEmpty() || !eventsToPublish.isEmpty())) {
      publishObject(null);
      processDMLOperations();
    }
      updateStepStatus();
    //return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
  }

  private Id processRecordsforNEW(Id stepId, Set<Id> cliIds) {
      if (cliIds == null) {          
          return null;
      }
      
      for (Id cliId : cliIds) {          
          if (!Orchestration_LimitsUtility.areLimitsViolated()) {
              
              Boolean statusUpdated = false;
              Boolean billSpecIdUpdated = false;
              Charge_Line_Item__c cli = cliMap.get(cliId);
              System.debug('CLIId### '+cliId);
              String corrId=cli.CorrelationId__c;
              
              if (cliNewSet.contains(cliId)) {
                  List<PricingMSResponseObject__c> pricingResponseRecords = cliToPriceResponseMap.get(cliId);
                  if (pricingResponseRecords == null || pricingResponseRecords.isEmpty()) {
                      inProgressStepList.add(stepId);
                  } else {
                      for (PricingMSResponseObject__c pricingResponseRec : pricingResponseRecords) {
                          Id result = generateChildRecordsForCLI(stepId, pricingResponseRec,corrId);
                          if (result == null) {
                              cli.Status__c = Label.Pricing_Records_Created;
                              statusUpdated = true;
                          } else {
                              return result;
                          }
                      }
                  }
              }
              
              //if (cli.billingSpecIdentifier__c == null && serviceAttachmentMap.containsKey(cli.serviceId__c)) {
              if (cli.billingSpecIdentifier__c == null && technicalObjMap.containsKey(cli.serviceId__c)) {
                  billSpecIdUpdated = getServiceTOCodeGUIDMap(cli, technicalObjMap.get(cli.serviceId__c));
              }
              if (billSpecIdUpdated || statusUpdated) {
                  // if (!hasDMLRowsLimitExceeded()) {
                  if (!Orchestration_LimitsUtility.areLimitsViolated()) {
                    //  cli.isCacheUpdated__c=true;
                      cliTobeUpdatedMap.put(cli.Id, cli);
                      if (!stepRelationshipMap.containsKey(stepId)) {
                          stepRelationshipMap.put(stepId, new Set<String>{ cli.id });
                      } else {
                          stepRelationshipMap.get(stepId).add(cli.Id);
                      }
                  } else {
                      return stepId;
                  }
              }
          }
          else{return stepId;}
      }
      return null;
  }

  private Id processRecordsForModify(Id stepId, Set<Id> cliIds) {
    if (cliIds == null) {
      return null;
    }
    Boolean LimitsHit = false;

    String corelationId = IntegrationRecordHandlerUtil.getCorrelationId();
    boolean containsTieredCharges = false, createEvent = false;
    //udpate the CLI Status to EventPublished and Billing Spec and Correlation Id
    for (Id cliId : cliIds) {
     if (Orchestration_LimitsUtility.areLimitsViolated()) {
        LimitsHit = true;
        break;
      }
      Boolean tobeUpdated = false;
      Charge_Line_Item__c cli = cliMap.get(cliId);
     // if (cli.billingSpecIdentifier__c == null && serviceAttachmentMap.containsKey(cli.serviceId__c)) {
     //  tobeUpdated = getServiceTOCodeGUIDMap(cli, serviceAttachmentMap.get(cli.serviceId__c));
       if (cli.billingSpecIdentifier__c == null && technicalObjMap.containsKey(cli.serviceId__c)) {       
       // technicalObjMap
        tobeUpdated = getServiceTOCodeGUIDMap(cli, technicalObjMap.get(cli.serviceId__c));
      }
      if (cli.status__c != 'Event Published' && cli.status__c != Label.Pricing_Records_Created) {
        createEvent = true;
        cli.CorrelationId__c = corelationId;
        cli.status__c = 'Event Published';

        System.debug(cli + '===>cli');
        //If any of the CLI is NGVoice then setting containsTieredCharges to true
        if (!containsTieredCharges && String.isNotBlank(cli.chargeType__c) && cli.chargeType__c.equalsIgnoreCase(Label.TieredRecurring)) {
          containsTieredCharges = true;
        }
      }
      // else if(cli.status__c == 'Event Published' || cli.status__c == Label.Pricing_Records_Created){
      //     inProgressStepList.add(stepId);
      // }
      if (tobeUpdated || createEvent) {
          //cli.isCacheUpdated__c=true;
        cliTobeUpdatedMap.put(cli.Id, cli);
        if (!stepRelationshipMap.containsKey(stepId)) {
          stepRelationshipMap.put(stepId, new Set<String>{ cli.id });
        } else {
          stepRelationshipMap.get(stepId).add(cli.Id);
        }
      }
      System.debug(stepRelationshipMap + '===>stepRelationshipMap');
    }

    if (createEvent) {
      PriceScheduleEvent__e priceSchEvent = new PriceScheduleEvent__e(eventType__c = 'Request', CorrelationId__c = corelationId, containsTieredCharges__c = containsTieredCharges);
      eventsToPublish.add(priceSchEvent);
    }
    return LimitsHit ? stepId : null;
      //return null;
  }

 // public boolean getServiceTOCodeGUIDMap(Charge_Line_Item__c cli, Blob attBody) {
   public boolean getServiceTOCodeGUIDMap(Charge_Line_Item__c cli, Orchestration_Technical__c techObj) {
    Map<String, String> CodetoGuidMap = new Map<String, String>();
    //List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(attBody.toString()), 'BILLING');
   // for (CS_SpecificationDTO.ServiceSpecification spec : srvspecList) {
     // String code = 'DMCAT_' + spec.code.split('Billing_')[1];
     String businessId=techObj.Field_14__c;
       string guid = techObj.Field_11__c;
     String code = 'DMCAT_' + businessId.split('Billing_')[1];
      //CodetoGuidMap.put(code, spec.guid);
      CodetoGuidMap.put(code, guid);
    //}
    if (CodetoGuidMap != null && !CodetoGuidMap.isEmpty() && CodetoGuidMap.containsKey(cli.BusinessID__c)) {
      cli.billingSpecIdentifier__c = CodetoGuidMap.get(cli.BusinessID__c);
      return true;
    }
   
    return false;
  }

  private void processDMLOperations() {
    //Database.SaveResult[] allResult = new List<Database.SaveResult>();
    //Storing the records
    List<Id> successIds = new List<Id>();
      List<Charge_Line_Item__c> chargeList = new List<Charge_Line_Item__c>();
      List<Price_Schedule_Line_Item__c> priceList = new List<Price_Schedule_Line_Item__c>();
      List<Tier_Line_Item__c> tierList = new List<Tier_Line_Item__c>();
      List<Price_Schedule_Discount_Association__c>discountList = new List <Price_Schedule_Discount_Association__c>();

    //Updating all the CLI records
    if (!cliTobeUpdatedMap.isEmpty()) {
     // allResult = Database.update(cliTobeUpdatedMap.values(), false);
        chargeList.addAll(cliTobeUpdatedMap.values());
          Orchestration_PlatformCacheUtility.updatePlatformCache(chargeList);
          for(Charge_Line_Item__c chrg:chargeList){
              successIds.add(chrg.Id);
          }
    }

    if (!psliTobeInserted.isEmpty()) {
      //Database.SaveResult[] updateResult = Database.insert(psliTobeInserted.values(), false);
      //allResult.addAll(updateResult);
      priceList.addAll(psliTobeInserted.values());
        system.debug('priceList### '+psliTobeInserted.values());
        Orchestration_PlatformCacheUtility.updatePlatformCache(priceList);
         // for(Price_Schedule_Line_Item__c prcItem:priceList){ 
             // system.debug('prcItem '+prcItem);
              successIds.add(priceList[0].Id);
         // }
    }

    //psliTobeInsertedMap.putAll(psliTobeInserted.values());

    if (!tliTobeInserted.isEmpty()) {
      //Database.SaveResult[] updateResult = Database.insert(tliTobeInserted.values(), false);
      //allResult.addAll(updateResult);
      tierList.addAll(tliTobeInserted.values());
        Orchestration_PlatformCacheUtility.updatePlatformCache(tierList);
          for(Tier_Line_Item__c tierItem:tierList){
              successIds.add(tierItem.Id);
          }
    }
    //tliTobeInsertedMap.putAll(tliTobeInserted.values());

    if (!psdaTobeInserted.isEmpty()) {
      //Database.SaveResult[] updateResult = Database.insert(psdaTobeInserted.values(), false);
     // allResult.addAll(updateResult);
         discountList.addAll(psdaTobeInserted.values());
        Orchestration_PlatformCacheUtility.updatePlatformCache(discountList);
          for(Price_Schedule_Discount_Association__c disItem:discountList){
              successIds.add(disItem.Id);
          }
    }
    //psdaTobeInsertedMap.putAll(psdaTobeInserted.values());
    /*String updatedErrorMsg = '';
    for (Database.SaveResult rslt : allResult) {
      if (rslt.isSuccess()) {
        successIds.add(rslt.getId());
      }
      else{//To debug Edge:188143
          for(Database.Error err : rslt.getErrors()) {         
          updatedErrorMsg += rslt.getId()+':' + err.getMessage();
        }        
      }
    }
    allResult.clear();*/
    //TODO to be updated
    Map<String, String> successIdentifiersMap = new Map<String, String>();
    for (String key : psliTobeInserted.keyset()) {
      if (successIds.contains(psliTobeInserted.get(key).Id)) {
        //successIdentifiers.add(mapProcessedCase.get(key).Subject);
        successIdentifiersMap.put(key, psliTobeInserted.get(key).Id);
      }
    }
    for (String key : tliTobeInserted.keyset()) {
      if (successIds.contains(tliTobeInserted.get(key).Id)) {
        //successIdentifiers.add(mapProcessedFLIs.get(key).Subscription__c);
        successIdentifiersMap.put(key, tliTobeInserted.get(key).Id);
      }
    }
    for (String key : psdaTobeInserted.keyset()) {
      if (successIds.contains(psdaTobeInserted.get(key).Id)) {
        successIdentifiersMap.put(key, psdaTobeInserted.get(key).Id);
      }
    }

    for (String stepId : stepRelationshipMap.keySet()) {
      Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
      perStepSuccessIds.mapInsertedRecords = new Map<String, String>();
      Boolean isFailed = false;
      for (String recId : stepRelationshipMap.get(stepId)) {
        if (!successIdentifiersMap.containsKey(recId) && !successIds.contains(recId)) {
          isFailed = true;
        } else if (successIdentifiersMap.containsKey(recId)) {
          perStepSuccessIds.mapInsertedRecords.put(recId, successIdentifiersMap.get(recId));
        }
      }
      /*String errorMessage = 'Error: Unable to process records';
      if (mapStepDetails.containsKey(stepId)) {
        stepResult sr = stepResults.get(stepId);
        if (sr.status == OrchestratorConstants.OrchestratorStep.Error) {
          isFailed = true;
          errorMessage = sr.message;
        }
      }*/

      if (!isFailed && (String.isBlank(IncompleteStepId) || !IncompleteStepId.equals(stepId)) && (!cliModifySet.isEmpty() && cliModifySet.containsKey(stepId))) {
       // stepResults.put(stepId, new stepResult('Waiting for feedback: Event Published', 'Waiting'));
           mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Waiting for feedback: Event Published',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Waiting));
        //move to next step
        continue;
      }

      if (!isFailed && (String.isBlank(IncompleteStepId) || !IncompleteStepId.equals(stepId)) && (inProgressStepList.isEmpty() || !inProgressStepList.contains(stepId))) {
       // stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
         mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
        //move to next step
        continue;
      }
      if (!isFailed && inProgressStepList.contains(stepId)) {
              //  stepResults.put(stepId, new stepResult('In Progress: Not all picing response found yet', OrchestratorConstants.OrchestratorStep.InProgress));
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='In Progress: Not all pricing response found yet',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress));
                //move to next step
                continue;
            }
      //Adding the previous stored ids - error/partial processed case
      if (processedIds.containsKey(stepId) && processedIds.get(stepId).mapInsertedRecords != null) {
        perStepSuccessIds.mapInsertedRecords.putAll(processedIds.get(stepId).mapInsertedRecords);
      }
        String serializedIds = JSON.serialize(perStepSuccessIds, true);

      if (!isFailed && ((!String.isBlank(IncompleteStepId) && IncompleteStepId.equals(stepId)) || inProgressStepList.contains(stepId))) {
        //stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Partial records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.InProgress,JSON__c=serializedIds));
      } else {
          //To debug Edge:188143
        //  if(!String.isEmpty(updatedErrorMsg)){
            //  updatedErrorMsg = updatedErrorMsg.mid(1, 254);
        //stepResults.put(stepId, new stepResult(updatedErrorMsg, OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
        mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: Unable to process records',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error,JSON__c=serializedIds));
                     // stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
        
          }
         // else{
              //stepResults.put(stepId, new stepResult(errorMessage, OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
           //   mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: Unable to process records',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
         // }
      //}
    }
  }

  public void publishObject(List<Orchestration_CallOutResponse> respList) {
    //High value events are queued therefore async
    List<Database.SaveResult> result = EventBus.publish(eventsToPublish);
  }

  private Id generateChildRecordsForCLI(Id stepId, PricingMSResponseObject__c pricingMSResponseObject, String corrId) {
    //TODO Complete Partial processing
     
    if (!String.isBlank(pricingMSResponseObject.ResponsePayload__c)) {
      System.debug('pricingMSResponseObject.ResponsePayload__c   ' + pricingMSResponseObject.ResponsePayload__c);

      ChargeLineItemsDTO chargeLineItemsDTOEM = ChargeLineItemsDTO.parse(pricingMSResponseObject.ResponsePayload__c);
      Orchestration_ProcessedRecords processedRecordIds = processedIds.get(stepId);
      if (chargeLineItemsDTOEM.chargeLineItems != null) {
        for (chargeLineItemsDTO.PriceScheduleLineItem priceScheduleLineItem : chargeLineItemsDTOEM.chargeLineItems.PriceScheduleLineItem) {
          String externalId;
          if (processedRecordIds == null || processedRecordIds.mapInsertedRecords == null || !processedRecordIds.mapInsertedRecords.containsKey(priceScheduleLineItem.Id)) {
           // if (!hasDMLRowsLimitExceeded()) {
              if (!Orchestration_LimitsUtility.areLimitsViolated()){
          count+=1;
              String corId = corrId+'PSLI' +String.valueOf(count);
              Price_Schedule_Line_Item__c priceScheduleLineItemToInsert = new Price_Schedule_Line_Item__c();

              priceScheduleLineItemToInsert.fromPeriod__c = String.valueOf(priceScheduleLineItem.fromPeriod);
              priceScheduleLineItemToInsert.toPeriod__c = String.valueOf(priceScheduleLineItem.toPeriod);
              priceScheduleLineItemToInsert.applicationDuration__c = priceScheduleLineItem.applicationDuration;
              priceScheduleLineItemToInsert.chargeInstance__c = pricingMSResponseObject.CLI_Instance_ID__c;
              priceScheduleLineItemToInsert.status__c = 'New';
              priceScheduleLineItemToInsert.CorrelationId__c = corId;
              system.debug('PSLI### '+priceScheduleLineItem.id);

              if (priceScheduleLineItem.TierLineItems != null && priceScheduleLineItem.TierLineItems.isEmpty()) {
                priceScheduleLineItemToInsert.unitPrice__c = priceScheduleLineItem.unitPrice; //Unit Price will not be applicable for NGUC Voice
              }

              if (priceScheduleLineItem.TierLineItems != null && !priceScheduleLineItem.TierLineItems.isEmpty() || !priceScheduleLineItem.ApplicableDiscounts.isEmpty()) {
                DateTime now = DateTime.now();
                externalId = String.valueOf(now) + String.valueOf(Math.random()); //External Id field to establish initial relation b/w PSLI and TLI
                priceScheduleLineItemToInsert.PSLIExternalId__c = externalId;
              }
              //psliTobeInserted.put(priceScheduleLineItem.id, priceScheduleLineItemToInsert);
              psliTobeInserted.put(corId, priceScheduleLineItemToInsert);
              if (!stepRelationshipMap.containsKey(stepId)) {
                stepRelationshipMap.put(stepId, new Set<String>{ priceScheduleLineItem.id });
              } else {
                stepRelationshipMap.get(stepId).add(priceScheduleLineItem.Id);
              }
            } else {
              return stepId;
            }
          }

          if (priceScheduleLineItem.TierLineItems != null && !priceScheduleLineItem.TierLineItems.isEmpty()) {
            //TLI will be non empty for NGUC Voice
            for (ChargeLineItemsDTO.TierLineItems tierLineItems : priceScheduleLineItem.TierLineItems) {
              String tliId = priceScheduleLineItem.id + '_' + tierLineItems.toUnit + '_' + tierLineItems.fromUnit;
              if (processedRecordIds == null || processedRecordIds.mapInsertedRecords == null || !processedRecordIds.mapInsertedRecords.containsKey(tliId)) {
               // if (!hasDMLRowsLimitExceeded()) {
               if (!Orchestration_LimitsUtility.areLimitsViolated()){
                  Tier_Line_Item__c tierLineItemToInsert = new Tier_Line_Item__c();

                  tierLineItemToInsert.Discounted_Price__c = Decimal.valueOf(tierLineItems.Discounted_Price);
                  tierLineItemToInsert.FromUnit__c = tierLineItems.fromUnit;
                  tierLineItemToInsert.status__c = 'New';
                  tierLineItemToInsert.ToUnit__c = tierLineItems.toUnit;
                  tierLineItemToInsert.fromPeriod__c = String.valueOf(priceScheduleLineItem.fromPeriod);
                  tierLineItemToInsert.toPeriod__c = String.valueOf(priceScheduleLineItem.toPeriod);
                  if (processedRecordIds != null && processedRecordIds.mapInsertedRecords != null && processedRecordIds.mapInsertedRecords.containsKey(priceScheduleLineItem.Id)) {
                    tierLineItemToInsert.PSLIInstance__c = processedRecordIds.mapInsertedRecords.get(priceScheduleLineItem.Id);
                  } else {
                      count+=1;
                    String corId = corrId + 'PSLI' +String.valueOf(count);
                      system.debug('corId### '+corId);
                    tierLineItemToInsert.PSLIInstance__r = new Price_Schedule_Line_Item__c(PSLIExternalId__c = externalId,CorrelationId__c=corId,chargeInstance__c = pricingMSResponseObject.CLI_Instance_ID__c);
                      psliTobeInserted.put(CorrId, tierLineItemToInsert.PSLIInstance__r);
                  }
                   tliCnt+=1;
                   String corId = corrId + 'PSLI' +String.valueOf(count)+'TLI' +String.valueOf(tliCnt);
                   tierLineItemToInsert.CorrelationId__c=corId;
                  tierLineItemToInsert.appliedDiscountAmount__c = Decimal.valueOf(tierLineItems.appliedDiscountAmount); //Added for EDGE-139696
                  tierLineItemToInsert.rateCardLineIdentifier__c = String.valueOf(tierLineItems.rateCardLineIdentifier); //Added for EDGE-139696
                  tliTobeInserted.put(tliId, tierLineItemToInsert);
                  if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new Set<String>{ tliId });
                  } else {
                    stepRelationshipMap.get(stepId).add(tliId);
                  }
                } else {
                  return stepId;
                }
              }
            }
          }

          if (priceScheduleLineItem.ApplicableDiscounts != null && !priceScheduleLineItem.ApplicableDiscounts.isEmpty()) {
            for (ChargeLineItemsDTO.ApplicableDiscounts applicableDiscounts : priceScheduleLineItem.ApplicableDiscounts) {
              if (processedRecordIds == null || processedRecordIds.mapInsertedRecords == null || !processedRecordIds.mapInsertedRecords.containsKey(priceScheduleLineItem.id + '_' + applicableDiscounts.Id)) {
                //if (!hasDMLRowsLimitExceeded()) {
                if (!Orchestration_LimitsUtility.areLimitsViolated()){
                  Price_Schedule_Discount_Association__c priceScheduleDiscountAssociation = new Price_Schedule_Discount_Association__c();
                  priceScheduleDiscountAssociation.discountInstance__c = applicableDiscounts.id;

                  if (processedRecordIds != null && processedRecordIds.mapInsertedRecords != null && processedRecordIds.mapInsertedRecords.containsKey(priceScheduleLineItem.Id)) {
                    priceScheduleDiscountAssociation.priceScheduleInstance__c = processedRecordIds.mapInsertedRecords.get(priceScheduleLineItem.Id);
                  } else {
                    priceScheduleDiscountAssociation.priceScheduleInstance__r = new Price_Schedule_Line_Item__c(PSLIExternalId__c = externalId);
                  }
                  psdaCnt+=1;
                  String corId = corrId + 'PSLI' +String.valueOf(count)+'PSDA' +String.valueOf(psdaCnt);
                  priceScheduleDiscountAssociation.CorrelationId__c=corId;

                  priceScheduleDiscountAssociation.isActive__c = true;
                  if (applicableDiscounts.appliedDiscountAmount != null) {
                    priceScheduleDiscountAssociation.appliedDiscountAmount__c = applicableDiscounts.appliedDiscountAmount;
                  }
                  psdaTobeInserted.put(priceScheduleLineItem.id + '_' + applicableDiscounts.Id, priceScheduleDiscountAssociation);
                  if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new Set<String>{ priceScheduleLineItem.id + '_' + applicableDiscounts.Id });
                  } else {
                    stepRelationshipMap.get(stepId).add(priceScheduleLineItem.id + '_' + applicableDiscounts.Id);
                  }
                } else {
                  return stepId;
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

 /* public override boolean hasDMLRowsLimitExceeded() {
    boolean dmlRowsExceeded = true;
    if ((eventsToPublish.size() + psdaTobeInserted.size() + tliTobeInserted.size() + psliTobeInserted.size() + cliTobeUpdatedMap.size() <= (Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c) - Limits.getDMLRows() - 1))) {
      return false;
    }
    return dmlRowsExceeded;
  }*/
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