public class OrchestrationCacheBackupHelper {
     
    public static void uploadData(String key, Object obj){
         System.debug(' uploadData() ==> ' );
         System.debug(' key ==> ' + key );
         System.debug(' obj ==> ' + obj ); 
        OrchestrationCacheManager.put(key, obj);
        Map<String, Object> objMap = new Map<String, Object>();
        //objMap.put(key, obj);
        //objMap = (Map<String, Object>) obj;
        //OrchestrationCacheBackupManager.put(objMap);
    }
    
    /*public static void uploadData(String primaryKey, String secondaryKey, Object obj){
        Map<String, Object> tempObj = new Map<String, Object>();
        Map<String, Object> innerMap = new Map<String, Object>();
        if(OrchestrationCacheManager.isStoredInCache(primaryKey)){
            innerMap = (Map<String, Object>) OrchestrationCacheManager.get(primaryKey);
            if(innerMap.containsKey(secondaryKey)){
                tempObj = (Map<String, Object>) innerMap.get(secondaryKey);   
            }
        }
        tempObj.putAll((Map<String, Object>) obj);
        innerMap.put(secondaryKey, tempObj);
        OrchestrationCacheManager.put(primaryKey, innerMap);
    }*/
    
    public class OrderObserverManagerOrderCacheHandlerWrapper{
        public Map<String, String> NetworkCodeGUIDRelationMap = new Map<String, String>();
        public String status = '';
        public List<String> error = new List<String>();
        
        public OrderObserverManagerOrderCacheHandlerWrapper(Map<String, String> NetworkCodeGUIDRelationMap, String status, List<String> error){
            if(NetworkCodeGUIDRelationMap != null && !NetworkCodeGUIDRelationMap.isEmpty())
                this.NetworkCodeGUIDRelationMap.putAll(NetworkCodeGUIDRelationMap);
            if(status != '')
                this.status = status;
            if(error != null && error.size() > 0)
                this.error.addAll(error);
        }
    }
    
    public static void uploadDataForOrder(String orderId, OrderObserverManagerOrderCacheHandlerWrapper wrapperObj){
        if(OrchestrationCacheManager.isStoredInCache(orderId)){
            OrderObserverManagerOrderCacheHandlerWrapper obj = (OrderObserverManagerOrderCacheHandlerWrapper) OrchestrationCacheManager.get(orderId);
            obj.NetworkCodeGUIDRelationMap.putAll(wrapperObj.NetworkCodeGUIDRelationMap);
            obj.status = wrapperObj.status;
            obj.error.addAll(wrapperObj.error);
            OrchestrationCacheManager.put(orderId, obj);
        }
        else{
            OrchestrationCacheManager.put(orderId, wrapperObj);
        }
    }
    
    public static void publishAttachmentProcessingEvent(List<ProcessAttachmentForOrchestration__e> Events){
        // Call method to publish events
        
        System.debug('Events ==> ' + Events );
        
        List<Database.SaveResult> results = EventBus.publish(Events);
        
        for(Database.SaveResult result: results){
            if (result.isSuccess()) {
                System.debug('Successfully published event ==> ' + result );
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
    
    
    public static Object getCacheDataObject(String key){
        Object backupData = OrchestrationCacheManager.get(key);

        return backupData;
    }
    
    Public Static List<String> updatedServiceIds  = new List<String>();
    
    public static void processAttachment(String key, String cacheHandler){
        System.debug('serviceIds in PF event: '+key);
        List<String> serviceIds = new List<String>();
        if(key != null){
            if(key.contains(','))
                serviceIds = key.split(',');
            else 
                serviceIds.add(key);
        }
        System.debug('service ids list ==> '+serviceIds);
        
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Order__r.csordtelcoa__Opportunity__c, csord__Order__c, csord__Subscription__c, csord__Service__c, RunTimeParent__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.isDesignTimeParent__c FROM csord__Service__c WHERE Id IN :serviceIds]);
        system.debug('servicesMap ==> '+servicesMap);
        for(String service: serviceIds){
            csord__Service__c s = New csord__Service__c ();
            if ( servicesMap.get(service) <> NULL ) {
                s = servicesMap.get(service);
            }
            
            try{
                if ( s <> NULL ) 
                    updateSpecsAttibutes(service, s);
            }
            catch(Exception e){
                csord__Order__c objOrder = new csord__Order__c(Id=s.csord__Order__c, csord__Status2__c='Order Decomposition Failed', Observer_Message__c=e.getMessage().left(255));
                update objOrder;
                if(OrchestrationCacheManager.isStoredInCache(s.csord__Order__c)){
                    OrderObserverManagerOrderCacheHandlerWrapper obj = (OrderObserverManagerOrderCacheHandlerWrapper) OrchestrationCacheManager.get(s.csord__Order__c);
                    obj.status = 'Error';
                    obj.error.add(e.getMessage().left(255));
                    OrchestrationCacheManager.put(s.csord__Order__c, obj);
                }
            }
        }
        putProcessedPlatformEventsCountInCache(cacheHandler);
        //createOrchestrationProcess(cacheHandler);
    }
    /*
    public static void createOrchestrationProcess(String cacheHandler){
        System.debug(' createOrchestrationProcess () ==> ' + cacheHandler);
        //Logic to call create orchestration process from PF event
        List<Id> finalOrders = new List<Id>();
        
        if(OrchestrationCacheManager.isStoredInCache(cacheHandler)){
            OrderObserverManagerCacheHandlerWrapper cacheHandlerWrapper = (OrderObserverManagerCacheHandlerWrapper) OrchestrationCacheManager.get(cacheHandler);
            System.debug(' cacheHandlerWrapper ==> ' + cacheHandlerWrapper);
            Integer diff = cacheHandlerWrapper.submitted - cacheHandlerWrapper.processed;
            System.debug(' diff ==> ' + diff);
            System.debug(' cacheHandlerWrapper.orderIdssize() ==> ' + cacheHandlerWrapper.orderIds.size() );
            if(diff == 0 && cacheHandlerWrapper.orderIds.size() > 0){
                for(Id oId: cacheHandlerWrapper.orderIds){
                    System.debug(' oId ==> ' + oId );
                    if(OrchestrationCacheManager.isStoredInCache(oId)){
                        
                        OrderObserverManagerOrderCacheHandlerWrapper obj = (OrderObserverManagerOrderCacheHandlerWrapper) OrchestrationCacheManager.get(oId);
                        
                        System.debug(' obj ==> ' + oId );
                        if(obj.status != 'Error'){
                            finalOrders.add(oId);
                        }
                    }
                }
            }
        }
        System.debug(' finalOrders ==> ' + finalOrders);
        if(!finalOrders.isEmpty()){
           // ManageOrdPrereqisteOrchestrationHandler.createOrchestrationProcessASYNC(finalOrders);
        }
    } 
    */
    
    public static void updateSpecsAttibutes(String key, csord__Service__c serviceObj) {
        
        System.debug(' updateSpecsAttibutes() ==> ');
        System.debug(' updateSpecsAttibutes() key ==> ' + key);
        System.debug(' updateSpecsAttibutes() serviceObj ==> ' + serviceObj );
        
        updatedServiceIds.add(serviceObj.Id); 
        
        //csord__Service__c service = serviceObj;//servicesMap.get(key);
        if(Test.isRunningTest()){
           Map<String, String> NetworkCodeGUIDRelationMap = new Map<String, String>();
           OrderObserverManagerOrderCacheHandlerWrapper orderWrapper = new OrderObserverManagerOrderCacheHandlerWrapper(NetworkCodeGUIDRelationMap, 'In Progress', null);
          uploadDataForOrder(serviceObj.csord__Order__c, orderWrapper);
        }
        OrderObserverManagerOrderCacheHandlerWrapper orderIdCachedMap = (OrderObserverManagerOrderCacheHandlerWrapper) getCacheDataObject(serviceObj.csord__Order__c);
        Map<String, String> NetworkCodeGUIDRelationMap = orderIdCachedMap.NetworkCodeGUIDRelationMap;
        
        //Map<String, Object> serviceToAttachmentMap = new Map<String, Object>();
        //if(orderIdCachedMap.containsKey('serviceToAttachmentMap'))
        //serviceToAttachmentMap = (Map<String, Object>) orderIdCachedMap.get('serviceToAttachmentMap');
        
        //System.debug('@@@$$$'+serviceToAttachmentMap);
        //Orchestration_AttachmentWrapper serviceattachment = (OrchestrationCacheManager.isStoredInCache(serviceObj.csord__Order__c+'-'+key)) ? (Orchestration_AttachmentWrapper) getCacheDataObject(serviceObj.csord__Order__c+'-'+key) : null;
        Orchestration_AttachmentWrapper serviceattachment = (OrchestrationCacheManager.isStoredInCache(key)) ? (Orchestration_AttachmentWrapper) getCacheDataObject(key) : null;
        System.debug(' serviceattachment ==> ' + serviceattachment );
        if(Test.isRunningTest()){
            Attachment attach = [Select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications.json' Limit 1];
            serviceattachment = new Orchestration_AttachmentWrapper(attach.Id, attach.body);
        }
        
        List<String> orderIds = New List<String> ();

        if(serviceattachment == null){


            list<Orchestration_Technical__c> techObjs = new list<Orchestration_Technical__c> ();
                
            techObjs = [SELECT Id, Field_3__c, Field_5__c, Field_19__c, Field_14__c FROM Orchestration_Technical__c 
                                WHERE Field_5__c IN : updatedServiceIds ];
                
            try{
                    
                for ( Orchestration_Technical__c a :techObjs){
                    a.Field_3__c = 'Completed';
                }   
            }
            catch(Exception e){
                System.debug('Error: '+e.getMessage());
                for ( Orchestration_Technical__c a :techObjs){
                    a.Field_3__c = 'Error';
                }
            }
                
            update techObjs; 
                

        }else if(serviceattachment != null){
            orderIds.add(serviceObj.csord__Order__c);
            System.debug('attchBody.toString ==> '+serviceattachment.attchBody.toString());
            Boolean attachmentChanged = false;            
            Map<String, String> tempOwnCodeGuidMap = new Map<String, String>();
            Map<String, String> tempParentCodeGuidMap = new Map<String, String>();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachment.attchBody.toString());
            List<Object> lstSpecifications = (List<Object>) results.get('specifications');
            if (lstSpecifications != null) {
                //populating self service code to guid map
                for (Object specification : lstSpecifications) {
                    Map<String, Object> spec = (Map<String, Object>) specification;
                    // now get attributes for this specification.
                    string code = (String) spec.get('code');
                    string guid = (String) spec.get('guid');
                    tempOwnCodeGuidMap.put(code, guid);//JJ: Orchestration new design
                }
                
                //populating parent service code to guid map
                if(serviceObj.csord__Service__c != null){
                    System.debug('@@@@'+serviceObj.csord__Service__c);
                    //Orchestration_AttachmentWrapper serviceattachment1 = (OrchestrationCacheManager.isStoredInCache(serviceObj.csord__Order__c+'-'+serviceObj.csord__Service__c)) ? (Orchestration_AttachmentWrapper) getCacheDataObject(serviceObj.csord__Order__c+'-'+serviceObj.csord__Service__c) : null;
                    Orchestration_AttachmentWrapper serviceattachment1 = (OrchestrationCacheManager.isStoredInCache(serviceObj.csord__Service__c)) ? (Orchestration_AttachmentWrapper) getCacheDataObject(serviceObj.csord__Service__c) : null;
                    System.debug('@@@@'+serviceattachment1);
                    String parentServiceAttachmentStr = (serviceattachment1 != null) ? serviceattachment1.attchBody.toString() : '';
                    if(Test.isRunningTest()){
                        parentServiceAttachmentStr = getBody();
                    }
                    if(parentServiceAttachmentStr != ''){
                        Map<String, Object> parentResults = (Map<String, Object>) JSON.deserializeUntyped(parentServiceAttachmentStr);
                        List<Object> parentLstSpecifications = (List<Object>) parentResults.get('specifications');
                        if (parentLstSpecifications != null) {
                            for (Object parentSpecification : parentLstSpecifications) {
                                Map<String, Object> spec = (Map<String, Object>) parentSpecification;
                                // now get attributes for this specification.
                                string code = (String) spec.get('code');
                                string guid = (String) spec.get('guid');
                                tempParentCodeGuidMap.put(code, guid);//JJ: Orchestration new design
                            }
                        }
                    }
                } 
                
                //populating run time parent service code to guid map
                if(serviceObj.RunTimeParent__c != null){
                    System.debug('@@@@'+serviceObj.RunTimeParent__c);
                    //Orchestration_AttachmentWrapper serviceattachment2 = (OrchestrationCacheManager.isStoredInCache(serviceObj.csord__Order__c+'-'+serviceObj.RunTimeParent__c)) ? (Orchestration_AttachmentWrapper) getCacheDataObject(serviceObj.csord__Order__c+'-'+serviceObj.RunTimeParent__c) : null;
                    Orchestration_AttachmentWrapper serviceattachment2 = (OrchestrationCacheManager.isStoredInCache(serviceObj.RunTimeParent__c)) ? (Orchestration_AttachmentWrapper) getCacheDataObject(serviceObj.RunTimeParent__c) : null;
                    System.debug('@@@@'+serviceattachment2);
                    String parentServiceAttachmentStr = (serviceattachment2 != null) ? serviceattachment2.attchBody.toString() : '';
                    
                    if(Test.isRunningTest()){
                        parentServiceAttachmentStr = getBody();
                    }
                    if(parentServiceAttachmentStr != ''){
                        Map<String, Object> parentResults = (Map<String, Object>) JSON.deserializeUntyped(parentServiceAttachmentStr);
                        List<Object> parentLstSpecifications = (List<Object>) parentResults.get('specifications');
                        if (parentLstSpecifications != null) {
                            for (Object parentSpecification : parentLstSpecifications) {
                                Map<String, Object> spec = (Map<String, Object>) parentSpecification;
                                // now get attributes for this specification.
                                string code = (String) spec.get('code');
                                string guid = (String) spec.get('guid');
                                tempParentCodeGuidMap.put(code, guid);//JJ: Orchestration new design
                            }
                        }
                    }
                } 
                
                for (Object specification : lstSpecifications) {
                    Map<String, String> additionalAttrs = new Map<String, String>();
                    System.debug('@@@'+specification);
                    Map<String, Object> specificationAttributesMap = (Map<String, Object>) specification;
                    System.debug('@@@'+specificationAttributesMap);
                    Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributesMap.get('attributes');
                    
                    for (String currAtt : attributesPropertyInSpecification.keySet()) {
                        if (currAtt != null && currAtt != '' && attributesPropertyInSpecification.get(currAtt) instanceof String) {
                            String currentAttributeValue = (String) attributesPropertyInSpecification.get(currAtt);
                            System.debug('currentAttributeValue ==> '+ currentAttributeValue );
                            if (currentAttributeValue != null && currentAttributeValue != '' && currentAttributeValue.contains('DMCAT_ProductSpecification')) {
                                
                                System.debug('tempOwnCodeGuidMap ==> '+ tempOwnCodeGuidMap +  tempOwnCodeGuidMap.containsKey(currentAttributeValue) );
                                System.debug('tempParentCodeGuidMap ==> '+ tempParentCodeGuidMap +  tempParentCodeGuidMap.containsKey(currentAttributeValue) );
                                System.debug('NetworkCodeGUIDRelationMap ==> '+ NetworkCodeGUIDRelationMap +  NetworkCodeGUIDRelationMap.containsKey(currentAttributeValue) );
                                
                                if(!tempOwnCodeGuidMap.isEmpty() && tempOwnCodeGuidMap.containsKey(currentAttributeValue)){
                                    additionalAttrs.put(currAtt, tempOwnCodeGuidMap.get(currentAttributeValue));
                                }
                                else if(!tempParentCodeGuidMap.isEmpty() && tempParentCodeGuidMap.containsKey(currentAttributeValue)){
                                    additionalAttrs.put(currAtt, tempParentCodeGuidMap.get(currentAttributeValue));
                                }
                                else if(!NetworkCodeGUIDRelationMap.isEmpty() && NetworkCodeGUIDRelationMap.containsKey(currentAttributeValue)){
                                    additionalAttrs.put(currAtt, NetworkCodeGUIDRelationMap.get(currentAttributeValue));
                                }
                            }
                        }
                    }
                    
                    System.debug('additionalAttrs ==> '+ additionalAttrs );
                    if (!additionalAttrs.isEmpty()) {
                        attachmentChanged = true;
                        if (specificationAttributesMap.get('additionalAttributes') != null) {
                            Map<String, Object> tempAdditionalAttMap = (Map<String, Object>) specificationAttributesMap.get('additionalAttributes');
                            tempAdditionalAttMap.putall(additionalAttrs);
                            specificationAttributesMap.put('additionalAttributes', tempAdditionalAttMap);
                        } else {
                            specificationAttributesMap.put('additionalAttributes', additionalAttrs);
                        }
                    }
                    
                    System.debug('specificationAttributesMap ==> '+ specificationAttributesMap );
                }
            }
            System.debug('attachmentChanged ==> '+ attachmentChanged );
            
            if (attachmentChanged) {
                serviceattachment.attchBody = Blob.valueOf(JSON.serialize(results));
                System.debug('serviceattachment.attchBody ==> '+ serviceattachment.attchBody );
                List<sObject> listOfsObjectToUpdate = new List<sObject>();
                listOfsObjectToUpdate.add(new Attachment(Id = serviceattachment.attchId, Body = Blob.valueOf(JSON.serialize(results))));
                listOfsObjectToUpdate.add(new OrchestrationCacheBackup__c(Key__c = key, Value__c = JSON.serialize(serviceattachment)));
                
                list<Orchestration_Technical__c> techObjs = new list<Orchestration_Technical__c> ();
                
                techObjs = [SELECT Id, Field_3__c, Field_5__c, Field_19__c, Field_14__c FROM Orchestration_Technical__c 
                                WHERE Field_5__c IN : updatedServiceIds ];
                
                try{
                    upsert listOfsObjectToUpdate;
                    
                    
                    for ( Orchestration_Technical__c a :techObjs){
                        a.Field_3__c = 'Completed';
                    }
                    
                    
                     
                }
                catch(Exception e){
                
                    System.debug('Error: '+e.getMessage());
                    
                    for ( Orchestration_Technical__c a :techObjs){
                        a.Field_3__c = 'Error';
                    }  
                }
                
                update techObjs; 
                
                System.debug('listOfsObjectToUpdate ==> '+ listOfsObjectToUpdate );
                OrchestrationCacheBackupHelper.uploadData(key, serviceattachment);
                
                //serviceToAttachmentMap.put(key, (Object) serviceattachment);
                //uploadData(service.csord__Order__c, 'serviceToAttachmentMap', serviceToAttachmentMap);
                //OrchestrationCacheManager.put('serviceToAttachmentMap', serviceToAttachmentMap);
            }else {
                list<Orchestration_Technical__c> techObjs = new list<Orchestration_Technical__c> ();
                
                techObjs = [SELECT Id, Field_3__c, Field_5__c, Field_19__c, Field_14__c FROM Orchestration_Technical__c 
                                WHERE Field_5__c IN : updatedServiceIds ];
                
                try{
                    
                    
                    for ( Orchestration_Technical__c a :techObjs){
                        a.Field_3__c = 'Completed';
                    }
                    
                    
                     
                }
                catch(Exception e){
                
                    System.debug('Error: '+e.getMessage());
                    
                    for ( Orchestration_Technical__c a :techObjs){
                        a.Field_3__c = 'Error';
                    }  
                }
                
                update techObjs; 
            }
        }
    }
    
    private static String getBody(){
        String body = '{ "serviceId": "DMCAT_ProductSpecification_000263","specifications" : [{'
            +'"code":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6976","guid":"648990ee-38b0-8e51-8048-e22a787a0240"}]}';
        return body;
    }
    
    public class OrderObserverManagerCacheHandlerWrapper{
        public Integer submitted = 0;
        public Integer processed = 0;
        public Set<Id> orderIds = new Set<Id>();
        
        public OrderObserverManagerCacheHandlerWrapper(Integer submitted, Integer processed, Set<Id> orderIds){
            this.submitted = submitted;
            this.processed = processed;
            if(orderIds != null && orderIds.size() > 0)
            this.orderIds.addAll(orderIds);
        }
    }
    
    //Logic to put no. of published platform events tracking before creating an orcehstration process from the batch class
    public static void putSubmittedPlatformEventsCountInCache(String cacheHandler, Integer value){
        OrderObserverManagerCacheHandlerWrapper cacheHandlerWrapper = new OrderObserverManagerCacheHandlerWrapper(0,0,null);
        if(OrchestrationCacheManager.isStoredInCache(cacheHandler)){
            cacheHandlerWrapper = (OrderObserverManagerCacheHandlerWrapper) OrchestrationCacheManager.get(cacheHandler);
        }
        cacheHandlerWrapper.submitted = value;
        OrchestrationCacheManager.put(cacheHandler, cacheHandlerWrapper);
    }
    
    //Logic to put no. of published platform events tracking before creating an orcehstration process from the batch class
    public static void putProcessedPlatformEventsCountInCache(String cacheHandler){
        Integer value = 1;
        OrderObserverManagerCacheHandlerWrapper cacheHandlerWrapper = new OrderObserverManagerCacheHandlerWrapper(0,0,null);
        if(OrchestrationCacheManager.isStoredInCache(cacheHandler)){
            cacheHandlerWrapper = (OrderObserverManagerCacheHandlerWrapper) OrchestrationCacheManager.get(cacheHandler);
            Integer oldValue = (cacheHandlerWrapper.processed != 0) ? cacheHandlerWrapper.processed : 0;
            value = value + oldValue;
        }
        cacheHandlerWrapper.processed = value;
        OrchestrationCacheManager.put(cacheHandler, cacheHandlerWrapper);
    }
    
    //Logic to put order ids in cache before processing an PF event from the batch class
    public static void putOrderIdsInCache(String cacheHandler, Set<Id> orderIds){
        OrderObserverManagerCacheHandlerWrapper cacheHandlerWrapper = new OrderObserverManagerCacheHandlerWrapper(0,0,null);
        if(OrchestrationCacheManager.isStoredInCache(cacheHandler)){
            cacheHandlerWrapper = (OrderObserverManagerCacheHandlerWrapper) OrchestrationCacheManager.get(cacheHandler);
        }
        cacheHandlerWrapper.orderIds.addAll(orderIds);
        OrchestrationCacheManager.put(cacheHandler, cacheHandlerWrapper);
    }
    
    Public Static void createPreReqProcessTemp(String[] orderIds){
        
        List<Orchestration_Technical__c> techObjs = new List<Orchestration_Technical__c> ();
        //Field_19__c = serviceObj.csord__Order__c, Field_3__c = 'Started', Field_5__c = serviceObj.Id
        //
        techObjs = [SELECT Id, Field_19__c,Field_3__c,Field_14__c,Field_5__c
                    FROM Orchestration_Technical__c
                    WHERE Field_14__c = 'PreREQ' AND 
                    Field_19__c IN:orderIds ORDER BY Field_19__c];
        
        Map<String,Map<String,String>> orderMainMap2 = New Map<String,Map<String,String>> ();
        Map<String,Set<String>> orderMainMap = New Map<String,Set<String>> ();
        
        for (Orchestration_Technical__c a :techObjs ){
            
            if ( orderMainMap.get(a.Field_19__c) <> NULL ) {
                Set<String> subDetails = orderMainMap.get(a.Field_19__c) ;
                subDetails.add(a.Field_3__c);
                orderMainMap.put(a.Field_19__c,subDetails );
            } else {
                Set<String> subDetails = New Set<String> () ;
                subDetails.add(a.Field_3__c);
                orderMainMap.put(a.Field_19__c,subDetails );
            }
            
            /*
            if ( orderMainMap.get(a.Field_19__c) <> NULL ) {
                Map<String,String> subDetails = orderMainMap.get(a.Field_19__c) ;
                subDetails.put(a.Field_5__c,a.Field_3__c);
                orderMainMap.put(a.Field_19__c,subDetails );
            } else {
                Map<String,String> subDetails = New Map<String,String> () ;
                subDetails.put(a.Field_5__c,a.Field_3__c);
                orderMainMap.put(a.Field_19__c,subDetails );
            }*/
            
        } // FOR LOOP ENDS 
        
        Set<String> completedOrderIds = New Set<String> ();
        for (String  orderId :orderMainMap.keyset() ){
            
            Set<String> currentOrderAllStatus = orderMainMap.get(orderId);
                
            if ( !currentOrderAllStatus.contains('Error') && !currentOrderAllStatus.contains('Started') ) 
                completedOrderIds.add(orderId);
        }
        
        ManageOrdPrereqisteOrchestrationHandler.createOrchestrationProcess(new List<String>(completedOrderIds) );

        
    }
}