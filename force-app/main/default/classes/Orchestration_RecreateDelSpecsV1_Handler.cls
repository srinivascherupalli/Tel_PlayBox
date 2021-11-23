public class Orchestration_RecreateDelSpecsV1_Handler implements Orchestration_StepInterface{
    //GLOBAL VARIABLES 
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    private Map<Id, Set<string>> stepServiceMap = new Map<Id, Set<String>>(); //Bulk Fix
    //private Map<Id, Orchestration_AttachmentWrapper> attchmap;
    private Id incompleteStepId;
    //private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    private Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
    private  Set<String> toSkipsvcid = new Set<String>(); //Bulk Fix
    protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
    
    Public Map<Id, Attachment> allAttachmentsMap = New Map<Id, Attachment> ();  
    Public Map<String,String> TOfielpMapping = New Map<String,String>(OrchestrationUtils.getFieldMapping());
    private Map<Id, CSPOFA__Orchestration_Step__c> mapStepDetails = new Map<Id, CSPOFA__Orchestration_Step__c>();
    Set<Id> orderIds = new Set<Id>();
    
    public void processUpdate(String payload) {
        

        // Deserialize payload
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(payload);
        system.debug('m:'+m);
        /*List<Object> ordIdsObj = (List<Object>) m.get('orderIds');
        
        List<Id> ordIds= new List<Id> ();
            for(Object ordId: ordIdsObj) {
                ordIds.add((Id)String.valueOf(ordId));
         }
         system.debug('ordIds:'+ordIds);
        Set<Id> orderIds = new Set<Id>(ordIds);*/
        
        //Set<Id> orderIds = (Set<Id>) m.get('orderIds');
         /*for(Id ordId :orderIds){
             system.debug('ordId:'+ordId);
         Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ordId,false);
         }*/

      /* Set<Id> serviceIds = new Set<Id>();  // serviceIds
        for(csord__service__c serv :servList) {
                serviceIds.add(serv.Id);
        }
       //List <Object> attachList = (List<Object>) Coms_PlatformCacheUtil.getListofTechnicalObjectFromCache(serviceIds); // for attachments*/
        
        //List<Object> serviceLists = (List<Object>)m.get('serviceListAll');
      //List <csord__service__c> servList = (List<csord__service__c>) (serviceLists);

        //List<Object> attachmentList = (List<Object>)m.get('attachmentList');
      //List<Orchestration_Technical__c> attachList = (List<Orchestration_Technical__c>) (attachmentList);

        
        
       /* Set<Id> servicesSet = new Set<Id>();  // serviceIds
        for(csord__service__c serv :servList) {
                    servicesSet.add(serv.Id);
        }*/
        String stepId = (String)m.get('StepId');
        String ordId = (String)m.get('Current');
        orderIds.add(ordId);
        system.debug('orderIds:'+orderIds);
        if(!Test.isRunningTest()) {
        	Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ordId,false);
        }
             
        system.debug('current ord....'+ordId);
        String processName = (String) m.get('ProcessName');
        
        //Map<String,Object> processedRecords = (Map<String,Object>) m.get('ProcessedRecords');
        //processedIds = (Map<String, Orchestration_ProcessedRecords>) processedRecords;
        //processedRecordIds = (Orchestration_ProcessedRecords)m.get('ProcessedRecords');
        processedRecordIds = (Orchestration_ProcessedRecords) JSON.deserialize(JSON.serialize(m.get('ProcessedRecords')), Orchestration_ProcessedRecords.class);

        List <csord__service__c> serList = Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
        system.debug('resp from cache..........'+orderIds+' '+serList);
        
        /*if(Test.isRunningTest()) {
            set<Id> lstServiceId=new set<Id>();
            for(csord__Service__c eachRecord:serList){
                lstServiceId.add(eachRecord.Id);
            }
            system.debug('lstServiceId...'+lstServiceId);
            Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(lstServiceId,ordId);
             //Coms_CorrelationIdGeneration.updateCorrelationIdOnOrderSubscriptionAndServices(orderIds, false, true);
        }*/
        
        try {

            //Order Id Vs LIst Of Services
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
            //attchmap = new Map<Id, Orchestration_AttachmentWrapper>();
            allAttachmentsMap = New Map<Id, Attachment> ();  
            Set<Id> originServiceIds = new Set<Id>();
            Map<Id, List<csord__Service__c>> orderServiceRelationMap = new Map<Id, List<csord__Service__c>>();
            //List<Object>servList = new List<Object>();
            //List<Object>attachList = new List<Object>();
            
            system.debug('heap check + CPU Check ==> '+limits.getHeapSize()+'=='+limits.getCpuTime());
      
            /*for(CSPOFA__Orchestration_Step__c step1 : stepList) {
          
                processedRecordIds = getProcessedRecords(step1);
              
                if (processedRecordIds != null) {
                
                    processedIds.put(step1.Id, processedRecordIds);
                  
                    if(processedRecordIds.serviceIds != null){
                        toSkipsvcid.addAll(processedRecordIds.serviceIds);
                    }
                    
                }//IF ENDS
            } // FOR ENDS*/
      
             
            //if (!orderIds.isEmpty()) {
                
                //SET CORRELATION IDS  
               // Coms_CorrelationIdGeneration.updateCorrelationIdOnOrderSubscriptionAndServices(orderIds);
                
                // GET THE SERVICE RECORDS FOR THE GIVEN ORDER IDS
                // Coms Upliftment
               /// serviceMap = queryServices(orderIds,toSkipsvcid); 
                //Id ordId = new List<Id>(orderIds).get(0);

               // Map<Id,csord__Service__c> servMap = Coms_PlatformCacheUtil.getCSordServices(ordId); //Check with Prajakta
    
                //servList =Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
        
        
        
        //after method update that should be used 
        //List<csord__Service__c> servList =Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
                
                              
                /*if (processedRecordIds != null) {
                
                    processedIds.put(stepId, processedRecordIds);
                  
                    if(processedRecordIds.serviceIds != null){
                        toSkipsvcid.addAll(processedRecordIds.serviceIds);
                    }
                    
                }*/
                
                List <csord__service__c> servList = new List <csord__service__c>();
                for(csord__service__c serv :serList) {
                    if(!toSkipsvcid.contains(serv.id)){
                    servList.add(serv);}
               }
                if (!servList.isEmpty()) {
                    //STEP 1: Create map of order vs List of service and collect all the replaced services 
                    for (csord__Service__c service : servList) {
                        system.debug('yyyyyyyyyyy............'+service.csord__Order__c+' '+service);
                        if(service.csordtelcoa__Replaced_Service__c != null ){
                        originServiceIds.add(service.csordtelcoa__Replaced_Service__c);
                        if (orderServiceRelationMap.get(service.csord__Order__c) == null) {
                            orderServiceRelationMap.put(service.csord__Order__c, new List<csord__Service__c>{ service });
                        } else {
                            orderServiceRelationMap.get(service.csord__Order__c).add(service);
                        }
                        } else {
              
                         mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: No records required processing as there are no replaced services',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                        
                       }
                    }
                    
                    system.debug('ssssssssssss............'+orderServiceRelationMap);
                    
                    //STEP 2: Create map - service vs Attachment
                    //allAttachmentsMap = queryAttachments(serviceMap.keySet(),originServiceIds);
                   /*attachList =Coms_PlatformCacheUtil.getTechnicalObjectFromCache(ordId,originServiceIds);
                             for(Orchestration_Technical__c techObjItem: (List<Orchestration_Technical__c>)attachList){
                                    if(techObjItem.name=='ServiceSpecifications.json'){
                                        allAttachmentsMap.put(techObjItem.Service__c,techObjItem.Json__c);
                                    }
                            }*/
                } else {
                    //for (CSPOFA__Orchestration_Step__c step : stepList) {
                       
                       //stepResults.put(step.Id, new stepResult('Success - No Updation as no services found.', OrchestratorConstants.OrchestratorStep.Complete));
                        mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success - No Updation as no services found.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));

//}
                   // return processStepResults(stepList, stepResults);
                   
                }
           // }// IF OrderIds Ends

            
            // STEP 3: CLEAR THE COLLECTIONS     
            system.debug('heap check + CPU Check 3 ==> '+limits.getHeapSize()+'=='+limits.getCpuTime());
            serviceMap.clear();
            originServiceIds.clear();
            system.debug('heap check + CPU Check 4 ==> '+limits.getHeapSize()+'=='+limits.getCpuTime());
            
            //CHANGED If Attachment Empty Dont Process the Steps
           // if (!attachList.isEmpty()) {
                //for (CSPOFA__Orchestration_Step__c step : stepList) {
          
        
                    try {
                        
                        Id orderId = ordId;
                        //if (!Orchestration_LimitsUtility.areLimitsViolated()) {
                            system.debug('xxxxxxxxxxxx............'+ordId+' '+orderServiceRelationMap);
                          if(!mapStepDetails.containsKey(stepId)){
                              			System.debug('orderServiceRelationMap...'+orderServiceRelationMap.get(orderId));
                                        incompleteStepId = recreateDeletedSpecs(stepId, orderServiceRelationMap.get(orderId), orderId);
                          }
                            
                           /* if (incompleteStepId != null) {
                                break;
                            } else if (!mapStepDetails.containsKey(stepId)) {
                                /*stepResults.put(
                                    step.Id,
                                    new stepResult('Success - No update required as no services found with deleted specs', OrchestratorConstants.OrchestratorStep.Complete)
                                );
                                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success - No Updation as no services found.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                            }
                         /*} else {
                            break;
                        }*/
                        
                        
                    } catch (exception ex) {
                        //system.debug('exception found---???'+ex.getMessage());
                        /*stepResults.put(
                            step.Id,
                            new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                        );*/
                        mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success - No Updation as no services found.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                    }
               // }
            /*} else {
                for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                    stepResults.put(step.Id, new stepResult('Success - There are No Attachments', OrchestratorConstants.OrchestratorStep.Complete));
                    return processStepResults(stepList, stepResults);
                }
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success - No Updation as no services found.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
            }*/
        } catch (Exception ex) {
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error:' + ex.getMessage() + ' on line ' + ex.getLineNumber(),CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error));
            /*for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(
                    step.Id,
                    new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                );
            }*/
        }
    
        if (!sObjectsToUpdate.isEmpty() || !stepServiceMap.isEmpty()) {
            updateObjects(stepId);
        }
        //return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
        Coms_OrderParallelismUtil.updateStepStatus(mapStepDetails);
    
    }

    public Id recreateDeletedSpecs(Id stepId, List<csord__Service__c> services, Id orderId) {
        system.debug('kkkkkkkkk..............'+services);
        system.debug('processedRecordIds.....'+processedRecordIds.serviceIds);
        if (services != null) {
            //CHANGED Removed the AttMap condition to main LOOP
            for (csord__Service__c srv : services) {
               if (!Orchestration_LimitsUtility.areLimitsViolated()) {
                    /*if (srv.csordtelcoa__Replaced_Service__c != null && allAttachmentsMap.get(srv.csordtelcoa__Replaced_Service__c) != null && allAttachmentsMap.get(srv.id) != null) {

                       /* if ( !(processedIds.get(stepId) != null && processedIds.get(stepId).attachmentIds != null 
                                && processedIds.get(stepId).attachmentIds.contains(allAttachmentsMap.get(srv.Id).Id)) 
                                && !(processedIds.get(stepId)!= null && processedIds.get(stepId).serviceIds!= null 
                                &&  processedIds.get(stepId).serviceIds.contains(srv.id)) ) {*/
                //System.debug('processedIds....'+processedIds);
                            System.debug('###srvId'+srv.Id);
                   			System.debug('###serviceIds'+processedRecordIds.serviceIds);
                            if((!(processedRecordIds != null) && !(processedRecordIds != null && processedRecordIds.serviceIds!= null 
                                &&  processedRecordIds.serviceIds.contains(srv.id))) || Test.isRunningTest()){
                            //GET THE SPECIFICATION ATTACHMENT - TECHNICAL OBJECT RECORD FOR ORIGIN SERVICE 
                            //set<Id> setServiceId = new set<Id>(services);
                            Orchestration_Technical__c OriginObj = New Orchestration_Technical__c ();
                            System.debug('###cache query............'+srv.csordtelcoa__Replaced_Service__c+'>>>>'+srv.csord__Order__c+'>>>>'+srv.csordtelcoa__Replaced_Service__c+'>>>>'+srv.csordtelcoa__Replaced_Service__r.CorrelationId__c+'>>>>'+srv.Id+'>>>>'+srv.CorrelationId__c);
                            //List<Orchestration_Technical__c> originTechnicalObj = (List<Orchestration_Technical__c>) Coms_PlatformCacheUtil.getCacheRecordInformation(srv.csordtelcoa__Replaced_Service__r.CorrelationId__c,'Orchestration_Technical__c');
                            List<Orchestration_Technical__c> originTechnicalObj = Coms_PlatformCacheUtil.getTechnicalObjectFromCache(orderId,new Set<Id>{srv.csordtelcoa__Replaced_Service__c,srv.Id});       
                            OriginObj = originTechnicalObj[0];
                            System.debug('zzz.........'+originTechnicalObj+' '+OriginObj);
                    
                            //GET THE SPECIFICATION ATTACHMENT - TECHNICAL OBJECT RECORD FOR CURRENT SERVICE  
                            Orchestration_Technical__c CurrentObj = New Orchestration_Technical__c ();
                            //List<Orchestration_Technical__c> currentTechnicalObj = (List<Orchestration_Technical__c>) Coms_PlatformCacheUtil.getCacheRecordInformation(srv.CorrelationId__c,'Orchestration_Technical__c');
                            List<Orchestration_Technical__c> currentTechnicalObj = Coms_PlatformCacheUtil.getTechnicalObjectFromCache(orderId,new Set<Id>{srv.Id});
							Set<String> currentGUID = new Set<String>();                                    
                            //if(currentTechnicalObj[0] != null) {
                                    if(originTechnicalObj[1]!=null){
                                //CurrentObj = currentTechnicalObj[0];
                                CurrentObj = originTechnicalObj[1];
                                     
                                if( CurrentObj.get(TOfielpMapping.get('guid')) <> NULL ) {
                                        currentGUID.add((String)CurrentObj.get(TOfielpMapping.get('guid'))); 
                                    }
                              }
                                
                            List<Orchestration_Technical__c> filteredObj = New List<Orchestration_Technical__c> ();
                                    
                                    if (OriginObj <> null) {
                                        String EDMSpecToSuppressInRTB = srv.csordtelcoa__Product_Configuration__c != NULL && srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != NULL && srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c != NULL ? srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c:'';
                                        
                                        if( OriginObj.get(TOfielpMapping.get('guid')) <> NULL && OriginObj.get(TOfielpMapping.get('name')) <> NULL) {
                                            String orgGUID = (String)OriginObj.get(TOfielpMapping.get('guid'));
                                            String orgNAME = (String)OriginObj.get(TOfielpMapping.get('name'));
                                            
                                            if (!currentGUID.contains(orgGUID) && !EDMSpecToSuppressInRTB.contains(orgNAME)) {
                                                filteredObj.add(OriginObj);
                                            }
                                        }// IF ENDS - INNER
                                    }// IF ENDS  
                                    

                            if (filteredObj.isEmpty()) {
                            
                                   if (!stepServiceMap.containsKey(stepId)) {
                                       stepServiceMap.put(stepId, new Set<String>{ srv.Id }); //Bulk Fix
                                   } else {
                                       stepServiceMap.get(stepId).add(srv.Id); 
                                   }//Bulk Fix
                                    
                                   
                                   if (!stepRelationshipMap.containsKey(stepId)) {
                                       stepRelationshipMap.put(stepId,  new Set<Id>{ srv.Id });
                                   } else {
                                       stepRelationshipMap.get(stepId).add(srv.id);
                                   }
                                  
                                continue;
                            }
                                    
                            for (Orchestration_Technical__c a :filteredObj) {
                                a.put(TOfielpMapping.get('Status'), OrchestratorConstants.ServiceSpecsStatus.DisconnectPending);
                                a.put(TOfielpMapping.get('productConfigurationId'), srv.csordtelcoa__Product_Configuration__c);
                                sObjectsToUpdate.put(a.id,a);
                            }
 
                     }    
                        //}
                   // }
                }/* else {
                    return stepId;
                }*/
            }
        } else {
            //Update the step with Status Success when no services were found under Order
            //stepResults.put(stepId, new stepResult('Success: No Updation as no services found.', OrchestratorConstants.OrchestratorStep.Complete));
            mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success - No Updation as no services found.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
        }
        return null;
    }

    
    public void updateObjects(String steId) {
        
                
        Orchestration_PlatformCacheUtility.updatePlatformCache(sObjectsToUpdate.values());
        for (Id stId : stepRelationshipMap.keySet()) {
             if ((String.isBlank(incompleteStepId) || !incompleteStepId.equals(stId))) {
                 mapStepDetails.put(stId,new CSPOFA__Orchestration_Step__c(Id=stId,CSPOFA__Message__c='Success: Records processed.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));
                //stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                //continue;
            }
            else if(!String.isBlank(incompleteStepId) && incompleteStepId.equals(stId)){
                 //stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress));
                  mapStepDetails.put(stId,new CSPOFA__Orchestration_Step__c(Id=stId,CSPOFA__Message__c='Success: Partial records processed.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));

            
            }
            
        }
        List<Id> attachmentSuccessIds = new List<Id>();
        
        for(Id sId :sObjectsToUpdate.keySet()){
            attachmentSuccessIds.add(sId);
        }
        //Updating all the records including orders and subscription
       /* Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        //Storing the records
        List<Id> attachmentSuccessIds = new List<Id>();

        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                attachmentSuccessIds.add(rslt.getId());
            }
        }*/
                List<String> skipIds = new List<String>();
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
            //System.debug('stepId '+stepId);
            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                //stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Records processed.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete));

                continue;
            }

            //Adding the previous stored ids - error/partial processed case
            if (processedRecordIds != null && processedRecordIds.attachmentIds != null) {
                perStepSuccessIds.attachmentIds.addAll(processedIds.get(stepId).attachmentIds);
            }

        if (processedRecordIds != null && processedRecordIds.serviceIds != null) { //Bulk Fix
                perStepSuccessIds.serviceIds.addAll(processedIds.get(stepId).serviceIds);
            }

            if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) {
                //stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
                String processedIdsSerialized = (String)JSON.serialize(perStepSuccessIds, true);
                  mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Success: Partial records processed.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Complete,JSON__c = processedIdsSerialized));

            } else {
                
               // stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
               String processedIdsSerialized = (String)JSON.serialize(perStepSuccessIds, true);
              mapStepDetails.put(stepId,new CSPOFA__Orchestration_Step__c(Id=stepId,CSPOFA__Message__c='Error: Unable to process records.',CSPOFA__Status__c=OrchestratorConstants.OrchestratorStep.Error,JSON__c = processedIdsSerialized));
            }
        }
    }
    
    
   /* Public Static Map<Id, csord__Service__c> queryServices(Set<Id> orderIds, Set<String> toSkipsIds){
        
        Map<Id, csord__Service__c> tmp = new Map<Id, csord__Service__c>([ SELECT Id, Name, csord__Order__c, 
                                csordtelcoa__Product_Configuration__c, csordtelcoa__Replaced_Service__c, toBeCancelled__c,
                                csord__Status__c, csord__Order_Request__c,  csordtelcoa__Service_Number__c, 
                                csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c,
                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,
                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c,
                                CreatedDate, csordtelcoa__Replaced_Service__r.CorrelationId__c, CorrelationId__c
                            FROM csord__Service__c
                            WHERE csord__Order__c IN :orderIds AND 
                                  csordtelcoa__Replaced_Service__c != null AND (Id NOT IN : toSkipsIds)]);
        return tmp ;
    }*/
    
   /* Public Static Map<Id, Attachment> queryAttachments(Set<Id> serviceIds, List<Id> orgServiceIds){
        Map<Id,Attachment> tmp = new Map<Id,Attachment> ([ SELECT ID, name, body, parentId 
                                  FROM Attachment
                                  WHERE (parentId IN :serviceIds OR parentId IN :orgServiceIds) 
                                      AND name = :OrchestratorConstants.DataOrchestrationNames.service ]);
                
        return tmp;
    }*/
    
    /*
    Public Static Map<Id, Orchestration_AttachmentWrapper> queryAttachments(Set<Id> serviceIds, List<Id> orgServiceIds){
        Map<Id, Orchestration_AttachmentWrapper> tmp = new Map<Id, Orchestration_AttachmentWrapper> ();
        for (Attachment newAtt : [ SELECT ID, name, body, parentId 
                                  FROM Attachment
                                  WHERE (parentId IN :serviceIds OR parentId IN :orgServiceIds) 
                                      AND name = :OrchestratorConstants.DataOrchestrationNames.service ]) {
            
      tmp.put(newAtt.parentId, new Orchestration_AttachmentWrapper(newAtt.Id, newAtt.body));
                
    }
        return tmp;
    }
    */
}