/**================================================================
* Appirio, Inc
* Name: Orchestration_GenerateTransientData
* Description: This Updates all the Orders with isTransientComplete__c = true and adds attachment to the Order
* Created Date: May 20, 2020
* Created By: Martand Atrey
* Updated Partial Processing - 16th Feb - Martand Atrey
1.Akanksha Jain		                Added condition to mark step as complete in case of Inflight remediation order
2.Vaibhav             08-06-2021    EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
==================================================================*/
global with sharing class Orchestration_GenerateTransientData extends Orchestration_AbstractStepHandler {
    private List<String> specCodeForTransientList;
    private Set<String> offerListForTransientList;
    private Map<String, List<String>> specCodeChangeTypeMap;
    private List<String> fieldAPINameList;
    private Id incompleteStepId;
    private List<Product_Attribute_Metadata__c> productMetadataList;
    // private Map<Id, csord__Service__c> serviceIDTransientDataMap;
    private Map<Id, sObject> sObjectsToUpsertMap = new Map<Id, sObject>();
    private Map<Id, csord__Service__c> services = new Map<Id, csord__Service__c>();
    private Map<Id, String> orderOldAssetMap = new Map<Id, String>();
    private Set<Id> failedOrderIdSet = new Set<Id>();
    private Map<Id, Attachment> attMap = new Map<Id, Attachment>();
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    private Set<String> successServicesSet = new Set<String>();
    private Map<Id, Orchestration_AttachmentWrapper> serviceAttachmentMap = new Map<Id, Orchestration_AttachmentWrapper>();
    private Map<Id, Orchestration_AttachmentWrapper> orderAttachmentMap = new Map<Id, Orchestration_AttachmentWrapper>();
    
    private List<String> subsStatusForAsset = new List<String>{ OrchestratorConstants.SubscriptionStatus.InProgress, OrchestratorConstants.SubscriptionStatus.Pending };
        
        //Map<Id, String> serviceScenerioTypeMap = new Map<Id, String>();
        //Map<Id, String> serviceOfferMap = new Map<Id, String>();
        
        public override List<SObject> process(List<SObject> steps) {
            List<SObject> sobjList=new List<SObject>();// Added as part of EDGE-222326
            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                return sobjList;// Added as part of EDGE-222326
            }
            List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
            
            try {
                stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
                //getRelatedOrderIds(stepList);
                Map<Id, Map<Id, csord__Service__c>> orderServicesMap = new Map<Id, Map<Id, csord__Service__c>>();
                Map<Id, Map<Id, csord__Service__c>> orderServiceOfferAttachMap = new Map<Id, Map<Id, csord__Service__c>>();
                //EDGE-170463 adding starts
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
                //EDGE-170463 adding ends
                //Map<Id, csord__Service__c> services = new Map<Id, csord__Service__c>([SELECT id,name,Replaced_Device_Id__c,csord__Status__c ,csord__Order__c FROM csord__Service__c WHERE csord__Order__c IN :orderIds]);
                
                specCodeForTransientList = new CS_TransientMetadataHelper().getSpecCodeListForNonAssetableProducts();
                offerListForTransientList = new CS_TransientMetadataHelper().getOfferListForNonAssetableProducts();
                specCodeChangeTypeMap = new CS_TransientMetadataHelper().getSpecCodeChangeTypeForNonAssetableProducts();
                fieldAPINameList = new CS_TransientMetadataHelper().getTransientReferenceAPINameList();
                productMetadataList = new CS_TransientMetadataHelper().getAttributeReferenceForNonAssetableProducts();
                //serviceIDTransientDataMap = new CS_TransientMetadataHelper().fetchTransientDataFromService(services.keyMap(), fieldAPINameList);
                
                String serviceQuery = 'SELECT id,name,Replaced_Device_Id__c,csord__Subscription__r.MarketableOffer__r.Offer_ID__c, csord__Status__c ,csord__Order__c, Scenario_Type__c,csord__Subscription__r.orderversion__c,csord__Order__r.Fulfilment_Order_Version__c ';
                String fieldAPIStr = ',';
                //Loop to add all the fields form the Metadata to the Query only if they Dont Exist
                for (String field : fieldAPINameList) {
                    if (!serviceQuery.toLowerCase().contains(field.toLowerCase())) {
                        fieldAPIStr = fieldAPIStr + field + ',';
                    }
                }
                
                serviceQuery += (fieldAPIStr.removeEnd(',') + ' FROM csord__Service__c WHERE csord__Order__c IN :orderIds '); //
                
                services = new Map<Id, csord__Service__c>((List<csord__Service__c>) Database.query(serviceQuery)); 
                //Create order vs all its Services Map
                for (csord__Service__c service : services.values()) 
                {
                    if ((inflightOrderSet.contains(service.csord__Order__c)) && (service.csord__Subscription__r.orderversion__c == service.csord__Order__r.Fulfilment_Order_Version__c))
                    {
                        if ((orderServicesMap.get(service.csord__Order__c) != null))
                        {
                            orderServicesMap.get(service.csord__Order__c).put(service.Id, service);
                        }
                        else{
                            orderServicesMap.put(service.csord__Order__c, new Map<Id, csord__Service__c>{ service.Id => service });
                        }
                    } 
                    
                    else if( baseOrderSet.contains(service.csord__Order__c))// EDGE-170463 added condition for Identifying base order services
                    {
                        
                        if ((orderServicesMap.get(service.csord__Order__c) != null))
                        {
                            orderServicesMap.get(service.csord__Order__c).put(service.Id, service);
                        }
                        else
                        {
                            orderServicesMap.put(service.csord__Order__c, new Map<Id, csord__Service__c>{ service.Id => service });
                        }
                    }
                    
                }
                
                //get all the attachments of the Services to be processed
                //attMap = new Map<Id, Attachment>([SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :services.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.service]);
                for (Attachment att : [SELECT Id, Name, Body, ParentId FROM Attachment WHERE (ParentId IN :services.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.service)
                                       OR (ParentId IN :orderServicesMap.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.TransientData)]) {
                                           
                                           if(att.Name == OrchestratorConstants.DataOrchestrationNames.service){
                                               serviceAttachmentMap.put(att.ParentId, new Orchestration_AttachmentWrapper(att.Id, att.body));
                                           }else {
                                               orderAttachmentMap.put(att.ParentId, new Orchestration_AttachmentWrapper(att.Id, att.body));
                                           }
                                       }
                
                //TO Populate the Map with Order vs Old Asset Ids
                getReplacedAssetIds();
                
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    try {
                        if (!Orchestration_LimitsUtility.areLimitsViolated() && !hasDMLRowsLimitExceeded()) {
                            String orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
                            
                            if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                                //Updating steps as Error since no proper data linked to step
                                stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
                                //Check the next step
                                continue;
                            }
                            if (step.CSPOFA__Orchestration_Process__r.Order__r.isTransientComplete__c) {
                                stepResults.put(step.Id, new StepResult('Success: Transient Already Completed', OrchestratorConstants.OrchestratorStep.Complete));
                                continue;
                            }
                            
                            TransientDataDTO dto = new TransientDataDTO();
                            
                            if (orderServicesMap.get(orderId) != null) {
                                //Populate all the record Ids that are processed already
                                Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                                
                                if (processedRecordIds != null) {
                                    processedIds.put(step.Id, processedRecordIds);
                                }
                                
                                //If the Order is already processed that means the Attachment has been added and order needs to be updated
                                if (processedIds.get(step.Id) != null && processedIds.get(step.Id).orderIds != null && processedIds.get(step.Id).orderIds.contains(orderId)) {
                                    sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                    continue;
                                }
                                Map<String, Id> serviceOfferAttMap = new Map<String, Id>();
                                
                                for (Id serviceId : orderServicesMap.get(orderId).keySet()) {
                                    Orchestration_AttachmentWrapper att = serviceAttachmentMap.get(serviceId);
                                    if (att == null || services.get(serviceId).csord__Subscription__c == null || services.get(serviceId).csord__Subscription__r.MarketableOffer__c == null || services.get(serviceId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c == null) {
                                        continue;
                                    }
                                    String offerId = services.get(serviceId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c;
                                    if (offerListForTransientList.contains(offerId)) {
                                        serviceOfferAttMap.put(serviceId + '::' + offerId, att.attchId);
                                    }
                                }
                                
                                if (!serviceOfferAttMap.isEmpty()) {
                                    getAllRequiredServiceSpecMappings(step.Id, orderId, dto, orderServicesMap.get(orderId), serviceOfferAttMap);
                                } else {
                                    sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                    stepResults.put(step.Id, new StepResult('Success: Records already processed or No Services Found', OrchestratorConstants.OrchestratorStep.Complete));
                                }
                            } 
                             else if(orderServicesMap.get(orderId) == null && step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Inflight Orchestration Process')// added for marking inflight remediation order step as complete
                            {
                                sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                stepResults.put(step.Id, new StepResult('Success: Records already processed or No Services Found', OrchestratorConstants.OrchestratorStep.Complete));
                            }
                            else 
                            {
                                //sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                stepResults.put(step.Id, new StepResult('Error: No Services Found', OrchestratorConstants.OrchestratorStep.Error));
                            }
                        }
                    } catch (Exception ex) {
                        System.debug('exception line ' + ex.getLineNumber());
                        stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                    }
                }
            } catch (Exception ex) {
                for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                }
            }
            
            if (!sObjectsToUpsertMap.isEmpty() || !sObjectsToUpdate.isEmpty()) {
                upsertObjects();
                updateObjects();
            }
            return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
        }
    
    public void getAllRequiredServiceSpecMappings(Id stepId, Id orderID, TransientDataDTO transientData, Map<Id, csord__Service__c> servicesMap, Map<String, Id> offerServiceToAttachmentMap) {
        Map<String, CS_SpecificationDTO.ServiceSpecification> guidFinalMap2 = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        List<TransientDataDTO.DataDTO> transDataDTOList = new List<TransientDataDTO.DataDTO>();
        if(orderAttachmentMap.containsKey(orderId)){
            transDataDTOList = TransientDataDTO.parseDataDTO(orderAttachmentMap.get(orderId).attchBody.toString());
        }
        
        successServicesSet = new Set<String>();
        for (String servOfferId : offerServiceToAttachmentMap.keyset()) {
            //serviceIDSet.add(servOfferId.split('::')[0]);
            String tempServiceId = servOfferId.split('::')[0];
            
            if(processedIds.get(stepId) != null && processedIds.get(stepId).serviceIds != null && processedIds.get(stepId).serviceIds.contains(tempServiceId)){
                continue;
            }
            //Check for limits and return step for Partial processing
            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                incompleteStepId = stepId;
                break;
            }
            List<CS_SpecificationDTO.ServiceSpecification> allReqdSrvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            allReqdSrvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(tempServiceId).attchBody.toString()), 'FULFILMENT', specCodeForTransientList));
            for (CS_SpecificationDTO.ServiceSpecification specs : allReqdSrvSpecList) {
                if (servicesMap.get(specs.serviceId) != null && servicesMap.get(specs.serviceId).csord__Subscription__c != null && servicesMap.get(specs.serviceId).csord__Subscription__r.MarketableOffer__c != null && servicesMap.get(specs.serviceId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c != null) {
                    String offer = servicesMap.get(specs.serviceId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c;
                    if (specCodeChangeTypeMap.containsKey(offer + '::' + specs.code.remove('_Fulfilment'))) {
                        List<String> changeTypeList = specCodeChangeTypeMap.get(offer + '::' + specs.code.remove('_Fulfilment'));
                        TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                        
                        if (changeTypeList.contains('New') && specs.status == 'Created') {
                            //TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = offer;
                            dataDTO.specCode = specs.code;
                            dataDTO.specGUID = specs.guid;
                            dataDTO.changeType = 'New';
                            guidFinalMap2.put(specs.guid, specs);
                        } else if ((changeTypeList.contains('Modify') || changeTypeList.contains(servicesMap.get(specs.serviceId).Scenario_Type__c)) && specs.status == 'Modified') {
                            //TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = offer;
                            dataDTO.specCode = specs.code; //remember this will have value ending with _Fulfilment
                            dataDTO.specGUID = specs.guid;
                            dataDTO.changeType = 'Modify';
                            guidFinalMap2.put(specs.guid, specs);
                        }
                        if (dataDTO.specGUID != null) {
                            transDataDTOList.add(dataDTO);
                        }
                    }
                }
            }
            successServicesSet.add(tempServiceId);
        }
        System.debug('transDataDTOList:' + transDataDTOList + ' Size : ' + transDataDTOList.size());
        if (transDataDTOList != null && transDataDTOList.size() > 0) {
            System.debug('Checkpoint: IN transDataDTOList');
            transientData.dataDTOList = transDataDTOList;
            populateTransientDTO(stepId, orderID, transientData, guidFinalMap2, servicesMap); //Changed last perameter to Map as we are getting the service record below
        } else {
            //If no specs were added then no need to add Attachment only set Checkbox(isTransientComplete__c) true
            sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
            return;
        }
        
    }
    
    /*********************************************************************************************************************************
* Method Name      :   populateTransientDTO
*Purpose           :   to get transient data
**********************************************************************************************************************************/
    public void populateTransientDTO(Id stepId, Id orderID, TransientDataDTO transientData, Map<String, CS_SpecificationDTO.ServiceSpecification> guidFinalMap2, Map<Id, csord__Service__c> servicesMap) {
        List<TransientDataDTO.DataDTO> transDataDTOList = transientData.dataDTOList;
        System.debug('Checkpoint: IN populateTransientDTO');
        
        Set<String> uniqueProdMetaSet = new Set<String>();
        for (TransientDataDTO.DataDTO dataDTO : transDataDTOList) {
            List<TransientDataDTO.TransientAttribute> transientAttrList = new List<TransientDataDTO.TransientAttribute>();
            String serviceID = '';
            if (dataDTO.specGUID != null && guidFinalMap2.get(dataDTO.specGUID) != null) {
                serviceID = guidFinalMap2.get(dataDTO.specGUID).serviceId;
                
                csord__Service__c serviceRecord = servicesMap.get(serviceID);
                
                for (Product_Attribute_Metadata__c prodMetadata : productMetadataList) {
                    if (prodMetadata.Offer_Id__c == dataDTO.offerID && prodMetadata.Product_ID__c == dataDTO.specCode.remove('_Fulfilment') && prodMetadata.Change_Type__c == dataDTO.changeType) {
                        TransientDataDTO.TransientAttribute transientAttribute = new TransientDataDTO.TransientAttribute();
                        transientAttribute.name = prodMetadata.Attribute_Name__c;
                        transientAttribute.value = String.valueOf(serviceRecord.get(prodMetadata.ReferenceField__c));
                        
                        transientAttrList.add(transientAttribute);
                    }
                }
            } //added check as part of EDGE-142395
            if (transientAttrList != null && transientAttrList.size() > 0) {
                dataDTO.attributes = transientAttrList;
            }
        }
        createAttachmentOnOrder(stepId, orderId, transientData); //review will this TransientData get updated?
    }
    
    /*********************************************************************************************************************************
* Method Name      :   getReplacedAssetIds
*Purpose           :   To populate orderOldAssetMap with the old asset id from the new asset associated with the generated order.
* Modified by      :Zeeshan, Martand
**********************************************************************************************************************************/
    public void getReplacedAssetIds() {
        List<Asset> assetRec = [
            SELECT id, name, csordtelcoa__Replaced_Asset__r.AssetID__c, AssetID__c, Subscription__r.csord__Order__c
            FROM Asset
            WHERE csordtelcoa__Replaced_Asset__c != null AND Subscription__c != null AND Subscription__r.csord__Order__c = :orderIds AND status = :OrchestratorConstants.AssetStatus.InActive AND Subscription__r.csord__Status__c IN :subsStatusForAsset AND Subscription__r.csord__Order__r.Scenario_Type__c = :Label.Device_Replacement
        ];
        if (!assetRec.isEmpty()) {
            for (Asset a : assetRec) {
                orderOldAssetMap.put(a.Subscription__r.csord__Order__c, a.csordtelcoa__Replaced_Asset__r.AssetID__c);
            }
        }
    }
    
    /*********************************************************************************************************************************
* Method Name      :   insertAttachmentOnOrder
*Purpose           :   to insert TransientDataDetails.json on Order
**********************************************************************************************************************************/
    public void createAttachmentOnOrder(Id stepId, Id orderId, TransientDataDTO transientData) {
        String jsonStr = TransientDataDTO.parse(transientData.dataDTOList);
        Attachment att = new Attachment();
        att.Body = Blob.valueOf(String.valueOf(jsonStr));
        att.ParentId = orderId;
        if(orderAttachmentMap.containsKey(orderId)){
            att.Id = orderAttachmentMap.get(orderId).attchId;
        }
        att.name = OrchestratorConstants.DataOrchestrationNames.TransientData;
        sObjectsToUpsertMap.put(orderId, att);
        if(incompleteStepId == null)
            sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
        stepRelationship.put(orderId, stepId);
    }
    
    public void upsertObjects() {
        Database.UpsertResult[] upsertResult = Database.upsert(sObjectsToUpsertMap.values(), false);
        for (String recordId : sObjectsToUpsertMap.keySet()) {
            if (sObjectsToUpsertMap.get(recordId).Id != null) {
                Orchestration_ProcessedRecords opr = new Orchestration_ProcessedRecords();
                opr.serviceIds = successServicesSet;
                if(processedIds.get(stepRelationship.get(recordId)) != null && processedIds.get(stepRelationship.get(recordId)).serviceIds != null){
                    opr.serviceIds.addAll(processedIds.get(stepRelationship.get(recordId)).serviceIds);
                }
                stepResults.put(stepRelationship.get(recordId), new stepResult('Partial Success: Attchment Inserted.', OrchestratorConstants.OrchestratorStep.InProgress, opr));
            } else {
                //Unable to Create Attachment
                failedOrderIdSet.add(recordId);
                stepResults.put(stepRelationship.get(recordId), new stepResult('Error: Unable to Create Attachment', OrchestratorConstants.OrchestratorStep.Error));
            }
        }
    }
    
    public override void updateObjects() {
        //To remove all the Orders which were failed
        if (!failedOrderIdSet.isEmpty()) {
            sObjectsToUpdate.keySet().removeAll(failedOrderIdSet);
        }
        
        //Updating all the records including orders and subscription
        Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        
        for (Database.SaveResult result : updateResult) {
            //Only order check
            if (result.isSuccess()) {
                stepResults.put(stepRelationship.get(result.getId()), new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
            } else {
                //Error : due to Order Failure
                stepResults.put(stepRelationship.get(result.getId()), new stepResult('Error: Unable to Update Record', OrchestratorConstants.OrchestratorStep.Error));
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
            CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,//EDGE-170463 added
            CSPOFA__Orchestration_Process__r.cspofa__account__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
            CSPOFA__Orchestration_Process__r.Order__c,
            CSPOFA__Orchestration_Process__r.Order__r.isTransientComplete__c,
            CSPOFA__Orchestration_Process__r.Order__r.scenario_type__c       
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
    
    public override boolean hasDMLRowsLimitExceeded() {
        boolean dmlRowsExceeded = true;
        if ((sObjectsToUpsertMap.size() + sObjectsToUpdate.size()) <= (Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c) - Limits.getDMLRows() - 1)) {
            return false;
        }
        return dmlRowsExceeded;
    }
}