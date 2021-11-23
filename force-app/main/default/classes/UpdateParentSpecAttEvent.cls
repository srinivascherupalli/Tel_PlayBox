public class UpdateParentSpecAttEvent {
    //TODO: New class to have attachment processing logic for Orchestration process: Done
    public static Orchestration_Technical__c techObj ;
    
    public static Integer updateParentSpecAttr(Set<Id> subscriptionIds, Set<Id> orderIdSet, Integer pfSequence, String cacheHandler){
        
        System.debug(' updateParentSpecAttr () ==> ');
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>();        
        servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__r.csordtelcoa__Opportunity__c, csord__Order__c, csord__Subscription__c, csord__Service__c, RunTimeParent__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.isDesignTimeParent__c FROM csord__Service__c WHERE csord__Subscription__r.Id IN :subscriptionIds]);
         
        //Check for design time parent in cache respective of the order's subscription in batch job chunk
        List<Id> designTimeParentOrderId = new List<Id>();
        for(Id ordId: orderIdSet){
            if(OrchestrationCacheManager.isStoredInCache(ordId)){
                OrchestrationCacheBackupHelper.OrderObserverManagerOrderCacheHandlerWrapper orderCacheWrapper = (OrchestrationCacheBackupHelper.OrderObserverManagerOrderCacheHandlerWrapper) OrchestrationCacheManager.get(ordId);
                if(orderCacheWrapper.NetworkCodeGUIDRelationMap.isEmpty()){
                    designTimeParentOrderId.add(ordId);
                }
            }
            else{
                designTimeParentOrderId.add(ordId);
            }
        }
        
        //Fetch design time parent services
        Map<Id, csord__Service__c> designTimeParentServicesMap = new Map<Id, csord__Service__c>(); 
        if(!designTimeParentOrderId.isEmpty()){
            designTimeParentServicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__c FROM csord__Service__c WHERE csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.isDesignTimeParent__c = true And csord__Order__c IN :designTimeParentOrderId]);
        }
    
        //Map<String, Orchestration_AttachmentWrapper> designTimeParentServiceToAttachmentMap = new Map<String, Orchestration_AttachmentWrapper>();
        if(!designTimeParentServicesMap.isEmpty()){
            for (Attachment att : [SELECT id, Name, body, parentId FROM Attachment WHERE parentId IN :designTimeParentServicesMap.keySet() AND name = :OrchestratorConstants.DataOrchestrationNames.service]) {
                csord__Service__c designTimeParentService = designTimeParentServicesMap.get(att.parentId);
                Map<String, String> NetworkCodeGUIDRelationMap = new Map<String, String>();
                CS_ServiceSpecificationV3 servSpecs = (CS_ServiceSpecificationV3) system.JSON.deserialize(att.Body.toString(), CS_ServiceSpecificationV3.class);
                System.debug('@@@att.Body.toString()'+att.Body.toString());
                System.debug('@@@servSpecs'+servSpecs);
                System.debug('@@@servSpecs.specifications'+servSpecs.specifications);
                if(servSpecs.specifications != null ){
                    for (CS_ServiceSpecificationV3.ServiceSpecifications specification : servSpecs.specifications) {
                        // now get attributes for this specification.
                        string code = specification.Code;
                        string guid = specification.Guid;
                        NetworkCodeGUIDRelationMap.put(code, guid);//JJ: Orchestration new design
                    }
                    OrchestrationCacheBackupHelper.OrderObserverManagerOrderCacheHandlerWrapper orderWrapper = new OrchestrationCacheBackupHelper.OrderObserverManagerOrderCacheHandlerWrapper(NetworkCodeGUIDRelationMap, 'In Progress', null);
                    OrchestrationCacheBackupHelper.uploadDataForOrder(designTimeParentService.csord__Order__c, orderWrapper);
                }
            }
        }
        
        //Looking for run time parent services if not available in current chunk
        List<String> runTimeParentServices = new List<String>();
        Map<Id, csord__Service__c> runTimeParentServicesMap = new Map<Id, csord__Service__c>();
        for(csord__Service__c s: servicesMap.values()){
            System.debug(' s ==> '+s);
            if(s.RunTimeParent__c != null && !servicesMap.containsKey(s.RunTimeParent__c)){
                    runTimeParentServices.add(s.Id);
            }
        }
        //Merging runtime parent services into the all services map
        if(!runTimeParentServices.isEmpty()){
            runTimeParentServicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__r.csordtelcoa__Opportunity__c, csord__Order__c, csord__Subscription__c, csord__Service__c, RunTimeParent__c, csordtelcoa__Product_Configuration__r.isDesignTimeParent__c FROM csord__Service__c WHERE Id IN :runTimeParentServices]);
            servicesMap.putAll(runTimeParentServicesMap);
        }
        
        //Map<String, Orchestration_AttachmentWrapper> serviceToAttachmentMap = new Map<String, Orchestration_AttachmentWrapper>();
        for (Attachment att : [SELECT id, Name, body, parentId FROM Attachment WHERE parentId IN :servicesMap.keySet() AND name = :OrchestratorConstants.DataOrchestrationNames.service]) {
            //serviceToAttachmentMap.put(att.parentId, new Orchestration_AttachmentWrapper(att.Id, att.Name, att.Body, att.ParentId));
            String key = att.parentId;//servicesMap.get(att.parentId).csord__Order__c +'-'+att.parentId;
            Orchestration_AttachmentWrapper attWrapper = new Orchestration_AttachmentWrapper(att.Id, att.Name, att.Body, att.ParentId);
            OrchestrationCacheBackupHelper.uploadData(key, attWrapper);
        }
        
        //create wrapper for orders which does not have any design time parent and putting this object into cache with status In P rogress
        for(Id oId: orderIdSet){
            if(! OrchestrationCacheManager.isStoredInCache(oId)){
                OrchestrationCacheBackupHelper.OrderObserverManagerOrderCacheHandlerWrapper orderWrapper = new OrchestrationCacheBackupHelper.OrderObserverManagerOrderCacheHandlerWrapper(null, 'In Progress', null);
                OrchestrationCacheBackupHelper.uploadDataForOrder(oId, orderWrapper);
            }
        }
        
        System.Debug(' cacheHandler ==> ' + cacheHandler );
        System.Debug(' orderIdSet ==> ' + orderIdSet);
        //Store order ids in cache to check failure of orders in PF event
        OrchestrationCacheBackupHelper.putOrderIdsInCache(cacheHandler,orderIdSet);
        
        Integer seq = pfSequence;
        List<String> serviceIds = new List<String>();
        List<ProcessAttachmentForOrchestration__e> pfEvents = new List<ProcessAttachmentForOrchestration__e>();
        Orchestration_Config__mdt config = Orchestration_Config__mdt.getAll().values();
        Integer srvLimit = config.ServicesLimitInPlatformEvent__c != null ? (Integer) config.ServicesLimitInPlatformEvent__c : 4;
        
        for (csord__Service__c service : servicesMap.values()) {
            System.Debug(' service ==> ' + service);
            serviceIds.add(service.Id);
           // if(serviceIds.size()== srvLimit){
                seq++;
           //     String sIds = serviceIds.toString().replace('(','').replace(')','');
           //     
           //     FOR SARV:
           
                ProcessAttachmentForOrchestration__e pfEvent = new ProcessAttachmentForOrchestration__e(Sequence__c=String.valueOf(seq), ServiceIds__c=service.Id, PlatformCacheHandler__c=cacheHandler);
                OrchestrationCacheBackupHelper.putSubmittedPlatformEventsCountInCache(cacheHandler, seq);
                pfEvents.add(pfEvent);
                serviceIds = new List<String>();
           
            /*** CREATE TECH OBJ ***/
            techObj = New Orchestration_Technical__c ( Field_19__c = service.csord__Order__c,
                                                        Field_3__c = 'Started',
                                                        Field_14__c = 'PreREQ',
                                                        Field_5__c = service.Id );
            insert techObj ;
                
        }
        
        
        OrchestrationCacheBackupHelper.publishAttachmentProcessingEvent(pfEvents);
        
        /*
        if(serviceIds.size()>0){
            seq++;
            String sIds = serviceIds.toString().replace('(','').replace(')','');
            ProcessAttachmentForOrchestration__e pfEvent = new ProcessAttachmentForOrchestration__e(Sequence__c=String.valueOf(seq), ServiceIds__c=sIds, PlatformCacheHandler__c=cacheHandler);
            OrchestrationCacheBackupHelper.putSubmittedPlatformEventsCountInCache(cacheHandler, seq);
            pfEvents.add(pfEvent);
        }*/ 
        
        
        return seq;
    }
}