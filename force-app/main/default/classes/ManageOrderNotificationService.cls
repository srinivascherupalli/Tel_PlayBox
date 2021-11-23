/********************************************************
Class Name : ManageOrderNotificationService
Test Class : ManageOrderNotificationServiceTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.              -                   30/8/2019       EDGE-112367  Directory Listing callout after  completion of UC,Mobile Access,Mobility
2.            Vaibhav                 -             EDGE-91568  Subscription and services status changes for Suspend functionality
3.            Shreya                22/10/2019      EDGE-113553 removed EDIS call
4.            Vaibhav               22/10/2019      EDGE-115655 Callout to NumberUtil class on receiving In progress and complete status notifications.  
5.            Vaibhav               26/11/2019      EDGE-125635 Suspend related changes fix
6.            Vaibhav               12/10/2019      EDGE-98385  Resume order realted changes
7.            Vaibhav Deshpande     21/01/2020      EDGE-120128 - priceAlteration block for EM new order
8.            Sandip Deshmane       4/2/2020        EDGE-132208 - Sync Removed Number status to NCS
9.            Sandip Deshmane       18/2/2020       EDGE-136242 - Added below condition to avoid calling existing code in case of NGUC. - Part of 575 refactoring
10.           Pawan/Vaibhav         18/03/2020      EDGE-124711/EDGE-124029 : Update CLI,DLI,TLI,PSLI on RTB completion
**********************************************************
*/
public with sharing class ManageOrderNotificationService {
    
    public static final String STATUS       = 'status';
    public static final String FULFILMENT       = 'FULFILMENT';
    public static List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
    
    @InvocableMethod
    public static void processNotificationRecord(List<String> parameters1){
        List<String> paramList = new List<String>();
        List<String> paramBillingList = new List<String>();
        List<String> paramAppointmentList = new List<String>();
        String notificationId;
        ManageOrderNotificationUtil.Parameters paramsUC = new ManageOrderNotificationUtil.Parameters();
        List<CS_SpecificationDTO.ComplexAttributes> simpleChars =  new List<CS_SpecificationDTO.ComplexAttributes>();
        List<CS_SpecificationDTO.ComplexAttributes> simpleCharsMobile =  new List<CS_SpecificationDTO.ComplexAttributes>();
        String OrderidNumber ;
        try{
            System.debug('parameters1'+parameters1);
            //List<String> parameters = paramString.split(':::');
            Boolean stopprocessing1 = false;
            
            String orderItemIdc1; String orderItemDetails1; String notificationAttr1; String eventType1;String sourceSystem1;
            orderItemIdc1 = parameters1[0];
            notificationAttr1 = parameters1[1];
            eventType1 = parameters1[2]; 
            orderItemDetails1 = parameters1[3];
            sourceSystem1 = parameters1[4];
            notificationId = parameters1[6];
            if(String.isEmpty(String.valueOf(orderItemIdc1)) || String.isEmpty(notificationAttr1) || String.isEmpty(eventType1) || String.isEmpty(sourceSystem1)){
                System.debug('Parameter Empty: '+orderItemIdc1+' | '+ notificationAttr1 + ' | '+eventType1+ ' | '+sourceSystem1);
                stopprocessing1 = true;
            }      
            if(!stopprocessing1){
                ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
                params.orderIdc = orderItemIdc1;
                if(String.isNotEmpty(notificationAttr1)) params.notifyAttributes = '{'+notificationAttr1+'}'; //convert string to JSON supported format
                if(String.isNotEmpty(orderItemDetails1)) params.orderItemDetails = '{'+orderItemDetails1+'}'; //convert string to JSON supported format
                params.eventType = eventType1; 
                if(sourceSystem1 == 'Fulfilment' && eventType1 =='statusNotification' || eventType1 == 'delay'){
                    paramList.add(JSON.serialize(params));
                    paramsUC = params;
                }
                if(sourceSystem1 == 'Billing') {paramBillingList.add(JSON.serialize(params));}
                if(sourceSystem1 == 'Fulfilment' && eventType1 =='appointmentNotification') {paramAppointmentList.add(JSON.serialize(params));}
            }
            
            if(!paramList.isEmpty())
                updateServiceRecord(paramList,notificationId);
            if(!paramBillingList.isEmpty()){updateSubscriptionRecord(paramBillingList,notificationId);}
            if(!paramAppointmentList.isEmpty()) {updateAppointmenRecord(paramAppointmentList,notificationId); }
            if(!paramList.isEmpty()){
                ManageOrderNotificationUtil.Parameters params  = (ManageOrderNotificationUtil.Parameters) JSON.deserialize(JSON.serialize(paramsUC), ManageOrderNotificationUtil.Parameters.class);
                String orderItemIdc = params.orderIdc ;
                String orderItemDetails = params.orderItemDetails;
                String notificationAttr = params.notifyAttributes;
                String eventType = params.eventType;
                String orderId = null ; String srvcNumber = null; String instanceId = null;
                Boolean stopprocessing = false;
                System.debug('orderItemIdc ::' + orderItemIdc );
                List<String> keyparams = orderItemIdc.split('\\|');
                if(keyparams.size() > 0){ orderId = keyparams[0]; }
                if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }
                if(keyparams.size() > 2){ instanceId = keyparams[2]; }
                
                
                System.debug('srvcNumber:: '+ srvcNumber);
                List<String> childAttr =  new List<String>();
                ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse(orderItemDetails);
                System.debug('productUpdates::'+productUpdates);
                if(productUpdates.childProduct != NULL){for(ManageOrderNotificationUtil.childProduct childProd : productUpdates.childProduct){childAttr.add(childProd.productId);}
                                                       }
                
                if(checkUCCompletion(JSON.serialize(paramsUC),notificationId,simpleChars,srvspecList,notificationAttr,orderItemIdc,childAttr)){
                    if(srvcNumber!=null){
                        //EDGE-81250 changes
                        List<csord__Service__c> uceServList = [select id from csord__service__c where csordtelcoa__Service_Number__c =: srvcNumber and (csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c like '%DMCAT_ProductOffering_000304%' OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c like '%DMCAT_ProductSpecification_000871%') FOR Update];    
                        
                        //sorting by createdDate
                        uceServList=(List<csord__Service__c>)CustomSortUtility.customSort(uceServList,'createddate','DateTime'); //list in ascending order
                        List<csord__Service__c> ucServList=new List<csord__Service__c>();
                        for(Integer i=uceServList.size()-1;i>=0;i--)
                            ucServList.add(uceServList.get(i));
                        
                        if(ucServList!=null && ucServList.size()>0){
                            ServiceSpecificationUtils.updateUCNumberSpecNumberStatus(new List<Id>(new Map<Id, csord__service__c>(ucServList).keySet()));
                        }
                        //end EDGE-81250
                    }    
                } 
                // system.debug('checkStatusmetyhid='+checkUCCompletion(JSON.serialize(paramsUC),notificationId,simpleChars  ));
                //EDIS call commented for EDGE-113553
                
                if(checkUCCompletion(JSON.serialize(paramsUC),notificationId,simpleChars,srvspecList,notificationAttr, orderItemIdc,childAttr)){
                    List<csord__Order__c> orderids = [Select Id from csord__Order__c where csord__Order_Number__c =:orderId  Or csord__Primary_Order__r.csord__Order_Number__c=:orderId FOR Update];
                    if(orderids!=null && orderids.size()>0){
                        //EDISSingleManager.processEDISOrderCompletion(orderids[0].Id,srvcNumber); 
                    }
                }
                
                if(checkMobileAccessCompletion(JSON.serialize(paramsUC),notificationId,simpleCharsMobile,srvspecList,notificationAttr,orderItemIdc)){
                    /* List<csord__Order__c> orderids = [Select Id from csord__Order__c where csord__Order_Number__c =:orderId  Or csord__Primary_Order__r.csord__Order_Number__c=:orderId for Update];
if(orderids!=null && orderids.size()>0){

EDISSingleManager.processEDISOrderCompletion(orderids[0].Id,srvcNumber);
}*/
                } 
                
                
            }
        }
        catch(Exception e){
            System.debug('Exception:'+ e.getTypeName() + ',' + e.getMessage() +','+  e.getLineNumber());
        }
    }
    
    
    public static Boolean checkUCCompletion(String parameters, String notificationId, List<CS_SpecificationDTO.ComplexAttributes> simpleChars,List<CS_SpecificationDTO.ServiceSpecification> specBody,String notificationAttr,String orderItemIdc,List<String> childAttr ){
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        //Notification__c notif = [Select Id,Name,Status__c,Internal_Error_Description__c from Notification__c where Id =: notificationId];
        system.debug('parameters--->'+parameters);
        system.debug('parameters--->'+notificationId);
        system.debug('parameters--->'+simpleChars);
        system.debug('parameters--->'+specBody);
        system.debug('parameters--->'+notificationAttr);
        system.debug('parameters--->'+orderItemIdc);
        system.debug('parameters--->'+childAttr);
        
        try{
            String orderId = null ; String srvcNumber = null; String instanceId = null;
            Boolean stopprocessing = false;
            List<String> keyparams = orderItemIdc.split('\\|');
            if(keyparams.size() > 0){ orderId = keyparams[0]; }
            if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }
            if(keyparams.size() > 2){ instanceId = keyparams[2]; }
            if(srvcNumber == null || orderId == null || instanceId == null){ stopprocessing = true;
                                                                           }
            String status = '';
            Boolean checkStatus = false;
            Boolean tobecancel = false;
            List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,Forecasted_Delivery_Date__c,csordtelcoa__Product_Configuration__c,CreatedDate,toBeCancelled__c,
                                                   (Select Id, Name,GUID__c, Service__c FROM Service_Specifications__r)
                                                   FROM csord__Service__c
                                                   WHERE csordtelcoa__Service_Number__c=:srvcNumber for update];
            for(csord__Service__c ser :serviceList)     
            {
                if(ser.toBeCancelled__c == 'true') tobecancel = true;
            }
            if(!stopprocessing){
                
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                System.debug('notifyAttrs:::' + notifyAttrs);
                
                for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){
                    if(attr.name.contains('status') && attr.value == Label.Complete){
                        status  = 'Complete';   
                    }
                    else if(attr.name.contains('status') && attr.value == 'In Progress'){
                        status  = 'In Progress';   
                    }
                    
                }
                
                system.debug('status='+status);   
                List<Service_Specification__c> serSpecifications = new List<Service_Specification__c>();
                List<Service_Specification__c> SerSpecificationsList = new List<Service_Specification__c>();
                
                //EDGE-81250 start
                serviceList=(List<csord__Service__c>)CustomSortUtility.customSort(serviceList,'createddate','DateTime'); //list in ascending order
                //end EDGE-81250
                //OrderidNumber =  serviceList[0].csord__Order__r.id; 
                NumberNCSHelper ncs = new NumberNCSHelper();
                List<String> rootConfigId = new List<String>();
                
                //EDGE-132208 Added to remove Attachment Query from for loop.
                for(csord__Service__c srv :  serviceList){
                    rootConfigId.add(srv.csordtelcoa__Product_Configuration__c);
                }
                System.debug('rootConfigId'+rootConfigId);   
                Map<String, List<Attachment>> attachmentMap = new Map<String, List<Attachment>>();
                if(rootConfigId.size() > 0){
                    List<Attachment> attList = new List<Attachment>();
                    attList = [select Id,Body,ParentId FROM Attachment WHERE ParentId In: rootConfigId and Name like '%NumberManagementv1%'];
                    for (Attachment att : attList) {
                        if (attachmentMap.containsKey(att.ParentId)) {
                            attachmentMap.get(att.ParentId).add(att);
                        } else {
                            attachmentMap.put(att.ParentId, new List<Attachment>{att});
                        }
                    }
                }
                //collect all info for OE
                List<NumberNCSDTO.Configuration> numberListold = new List<NumberNCSDTO.Configuration>();
                Map<String,List<NumberNCSDTO.Configuration>> configIdToNumberList = new Map<String,List<NumberNCSDTO.Configuration>>();
                for (String configId : rootConfigId) {
                    if (!attachmentMap.containsKey(configId)) {
                        continue;
                    }
                    //we have attachments so add PC and initialize configIdToNumberList for it
                    configIdToNumberList.put(configId, new List<NumberNCSDTO.Configuration>());
                    for (attachment att : attachmentMap.get(configId)) {
                        String jsonStr = att.body.toString();
                        system.debug('jsonStr ==' + jsonStr);
                        NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                        for (NumberNCSDTO.Configuration config : ncsDTO.configurations) {
                            if (config.status == Label.NumberStatus_DISCONNECT_PENDING) {
                                config.status = Label.NumberStatus_DISCONNECT_IN_PROGRESS;
                            }else if(config.status == Label.NumberStatus_DISCONNECT_IN_PROGRESS){
                                config.status = Label.NumberStatus_DISCONNECTED;
                            }
                            numberListold.add(config);
                        }
                        System.debug('Updated Attachment'+numberListold);
                        configIdToNumberList.get(configId).addAll(numberListold);
                        System.debug('Updated AttachmentList'+configIdToNumberList);
                    }
                }
                //EDGE-136242 - Added below condition to avoid calling existing code in case of NGUC. - Part of 575 refactoring
                Map<String, csord__Service__c> srvMap = new Map<String, csord__Service__c>();
                List<String> subNumList = new List<String>();
                List<String> ProductCodeList = new List<String>();
                for(csord__Service__c srv :  serviceList){
                    subNumList.add(srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c);
                }
                for(CS_SpecificationDTO.ServiceSpecification srvSpec : specBody){
                    ProductCodeList.add(srvSpec.code.removeEnd('_Fulfilment'));
                }
                system.debug('ProductCodeList--'+ProductCodeList);
                system.debug('serviceList--'+serviceList);
                boolean processStatus = false;
                //EDGE-136242 - Added below condition to avoid calling existing code in case of NGUC. - Part of 575 refactoring
                //Below code is existing code contains SOQL in for loop & Munich team will refactor this code later.
                if(ProductCodeList.contains('DMCAT_ProductSpecification_000322') || ProductCodeList.contains('DMCAT_ProductSpecification_000312')){
                    for(csord__Service__c srv :  serviceList){
                        for(CS_SpecificationDTO.ServiceSpecification srvSpec : specBody)
                        {
                            system.debug('srvSpec ='+srvSpec );  
                            //EDGE-132208 - Added NGUC product code check and ProcessStatus.
                            //EDGE-136242 - Removed NGUC Product check for Refactoring
                            if((instanceId == srvSpec.guid) && ((srvSpec.code == 'DMCAT_ProductSpecification_000322_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000312_Fulfilment')) && status =='Complete'){
                                ncs.updateNCSForStatus(srv.csordtelcoa__Product_Configuration__c);
                                checkStatus = true;
                                if(tobecancel != true){
                                    NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Provisioned');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                }
                                else{NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Disconnected');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                }
                                processStatus = true;
                            }else 
                            //EDGE-132208 - Added NGUC product code check
                            //EDGE-136242 - Removed NGUC Product check for Refactoring
                            if((instanceId == srvSpec.guid) && ((srvSpec.code == 'DMCAT_ProductSpecification_000322_Fulfilment') || (srvSpec.code == 'DMCAT_ProductSpecification_000312_Fulfilment'))&& status =='In Progress')
                            {
                                if(tobecancel != true){
                                    NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Provisioning In Progress');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                }
                                else{NumberUtil.UpdateNumberStatus(srvSpec.code,srv.csord__Subscription__r.csordtelcoa__Subscription_Number__c,'Disconnect In Progress');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                                } 
                                processStatus = true;
                            }
                        } 
                    }
                }
                //EDGE-136242 - Added below code to bulkify NumberUtil call for NGUC Number Management.
                Map<String, List<Number__C>> NumberMap = new Map<String, List<Number__C>>();
                List<Number__C> updatedNumList = new List<Number__C>();
                if((ProductCodeList != null || ProductCodeList.size() > 0) && (subNumList != null || subNumList.size() > 0)){
                    if(ProductCodeList.contains('DMCAT_ProductSpecification_000871')){
                        if(status == 'Complete'){
                            if(tobecancel != true){
                                NumberUtil.UpdateNumberStatusBulkified(ProductCodeList, subNumList, 'Provisioned');
                            }else{
                                NumberUtil.UpdateNumberStatusBulkified(ProductCodeList, subNumList, 'Disconnected');
                            }
                        }else if(status == 'In Progress'){
                            if(tobecancel != true){
                                NumberUtil.UpdateNumberStatusBulkified(ProductCodeList, subNumList, 'Provisioning In Progress');
                            }else{
                                NumberUtil.UpdateNumberStatusBulkified(ProductCodeList, subNumList, 'Disconnect In Progress');
                            }
                        }
                        processStatus = true;
                    }
                }
                //EDGE-132208 - Added to Sync Status to NCS.
                System.debug('rootConfigId'+rootConfigId);
                System.debug('configIdToNumberList'+configIdToNumberList);
                ncs.updateExistingNCSbulk(rootConfigId, 'NumberManagementv1', configIdToNumberList);
                // EDGE-136242 End
                return processStatus;
            }
            return false;
        }catch(Exception e) {
            System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());return false;  }
    }
    
    public static Boolean checkMobileAccessCompletion(String parameters, String notificationId, List<CS_SpecificationDTO.ComplexAttributes> simpleCharsMobile,List<CS_SpecificationDTO.ServiceSpecification> specBody,String notificationAttr,String orderItemIdc){
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        //Notification__c notif = [Select Id,Name,Status__c,Internal_Error_Description__c from Notification__c where Id =: notificationId];
        try{
            String orderId = null ; String srvcNumber = null; String instanceId = null;
            Boolean stopprocessing = false;
            Boolean tobecancel = false;
            String subNumber;
            List<String> keyparams = orderItemIdc.split('\\|');
            if(keyparams.size() > 0){ orderId = keyparams[0]; }
            if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }
            if(keyparams.size() > 2){ instanceId = keyparams[2]; }
            if(srvcNumber == null || orderId == null || instanceId == null){stopprocessing = true;
                                                                           }
            
            String status = ''; Boolean checkStatus = false;
            if(!stopprocessing){
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                System.debug('notifyAttrs:::' + notifyAttrs);
                
                for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){
                    if(attr.name.contains('status') && attr.value == Label.Complete){status  = 'Complete';}
                    else if(attr.name.contains('status') && attr.value == 'In Progress'){
                        status  = 'In Progress';   
                    }
                }
                system.debug('status='+status);      
                
                
                List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,Forecasted_Delivery_Date__c,CreatedDate,toBeCancelled__c,
                                                       (Select Id, Name,GUID__c, Service__c FROM Service_Specifications__r)
                                                       FROM csord__Service__c
                                                       WHERE csordtelcoa__Service_Number__c=:srvcNumber for Update];
                for(csord__Service__c ser :serviceList)     
                {
                    if(ser.toBeCancelled__c == 'true') tobecancel = true;
                    subNumber=ser.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
                }
                serviceList=(List<csord__Service__c>)CustomSortUtility.customSort(serviceList,'createddate','DateTime');
                //OrderidNumber =  serviceList[0].csord__Order__r.id;                                          
                for(CS_SpecificationDTO.ServiceSpecification srvSpec : specBody)
                {
                    if((instanceId == srvSpec.guid) && (srvSpec.code == 'DMCAT_ProductSpecification_000263_Fulfilment'||srvSpec.code =='DMCAT_ProductSpecification_000420_Fulfilment') && status =='Complete')
                    {
                        if(tobecancel != true){
                            NumberUtil.UpdateNumberStatus(srvSpec.code,subNumber,'Provisioned');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                        }
                        else{NumberUtil.UpdateNumberStatus(srvSpec.code,subNumber,'Disconnected');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                            }
                        return true;
                    }else if((instanceId == srvSpec.guid) && (srvSpec.code == 'DMCAT_ProductSpecification_000263_Fulfilment'||srvSpec.code =='DMCAT_ProductSpecification_000420_Fulfilment') && status.containsIgnoreCase('In Progress'))
                    {
                        if(tobecancel != true){
                            NumberUtil.UpdateNumberStatus(srvSpec.code,subNumber,'Provisioning In Progress');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                        }
                        else{NumberUtil.UpdateNumberStatus(srvSpec.code,subNumber,'Disconnect In Progress');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                            } 
                        
                    }
                }
            }
            return false;      
        }catch(Exception e) {
            System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());  return false;
        }
    }   
    
    
    
    @TestVisible
    private static void updateServiceRecord(List<String> parameters,String notificationId){
        Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
        List<String> orderNumbers = new List<String>();
        List<id> orderIdList = new List<Id>();
        Notification__c notif = [Select Id,Name,Status__c,Internal_Error_Description__c from Notification__c where Id =: notificationId];
        String eventsrvcNumber;
        List<String>guidList= new List<String>();String orderItemIdc;String notificationAttr;String orderItemDetails;String eventType;Boolean stopprocessing = false;String notifStatus='';
        List<String> keyparams = new List<String>();
        String orderId; String srvcNumber; String instanceId;Boolean isSuspendResume=false;
        
        try{
            for(String parameterString: parameters){
                system.debug('parameterString'+parameterString);
                ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
                params = (ManageOrderNotificationUtil.Parameters) JSON.deserialize(parameterString, ManageOrderNotificationUtil.Parameters.class);
                parameterMap.put(params.orderIdc, params);
                orderNumbers.add(params.orderIdc.split('\\|')[0]);
            }
            System.debug('parameterMap::'+parameterMap);
            Map<Id, csord__Service__c> srvcListtoUpdate = new Map<Id, csord__Service__c>();
            String subscriptionId = '';
            String primaryOrderId = '';
            
            List<csord__Order__c> orderList = [SELECT id,Name, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE csord__Order_Number__c IN:orderNumbers Or csord__Primary_Order__r.csord__Order_Number__c IN: orderNumbers for update];
            orderList=(List<csord__Order__c>)CustomSortUtility.customSort(orderList,'createddate','DateTime');
            for(csord__Order__c ord : orderList){
                orderIdList.add(ord.id);
                primaryOrderId = ord.id;
                if(ord.Name.containsIgnoreCase('Resume') || ord.Name.containsIgnoreCase('Suspend') )
                {
                    isSuspendResume=true;
                }
            }
            List<csord__Service__c> srvcList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.id , csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate,Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Order__r.csordtelcoa__Opportunity__c ,csord__Subscription__r.Suspension_reason__c,csord__Service__c,csord__Subscription__r.csord__Status__c,csord__Order__r.Name,csord__Order__r.csord__Status2__c  FROM csord__Service__c WHERE csord__Order__r.id IN:orderIdList FOR UPDATE];
            List<Id> allServiceId = new List<id>();
            Map<String, csord__Service__c> serviceMap = new Map<String, csord__Service__c>();
            Map<String, csord__Service__c> serviceMapWithId = new Map<String, csord__Service__c>();
            Set<String> orderIds = new Set<String>();
            Set<String> replacedSubscriptionIds = new Set<String>();
            Map<String, String> serviceAttachmentMap = new Map<String, String>();
            Map<String,Attachment> servAttachmentRecordMap = new Map<String,Attachment>();
            List<Id> ReplacedsubscrpList =  new List<Id>();
            Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
            for(csord__Service__c svc: srvcList){
                orderIds.add(svc.csord__Order__r.id);
                allServiceId.add(svc.id);
                replacedSubscriptionIds.add(svc.ReplacedSubscription__c);
                serviceMap.put(svc.csordtelcoa__Service_Number__c, svc);
                serviceMapWithId.put(svc.Id,svc);
                if(svc.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c != null &&  svc.csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c == null)
                    ReplacedsubscrpList.add(svc.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c);
            }
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :allServiceId for update]){
                servAttachmentRecordMap.put(att.parentId,att);
                serviceAttachmentMap.put(att.parentId,att.body.toString());}
            system.debug('serviceAttachmentMap::'+serviceAttachmentMap.values());
            list<csord__Service__c> ReplacedserviceSubsList =  [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.id , csord__Order_Request__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate,Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c  WHERE  csord__Subscription__c IN :ReplacedsubscrpList FOR UPDATE];
            for(csord__Service__c svc: ReplacedserviceSubsList){serviceMap.put(svc.csordtelcoa__Service_Number__c, svc);serviceMapWithId.put(svc.Id,svc);
                                                               }
            
            System.debug('orderIds::'+orderIds);
            System.debug('replacedSubscriptionIds::'+replacedSubscriptionIds);
            System.debug('serviceMap::'+serviceMap);
            
            
            //for every notification update specs
            srvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            for(String eachService: serviceAttachmentMap.keySet()){
                srvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),FULFILMENT));
            }
            system.debug('srvspecList::'+srvspecList);
            Map<String, CS_SpecificationDTO.ServiceSpecification> serviceSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
            serviceSpecMap = getallOrderSpecs(srvspecList);
            for(String key: parameterMap.keySet()){
                ManageOrderNotificationUtil.Parameters updates = parameterMap.get(key);
                orderItemIdc = updates.orderIdc ;
                notificationAttr = updates.notifyAttributes;
                system.debug('notificationAttr'+notificationAttr);
                orderItemDetails = updates.orderItemDetails;
                eventType = updates.eventType;
                keyparams = orderItemIdc.split('\\|');
                
                if(!keyparams.isEmpty()){ orderId = keyparams[0]; }
                if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }
                if(keyparams.size() > 2){ instanceId = keyparams[2]; }
                
                eventsrvcNumber=srvcNumber;
            } 
            
            ManageOrderNotificationUtil.NotificationAttributesDataObject notifAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
            for(ManageOrderNotificationUtil.NotificationAttributes attr: notifAttrs.attributes){
                if(attr.name.contains('status') && attr.value == Label.Complete){
                    notifStatus  = 'Complete';   
                }
                else if(attr.name.contains('status') && attr.value == 'In Progress'){
                    notifStatus  = 'In Progress';   
                }
            }
            system.debug('notifStatus'+notifStatus);
            String currentSpecStatus;
            ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse(orderItemDetails);
            System.debug('productUpdates::'+productUpdates);
            Map<String, String> specToUpdatedStatusMap = new Map<String, String>();
            specToUpdatedStatusMap.put(productUpdates.productId, productUpdates.status);
            specToUpdatedStatusMap.putAll(getChildProducts(productUpdates));
            guidList.addAll(specToUpdatedStatusMap.keySet());
            system.debug('Adding to guidList:::'+guidList); 
            System.debug('specToUpdatedStatusMap::'+specToUpdatedStatusMap);
            //if notification type is error update service specs
            if(eventType == 'error' && !serviceMap.isEmpty() && String.isNotEmpty(orderItemDetails)){
                /*ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
for(ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes){
if(attr.name.contains(STATUS)){
csedm.API_1.updateServiceSpecificationPropertyById(serviceMap.get(srvcNumber).Id, instanceId, STATUS, Label.MO_Acknowledge_fail_status);
}
}*/
                Set<Id> serviceIds = new Set<Id>();
                Map<String, String> replacedSpecToUpdatedStatusMap = new Map<String, String>();
                
                if(!specToUpdatedStatusMap.isEmpty()){
                    specMapUpdateErrorStatus(specToUpdatedStatusMap, replacedSpecToUpdatedStatusMap, serviceSpecMap, serviceIds,serviceAttachmentMap,servAttachmentRecordMap);
                }
                /* if(!replacedSpecToUpdatedStatusMap.isEmpty()){
replacedSpecMapUpdateErrorStatus(replacedSubscriptionIds, replacedSpecToUpdatedStatusMap, serviceIds);
}*/
                srvcListtoUpdate.put(serviceMap.get(srvcNumber).Id, serviceMap.get(srvcNumber));
                List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, CreatedDate,csord__Subscription__c,csord__Order__r.Name,csord__Subscription__r.csord__Status__c from csord__Service__c where Id IN: serviceIds FOR UPDATE];
                for(csord__Service__c srv: serviceList) srvcListtoUpdate.put(srv.Id, srv);
            }
            
            //if notification type is statusNotification update service specs
            if(eventType == 'statusNotification' || eventType == 'delay' && !serviceMap.isEmpty() && String.isNotEmpty(orderItemDetails)){
                //update the specs as per status update recieved
                
                //update the specs as per status update recieved
                
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                Map<String,String> additionalAttrs = new Map<String,String>();
                Map<String,String> existingAdditionalAttrs = new Map<String,String>();
                Map<String,String> dateAdditionalAttrs = new Map<String,String>();
                Datetime forecastedDate = NULL;
                Datetime committedDate = NULL;
                //EDGE : 99309 ::Added
                String tenancyId;
                System.debug('specToUpdatedStatusMap::'+specToUpdatedStatusMap);
                //List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serviceMap.get(srvcNumber).Id),FULFILMENT);
                
                for(CS_SpecificationDTO.ServiceSpecification specs: srvspecList){
                    additionalAttrs = new Map<String,String>();
                    existingAdditionalAttrs = new Map<String,String>();
                    dateAdditionalAttrs = new Map<String,String>();
                    if(specToUpdatedStatusMap.containsKey(specs.guid)){
                        currentSpecStatus = specs.status;
                        System.debug('currentSpecStatus::'+currentSpecStatus);
                        if(currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(specs.guid).contains(Label.Complete)){
                            specToUpdatedStatusMap.put(specs.guid, Label.MO_status_disconnected);
                            system.debug('before update att ' + (serviceAttachmentMap.get(specs.serviceId)));
                            String udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                            
                            Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                            system.debug('udtattbody ' + udtattbody);
                            att.body = Blob.valueOf(udtattbody);
                            //update att;
                            serviceAttachmentMap.put(att.parentId,att.Body.toString());
                            updatedAttSet.put(att.id,att);
                            //csedm.API_1.updateServiceSpecificationPropertyById(specs.serviceId, specs.guid, STATUS, Label.MO_status_disconnected);
                            system.debug('specstatusmap-->'+specToUpdatedStatusMap.get(specs.guid));
                            system.debug('guid-->'+specs.guid);
                        }else if(currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(specs.guid).contains('In Progress')){
                            specToUpdatedStatusMap.put(specs.guid, 'Disconnect In Progress');
                            system.debug('before update att ' + (serviceAttachmentMap.get(specs.serviceId)));
                            String udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                            
                            Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                            system.debug('udtattbody ' + udtattbody);
                            att.body = Blob.valueOf(udtattbody);
                            //update att;
                            serviceAttachmentMap.put(att.parentId,att.Body.toString());
                            updatedAttSet.put(att.id,att);
                        }else if(currentSpecStatus.contains('Suspend') && specToUpdatedStatusMap.get(specs.guid).contains('In Progress')){ //EDGE-125635 -updating service spec status in case of suspend - In progress
                            
                            specToUpdatedStatusMap.put(specs.guid, system.label.subscription_Suspended_Status);
                            system.debug('before update att ' + (serviceAttachmentMap.get(specs.serviceId)));
                            String udtattbody =csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));                         
                            Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                            att.body = Blob.valueOf(udtattbody);
                            serviceAttachmentMap.put(att.parentId,att.Body.toString());
                            updatedAttSet.put(att.id,att);
                            
                        }else if(currentSpecStatus.contains(system.label.subscription_Suspended_Status) && specToUpdatedStatusMap.get(specs.guid).contains(Label.Complete)){ //EDGE-125635 -updating service spec status in case of suspend - Complete
                            
                            specToUpdatedStatusMap.put(specs.guid, system.label.subscription_Suspended_Status);
                            system.debug('before update att ' + (serviceAttachmentMap.get(specs.serviceId)));
                            String udtattbody =csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));                         
                            Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                            att.body = Blob.valueOf(udtattbody);
                            serviceAttachmentMap.put(att.parentId,att.Body.toString());
                            updatedAttSet.put(att.id,att);
                            
                        }else{
                            system.debug('before update att ' + (serviceAttachmentMap.get(specs.serviceId)));
                            String udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                            
                            Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                            system.debug('udtattbody ' + udtattbody);
                            att.body = Blob.valueOf(udtattbody);
                            //update att;
                            serviceAttachmentMap.put(att.parentId,att.Body.toString());
                            updatedAttSet.put(att.id,att);
                            
                        }
                        
                        for(CS_SpecificationDTO.SimpleAttributes simpleAttr : specs.additionalAttributes) {
                            existingAdditionalAttrs.put(simpleAttr.name,simpleAttr.value);
                            existingAdditionalAttrs.remove('currentForecastedDeliveryDate');
                            existingAdditionalAttrs.remove('telstraCommittedDate');
                        }
                        for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){
                            if(currentSpecStatus =='In Progress'){
                                if(attr.name.contains('currentForecastedDeliveryDate') || attr.name.contains('current Forecasted Delivery Date')){dateAdditionalAttrs.put(attr.name,attr.value); forecastedDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);}
                                else if(attr.name.contains('telstraCommittedDate') || attr.name.contains('telstra Committed Date')){dateAdditionalAttrs.put(attr.name,attr.value);committedDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);}
                                //EDGE : 99309 ::Added
                                if(existingAdditionalAttrs.containsKey('TenancyID')) {tenancyId = existingAdditionalAttrs.get('TenancyID');}} }
                        additionalAttrs.putAll(existingAdditionalAttrs);
                        additionalAttrs.putAll(dateAdditionalAttrs);            
                        //csedm.API_1.addCharacteristic(serviceMap.get(srvcNumber).Id, specs.guid,additionalAttrs);
                        String bodyAdditionalAttr = ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(serviceAttachmentMap.get(specs.serviceId),specs.guid,additionalAttrs);
                        Attachment attAdd = servAttachmentRecordMap.get(specs.serviceId);
                        
                        attAdd.body = Blob.valueOf(bodyAdditionalAttr);
                        //update att;
                        serviceAttachmentMap.put(attAdd.parentId,attAdd.Body.toString());
                        updatedAttSet.put(attAdd.id,attAdd);
                        csord__Service__c ser = serviceMap.get(srvcNumber);
                        
                        if(serviceMap.get(srvcNumber).Forecasted_Delivery_Date__c == NULL || serviceMap.get(srvcNumber).Forecasted_Delivery_Date__c < forecastedDate)
                            ser.Forecasted_Delivery_Date__c = forecastedDate;
                        if(serviceMap.get(srvcNumber).Telstra_Committed_Date__c == NULL || serviceMap.get(srvcNumber).Telstra_Committed_Date__c < committedDate)
                            ser.Telstra_Committed_Date__c = committedDate;
                        //EDGE : 99309 ::Added
                        if(String.isNotBlank(tenancyId)){ser.Tenancy_Id__c = tenancyId;}
                        
                        //srvcListtoUpdate.put(ser.Id,ser);
                        srvcListtoUpdate.put(specs.serviceId,serviceMapWithId.get(specs.serviceId));
                        System.debug('specToUpdatedStatusMap::'+specToUpdatedStatusMap);
                        System.debug('specToUpdatedStatusMapValue::'+specToUpdatedStatusMap.get(specs.guid));
                        System.debug('Values++++++'+specs.serviceId+'___'+specs.guid);
                        specToUpdatedStatusMap.remove(specs.guid);
                    }
                }
                //srvcListtoUpdate.put(serviceMap.get(srvcNumber).Id, serviceMap.get(srvcNumber));
                System.debug('srvcListtoUpdate.put::::'+srvcListtoUpdate);
                system.debug('checking if anything is remaining ' + specToUpdatedStatusMap);
                
                //if there are any remaining updates fetch it from the order and update it
                if(!specToUpdatedStatusMap.isEmpty()){
                    Id ordId = serviceMap.get(srvcNumber).csord__Order__r.csordtelcoa__Opportunity__c;
                    System.debug('orderReq:::'+ordId);
                    Map<String, CS_SpecificationDTO.ServiceSpecification> allspecMap = serviceSpecMap;
                    System.debug('specToUpdatedStatusMap::'+specToUpdatedStatusMap);
                    //System.debug('allspecMap::'+allspecMap);
                    Set<Id> serviceIds = new Set<Id>();
                    for(String guid: specToUpdatedStatusMap.keySet()){
                        CS_SpecificationDTO.ServiceSpecification specs = allspecMap.get(guid);
                        currentSpecStatus = specs.status;
                        System.debug('currentSpecStatus22::'+currentSpecStatus);
                        if(currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(specs.guid).contains(Label.Complete)){
                            specToUpdatedStatusMap.put(specs.guid, Label.MO_status_disconnected);
                        }
                        String udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', specToUpdatedStatusMap.get(specs.guid));
                        Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                        system.debug('udtattbody ' + udtattbody);
                        att.body = Blob.valueOf(udtattbody);
                        //update att;
                        serviceAttachmentMap.put(att.parentId,att.Body.toString());
                        updatedAttSet.put(att.id,att);
                        
                        additionalAttrs.clear();
                        existingAdditionalAttrs.clear();
                        for(CS_SpecificationDTO.SimpleAttributes simpleAttr : specs.additionalAttributes) {
                            existingAdditionalAttrs.put(simpleAttr.name,simpleAttr.value);existingAdditionalAttrs.remove('currentForecastedDeliveryDate');existingAdditionalAttrs.remove('telstraCommittedDate');  
                        }
                        additionalAttrs.putAll(existingAdditionalAttrs); additionalAttrs.putAll(dateAdditionalAttrs);
                        csedm.API_1.addCharacteristic(specs.serviceId, specs.guid,additionalAttrs); serviceIds.add(specs.serviceId);
                        specToUpdatedStatusMap.remove(specs.guid);}
                    //EDGE : 99309 ::Modified
                    List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Order__c,csord__Order__r.csord__Status2__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, CreatedDate,Forecasted_Delivery_Date__c,Telstra_Committed_Date__c,csord__Subscription__c, Tenancy_Id__c,csord__Subscription__r.Suspension_reason__c,csord__Service__c,csord__Subscription__r.csord__Status__c,csord__Order__r.Name  from csord__Service__c where Id IN: serviceIds FOR UPDATE];
                    for(csord__Service__c srv: serviceList){
                        if(srv.Forecasted_Delivery_Date__c < forecastedDate || srv.Forecasted_Delivery_Date__c == NULL)
                        {srv.Forecasted_Delivery_Date__c = forecastedDate;}
                        if(srv.Telstra_Committed_Date__c < committedDate || srv.Telstra_Committed_Date__c == NULL)
                        {srv.Telstra_Committed_Date__c = committedDate;}
                        if(String.isNotBlank(tenancyId)) //EDGE : 99309 ::Added
                        {srv.Tenancy_Id__c = tenancyId;}
                        srvcListtoUpdate.put(srv.Id, srv);}}               
            }
            if(!updatedAttSet.isEmpty()){update updatedAttSet.values();}
            //for every service update status
            String subStageStatus = NULL; List<csord__Subscription__c> subs=new List<csord__Subscription__c>(); Map<Id, csord__Subscription__c> subMap= new Map<Id, csord__Subscription__c>();Map<Id, csord__Order__c> ordMap= new Map<Id, csord__Order__c>();
            List<CS_SpecificationDTO.ServiceSpecification> updatedSrvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            for(String eachService: serviceAttachmentMap.keySet()){updatedSrvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),FULFILMENT));
                                                                  }
            system.debug('notifStatus'+notifStatus);
            for(csord__Service__c svc: srvcListtoUpdate.values())
            {
                String status = calculateServiceStatus(svc.Id,updatedSrvSpecList);
                system.debug('notifStatus'+notifStatus);
                if(!String.isEmpty(status)){
                    if(status.containsIgnoreCase('Suspended')) //EDGE-91568 - Update parent service status as Suspended if status contains Suspended value
                    {
                        if(notifStatus.containsIgnoreCase('In Progress'))
                        {
                            if(svc.csord__Service__c==null)
                            {
                                svc.csord__Status__c ='In Progress'; 
                                svc.csord__Subscription__r.csord__Status__c = 'Provisioning In Progress';
                                svc.csord__Order__r.csord__Status2__c='In Progress';  //update subscription status as Suspended in Suspend Scenario
                            }else
                            {
                                svc.csord__Status__c = 'Connected';  
                                svc.csord__Subscription__r.csord__Status__c = 'Provisioning In Progress';
                                svc.csord__Order__r.csord__Status2__c='In Progress';   //update subscription status as Suspended in Suspend Scenario
                            }
                        }else if(notifStatus.containsIgnoreCase('Complete'))
                        {
                            if(svc.csord__Service__c==null)
                            {
                                svc.csord__Status__c = status; 
                                svc.csord__Subscription__r.csord__Status__c = 'Suspended';
                                svc.csord__Order__r.csord__Status2__c='Completed';  //update subscription status as Suspended in Suspend Scenario
                            }else
                            {
                                svc.csord__Status__c = 'Connected';  
                                svc.csord__Subscription__r.csord__Status__c = 'Suspended';
                                svc.csord__Order__r.csord__Status2__c='Completed';   //update subscription status as Suspended in Suspend Scenario
                            }
                            
                            
                        }
                        
                    }else if(svc.csord__Order__r.Name.containsIgnoreCase('Resume'))
                    {
                        System.debug('insidejshjag');
                        if(notifStatus.containsIgnoreCase('In Progress'))
                        {
                            svc.csord__Subscription__r.csord__Status__c = 'Provisioning In Progress'; 
                            svc.csord__Status__c = status;
                            svc.csord__Order__r.csord__Status2__c='In Progress';
                        }else if(notifStatus.containsIgnoreCase('Complete'))
                        {
                            svc.csord__Subscription__r.csord__Status__c = 'Active'; 
                            svc.csord__Status__c = status;
                            svc.csord__Order__r.csord__Status2__c='Completed';
                        }
                    }
                    else
                    {
                        svc.csord__Status__c = status;
                    }
                    subStageStatus = status;
                    subscriptionId = svc.csord__Subscription__c;
                    if(status.containsIgnoreCase('Disconnected'))
                    {
                        svc.substage__c = 'Complete';svc.stage__c = 'Closed';
                      }else if(status.containsIgnoreCase('Connected')) 
                      {
                        svc.substage__c = 'Product Completion Notice';
                        svc.stage__c = 'Closed';
                      }
                    srvcListtoUpdate.put(svc.Id,svc);
                    subs.add(svc.csord__Subscription__r);
                    subMap.put(svc.csord__Subscription__c,svc.csord__Subscription__r);
                    System.debug('subMap:::1'+subMap);
                    ordMap.put(svc.csord__Order__c,svc.csord__Order__r);
                    System.debug('ordMap:::1'+ordMap);
                }
            }
            if(!srvcListtoUpdate.isEmpty()){
                System.debug('srvcListtoUpdate:::'+srvcListtoUpdate);
                update srvcListtoUpdate.values();
                if(!subMap.isEmpty())
                {
                    update subMap.values();
                    System.debug('subMap:::'+subMap);
                }
                if(!ordMap.isEmpty())
                {
                    update ordMap.values();
                    System.debug('ordMap:::'+ordMap);
                }
                
                if(subStageStatus != null && subStageStatus.containsIgnoreCase('Connected')) {
                    System.debug('UpdateSubandOrder:::');
                    ManageSubStageNotification.updateSubscriptions(subscriptionId,'stage');
                    ManageSubStageNotification.updateOrder(primaryOrderId);
                }
            }
            
            notif.Status__c = 'Completed';
            system.debug('guidList:::'+guidList); 
            
            InvokeInventoryPublishEvents.publishServiceSpecificationHandler(eventsrvcNumber,guidList);
            
            // EDGE-113552
            Map<Id, String> ordStatusMap = new Map<Id, String>();
            for(id ordr: orderIdList){
                ordStatusMap.put(ordr,'Success');
            }
            if(!isSuspendResume)
            {
                ManageOrderAcknowledgeHandler.processAcknowledgements(ordStatusMap);
            }
            
        }
        
        catch(Exception e){
            notif.Status__c = 'Error';
            notif.Internal_Error_Description__c = e.getTypeName() +','+e.getMessage() +','+  e.getLineNumber();
        }
        //update notif;
    }
    
    
    @TestVisible
    private static void updateSubscriptionRecord(List<String> parameters,String notificationId){
        system.debug('parameters=='+parameters);
        Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
        List<String> eventIds = new List<String>();
        Notification__c notif = [Select Id,Name,Status__c,Internal_Error_Description__c from Notification__c where Id =: notificationId for update];
        try{  
            for(String parameterString: parameters){
                ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
                params = (ManageOrderNotificationUtil.Parameters) JSON.deserialize(parameterString, ManageOrderNotificationUtil.Parameters.class);
                parameterMap.put(params.orderIdc, params);
                eventIds.add(params.orderIdc);
            }
            system.debug('eventIds=='+eventIds);
            System.debug('parameterMap::'+parameterMap);
            List<csord__Subscription__c> subsListtoUpdate = new List<csord__Subscription__c>();
            
            List<csord__Subscription__c> subsList = [SELECT Id, Name,Sub_status__c,eventId__c,csord__Status__c,Suspension_reason__c,CreatedDate,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE eventId__c IN:eventIds for update ];
            subsList=(List<csord__Subscription__c>)CustomSortUtility.customSort(subsList,'createddate','DateTime'); //list in ascending order
            
            Map<String, csord__Subscription__c> subscriptionMap = new Map<String, csord__Subscription__c>();
         
            for(csord__Subscription__c sub: subsList){
                subscriptionMap.put(sub.eventId__c, sub);
             
            }
            
             //commented code as part of EDGE-124711/EDGE-124029
            //EDGE-120128 - start
           /* Map<Id,List<Price_Schedule_Line_Item__c>> mapSubsPSLI=new Map<Id,List<Price_Schedule_Line_Item__c>>();
           
            List<Price_Schedule_Line_Item__c> PSLIList=new List<Price_Schedule_Line_Item__c>();
            for(Price_Schedule_Line_Item__c psli : [select id,chargeInstance__c,fromPeriod__c,priority__c,status__c,toPeriod__c,unitPrice__c,chargeInstance__r.serviceId__r.csord__Subscription__c from Price_Schedule_Line_Item__c where chargeInstance__r.serviceId__r.csord__Subscription__r.Id IN :subsList])
            {
               if(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id!=null){
               if(mapSubsPSLI.containsKey(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id))
                {
                    List<Price_Schedule_Line_Item__c> lstPSLI = mapSubsPSLI.get(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id);
                    lstPSLI.add(psli);
                    mapSubsPSLI.put(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id, lstPSLI);
                }
                else
                {
                    mapSubsPSLI.put(psli.chargeInstance__r.serviceId__r.csord__Subscription__r.id, new List<Price_Schedule_Line_Item__c>{psli});
                }}
            }*/
           //EDGE-120128 - end
            //added code as part of EDGE-124711/EDGE-124029
             if(!subsList.isEmpty())
             {
                 updateSchedulesonCallback(subsList);
             }
            System.debug('subscriptionMap::'+subscriptionMap);
            
            
            
            //for every notification update specs
            for(String key: parameterMap.keySet()){
                ManageOrderNotificationUtil.Parameters param = parameterMap.get(key);
                String eventType = param.eventType;
                csord__Subscription__c sub = subscriptionMap.get(param.orderIdc);
                String notificationAttr = param.notifyAttributes;
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                for(ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes){
                    if(attr.name.contains(STATUS) && attr.value == Label.Complete && sub.Sub_status__c == Label.MO_status_active){
                        sub.csord__Status__c =  Label.MO_status_active;
                        subsListtoUpdate.add(sub);
                        NumberUtil.UpdateNumberStatus(sub.csordtelcoa__Subscription_Number__c,'Active');//EDGE-115655 - calling NumberUtil class to update number status on receiving Complete Notification
                        //commented code as part of EDGE-124711/EDGE-124029
                        /*  if(mapSubsPSLI.containsKey(sub.Id)){
                        for(Price_Schedule_Line_Item__c psli:mapSubsPSLI.get(sub.Id)) //EDGE-120128 - if current subscrption is in mapSubsPSLI map then updating PSLI status related to that subscrption
                         {
                        psli.status__c='Active';
                        psliList.add(psli); //EDGE-120128 - added PSLI in List
                        }
                        }*/}
                    if(attr.name.contains(STATUS) && attr.value == Label.Complete && sub.Sub_status__c == Label.MO_status_inactive){
                        sub.csord__Status__c =  Label.MO_status_inactive;
                        subsListtoUpdate.add(sub);
                        NumberUtil.UpdateNumberStatus(sub.csordtelcoa__Subscription_Number__c,'Inactive');//EDGE-115655 - calling NumberUtil class to update number status on receiving In progress Notification
                         //commented code as part of EDGE-124711/EDGE-124029
                        /* if(mapSubsPSLI.containsKey(sub.Id)){
                        for(Price_Schedule_Line_Item__c psli:mapSubsPSLI.get(sub.Id)) //EDGE-120128
                        {
                        psli.status__c='Ready to Inactive';//EDGE-120128 - added PSLI in List
                        psliList.add(psli);
                        }
                       }*/
                    }
                    if(eventType == 'error' && attr.name.contains('error')){
                        sub.csord__Status__c =  Label.MO_Acknowledge_fail_status;
                        subsListtoUpdate.add(sub);
                    }
                }
                /*if(!subsListtoUpdate.isEmpty())
update subsListtoUpdate;*/ //changes for code violations
            }
            if(!subsListtoUpdate.isEmpty())
            {update subsListtoUpdate;}
             //commented code as part of EDGE-124711/EDGE-124029
           /* if(!psliList.isEmpty())
            {
                update psliList;  //EDGE-120128 -updating PSLI outside loop
            }*/
            notif.Status__c = 'Completed';
            
            
            Map<Id,csord__Service__c> servList =new Map<Id,csord__Service__c>([SELECT Id,Name,csord__Order__c,toBeCancelled__c,csord__Subscription__r.eventId__c,Action_Type__c FROM csord__Service__c WHERE csord__Subscription__r.eventId__c IN : eventIds for update]);
            List<csord__Service__c> updatableService = new List<csord__Service__c>();
            Map<String, csord__Service__c> serviceMap = new Map<String, csord__Service__c>();
            for(csord__Service__c serv : servList.values()){
                //if(serv.toBeCancelled__c =='true')
                // {   
                List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById((serv.Id)),'BILLING');
                if(serv.Action_Type__c == 'PayOut'){
                    serv.csord__Status__c = 'Paid Out';
                    updatableService.add(serv);
                }
                for(CS_SpecificationDTO.ServiceSpecification spec :srvspecList)
                {
                    if(servList.get(spec.serviceId).toBeCancelled__c == 'true') csedm.API_1.updateServiceSpecificationPropertyById(spec.serviceId, spec.guid, STATUS, 'Disconnected');
                    else
                        csedm.API_1.updateServiceSpecificationPropertyById(spec.serviceId, spec.guid, STATUS, 'Complete');
                }
                // }else{
                
                //}
                
            }
            if(!updatableService.isEmpty()){
                update updatableService;
            }
            
        }
        catch(Exception e){
            notif.Status__c = 'Error';
            notif.Internal_Error_Description__c = e.getTypeName() +','+e.getMessage() +','+  e.getLineNumber();
        }
        //update notif;
    }
    
    @TestVisible
    private static void updateAppointmenRecord(List<String> paramAppointmentList,String notificationId){
        Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
        List<String> appointmentIds = new List<String>();
        Notification__c notif = [Select Id,Name,Status__c,Internal_Error_Description__c from Notification__c where Id =: notificationId for update];
        try{  
            for(String parameterString: paramAppointmentList){
                ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
                params = (ManageOrderNotificationUtil.Parameters) JSON.deserialize(parameterString, ManageOrderNotificationUtil.Parameters.class);
                parameterMap.put(params.orderIdc, params);
                appointmentIds.add(params.orderIdc);
            }
            List<Appointment__c> apptListtoUpdate = new List<Appointment__c>();
            List<Appointment__c> apptList = [SELECT Id,Status__c,SlotId__c FROM Appointment__c WHERE  SlotId__c IN: appointmentIds for update];
            Map<String, Appointment__c> appointmentMap = new Map<String, Appointment__c>();
            for(Appointment__c appt: apptList){
                appointmentMap.put(String.valueof(appt.SlotId__c), appt);
            }
            for(String key: parameterMap.keySet()){
                ManageOrderNotificationUtil.Parameters param = parameterMap.get(key);
                Appointment__c appt = appointmentMap.get(param.orderIdc);
                String notificationAttr = param.notifyAttributes;
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(notificationAttr);
                for(ManageOrderNotificationUtil.NotificationAttributes attr: notifyAttrs.attributes){
                    if(attr.name.contains(STATUS) && attr.value != ''){
                        appt.Status__c =  attr.value;
                        apptListtoUpdate.add(appt);
                    }
                }
                
            }
            if(!apptListtoUpdate.isEmpty()){
                update apptListtoUpdate;
            }
            notif.Status__c = 'Completed';}catch(Exception e){notif.Status__c = 'Error';notif.Internal_Error_Description__c = e.getTypeName() +','+ e.getMessage() + ','+  e.getLineNumber();
                                                             }
        //update notif;
    }
    
    private static void specMapUpdateErrorStatus(Map<String, String> specToUpdatedStatusMap, Map<String, String> replacedSpecToUpdatedStatusMap, Map<String, CS_SpecificationDTO.ServiceSpecification> serviceSpecMap, Set<Id> serviceIds,Map<String, String> serviceAttachmentMap,Map<String,Attachment> servAttachmentRecordMap){
        String currentSpecStatus;
        try{  
            Map<Id,Attachment> updatedAttSet = new Map<Id,Attachment>();
            for(String guid: specToUpdatedStatusMap.keySet()){
                CS_SpecificationDTO.ServiceSpecification spec = serviceSpecMap.get(guid);
                if(spec != null){ currentSpecStatus = spec.status;
                                 system.debug('currentSpecStatus'+currentSpecStatus);
                                 if(currentSpecStatus.contains('Disconnect') && specToUpdatedStatusMap.get(spec.guid).contains(Label.Complete)){
                                     specToUpdatedStatusMap.put(spec.guid, Label.MO_status_disconnected);
                                 }else{
                                     String udtattbody = csedm.API_1.updateServiceSpecificationProperty(serviceAttachmentMap.get(spec.serviceId), spec.guid, 'status', specToUpdatedStatusMap.get(spec.guid));    
                                     Attachment att = servAttachmentRecordMap.get(spec.serviceId);
                                     system.debug('udtattbody ' + udtattbody);
                                     att.body = Blob.valueOf(udtattbody);
                                     //update att;
                                     serviceAttachmentMap.put(att.parentId,att.Body.toString());
                                     updatedAttSet.put(att.id,att);
                                 }
                                 
                                 serviceIds.add(spec.serviceId);
                                }
                else {
                    replacedSpecToUpdatedStatusMap.put(guid,specToUpdatedStatusMap.get(guid));
                }
            }
            if(!updatedAttSet.isEmpty()){              update updatedAttSet.values(); }}catch(Exception e){System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());
                                                                                                          }
    }
    @TestVisible
    private static void replacedSpecMapUpdateErrorStatus(Set<String> replacedSubscriptionIds, Map<String, String> replacedSpecToUpdatedStatusMap, Set<Id> serviceIds){
        String currentSpecStatus;
        Map<String, CS_SpecificationDTO.ServiceSpecification> replacedServiceSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        
        try{
            for(String subId : replacedSubscriptionIds){
                String subSpec = csedm.API_1.getSubscriptionSpecificationsById(subId);
                if(!String.isEmpty(subSpec)){
                    List<CS_SpecificationDTO.ServiceSpecification> servSpecList = CS_SpecificationDTO.parseSubscriptionSpec(subSpec,FULFILMENT);
                    for(CS_SpecificationDTO.ServiceSpecification servSpec : servSpecList){
                        replacedServiceSpecMap.put(servSpec.guid, servSpec);
                    }
                }
            }
            
            for(String guid : replacedSpecToUpdatedStatusMap.keySet()){
                CS_SpecificationDTO.ServiceSpecification servcSpec = replacedServiceSpecMap.get(guid);
                if(servcSpec != null){currentSpecStatus = servcSpec.status;
                                      if(currentSpecStatus.contains('Disconnect') && replacedSpecToUpdatedStatusMap.get(servcSpec.guid).contains(Label.Complete)){
                                          replacedSpecToUpdatedStatusMap.put(servcSpec.guid, Label.MO_status_disconnected);
                                      }
                                      csedm.API_1.updateServiceSpecificationPropertyById(servcSpec.serviceId, servcSpec.guid, STATUS, replacedSpecToUpdatedStatusMap.get(servcSpec.guid));
                                      serviceIds.add(servcSpec.serviceId);
                                      
                                     }
            }
        }
        catch(Exception e){
            System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());
        }  
    }
    
    
    @TestVisible
    private static Map<String, String> getChildProducts(ManageOrderNotificationUtil.Product prd){
        Map<String, String> statuses = new Map<String, String>();
        try{
            if(prd != null && prd.childProduct != null){
                List<ManageOrderNotificationUtil.ChildProduct> childPrds = prd.childProduct;
                for(ManageOrderNotificationUtil.ChildProduct childp: childPrds){
                    statuses.put(childp.productId, childp.status); }}}catch(Exception e){System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());
                                                                                        }
        return statuses;
    }
    //@TestVisible
    public static String calculateServiceStatus(String srvcId,List<CS_SpecificationDTO.ServiceSpecification> cfsAttrList){
        
        String status;
        //List<CS_SpecificationDTO.ServiceSpecification> cfsAttrList = new List<CS_SpecificationDTO.ServiceSpecification>();
        //cfsAttrList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(srvcId),FULFILMENT);
        Integer completeCount = 0;
        Integer disconnectedCount = 0;
        Integer cancelledCount = 0;
        Integer failedCount = 0;
        Integer specSize = 0;
        
        csord__Service__c serv = [SELECT Id, Name, csord__Status__c, csord__Order__c,csord__Order__r.Name , csord__Order_Request__c, csordtelcoa__Service_Number__c, CreatedDate,Forecasted_Delivery_Date__c,Telstra_Committed_Date__c,csord__Subscription__c, Tenancy_Id__c,csord__Subscription__r.Suspension_reason__c,csord__Service__c  from csord__Service__c where Id=: srvcId];
        //add query on subscription via service 
        try{
            for(CS_SpecificationDTO.ServiceSpecification specs: cfsAttrList){
                if(specs.serviceId == srvcId){
                    specSize +=1;
                    if(specs.status == Label.MO_Acknowledge_fail_status)         failedCount += 1;
                    if(specs.status == Label.MO_status_error)         failedCount += 1;
                    if(specs.status == Label.MO_status_in_progress)       status = Label.MO_status_in_progress;
                    if(specs.status == Label.MO_status_cancel_in_progress)   status = Label.MO_status_cancel_in_progress;
                    if(specs.status == Label.MO_status_disconnect_in_progress)       status = Label.MO_status_disconnect_in_progress;
                    if(specs.status == Label.Complete)       completeCount += 1 ;
                    if(specs.status == Label.MO_status_disconnected)     disconnectedCount += 1;
                    if(specs.status == Label.MO_status_cancel)       cancelledCount += 1;
                }
                
            }
            System.debug('Status::'+status);
            System.debug('Total Specs:::'+specSize+'completeCount::'+completeCount+'cancelledCount:::'+cancelledCount+'disconnectedCount:::'+disconnectedCount+'failedCount::'+failedCount);
            if(completeCount == specSize){status = Label.MO_Service_Status_Connected;}
            if(serv.csord__Subscription__r.Suspension_reason__c!=null && serv.csord__Subscription__r.Suspension_reason__c.containsIgnoreCase('Requested by')){status = system.label.subscription_Suspended_Status;} //If suspension reason is populated on subscription then sending status as suspended               
            if(disconnectedCount == specSize) status = Label.MO_status_disconnected;
            if(cancelledCount == specSize) status = Label.MO_status_cancel;
            if(failedCount > 0) status = Label.MO_Acknowledge_fail_status;
        }
        catch(Exception e){
            System.debug('Exception:'+ e.getTypeName() +','+e.getMessage() +','+  e.getLineNumber());
        }
        return status;
    }
    
    /*public static Map<String,List<CS_SpecificationDTO.ServiceSpecification>> findChildSpecs(List<CS_SpecificationDTO.ServiceSpecification> allSrvSpecList){
Map<String,List<CS_SpecificationDTO.ServiceSpecification>> SpecsMap = new Map<String,List<CS_SpecificationDTO.ServiceSpecification>>();
try{
for(CS_SpecificationDTO.ServiceSpecification srvSpec : allSrvSpecList){
for(CS_SpecificationDTO.SimpleAttributes attr: srvSpec.additionalAttributes){
if(attr.name.contains('parentSpec')){
if(SpecsMap.containsKey(srvSpec.serviceId)){
List<CS_SpecificationDTO.ServiceSpecification> childspec  = SpecsMap.get(srvSpec.serviceId);
childspec.add(srvSpec);
SpecsMap.put(srvSpec.serviceId,childspec);
}
else{
SpecsMap.put(srvSpec.serviceId, new List<CS_SpecificationDTO.ServiceSpecification> {srvSpec});
}
}
}
}
}
catch(Exception e){
System.debug('Exception:'+ e.getTypeName() +' '+e.getMessage());
}
return SpecsMap;
}
*/
    public static Map<String, CS_SpecificationDTO.ServiceSpecification> getallOrderSpecs(List<CS_SpecificationDTO.ServiceSpecification> srvspecList){
        Map<String, CS_SpecificationDTO.ServiceSpecification> srvSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        try{
            // if(srvspecList!=null){
            /*List<csord__Order__c> allOrders = [SELECT Id, Name, csord__Status2__c, csord__Order_Request__c FROM csord__Order__c WHERE csordtelcoa__Opportunity__c =: orderRequestId];
List<String> ordIds = new List<String>();
for(csord__Order__c ord: allOrders){
ordIds.add(ord.Id);
}*/
            //List<CS_SpecificationDTO.ServiceSpecification> serviceJSONSpecMap = new List<CS_SpecificationDTO.ServiceSpecification>();
            //serviceJSONSpecMap = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(specBody),FULFILMENT);
            
            for(CS_SpecificationDTO.ServiceSpecification serSpec : srvspecList) {
                srvSpecMap.put(serSpec.guid, serSpec);}}catch(Exception e){System.debug('Exception:'+ e.getTypeName() +' '+e.getMessage());}
        return srvSpecMap;
    }
  
 //added method as part of EDGE-124711/EDGE-124029
  public static void updateSchedulesonCallback(List<csord__Subscription__c> subsList)
    {
        Map<Id, csord__Service__c> serviceIdsToFetchNew = new Map<Id, csord__Service__c>();
            Map<Id, csord__Service__c> serviceIdsToFetchModify = new Map<Id, csord__Service__c>();
    
            set<Id> baseOrderServiceIDModify=new set<Id>();
            set<Id> baseOrderServiceIDCancel=new set<Id>();
            Map<Id, csord__Service__c> serviceMapPricing =  new Map<Id, csord__Service__c>([SELECT Id,  Name, csord__Subscription__c, Scenario_Type__c,toBeCancelled__c,csordtelcoa__Replaced_Service__c FROM csord__Service__c where csord__Subscription__c IN : subsList]);
            
            for(Id serviceKey : serviceMapPricing.keyset()){
                
                if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c == null){
                    serviceIdsToFetchNew.put(serviceKey, serviceMapPricing.get(serviceKey));
                }
                else if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c != null && serviceMapPricing.get(serviceKey).toBeCancelled__c.equalsIgnoreCase('false')){
                    serviceIdsToFetchNew.put(serviceKey, serviceMapPricing.get(serviceKey));
                    baseOrderServiceIDModify.add(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c);
                    //serviceIdsToFetchModify.put(serviceKey, serviceMap.get(serviceKey));  
                }else if(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c != null && serviceMapPricing.get(serviceKey).toBeCancelled__c.equalsIgnoreCase('true')){
                    baseOrderServiceIDCancel.add(serviceMapPricing.get(serviceKey).csordtelcoa__Replaced_Service__c);
                }
            
            }
            
            if(serviceIdsToFetchNew!=null)
            {
                CeasePriceScheduleStep.updateSchedule(serviceIdsToFetchNew.keySet(), 'Active');
            }
            if(baseOrderServiceIDModify!=null)
            {
                CeasePriceScheduleStep.updateSchedule(baseOrderServiceIDModify, 'Replaced');
            }
            if(baseOrderServiceIDCancel!=null)
            {
                CeasePriceScheduleStep.updateSchedule(baseOrderServiceIDCancel, 'Inactive');
            }
    }
}