/********************************************************
Class Name : ManageSubStageNotification
Test Class : ManageSubStageNotificationTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Shreya                19/11/2019      EDGE-116041 modified processSubStageNotification method to receive NetworkServiceId 
2.            Kiran                11/12/2019      EDGE-116041  NetworkServiceId rolled up to Subscription
3.            Pawan                 05-05-2020      EDGE-147219 : Ignore Number tag from substage notification of O2A
**********************************************************/
public with sharing class ManageSubStageNotification 
{
    //EDGE-116041
    private final static String NETSERID = 'NetworkServiceId';
    //EDGE-80847   
    public static String tenancyId = '';
    public static List<String> deviceIds = new List<String>();
    public static String deviceType = '';
    @InvocableMethod
    public static void processNotificationRecord(List<String> parameters1){
        System.debug('SubStageParams:::' + parameters1);
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        Boolean stopprocessing = false;
        String notificationId;
        String tenancyId = '';//EDGE-80847   
        try{
            
            
            String orderItemIdc; String orderItemDetails; String milestoneRecr; String eventType;String sourceSystem;
            orderItemIdc = parameters1[0];
            milestoneRecr = parameters1[1];
            eventType = parameters1[2]; 
            orderItemDetails = parameters1[3];
            //if(parameters.size() > 4){ sourceSystem = parameters[4]; }
            notificationId = parameters1[4]; 
            System.debug('Id::' + notificationId);
            if(String.isEmpty(String.valueOf(orderItemIdc)) || String.isEmpty(milestoneRecr) || String.isEmpty(eventType)){
                System.debug('Parameter Empty: '+String.valueOf(orderItemIdc)+' | '+ milestoneRecr + ' | '+eventType);
                stopprocessing = true;
            }
            system.debug('stopprocessing'+stopprocessing);
            if(!stopprocessing){
                params.orderIdc = orderItemIdc;
                if(String.isNotEmpty(milestoneRecr)) params.notifyAttributes = '{'+milestoneRecr+'}'; //convert string to JSON supported format
                if(String.isNotEmpty(orderItemDetails)) params.orderItemDetails = '{'+orderItemDetails+'}'; //convert string to JSON supported format
                params.eventType = eventType; 
            }
            System.debug('params'+params);
            
            if(params != null && !stopprocessing)
                System.debug('processSubStageNotification  calling!');
            processSubStageNotification(JSON.serialize(params),notificationId);
        }
        catch(Exception e){
            System.debug('Exception:' + e.getTypeName() +' '+ e.getMessage());
        }
    }
    
    public static void processSubStageNotification(String parameters, String notificationId){
        System.debug('In method processSubStageNotification with notif id'+notificationId);
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        Notification__c notif = [Select Id,Name,orderItemId__c,Status__c,Internal_Error_Description__c from 
                                 Notification__c where Id =: notificationId];
        System.debug('notif'+notif);
        String eventsrvcNumber;
        List<String> guidList= new List<String>();
        //Abinash
        List<id> orderIdList = new List<Id>(); 
        Map<String,String> mapNotifyAttr = new Map<String,String>(); //EDGE-80847        
        
        try{
            params = (ManageOrderNotificationUtil.Parameters) JSON.deserialize(parameters, ManageOrderNotificationUtil.Parameters.class);
            System.debug('parameters:::'+parameters);
            String orderItemIdc = params.orderIdc ;
            System.debug('orderItemIdc====>'+orderItemIdc);
            String orderItemDetails = params.orderItemDetails;
            String notificationAttr = params.notifyAttributes;
            String eventType = params.eventType;
            String orderId = null ; String srvcNumber = null; String instanceId = null;
            Boolean stopprocessing = false;
            List<String> keyparams = orderItemIdc.split('\\|');
            if(keyparams.size() > 0){ orderId = keyparams[0]; }
            if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }
            if(keyparams.size() > 2){ instanceId = keyparams[2]; }
            System.debug('orderId===>'+orderId +'srvcNumber===>'+srvcNumber+'instanceId====>'+instanceId);
            if(srvcNumber == null || orderId == null || instanceId == null){
                stopprocessing = true;
            }         
            eventsrvcNumber =srvcNumber;
            
            String serviceId;
            List<csord__Service__c> childService = new List<csord__Service__c>();
            String subscriptionId;
            String primaryOrderId;
            String subStageName = NULL;
            DateTime subStageCompletionDate = System.Now();//NULL;
            Set<Id> srvSpecIdSet= new Set<Id>();
            Datetime forecastedDate = NULL;
            //added for EDGE-116041
            String NetworkServiceId;
            List<csord__Service__c> updateServiceList = new List<csord__Service__c>();
            
            if(!stopprocessing)
            {
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                System.debug('notifyAttrs:::' + notifyAttrs);
                //----- Extract subStage details from Notification Attributes
                for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){
                    if(attr.name.contains('subStage')){
                        subStageName = attr.value;}
                 //NetworkServiceId added for EDGE-116041
                    if(NETSERID.contains(attr.name)){
                         NetworkServiceId = attr.value;
                        System.debug('N/W Service Id'+NetworkServiceId);
                    }
                //
                    if(attr.name.contains('currentForecastedDeliveryDate')) {
                        forecastedDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class); }
                    else if(attr.name.contains('DesignCompletionDate')||attr.name.contains('EquipmentOrderedDate')||attr.name.contains('EquipmentDeliveredDate')||attr.name.contains('InstallationDate')||attr.name.contains('ServiceActivationDate')||attr.name.contains('CustomerOrderAcceptanceDate') ||attr.name.contains('ServiceDeactivationDate')||attr.name.contains('DeviceRecoveredDate')){ 
                        subStageCompletionDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);}
                }               
                if(subStageName != NULL){ //EDGE-80847   
                    
                    mapNotifyAttr.put('subStageName', subStageName); //EDGE-103758
                    system.debug('subStageName>>>>>>'+subStageName);
                    if(subStageName.contains('Equipment Ordered') || subStageName.contains('Picking & Packing') || subStageName.contains('Delivery Tracking')){
                        for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){
                            //EDGE-119708 Logistics Order number is not getting displayed in subscription page even 
                            //after recieving DISPATCHED status from LOMS
                            if(subStageName.contains('Equipment Ordered') && attr.name.contains('LogisticOrderNumber')){
                                mapNotifyAttr.put('LogisticOrderNumber', attr.value);
                            }
                            if(subStageName.contains('Picking & Packing') && attr.name.contains('EstimatedDeliveryDate')){
                                mapNotifyAttr.put('EstimatedDeliveryDate', attr.value);
                            }                       
                            if(subStageName.contains('Delivery Tracking') && attr.name.contains('ConsignmentNumber')){
                                mapNotifyAttr.put('ConsignmentNumber', attr.value);
                            }
                            if(subStageName.contains('Delivery Tracking') && attr.name.contains('TrackingURL')){
                                mapNotifyAttr.put('TrackingURL', attr.value);
                            }
                            
                        }
                    }
                }
                
                
                List<Service_Specification__c> serSpecifications = new List<Service_Specification__c>();
                List<Service_Specification__c> SerSpecificationsList = new List<Service_Specification__c>();
                List<csord__Service__c> serviceListData = [SELECT Id, Name, csord__Status__c, csord__Subscription__c, csord__Order__c,toBeCancelled__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,Forecasted_Delivery_Date__c,
                                                       (Select Id, Name,GUID__c, Service__c FROM Service_Specifications__r),
                                                       (Select id,Name, csord__Status__c, csord__Subscription__c, csord__Order__c,toBeCancelled__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,Forecasted_Delivery_Date__c from csord__Services__r)
                                                       FROM csord__Service__c
                                                       WHERE csordtelcoa__Service_Number__c=:srvcNumber Order By CreatedDate];
                
                System.debug('serviceList:::' + serviceListData);
                
                List<csord__Service__c> serviceList = new List<csord__Service__c>();
                
                for(csord__Service__c srv :  serviceListData){
                    serviceList.add(srv);
                    if(srv.csord__Services__r != null  && srv.csord__Services__r.size() > 0){
                        //serviceList.addAll(srv.csord__Services__r);
                    }
                    
                }
                //to get substagematrix records
                
                Map<String,String> finalSubStageMatrix = new Map<String,String>();
                for(csord__Service__c srv :  serviceList)
                {
                    
                    serviceId = srv.Id;
                    if(srv.csord__Services__r !=  null && !srv.csord__Services__r.isEmpty())
                    childService.addAll(srv.csord__Services__r);
                    subscriptionId = srv.csord__Subscription__c;
                    
                    // primaryOrderId = srv.csord__Order__r.csord__Primary_Order__c != null ? srv.csord__Order__r.csord__Primary_Order__c : srv.csord__Order__c;
                    primaryOrderId = srv.csord__Order__c;
                    
                    System.debug(':serviceId:' + serviceId + ':subscriptionId:' + subscriptionId + ':primaryOrderId:' + primaryOrderId);
                    srv.Forecasted_Delivery_Date__c = forecastedDate; 
                    //NetworkServiceId added to Service object for EDGE-116041
                    srv.NetworkServiceId__c = NetworkServiceId;
                    updateServiceList.add(srv);
                    
                    //----- create all serviceSpecs Records(Parent Service) when first subStage Notification is Received
                    if(srv.Service_Specifications__r.size()==0){
                        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(srv.Id),'FULFILMENT');
                        system.debug('srvspecList:::' + srvspecList);
                        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList)
                        {
                            boolean checkChildSpec=false;
                            Set<String> serviceGuid = new Set<String>();
                            system.debug('srvSpec:::'+srvSpec + 'additionalAttributes:::' + srvSpec.additionalAttributes);
                            if(srvSpec.additionalAttributes.size()!=0){
                                for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                                    system.debug('attr===='+attr+'----='+attr.name);
                                    if(attr.name == 'parentSpec'){
                                        checkChildSpec = true;
                                        break;}            
                                }
                                if(!checkChildSpec){
                                    Service_Specification__c serSpec = new Service_Specification__c();
                                    serSpec.Name = srvSpec.name;
                                    serSpec.GUID__c = srvSpec.guid;
                                    serSpec.Service__c = srv.Id;
                                    serSpec.Code__c = srvSpec.code.removeEnd('_Fulfilment');
                                    serSpecifications.add(serSpec); 
                                }
                            }
                            
                            else{
                                Service_Specification__c serSpec = new Service_Specification__c();
                                serSpec.Name = srvSpec.name;
                                serSpec.GUID__c = srvSpec.guid;
                                serSpec.Service__c = srv.Id;
                                serSpec.Code__c = srvSpec.code.removeEnd('_Fulfilment');
                                serSpecifications.add(serSpec);
                            }
                            //adding network service id to service spec EDGE-116041
                            for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.SimpleAttributes){
                                if(NETSERID.equals(attr.name)){
                                    attr.value = NetworkServiceId;
                                }
                            }
                        }
                    }
                    
                    else {
                        SerSpecificationsList.addAll(srv.Service_Specifications__r);
                    }
                    finalSubStageMatrix= getSubStageMatrix(serviceId,subStageName,srv.toBeCancelled__c,srv.csord__Status__c);
                    System.debug('serviceId-->'+serviceId + 'subStageName===>'+subStageName + 'srv.toBeCancelled__c-->'+srv.toBeCancelled__c + 'srv.csord__Status__c==>'+srv.csord__Status__c);
                    System.debug('finalSubStageMatrix===>'+finalSubStageMatrix);
                }
                update updateServiceList;
                
                if(!serSpecifications.isEmpty()){
                    System.debug('serSpecifications:::' + serSpecifications);
                    insert serSpecifications;
                }
                SerSpecificationsList.addAll(serSpecifications);
                
                //----- create subStageNotification Records         
                Map<String, Service_Specification__c> srvSpecMap = new Map<String, Service_Specification__c>();
                for(Service_Specification__c srvSpec: SerSpecificationsList) {
                    srvSpecIdSet.add(srvSpec.Id);
                    srvSpecMap.put(srvSpec.guid__c,srvSpec);
                }
                System.debug('srvSpecMap::' + srvSpecMap);
                subStageNotification__c subStageNotif = new subStageNotification__c();
                subStageNotif.Name = subStageName;
                System.debug('subStageNotif.Name===>'+subStageNotif.Name);
                //System.debug('instanceId::' + instanceId + ' serId:::' + srvSpecMap.get(instanceId).Id);
                if(srvSpecMap.size()>0 && srvSpecMap.containsKey(instanceId)){
                    subStageNotif.Service_Specification__c = srvSpecMap.get(instanceId).Id;
                    System.debug('srvSpecMap.get(instanceId).Id===>'+srvSpecMap.get(instanceId).Id);
                }
                subStageNotif.Substage_Completion_Date__c = subStageCompletionDate;
                insert subStageNotif;
                // List<subStageNotification__c> subStageNotifList = new List<subStageNotification__c>([Select Id,Name,Service_Specification__c,Substage_Completion_Date__c FROM subStageNotification__c WHERE Name =: subStageName and Service_Specification__c IN : srvSpecIdSet]);
                
                //----- create subStageNotificationMap based on subStageName Received in Notification
                System.debug('subStageName::' + subStageName);
                List<Service_Specification__c> serSpecList = [Select Id, Service__c, Code__c, guid__c, (Select Name,Service_Specification__c from subStageNotifications__r where Name =:subStageName) from Service_Specification__c where service__c =: serviceId];
                String subNotification;
                System.debug('serSpecList::' + serSpecList);
                Map<String,String> subStageNotificationMap  = new Map<String,String>();
                //Set<String> specCodeSet = new Set<String>();
                Set<String> guidSet = new Set<String>();
                for(Service_Specification__c serSpec : serSpecList) {
                    subNotification = '';
                    for(subStageNotification__c subNotif : serSpec.subStageNotifications__r){
                        subNotification = subNotif.Name;
                    } 
                    if(subNotification.containsIgnoreCase(subStageName)) {
                        subStageNotificationMap.put(serSpec.Code__c,subNotification.toLowerCase(UserInfo.getLocale()));
                    }
                    //specCodeSet.add(serSpec.Code__c);
                    guidSet.add(serSpec.guid__c);
                }
                // System.debug('specCodeSet::' + specCodeSet);
                
                
                
                
                //----- Update additional attributes of Service Specs with attributes from orderItemDetails & notificationAttributes
                //if(subStageName.containsIgnoreCase('Product Requirements Validation')){
                List<csord__Service__c> srvList = [Select Id,Name from csord__Service__c where csord__Subscription__c  =: subscriptionId];
                Map<String,Map<String,String>> guidAttrMap = getGuidAttr(orderItemDetails,getGuidAdditionalAttributes(srvList));
                if(deviceIds != null && deviceIds.size() > 0  && deviceType != ''){
                    system.debug('deviceIds--'+deviceIds);
                    system.debug('serviceId--'+serviceId);
                    system.debug('deviceType--'+deviceType); 
                    updateAssets(deviceIds,serviceId,deviceType);  
                }
                //EDGE-105575 : quering CFSID from subs to populate it.//Query modified for NetworkServiceId
                csord__Subscription__c subsc = [Select Id, Name, customerFacingServiceId__c,NetworkserviceId__c from csord__Subscription__c where Id = :subscriptionId];
                Map<Id,Attachment> updatedGuidAttrMap = new Map <Id,Attachment>();
                if(guidAttrMap != NULL){
                    //EDGE-105575 : roll-up CFS ID at subscription
                    if(guidAttrMap.containskey(instanceId)){
                        subsc.customerFacingServiceId__c = guidAttrMap.get(instanceId).get('CustomerFacingServiceId');
                        //NetworkServiceId rolled up to subscription
                        subsc.NetworkserviceId__c = NetworkServiceId;
                        update subsc;
                    }
                    //End
                    for(String guid : guidAttrMap.keySet()){
                        csedm.API_1.addCharacteristic(serviceId, guid, guidAttrMap.get(guid));
                        //updatedGuidAttrMap = ServiceSpecificationUtils.getAddCharacteristic(serviceID,guid,guidAttrMap.get(guid));  
                        guidList.add(guid);
                    }
                    for(String guid : guidAttrMap.keySet()){
                        for(csord__Service__c childs : childService){
                        csedm.API_1.addCharacteristic(childs.Id, guid, guidAttrMap.get(guid));
                        //updatedGuidAttrMap = ServiceSpecificationUtils.getAddCharacteristic(serviceID,guid,guidAttrMap.get(guid));  
                        guidList.add(guid);
                        }
                        
                    }
                    
                }
                
                if(!updatedGuidAttrMap.isEmpty()){
                    
                    update updatedGuidAttrMap.values();
                }
                //}
                //if(!subStageName.containsIgnoreCase('Product Requirements Validation')){
                Map<String,Map<String,String>> notifAttrMap = getGuidNotifAttr(orderItemDetails,notificationAttr,getGuidAdditionalAttributes(srvList));
                Map<Id,Attachment> updatedNotifAttrMap = new Map <Id,Attachment>();
                System.debug('notifAttrMap.values()'+notifAttrMap.values());
                if(notifAttrMap.values() != NULL){
                    for(String guid : notifAttrMap.keySet()){
                        csedm.API_1.addCharacteristic(serviceId, guid, notifAttrMap.get(guid));
                        //updatedNotifAttrMap = ServiceSpecificationUtils.getAddCharacteristic(serviceID,guid,notifAttrMap.get(guid));    
                        
                    }
                    
                }
                System.debug('updatedNotifAttrMap'+updatedNotifAttrMap);
                if(!updatedNotifAttrMap.isEmpty()){
                    
                    update updatedNotifAttrMap.values();
                }
                
                //-----Roll-up subStage & stage fields of Services, Subscriptions, Orders-//EDGE-80847
                if(finalSubStageMatrix.equals(subStageNotificationMap)){
                    if(!subStageName.containsIgnoreCase(System.Label.EquipmentOrdered) && !subStageName.containsIgnoreCase(System.Label.EquipmentDelivered)){
                        System.debug('Inside If with subStageName:'+subStageName);
                        Set<String> allServiceSet = getChildServices(subscriptionId, guidSet);
                        allServiceSet.add(serviceId);
                        System.debug('allServiceSet::' + allServiceSet);
                        updateServices(allServiceSet, subStageName);
                    }
                    updateSubscriptions(subscriptionId,'subStage',mapNotifyAttr); //EDGE-103758
                    if(!subStageName.containsIgnoreCase(System.Label.EquipmentOrdered) && !subStageName.containsIgnoreCase(System.Label.EquipmentDelivered)){
                        updateOrderSubStage(primaryOrderId);                    
                    }    
                } 
            }
            
            notif.Status__c = 'Completed';          
            System.debug('notif.Status__c'+notif.Status__c);
            Boolean isSubLogicallyDeactivated = false;
            if(subStageName == System.Label.LogicalDeactivation){ 
                System.debug('Inside Logical deactivation ');
                isSubLogicallyDeactivated = checkSubscriptionDeactivation(serviceId, subscriptionId, subStageName);
                System.debug('isSubLogicallyDeactivated===>'+isSubLogicallyDeactivated);
            }
            
            if(isSubLogicallyDeactivated){
                csord__Subscription__c subToUpdate = [Select id,name,Trigger_RTS__c from csord__Subscription__c where Id =: subscriptionId];
                System.debug('subToUpdate=====>'+subToUpdate);
                subToUpdate.Trigger_RTS__c = true;
                update subToUpdate;
            }
        }
        catch(Exception e) {
            notif.Status__c = 'Error';
            notif.Internal_Error_Description__c = e.getTypeName() +', '+ e.getMessage() + ', ' + e.getLineNumber();
            System.debug('ExceptionOccured:::' + e.getMessage() + '--'+ e.getLineNumber());
        }
        update notif; 
        System.debug('notif updated');
        InvokeInventoryPublishEvents.publishServiceSpecificationHandler(eventsrvcNumber,guidList);
    }
    
    @TestVisible
    private static boolean checkSubscriptionDeactivation(String serviceId,String subscriptionId, String subStageName){
        Integer logicalDeactivatedProductCount = 0;
        Integer specToTrackCount = 0;
        Map<String,String> specificationCodeMap = new Map<String,String>();
        Set<String> specCodeToTrackSet = new Set<String>(); 
        List<Id> serviceIdList = new List<Id>();
        System.debug('serviceId===>'+serviceId+ 'subscriptionId====>'+subscriptionId+ 'subStageName====>'+subStageName);
        for(RightToStopProductMetadata__mdt mdata : [select id,offerCode__c,parentSpecCode__c,specificationCode__c,subStageTriggersCeaseBill__c from RightToStopProductMetadata__mdt]){
            specificationCodeMap.put(mdata.specificationCode__c, mdata.parentSpecCode__c);
            System.debug('specificationCodeMap====>'+specificationCodeMap.keyset());
        }
        
        for(String specCodeKey : specificationCodeMap.Keyset()){
            specCodeToTrackSet.add(specCodeKey);
            System.debug('specCodeToTrackSet===>'+specCodeToTrackSet);
        }
        for(csord__Service__c serv :[SELECT Id, Name, csord__Status__c, csord__Subscription__c FROM csord__Service__c WHERE csord__Subscription__c =: subscriptionId AND Id =: serviceId]){
            serviceIdList.add(serv.Id); 
            System.debug('serviceIdList===>'+serviceIdList);
            
        }
        Boolean isSpecvaluePresent = false;
        Boolean isSpecCodePresent = false;
        
        List<subStageNotification__c>  substageList =[Select Name,Service_Specification__c,Service_Specification__r.Code__c from subStageNotification__c where Name =:subStageName AND Service_Specification__r.service__c in: serviceIdList ]; 
        for(subStageNotification__c subStageNotification : substageList){
            System.debug('subStageNotification===>'+subStageNotification);
            //if(servSpec.subStageNotifications__r != null){
            isSpecvaluePresent = specCodeToTrackSet.Contains(subStageNotification.Service_Specification__r.Code__c);
            
            
            if(isSpecvaluePresent){
                logicalDeactivatedProductCount++;
                System.debug('logicalDeactivatedProductCount==>'+logicalDeactivatedProductCount);
            }
            //  }
        }
        List<CS_SpecificationDTO.ServiceSpecification> allServSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        for(csord__Service__c srv : [SELECT Id, Name, csord__Status__c FROM csord__Service__c WHERE Id IN : serviceIdList]){
            allServSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(srv.id),'FULFILMENT');
            System.debug('allServSpecList===>'+allServSpecList);
            
            for(CS_SpecificationDTO.ServiceSpecification srvSpec : allServSpecList){
                System.debug('srvSpec.code====>'+srvSpec.code);
                //String specCodeString = srvSpec.code
                isSpecCodePresent = specCodeToTrackSet.Contains(srvSpec.code.removeEnd('_Fulfilment'));
                if(isSpecCodePresent){
                    specToTrackCount++;
                    System.debug('specToTrackCount===>'+specToTrackCount);
                }
                
            }
        }
        if(logicalDeactivatedProductCount == specToTrackCount ){
            return true;
        }else{
            return false;
        }
    }
    
    public static Map<String,String> getSubStageMatrix(String srvId,String subStgeName, String tobeCancelled,String servStatus){
        System.debug('tobeCancelled===>'+tobeCancelled);
        //----- get fieldLabelMap & fieldNameMap from Schema for new/Modify and Cease Order
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.substage_matrix__mdt.fields.getMap();
        Map<String, Schema.SObjectField> ceaseFieldMap = Schema.SObjectType.Substage_Matrix_Cease_Order__mdt.fields.getMap();
        Map<String,String> fieldLabelMap = new Map<String,String>();
        Map<String,String> fieldNameMap = new Map<String,String>();
        Map<String,String> ceaseFieldLabelMap = new Map<String,String>();
        Map<String,String> ceaseFieldNameMap = new Map<String,String>();
        Map<String,String> finalSubStageMatrixMap = new Map<String,String>();
        List<Service_Specification__c> serSpecList = [Select Id, Service__c, Code__c, guid__c from Service_Specification__c where service__c =: srvId];
        Set<String> specCodeSet = new Set<String>();
        for(Service_Specification__c serSpec : serSpecList) {                   
            specCodeSet.add(serSpec.Code__c);
            
        }
        System.debug('specCodeSet=>'+specCodeSet);
        if(tobeCancelled == 'false'){
            System.debug('Inside new/modify matrix');
            for(String fieldName: fieldMap.keySet()) {
                fieldLabelMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
                fieldNameMap.put(fieldMap.get(fieldName).getDescribe().getLabel().toLowerCase(UserInfo.getLocale()),fieldName);
            }               
            System.debug('fieldLabelMap::' + fieldLabelMap);    System.debug('fieldNameMap::' + fieldNameMap);
            //----- create subStageMatrixMap from Matrix Metadata based on subStageName and specCodes for New/Modify
            System.debug('UserInfo.getLocale()'+UserInfo.getLocale());
            System.debug('subStgeName.toLowerCase(UserInfo.getLocale()'+subStgeName.toLowerCase(UserInfo.getLocale()));
            if(fieldNameMap.get(subStgeName.toLowerCase(UserInfo.getLocale()))!= null){
                
                string field = fieldNameMap.get(subStgeName.toLowerCase(UserInfo.getLocale()));
                System.debug('field====>'+field);
                
                String qry = 'Select DeveloperName,'+ String.escapeSingleQuotes(field) + ' from Substage_Matrix__mdt where DeveloperName IN :specCodeSet and ' + String.escapeSingleQuotes(field) + ' = true ';
                System.debug('qry::' + qry);
                List<Substage_Matrix__mdt> subStageMatrixList = Database.Query(qry);
                
                for(Substage_Matrix__mdt subStageMatrix : subStageMatrixList) {
                    finalSubStageMatrixMap.put(subStageMatrix.DeveloperName,fieldLabelMap.get(field).toLowerCase(UserInfo.getLocale()));
                }
                System.debug('finalSubStageMatrixMap under new/Modify::' + finalSubStageMatrixMap);
            }
        }
        else {
            System.debug('Inside cease matrix');
            for(String ceaseFieldName: ceaseFieldMap.keySet()){                 
                ceaseFieldLabelMap.put(ceaseFieldName,ceaseFieldMap.get(ceaseFieldName).getDescribe().getLabel());
                ceaseFieldNameMap.put(ceaseFieldMap.get(ceaseFieldName).getDescribe().getLabel().toLowerCase(UserInfo.getLocale()),ceaseFieldName);
            }
            System.debug('ceaseFieldLabelMap::' + ceaseFieldLabelMap);    System.debug('ceaseFieldNameMap::' + ceaseFieldNameMap);
            if(ceaseFieldNameMap.get(subStgeName.toLowerCase(UserInfo.getLocale())) != null){
                
                //----- create subStageMatrixMap from Matrix Metadata based on subStageName and specCodes for cancel order
                String ceaseField = ceaseFieldNameMap.get(subStgeName.toLowerCase(UserInfo.getLocale()));
                System.debug('ceaseField====>'+ceaseField);
                String ceaseQry = 'Select DeveloperName,'+ String.escapeSingleQuotes(ceaseField) + ' from Substage_Matrix_Cease_Order__mdt where DeveloperName IN :specCodeSet and ' + String.escapeSingleQuotes(ceaseField) + ' = true ';
                System.debug('ceaseQry====>'+ceaseQry);
                List<Substage_Matrix_Cease_Order__mdt> ceaseSubstageMatrixList = Database.Query(ceaseQry);
                
                Map<String,String> ceaseSubStageMatrixMap = new Map<String,String>();
                for(Substage_Matrix_Cease_Order__mdt ceaseSubStageMatrix : ceaseSubstageMatrixList) {
                    finalSubStageMatrixMap.put(ceaseSubStageMatrix.DeveloperName,ceaseFieldLabelMap.get(ceaseField).toLowerCase(UserInfo.getLocale()));
                }
                System.debug('finalSubStageMatrixMap under cease::===>' + finalSubStageMatrixMap);
            }
            
        }
        return finalSubStageMatrixMap;
        
        
        
    }
    
    //-----Utility Functions
    //
    //----- get Map of guid & existing additionalAttributes from ServiceSpecs to update ServiceSpecs -----//
    public static Map<String,Map<String,String>> getGuidAdditionalAttributes(List<csord__Service__c> serviceList){
        Map<String,String> addAttrMap = NULL;
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        for(csord__Service__c serv : serviceList){
            List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'FULFILMENT');
            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){
                addAttrMap = new Map<String,String>();
                for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                    addAttrMap.put(attr.name,attr.value);}
                guidAddAttrMap.put(srvSpec.guid,addAttrMap);
            }
        }
        System.debug('guidAddAttrMap::' + guidAddAttrMap);
        return guidAddAttrMap;
    }    
    
    
    //----- get Map of Parent guid,Child guid & attributes from orderItemDetails to update Service Specifications -----//
    public static Map<String,Map<String,String>> getGuidAttr(String orderItemDetails, Map<String,Map<String,String>> guidAddAttribMap){
        Map<String,String> attrMap = new Map<String,String>();
        Map<String,Map<String,String>> guidAttrMap = new Map<String,Map<String,String>>();
        Map<String,String> childAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> guidChildAttrMap = new Map<String,Map<String,String>>();
        ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse(orderItemDetails);
        Map<String,Exclusion_List_NotifAtts__c> mapNotifAttsToExclude = Exclusion_List_NotifAtts__c.getAll(); //EDGE-147219
        system.debug('productUpdates.attributes>>>'+ productUpdates.attributes);
       if(productUpdates.attributes != NULL){
           if(productUpdates.productId != null && guidAddAttribMap.get(productUpdates.productId) != null){
               attrMap.putAll(guidAddAttribMap.get(productUpdates.productId));
           }
      
            for(ManageOrderNotificationUtil.NotificationAttributes attr : productUpdates.attributes){
                //attrMap.putAll(guidAddAttribMap.get(productUpdates.productId));
                //EDGE-147219 : If attribute is in exclude list then not adding it in map
                if(!mapNotifAttsToExclude.containsKey(attr.name)){
                        attrMap.put(attr.name,attr.value);
                    }
                //attrMap.put(attr.name,attr.value);
                system.debug('attr Name>>>'+ attr.name);
                //EDGE-80847
                if(attr.name.equalsIgnoreCase('DeviceID')){
                    for(String di: attr.value.split(',')){
                        deviceIds.add(di);
                    }
                }
                if(attr.name.equalsIgnoreCase('DeviceIDType')){
                    deviceType = attr.value;
                }
                if(attr.name.equalsIgnoreCase('tenancyId')){
                    tenancyId = attr.value;
                }
            }
            guidAttrMap.put(productUpdates.productId,attrMap);
        }
        if(productUpdates.childProduct != NULL){
            for(ManageOrderNotificationUtil.childProduct childProd : productUpdates.childProduct){
                childAttrMap = new Map<String,String>();
                system.debug('childProd.productId>>>'+childProd.productId);
                system.debug('guidAddAttribMap>>>'+guidAddAttribMap);
                system.debug('containsKey>>>'+guidAddAttribMap.containsKey(childProd.productId));
                system.debug('get>>>'+guidAddAttribMap.get(childProd.productId));
                system.debug('childAttrMap>>>'+childAttrMap);
                if(childProd.productId != null && guidAddAttribMap != null 
                   && guidAddAttribMap.containsKey(childProd.productId) && guidAddAttribMap.get(childProd.productId) != null){
          childAttrMap.putAll(guidAddAttribMap.get(childProd.productId));
                   }
                if(childProd.attributes != NULL){
                    for(ManageOrderNotificationUtil.NotificationAttributes childAttr : childProd.attributes){
                        //childAttrMap.putAll(guidAddAttribMap.get(childProd.productId));
               if(childAttr.name.equalsIgnoreCase('DeviceID')){
                    for(String di: childAttr.value.split(',')){
                        deviceIds.add(di);
                    }
                }
                if(childAttr.name.equalsIgnoreCase('DeviceIDType')){
                    deviceType = childAttr.value;
                }
                if(childAttr.name.equalsIgnoreCase('tenancyId')){
                    tenancyId = childAttr.value;
                }
                        childAttrMap.put(childAttr.name,childAttr.value);                       
                    }
                }
                guidChildAttrMap.put(childProd.productId,childAttrMap);
            }
            guidAttrMap.putAll(guidChildAttrMap);
        }
        System.debug('guidAttrMap::' + guidAttrMap);
        return guidAttrMap;
    }
    
    
    //----- get Map of Parent guid & attributes from notification Attributes to update Service Specifications -----//
    public static Map<String,Map<String,String>> getGuidNotifAttr(String orderItemDetails, String notificationAttr, Map<String,Map<String,String>> guidAddAttribMap){
        Map<String,String> notifAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> guidNotifAttrMap = new Map<String,Map<String,String>>();
        ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse(orderItemDetails);
        ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
        notifAttrMap.putAll(guidAddAttribMap.get(productUpdates.productId));
        for(ManageOrderNotificationUtil.NotificationAttributes notifAttr : notifyAttrs.attributes){
            if(!notifAttr.name.containsIgnoreCase('subStage')){ 
                //EDGE-80847
                notifAttrMap.put(notifAttr.name,notifAttr.value);
                if(notifAttr.name.equalsIgnoreCase('tenancyId')){
                    tenancyId = notifAttr.value;
                }
            }
        }
        guidNotifAttrMap.put(productUpdates.productId,notifAttrMap);
        System.debug('guidNotifAttrMap::' + guidNotifAttrMap);
        return guidNotifAttrMap;
    }
    
    
    //----- get all Child Services of a Parent Service under Subscription -----//
    public static Set<String> getChildServices(String subscriptionId, Set<String> guidSet)
    {
        Set<String> childServiceSet = new Set<String>();
        List<csord__Service__c> serviceList = [Select Id,Name from csord__Service__c where csord__Subscription__c  =: subscriptionId];
        for(csord__Service__c serv : serviceList){
            List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'FULFILMENT');
            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){
                if(srvSpec.additionalAttributes.size()!=0){
                    for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                        if(attr.name.containsIgnoreCase('parentSpec') && guidSet.contains(attr.value)){
                            childServiceSet.add(serv.Id);
                        }
                    }
                }
            }
        }
        System.debug('childServiceSet:::' + childServiceSet);
        return childServiceSet;
    }
    
    
    //----- Update stage and substage of Services -----//
    public static void updateServices(Set<String> serSet, String subStageName) {
        System.debug('Inside updateServices method');
        //EDGE-80847
        List<csord__Service__c> serviceList = [SELECT Id, Name,Tenancy_Id__c, substage__c, stage__c, csord__Status__c,toBeCancelled__c , csord__Subscription__c FROM csord__Service__c WHERE  Id IN :serSet];
        for(csord__Service__c srvc :  serviceList) {
            if(srvc.substage__c == NULL)
            { srvc.substage__c = subStageName;
             srvc.Tenancy_Id__c = tenancyId;
             System.debug('srvc.substage__c jshdg'+srvc.substage__c );}
            
            if(srvc.substage__c != NULL && !srvc.substage__c.equalsIgnoreCase(System.Label.ProductCompletionNotice))
            { srvc.substage__c = subStageName; 
             srvc.Tenancy_Id__c = tenancyId;//EDGE-80847
            }        
        }
        System.debug('serviceList::' + serviceList);
        update serviceList;
        List<csord__Service__c> updateServiceList = [SELECT Id, Name, substage__c, stage__c, csord__Status__c, toBeCancelled__c,csord__Subscription__c FROM csord__Service__c WHERE  Id IN :serSet];
        
        for(csord__Service__c srvc :  updateServiceList) {
            System.debug('Inside updateserviceList');
            if(srvc.stage__c == NULL){
                if(subStageName.containsIgnoreCase(System.Label.ProductRequirementsValidation)){
                    srvc.stage__c = System.Label.OrderReceived;}
                else if(subStageName.containsIgnoreCase(System.Label.ProductPreparation) || subStageName.containsIgnoreCase(System.Label.SiteVisitAndInstallation) || subStageName.containsIgnoreCase(System.Label.ProductActivationAndTesting) || subStageName.containsIgnoreCase(System.Label.LogicalDeactivation) || subStageName.containsIgnoreCase(System.Label.DeviceRecovery)||subStageName.containsIgnoreCase(System.Label.EquipmentRecovered) || subStageName.containsIgnoreCase(System.Label.EquipmentOrdered)||subStageName.containsIgnoreCase(System.Label.EquipmentDelivered) ) {
                    
                    srvc.stage__c = System.Label.OrderBeingFulfilled; 
                    System.debug('srvc.stage__c vhsa==>'+srvc.stage__c);
                }
                else if(subStageName.containsIgnoreCase(System.Label.CustomerOrderAcceptance)){
                    srvc.stage__c = System.Label.OrderReadyForUse; }
                else if(subStageName.containsIgnoreCase(System.Label.ProductCompletionNotice)) {
                    System.debug('check1');
                    srvc.stage__c = System.Label.OrderClosed; }
                else{
                    System.debug('check2');
                }
            }
            if(srvc.stage__c != NULL && !srvc.stage__c.equalsIgnoreCase(System.Label.OrderClosed)){
                if(subStageName.containsIgnoreCase(System.Label.ProductRequirementsValidation) && !srvc.substage__c.containsIgnoreCase(System.Label.ProductActivationAndTesting)){                      
                    srvc.stage__c = System.Label.OrderReceived; }
                else if(subStageName.containsIgnoreCase(System.Label.ProductPreparation) || subStageName.containsIgnoreCase(System.Label.SiteVisitAndInstallation) || subStageName.containsIgnoreCase(System.Label.ProductActivationAndTesting)|| subStageName.containsIgnoreCase(System.Label.LogicalDeactivation)|| subStageName.containsIgnoreCase(System.Label.DeviceRecovery)||subStageName.containsIgnoreCase(System.Label.EquipmentRecovered) || subStageName.containsIgnoreCase(System.Label.EquipmentOrdered)||subStageName.containsIgnoreCase(System.Label.EquipmentDelivered)) {
                    srvc.stage__c = System.Label.OrderBeingFulfilled; }
                else if(subStageName.containsIgnoreCase(System.Label.CustomerOrderAcceptance)){
                    srvc.stage__c = System.Label.OrderReadyForUse; }
                else if(subStageName.containsIgnoreCase(System.Label.ProductCompletionNotice)) {
                    System.debug('check3');
                    srvc.stage__c = System.Label.OrderClosed; 
                }
                else{
                    System.debug('check4');
                }
            }
            
            System.debug('updatedServiceList::' + updateServiceList);
            
            
        }
        update updateServiceList;
    }
    
    public static void updateSubscriptions(String subId, String notificationType){
        updateSubscriptions(subId, notificationType, null);
    }
    //----- Update Subscription Stage depending on count of services stages -----//
    public static void updateSubscriptions(String subId, String notificationType, Map<String, String> mapNotifyAttr){
        Integer receivedCount = 0;
        Integer beingFulfilledCount = 0;
        Integer readyForUseCount = 0;
        Integer fulfilledCount = 0;
        csord__Subscription__c subscrib = new csord__Subscription__c();
        //Vimal remove update of secondary orders
        csord__Order__c secOrder = new csord__Order__c();
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        //BUG Fix Changes
        if(notificationType.containsIgnoreCase('Stage')){
            ////EDGE-80847
            //serviceList = [Select Id,Name,stage__c,csord__Subscription__c,csord__Order__c,csord__Status__c from csord__Service__c where csord__Subscription__c  =: subId and csord__Status__c != 'Connected'];
            serviceList = [Select Id,Name,stage__c,Tenancy_ID__c    ,csord__Subscription__c,csord__Order__c,csord__Status__c,toBeCancelled__c from csord__Service__c where csord__Subscription__c  =: subId and (NOT Name LIKE 'Bandwidth%')];
        }       
        for(csord__Service__c srvc :  serviceList) {
            System.debug('srvc::'+srvc);
            if(srvc.stage__c != NULL) {
                if(srvc.stage__c.containsIgnoreCase(System.Label.OrderReceived))            { receivedCount += 1; }
                else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderBeingFulfilled)) { receivedCount += 1; beingFulfilledCount += 1; }
                else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderReadyForUse))    { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; }
                else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderClosed))         { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; fulfilledCount += 1; System.debug('checkAAA');}
            }
            subscrib.Id = srvc.csord__Subscription__c;
            //secOrder.Id = srvc.csord__Order__c;
        }
        System.debug('serviceListSize:' + serviceList.size() + ':receivedCount:' + receivedCount + ':beingFulfilledCount:' + beingFulfilledCount + ':readyForUseCount:' + readyForUseCount + ':fulfilledCount:' + fulfilledCount);        
        if(serviceList.size() > 0){
            subscrib.TenancyID__c = tenancyId;
            if(receivedCount == serviceList.size())         { subscrib.stage__c = System.Label.OrderReceived;   }
            if(beingFulfilledCount == serviceList.size())   { subscrib.stage__c = System.Label.OrderBeingFulfilled;}
            if(readyForUseCount == serviceList.size())      { subscrib.stage__c = System.Label.OrderReadyForUse;    }
            if(fulfilledCount == serviceList.size())        { subscrib.stage__c = System.Label.OrderClosed;   System.debug('checkBBBBB');  }
            System.debug('updateSubscriptions__subscrib::' + subscrib); 
            //secOrder.stage__c = subscrib.stage__c;
            if(mapNotifyAttr != null && mapNotifyAttr.size()>0){//EDGE-80847 Start
                if(mapNotifyAttr.ContainsKey('subStageName')){
                    list<SubStageStatus__mdt> subStageStatusRec = [SELECT id, Status__c, SubStage__c FROM SubStageStatus__mdt where SubStage__c = :mapNotifyAttr.get('subStageName')];
                    if(subStageStatusRec != null && subStageStatusRec.size() > 0)
                        subscrib.SubStageStatus__c = subStageStatusRec[0].Status__c;
                    else
                        subscrib.SubStageStatus__c = 'Delivery Information Not Available';
                }
                //EDGE-119708 Logistics Order number is not getting displayed in subscription page even 
        //after recieving DISPATCHED status from LOMS
                if(mapNotifyAttr.ContainsKey('LogisticOrderNumber'))
                    subscrib.Logistics_Order_Number__c = mapNotifyAttr.get('LogisticOrderNumber');
                if(mapNotifyAttr.ContainsKey('ConsignmentNumber'))
                    subscrib.Consignment_Number__c = mapNotifyAttr.get('ConsignmentNumber');
                if(mapNotifyAttr.ContainsKey('TrackingURL'))
                    subscrib.Delivery_Tracking__c = mapNotifyAttr.get('TrackingURL');
                if(mapNotifyAttr.ContainsKey('EstimatedDeliveryDate'))
                    subscrib.Estimated_Delivery_Date__c = (datetime)json.deserialize('"'+mapNotifyAttr.get('EstimatedDeliveryDate')+'"', datetime.class);
            }//EDGE-80847 End
            update subscrib;
            //update secOrder;
        }
    }
    
    
    //----- Update Primary Order Stage based on count of Secondary Orders -----//
    //Abinash : Below method is only updating secondary order and now it is nomore used ecause we don't have any secondary order and Order stage is already updating in updateSubscriptions method
    public static void updateOrder(String primaryOrdId) {
        Integer receivedCount = 0;
        Integer beingFulfilledCount = 0;
        Integer readyForUseCount = 0;
        Integer fulfilledCount = 0;
        csord__Order__c primaryOrder = new csord__Order__c();
        List<csord__Order__c> orderList = [Select Id,Name,stage__c,csord__Primary_Order__c from csord__Order__c where csord__Primary_Order__c =: primaryOrdId];
        for(csord__Order__c ord : orderList){
            if(ord.stage__c != NULL) {
                if(ord.stage__c.containsIgnoreCase(System.Label.OrderReceived))         { receivedCount += 1; }
                else if(ord.stage__c.containsIgnoreCase(System.Label.OrderBeingFulfilled)){ receivedCount += 1; beingFulfilledCount += 1;   }
                else if(ord.stage__c.containsIgnoreCase(System.Label.OrderReadyForUse))     { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1;  }
                else if(ord.stage__c.containsIgnoreCase(System.Label.OrderClosed))          { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; fulfilledCount += 1; }
            }
            primaryOrder.Id = ord.csord__Primary_Order__c;
            System.debug('primaryOrder.Id====>'+primaryOrder.Id);
        }
        System.debug('orderList:' + orderList.size() + ':receivedCount:' + receivedCount + ':beingFulfilledCount:' + beingFulfilledCount + ':readyForUseCount:' + readyForUseCount + ':fulfilledCount:' + fulfilledCount); 
        if(orderList.size() > 0){
            if(receivedCount == orderList.size())           { primaryOrder.stage__c = System.Label.OrderReceived;   }
            if(beingFulfilledCount == orderList.size())     { primaryOrder.stage__c = System.Label.OrderBeingFulfilled;}
            if(readyForUseCount == orderList.size())        { primaryOrder.stage__c = System.Label.OrderReadyForUse;    }
            if(fulfilledCount == orderList.size())          { primaryOrder.stage__c = System.Label.OrderClosed;     }
            System.debug('updateOrder_primaryOrder::' + primaryOrder);
            update primaryOrder;
        }
    }
    
    //Vimal: creating new method signature to update the primary order stages based on services and irrespective of secondary orders
    public static void updateOrderSubStage(String orderId) {
        Integer receivedCount = 0;
        Integer beingFulfilledCount = 0;
        Integer readyForUseCount = 0;
        Integer fulfilledCount = 0;
        //csord__Order__c primaryOrder = new csord__Order__c();
        //fetch stage information from Subscriptions
        List<csord__Subscription__c> subList = [Select Id,Name,stage__c,csord__Order__c from csord__Subscription__c where csord__Order__c =: orderId AND Name !='Connected Workplace Solution'];
        //create a map of orderid and subList
        Map<Id, List<csord__Subscription__c>> ordSubMap = new Map<Id, List<csord__Subscription__c>>();
        for(csord__Subscription__c sub : subList){
            if(!ordSubMap.containsKey(sub.csord__Order__c)){
                ordSubMap.put(sub.csord__Order__c, new List<csord__Subscription__c>{sub});
            } else {
                ordSubMap.get(sub.csord__Order__c).add(sub);
            }
        }
        
        List<csord__Order__c> orderListtoUpdate = new List<csord__Order__c>();
        
        for(Id ordId: ordSubMap.keySet()){
            List<csord__Subscription__c> subList2 = ordSubMap.get(ordId);
            for(csord__Subscription__c sub1 : ordSubMap.get(ordId)){
                if(sub1.stage__c != NULL) {
                    if(sub1.stage__c.containsIgnoreCase(System.Label.OrderReceived))         { receivedCount += 1; }
                    else if(sub1.stage__c.containsIgnoreCase(System.Label.OrderBeingFulfilled)){ receivedCount += 1; beingFulfilledCount += 1;   }
                    else if(sub1.stage__c.containsIgnoreCase(System.Label.OrderReadyForUse))     { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1;  }
                    else if(sub1.stage__c.containsIgnoreCase(System.Label.OrderClosed))          { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; fulfilledCount += 1; }
                }
            }
            System.debug('subList2:' + subList2.size() + ':receivedCount:' + receivedCount + ':beingFulfilledCount:' + beingFulfilledCount + ':readyForUseCount:' + readyForUseCount + ':fulfilledCount:' + fulfilledCount); 
            if(subList.size() > 0){
                csord__Order__c ordertoUpdate = new csord__Order__c();
                ordertoUpdate.Id = ordId;
                if(receivedCount == subList2.size())           { ordertoUpdate.stage__c = System.Label.OrderReceived;   }
                if(beingFulfilledCount == subList2.size())     { ordertoUpdate.stage__c = System.Label.OrderBeingFulfilled;}
                if(readyForUseCount == subList2.size())        { ordertoUpdate.stage__c = System.Label.OrderReadyForUse;    }
                if(fulfilledCount == subList2.size())          { ordertoUpdate.stage__c = System.Label.OrderClosed;     }
                //System.debug('updateOrder_primaryOrder::' + primaryOrder);
                orderListtoUpdate.add(ordertoUpdate);
            }
            //reset counters
            receivedCount = 0;
            beingFulfilledCount = 0;
            readyForUseCount = 0;
            fulfilledCount = 0;
        }
        
        if(orderListtoUpdate.size() > 0){
            update orderListtoUpdate;
        }
        
        
    }
    public static void updateAssets(List<String> deviceID,String serviceId,String deviceIdType){
        system.debug('deviceIds--'+deviceID);
        system.debug('serviceId--'+serviceId);
        system.debug('deviceType--'+deviceIdType); 
        AssetUpsertionHelper.updateAsset(deviceID,serviceId,deviceIdType);
    }    
}