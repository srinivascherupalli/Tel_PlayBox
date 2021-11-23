global with sharing class Orchestration_ValidateOrderFulfillmentV1 extends Orchestration_AbstractStepHandler {
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
    private List<sObject> sObjectFulfilmetToInsert = new List<sObject>();
    private List<sObject> sObjectFCRToInsert = new List<sObject>();
    private Map<String, List<sObject>> sObjectFulfilmetToInsertMap = new Map<String, List<sObject>>(); //Map< parent case unique identifier => List {child fulfilment item}>
    private Map<String, List<sObject>> sObjectFCRToInsertMap = new Map<String, List<sObject>>(); //Map< parent FLI unique identifier => List {child FCR}>
    private Id IncompleteStepId = null;
   //DPG-3624: Handle FLI for PS MS and TMDM offer
    public static final String ManagedService_MarketableOffer = 'DMCAT_Offer_000854';
     Boolean flagMS =false;
    
    //Private Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> calloutResults;
    Private Map<id,Map<String,String>> calloutResults;
    public override Boolean performCallouts(List<SObject> data)
    {
        Boolean calloutsPerformed = false;          
        List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>)data;        
        List<Id> processIds = new List<Id>();       
        Set<Id> orderId = new Set<Id>();    
        
        List<String> PCConfigId= new list<String>();
        
        for (CSPOFA__Orchestration_Step__c step : stepList)
        {  processIds.add(step.CSPOFA__Orchestration_Process__c);        
        }
        
        List<CSPOFA__Orchestration_Process__c> processes = [select id,Order__c, csordtelcoa__subscription__c,CSPOFA__process_type__c from CSPOFA__Orchestration_Process__c where id in :processIds ];
        for (CSPOFA__Orchestration_Process__c p : processes)
        {   orderId.add(p.Order__c);
        }
     
        
        // Added by Poonam
        List<csord__Subscription__c> SublistAll = (List<csord__Subscription__c>) Coms_PlatformCacheUtil.getAllSubscriptionFromCache(orderId);
        
         List<csord__Subscription__c> Sublist = new List<csord__Subscription__c>();
         Set<String> configSpecs = new Set<String> {'DMCAT_Offer_000936','DMCAT_ProductSpecification_000718'}; 
         for(csord__Subscription__c sub:SublistAll) {  
            if(configSpecs.contains(sub.ConfigSpecID__c)) {
                Sublist.add(sub);
            }
        }
        //list<csord__Subscription__c> Sublist= [select id,csordtelcoa__Product_Configuration__c,csord__Order__c from csord__Subscription__c where csord__Order__c in :orderIds and ConfigSpecID__c IN ('DMCAT_Offer_000936','DMCAT_ProductSpecification_000718')];
      
        for(csord__Subscription__c sub:Sublist){
            PCConfigId.add(sub.csordtelcoa__Product_Configuration__c);
        }
        
        Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> oeMap = cssmgnt.API_1.getOEData(PCConfigId);        
        this.calloutResults = parseResponse(oeMap);  
        system.debug('this.calloutResults'+this.calloutResults);
        calloutsPerformed = true;        
        return calloutsPerformed;    
    }
    
    
    public override List<sObject> process(List<sObject> data) {
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            system.debug('stopping execution as limit breached.....');
            return null;
        }
        Map<Id, List<csord__Subscription__c>> orderSubscriptionMap = new Map<Id, List<csord__Subscription__c>>();
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
               //Stoping the case creation process as part of EDGE-184113
           //   Id caseFulfillmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fulfillment').getRecordTypeId();
            Id fcrPortalAdminRecordTypeID = Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Portal Admin').getRecordTypeId();
            List<Id> professionalServicesPCList = new List<Id>();
            Map<Id, Id> pcToOrderIdMap = new Map<Id, Id>();
            Map<Id, Attachment> opUserAttMap = new Map<Id, Attachment>();
            Map<String, FCR_Settings__c> offerMapping = FCR_Settings__c.getAll();
            
            // Added by Poonam
            List<csord__Subscription__c> subscriptionList = (List<csord__Subscription__c>) Coms_PlatformCacheUtil.getAllSubscriptionFromCache(OrderIds);
            system.debug('subscriptionList:'+subscriptionList);
            Map<Id, csord__Subscription__c> subsMap = new Map<Id, csord__Subscription__c> (subscriptionList);
                /*new Map<Id, csord__Subscription__c>(
                [
                    SELECT
                    Id,
                    Name,
                    csord__Status__c,
                    Parent_Subscription__c,
                    csord__Order__c,
                    csord__Order__r.csord__Order_Number__c,
                    csord__Order__r.csord__Status2__c,
                    csord__Order__r.skipFulfillment__c,
                    cssdm__solution_association__c,
                    csord__Order__r.csordtelcoa__Opportunity__c,
                    csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,
                    csord__Account__c,
                    ConfigSpecID__c,
                    triggerBill_RTB__c,
                    toBeCancelled__c,
                    Trigger_RTS__c,
                    Billing_Account__c,
                    csordtelcoa__Product_Configuration__c,
                    csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId,
                    MarketableOffer__c,
                    MarketableOffer__r.Config__c,
                    MarketableOffer__r.Offer_ID__c,
                    MarketableOffer__r.Name,
                    MarketableOffer__r.Type__c,
                    csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                    (SELECT Id, Tenancy_Id__c, Purchase_Order_No__c, csord__Status__c FROM csord__Services__r)
                    FROM csord__Subscription__c
                    WHERE csord__Order__c IN :orderIds
                ]
            );*/
            
        
            List<Id> userIds = new List<Id>();
            system.debug('subsMap:'+subsMap);
            for (csord__Subscription__c subscription : subsMap.values()) {
                if (orderSubscriptionMap.get(subscription.csord__Order__c) == null) {
                    orderSubscriptionMap.put(subscription.csord__Order__c, new List<csord__Subscription__c>{ subscription });
                } else {
                    orderSubscriptionMap.get(subscription.csord__Order__c).add(subscription);
                }
                
                if (
                    subscription.MarketableOffer__r != null &&
                    subscription.csordtelcoa__Product_Configuration__r != null &&
                    String.isNotBlank(subscription.MarketableOffer__r.Type__c) &&
                    subscription.MarketableOffer__r.Type__c == 'Professional Service' &&
                    subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' &&
                    String.isNotBlank(subscription.MarketableOffer__r.Config__c)
                ) {
                    Map<String, Object> basketConfiguration = (Map<String, Object>) JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                    if (basketConfiguration.get('SOMOpenAir') != null && (Boolean) basketConfiguration.get('SOMOpenAir')) {
                        professionalServicesPCList.add(subscription.csordtelcoa__Product_Configuration__c);
                        pcToOrderIdMap.put(subscription.csordtelcoa__Product_Configuration__c, subscription.csord__Order__c);

                        if(this.calloutResults!= null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c)!= null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User')!=null && !(String.isBlank(this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User'))))
                      userIds.add(this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User'));
                    }
                }
            }
            List<id> oeSubscriptionIDList = new List<id>();
            Map<Id, List<id>> oePCSubscriptionIDMap = new Map<Id, List<id>>();
            for(Id professionalServicesPCID:professionalServicesPCList){

                if(this.calloutResults != null && this.calloutResults.get(professionalServicesPCID)!=null && this.calloutResults.get(professionalServicesPCID).get('Network')!=null && !(String.isBlank(this.calloutResults.get(professionalServicesPCID).get('Network'))))
                {
                oeSubscriptionIDList.addAll(this.calloutResults.get(professionalServicesPCID).get('Network').split(','));
                oePCSubscriptionIDMap.put(professionalServicesPCID,this.calloutResults.get(professionalServicesPCID).get('Network').split(','));
                }
            }
            Map<Id, csord__Subscription__c> oeSubscriptionMap = new Map<Id, csord__Subscription__c>([select id,Parent_Subscription__c from csord__Subscription__c where ID IN :oeSubscriptionIDList]);
            /*Map<Id, List<String>> orderIdToOfferList = new Map<Id, List<String>>();
            Map<Id, Map<Id, Id>> orderIdToOperationUser = new Map<Id, Map<Id, Id>>();
            for (attachment att : [SELECT Id, name, body, ParentId FROM Attachment WHERE ParentId IN :professionalServicesPCList AND Name = 'Operations User_schema.json']) {
                String strbody = att.body.tostring();
                Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(strbody);
                List<Object> reqAttrList = (List<Object>) request.get('configurations');
                for (Object simpleAttr : reqAttrList) {
                    Map<String, Object> smpObj = (Map<String, Object>) simpleAttr;
                    if (smpObj.get('OfferName') != null) {
                        system.debug(smpObj.get('OfferName'));
                        if (orderIdToOfferList.containskey(pcToOrderIdMap.get(att.ParentId))) {
                            orderIdToOfferList.get(pcToOrderIdMap.get(att.ParentId)).add((String) smpObj.get('OfferName'));
                        } else {
                            orderIdToOfferList.put(pcToOrderIdMap.get(att.ParentId), new List<String>{ (String) smpObj.get('OfferName') });
                        }
                    }
                    if (smpObj.get('Operational User') != null) {
                        if (!orderIdToOperationUser.containskey(pcToOrderIdMap.get(att.ParentId))) {
                            orderIdToOperationUser.put(pcToOrderIdMap.get(att.ParentId), new Map<Id, Id>{ att.ParentId => (Id) smpObj.get('Operational User') });
                        } else {
                            orderIdToOperationUser.get(pcToOrderIdMap.get(att.ParentId)).put(att.ParentId, (Id) smpObj.get('Operational User'));
                        }
                    }
                }
            }*/
            
            //List<Id> userIds = new List<Id>();
            /*for (Map<Id, Id> keyMap : orderIdToOperationUser.values()) {
                userIds.addAll(keyMap.values());
            }*/
            Map<Id, user> userMap = new Map<Id, user>([SELECT id, contactid FROM user WHERE id IN :userIds]);
             Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    //Populate all the record Ids that are processed already
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    Map<String, List<csord__Subscription__c>> prodConfigToListOfSubs = new Map<String, List<csord__Subscription__c>>();
                    List<csord__Subscription__c> managedServicesSubsList = new List<csord__Subscription__c>();
                    List<csord__Subscription__c> professionalServicesSubsList = new List<csord__Subscription__c>();
                    List<csord__Subscription__c> managedServRTSList = new List<csord__Subscription__c>();
                    Map<String, List<csord__Subscription__c>> billAcc = new Map<String, List<csord__Subscription__c>>();
                    Set<String> ordId= new Set<String>();
                    
                    Boolean triggerRtbFlag = false;
                    Integer skipFulfilmentCounter = 0;
                    
                    /****loop to iterate over subscription and see if this order needs any processing. if not skip for this order and mark teh step as complete after the loop ends*******/
                    for (csord__Subscription__c subscription : orderSubscriptionMap.get(step.cspofa__orchestration_process__r.order__c)) {
                        if (Orchestration_LimitsUtility.areLimitsViolated()) {break;
                        }
                        //Logic check one for skipFulfillment__c on order record
                        if (!step.cspofa__orchestration_process__r.order__r.skipFulfillment__c) {
                            if (subscription.MarketableOffer__r != null && String.isNotBlank(subscription.MarketableOffer__r.Config__c)) {
                                Map<String, Object> basketConfiguration = (Map<String, Object>) JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                                if (basketConfiguration.get('SOMOpenAir') != null && (Boolean) basketConfiguration.get('SOMOpenAir')) {
                                    skipFulfilmentCounter++;
                                }
                            }
                        }
                        //logic check 2 for subs and service data collection for managed services
                        //DPG-2857
                        if (subscription.MarketableOffer__r != null && subscription.MarketableOffer__r.Offer_ID__c== 'DMCAT_Offer_001251') {
                            managedServicesSubsList.add(subscription);
                            
                             if (subscription.Billing_Account__c != null) {
                            if (!billAcc.containsKey(subscription.Billing_Account__c)) {
                                billAcc.put(subscription.Billing_Account__c, new List<csord__Subscription__c>{ subscription });
                            } else {
                                billAcc.get(subscription.Billing_Account__c).add(subscription);
                            }
                        }
                        }
                         system.debug('billAcc++' +billAcc);
                         system.debug('managedServicesSubsList++' +managedServicesSubsList);
                         
                         //RTS for Managed Service and Adaptive Care; Ila/Monali
                         if(subscription.MarketableOffer__r != NULL && String.isNotBlank(subscription.MarketableOffer__r.Config__c)){
                             Map<String, Object> basketConfiguration = (Map<String, Object>)JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                        if( basketConfiguration.get('SOMOpenAir') != NULL && (Boolean)basketConfiguration.get('SOMOpenAir'))
                        {
                            managedServRTSList.add(subscription);
                        }
                         }
                         
                        if (
                            subscription.MarketableOffer__r != null &&
                            subscription.csordtelcoa__Product_Configuration__r != null &&
                            String.isNotBlank(subscription.MarketableOffer__r.Type__c) &&
                            subscription.MarketableOffer__r.Type__c == 'Professional Service' &&
                            subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' &&
                            String.isNotBlank(subscription.MarketableOffer__r.Config__c)
                        ) {
                            Map<String, Object> basketConfiguration = (Map<String, Object>) JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                            if (basketConfiguration.get('SOMOpenAir') != null && (Boolean) basketConfiguration.get('SOMOpenAir')) {
                                professionalServicesSubsList.add(subscription);
                                ordId.add(subscription.csord__Order__c);
                            }
                        }
                        if (subscription.ConfigSpecID__c != null) {
                            if (!prodConfigToListOfSubs.containsKey(subscription.ConfigSpecID__c)) {
                                prodConfigToListOfSubs.put(subscription.ConfigSpecID__c, new List<csord__Subscription__c>{ subscription });
                            } else {
                                prodConfigToListOfSubs.get(subscription.ConfigSpecID__c).add(subscription);
                            }
                        }
                    }
                    
                    if (skipFulfilmentCounter == 0 && managedServicesSubsList.isEmpty() && professionalServicesSubsList.isEmpty()) {
                        stepResults.put(step.Id, new stepResult('Success: Not a manual fulfilment Order', OrchestratorConstants.OrchestratorStep.Complete));
                        continue;
                    }
                    //add logic 1 data to DML variabls
                    if (skipFulfilmentCounter > 0 && orderSubscriptionMap.get(step.cspofa__orchestration_process__r.order__c).size() == skipFulfilmentCounter) {
                        if (!hasDMLRowsLimitExceeded()) {
                            step.cspofa__orchestration_process__r.order__r.skipFulfillment__c = true;
                            sObjectsToUpdate.put(step.cspofa__orchestration_process__r.order__c, step.cspofa__orchestration_process__r.order__r);
                            //stepRelationship.put(step.cspofa__orchestration_process__r.order__c, step.id);
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new List<String>{ step.cspofa__orchestration_process__r.order__c });
                            } else {
                                stepRelationshipMap.get(step.Id).add(step.cspofa__orchestration_process__r.order__c);
                            }
                        } else {
                            IncompleteStepId = step.Id;
                            break;
                        }
                    }
                    /**************************************  
                    Description: Update Trigger RTB for SolutionSubscription for Adaptive Care 
                    Stor: DPG-1914 || DPG-2857
                    Author: Ila
                    /******************************************/
                    if (!managedServicesSubsList.isEmpty()) {
                        for (csord__Subscription__c subscription : managedServicesSubsList) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                break;
                            }
                            
                            if (subscription.csord__Status__c != 'Provisioned') {
                                subscription.csord__Status__c = 'Provisioned';
                                if (subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent') {
                                   system.debug('inside iff ' +subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c);
                                    subscription.triggerBill_RTB__c = true;
                                }
                                
                                if (!hasDMLRowsLimitExceeded()) {
                                    sObjectsToUpdate.put(subscription.Id, subscription);
                                    if (!stepRelationshipMap.containsKey(step.Id)) {
                                        stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                    } else {
                                        stepRelationshipMap.get(step.Id).add(subscription.Id);
                                    }
                                } else {
                                    IncompleteStepId = step.Id;
                                    break;
                                }
                            }
                            
                            for (csord__Service__c svc : subscription.csord__Services__r) {
                                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                    break;
                                }
                                if (svc.csord__Status__c != 'Connected') {
                                    svc.csord__Status__c = 'Connected';
                                    if (!hasDMLRowsLimitExceeded()) {
                                        sObjectsToUpdate.put(svc.Id, svc);
                                        if (!stepRelationshipMap.containsKey(step.Id)) {
                                            stepRelationshipMap.put(step.Id, new List<String>{ svc.Id });
                                        } else {
                                            stepRelationshipMap.get(step.Id).add(svc.Id);
                                        }
                                    } else {
                                        IncompleteStepId = step.Id;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                     /**************************************
                    Description: Update Trigger RTB for  Individual Subscription for Adaptive Care 
                    Stor: DPG-1914 ||DPG-2857
                    Author: Ila
                    /******************************************/
                    if (!billAcc.isEmpty()) {
                       
                       for(Id billAccId: billAcc.keyset()){
                           for ( csord__Subscription__c subs : billAcc.get(billAccId) )
                            {
                                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                break;
                            }
                                triggerRtbFlag = ( subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent' && subs.triggerBill_RTB__c==true) ? true : false;
                            }
                            system.debug('triggerRtbFlag.triggerBill_RTB__c' +triggerRtbFlag);

                              for(csord__Subscription__c subscription : billAcc.get(billAccId)){
                                     if(subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' && triggerRtbFlag==true){
                                    system.debug('inside ifff');
                                    subscription.triggerBill_RTB__c=true;
                            }
                            
                                if (!hasDMLRowsLimitExceeded()) {
                                    sObjectsToUpdate.put(subscription.Id, subscription);
                                    if (!stepRelationshipMap.containsKey(step.Id)) {
                                        stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                    } else {
                                        stepRelationshipMap.get(step.Id).add(subscription.Id);
                                    }
                                } else {
                                    IncompleteStepId = step.Id;
                                    break;
                                }
                              }
                       }
                        }
                    
                        /************************************** 
                        Description: Update RTS for individual subscription for Adaptive care and Managed Service
                        Story: DPG-1914 || DPG-2857
                        Author: Ila
                        /******************************************/
                    if (!managedServRTSList.isEmpty()) {

                        for (csord__Subscription__c subscription : managedServRTSList) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                break;
                            }
                               
            //Update Trigger RTS for Individual Subscription for Adaptive Care and Managed Service
                if(subscription.toBeCancelled__c=='true' && subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent')  
                {
                    /* Get all services using subscription id - You will get only one here
                    For that service get service spec from attachment parse all billing specs update status attribute
                    */ 
                    Map<Id,csord__Service__c> servList = new Map<Id,csord__Service__c>([SELECT Id,Name,csord__Order__c,csord__Service__c,toBeCancelled__c,csord__Subscription__r.eventId__c,Action_Type__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Service__c WHERE csord__Subscription__r.id =: subscription.Id]);
                    Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
                    String updatedServiceattachmentstr;
                    Map<Id,Attachment> servspecattchmentMap = new Map<Id,Attachment>();
                    List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
                    
                    for(Attachment att: [Select id,body,parentId from Attachment where parentId in :servList.keyset()]){
                    serviceAttachmentMap.put(att.parentId,att.body.toString());
                    servspecattchmentMap.put(att.parentId,att);
                    }
                    
                    for(csord__Service__c serv : servList.values()){
                    for(String eachService: serviceAttachmentMap.keySet()){
                    srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(serv.Id)),'BILLING');
                    }
                        
                    updatedServiceattachmentstr =serviceAttachmentMap.get(serv.Id);
                    for(CS_SpecificationDTO.ServiceSpecification spec :srvspecList){
                        if(servList.get(spec.serviceId).toBeCancelled__c == 'true'){
                        updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(updatedServiceattachmentstr, spec.guid, 'status', 'Disconnected');}
                        
                        if(updatedServiceattachmentstr!=null){
                                                    Attachment toUpdateAtt =servspecattchmentMap.get(spec.serviceId);
                                                    toUpdateAtt.body = Blob.valueof(updatedServiceattachmentstr);
                                                    updatedAttSet.put(toUpdateAtt.id,toUpdateAtt);
                                                }
                    }
                    }
                    
                    
                    system.debug('inside if of updateRTSAdaptive');
                    subscription.Trigger_RTS__c=true;
                }
              //sObjectUOW.registerDirty(subscription);
                                if (!hasDMLRowsLimitExceeded()) {
                                    sObjectsToUpdate.put(subscription.Id, subscription);
                                    if (!stepRelationshipMap.containsKey(step.Id)) {
                                        stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                    } else {
                                        stepRelationshipMap.get(step.Id).add(subscription.Id);
                                    }
                                } else {
                                    IncompleteStepId = step.Id;
                                    break;
                                }  
          
        }
           
                        
                            }
                        
                        
                    //Logic 3 data to DML variables
                    if (!professionalServicesSubsList.isEmpty()) {
                        for(csord__Subscription__c subsMS: [Select Id,MarketableOffer__r.Offer_ID__c from csord__Subscription__c where csord__Order__c=:ordId] ){
                            //DPG-3624: Handle FLI for PS MS and TMDM offer
                            if(subsMS.MarketableOffer__r.Offer_ID__c == ManagedService_MarketableOffer){
                                flagMS=true;
                            }
                        }
                        //insert case if not already available in already processedrecords
                        if (
                            processedRecordIds == null ||
                            (processedRecordIds.mapInsertedRecords != null &&
                             !processedRecordIds.mapInsertedRecords.containsKey(step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c))
                        ) {
                            if (!hasDMLRowsLimitExceeded()) {
                                   //Stoping the case creation process as part of EDGE-184113
                                //system.debug('creating case'+orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values()[0]);
                           //    Case fulfillmentRecord = new Case(RecordTypeId = caseFulfillmentRecordTypeId);
                            //  fulfillmentRecord.Subject = step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c;
                          //    fulfillmentRecord.OpportunityId__c = step.cspofa__orchestration_process__r.Order__r.csordtelcoa__Opportunity__c;
                          //    fulfillmentRecord.AccountId = step.cspofa__orchestration_process__r.Order__r.csord__Account__c;
                              system.debug('creating case2' + step.cspofa__orchestration_process__r.Order__r.csordtelcoa__Opportunity__r.OwnerId);
                                
                                /*system.debug('creating case3' + orderIdToOfferList.get(step.cspofa__orchestration_process__r.order__c));
                                if (
                                    orderIdToOfferList.get(step.cspofa__orchestration_process__r.order__c) != null &&
                                    orderIdToOfferList.get(step.cspofa__orchestration_process__r.order__c).contains('Telstra Collaboration Professional Services') &&
                                    orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c) != null &&
                                    orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values().size() != 0
                                ) {
                                    fulfillmentRecord.OwnerId = orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values()[0];
                                } else if (
                                    orderIdToOfferList.get(step.cspofa__orchestration_process__r.order__c) != null &&
                                    orderIdToOfferList.get(step.cspofa__orchestration_process__r.order__c).contains('Telstra Collaboration Professional Services') &&
                                    orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c) != null &&
                                    orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values().size() != 0
                                ) {
                                    fulfillmentRecord.OwnerId = orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values()[0];
                                } else {
                                    fulfillmentRecord.OwnerId = step.cspofa__orchestration_process__r.Order__r.csordtelcoa__Opportunity__r.OwnerId; //owner of case is opportunity owner
                                }*/
                                //Stoping the case creation process as part of EDGE-184113
                             //    fulfillmentRecord.OwnerId = step.cspofa__orchestration_process__r.Order__r.csordtelcoa__Opportunity__r.OwnerId; //owner of case is opportunity owner
                                
                            //    sObjectsToInsert.add(fulfillmentRecord);
                                //stepToCaseIdentifier.put(step.Id, step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c);
                           /*     if (!stepRelationshipMap.containsKey(step.Id)) {
                                    stepRelationshipMap.put(step.Id, new List<String>{ step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c });
                                } else {
                                    stepRelationshipMap.get(step.Id).add(step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c);
                                }
                                */
                            } else {
                                IncompleteStepId = step.Id;
                                break;
                            }
                        }
                        //insert fulfilment records
                        for (csord__Subscription__c subscription : professionalServicesSubsList) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                break;
                            }
                            List<Id> newListid = new List<Id>();
                            set<Id> newSetid = new Set<Id>();
                            //List<Id> newListid = new List<Id>();
                            if (offerMapping.containsKey(subscription.ConfigSpecID__c)) {
                                List<csord__Subscription__c> ngVoiceSubscriptionId = prodConfigToListOfSubs.get(
                                    offerMapping.get(subscription.ConfigSpecID__c).Product_Configuration_code__c
                                );
                                if (ngVoiceSubscriptionId != null) {
                                    for (csord__Subscription__c subs : ngVoiceSubscriptionId) {
                                        newSetid.add(subs.Parent_Subscription__c != null ? subs.Parent_Subscription__c : subs.id);
                                        newListid.add(subs.id);
                                    }
                                }
                            }
                            if(oePCSubscriptionIDMap.containsKey(subscription.csordtelcoa__Product_Configuration__c))
                            {    List<id> subList= oePCSubscriptionIDMap.get(subscription.csordtelcoa__Product_Configuration__c);
                                for (Id subId : subList) {
                                    csord__Subscription__c subs=oeSubscriptionMap.get(subId);
                                        newSetid.add(subs.Parent_Subscription__c != null ? subs.Parent_Subscription__c : subs.id);
                                        newListid.add(subs.id);
                                    }
                            }
                            system.debug('subscription'+subscription);
                            system.debug('processedRecordIds'+processedRecordIds);
                            //system.debug('processedRecordIds'+processedRecordIds.mapInsertedRecords);
                            if (
                                processedRecordIds == null || (processedRecordIds.mapInsertedRecords != null && !processedRecordIds.mapInsertedRecords.containsKey(subscription.Id)) && !flagMS
                            ) {
                                if (!hasDMLRowsLimitExceeded()) {
                                    FulfillmentLineItem__c fulfillmentLineItem = new FulfillmentLineItem__c();
                                    fulfillmentLineItem.Name = subscription.Name;
                                    fulfillmentLineItem.Account__c = subscription.csord__Account__c;
                                   /* if (
                                        orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c) != null && orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values().size() != 0
                                    ) {
                                        fulfillmentLineItem.OwnerId = orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c)
                                            .get(subscription.csordtelcoa__Product_Configuration__c) != null
                                            ? orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).get(subscription.csordtelcoa__Product_Configuration__c)
                                            : subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                                    } else {
                                        fulfillmentLineItem.OwnerId = subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                                    }*/

                                    if(this.calloutResults!= null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c)!=null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User')!= null && !(String.isBlank(this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User')))){
                                     fulfillmentLineItem.OwnerId= this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User');
                                    }else
                                        fulfillmentLineItem.OwnerId = subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                                    fulfillmentLineItem.Offer_Name__c = subscription.MarketableOffer__r.Name; // Offer Name for fulfillment Line item
                                    fulfillmentLineItem.subscription__c = subscription.Id; //link to the subscription
                                    fulfillmentLineItem.Assigned_Date__c = System.today();
                                    if (
                                        processedRecordIds != null &&
                                        processedRecordIds.mapInsertedRecords != null &&
                                        processedRecordIds.mapInsertedRecords.containsKey(step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c)
                                    ) {
                                        fulfillmentLineItem.case__c = processedRecordIds.mapInsertedRecords.get(
                                            step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c
                                        );
                                    }
                                    String subList = String.join(newListid, ',');
                                    fulfillmentLineItem.FCR_Subscriptions__c = subList;
                                    sObjectFulfilmetToInsert.add(fulfillmentLineItem);
                                    //sObjectFulfilmetToInsertMap.put(subscription.Id,fulfillmentLineItem);
                                    if (!sObjectFulfilmetToInsertMap.containsKey(step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c)) {
                                        sObjectFulfilmetToInsertMap.put(
                                            step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c,
                                            new List<sObject>{ fulfillmentLineItem }
                                        );
                                    } else {
                                        sObjectFulfilmetToInsertMap.get(step.cspofa__orchestration_process__r.Order__r.csord__Order_Number__c).add(fulfillmentLineItem);
                                    }
                                    if (!stepRelationshipMap.containsKey(step.Id)) {
                                        stepRelationshipMap.put(step.Id, new List<String>{ subscription.Id });
                                    } else {
                                        stepRelationshipMap.get(step.Id).add(subscription.Id);
                                    }
                                    
                                    //stepToCaseIdentifier.put(step.Id, subscription.Id);
                                } else {
                                    IncompleteStepId = step.Id;
                                    break;
                                }
                            }
                            system.debug('sObjectFulfilmetToInsertMap 565'+sObjectFulfilmetToInsertMap);
                            
                            for (Id ngvsubscription : newSetid) {
                                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                    break;
                                }
                                String tempUniqeKey = subscription.Id + ':' + ngvsubscription;
                                if (
                                    processedRecordIds == null ||
                                    (processedRecordIds.mapInsertedRecords != null && !processedRecordIds.mapInsertedRecords.containsKey(tempUniqeKey))
                                ) {
                                    if (!hasDMLRowsLimitExceeded()) {
                                        String Ownerid;
                                if(this.calloutResults != null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c)!=null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User')!= null && !(String.isBlank(this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User')))){
                                        
                                            Ownerid= this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User');
                                        }else
                                            Ownerid= subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                                    
                                     /*   if (
                                            orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c) != null && orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values().size() != 0
                                        ) {
                                            Ownerid = orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c)
                                                .get(subscription.csordtelcoa__Product_Configuration__c) != null
                                                ? orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).get(subscription.csordtelcoa__Product_Configuration__c)
                                                : subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                                        } else {
                                            OwnerId = subscription.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId;
                                        }*/
                                        
                                        String ContactId;

                                        if(this.calloutResults!=null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c)!=null && this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User')!= null && !(String.isBlank(this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User'))) ){
                                            ContactId= (userMap.get(this.calloutResults.get(subscription.csordtelcoa__Product_Configuration__c).get('Operational User'))).contactId;
                                        }else
                                            ContactId= subscription.csord__Order__r.csordtelcoa__Opportunity__r.Owner.contactId;
                                    
                                        /*if (
                                            orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c) != null && orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).values().size() != 0 && orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).get(subscription.csordtelcoa__Product_Configuration__c) != null && userMap.get(orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c).get(subscription.csordtelcoa__Product_Configuration__c)) != null
                                        ) {
                                            ContactId = userMap.get(
                                                orderIdToOperationUser.get(step.cspofa__orchestration_process__r.order__c)
                                                .get(subscription.csordtelcoa__Product_Configuration__c)
                                            )
                                                .contactid;
                                        } else {
                                            ContactId = subscription.csord__Order__r.csordtelcoa__Opportunity__r.Owner.contactId;
                                        }*/
                                        if(Test.isRunningTest()) contactId = System.Label.VALIDATEORDERFULFILMENT_INVALIDCONTACTID;
                                        if (contactId != null) {
                                            Functional_Contact_Role__c fcr = new Functional_Contact_Role__c(
                                                Role__c = offerMapping.get(subscription.ConfigSpecID__c).Role_Name__c,
                                                Role_Type__c = 'Subscription',
                                                RecordTypeId = fcrPortalAdminRecordTypeID,
                                                SubscriptionID__c = ngvsubscription,
                                                Partner_User__c = Ownerid,
                                                ContactID__c = ContactId,
                                                parentFLISubsId__c = subscription.id
                                            );
                                            
                                            if (
                                                processedRecordIds != null &&
                                                processedRecordIds.mapInsertedRecords != null &&
                                                processedRecordIds.mapInsertedRecords.containsKey(subscription.Id)
                                            ) {
                                                fcr.Fulfillment_Task__c = processedRecordIds.mapInsertedRecords.get(subscription.Id);
                                            }
                                            sObjectFCRToInsert.add(fcr);
                                            //sObjectFCRToInsertMap.put(ngvsubscription,fcr);
                                            if (!sObjectFCRToInsertMap.containsKey(subscription.Id)) {
                                                sObjectFCRToInsertMap.put(subscription.Id, new List<sObject>{ fcr });
                                            } else {
                                                sObjectFCRToInsertMap.get(subscription.Id).add(fcr);
                                            }
                                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                                stepRelationshipMap.put(step.Id, new List<String>{ tempUniqeKey });
                                            } else {
                                                stepRelationshipMap.get(step.Id).add(tempUniqeKey);
                                            }
                                        } else {
                                            stepResults.put(
                                                step.Id,
                                                new stepResult('Contact Id is missing for this operational user', OrchestratorConstants.OrchestratorStep.Error)
                                            );
                                        }
                                    } else {
                                        IncompleteStepId = step.Id;
                                        break;
                                    }
                                }
                                //sObjectUOW.registerNew(fcr,Functional_Contact_Role__c.Fulfillment_Task__c,fulfillmentLineItem);
                            }
                        }
                    }
                    system.debug('just before the statement' + IncompleteStepId + stepRelationshipMap.keyset() + stepRelationshipMap.values());
                    if (!stepRelationshipMap.containsKey(step.Id)) {
                        system.debug('just after the statement');
                        stepResults.put(
                            step.Id,
                            new stepResult('Success - No update required as no records found to update or insert', OrchestratorConstants.OrchestratorStep.Complete)
                        );
                    }
                } catch (Exception ex) {
                    system.debug('any error inside step loop===????' + ex.getMessage());
                    stepResults.put(
                        step.Id,
                        new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                    );
                }
            }
             if(!updatedAttSet.isEmpty()){
             update updatedAttSet.values();}
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(
                    step.Id,
                    new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                );
            }
        }
        
        
        if (!sObjectsToUpdate.isEmpty() || !sObjectsToInsert.isEmpty() || !sObjectFulfilmetToInsert.isEmpty() || !sObjectFCRToInsert.isEmpty()) {
            processDMLOperations();
        }
        
        return processStepResults(stepList, stepResults);
    }
    
    
    
    
    //method override getsteplist
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
            CSPOFA__Orchestration_Process__r.cspofa__account__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
            CSPOFA__Orchestration_Process__r.Order__c,
            CSPOFA__Orchestration_Process__r.Order__r.skipFulfillment__c,
            cspofa__orchestration_process__r.Order__r.csord__Order_Number__c,
            cspofa__orchestration_process__r.Order__r.csordtelcoa__Opportunity__r.OwnerId,
            cspofa__orchestration_process__r.Order__r.csord__Account__c,
            cspofa__orchestration_process__r.Order__r.csordtelcoa__Opportunity__c
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
        //Returning the step list
        return stepList;
    }
    
    public void processDMLOperations() {
        //List<sObject> sObjectFulfilmetToInsert = new List<sObject>();
        //List<sObject> sObjectFCRToInsert = new List<sObject>();
        sObjectFulfilmetToInsert.clear();
        sObjectFCRToInsert.clear();
        List<String> caseUniqueIdList = new List<String>();
        List<String> FLIUniqueIdList = new List<String>();
        Map<Id, SObject> mapProcessedCase = new Map<Id, SObject>();
        Map<Id, SObject> mapProcessedFLIs = new Map<Id, SObject>();
        Map<Id, SObject> mapProcessedFCRs = new Map<Id, SObject>();
        /***Updating Order Records Start****/
       
        /*Database.SaveResult[] result = new List<Database.SaveResult>();
        if (!sObjectsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
            result.addAll(updateResult);
        }*/
        
        Orchestration_PlatformCacheUtility.updatePlatformCache(sObjectsToUpdate.values());
        //Stoping the case creation process as part of EDGE-184113
        /***Updating Order Records Ends***/
        /***Inserting Case Records Start****/
      /*  if (!sObjectsToInsert.isEmpty()) {
            Database.SaveResult[] updateResult = Database.insert(sObjectsToInsert, false);
            result.addAll(updateResult);
        }*/
        /***Inserting Case Records Ends****/
        //Stoping the case creation process as part of EDGE-184113
        /***Inserting FLI Records Start****/
        /*  system.debug('sObjectsToInsert 758'+sObjectsToInsert);
       for (sObject sObj : sObjectsToInsert) {
            string str = String.valueOf(sObj.get('Subject'));
            caseUniqueIdList.add(str);
          
           system.debug('sObjectFulfilmetToInsertMap 758'+sObjectFulfilmetToInsertMap+'str'+str);
            if (sObjectFulfilmetToInsertMap.containsKey(str)) {
                //system.debug('mapChildRecords.get(str)=='+mapChildRecords.get(str).get('parentId'));
                for (sObject sObjChild : sObjectFulfilmetToInsertMap.get(str)) {
                //    sObjChild.put('case__c', sObj.Id);
                    sObjectFulfilmetToInsert.add(sObjChild);
                }
            }
        }
    */
         system.debug('sObjectFulfilmetToInsert758'+sObjectFulfilmetToInsert);
        for (String key : sObjectFulfilmetToInsertMap.keyset()) {
           // if (!caseUniqueIdList.contains(key)) {
                for (sObject sObjChild : sObjectFulfilmetToInsertMap.get(key)) {
                    sObjectFulfilmetToInsert.add(sObjChild);
           //     }
            }
        }
    
        
      
        if (!sObjectFulfilmetToInsert.isEmpty()) {
            Orchestration_PlatformCacheUtility.updatePlatformCache(sObjectFulfilmetToInsert);
            //Database.SaveResult[] updateResult = Database.insert(sObjectFulfilmetToInsert, false);
            //result.addAll(updateResult);
        }
        /***Inserting FLI Records Ends****/
        /***Inserting FCR Records Start****/
        for (sObject sObj : sObjectFulfilmetToInsert) {
            string str = String.valueOf(sObj.get('subscription__c'));
            FLIUniqueIdList.add(str);
            if (sObjectFCRToInsertMap.containsKey(str)) {
                for (sObject sObjChild : sObjectFCRToInsertMap.get(str)) {
                    sObjChild.put('Fulfillment_Task__c', sObj.Id);
                    sObjectFCRToInsert.add(sObjChild);
                }
            }
        }
      
        
        for (String key : sObjectFCRToInsertMap.keyset()) {
            if (!FLIUniqueIdList.contains(key)) {
                for (sObject sObjChild : sObjectFCRToInsertMap.get(key)) {
                    sObjectFCRToInsert.add(sObjChild);
                }
            }
        }
        if (!sObjectFCRToInsert.isEmpty()) {
            //Database.SaveResult[] updateResult = Database.insert(sObjectFCRToInsert, false);
            //result.addAll(updateResult);
            Orchestration_PlatformCacheUtility.updatePlatformCache(sObjectFCRToInsert);
        }
           system.debug('sObjectFCRToInsert 893'+sObjectFCRToInsert);
        /***Inserting FCR Records Start****/
        mapProcessedCase.putAll(sObjectsToInsert);
        mapProcessedFLIs.putAll(sObjectFulfilmetToInsert);
        mapProcessedFCRs.putAll(sObjectFCRToInsert);
        /*List<Id> successIds = new List<Id>();
        for (Database.SaveResult rslt : result) {
            if (rslt.isSuccess()) {
                successIds.add(rslt.getId());
            }
        }
        Map<String, String> successIdentifiersMap = new Map<String, String>();
        for (String key : mapProcessedCase.keyset()) {
            if (successIds.contains(key)) {
                //successIdentifiers.add(mapProcessedCase.get(key).Subject);
                successIdentifiersMap.put((String) mapProcessedCase.get(key).get('Subject'), key);
            }
        }
        for (String key : mapProcessedFLIs.keyset()) {
            if (successIds.contains(key)) {
                //successIdentifiers.add(mapProcessedFLIs.get(key).Subscription__c);
                successIdentifiersMap.put((String) mapProcessedFLIs.get(key).get('Subscription__c'), key);
            }
        }
        for (String key : mapProcessedFCRs.keyset()) {
            if (successIds.contains(key)) {
                String fcrIdentifier = mapProcessedFCRs.get(key).get('parentFLISubsId__c') + ':' + mapProcessedFCRs.get(key).get('SubscriptionID__c');
                successIdentifiersMap.put(fcrIdentifier, key);
            }
        }*/
        for (Id stepId : stepRelationshipMap.keySet()) {
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            perStepSuccessIds.mapInsertedRecords = new Map<String, String>();
            Boolean isFailed = false;
            for (String recId : stepRelationshipMap.get(stepId)) {
             /*system.debug('successIdentifiersMap 837'+successIdentifiersMap);
              system.debug('successIds 837'+successIds+'recId'+recId);
                if (!successIdentifiersMap.containsKey(recId) && !successIds.contains(recId)) {
                    isFailed = true;
                } else if (successIdentifiersMap.containsKey(recId)) {
                    perStepSuccessIds.mapInsertedRecords.put(recId, successIdentifiersMap.get(recId));
                }*/
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
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
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
    public override boolean hasDMLRowsLimitExceeded() {
        boolean dmlRowsExceeded = true;
        if (
            (sObjectsToInsert.size() + sObjectsToUpdate.size() + sObjectFulfilmetToInsert.size() + sObjectFCRToInsert.size() <=
             (Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c) -
              Limits.getDMLRows() -
              1))
        ) {
            return false;
        }
        return dmlRowsExceeded;
    }
    public Map<id,Map<String,String>> parseResponse(Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> oeMap){
        Map<id,Map<String,String>> pcOEMap= new Map<id,Map<String,String>>();
        for(Id configId : oeMap.keySet()){
            List<cssmgnt.ProductProcessingUtility.Configuration > configlst = new List<cssmgnt.ProductProcessingUtility.Configuration>();
            Map<String,List<cssmgnt.ProductProcessingUtility.Attribute>> attrmap = new Map<String,List<cssmgnt.ProductProcessingUtility.Attribute>>();
            Map<String,String> oeconfigNamemap = new Map<String,String>();
            Map<String,String> oeAttributeMap = new Map<String,String>();
            
            List<cssmgnt.ProductProcessingUtility.Component> objlst = oeMap.get(configId);
            
            for(cssmgnt.ProductProcessingUtility.Component comp : objlst){
                configlst.addAll(comp.configurations);
            }
            //Process each OE config 
            for(cssmgnt.ProductProcessingUtility.Configuration config : configlst){
                attrmap.put(config.guid,config.attributes);
                oeconfigNamemap.put(config.guid,config.ConfigurationName);        
            }
            //Process attributes of each OE config
            for(String oeguid : attrmap.keySet()){
                system.debug('oeconfigGUID'+oeguid);
                system.debug('oeconfigName'+oeconfigNamemap.get(oeguid));
                if(oeconfigNamemap!= null && oeconfigNamemap.containsKey(oeguid) && oeconfigNamemap.get(oeguid) != null ){
                    //Process each attribute of the OE config
                    for(cssmgnt.ProductProcessingUtility.Attribute attr : attrmap.get(oeguid)){                                 
                        system.debug('oeattribute'+attr);
                        if(oeAttributeMap.containsKey(attr.name) && oeAttributeMap.get(attr.name) != attr.value){
                            oeAttributeMap.put(attr.name,oeAttributeMap.get(attr.name)+','+attr.value); 
                        }else
                            oeAttributeMap.put(attr.name,attr.value);   
                    }
                }
                else {
                    continue;
                }
            }
            pcOEMap.put(configId,oeAttributeMap);
        }   
        return pcOEMap;
    }

}