/**================================================================

* Name: Orchestration_GenTransDataV1_Handler
* Description: This Updates all the Orders with isTransientComplete__c = true and adds attachment to the Order
=================================================================*/
global with sharing class Orchestration_GenTransDataV1_Handler implements Orchestration_StepInterface{
    private List<String> specCodeForTransientList;
    private Set<String> offerListForTransientList;
    private Map<String, List<String>> specCodeChangeTypeMap;
    private List<String> fieldAPINameList;
    private Id incompleteStepId;
    private List<Product_Attribute_Metadata__c> productMetadataList;
    // private Map<Id, csord__Service__c> serviceIDTransientDataMap;
    private Map<Id, sObject> sObjectsToUpsertMap = new Map<Id, sObject>();
    //private Map<Id, csord__Service__c> services = new Map<Id, csord__Service__c>();
    private Map<Id, String> orderOldAssetMap = new Map<Id, String>();
    private Set<Id> failedOrderIdSet = new Set<Id>();
    private Map<Id, Attachment> attMap = new Map<Id, Attachment>();
    //private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
  private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    private Set<String> successServicesSet = new Set<String>();
    private Map<Id, Orchestration_Technical__c> serviceAttachmentMap = new Map<Id, Orchestration_Technical__c>();
    private Map<Id, Orchestration_AttachmentWrapper> orderAttachmentMap = new Map<Id, Orchestration_AttachmentWrapper>();
  List<Object> servList = new List<Object>();
       private Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();

      private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
         Set<Id> orderIds = new Set<Id>();

Id stepId;
    
    private List<String> subsStatusForAsset = new List<String>{ OrchestratorConstants.SubscriptionStatus.InProgress, OrchestratorConstants.SubscriptionStatus.Pending };
        
        //Map<Id, String> serviceScenerioTypeMap = new Map<Id, String>();
        //Map<Id, String> serviceOfferMap = new Map<Id, String>();
        
       public void processUpdate (String strPayload) {
            List<SObject> sobjList=new List<SObject>();// Added as part of EDGE-222326
            //if (!Orchestration_LimitsUtility.areLimitsViolated()) {
                //return sobjList;// Added as part of EDGE-222326
         
            //}
        
            
            try {
        //Set<Id> baseOrderSet = new Set<Id>();
               //Set<Id> inflightOrderSet = new Set<Id>();
         Map<Id,boolean>inflightFlagMap = new Map<Id,boolean>();


       Map<String, Object> mapPayload = (Map<String, Object>)JSON.deserializeUntyped(strPayload);
           Id orderId = (Id)mapPayload.get('OrderId');
             
            stepId = (Id)mapPayload.get('StepId');
          /*  for(integer i=0;i<reqs.size();i++){
                String str=(String)reqs[i];
                system.debug(str);
                orderIds.add(str);
            }*/

      orderIds.add(orderId);

         Object inflightFlag = mapPayload.get('inflightFlagMap');
                String s1=JSON.serialize(inflightFlag);
 inflightFlagMap = (Map<Id,Boolean>) JSON.deserialize(s1, Map<Id,Boolean>.class);
               //baseOrderSet = (Set<Id>)mapPayload.get('baseOrderSet');
        
  
                Map<Id, Map<Id, csord__Service__c>> orderServicesMap = new Map<Id, Map<Id, csord__Service__c>>();
                Map<Id, Map<Id, csord__Service__c>> orderServiceOfferAttachMap = new Map<Id, Map<Id, csord__Service__c>>();
                //EDGE-170463 adding starts
                              //EDGE-170463 adding ends
                //Map<Id, csord__Service__c> services = new Map<Id, csord__Service__c>([SELECT id,name,Replaced_Device_Id__c,csord__Status__c ,csord__Order__c FROM csord__Service__c WHERE csord__Order__c IN :orderIds]);
                
                specCodeForTransientList = new CS_TransientMetadataHelper().getSpecCodeListForNonAssetableProducts();
                offerListForTransientList = new CS_TransientMetadataHelper().getOfferListForNonAssetableProducts();
                specCodeChangeTypeMap = new CS_TransientMetadataHelper().getSpecCodeChangeTypeForNonAssetableProducts();
                fieldAPINameList = new CS_TransientMetadataHelper().getTransientReferenceAPINameList();
                productMetadataList = new CS_TransientMetadataHelper().getAttributeReferenceForNonAssetableProducts();
                //serviceIDTransientDataMap = new CS_TransientMetadataHelper().fetchTransientDataFromService(services.keyMap(), fieldAPINameList);
                
        //commented as part of coms upliftment
               /* String serviceQuery = 'SELECT id,name,Replaced_Device_Id__c,csord__Subscription__r.MarketableOffer__r.Offer_ID__c, csord__Status__c ,csord__Order__c, Scenario_Type__c,csord__Subscription__r.orderversion__c,csord__Order__r.Fulfilment_Order_Version__c ';
                String fieldAPIStr = ',';
                //Loop to add all the fields form the Metadata to the Query only if they Dont Exist
                for (String field : fieldAPINameList) {
                    if (!serviceQuery.toLowerCase().contains(field.toLowerCase())) {
                        fieldAPIStr = fieldAPIStr + field + ',';
                    }
                }
                
                serviceQuery += (fieldAPIStr.removeEnd(',') + ' FROM csord__Service__c WHERE csord__Order__c IN :orderIds '); //
                
                services = new Map<Id, csord__Service__c>((List<csord__Service__c>) Database.query(serviceQuery)); 
        
        */
       Map<Id, csord__Service__c>services = new Map<Id, csord__Service__c>();
      servList =Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
      List<Orchestration_Technical__c> attachList = new List<Orchestration_Technical__c>();
      //Id ordId;
      set<Id> serIds = new set<Id>();
      
                //Create order vs all its Services Map
                for (csord__Service__c service : (List<csord__Service__c>)servList) 
                {
          services.put(service.id,service);
                    system.debug('services### '+services);
                    if (inflightFlagMap.get(service.csord__Order__c) && (service.csord__Subscription__r.orderversion__c == service.csord__Order__r.Fulfilment_Order_Version__c))
                    {
                        if ((orderServicesMap.get(service.csord__Order__c) != null))
                        {
                            orderServicesMap.get(service.csord__Order__c).put(service.Id, service);
                        }
                        else{
                            orderServicesMap.put(service.csord__Order__c, new Map<Id, csord__Service__c>{ service.Id => service });
                        }
                    } 
                    
                    else if(!inflightFlagMap.get(service.csord__Order__c))// EDGE-170463 added condition for Identifying base order services
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
          
          serIds.add(service.Id);
                  //  ordId= service.csord__Order__c;
        
                }
                
                //get all the attachments of the Services to be processed
                //attMap = new Map<Id, Attachment>([SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :services.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.service]);
        
        //commented as coms upliftment
        /*
                for (Attachment att : [SELECT Id, Name, Body, ParentId FROM Attachment WHERE (ParentId IN :services.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.service)
                                       OR (ParentId IN :orderServicesMap.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.TransientData)]) {
                                           
                                           if(att.Name == OrchestratorConstants.DataOrchestrationNames.service){
                                               serviceAttachmentMap.put(att.ParentId, new Orchestration_AttachmentWrapper(att.Id, att.body));
                                           }else {
                                               orderAttachmentMap.put(att.ParentId, new Orchestration_AttachmentWrapper(att.Id, att.body));
                                           }
                                       }
                     
        */             
                  
        attachList =Coms_PlatformCacheUtil.getTechnicalObjectFromCache(orderId,serIds);
        
        for(Orchestration_Technical__c techObj:attachList){
                serviceAttachmentMap.put(techObj.Service__c, techObj);
            system.debug('techObj.Service__c '+techObj.Service__c);
            }
                  
                //TO Populate the Map with Order vs Old Asset Ids
                getReplacedAssetIds();
              try {
                   
                          /*  String orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
                            
                            if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                                //Updating steps as Error since no proper data linked to step
                               // stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
                                //Check the next step
                
                   mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Error: Step do not have an order',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));

                                continue;
                            }
                            if (step.CSPOFA__Orchestration_Process__r.Order__r.isTransientComplete__c) {
                                //stepResults.put(step.Id, new StepResult('Success: Transient Already Completed', OrchestratorConstants.OrchestratorStep.Complete));
                           mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Success: Transient Already Completed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));

                                continue;
                            }*/
              //handled both conditions in main class
               Object processedRecord = mapPayload.get('processedRecordIds');
               String prRecords = JSON.serialize(processedRecord);
               processedRecordIds =  (Orchestration_ProcessedRecords) JSON.deserialize(prRecords, Orchestration_ProcessedRecords.class);
                  

                            TransientDataDTO dto = new TransientDataDTO();
                            
                            if (orderServicesMap.get(orderId) != null) {
                                //Populate all the record Ids that are processed already
                               
                                //If the Order is already processed that means the Attachment has been added and order needs to be updated
                                if (processedRecordIds!= null && processedRecordIds.orderIds != null && processedRecordIds.orderIds.contains(orderId)) {
                                    sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                    //continue;
                               }
                                Map<String, Id> serviceOfferAttMap = new Map<String, Id>();
                                system.debug('orderServicesMap '+orderServicesMap);
                                for (Id serviceId : orderServicesMap.get(orderId).keySet()) {                                    
                                    Orchestration_Technical__c att = serviceAttachmentMap.get(serviceId);
                                    system.debug('marketableId### '+services.get(serviceId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c);
                                    system.debug('offerId### '+services.get(serviceId).csord__Subscription__r.MarketableOffer__c);
                                    if (att == null || services.get(serviceId).csord__Subscription__c == null || services.get(serviceId).csord__Subscription__r.MarketableOffer__c == null || services.get(serviceId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c == null) {
                                        continue;
                                    }
                                    String offerId = services.get(serviceId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c;
                                    if (offerListForTransientList.contains(offerId)) {
                                        serviceOfferAttMap.put(serviceId + '::' + offerId, att.id);
                                    }
                                }
                                
                                if (!serviceOfferAttMap.isEmpty()) {
                                    getAllRequiredServiceSpecMappings(stepId, orderId, dto, orderServicesMap.get(orderId), serviceOfferAttMap);
                                } else {
                                    sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                      mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Success: Records already processed or No Services Found',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));

                  //stepResults.put(step.Id, new StepResult('Success: Records already processed or No Services Found', OrchestratorConstants.OrchestratorStep.Complete));
                                }
                            } 
                             else if(orderServicesMap.get(orderId) == null && inflightFlagMap.get(orderId) )//&& step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Inflight Orchestration Process')// added for marking inflight remediation order step as complete
                            {
                                sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                //stepResults.put(step.Id, new StepResult('Success: Records already processed or No Services Found', OrchestratorConstants.OrchestratorStep.Complete));
                               mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Success: Records already processed or No Services Found',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));

              }
                            else 
                            {
                               // sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
                                //stepResults.put(step.Id, new StepResult('Error: No Services Found', OrchestratorConstants.OrchestratorStep.Error));
                                 mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Error: No Services Found',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));

              }
                        
                    } catch (Exception ex) {
                        System.debug('exception line ' + ex.getLineNumber());
                        //stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                        mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c= 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));

          }
                
            } catch (Exception ex) {
                //for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                   //stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                    mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c= 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));

        //}
            }
            
            if (!sObjectsToUpsertMap.isEmpty() || !sObjectsToUpdate.isEmpty()) {
                //upsertObjects();
                updateObjects();
            }
            //return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
      Coms_OrderParallelismUtil.updateStepStatus(mapStepDetails);
        }
    
    public void getAllRequiredServiceSpecMappings(Id stepId, Id orderID, TransientDataDTO transientData, Map<Id, csord__Service__c> servicesMap, Map<String, Id> offerServiceToAttachmentMap) {
        //Map<String, CS_SpecificationDTO.ServiceSpecification> guidFinalMap2 = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
         Map<String, Orchestration_Technical__c> guidFinalMap2 = new Map<String, Orchestration_Technical__c>();
        List<TransientDataDTO.DataDTO> transDataDTOList = new List<TransientDataDTO.DataDTO>();
        if(orderAttachmentMap.containsKey(orderId)){
            transDataDTOList = TransientDataDTO.parseDataDTO(orderAttachmentMap.get(orderId).attchBody.toString());
        }
        
        successServicesSet = new Set<String>();
        for (String servOfferId : offerServiceToAttachmentMap.keyset()) {
            //serviceIDSet.add(servOfferId.split('::')[0]);
            String tempServiceId = servOfferId.split('::')[0];
            
            if(processedRecordIds!= null && processedRecordIds.serviceIds != null && processedRecordIds.serviceIds.contains(tempServiceId)){
                continue;
            }
            //Check for limits and return step for Partial processing
            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                incompleteStepId = stepId;
                break;
            }
            system.debug('allReqdSrvSpecList '+ tempServiceId +'---'+specCodeForTransientList);
            List<CS_SpecificationDTO.ServiceSpecification> allReqdSrvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            //allReqdSrvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(tempServiceId), 'FULFILMENT', specCodeForTransientList));
            for(Orchestration_Technical__c specs :serviceAttachmentMap.values()){
            //for (CS_SpecificationDTO.ServiceSpecification specs : allReqdSrvSpecList) {
                if (servicesMap.get(specs.Service__c) != null && servicesMap.get(specs.Service__c).csord__Subscription__c != null && servicesMap.get(specs.Service__c).csord__Subscription__r.MarketableOffer__c != null && servicesMap.get(specs.Service__c).csord__Subscription__r.MarketableOffer__r.Offer_ID__c != null) {
                    String offer = servicesMap.get(specs.Service__c).csord__Subscription__r.MarketableOffer__r.Offer_ID__c;
                    if (specCodeChangeTypeMap.containsKey(offer + '::' + specs.Field_14__c.remove('_Fulfilment'))) {
                        List<String> changeTypeList = specCodeChangeTypeMap.get(offer + '::' + specs.Field_14__c.remove('_Fulfilment'));
                        TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                        
                        if (changeTypeList.contains('New') && specs.Field_3__c == 'Created') {
                            //TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = offer;
                            dataDTO.specCode = specs.Field_14__c;
                            dataDTO.specGUID = specs.Field_11__c;
                            dataDTO.changeType = 'New';
                            guidFinalMap2.put(specs.Field_11__c, specs);
                        } else if ((changeTypeList.contains('Modify') || changeTypeList.contains(servicesMap.get(specs.service__c).Scenario_Type__c)) && specs.Field_3__c == 'Modified') {
                            //TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
                            dataDTO.offerID = offer;
                            dataDTO.specCode = specs.Field_14__c; //remember this will have value ending with _Fulfilment
                            dataDTO.specGUID = specs.Field_11__c;
                            dataDTO.changeType = 'Modify';
                            guidFinalMap2.put(specs.Field_11__c, specs);
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
   public void populateTransientDTO(Id stepId, Id orderID, TransientDataDTO transientData, Map<String, Orchestration_Technical__c> guidFinalMap2, Map<Id, csord__Service__c> servicesMap) {
    //public void populateTransientDTO(Id stepId, Id orderID, TransientDataDTO transientData, Map<String, CS_SpecificationDTO.ServiceSpecification> guidFinalMap2, Map<Id, csord__Service__c> servicesMap) {
        List<TransientDataDTO.DataDTO> transDataDTOList = transientData.dataDTOList;
        System.debug('Checkpoint: IN populateTransientDTO');
        
        Set<String> uniqueProdMetaSet = new Set<String>();
        for (TransientDataDTO.DataDTO dataDTO : transDataDTOList) {
      csord__Service__c serviceRecord = new csord__Service__c();
            List<TransientDataDTO.TransientAttribute> transientAttrList = new List<TransientDataDTO.TransientAttribute>();
            String serviceID = '';
            if (dataDTO.specGUID != null && guidFinalMap2.get(dataDTO.specGUID) != null) {
                serviceID = guidFinalMap2.get(dataDTO.specGUID).service__c;
                
                 serviceRecord = servicesMap.get(serviceID);
                
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
       
       
       String jsonStr = (String)TransientDataDTO.parse(dataDTO);
             serviceRecord.OrderTransientDataDetails__c = jsonStr;
       sObjectsToUpdate.put(serviceRecord.id, serviceRecord);
       sObjectsToUpdate.put(orderId, new csord__Order__c(Id = orderId, isTransientComplete__c = true));
      stepRelationship.put(stepId,orderId);


        }
      //  createAttachmentOnOrder(stepId, orderId, transientData); //review will this TransientData get updated?
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
   /* public void createAttachmentOnOrder(Id stepId, Id orderId, TransientDataDTO transientData) {
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
    }*/
    
    /*public void upsertObjects() {
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
    }*/
    
    public void updateObjects() {
    
        //To remove all the Orders which were failed
        /*if (!failedOrderIdSet.isEmpty()) {
            sObjectsToUpdate.keySet().removeAll(failedOrderIdSet);
        }*/
        
        //Updating all the records including orders and subscription
        //Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        
      Orchestration_PlatformCacheUtility.updatePlatformCache(sObjectsToUpdate.values());

       /* for (Database.SaveResult result : updateResult) {
            //Only order check
            if (result.isSuccess()) {
                stepResults.put(stepRelationship.get(result.getId()), new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
            } else {
                //Error : due to Order Failure
                stepResults.put(stepRelationship.get(result.getId()), new stepResult('Error: Unable to Update Record', OrchestratorConstants.OrchestratorStep.Error));
            }
        }*/
           for (Id stepId : stepRelationship.keySet()) {

              mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(CSPOFA__Message__c='Success: Records processed',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
         }
    }
   /* public boolean hasDMLRowsLimitExceeded() {
        boolean dmlRowsExceeded = true;
        if ((sObjectsToUpsertMap.size() + sObjectsToUpdate.size()) <= (Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c) - Limits.getDMLRows() - 1)) {
            return false;
        }
        return dmlRowsExceeded;
    }*/
}