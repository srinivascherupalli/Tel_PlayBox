/**
*  Purpose          :   This class is used to create Subscription, Service, Attachment on the basis of Attachment on Product Configurations in two ways: DTO or NGUC.
*
*  Author          :   Gaurang Maheshwari
*
*  Created Date    :   16 June 2020
*
*  Current Version :   V_1.0
*
*  Revision Log    :   V_1.0 - Gaurang Maheshwari (16 June 2020) - Created/Optimised
*     Developer             Date         Changes
*     Martand Atrey      28/07/2020      Added Parent Id to the Attachment [EDGE-165190]
* Dheeraj Bhatt /Veena   09/10/2020      Capture Service Level Preference for all data plans as email 
*                                        and primary billing contact email as default during order generation for New/MAC orders
* Mukta Wadhwani         18-02-2021      Commented logic to Stop creation of Legacy Transition UC product for EDGE-133470
*/
global with sharing class Orchestration_CreateLegacyService extends Orchestration_AbstractStepHandler {
    public Map<String, String> stepmap = new Map<String, String>();
    private Database.SaveResult[] result = new List<Database.SaveResult>();
    public Map<String, CSPOFA__Orchestration_Step__c> mapSetp = new Map<String, CSPOFA__Orchestration_Step__c>();
    static Map<String, List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>> servlistmap = null;
    static Map<String, List<TransitionDataDTO.serviceDTOMobile>> ngUcServiceListMap = null;
    //static Map<String, String> mapProcessedServicesWOAttach = new  Map<String, String>();
    static Map<String, String> mapProcessedSubscriptionWOSrvc = new Map<String, String>();
    
    Set<String> failedOrders = new Set<String>();
    Set<String> failedStep = new Set<String>();
    
    public Map<String, CSPOFA__Orchestration_Step__c> mapStep = new Map<String, CSPOFA__Orchestration_Step__c>();
    public Map<String, Orchestration_ProcessedRecords> mapStepWithProcessedData = new Map<String, Orchestration_ProcessedRecords>();
    public Map<String, Set<String>> mapProcessed = new Map<String, Set<String>>();
    
    //Map to store Sobject w.r.t. uniqueId
    public static Map<String, Sobject> mapNGUCSubscriptionToInsert = new Map<String, Sobject>();
    public static Map<String, Sobject> mapNGUCServiceToInsert = new Map<String, Sobject>();
    public static Map<String, Sobject> mapDTOSobjectToInsert = new Map<String, Sobject>();
    
    public static Map<String, Sobject> mapAttachmentToInsert = new Map<String, Sobject>();
    public List<Sobject> attachmentsToInsert = new List<Sobject>();
    
    //Map to store uniqueId w.r.t. OrderId
    public Map<String, String> uniqueIdToOrder = new Map<String, String>();
    
    Map<String, Orchestration_ProcessedRecords> mapProcessedData;
    
    List<CSPOFA__Orchestration_Step__c> stepList;
    
    public Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    
    private Map<Id, Orchestration_AttachmentWrapper> mapServiceToAttachment = new Map<Id, Orchestration_AttachmentWrapper>();
    private Map<Id, List<csord__Service__c>> mapOrderToServices = new Map<Id, List<csord__Service__c>>();
    private Map<Id, csord__Subscription__c> mapSubscriptions;
    private Id IncompleteStepId = null;
    //private Map<Id, Id> stepRelationshipMap = new Map<Id, Id>();
    private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
   
    /**
* @description     :   This method is inherited from AbstractStepHandlers to do further processing
*
* @param           :   List<Sobject>
*
* @return          :   List<Sobject>
**/
    public override List<sObject> process(List<sObject> data) {
        //system.debug('step runnning...........');
        //Check if any limits hit then return execution
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            system.debug('stopping execution as limit breached.....');
            return null;
        }
        
        try {
            //Type caste Sobject into Steps
            stepList = getStepList(data);
            
            createLegacyServices(orderIds);
            
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    //Populate all the record Ids that are processed already
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    
                    if (mapOrderToServices.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                        Boolean isAllServiceWAttachment = false;
                        for (csord__Service__c service : mapOrderToServices.get(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                IncompleteStepId = step.Id;
                                break;
                            }
                            
                            if (mapServiceToAttachment.containsKey(service.Id)) {
                                isAllServiceWAttachment = true;
                                Orchestration_AttachmentWrapper currentAttachment = mapServiceToAttachment.get(service.Id);
                                
                                if (currentAttachment.attchName == System.label.DTOName) {
                                    ReplicatorGetServiceDataObject_V2 AttchedServiceDTO = ReplicatorGetServiceDataObject_V2.parse(currentAttachment.attchBody.toString());
                                    LegacyServiceList(AttchedServiceDTO, service.csord__Subscription__c, service.csord__Order__c, step.Id);
                                } 
                                /*Commented for EDGE-133470 TO Stop creation of Legacy Transition UC product 
                                else if (currentAttachment.attchName == System.label.NgUcTransitionName) {
                                    TransitionDataDTO transitionNGUC = TransitionDataDTO.parse(currentAttachment.attchBody.toString());
                                    ngUCLegacyServiceList(transitionNGUC, service.csord__Subscription__c, service.csord__Order__c, step.Id);
                                }*/
                            }
                        }
                        
                        if ((IncompleteStepId == null || (IncompleteStepId != null && IncompleteStepId != step.Id)) && !isAllServiceWAttachment) {
                            stepResults.put(step.Id, new stepResult('Success: Order related Legacy Services does not have Attachment', OrchestratorConstants.OrchestratorStep.Complete));
                        } else if (!stepRelationshipMap.containsKey(step.Id)) {
                            //system.debug('just after the statement');
                            stepResults.put(step.Id, new stepResult('Success - No update required as no transition records found to update or insert', OrchestratorConstants.OrchestratorStep.Complete));
                        }
                    } else {
                        stepResults.put(step.Id, new stepResult('Success: Not associated to any Service', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
            
            if ( !mapNGUCSubscriptionToInsert.isEmpty() || !mapNGUCServiceToInsert.isEmpty() || !mapDTOSobjectToInsert.isEmpty() || !mapAttachmentToInsert.isEmpty()) {
                //processDMLOperations();
                insertObjects();
            }
            
            return processStepResults(stepList, stepResults);
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        return processStepResults(stepList, stepResults);
    }
    
    public void createLegacyServices(Set<Id> orderIds) {
       mapSubscriptions = new Map<Id, csord__Subscription__c>([SELECT Id, csord__Order__c FROM csord__Subscription__c WHERE csord__Order__c IN :orderIds]);
        
        Map<Id, Set<Id>> PCRToServicecIdMap = new Map<Id, Set<Id>>();
        Map<Id, csord__Service__c> mapServices = new Map<Id, csord__Service__c>();
        
        //Method to create legacy services on connected workplace subscription
        for (csord__Service__c serv : [
            SELECT id, csord__Subscription__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c,csordtelcoa__Service_Number__c,mainCharge__r.Type__c, csordtelcoa__Product_Configuration__r.cssdm__solution_association__r.Name,csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Subscription__r.csord__Order__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c, csordtelcoa__Product_Configuration__c, csord__Order__c
            FROM csord__Service__c
            WHERE csord__Subscription__c IN :mapSubscriptions.keyset() AND csordtelcoa__Product_Configuration__c != null
        ]) {
            /** QUESTION: Can we have more than one Services on a Product Configuration **/
            if (PCRToServicecIdMap.containsKey(serv.csordtelcoa__Product_Configuration__c)) {
                PCRToServicecIdMap.get(serv.csordtelcoa__Product_Configuration__c).add(serv.id);
            } else {
                PCRToServicecIdMap.put(serv.csordtelcoa__Product_Configuration__c, new Set<Id>{ serv.id });
            }
            mapServices.put(serv.Id, serv);
            
            if (!mapOrderToServices.containsKey(serv.csord__Subscription__r.csord__Order__c)) {
                mapOrderToServices.put(serv.csord__Subscription__r.csord__Order__c, new List<csord__Service__c>());
            }
            mapOrderToServices.get(serv.csord__Subscription__r.csord__Order__c).add(serv);
        }
        
        //system.debug('@@PCRToSubscriptionIdMap@@' + PCRToServicecIdMap);
        //system.debug('@@PC_To_PCR_Map@@'+PC_To_PCR_Map);
        
        Map<id, ReplicatorGetServiceDataObject_V2> DTO_to_PcrMap = new Map<id, ReplicatorGetServiceDataObject_V2>();
        Map<Id, TransitionDataDTO> ngUCPcrMap = new Map<Id, TransitionDataDTO>();
        
        for (Attachment atchmnt : [SELECT ID, name, body, parentId FROM Attachment WHERE parentId IN :PCRToServicecIdMap.keySet() AND (name = :System.label.DTOName OR name = :System.label.NgUcTransitionName)]) {
            for (String servId : PCRToServicecIdMap.get(atchmnt.parentId)) {
                mapServiceToAttachment.put(servId, new Orchestration_AttachmentWrapper(atchmnt.Id, atchmnt.Name, atchmnt.body));
            }
        }
    }
    /*Commented for EDGE-133470 TO Stop creation of Legacy Transition UC product 
    public void ngUCLegacyServiceList(TransitionDataDTO transitionDTO, ID SubscrptionID, Id OrderID, String stepId) {
        Map<Sobject, Sobject> mapServiceWithAttachment = new Map<Sobject, Sobject>();
        
        Map<String, TransitionDataDTO.serviceDTOMobile> serviceAndServiceDTOMap = new Map<String, TransitionDataDTO.serviceDTOMobile>();
        Map<String, String> nameValueMap = new Map<String, String>();
        List<csord__Service__c> servListTobeInserted = new List<csord__Service__c>();
        //List<String> siteADBORID = new List<String>();
        
        List<csord__Subscription__c> subListTobeInserted = new List<csord__Subscription__c>();
        ngUcServiceListMap = new Map<String, List<TransitionDataDTO.serviceDTOMobile>>();
        
        JSONGenerator PrimaryFNN = JSON.createGenerator(true);
        
        Map<String, List<csord__Subscription__c>> mapOrderSubIdWithSubs = new Map<String, List<csord__Subscription__c>>();
        
        Orchestration_ProcessedRecords existingProcessedRecords = processedIds.containsKey(stepId) ? processedIds.get(stepId) : null;
        //String uniqueCombo = orderWrap.OrderId + '#' + orderWrap.SubscriptionId;
        for (TransitionDataDTO.productListDTO productList : transitionDTO.productList) {
            for (TransitionDataDTO.SiteDTOMobile siteDTO : productList.site) {
                List<TransitionDataDTO.serviceDTOMobile> servList1 = new List<TransitionDataDTO.serviceDTOMobile>();
                
                for (TransitionDataDTO.serviceListDTOMobile serviceListDTO : siteDTO.serviceList) {
                    for (TransitionDataDTO.groupDTOMobile groupDTO : serviceListDTO.groupType) {
                        if (Orchestration_LimitsUtility.areLimitsViolated()) {
                            IncompleteStepId = stepId;
                            break;
                        }
                        
                        //System.debug('serviceListDTO.groupType ::' + groupDTO);
                        
                        String uniqueId = System.Label.LegacySubscriptionName + ' ' + groupDTO.groupId + '#' + SubscrptionID + '::' + OrderID;
                        //System.debug('uniqueId :::' + uniqueId);
                        uniqueIdToOrder.put(uniqueId, OrderID);
                        csord__Subscription__c newSub;
                        
                        //System.debug('existingProcessedRecords ::' + existingProcessedRecords);
                        
                        if (groupDTO.checkValue == true && !hasDMLRowsLimitExceeded() && (existingProcessedRecords == null || (existingProcessedRecords.mapInsertedRecords != null && !existingProcessedRecords.mapInsertedRecords.containsKey(uniqueId)))) {
                            newSub = new csord__Subscription__c();
                            newSub.Name = System.Label.LegacySubscriptionName + ' ' + groupDTO.groupId; //'Transition UC Subscription';
                            newSub.csord__Status__c = System.Label.LegacySpecStatus;
                            newSub.Billing_Account__c = null;
                            newSub.csord__Order__c = OrderID;
                            newSub.csord__Identification__c = 'SUB_' + SubscrptionID;
                            newSub.ADBORID__c = siteDTO.ADBOR_Id;
                            newSub.Product_Type__c = productList.Product_Type;
                            newSub.Transition_ID__c = groupDTO.transitionId;
                            //EDGE-125031 : added
                            newSub.legacy_subscription__c = SubscrptionID;
                            newSub.csord__External_Identifier2__c = uniqueId;
                            
                            mapNGUCSubscriptionToInsert.put(uniqueId, newSub);
                            sObjectsToInsert.add(mapNGUCSubscriptionToInsert.get(uniqueId));
                            if (!stepRelationshipMap.containsKey(stepId)) {
                                stepRelationshipMap.put(stepId, new List<String>{ uniqueId });
                            } else {
                                stepRelationshipMap.get(stepId).add(uniqueId);
                            }
                        } else if (groupDTO.checkValue == true && (existingProcessedRecords != null && existingProcessedRecords.mapInsertedRecords != null && existingProcessedRecords.mapInsertedRecords.containsKey(uniqueId))) {
                            newSub = new csord__Subscription__c(Id = existingProcessedRecords.mapInsertedRecords.get(uniqueId), ADBORID__c = siteDTO.ADBOR_Id, Product_Type__c = productList.Product_Type, Transition_ID__c = groupDTO.transitionId);
                            mapNGUCSubscriptionToInsert.put(uniqueId, newSub);
                        }
                        String uniqueServSpec = groupDTO.transitionId + '#' + groupDTO.groupId;
                        ngUcServiceListMap.put(uniqueServSpec, groupDTO.service);
                    }
                }
                //system.debug('@@servlistmap@@' + ngUcServiceListMap);
            }
        }
        
        //System.debug('mapNGUCSubscriptionToInsert ::' + mapNGUCSubscriptionToInsert);
        if (mapNGUCSubscriptionToInsert.size() > 0) {
            //insert subListTobeInserted;
            
            JSONGenerator serviceSpecJSON;
            
            //for(csord__Subscription__c subRec : orderWrap.innerWrap){
            //for(Orchestration_OrderLegacyWrapper.InnerWrapper innerWrap : orderWrap.innerWraps){
            for (String uniqueId : mapNGUCSubscriptionToInsert.keyset()) {
                String groupId = uniqueId.substringBefore('#').replace(System.Label.LegacySubscriptionName, '').trim();
                
                String uniqueService = uniqueId + 'Service';
                String uniqueAttachment = uniqueService + 'Attachment';
                if (!Orchestration_LimitsUtility.areLimitsViolated() && !hasDMLRowsLimitExceeded()) {
                    csord__Subscription__c subRec = (csord__Subscription__c) mapNGUCSubscriptionToInsert.get(uniqueId);
                    csord__Service__c serv;
                    
                    if (existingProcessedRecords == null || (existingProcessedRecords.mapInsertedRecords != null && !existingProcessedRecords.mapInsertedRecords.containsKey(uniqueService))) {
                        serv = new csord__Service__c();
                        serv.Name = 'Legacy Service' + ' ' + subRec.ADBORID__c;
                        //serv.csord__Subscription__c = subRec.ID;
                        if (String.isNotBlank(subRec.Id)) {
                            serv.csord__Subscription__c = subRec.Id;
                        }
                        serv.csord__Order__c = OrderID;
                        serv.csord__Identification__c = 'SVC' + '_' + subRec.ADBORID__c;
                        serv.Offer_Type__c = subRec.Product_Type__c;
                        serv.Transition_Id__c = subRec.Transition_ID__c;
                        serv.csord__Status__c = OrchestratorConstants.ServiceStatus.DisconnectPending; //System.Label.LegacySpecStatus;
                        serv.csord__External_Identifier2__c = uniqueId;
                        
                        if (String.isBlank(subRec.Id) && mapNGUCSubscriptionToInsert.containsKey(uniqueId)) /*&& !mapProcessedSubscriptionWOSrvc.containsKey(uniqueId)*/ /*{
                            serv.csord__Subscription__r = new csord__Subscription__c(csord__External_Identifier2__c = String.valueOf(mapNGUCSubscriptionToInsert.get(uniqueId).get('csord__External_Identifier2__c')));
                        }
                        mapNGUCServiceToInsert.put(uniqueService, serv);
                        sObjectsToInsert.add(mapNGUCServiceToInsert.get(uniqueService));
                        if (!stepRelationshipMap.containsKey(stepId)) {
                            stepRelationshipMap.put(stepId, new List<String>{ uniqueService });
                        } else {
                            stepRelationshipMap.get(stepId).add(uniqueService);
                        }
                        if (!hasDMLRowsLimitExceeded()) {
                            mapAttachmentToInsert.put(uniqueAttachment, Orchestration_Utility.getAttachment(serv, 'NGUC', null, String.valueOf(subRec.get('ADBORID__c')), ngUcServiceListMap, null, groupId));
                            if (!stepRelationshipMap.containsKey(stepId)) {
                                stepRelationshipMap.put(stepId, new List<String>{ uniqueAttachment });
                            } else {
                                stepRelationshipMap.get(stepId).add(uniqueAttachment);
                            }
                        } else {
                            IncompleteStepId = stepId;
                            break;
                        }
                        //sObjectsToInsert.add(Orchestration_Utility.getAttachment(serv, 'NGUC', null, String.valueOf(subRec.get('ADBORID__c')), ngUcServiceListMap, null));
                    } else if (existingProcessedRecords != null && existingProcessedRecords.mapInsertedRecords != null && existingProcessedRecords.mapInsertedRecords.containsKey(uniqueService) && !existingProcessedRecords.mapInsertedRecords.containsKey(uniqueAttachment)) {
                        serv = new csord__Service__c(Id = existingProcessedRecords.mapInsertedRecords.get(uniqueService),Name = 'Legacy Service' + ' ' + subRec.ADBORID__c,csord__Order__c = OrderID,csord__Identification__c = 'SVC' + '_' + subRec.ADBORID__c, Offer_Type__c = subRec.Product_Type__c,Transition_Id__c = subRec.Transition_ID__c,csord__Status__c = OrchestratorConstants.ServiceStatus.DisconnectPending);
                        
                        if (!hasDMLRowsLimitExceeded()) {
                            mapAttachmentToInsert.put(uniqueAttachment, Orchestration_Utility.getAttachment(serv, 'NGUC', null, String.valueOf(subRec.get('ADBORID__c')), ngUcServiceListMap, null, groupId));
                            if (!stepRelationshipMap.containsKey(stepId)) {
                                stepRelationshipMap.put(stepId, new List<String>{ uniqueAttachment });
                            } else {
                                stepRelationshipMap.get(stepId).add(uniqueAttachment);
                            }
                            //sObjectsToInsert.add(Orchestration_Utility.getAttachment(serv, 'NGUC', null, String.valueOf(subRec.get('ADBORID__c')), ngUcServiceListMap, null));
                        } else {
                            IncompleteStepId = stepId;
                            break;
                        }
                    }
                } else {
                    IncompleteStepId = stepId;
                    break;
                }
            }
        }
        //return orderWrap;
    }*/
    
    public void LegacyServiceList(ReplicatorGetServiceDataObject_V2 siteDTO, ID SubscrptionID, Id OrderID, String stepId) {
        Map<String, ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> serviceAndServiceDTOMap = new Map<String, ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
        Map<String, String> nameValueMap = new Map<String, String>();
        List<csord__Service__c> servListTobeInserted = new List<csord__Service__c>();
        servlistmap = new Map<String, List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>();
        JSONGenerator PrimaryFNN = JSON.createGenerator(true);
        //System.debug('siteDTO ' + siteDTO);
        //System.debug('siteDTO.site ' + siteDTO.site);
        
        Orchestration_ProcessedRecords existingProcessedRecords = processedIds.containsKey(stepId) ? processedIds.get(stepId) : null;
        
        //System.debug('existingProcessedRecords :::' + existingProcessedRecords);
        
        for (ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site : siteDTO.site) {
            //create legacy service for each service in Replicator
            //system.debug('**Adbor_id**' + site.ADBOR_ID);
            //system.debug('**SubscrptionID**' + SubscrptionID);
            JSONGenerator serviceSpecJSON;
            
            for (ReplicatorGetServiceDataObject_V2.productListDTO prod : site.productList) {
                if (Orchestration_LimitsUtility.areLimitsViolated() && !hasDMLRowsLimitExceeded()) {
                    IncompleteStepId = stepId;
                    break;
                }
                
                //System.debug('site.prod ::' + prod);
                
                if (prod.checkValue == true) {
                    String uniqueId = prod.Product_Type + '#' + SubscrptionID + '::' + OrderID;
                    String uniqueAttachment = uniqueId + 'Attachment';
                    //Orchestration_OrderLegacyWrapper.ChildWrap childWrap;
                    
                    List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> servList1 = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
                    for (ReplicatorGetServiceDataObject_V2.serviceListDTO servlist : prod.serviceList) {
                        //PrimaryFNN = generatePrimaryFNNAttribute(servlist.service);
                        // NumberJSON=generateNumberAttribute(servlist.service);
                        if (servlistmap.containsKey(prod.Product_Type)) {
                            servList1 = servlistmap.get(prod.Product_Type);
                            servList1.addAll(servlist.service);
                        } else {
                            servList1.addAll(servlist.service);
                        }
                        servlistmap.put(prod.Product_Type, servList1);
                    }
                    uniqueIdToOrder.put(uniqueId, OrderID);
                    csord__Service__c service;
                    
                    if (existingProcessedRecords == null || (existingProcessedRecords.mapInsertedRecords != null && !existingProcessedRecords.mapInsertedRecords.containsKey(uniqueId))) {
                        service = new csord__Service__c();
                        service.Name = System.Label.LegacySpecName;
                        service.Offer_Type__c = prod.Product_Type;
                        service.csord__Subscription__c = SubscrptionID;
                        service.csord__Order__c = OrderID;
                        
                        //system.debug('@@servlistmap@@' + servlistmap);
                        service.csord__Identification__c = 'Service_' + SubscrptionID;
                        service.csord__Status__c = System.Label.LegacySpecStatus;
                        //sObjectsToInsert.add(service);
                        mapDTOSobjectToInsert.put(uniqueId, service);
                        if (!stepRelationshipMap.containsKey(stepId)) {
                            stepRelationshipMap.put(stepId, new List<String>{ uniqueId });
                        } else {
                            stepRelationshipMap.get(stepId).add(uniqueId);
                        }
                        //sObjectsToInsert.add(mapDTOSobjectToInsert.get(uniqueId));
                        
                        if ((existingProcessedRecords == null || (existingProcessedRecords.mapInsertedRecords != null && !existingProcessedRecords.mapInsertedRecords.containsKey(uniqueAttachment)))) {
                            if (!hasDMLRowsLimitExceeded()) {
                                mapAttachmentToInsert.put(uniqueAttachment, Orchestration_Utility.getAttachment(service, 'DTO', serviceSpecJSON, null, null, servlistmap, null));
                                if (!stepRelationshipMap.containsKey(stepId)) {
                                    stepRelationshipMap.put(stepId, new List<String>{ uniqueAttachment });
                                } else {
                                    stepRelationshipMap.get(stepId).add(uniqueAttachment);
                                }
                            } else {
                                IncompleteStepId = stepId;
                                break;
                            }
                        }
                        //system.debug('sObjectsToInsert' + sObjectsToInsert);
                    } else if (existingProcessedRecords != null && existingProcessedRecords.mapInsertedRecords != null && existingProcessedRecords.mapInsertedRecords.containsKey(uniqueId) && !existingProcessedRecords.mapInsertedRecords.containsKey(uniqueAttachment)) {
                        service = new csord__Service__c(
                            Id = existingProcessedRecords.mapInsertedRecords.get(uniqueId),
                            Name = System.Label.LegacySpecName,
                            Offer_Type__c = prod.Product_Type,
                            csord__Subscription__c = SubscrptionID,
                            csord__Order__c = OrderID,
                            csord__Identification__c = 'Service_' + SubscrptionID,
                            csord__Status__c = System.Label.LegacySpecStatus
                        );
                        
                        if (!hasDMLRowsLimitExceeded()) {
                            mapAttachmentToInsert.put(uniqueAttachment, Orchestration_Utility.getAttachment(service, 'DTO', serviceSpecJSON, null, null, servlistmap, null));
                            if (!stepRelationshipMap.containsKey(stepId)) {
                                stepRelationshipMap.put(stepId, new List<String>{ uniqueAttachment });
                            } else {
                                stepRelationshipMap.get(stepId).add(uniqueAttachment);
                            }
                            //sObjectsToInsert.add(Orchestration_Utility.getAttachment(service, 'DTO', serviceSpecJSON, null, null, servlistmap));
                        } else {
                            IncompleteStepId = stepId;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    /*
public void processDMLOperations() {
//DML Operation
insertObjects();

//Get process data on Step
/*populateProcessData();

System.debug('IncompleteStepId ::: '+ IncompleteStepId);
for(Id stepId : stepRelationshipMap.keySet()){

if(mapProcessedData.containsKey(stepId)) {

if(failedStep.contains(stepId) && stepResults.containsKey(stepId) && (String.isBlank(IncompleteStepId) || IncompleteStepId.equals(stepId))) {

stepResults.get(stepId).processedRecords = mapProcessedData.get(stepId);
} else {

if (!stepResults.containsKey(stepId) && (String.isBlank(IncompleteStepId) || !IncompleteStepId.equals(stepId))) {
stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
//move to next step
}
}
continue;
} else {

if((String.isBlank(IncompleteStepId) || IncompleteStepId.equals(stepId)) && !stepResults.containsKey(stepId)) {
stepResults.put(stepId, new StepResult('Success: No Records Processed', OrchestratorConstants.OrchestratorStep.Complete));
continue;
}
}

if (String.isNotBlank(IncompleteStepId) && IncompleteStepId.equals(stepId)) {

if(stepResults.containsKey(stepId)) {
stepResults.get(stepId).message = 'Success: Partial records processed';
stepResults.get(stepId).status = OrchestratorConstants.OrchestratorStep.InProgress;
stepResults.get(stepId).processedRecords = mapProcessedData.get(stepId);
} else {

stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, mapProcessedData.get(stepId)));
}
continue;
}
}
}
/* public void populateProcessData() {

System.debug('mapNGUCSubscriptionToInsert :::'+ mapNGUCSubscriptionToInsert);
System.debug('mapNGUCServiceToInsert :::'+ mapNGUCServiceToInsert);
System.debug('mapDTOSobjectToInsert :::'+ mapDTOSobjectToInsert);
System.debug('mapAttachmentToInsert :::'+ mapAttachmentToInsert);

Map<String, Sobject> mapServiceToInsert = new Map<String, Sobject>();
mapServiceToInsert.putAll(mapNGUCServiceToInsert);
mapServiceToInsert.putAll(mapDTOSobjectToInsert);

mapProcessedData = new Map<String, Orchestration_ProcessedRecords>();

populateMapProcessedData(mapNGUCSubscriptionToInsert, OrchestratorConstants.SOBJECT_ENUM.SUBSCRIPTION);
populateMapProcessedData(mapServiceToInsert, OrchestratorConstants.SOBJECT_ENUM.SERVICE);
populateMapProcessedData(mapAttachmentToInsert, OrchestratorConstants.SOBJECT_ENUM.ATTACHMENT);
}

public void populateMapProcessedData(Map<String, Sobject> mapProcessedObject, String objectType) {

if(mapProcessedObject.size() > 0) {

for(String uniqueId : mapProcessedObject.keyset()) {

System.debug(' uniqueId ::'+ uniqueId);
System.debug(' uniqueIdToOrder ::'+ uniqueIdToOrder);

String recordId = String.valueOf(mapProcessedObject.get(uniqueId).get('Id'));
String stepId = stepmap.get(uniqueIdToOrder.get(uniqueId));

System.debug('stepId:::'+  stepId);

if(String.isBlank(recordId)){

if(stepResults.containsKey(stepId)) {

stepResults.get(stepId).message = 'Error: Unable to process records';
stepResults.get(stepId).Status = OrchestratorConstants.OrchestratorStep.Error;
//stepResults.get(stepId).JSON = JSON.serialize(mapStepWithWrapper.get(stepId));
} else {

stepResults.put(stepId, new StepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error));
}

failedOrders.add(uniqueId.substringAfter('::'));
if(!failedStep.contains(stepId)) {

failedStep.add(stepId);
}
} else if(String.isNotBlank(recordId)) {

if(!stepResults.containsKey(stepId) || (stepResults.containsKey(stepId) && stepResults.get(stepId).Status != OrchestratorConstants.OrchestratorStep.Error)) {

stepResults.put(stepId, new StepResult('Success: Record Processed', OrchestratorConstants.OrchestratorStep.Complete));
}

Orchestration_ProcessedRecords currentProcessed;

if(processedIds.containsKey(stepId)) {

currentProcessed = processedIds.get(stepId);
}

if(currentProcessed == null) {

currentProcessed = new Orchestration_ProcessedRecords();
currentProcessed.subsIds = new Set<String>();
currentProcessed.serviceIds = new Set<String>();
currentProcessed.attachmentIds = new Set<String>();
}
if(currentProcessed.mapInsertedRecords == null) {

currentProcessed.mapInsertedRecords = new Map<String, String>();
}

currentProcessed.mapInsertedRecords.put(uniqueId, recordId);

mapProcessedData.put(stepId, currentProcessed);
}
}
}
}*/
    
    public override boolean hasDMLRowsLimitExceeded() {
        boolean dmlRowsExceeded = true;
        if ((mapAttachmentToInsert.size() + sObjectsToInsert.size() + mapDTOSobjectToInsert.size()) <= (Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c) - Limits.getDMLRows() - 1)) {
            return false;
        }
        return dmlRowsExceeded;
    }
    
    public override void insertObjects() {
        //System.debug('sObjectsToInsert :::' + sObjectsToInsert);
        //System.debug('mapDTOSobjectToInsert :::' + mapDTOSobjectToInsert);
        //System.debug('mapAttachmentToInsert :::' + mapAttachmentToInsert);
        
        if (sObjectsToInsert.size() > 0) {
            //insert sObjectsToInsert;
            Database.SaveResult[] updateResult = Database.insert(sObjectsToInsert, false);
            result.addAll(updateResult);
        }
        
        if (mapDTOSobjectToInsert.size() > 0) {
            // insert mapDTOSobjectToInsert.values();
            List<sObject> DTOSobjectToInsert = mapDTOSobjectToInsert.values();
            
            Database.SaveResult[] updateResult = Database.insert(DTOSobjectToInsert, false);
            result.addAll(updateResult);
        }
       
        
        for (String uniqueAttachment : mapAttachmentToInsert.keyset()) {
            String uniqueId = uniqueAttachment.substringBefore('Attachment');
            
            if (String.isBlank(String.valueOf(mapAttachmentToInsert.get(uniqueAttachment).get('ParentId')))) {
                //EDGE-165190 - To add the parent Id to Attachment
                Map<String, Object> attMap = (Map<string, Object>) JSON.deserializeUntyped(((Blob) mapAttachmentToInsert.get(uniqueAttachment).get('Body')).toString());
                if (mapDTOSobjectToInsert.containsKey(uniqueId)) {
                    mapAttachmentToInsert.get(uniqueAttachment).put('ParentId', String.valueOf(mapDTOSobjectToInsert.get(uniqueId).get('Id')));
                    attMap.put('serviceId', String.valueOf(mapDTOSobjectToInsert.get(uniqueId).get('Id')));
                } else if (mapNGUCServiceToInsert.containsKey(uniqueId)) {
                    mapAttachmentToInsert.get(uniqueAttachment).put('ParentId', String.valueOf(mapNGUCServiceToInsert.get(uniqueId).get('Id')));
                    attMap.put('serviceId', String.valueOf(mapNGUCServiceToInsert.get(uniqueId).get('Id')));
                }
                //EDGE-165190 - To add the parent Id to Attachment
                mapAttachmentToInsert.get(uniqueAttachment).put('Body', Blob.valueOf(JSON.serialize(attMap)));
                attMap.clear();
                // attachmentsToInsert.add(mapAttachmentToInsert.get(uniqueAttachment));
            }
            attachmentsToInsert.add(mapAttachmentToInsert.get(uniqueAttachment));
        }
        
        if (attachmentsToInsert.size() > 0) {
            //insert attachmentsToInsert;
            Database.SaveResult[] updateResult = Database.insert(attachmentsToInsert, false);
            result.addAll(updateResult);
        }
        List<Id> successIds = new List<Id>();
        for (Database.SaveResult rslt : result) {
            if (rslt.isSuccess()) {
                successIds.add(rslt.getId());
            }
        }
        Map<String, String> successIdentifiersMap = new Map<String, String>();
        //System.debug('mapNGUCSubscriptionToInsert :::' + mapNGUCSubscriptionToInsert);
        //System.debug('mapNGUCServiceToInsert :::' + mapNGUCServiceToInsert);
        //System.debug('mapDTOSobjectToInsert :::' + mapDTOSobjectToInsert);
        //System.debug('mapAttachmentToInsert :::' + mapAttachmentToInsert);
        /*Commented for EDGE-133470 TO Stop creation of Legacy Transition UC product 
        for (String key : mapNGUCSubscriptionToInsert.keyset()) {
            String recordId = (String) mapNGUCSubscriptionToInsert.get(key).get('Id');
            if (successIds != null && recordId != null) {
                if (successIds.contains(recordId)) {
                    //successIdentifiers.add(mapProcessedCase.get(key).Subject);
                    successIdentifiersMap.put(key, recordId);
                }
            }
        }*/
        for (String key : mapNGUCServiceToInsert.keyset()) {
            String recordId = (String) mapNGUCServiceToInsert.get(key).get('Id');
            if (successIds != null && recordId != null) {
                if (successIds.contains(recordId)) {
                    //successIdentifiers.add(mapProcessedCase.get(key).Subject);
                    successIdentifiersMap.put(key, recordId);
                }
            }
        }
        for (String key : mapDTOSobjectToInsert.keyset()) {
            String recordId = (String) mapDTOSobjectToInsert.get(key).get('Id');
            if (successIds != null && recordId != null) {
                if (successIds.contains(recordId)) {
                    //successIdentifiers.add(mapProcessedCase.get(key).Subject);
                    successIdentifiersMap.put(key, recordId);
                }
            }
        }
        for (String key : mapAttachmentToInsert.keyset()) {
            String recordId = (String) mapAttachmentToInsert.get(key).get('Id');
            if (successIds != null && recordId != null) {
                if (successIds.contains(recordId)) {
                    //successIdentifiers.add(mapProcessedCase.get(key).Subject);
                    successIdentifiersMap.put(key, recordId);
                }
            }
        }
        
        for (Id stepId : stepRelationshipMap.keySet()) {
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            perStepSuccessIds.mapInsertedRecords = new Map<String, String>();
            Boolean isFailed = false;
            for (String recId : stepRelationshipMap.get(stepId)) {
                if (!successIdentifiersMap.containsKey(recId)) {
                    isFailed = true;
                } else if (successIdentifiersMap.containsKey(recId)) {
                    perStepSuccessIds.mapInsertedRecords.put(recId, successIdentifiersMap.get(recId));
                }
            }
            String errorMessage = 'Error: Unable to process records';
            if (stepResults.containsKey(stepId)) {
                stepResult sr = stepResults.get(stepId);
                if (sr.status == OrchestratorConstants.OrchestratorStep.Error) {
                    isFailed = true;
                    errorMessage = sr.message;
                }
            }
            if (!isFailed && (String.isBlank(IncompleteStepId) || !IncompleteStepId.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Transition Records created', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }
            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).mapInsertedRecords != null) {
                perStepSuccessIds.mapInsertedRecords.putAll(processedIds.get(stepId).mapInsertedRecords);
            }
            
            if (!isFailed && !String.isBlank(IncompleteStepId) && IncompleteStepId.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            } else {
                stepResults.put(stepId, new stepResult(errorMessage, OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
            }
        }
    }
    
    //method override getsteplist
    public override List<sObject> getStepList(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                OrderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                //stepRelationshipMap.put(step.Id, step.CSPOFA__Orchestration_Process__r.Order__c);
            }
            
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);
            }
        }
        //Check if attachments is required
        if (stepIds.size() > 0) {
            getAttachmentList(stepIds);
        }
        //Returning the step list
        return stepList;
    }
}