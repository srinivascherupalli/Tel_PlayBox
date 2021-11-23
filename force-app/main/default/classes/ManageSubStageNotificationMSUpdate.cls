/********************************************************   
Class Name : ManageSubStageNotificationMSUpdate 
Test Class :ManageSubStageNotificationMSUpdateTest  
=============================================================================================================================== 
Change.No.    Developer Name          Date          Story Description   
1               Prajakta           7-02-2020    
2               Prajakta           05-05-2020      EDGE-147027  
3.              Pawan              05-05-2020      EDGE-147219 : Ignore Number tag from substage notification of O2A    
4.              Vaibhav            06-07-2020       EDGE-158047 : populate DeviceID/DeviceIDType for child products on Asset object 
5.              Vaibhav            24-07-2020       EDGE-160369  : Network ServiceID fix    
6.              vaibhav            27-07-2020       EDGE-164886 
7.              Pawan              10-08-2020       EDGE-167675 : Trigger_RTS__c changes    
8.              Dheeraj            28-08-2020       EDGE-168182 : Logistics Order Number Fix    
9.              Dheeraj            03-09-2020       EDGE-174212: Tenancy ID Order Number Fix    
10.             Dheeraj            03-09-2020       EDGE-174900: Service Activation Date in Child Spec Fix  
11              Prajakta           22-10-2020       EDGE-184831 
12              Prajakta           06/11/2020       EDGE-188475 
13              Gnana              02/12/2020       EDGE-187675 Added logic to process "Ready for Activation" SubStage Notification 
14              Vaibhav            02/12/2020       EDGE-170550 
15.             Pawan              14/12/2020       EDGE-189531 : Updated condition to support MAC on MAC scenarios 
16.             Vaibhav            16/12/2020       EDGE-187676 
17.             Prajakta           22/03/2021       EDGE-170530 
18.             Pawan Singh       20/04/2021    EDGE-215225 : added condition to check before all throw statements  enableThrowException    
19.             Suyash/Payel      23/04/2021        TC-47565 & TC-47820 : Defect fix related to subStageNotification    
20.             Vaibhav            26/04/2021      INC000095547173 fix  
21.             Anuj Pathak       04/05/2021        Edge-204029 
22.             Vaibhav           18/05/2021       B2B-328 - Solution Supress
23.             Pawan             04-June-2021      EDGE-168182 - Updated logic 
24.             Pawan           08-June-2021    EDGE-189974 - Enhanced Cancel logic to handle multiple deactivation notification
25.             Suyash          23-07-2021      DIGI-5141 - Tenancy ID is not populating for SDWAN Tenancy service on SFDC UI
26.             Nikkhil         29-10-2021      DIGI-36924
**********************************************************/ 
public with sharing class ManageSubStageNotificationMSUpdate{   
    private static String correlationId = GuidUtil.NewGuid();   
    private static final String CONST_INTERFACENAME = 'ManageSubStageNotificationMSUpdate'; 
    //EDGE-116041   
    private final static String NETSERID = 'NetworkServiceId';  
    private final static String CFSID = 'CustomerFacingServiceId';  
    private final static String TENANCYID ='TenancyID'; //EDGE-174212   
    //EDGE-80847    
    //public static String tenancyId = '';  
    //public static List<String> deviceIds = new List<String>();    
    // public static String deviceType = '';    
    public static  Map<String,Map<String,String>> mapNotifyAttrwithServiceId =  new Map<String,Map<String,String>>(); //EDGE-168182 
    //public static Map<Id,csord__Subscription__c> solutionToSubMap = new Map<Id,csord__Subscription__c>();//EDGE-187676    
    public static Map<Id,csord__Subscription__c> subIdToSubMap = new Map<Id,csord__Subscription__c>();//EDGE-187676 
    public static Map<Id,List<Number__c>> subIdtoNumberMap = new Map<Id,List<Number__c>>();  //EDGE-187676  
    public static void processSubStageNotification(Map<String,List<NotificationParameters>> orderItemIdNotifMap,List<NotificationParameters> paramsList){   
        boolean enableThrowException = Boolean.valueOf(EnvironmentVariable__c.getValues('EnableThrowException').Value__c); //EDGE-215225    
        /*System.debug('In method processSubStageNotification with notif id'+notificationId);   
ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();   
Notification__c notif = [Select Id,Name,orderItemId__c,Status__c,Internal_Error_Description__c from Notification__c where Id =: notificationId];    
System.debug('notif'+notif);*/  
        String eventsrvcNumber; 
        // List<String> guidList= new List<String>();   
        //Abinash   
        List<id> orderIdList = new List<Id>();  
        Map<String,String> mapNotifyAttr = new Map<String,String>(); //EDGE-80847   
        Map<String,Datetime> mapsrvcwithforecasteddate = new Map<String,DateTime>(); //EDGE-168182  
        Map<String,Datetime> mapsrvcwithEstimatedPoNRdate = new Map<String,DateTime>(); 
        Map<Id,String> srIdSubstageMap = new Map<Id,String>();  
        List<csord__Service__c> childService = new List<csord__Service__c>();   
        List<String> notifOrderList=new List<String>(); //EDGE-187676   
        String toLog ='';   
        try{    
            // String serviceId;    
            String subStageName = NULL; 
            DateTime subStageCompletionDate = System.Now();//NULL;  
            Set<Id> srvSpecIdSet= new Set<Id>();    
            Datetime forecastedDate = NULL; 
            //added for EDGE-116041 
            String NetworkServiceId;    
            string orderId; 
            string srvcNumber;  
            String SubscriptionId;  
            Boolean stopprocessing = false; 
            List<csord__Service__c> updateServiceList = new List<csord__Service__c>();  
            Map<Id,csord__Service__c> svcIdSvcMap = new Map<Id,csord__Service__c>();    //Map of svc Id and svc 
            List<string> srvcNumberList = new List<string>();   
            Map<String,string> servNetworkServiceIdMap = new Map<String,string>();  
            Map<String,String> mapServCustomerFacingId = new Map<String,string>();// EDGE-204029    
            Map<String,string> servnumSubstageMap = new Map<String,string>();   
            Map<Id,string> servIdSubstageMap = new Map<Id,string>();    
            Map<String,Set<String>> servguidMap = new Map<String,Set<String>>(); //EDGE-184831  
            List<Id> subList = new List<Id>();  
            List<Id>serviceIdList = new List<Id>(); 
            Map<Id,Id>servSubMap = new Map<Id,Id>();    
            Map<String,Id>seridNumberMap = new Map<String,Id>();    
            List<Id>serIdList = new List<Id>(); 
            Map<Id,string> subIdtoNetworkSServIDMap = new Map<Id,string>(); //added as part of EDGE-160369  
            Map<Id,string> mapSubIdtoCustomerFacingId = new Map<Id,string>(); //EDGE-204029 
            Map<Id,Datetime> subIdtoEstimatedPoNRDateMap = new Map<Id,Datetime>();  
            List<csord__Subscription__c> subscriptionlist =new List<csord__Subscription__c>(); //added as part of EDGE-160369   
            if(!stopprocessing) 
            {   
                for(NotificationParameters notif :paramsList){  
                    ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();   
                    params.orderIdc = notif.orderItemId;    
                    if(String.isNotEmpty(notif.notificationAttributes)) params.notifyAttributes = '{'+String.valueOf(notif.notificationAttributes)+'}'; 
                    if(String.isNotEmpty(notif.orderItemDetails)) params.orderItemDetails = '{'+String.valueOf(notif.orderItemDetails)+'}'; //convert string to JSON supported format   
                    params.eventType = notif.eventType; 
                    List<String> keyparams = params.orderIdc.split('\\|');  
                    if(keyparams.size() > 0){ orderId = keyparams[0]; } 
                    if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }  
                    notifOrderList.add(orderId); //EDGE-187676  
                    ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{'+String.valueOf(notif.notificationAttributes)+'}');   
                    System.debug('notifyAttrs:::' + notifyAttrs);   
                    //----- Extract subStage details from Notification Attributes   
                    for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){  
                        if(attr.name.contains('subStage')){ 
                            subStageName = attr.value;} 
                        //NetworkServiceId added for EDGE-116041    
                        system.debug('attributr Name>>>>>>::'+attr.name);   
                        //  
                        if(attr.name.contains('currentForecastedDeliveryDate')) {   
                            forecastedDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);    
                            mapsrvcwithforecasteddate.put(srvcNumber,forecastedDate); //EDGE-168182 
                        }   
                        else if(attr.name.contains('EstimatedPoNRDate')){ //EDGE-170530 
                            mapsrvcwithEstimatedPoNRdate.put(srvcNumber,(datetime)json.deserialize('"'+attr.value+'"', datetime.class));    
                        }   
                        else if(attr.name.contains('DesignCompletionDate')||attr.name.contains('EquipmentOrderedDate')||attr.name.contains('EquipmentDeliveredDate')||attr.name.contains('InstallationDate')||attr.name.contains('ServiceActivationDate')||attr.name.contains('CustomerOrderAcceptanceDate') ||attr.name.contains('ServiceDeactivationDate')||attr.name.contains('DeviceRecoveredDate') || attr.name.contains('EquipmentDeliveryFailedDate')){  
                            subStageCompletionDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);}   
                    }   
                    ManageOrderNotificationUtil.Product productUp = ManageOrderNotificationUtil.parse('{'+String.valueOf(notif.orderItemDetails)+'}');  
                    Map<String,String> getnotifattrmap = new Map<String,String>(); //EDGE-168182    
                    for(ManageOrderNotificationUtil.NotificationAttributes attr : productUp.attributes){    
                        system.debug('attr.name' + attr.name +'attr.value' +attr.value);    
                        if(NETSERID.contains(attr.name)){servNetworkServiceIdMap.put(srvcNumber,attr.value);    
                                                         System.debug('N/W Service Id'+attr.value); 
                                                         system.debug('servNetworkServiceIdMap::'+servNetworkServiceIdMap); 
                                                         system.debug('attributr Name>>>>>>::'+attr.name + '>>>>' + attr.value);    
                                                        }   
                        //EDGE-204029 start 
                        if(CFSID.contains(attr.name)){  
                            mapServCustomerFacingId.put(srvcNumber,attr.value); 
                            system.debug('attributr Name>>>>>>::'+attr.name + '>>>>' + attr.value); 
                        }   
                        //EDGE-204029 End   
                        else if(TENANCYID.containsIgnoreCase(attr.name)){ //DIGI-5141 - Updated the function from contains to containsIgnoreCase
                            getnotifattrmap.put('TenancyID', attr.value);   
                        }// EDGE-174212 added for tenancy ID    
                    }   
                    servnumSubstageMap.put(srvcNumber,subStageName);    
                    system.debug('servnumSubstageMap'+servnumSubstageMap);  
                    if(subStageName != NULL){ //EDGE-80847  
                        getnotifattrmap.put('subStageName', subStageName);//added as part of EDGE-170550    
                        mapNotifyAttr.put('subStageName', subStageName); //EDGE-103758  
                        system.debug('subStageName>>>>>>'+subStageName);    
                        // Added "Ready for Activation" condition as part of EDGE-187675    
                        if(subStageName.contains('Equipment Ordered') || subStageName.contains('Picking & Packing') || subStageName.contains('Delivery Tracking') ||subStageName.contains('Equipment Delivery Failed') || subStageName.contains('Ready for Activation')){ //added as part of EDGE-170550                        
                            for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){  
                                //EDGE-119708 Logistics Order number is not getting displayed in subscription page even 
                                //after recieving DISPATCHED status from LOMS  
                                //EDGE-168182 - Updated if conditions to correct logic with brackets ()                             
                                if((subStageName.contains('Equipment Ordered') || subStageName.contains('Equipment Delivery Failed')) && attr.name.contains('LogisticOrderNumber')){  
                                    //mapNotifyAttr.put('LogisticOrderNumber', attr.value); 
                                    getnotifattrmap.put('LogisticOrderNumber', attr.value); 
                                }   
                                if(subStageName.contains('Picking & Packing') && attr.name.contains('EstimatedDeliveryDate')){  
                                    //mapNotifyAttr.put('EstimatedDeliveryDate', attr.value);   
                                    getnotifattrmap.put('EstimatedDeliveryDate', attr.value);   
                                }   
                                if((subStageName.contains('Delivery Tracking') || subStageName.contains('Equipment Delivery Failed')) && attr.name.contains('ConsignmentNumber')){ //added as part of EDGE-170550 
                                    //mapNotifyAttr.put('ConsignmentNumber', attr.value);   
                                    getnotifattrmap.put('ConsignmentNumber', attr.value);   
                                }   
                                if((subStageName.contains('Delivery Tracking') || subStageName.contains('Equipment Delivery Failed')) && attr.name.contains('TrackingURL')){ //added as part of EDGE-170550   
                                    //mapNotifyAttr.put('TrackingURL', attr.value); 
                                    getnotifattrmap.put('TrackingURL', attr.value); 
                                }   
                                if(subStageName.contains('Ready for Activation')&& attr.name.contains('ReadyForActivationDate')){ //added as part of EDGE-187675    
                                    getnotifattrmap.put('ReadyForActivationDate', attr.value);  
                                }   
                            }   
                        }   
                    }   
                    // create a  map for collecting service id and subscription id - EDGE-168182    
                    system.debug('getnotifattrmap  ===  '+getnotifattrmap); 
                    //mapNotifyAttrwithServiceId.put(srvcNumber,getnotifattrmap);   
                    //EDGE-168182   
                    if(mapNotifyAttrwithServiceId.containsKey(srvcNumber)){ 
                        Map<String,String> addnotifattr= new Map<String,String>();  
                        addnotifattr = (mapNotifyAttrwithServiceId.get(srvcNumber));    
                        addnotifattr.putAll(getnotifattrmap);   
                        mapNotifyAttrwithServiceId.put(srvcNumber,addnotifattr);    
                    }   
                    else{   
                        mapNotifyAttrwithServiceId.put(srvcNumber,getnotifattrmap); 
                    }   
                    system.debug('mapNotifyAttrwithServiceId  ===  '+mapNotifyAttrwithServiceId);   
                    mapNotifyAttr.putAll(getnotifattrmap); //EDGE-168182    
                    srvcNumberList.add(srvcNumber); 
                    toLog += '*'+notif.orderItemId+'-->'+notif.msCorrelationId+'\n';    
                }   
                /*solutionToSubMap =*/ getSolutiontosubMap(notifOrderList); //EDGE-187676   
                List<Service_Specification__c> serSpecifications = new List<Service_Specification__c>();    
                List<Service_Specification__c> SerSpecificationsList = new List<Service_Specification__c>();    
                List<csord__Service__c> serviceListData = [SELECT Id, Name,csord__Order__r.csord__Status2__c , csord__Status__c, csord__Subscription__c, csord__Order__c,toBeCancelled__c,csordtelcoa__Replaced_Service__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,Forecasted_Delivery_Date__c,csord__Subscription__r.customerFacingServiceId__c,NetworkserviceId__c,csord__Subscription__r.id, Estimated_PoNR_Date__c, csord__Subscription__r.Estimated_PoNR_Date__c, customer_facing_service_id__c,
                                                           (Select Id, Name,GUID__c, Service__c FROM Service_Specifications__r),    
                                                           (Select id,Name, csord__Status__c, csord__Subscription__c,csord__Subscription__r.customerFacingServiceId__c,csord__Subscription__r.NetworkserviceId__c ,csord__Order__c,toBeCancelled__c,csord__Order__r.id, csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,Forecasted_Delivery_Date__c,NetworkserviceId__c, csord__Subscription__r.id from csord__Services__r) 
                                                           FROM csord__Service__c   
                                                           WHERE csordtelcoa__Service_Number__c IN:srvcNumberList Order By CreatedDate DESC];   
                //to get substagematrix records 
                Map<String,String> finalSubStageMatrix = new Map<String,String>();  
                Map<String, String> notifsubStageNameMap = new Map<String, String>();   
                Map<Id,String>servtobecancelledMap = new Map<Id,String>();  
                List<Id> ordList = new List<Id>();  
                List<Id>subscriptionIdList = new List<Id>();    
                for(csord__Service__c serc :serviceListData){   
                    serIdList.add(serc.id); 
                    svcIdSvcMap.put(serc.id, serc);     //Map of svc Id and svc 
                }   
                Map<Id,String> serAttachmentMap = new Map<Id,String>(); 
                for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serIdList]){    
                    serAttachmentMap.put(att.parentId,att.body.toString()); 
                }   
                for(csord__Service__c srv :  serviceListData)   
                {   
                    // serviceId = srv.Id;  
                    seridNumberMap.put(srv.csordtelcoa__Service_Number__c,srv.id);  
                    if(servnumSubstageMap.get(srv.csordtelcoa__Service_Number__c)!= null){  
                        servIdSubstageMap.put(srv.id,servnumSubstageMap.get(srv.csordtelcoa__Service_Number__c));   
                        for(csord__Service__c childs : srv.csord__Services__r){ //added as part of EDGE-186051  
                            system.debug('childs'+childs);  
                            servIdSubstageMap.put(childs.id,servnumSubstageMap.get(srv.csordtelcoa__Service_Number__c));    
                        }   
                    }   
                    system.debug('servIdSubstageMap'+servIdSubstageMap);    
                    if(srv.csord__Services__r !=  null && !srv.csord__Services__r.isEmpty())    
                        childService.addAll(srv.csord__Services__r);    
                    //subscriptionId = srv.csord__Subscription__c;  
                    subscriptionIdList.add(srv.csord__Subscription__c); 
                    // primaryOrderId = srv.csord__Order__r.csord__Primary_Order__c != null ? srv.csord__Order__r.csord__Primary_Order__c : srv.csord__Order__c;    
                    ordList.add(srv.csord__Order__c);   
                    // System.debug(':serviceId:' + serviceId + ':subscriptionId:' + subscriptionId + ':primaryOrderId:' + primaryOrderId); 
                    //srv.Forecasted_Delivery_Date__c = forecastedDate; 
                    srv.Forecasted_Delivery_Date__c = mapsrvcwithforecasteddate.get(srv.csordtelcoa__Service_Number__c);  //EDGE-168182 
                    system.debug('srv.Forecasted_Delivery_Date__c' +srv.Forecasted_Delivery_Date__c);   
                    //NetworkServiceId added to Service object for EDGE-116041  
                    system.debug('netserId::'+servNetworkServiceIdMap.get(srv.csordtelcoa__Service_Number__c)); 
                    if(servNetworkServiceIdMap.containsKey(srv.csordtelcoa__Service_Number__c)){ //added as part of EDGE-160369 
                        srv.NetworkServiceId__c = String.ValueOf(servNetworkServiceIdMap.get(srv.csordtelcoa__Service_Number__c));} 
                    //EDGE-204029 Start 
                    if(mapServCustomerFacingId.containsKey(srv.csordtelcoa__Service_Number__c)){    
                        mapSubIdtoCustomerFacingId.put(srv.csord__Subscription__r.id,mapServCustomerFacingId.get(srv.csordtelcoa__Service_Number__c));  
                         //Added by Nikhil as part of DIGI-36924
                        srv.customer_facing_service_id__c = String.ValueOf(mapServCustomerFacingId.get(srv.csordtelcoa__Service_Number__c));
                    }   
                    //EDGE-204029 End   
                    //EDGE-170530   
                    if(mapsrvcwithEstimatedPoNRdate.containsKey(srv.csordtelcoa__Service_Number__c)){   
                        srv.Estimated_PoNR_Date__c = mapsrvcwithEstimatedPoNRdate.get(srv.csordtelcoa__Service_Number__c);  
                        subIdtoEstimatedPoNRDateMap.put(srv.csord__Subscription__r.id,mapsrvcwithEstimatedPoNRdate.get(srv.csordtelcoa__Service_Number__c));    
                    }   
                    updateServiceList.add(srv); 
                    //----- create all serviceSpecs Records(Parent Service) when first subStage Notification is Received    
                    system.debug('Service_Specifications__r size :::' + srv.Service_Specifications__r.size());  
                    if(srv.Service_Specifications__r.size() >= 0){  
                        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serAttachmentMap.get(srv.id)),'FULFILMENT'); 
                        system.debug('srvspecList:::' + srvspecList);   
                        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList) 
                        {   
                            boolean checkChildSpec=false;   
                            Set<String> serviceGuid = new Set<String>();    
                            system.debug('srvSpec:::'+srvSpec + 'additionalAttributes:::' + srvSpec.additionalAttributes);  
                            if(srvSpec.additionalAttributes.size()!=0){ 
                                for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){   
                                    system.debug('attr===='+attr+'----='+attr.name);    
                                    if(attr.name == 'parentSpec'){ checkChildSpec = true;break;}    
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
                                    if(servNetworkServiceIdMap.containsKey(srv.csordtelcoa__Service_Number__c)){ //added as part of EDGE-160369 
                                        attr.value = servNetworkServiceIdMap.get(srv.csordtelcoa__Service_Number__c);}  
                                }   
                                if(CFSID.equals(attr.name)){srv.csord__Subscription__r.customerFacingServiceId__c = attr.value; 
                                                           }    
                            }   
                        }   
                        if(servNetworkServiceIdMap.containsKey(srv.csordtelcoa__Service_Number__c)){    
                            NetworkServiceId = String.valueOf(servNetworkServiceIdMap.get(srv.csordtelcoa__Service_Number__c)); 
                            subIdtoNetworkSServIDMap.put(srv.csord__Subscription__r.id,NetworkServiceId);}  
                        //subList.add(srv.csord__Subscription__c);  
                        system.debug('NetworkServiceId::'+NetworkServiceId);    
                    }   
                    else {  
                        SerSpecificationsList.addAll(srv.Service_Specifications__r);    
                    }   
                    //finalSubStageMatrix= getSubStageMatrix(serviceId,subStageName,srv.toBeCancelled__c,srv.csord__Status__c); 
                    // System.debug('serviceId-->'+serviceId + 'subStageName===>'+subStageName + 'srv.toBeCancelled__c-->'+srv.toBeCancelled__c + 'srv.csord__Status__c==>'+srv.csord__Status__c);  
                    //System.debug('finalSubStageMatrix===>'+finalSubStageMatrix);  
                    serviceIdList.add(srv.Id);  
                    servSubMap.put(srv.Id,srv.csord__Subscription__c);  
                    servtobecancelledMap.put(srv.Id,srv.toBeCancelled__c);  
                }   
                //code comented as part of EDGE-160369  
                /* List<csord__Subscription__c> subscriptionlist = [select id,NetworkserviceId__c from  csord__Subscription__c where id IN:subList LIMIT 1];    
if(!subscriptionlist.isEmpty()){    
subscriptionlist[0].NetworkserviceId__c = NetworkServiceId; 
system.debug ('updateServiceList::'+updateServiceList); 
system.debug ('subscriptionlist::'+subscriptionlist);}*/    
                List<Id> subIdsList = new List<Id>();   
                if(!subIdtoNetworkSServIDMap.isEmpty()){    
                    subIdsList.addAll(subIdtoNetworkSServIDMap.keySet());}  
                if(!subIdtoEstimatedPoNRDateMap.isEmpty()){ 
                    subIdsList.addAll(subIdtoEstimatedPoNRDateMap.keySet());    
                }   
                //EDGE-204029 Start 
                if(!mapSubIdtoCustomerFacingId.isEmpty()){  
                    subIdsList.addAll(mapSubIdtoCustomerFacingId.keySet()); 
                }   
                //EDGE-204029 End   
                for(csord__Subscription__c sub :[select id,NetworkserviceId__c,Estimated_PoNR_Date__c,customerFacingServiceId__c from  csord__Subscription__c where id IN:subIdsList]) //added as part of EDGE-160369   
                {   
                    
                    if(subIdtoNetworkSServIDMap.containsKey(sub.id)){   
                        sub.NetworkserviceId__c = subIdtoNetworkSServIDMap.get(sub.id); 
                        
                     }   
                    if(subIdtoEstimatedPoNRDateMap.containsKey(sub.id)){    
                        sub.Estimated_PoNR_Date__c = subIdtoEstimatedPoNRDateMap.get(sub.id);  
                        
                    }   
                    //EDGE-204029 Start 
                    if(mapSubIdtoCustomerFacingId.containsKey(sub.id)){ 
                        sub.customerFacingServiceId__c = mapSubIdtoCustomerFacingId.get(sub.id);  
                          
                    }   
                    //EDGE-204029 End   
                   
                    subscriptionlist.add(sub);
                    
                }  
                system.debug('subscriptionlist---->'+subscriptionlist); 
                if(!updateServiceList.isEmpty()){   
                    try {   
                        update updateServiceList;   
                    }   
                    catch(DmlException e) { 
                        logException('processSubStageNotification', '', correlationId, e.getMessage() + ' - ' + e.getLineNumber(), 'Error while updating service records'); 
                        if(enableThrowException){throw e;} //EDGE-215225    
                    }   
                }   
                if(!subscriptionlist.isEmpty()){    
                    try {   
                        update subscriptionlist;    
                    }   
                    catch(DmlException e) { 
                        logException('processSubStageNotification', '', correlationId, e.getMessage() + ' - ' + e.getLineNumber(), 'Error while updating subscription records');    
                        if(enableThrowException){throw e;} //EDGE-215225    
                    }   
                }   
                if(!serSpecifications.isEmpty()){   
                    try {   
                        System.debug('serSpecifications:::' + serSpecifications);   
                        insert serSpecifications;   
                    }   
                    catch(DmlException e) { 
                        logException('processSubStageNotification', '', correlationId, e.getMessage() + ' - ' + e.getLineNumber(), 'Error while inserting specification records');  
                        if(enableThrowException){throw e;}//EDGE-215225 
                    }   
                }   
                SerSpecificationsList.addAll(serSpecifications);    
                //----- create subStageNotification Records 
                Map<String, Service_Specification__c> srvSpecMap = new Map<String, Service_Specification__c>(); 
                for(Service_Specification__c srvSpec: SerSpecificationsList) {  
                    System.debug('svcIdSvcMap :: '+ svcIdSvcMap);   
                    System.debug('srvSpec.Id :: '+ srvSpec.Id); 
                    //  System.debug('srvSpecMap.get(srvSpec.Id :: '+ srvSpecMap.get(srvSpec.Id));  
                    //  System.debug('svcIdSvcMap.get(srvSpec.Service__c).csordtelcoa__Replaced_Service__c  :: '+ (svcIdSvcMap.get(srvSpec.Service__c)).csordtelcoa__Replaced_Service__c ); 
                    /*  if(srvSpecMap.get(srvSpec.guid__c) != null){    
if((svcIdSvcMap.get(srvSpec.Service__c)).csordtelcoa__Replaced_Service__c != null && (svcIdSvcMap.get(srvSpec.Service__c)).csord__Status__c != null && (svcIdSvcMap.get(srvSpec.Service__c)).csord__Status__c.containsIgnoreCase('In Progress') ){ //EDGE-189531 : Updated condition to support MAC on MAC scenarios    
srvSpecIdSet.add(srvSpec.Id);   
srvSpecMap.put(srvSpec.guid__c,srvSpec);    
}   
}   
else{   
srvSpecIdSet.add(srvSpec.Id);   
srvSpecMap.put(srvSpec.guid__c,srvSpec);    
}   
//EDGE-189531 : Keeping the commented code for reference, will remove in subsquent release if there is no impact    
*/  
                    //EDGE-189531 : Only putting check for status, as substage record should only be created for the latest service and that order would contain status In Progress.    
                    //csord__Order__r.csord__Status2__c 
                    if(svcIdSvcMap.get(srvSpec.Service__c).csord__Order__r.csord__Status2__c != null && svcIdSvcMap.get(srvSpec.Service__c).csord__Order__r.csord__Status2__c.containsIgnoreCase('In Progress')){   
                        srvSpecIdSet.add(srvSpec.Id);   
                        srvSpecMap.put(srvSpec.guid__c,srvSpec);    
                    }   
                }   
                System.debug('srvSpecMap::' + srvSpecMap);  
                List<subStageNotification__c> subStageNotifList = new List<subStageNotification__c>();  
                String ordId;   
                String svcNumber;   
                String instId;  
                Map<String,String> servSubstageMap = new Map<String,String>();  
                for(NotificationParameters noti :paramsList){   
                    subStageNotification__c subStageNotif = new subStageNotification__c();  
                    List<String> keyparams = noti.orderItemId.split('\\|'); 
                    if(keyparams.size() > 0){ ordId = keyparams[0]; }   
                    if(keyparams.size() > 1){ svcNumber = keyparams[1]; }   
                    if(keyparams.size() > 2){ instId = keyparams[2]; }  
                    ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{'+String.valueOf(noti.notificationAttributes)+'}');    
                    System.debug('notifyAttrs:::' + notifyAttrs);   
                    //----- Extract subStage details from Notification Attributes   
                    for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes){  
                        if(attr.name.contains('subStage')){ 
                            subStageNotif.Name = attr.value;    
                            servSubstageMap.put(svcNumber,subStageNotif.Name);  
                        }   
                        if(attr.name.contains('currentForecastedDeliveryDate')) {   
                            forecastedDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class); }  
                        else if(attr.name.contains('DesignCompletionDate')||attr.name.contains('EquipmentOrderedDate')||attr.name.contains('EquipmentDeliveredDate')||attr.name.contains('InstallationDate')||attr.name.contains('ServiceActivationDate')||attr.name.contains('CustomerOrderAcceptanceDate') ||attr.name.contains('ServiceDeactivationDate')||attr.name.contains('DeviceRecoveredDate')){   
                            subStageNotif.Substage_Completion_Date__c  = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);}   
                    }   
                    System.debug('subStageNotif.Name===>'+subStageNotif.Name);  
                    if(srvSpecMap.size()>0 && srvSpecMap.containsKey(instId)){subStageNotif.Service_Specification__c = srvSpecMap.get(instId).Id;   
                                                                              System.debug('srvSpecMap.get(instanceId).Id===>'+srvSpecMap.get(instId).Id);  
                                                                             }  
                    subStageNotifList.add(subStageNotif);   
                    toLog += '*'+noti.orderItemId+'-->'+subStageNotif.Name+'-->'+noti.msCorrelationId+'\n'; 
                }   
                for(csord__Service__c sr:[SELECT Id, Name, csord__Status__c, csord__Subscription__c, csord__Order__c, csord__Order__r.csord__Status2__c, csordtelcoa__Service_Number__c from csord__Service__c where csordtelcoa__Service_Number__c IN:servSubstageMap.keySet() order by CreatedDate DESC]){    
                    srIdSubstageMap.put(sr.id,servSubstageMap.get(sr.csordtelcoa__Service_Number__c));  
                }   
                finalSubStageMatrix= getSubStageMatrix(serviceIdList,srIdSubstageMap,servtobecancelledMap); 
                if(!subStageNotifList.isEmpty()){   
                    try {   
                        insert subStageNotifList;   
                    }   
                    catch(DmlException e) { 
                        logException('processSubStageNotification', '', correlationId, e.getMessage() + ' - ' + e.getLineNumber(), 'Error while inserting sub stage notification records'); 
                        if(enableThrowException){throw e;}//EDGE-215225 
                    }   
                }   
                // List<subStageNotification__c> subStageNotifList = new List<subStageNotification__c>([Select Id,Name,Service_Specification__c,Substage_Completion_Date__c FROM subStageNotification__c WHERE Name =: subStageName and Service_Specification__c IN : srvSpecIdSet]);   
                //----- create subStageNotificationMap based on subStageName Received in Notification   
                //System.debug('subStageName::' + subStageName);    
                List<Service_Specification__c> serSpecList = [Select Id, name,Service__c, Code__c, guid__c, (Select Name,Service_Specification__c from subStageNotifications__r) from Service_Specification__c where service__c IN: serviceIdList]; 
                String subNotification; 
                System.debug('serSpecList::' + serSpecList);    
                Map<String,String> subStageNotificationMap  = new Map<String,String>(); 
                //Set<String> specCodeSet = new Set<String>();  
                Set<String> guidSet = new Set<String>();    
                for(Service_Specification__c serSpec : serSpecList) {   
                    system.debug('erSpec.Name'+serSpec.Name);   
                    system.debug('serSpec.service__c'+serSpec.service__c);  
                    system.debug('serSpec364'+servIdSubstageMap.get(serSpec.service__c));   
                    if(serSpec.Name ==servIdSubstageMap.get(serSpec.service__c)){   
                        subNotification = '';   
                        for(subStageNotification__c subNotif : serSpec.subStageNotifications__r){subNotification = subNotif.Name;   
                                                                                                }   
                        if(subNotification.containsIgnoreCase(subStageName)) {subStageNotificationMap.put(serSpec.Code__c,subNotification.toLowerCase(UserInfo.getLocale()));   
                                                                             }  
                        //specCodeSet.add(serSpec.Code__c); 
                    }   
                    guidSet.add(serSpec.guid__c);   //added as part of EDGE-186051  
                    system.debug('guidSet369'+guidSet); 
                }   
                // System.debug('specCodeSet::' + specCodeSet); 
                //----- Update additional attributes of Service Specs with attributes from orderItemDetails & notificationAttributes    
                //if(subStageName.containsIgnoreCase('Product Requirements Validation')){   
                // List<csord__Service__c> srvList = [Select Id,Name from csord__Service__c where csord__Subscription__c  =: subscriptionId];   
                system.debug('guidSet377'+guidSet); 
                getGuidAttr(paramsList,childService,getGuidAdditionalAttributes(serviceListData,serIdList),serviceIDList);  
                //EDGE-105575 : quering CFSID from subs to populate it.//Query modified for NetworkServiceId    
                /* List<csord__Subscription__c> subList = [Select Id, Name, customerFacingServiceId__c,NetworkserviceId__c from csord__Subscription__c where Id = :subscriptionIdList]; 
Map<Id,Attachment> updatedGuidAttrMap = new Map <Id,Attachment>();  
if(!subList.isEmpty()){ 
if(guidAttrMap != NULL){    
//EDGE-105575 : roll-up CFS ID at subscription  
if(guidAttrMap.containskey(instanceId)){    
subsc.customerFacingServiceId__c = guidAttrMap.get(instanceId).get('CustomerFacingServiceId');  
//NetworkServiceId rolled up to subscription    
subsc.NetworkserviceId__c = NetworkServiceId;   
update subsc;   
}   
}*/ 
                //End   
                /*  for(String guid : guidAttrMap.keySet()){    
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
*/  
                servguidMap = getGuidList(serviceListData,serIdList);   
                /*if(!updatedGuidAttrMap.isEmpty()){    
update updatedGuidAttrMap.values(); 
}*/ 
                //} 
                //if(!subStageName.containsIgnoreCase('Product Requirements Validation')){  
                getGuidNotifAttr(getGuidAdditionalAttributes(serviceListData,serIdList),paramsList,seridNumberMap); 
                /* Map<Id,Attachment> updatedNotifAttrMap = new Map <Id,Attachment>();  
System.debug('notifAttrMap.values()'+notifAttrMap.values());    
if(notifAttrMap.values() != NULL){  
for(String guid : notifAttrMap.keySet()){   
csedm.API_1.addCharacteristic(serviceId, guid, notifAttrMap.get(guid)); 
//updatedNotifAttrMap = ServiceSpecificationUtils.getAddCharacteristic(serviceID,guid,notifAttrMap.get(guid));  
}   
}*/ 
                /* System.debug('updatedNotifAttrMap'+updatedNotifAttrMap); 
if(!updatedNotifAttrMap.isEmpty()){ 
update updatedNotifAttrMap.values();    
}*/ 
                system.debug('before if========='); 
                //-----Roll-up subStage & stage fields of Services, Subscriptions, Orders-//EDGE-80847  
                if(finalSubStageMatrix.equals(subStageNotificationMap)){    
                    system.debug('inside if========='); 
                    // if(!subStageName.containsIgnoreCase(System.Label.EquipmentOrdered) && !subStageName.containsIgnoreCase(System.Label.EquipmentDelivered)){    
                    //   System.debug('Inside If with subStageName:'+subStageName); 
                    system.debug('subscriptionIdList'+subscriptionIdList);  
                    system.debug('guidSet'+guidSet);    
                    List<String> allServiceSet = getChildServices(subscriptionIdList, guidSet); 
                    allServiceSet.addAll(serviceIdList);    
                    System.debug('allServiceSet::' + allServiceSet);    
                    System.debug('servIdSubstageMap::' + servIdSubstageMap);    
                    updateServices(allServiceSet, servIdSubstageMap);   
                    // }    
                    //updateSubscriptions(subscriptionIdList,'subStage',mapNotifyAttr); //EDGE-103758 Commented new method is made as part of EDGE-168182   
                    updateSubscriptions(subscriptionIdList,'subStage');//EDGE-168182    
                    // if(!subStageName.containsIgnoreCase(System.Label.EquipmentOrdered) && !subStageName.containsIgnoreCase(System.Label.EquipmentDelivered)){    
                    updateOrderSubStage(ordList);   
                    // }    
                }   
                /*   //notif.Status__c = 'Completed';   
//System.debug('notif.Status__c'+notif.Status__c);  
Boolean isSubLogicallyDeactivated = false;  
// if(subStageName == System.Label.LogicalDeactivation){    
System.debug('Inside Logical deactivation ');   
// isSubLogicallyDeactivated = checkSubscriptionDeactivation(serviceId, subscriptionId, subStageName);  
System.debug('isSubLogicallyDeactivated===>'+isSubLogicallyDeactivated);    
// }    
if(isSubLogicallyDeactivated){  
csord__Subscription__c subToUpdate = [Select id,name,Trigger_RTS__c from csord__Subscription__c where Id =: subscriptionId];    
System.debug('subToUpdate=====>'+subToUpdate);  
subToUpdate.Trigger_RTS__c = true;  
update subToUpdate; 
}   
*/  
                Map<Id,boolean> servCheckDeactivationMap = checkSubscriptionDeactivation(serviceIdList);    
                List<Id> SubIdList = new List<Id>();    
                if(!servCheckDeactivationMap.isEmpty()) 
                {   
                    for(Id ser :servCheckDeactivationMap.keyset()){ if(servCheckDeactivationMap.get(ser)== true){SubIdList.add(servSubMap.get(ser));System.debug('servSubMap.get(ser) : '+servSubMap.get(ser)); 
                                                                                                                }   
                                                                  } 
                }   
                List<csord__Subscription__c> subToUpdate = [Select id,name,Trigger_RTS__c from csord__Subscription__c where Id IN: SubIdList];  
                if(!subToUpdate.isEmpty()){for(csord__Subscription__c sub :subToUpdate){sub.Trigger_RTS__c = true;} 
                                           update subToUpdate;  
                                          } 
                InvokeInventoryPublishEvents.publishServiceSpecificationHandlerMSUpdate(servguidMap);   
            }   
            if(!String.isBlank(toLog)){ 
                Logger2 log = Logger2.getLogger('SubStageNotifications');   
                log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false,200,'','','');    
                log.exitLogger();   
            }   
        }   
        catch(Exception e) {    
            // notif.Status__c = 'Error';   
            // notif.Internal_Error_Description__c = e.getTypeName() +', '+ e.getMessage() + ', ' + e.getLineNumber();  
            logException('processSubStageNotification', '', correlationId, e.getMessage() + ' - ' + e.getLineNumber(), 'Error while processing substage notifications');    
            if(enableThrowException){throw e;}//EDGE-215225 
        }   
        // update notif;    
        // System.debug('notif updated');   
    }   
    //----- get guid List   
    public static Map<String,Set<String>>getGuidList(List<csord__Service__c> serviceList,List<Id>serid){    
        Map<String,String> addAttrMap = NULL;   
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();   
        List<csord__Service__c> childService = new List<csord__Service__c>();   
        Map<String,Set<String>> srvnumguidMap = new Map<String,Set<String>>();//EDGE-184831 
        Map<id,string>serguidMap = new Map<id,string>();    
        Map<Id,String> serIdguidMap = new Map<Id,String>(); 
        Map<Id,String> serAttachmentMap = new Map<Id,String>(); 
        Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();   
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        List<Id>childidList = new List<Id>();   
        System.debug('serid:::'+serid); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serid]){    
            System.debug('att.body.toString()::'+att.body.toString());  
            serAttachmentMap.put(att.parentId,att.body.toString()); 
            servAttachmentRecordMap.put(att.parentId,att);  
        }   
        for(csord__Service__c serv : serviceList){  
            List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serAttachmentMap.get(serv.Id)),'FULFILMENT');    
            system.debug('srvspecList::'+srvspecList);  
            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){    
                system.debug('srvSpec guid ::'+srvSpec.guid);   
                addAttrMap = new Map<String,String>();  
                for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){   
                    addAttrMap.put(attr.name,attr.value);}  
                guidAddAttrMap.put(srvSpec.guid,addAttrMap);    
                serIdguidMap.put(serv.id,srvSpec.guid); 
                if(serv.csord__Services__r != null){    
                    childService.addAll(serv.csord__Services__r);}  
            }   
        }   
        system.debug('childService::'+childService);    
        for(csord__Service__c childs : childService){   
            childidList.add(childs.id); 
        }   
        system.debug('serAttachmentMap before loop::'+serAttachmentMap);    
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :childidList]){  
            serAttachmentMap.put(att.parentId,att.body.toString()); 
            system.debug('serAttachmentMap9::'+serAttachmentMap);   
            servAttachmentRecordMap.put(att.parentId,att);  
        }   
        system.debug('servAttachmentRecordMap::'+servAttachmentRecordMap);  
        system.debug('serIdguidMap::'+serIdguidMap);    
        for(Id ser :serIdguidMap.keySet()){ 
            String attach =csedm.API_1.addCharacteristic(serAttachmentMap.get(ser),ser, serIdguidMap.get(ser), guidAddAttrMap.get(serIdguidMap.get(ser)));  
            system.debug('attach::'+attach);    
            Attachment attAdd = servAttachmentRecordMap.get(ser);   
            attAdd.body = Blob.valueOf(attach); 
            serAttachmentMap.put(attAdd.parentId,attAdd.Body.toString());   
            updatedAttSet.put(attAdd.id,attAdd);    
            system.debug('serAttachmentMap1::'+serAttachmentMap);   
            serguidMap.put(ser,serIdguidMap.get(ser));  
            if(childService!= null){    
                for(csord__Service__c childs : childService){   
                    string childatt =csedm.API_1.addCharacteristic(serAttachmentMap.get(childs.Id),childs.Id,serIdguidMap.get(ser), guidAddAttrMap.get(serIdguidMap.get(ser))); 
                    system.debug('childatt::'+childatt);    
                    Attachment ChildattAdd = servAttachmentRecordMap.get(childs.Id);    
                    ChildattAdd.body = Blob.valueOf(childatt);  
                    serAttachmentMap.put(ChildattAdd.parentId,ChildattAdd.Body.toString()); 
                    updatedAttSet.put(ChildattAdd.id,ChildattAdd);  
                    serguidMap.put(ser,serIdguidMap.get(ser));  
                    system.debug('serAttachmentMap2::'+serAttachmentMap);   
                }}  
        }   
        system.debug('updatedAttSet::'+updatedAttSet);  
        if(!updatedAttSet.isEmpty()){   
            update updatedAttSet.values();  
        }   
        for(csord__Service__c srv :[select id, csordtelcoa__Service_Number__c, csord__Order__r.csord__Status2__c from csord__Service__c where id IN:serguidMap.keyset()]){  
            Set<String> gid = new Set<String>(); //EDGE-184831  
            gid.add(serguidMap.get(srv.id));    
            srvnumguidMap.put(srv.csordtelcoa__Service_Number__c,gid);  
        }   
        System.debug('srvnumguidMap::' + srvnumguidMap);    
        return srvnumguidMap;   
    }   
    //-----Utility Functions    
    //  
    //----- get Map of guid & existing additionalAttributes from ServiceSpecs to update ServiceSpecs -----//    
    public static Map<String,Map<String,String>> getGuidAdditionalAttributes(List<csord__Service__c> serviceList,List<Id>serId){    
        //system.debug('serviceList::570'+serviceList); 
        // system.debug('serId::571'+serId);    
        Map<String,String> addAttrMap = NULL;   
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();   
        Map<Id,String> serAttachmentMap = new Map<Id,String>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serId]){    
            serAttachmentMap.put(att.parentId,att.body.toString()); 
        }   
        //system.debug('serAttachmentMap::578'+serAttachmentMap);   
        for(csord__Service__c serv : serviceList){  
            // system.debug('serv::580'+serv);  
            List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serAttachmentMap.get(serv.Id)),'FULFILMENT');    
            // system.debug('srvspecList::580'+srvspecList);    
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
    public static void getGuidAttr(List<NotificationParameters> paramsList,List<csord__Service__c> childService,Map<String,Map<String,String>> guidAddAttribMap,List<Id>serviceIdList ){    
        Map<String,Map<String,String>> servnumDeviceMap = new Map<String,Map<String,String>>(); 
        Map<String,String> servnumDeviceBlankMap = new Map<String,String>();    
        Map<String,Map<String,String>> guidAttrMap = new Map<String,Map<String,String>>();  
        //List<String> deviceList = new List<String>(); 
        //Map<String,String> deviceMap = new Map<String,String>();  
        List<String> deviceTypeList = new List<String>();   
        List<String> srvcNumberList = new List<String>();   
        Map<String,String> corIdOrderItemIdMap = new Map<String,String>();  
        Map<String,csord__Service__c> sernumServiceMap = new Map<String,csord__Service__c>();   
        Map<String,Exclusion_List_NotifAtts__c> mapNotifAttsToExclude = Exclusion_List_NotifAtts__c.getAll();   //EDGE-147219   
        //EDGE-158047--Start********************************************    
        Map<Id,csord__Service__c> childServMap=new Map<Id,csord__Service__c>(); 
        Map<Id,String> serAttachmentMap = new Map<Id,String>(); 
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        //Map<String,String> childDeviceMap = new Map<String,String>(); 
        List<Id>childidList = new List<Id>();   
        List<String> childSrvcNumberList = new List<String>();  
        Map<String,Attachment> prodIdtoAttachmentMap=new Map<String,Attachment>();  
        Map<String,String> guidToChildservMap=new Map<String,String>(); 
        //Map<String,Map<String,String>> guidChildAttrMap = new Map<String,Map<String,String>>();   
        //string DevIdtype; 
        Map<String,String> addAttrMap = new Map<String,String>();   
        system.debug('childService'+childService);  
        for(csord__Service__c childs : childService){   
            childidList.add(childs.id); 
            childServMap.put(childs.id,childs); 
        }   
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :childidList]){  
            serAttachmentMap.put(att.parentId,att.body.toString()); 
            servAttachmentRecordMap.put(att.parentId,att);  
        }   
        for(csord__Service__c srv :childServMap.values()){  
            List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(srv.id)),'FULFILMENT');  
            for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){ 
                prodIdtoAttachmentMap.put(spec.guid,servAttachmentRecordMap.get(srv.id));   
                guidToChildservMap.put(spec.guid,srv.Id);   
                system.debug('spec.guid'+spec.guid);    
                addAttrMap = new Map<String,String>();  
                for(CS_SpecificationDTO.SimpleAttributes attr :spec.additionalAttributes){ //added as part of EDGE-164886   
                    addAttrMap.put(attr.name,attr.value);}  
                guidAddAttribMap.put(spec.guid,addAttrMap); 
            }   
        }   
        //guidAddAttribMap.putAll(guidChildAttrMap); //added as part of EDGE-164886 
        system.debug('guidAddAttribMap::640'+guidAddAttribMap); 
        system.debug('childServMap'+childServMap);  
        //EDGE-158047--End********************************************  
        Map<String,Map<String,String>> mapMobilechildAttrMap = new Map<String,Map<String,String>>();//EDGE-181842   
        for(NotificationParameters notification :paramsList){   
            Map<String,String> attrMap = new Map<String,String>();  
            Map<String,String> childAttrMap = new Map<String,String>(); 
            Map<String,String> childDeviceMap = new Map<String,String>();   
            Map<String,String> notifAttrMapservice = new Map<String,String>(); //EDGE-174900    
            List<String> deviceIds = new List<String>();    
            Map<String,String> allattrMap = new Map<String,String>();//EDGE-192006  
            String deviceType;  
            //EDGE-174900 start 
            ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{'+String.valueOf(notification.notificationAttributes)+'}');    
            for(ManageOrderNotificationUtil.NotificationAttributes notifAttr : notifyAttrs.attributes){ 
                //EDGE-EDGE-17340620.12 
                if(notifAttr.name.containsIgnoreCase('ServiceActivationDate') || notifAttr.name.containsIgnoreCase('productCompletionDate') || notifAttr.name.containsIgnoreCase('currentForecastedDeliveryDate') || notifAttr.name.containsIgnoreCase('telstraCommittedDate')|| notifAttr.name.contains('EquipmentDeliveryFailedDate')){   
                    notifAttrMapservice.put(notifAttr.name,notifAttr.value);    
                }   
            }//EDGE-174900 end  
            system.debug('notifAttrMapservice' +notifAttrMapservice);   
            //Map<String,Map<String,String>> guidChildAttrMap = new Map<String,Map<String,String>>();   
            System.debug('my OrderItem::'+notification.orderItemDetails);   
            ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse('{'+String.valueOf(notification.orderItemDetails)+'}');  
            system.debug('productUpdates:'+productUpdates); 
            String orderId; 
            String srvcNumber;  
            String instance;    
            Map<String,String> deviceMap = new Map<String,String>();    
            List<String> deviceList = new List<String>();   
            string DevIdtype;   
            List<String> keyparams = notification.orderItemId.split('\\|'); 
            if(keyparams.size() > 0){ orderId = keyparams[0]; } 
            if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }  
            if(keyparams.size() > 2){ instance = keyparams[2]; }    
            corIdOrderItemIdMap.put(notification.msCorrelationId,notification.orderItemId); 
            srvcNumberList.add(srvcNumber); 
            system.debug('productUpdates.attributes>>>'+ productUpdates.attributes);    
            if(productUpdates.attributes != NULL){  
                if(productUpdates.productId != null && guidAddAttribMap.get(productUpdates.productId) != null){ 
                    attrMap.putAll(guidAddAttribMap.get(productUpdates.productId)); 
                    allattrMap.putAll(guidAddAttribMap.get(productUpdates.productId));//EDGE-192006 
                }   
                for(ManageOrderNotificationUtil.NotificationAttributes attr : productUpdates.attributes){   
                    //attrMap.putAll(guidAddAttribMap.get(productUpdates.productId));   
                    //EDGE-147219 : If attribute is in exclude list then not adding it in map   
                    if(!mapNotifAttsToExclude.containsKey(attr.name)){  
                        attrMap.put(attr.name,attr.value);  
                        allattrMap.put(attr.name,attr.value);//EDGE-192006  
                    }   
                    system.debug('attrMap 647'+attrMap);    
                    // attrMap.put(attr.name,attr.value);   
                    system.debug('attr Name>>>'+ attr.name);    
                    //EDGE-80847    
                    if(attr.name.equalsIgnoreCase('DeviceID'))  
                    {if(attr.value !=null && String.isNotBlank(attr.value)){    
                        for(String di: attr.value.split(',')){deviceList.add(di);   
                                                             }  
                    }   
                     else{  
                         servnumDeviceBlankMap.put(srvcNumber,'Blank'); //EDGE-170530   
                     }  
                    }   
                    if(attr.name.equalsIgnoreCase('DeviceIDType')){ 
                        if(attr.value !=null&& String.isNotBlank(attr.value)){  
                            DevIdtype=attr.value;   
                        }   
                    }   
                    /*if(attr.name.equalsIgnoreCase('tenancyId')){ if(attr.value !=null){tenancyId = attr.value;}   
}*///EDGE-174212    
                }   
                for(string deviceId :deviceList){   
                    if(deviceId != null && DevIdtype!= null){   
                        deviceMap.put(deviceId,DevIdtype);} }   
                if(servnumDeviceMap.containsKey(srvcNumber)) //added as part of EDGE-158047 
                {   
                    Map<String,String> tempMap=servnumDeviceMap.get(srvcNumber);    
                    tempMap.putAll(deviceMap);  
                    servnumDeviceMap.put(srvcNumber,tempMap);   
                }else{  
                    servnumDeviceMap.put(srvcNumber,deviceMap); 
                }   
                //servnumDeviceMap.put(srvcNumber,deviceMap);   
                system.debug('servnumDeviceMap 673'+servnumDeviceMap);  
                system.debug('srvcNumber674'+srvcNumber);   
                if(guidAttrMap.containsKey(productUpdates.productId)) // EDGE-188475    
                {   
                    Map<String,String> tempMap=guidAttrMap.get(productUpdates.productId);   
                    tempMap.putAll(attrMap);    
                    guidAttrMap.put(productUpdates.productId,tempMap);  
                }else{  
                    guidAttrMap.put(productUpdates.productId,attrMap);  
                }   
                system.debug('guidAttrMap 667'+guidAttrMap);    
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
                            system.debug('childAttr>>>>>>' + childAttr.name + '>>>>>' + childAttr.value);   
                            if(childAttr.name.equalsIgnoreCase('DeviceID')){    
                                if(childAttr.value!= null && String.isNotBlank(childAttr.value)){   
                                    for(String di: childAttr.value.split(',')){deviceIds.add(di); } }   
                                else{   
                                    servnumDeviceBlankMap.put(srvcNumber,'Blank'); //EDGE-170530    
                                }   
                            }   
                            if(childAttr.name.equalsIgnoreCase('DeviceIDType')){    
                                deviceType = childAttr.value;   
                            }   
                            /*if(childAttr.name.equalsIgnoreCase('tenancyId')){ 
// tenancyId = childAttr.value; 
}*///EDGE-174212    
                            childAttrMap.put(childAttr.name,childAttr.value);   
                            allattrMap.put(childAttr.name,childAttr.value);//EDGE-192006    
                        }   
                        system.debug('allattrMap>>>>>'+allattrMap); 
                        mapMobilechildAttrMap.put(srvcNumber,allattrMap);//EDGE-192006 EDGE-181842,EDGE-189142 Putting correct map  
                        //mapMobilechildAttrMap.put(srvcNumber,attrMap);//EDGE-181842,EDGE-189142 Putting correct map   
                        system.debug('deviceIds before loop:'+deviceIds);   
                        for(string deviceId :deviceIds){    
                            if(  deviceId!= null &&  deviceType!= null){    
                                childDeviceMap.put (deviceId,deviceType);} //added as part of EDGE-158047   
                            system.debug('childAttrMap 715:'+childAttrMap);                                                  }  
                        //added as part of EDGE-158047 --start  
                        if(prodIdtoAttachmentMap.get(childProd.productId)!=null){   
                            List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(prodIdtoAttachmentMap.get(childProd.productId)),'FULFILMENT');   
                            for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){ 
                                system.debug('spec.guid'+spec.guid);    
                                system.debug('childProd.productId'+childProd.productId);    
                                if(spec.guid==childProd.productId)  
                                { system.debug('inside if');    
                                 // EDGE-188475 
                                 if(servnumDeviceMap.containsKey(childServMap.get(spec.serviceId).csordtelcoa__Service_Number__c)){ 
                                     Map<String,String> temp = servnumDeviceMap.get(childServMap.get(spec.serviceId).csordtelcoa__Service_Number__c);   
                                     temp.putAll(childDeviceMap);   
                                     servnumDeviceMap.put(childServMap.get(spec.serviceId).csordtelcoa__Service_Number__c,temp);    
                                 }else{ 
                                     servnumDeviceMap.put(childServMap.get(spec.serviceId).csordtelcoa__Service_Number__c,childDeviceMap); }    
                                 childSrvcNumberList.add(childServMap.get(spec.serviceId).csordtelcoa__Service_Number__c);  
                                }   
                            }}  
                        //EDGE-158047--End  
                        system.debug('servnumDeviceMap'+servnumDeviceMap);  
                        system.debug('childSrvcNumberList'+childSrvcNumberList);    
                    }   
                    //guidChildAttrMap = new Map<String,Map<String,String>>();  
                    system.debug('childProd.productId::'+childProd.productId);  
                    //childAttrMap.putAll(attrMap);//prajakta   
                    if(notifAttrMapservice.size()>0){   
                        childAttrMap.putAll(notifAttrMapservice); //EDGE-174900 
                    }   
                    if(guidAttrMap.containsKey(childProd.productId)){   
                        Map<String,String> childallAttributeMap = guidAttrMap.get(childProd.productId); 
                        childallAttributeMap.putAll(childAttrMap);  
                        guidAttrMap.put(childProd.productId,childallAttributeMap);  
                    }   
                    else{   
                        guidAttrMap.put(childProd.productId,childAttrMap); }    
                    system.debug('guidAttrMap on 870:'+guidAttrMap);    
                    //added as part of EDGE-164886  
                    //code commented  as part of EDGE-164886    
                    /*if(guidChildAttrMap.containsKey(childProd.productId)) //added as part of EDGE-158047  
{   
Map<String,String> tempMap=guidChildAttrMap.get(childProd.productId);   
tempMap.putAll(childAttrMap);   
guidChildAttrMap.put(childProd.productId,tempMap);  
}else{  
guidChildAttrMap.put(childProd.productId,childAttrMap); 
}*/ 
                    // system.debug('guidChildAttrMap 745:'+guidChildAttrMap);  
                }   
                // system.debug('guidChildAttrMap 781:'+guidChildAttrMap);  
                //guidAttrMap.putAll(guidChildAttrMap); 
                system.debug('guidAttrMap 749:'+guidAttrMap);   
                /*if(!srvcNumberList.isEmpty() && (childAttrMap.ContainsKey('IMSI') ||  
childAttrMap.ContainsKey('SIMSerialNumber'))){ ////EDGE-144111,EDGE-149605  
updateNumberrecords(srvcNumberList, childAttrMap);  
} */    
            }   
            system.debug('childAttrMap>>>'+childAttrMap);   
        }   
        //EDGE-181842 it will collect all notification and call once the method 
        if(!mapMobilechildAttrMap.isEmpty()){   
            updateNumberrecords(srvcNumberList, mapMobilechildAttrMap); 
        }   
        system.debug('guidAttrMap made:'+guidAttrMap);  
        List<csord__Service__c> serList = [SELECT Id, csordtelcoa__Service_Number__c FROM   
                                           csord__Service__c WHERE csordtelcoa__Service_Number__c IN:srvcNumberList];   
        List<Id>serid = new  List<Id>();    
        Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();   
        for(csord__Service__c ser:serList){ 
            sernumServiceMap.put(ser.csordtelcoa__Service_Number__c,ser);   
            serid.add(ser.id);  
        }   
        //Map<Id,String> serAttachmentMap = new Map<Id,String>(); // commented as part of EDGE-158047 - added code at beginning of method   
        //Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); // commented as part of EDGE-158047 - added code at beginning of method   
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serid]){    
            serAttachmentMap.put(att.parentId,att.body.toString()); 
            servAttachmentRecordMap.put(att.parentId,att);  
        }   
        /*List<Id>childidList = new List<Id>();   // code commented as part of EDGE-158047 - added code at beginning of method  
for(csord__Service__c childs : childService){   
childidList.add(childs.id); 
}   
for(Attachment att: [Select id,body,parentId from Attachment where parentId in :childidList]){  
serAttachmentMap.put(att.parentId,att.body.toString()); 
servAttachmentRecordMap.put(att.parentId,att);  
}*/ // --- EDGE-158047 -END 
        system.debug('serList::'+serList);  
        if(guidAttrMap != NULL){    
            system.debug('guidAttrMap::'+guidAttrMap);  
            String ordId;   
            String srvcNum; 
            String inst;    
            for(String cor : corIdOrderItemIdMap.keySet()){ 
                String orderItemid = corIdOrderItemIdMap.get(cor);  
                List<String> keyp = orderItemid.split('\\|');   
                if(keyp.size() > 0){ ordId = keyp[0]; } 
                if(keyp.size() > 1){ srvcNum = keyp[1]; }   
                if(keyp.size() > 2){ inst = keyp[2]; }  
                //EDGE-105575 : roll-up CFS ID at subscription  
                /*if(guidAttrMap.containskey(inst)){    
subsc.customerFacingServiceId__c = guidAttrMap.get(inst).get('CustomerFacingServiceId');    
//NetworkServiceId rolled up to subscription    
subsc.NetworkserviceId__c = NetworkServiceId;   
update subsc;   
}*/ 
                //End   
                system.debug('guidAttrMap::'+guidAttrMap);  
                for(String guid : guidAttrMap.keySet()){    
                    system.debug('sernumServiceMap>>>>'+sernumServiceMap.get(srvcNum).id);  
                    //system.debug('guidAttrMap>>>>'+guidAttrMap.get(guid));    
                    //csedm.API_1.addCharacteristic(sernumServiceMap.get(srvcNum).id, guid, guidAttrMap.get(guid)); 
                    String attach = csedm.API_1.addCharacteristic(serAttachmentMap.get(sernumServiceMap.get(srvcNum).id),sernumServiceMap.get(srvcNum).id, guid, guidAttrMap.get(guid));    
                    system.debug('attach line714::'+attach);    
                    Attachment attAdd = servAttachmentRecordMap.get(sernumServiceMap.get(srvcNum).id);  
                    attAdd.body = Blob.valueOf(attach); 
                    serAttachmentMap.put(attAdd.parentId,attAdd.Body.toString());   
                    updatedAttSet.put(attAdd.id,attAdd);    
                    //updatedGuidAttrMap = ServiceSpecificationUtils.getAddCharacteristic(serviceID,guid,guidAttrMap.get(guid));    
                    system.debug('inside for1::====');  
                    for(csord__Service__c childs : childService){   
                        if(childs.Id==guidToChildservMap.get(guid)){ // code added as part of EDGE-158047   
                            system.debug('childs::::'+childs);  
                            //csedm.API_1.addCharacteristic(childs.Id, guid, guidAttrMap.get(guid));    
                            //updatedGuidAttrMap = ServiceSpecificationUtils.getAddCharacteristic(serviceID,guid,guidAttrMap.get(guid));    
                            system.debug('guid'+guid);  
                            // csedm.API_1.addCharacteristic(childs.Id, guid, guidAttrMap.get(guid));   
                            //system.debug('guidAttrMap.get(guid)'+guidAttrMap.get(guid));  
                            String attachChild = csedm.API_1.addCharacteristic(serAttachmentMap.get(childs.Id),childs.Id, guid, guidAttrMap.get(guid)); 
                            system.debug('attachChild '+attachChild);   
                            Attachment attAddChild = servAttachmentRecordMap.get(childs.Id);    
                            attAddChild.body = Blob.valueOf(attachChild);   
                            serAttachmentMap.put(attAddChild.parentId,attAddChild.Body.toString()); 
                            updatedAttSet.put(attAddChild.id,attAddChild);  
                            system.debug('serAttachmentMap::'+serAttachmentMap);    
                            system.debug('inside for2::====');} 
                    }   
                }   
            }   
        }system.debug('updatedAttSet line 735::'+updatedAttSet);    
        if(!updatedAttSet.isEmpty()){   
            update updatedAttSet.values();  
        }   
        if(!childSrvcNumberList.isEmpty()){ //added as part of EDGE-158047  
            srvcNumberList.addAll(childSrvcNumberList);}    
        system.debug('srvcNumberList::'+srvcNumberList);    
        system.debug('servnumDeviceMap::'+servnumDeviceMap);    
        updateAssets(servnumDeviceMap,srvcNumberList,servnumDeviceBlankMap);    
    }   
    public static void updateAssets(Map<String,Map<String,String>>servnumDeviceMap ,List<string>srvcNumberList,Map<String,String>servnumDeviceBlankMap){    
        AssetUpsertionHelper.updateAssetMSupdate(servnumDeviceMap,srvcNumberList,servnumDeviceBlankMap);  //EDGE-170530 
    }   
    //----- get Map of Parent guid & attributes from notification Attributes to update Service Specifications -----//   
    public static void getGuidNotifAttr( Map<String,Map<String,String>> guidAddAttribMap, List<NotificationParameters> paramsList,Map<String,Id>seridNumberMap){    
        Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();   
        Map<Id,String> serAttachmentMap = new Map<Id,String>(); 
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :seridNumberMap.values()]){  
            serAttachmentMap.put(att.parentId,att.body.toString()); 
            servAttachmentRecordMap.put(att.parentId,att);  
        }   
        Map<String,Map<String,String>> notifAttrMapwithSvcnum = new Map<String,Map<String,String>>(); //EDGE-168182 
        for(NotificationParameters notif :paramsList){  
            Map<String,String> notifAttrMap = new Map<String,String>(); 
            Map<String,Map<String,String>> guidNotifAttrMap = new Map<String,Map<String,String>>(); 
            List<String> keyparams = new List<String>();    
            String orderId; 
            String srvcNumber;  
            // String serviceId;    
            keyparams = notif.orderItemId.split('\\|'); 
            if(!keyparams.isEmpty()){ orderId = keyparams[0]; } 
            if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }  
            /*  for(csord__Service__c ser :[select id, csordtelcoa__Service_Number__c from csord__Service__c where csordtelcoa__Service_Number__c =:srvcNumber]){   
serviceId = ser.id; 
}*/ 
            system.debug('guidAddAttribMap-----'+guidAddAttribMap); 
            ManageOrderNotificationUtil.Product productUpdates = ManageOrderNotificationUtil.parse('{'+String.valueOf(notif.orderItemDetails)+'}'); 
            ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes('{'+String.valueOf(notif.notificationAttributes)+'}');   
            if(productUpdates.productId != null && guidAddAttribMap.get(productUpdates.productId) != null){ 
                //EDGE-168182 start 
                if(!notifAttrMapwithSvcnum.containsKey(srvcNumber)){    
                    notifAttrMap.putAll(guidAddAttribMap.get(productUpdates.productId));    
                    notifAttrMapwithSvcnum.put(srvcNumber,notifAttrMap);    
                }   
                // System.debug('notifAttrMapwithSvcnum::' + notifAttrMapwithSvcnum);   
            }   
            //EDGE-168182 end   
            //notifAttrMap.putAll(guidAddAttribMap.get(productUpdates.productId));  
            for(ManageOrderNotificationUtil.NotificationAttributes notifAttr : notifyAttrs.attributes){ 
                if(!notifAttr.name.containsIgnoreCase('subStage')){ 
                    //EDGE-168182 start 
                    if(!notifAttrMapwithSvcnum.containsKey(srvcNumber)){    
                        notifAttrMap.put(notifAttr.name,notifAttr.value);   
                        //notifAttrMap.putAll(guidAddAttribMap.get(productUpdates.productId));  
                        notifAttrMapwithSvcnum.put(srvcNumber,notifAttrMap);    
                    }   
                    else{   
                        Map<String,String> getattributes1 = new Map<String,String>();   
                        getattributes1.putAll(notifAttrMapwithSvcnum.get(srvcNumber));  
                        notifAttrMap.put(notifAttr.name,notifAttr.value);   
                        getattributes1.putAll(notifAttrMap);    
                        notifAttrMapwithSvcnum.put(srvcNumber,getattributes1);  
                    }   
                    //EDGE-168182 end   
                    //EDGE-80847    
                    // notifAttrMap.put(notifAttr.name,notifAttr.value);    
                    /* if(notifAttr.name.equalsIgnoreCase('tenancyId')){ tenancyId = notifAttr.value;   
}*///EDGE-174212    
                }   
                // System.debug('notifAttrMapwithSvcnum::' + notifAttrMapwithSvcnum);   
            }   
            // guidNotifAttrMap.put(productUpdates.productId,notifAttrMap); EDGE-168182 
            guidNotifAttrMap.put(productUpdates.productId,notifAttrMapwithSvcnum.get(srvcNumber));  
            System.debug('guidNotifAttrMap::' + guidNotifAttrMap);  
            System.debug('notifAttrMapwithSvcnum::' + notifAttrMapwithSvcnum);  
            if(!guidNotifAttrMap.isEmpty()){    
                for(String guid : guidNotifAttrMap.keySet()){   
                    String attach =csedm.API_1.addCharacteristic(serAttachmentMap.get(seridNumberMap.get(srvcNumber)),seridNumberMap.get(srvcNumber), guid, guidNotifAttrMap.get(guid));    
                    System.debug('attach in getGuidNotifAttr ::' + attach); 
                    Attachment attAdd = servAttachmentRecordMap.get(seridNumberMap.get(srvcNumber));    
                    attAdd.body = Blob.valueOf(attach); 
                    serAttachmentMap.put(attAdd.parentId,attAdd.Body.toString());   
                    updatedAttSet.put(attAdd.id,attAdd);    
                }   
            }   
        }   
        System.debug('updatedAttSet in getGuidNotifAttr ::' + updatedAttSet);   
        if(!updatedAttSet.isEmpty()){   
            update updatedAttSet.values();} 
    }   
    //----- get all Child Services of a Parent Service under Subscription -----//   
    public static List<String> getChildServices(List<Id> subscriptionIdList, Set<String> guidSet)   
    {   
        List<String> childServiceSet = new List<String>();  
        Map<Id,csord__Service__c> serviceList = new Map<Id,csord__Service__c>([Select Id,Name, csord__Order__r.csord__Status2__c from csord__Service__c where csord__Subscription__c IN:subscriptionIdList]);   
        Map<Id,String> serviceAttachmentMap = new Map<Id,String>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serviceList.keySet()]){ 
            serviceAttachmentMap.put(att.parentId,att.body.toString()); 
        }   
        for(String eachService: serviceAttachmentMap.keySet()){ 
            List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'FULFILMENT');    
            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){    
                if(srvSpec.additionalAttributes.size()!=0){ 
                    for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){   
                        if(attr.name.containsIgnoreCase('parentSpec') && guidSet.contains(attr.value)){ 
                            childServiceSet.add(eachService);   
                        }   
                    }   
                }   
            }   
        }   
        /* for(csord__Service__c serv : serviceList){   
List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serv.Id),'FULFILMENT');  
for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){    
if(srvSpec.additionalAttributes.size()!=0){ 
for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){   
if(attr.name.containsIgnoreCase('parentSpec') && guidSet.contains(attr.value)){ 
childServiceSet.add(serv.Id);   
}   
}   
}   
}   
} */    
        System.debug('childServiceSet:::' + childServiceSet);   
        return childServiceSet; 
    }   
    //----- Update stage and substage of Services -----//   
    public static void updateServices(List<String> serSet, Map<Id,string> servIdSubstageMap) {  
        System.debug('Inside updateServices method');   
        //EDGE-80847    
        List<csord__Service__c> serviceList = [SELECT Id, Name,Tenancy_Id__c, substage__c, stage__c, csord__Status__c,toBeCancelled__c, csord__Order__r.csord__Status2__c , csord__Subscription__c,csordtelcoa__Service_Number__c FROM csord__Service__c WHERE  Id IN :serSet]; 
        for(csord__Service__c srvc :  serviceList) {    
            //EDGE-147027   
            /* if(srvc.substage__c == NULL) 
{ srvc.substage__c = servIdSubstageMap.get(srvc.id);    
srvc.Tenancy_Id__c = tenancyId; 
system.debug('tenancyId::'+tenancyId);  
//EDGE-80847    
}   */  
            system.debug('servIdSubstageMap'+servIdSubstageMap);    
            if(servIdSubstageMap.get(srvc.id) != null){  //TC-47565 & TC-47820  
                system.debug('fetch substage'); 
                system.debug('srvc.id'+srvc.id);    
                srvc.substage__c = servIdSubstageMap.get(srvc.id);  
                system.debug('servIdSubstageMap.get(srvc.id)'+servIdSubstageMap.get(srvc.id));  
            }   
            if(mapNotifyAttrwithServiceId.get(srvc.csordtelcoa__Service_Number__c)!=null && mapNotifyAttrwithServiceId.get(srvc.csordtelcoa__Service_Number__c).get('TenancyID') != null){  
                system.debug('fetch tenancy id');   
                srvc.Tenancy_Id__c = mapNotifyAttrwithServiceId.get(srvc.csordtelcoa__Service_Number__c).get('TenancyID');  
                system.debug('srvc.Tenancy_Id__c::'+srvc.Tenancy_Id__c);//EDGE-174212   
            }   
            /*srvc.substage__c = servIdSubstageMap.get(srvc.id);    
if(!mapNotifyAttrwithServiceId.isEmpty() && mapNotifyAttrwithServiceId.get(srvc.csordtelcoa__Service_Number__c)!= null && mapNotifyAttrwithServiceId.get(srvc.csordtelcoa__Service_Number__c).get('TenancyID')!= null){ 
srvc.Tenancy_Id__c = mapNotifyAttrwithServiceId.get(srvc.csordtelcoa__Service_Number__c).get('TenancyID');  
system.debug('srvc.Tenancy_Id__c::'+srvc.Tenancy_Id__c);} //EDGE-174212*/   
        }   
        if(!serviceList.isEmpty()){ 
            update serviceList;}    
        // List<csord__Service__c> updateServiceList = [SELECT Id, Name, substage__c, stage__c, csord__Status__c, toBeCancelled__c,csord__Subscription__c FROM csord__Service__c WHERE  Id IN :serSet]; 
        for(csord__Service__c srvc :serviceList){   
            System.debug('Inside updateserviceList');   
            if(srvc.stage__c == NULL){  
                if(!servIdSubstageMap.isEmpty()&& servIdSubstageMap.get(srvc.id)!=null ){   
                    if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductRequirementsValidation)){  
                        srvc.stage__c = System.Label.OrderReceived;}    
                    else if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductPreparation) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.SiteVisitAndInstallation) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductActivationAndTesting) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.LogicalDeactivation) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.DeviceRecovery)||servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.EquipmentRecovered) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.EquipmentOrdered)||servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.EquipmentDelivered) ) {  
                        srvc.stage__c = System.Label.OrderBeingFulfilled;   
                        System.debug('srvc.stage__c vhsa==>'+srvc.stage__c);    
                    }   
                    else if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.CustomerOrderAcceptance)){   
                        srvc.stage__c = System.Label.OrderReadyForUse; }    
                    else if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductCompletionNotice)) {  
                        System.debug('check1'); 
                        srvc.stage__c = System.Label.OrderClosed; } 
                    else{   
                        System.debug('check2'); 
                    }   
                }}  
            if(srvc.stage__c != NULL && !srvc.stage__c.equalsIgnoreCase(System.Label.OrderClosed)){ 
                if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductRequirementsValidation) && !srvc.substage__c.containsIgnoreCase(System.Label.ProductActivationAndTesting)){    
                    srvc.stage__c = System.Label.OrderReceived; }   
                else if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductPreparation) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.SiteVisitAndInstallation) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductActivationAndTesting)|| servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.LogicalDeactivation)|| servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.DeviceRecovery)||servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.EquipmentRecovered) || servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.EquipmentOrdered)||servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.EquipmentDelivered)) { 
                    srvc.stage__c = System.Label.OrderBeingFulfilled; } 
                else if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.CustomerOrderAcceptance)){   
                    srvc.stage__c = System.Label.OrderReadyForUse; }    
                else if(servIdSubstageMap.get(srvc.id).containsIgnoreCase(System.Label.ProductCompletionNotice)) {  
                    System.debug('check3'); 
                    srvc.stage__c = System.Label.OrderClosed;   
                }   
                else{   
                    System.debug('check4'); 
                }   
            }   
            // System.debug('updatedServiceList::' + updateServiceList);    
        }   
        update serviceList; 
    }   
    /* public static void updateSubscriptions(List<Id> subIdList, String notificationType){ 
updateSubscriptions(subIdList, notificationType, null); 
}*/ 
    //----- Update Subscription Stage depending on count of services stages -----// 
    /*public static void updateSubscriptions(List<Id> subIdList, String notificationType, Map<String, String> mapNotifyAttr){   
Integer receivedCount = 0;  
Integer beingFulfilledCount = 0;    
Integer readyForUseCount = 0;   
Integer fulfilledCount = 0; 
csord__Subscription__c subscrib = new csord__Subscription__c(); 
List<csord__Subscription__c> updateSubscrib = new List<csord__Subscription__c>();   
//Vimal remove update of secondary orders   
csord__Order__c secOrder = new csord__Order__c();   
List<csord__Service__c> serviceList = new List<csord__Service__c>();    
//BUG Fix Changes   
if(notificationType.containsIgnoreCase('Stage')){   
////EDGE-80847  
//serviceList = [Select Id,Name,stage__c,csord__Subscription__c,csord__Order__c,csord__Status__c from csord__Service__c where csord__Subscription__c  =: subId and csord__Status__c != 'Connected'];    
// for( Id sub :    subIdList){ 
serviceList = [Select Id,Name,stage__c,Tenancy_ID__c    ,csord__Subscription__c,csord__Order__c,csord__Status__c,toBeCancelled__c from csord__Service__c where csord__Subscription__c IN: subIdList and (NOT Name LIKE 'Bandwidth%')];  
for(csord__Service__c srvc :  serviceList) {    
System.debug('srvc::'+srvc);    
if(srvc.stage__c != NULL) { 
if(srvc.stage__c.containsIgnoreCase(System.Label.OrderReceived))            { receivedCount += 1; } 
else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderBeingFulfilled)) { receivedCount += 1; beingFulfilledCount += 1; }   
else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderReadyForUse))    { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; }    
else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderClosed))         { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; fulfilledCount += 1; System.debug('checkAAA');}  
}   
subscrib.Id = srvc.csord__Subscription__c;  
System.debug('srvc.csord__Subscription__c;  '+srvc.csord__Subscription__c); 
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
System.debug('mapNotifyAttr :: '+mapNotifyAttr);    
if(mapNotifyAttr.ContainsKey('LogisticOrderNumber'))    
subscrib.Logistics_Order_Number__c = mapNotifyAttr.get('LogisticOrderNumber');  
if(mapNotifyAttr.ContainsKey('ConsignmentNumber'))  
subscrib.Consignment_Number__c = mapNotifyAttr.get('ConsignmentNumber');    
if(mapNotifyAttr.ContainsKey('TrackingURL'))    
subscrib.Delivery_Tracking__c = mapNotifyAttr.get('TrackingURL');   
if(mapNotifyAttr.ContainsKey('EstimatedDeliveryDate'))  
subscrib.Estimated_Delivery_Date__c = (datetime)json.deserialize('"'+mapNotifyAttr.get('EstimatedDeliveryDate')+'"', datetime.class);   
}//EDGE-80847 End   
//update subscrib;  
updateSubscrib.add(subscrib);   
//update secOrder;  
}   
if(!updateSubscrib.isEmpty()){  
update updateSubscrib;  
}   
}   
}*/ 
    //EDGE-168182   
    public static void updateSubscriptions(List<Id> subIdList, String notificationType){    
        Integer receivedCount = 0;  
        Integer beingFulfilledCount = 0;    
        Integer readyForUseCount = 0;   
        Integer fulfilledCount = 0; 
        system.debug('subIdList' +subIdList);   
        Map<String,String> mapServSub = new Map<String,String>(); //EDGE-168182 map of service vs subscription  
        List<String> StageNAme =  new List<String>(); //EDGE-168182 list to store stagename to avoid SOQL in for Loop   
        Map<String, Map<String,String>> mapSubscriptionnotifattr = new Map<String, Map<String,String>>(); //EDGE-168182 map of subscription holding notiffattributes    
        List<csord__Subscription__c> updateSubscrib = new List<csord__Subscription__c>();   
        //List<csord__Subscription__c> updatesolutionSubscrib = new List<csord__Subscription__c>(); //EDGE-187676   
        //Vimal remove update of secondary orders   
        csord__Order__c secOrder = new csord__Order__c();   
        List<csord__Service__c> serviceList = new List<csord__Service__c>();    
        List<Number__c> numbList = new List<Number__c>();  //EDGE-187676    
        //BUG Fix Changes   
        if(notificationType.containsIgnoreCase('Stage')){   
            ////EDGE-80847  
            //serviceList = [Select Id,Name,stage__c,csord__Subscription__c,csord__Order__c,csord__Status__c from csord__Service__c where csord__Subscription__c  =: subId and csord__Status__c != 'Connected'];    
            // for( Id sub :    subIdList){ 
            serviceList = [Select Id,Name,csordtelcoa__Service_Number__c,stage__c,Tenancy_ID__c ,csord__Subscription__c,csord__Order__c, csord__Order__r.csord__Status2__c,csord__Status__c,toBeCancelled__c from csord__Service__c where csord__Subscription__c IN: subIdList and (NOT Name LIKE 'Bandwidth%')]; // ADDED csordtelcoa__Service_Number__c   
            system.debug('serviceList' +serviceList);   
            for(csord__Service__c srvc :  serviceList) {    
                System.debug('srvc::'+srvc);    
                if(srvc.stage__c != NULL) { 
                    if(srvc.stage__c.containsIgnoreCase(System.Label.OrderReceived))            { receivedCount += 1; } 
                    else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderBeingFulfilled)) { receivedCount += 1; beingFulfilledCount += 1; }   
                    else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderReadyForUse))    { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; }    
                    else if(srvc.stage__c.containsIgnoreCase(System.Label.OrderClosed))         { receivedCount += 1; beingFulfilledCount += 1; readyForUseCount += 1; fulfilledCount += 1; System.debug('checkAAA');}  
                }   
                // subscrib.Id = srvc.csord__Subscription__c;   
                //secOrder.Id = srvc.csord__Order__c;   
                mapServSub.put(srvc.csordtelcoa__Service_Number__c,srvc.csord__Subscription__c); //EDGE-168182 filling map service n subscription   
            }   
            system.debug('Map values for mapServSub   '+mapServSub);    
            if(mapNotifyAttrwithServiceId != null){ 
                for(String serviceno : mapNotifyAttrwithServiceId.keyset()){ //this will create a map of subscription with  map of notifattr code dheeraj   
                    if (mapServSub.containsKey(serviceno))  
                    {   
                        if(!mapSubscriptionnotifattr.containsKey(mapServSub.get(serviceno))){   
                            Map<String,String> Mapnotification = new Map<String,String>();  
                            Mapnotification = mapNotifyAttrwithServiceId.get(serviceno);    
                            mapSubscriptionnotifattr.put(mapServSub.get(serviceno),Mapnotification);    
                        }   
                        else{   
                            mapSubscriptionnotifattr.get(mapServSub.get(serviceno)).putAll(mapNotifyAttrwithServiceId.get(serviceno));  
                        }   
                    }   
                }   
            }   
            system.debug('Map values for mapSubscriptionnotifattr  = '+mapSubscriptionnotifattr);   
            System.debug('serviceListSize:' + serviceList.size() + ':receivedCount:' + receivedCount + ':beingFulfilledCount:' + beingFulfilledCount + ':readyForUseCount:' + readyForUseCount + ':fulfilledCount:' + fulfilledCount);  
            if(serviceList.size() > 0){ 
                if(mapSubscriptionnotifattr.size()>0 && mapSubscriptionnotifattr != null){  
                    for(String subsId : mapSubscriptionnotifattr.keySet()){ 
                        csord__Subscription__c subscrib = new csord__Subscription__c(); 
                        subscrib.Id = subsId;   
                        //subscrib.TenancyID__c = tenancyId; commenting the tenancy as part of EDGE-168182  
                        if(receivedCount == serviceList.size())         { subscrib.stage__c = System.Label.OrderReceived;   }   
                        if(beingFulfilledCount == serviceList.size())   { subscrib.stage__c = System.Label.OrderBeingFulfilled;}    
                        if(readyForUseCount == serviceList.size())      { subscrib.stage__c = System.Label.OrderReadyForUse;    }   
                        // if(fulfilledCount == serviceList.size())        { subscrib.stage__c = System.Label.OrderClosed;   System.debug('checkBBBBB');  } 
                        System.debug('updateSubscriptions__subscrib::' + subscrib); 
                        //secOrder.stage__c = subscrib.stage__c;    
                        System.debug('mapSubscriptionnotifattr' + mapSubscriptionnotifattr);    
                        if(mapSubscriptionnotifattr.get(subsId) != null && mapSubscriptionnotifattr.get(subsId).size()>0){//EDGE-80847 Start    
                            if(mapSubscriptionnotifattr.get(subsId).ContainsKey('subStageName')){   
                                StageNAme.add(mapSubscriptionnotifattr.get(subsId).get('subStageName')); // Code dheeraj list to add all stagename  
                                /*list<SubStageStatus__mdt> subStageStatusRec = [SELECT id, Status__c, SubStage__c FROM SubStageStatus__mdt where SubStage__c = :mapSubscriptionnotifattr.get(subsId).get('subStageName')]; 
if(subStageStatusRec != null && subStageStatusRec.size() > 0)   
subscrib.SubStageStatus__c = subStageStatusRec[0].Status__c;    
else    
subscrib.SubStageStatus__c = 'Delivery Information Not Available';*/    
                            }   
                            //EDGE-119708 Logistics Order number is not getting displayed in subscription page even 
                            //after recieving DISPATCHED status from LOMS   
                            if(mapSubscriptionnotifattr.get(subsId).ContainsKey('TenancyID'))//added //EDGE-174212  
                                subscrib.TenancyID__c = mapSubscriptionnotifattr.get(subsId).get('TenancyID');  
                            if(mapSubscriptionnotifattr.get(subsId).ContainsKey('LogisticOrderNumber')) 
                                subscrib.Logistics_Order_Number__c = mapSubscriptionnotifattr.get(subsId).get('LogisticOrderNumber');   
                            if(mapSubscriptionnotifattr.get(subsId).ContainsKey('ConsignmentNumber'))   
                                subscrib.Consignment_Number__c = mapSubscriptionnotifattr.get(subsId).get('ConsignmentNumber'); 
                            if(mapSubscriptionnotifattr.get(subsId).ContainsKey('TrackingURL')) 
                                subscrib.Delivery_Tracking__c = mapSubscriptionnotifattr.get(subsId).get('TrackingURL');    
                            if(mapSubscriptionnotifattr.get(subsId).ContainsKey('EstimatedDeliveryDate'))   
                                subscrib.Estimated_Delivery_Date__c = (datetime)json.deserialize('"'+mapSubscriptionnotifattr.get(subsId).get('EstimatedDeliveryDate')+'"', datetime.class);    
                            //system.debug('subIdToSubMap1241'+subIdToSubMap);  
                            //system.debug('solutionToSubMap1241'+solutionToSubMap);    
                            if(mapSubscriptionnotifattr.get(subsId).ContainsKey('ReadyForActivationDate')){// Added as part of EDGE-187675,EDGE-187676  
                                subscrib.Ready_for_Activation_Date__c = (datetime)json.deserialize('"'+mapSubscriptionnotifattr.get(subsId).get('ReadyForActivationDate')+'"', datetime.class); 
                                subscrib.csord__status__c = 'Ready For Activation'; //EDGE-187676 - start   
                                subscrib.Trigger_RFA__c=true;   
                                //commented as part of B2B-328 - solution supression - start  
                                /*csord__Subscription__c solutionsub;   
if(subIdToSubMap.containsKey(subscrib.id) && solutionToSubMap.containsKey(subIdToSubMap.get(subscrib.id).cssdm__solution_association__c)){  
solutionsub = solutionToSubMap.get(subIdToSubMap.get(subscrib.id).cssdm__solution_association__c);  
if(solutionsub.csord__status__c != 'Ready For Activation' && solutionsub.csord__status__c == OrchestratorConstants.SubscriptionStatus.ProvisioningInProgress)   
{   
solutionsub.csord__status__c = 'Ready For Activation';  
solutionsub.Trigger_RFA__c = true;  
solutionsub.Ready_for_Activation_Date__c = (datetime)json.deserialize('"'+mapSubscriptionnotifattr.get(subsId).get('ReadyForActivationDate')+'"', datetime.class);  
updatesolutionSubscrib.add(solutionsub);    
}   
}   
//added as part of INC000095547173  
if(solutionsub!=null && (solutionsub.csord__status__c=='Provisioned' || solutionsub.csord__status__c=='Active' || solutionsub.csord__status__c=='Bill Readiness In Progress') &&  solutionsub.Trigger_RFA__c == true){*/    
                                //} //commented as part of B2B-328 - solution supression - end    
                                system.debug('subIdtoNumberMap1254'+subIdtoNumberMap);  
                                system.debug('subscrib1256'+subscrib.id);   
                                system.debug('subIdtoNumberMap1255'+subIdtoNumberMap.get(subscrib.id)); 
                                if(subIdtoNumberMap.containsKey(subscrib.id)){  
                                    for(Number__c num :subIdtoNumberMap.get(subscrib.id))   
                                    {   
                                        num.Status__c = 'Ready For Activation'; 
                                        numbList.add(num);  
                                    }   
                                }   
                            }    //EDGE-187676 - End    
                        }//EDGE-80847 End   
                        //update subscrib;  
                        updateSubscrib.add(subscrib);   
                        //update secOrder;  
                    }   
                    //avoid SOQL from for loop start dheeraj    
                    list<SubStageStatus__mdt> subStageStatusRec = [SELECT id, Status__c, SubStage__c FROM SubStageStatus__mdt where SubStage__c in :StageNAme]; 
                    //list of metadta coressponding stage name  
                    Map<String,List<SubStageStatus__mdt>> MapMetadatalist = new Map<String,List<SubStageStatus__mdt>>(); //map of stage name and list of metadata   
                    for(SubStageStatus__mdt metadatalist : subStageStatusRec){  
                        if(MapMetadatalist.containsKey(metadatalist.SubStage__c)){  
                            MapMetadatalist.get(metadatalist.SubStage__c).add(metadatalist);    
                        }   
                        else{   
                            MapMetadatalist.put(metadatalist.SubStage__c,new List<SubStageStatus__mdt>{metadatalist});  
                        }   
                    }   
                    System.debug('MapMetadatalist:' +MapMetadatalist);  
                    System.debug('updateSubscrib:' +updateSubscrib);    
                    //updating the status on subscription record    
                    for (csord__Subscription__c Subscriptionlist :updateSubscrib){  
                        system.debug('get values for  ==='+mapSubscriptionnotifattr.get(Subscriptionlist.Id));  
                        if(mapSubscriptionnotifattr.get(Subscriptionlist.Id).ContainsKey('subStageName')){  
                            system.debug('Inside first if loop means it contain key as substageNAme');  
                            if(MapMetadatalist.get(mapSubscriptionnotifattr.get(Subscriptionlist.Id).get('subStageName')) != null && MapMetadatalist.get(mapSubscriptionnotifattr.get(Subscriptionlist.Id).get('subStageName')).size()>0){  
                                Subscriptionlist.SubStageStatus__c = MapMetadatalist.get(mapSubscriptionnotifattr.get(Subscriptionlist.Id).get('subStageName'))[0].Status__c;   
                            }   
                            else{   
                                Subscriptionlist.SubStageStatus__c = 'Delivery Information Not Available';  
                            }   
                        }   
                    }   
                    //avoid SOQL from for loop end dheeraj  
                }   
            }   
            system.debug('updateSubscrib' +updateSubscrib); 
            /*system.debug('updatesolutionSubscrib' +updatesolutionSubscrib);   
if(!updatesolutionSubscrib.isEmpty())   
{   
updateSubscrib.addAll(updatesolutionSubscrib);  
}*/ 
            if(!updateSubscrib.isEmpty()){  
                update updateSubscrib;  
            }   
            if(!numbList.isEmpty()) //EDGE-187676   
            {   
                update numbList;    
            }   
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
        List<csord__Order__c> orderList = [Select Id,Name,stage__c,csord__Primary_Order__c from csord__Order__c where id =: primaryOrdId];  
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
    public static void updateOrderSubStage(List<ID> orderIdList) {  
        Integer receivedCount = 0;  
        Integer beingFulfilledCount = 0;    
        Integer readyForUseCount = 0;   
        Integer fulfilledCount = 0; 
        //csord__Order__c primaryOrder = new csord__Order__c(); 
        //fetch stage information from Subscriptions    
        List<csord__Subscription__c> subList = [Select Id,Name,stage__c,csord__Order__c from csord__Subscription__c where csord__Order__c IN: orderIdList AND Name !='Connected Workplace Solution'];   
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
    public static Map<String,String> getSubStageMatrix(List<Id>serviceIdList,Map<Id,String> servIdSubstageMap,Map<Id,String> servtobecancelledMap){ 
        //System.debug('tobeCancelled===>'+tobeCancelled);  
        //----- get fieldLabelMap & fieldNameMap from Schema for new/Modify and Cease Order 
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.substage_matrix__mdt.fields.getMap();    
        Map<String, Schema.SObjectField> ceaseFieldMap = Schema.SObjectType.Substage_Matrix_Cease_Order__mdt.fields.getMap();   
        Map<String,String> fieldLabelMap = new Map<String,String>();    
        Map<String,String> fieldNameMap = new Map<String,String>(); 
        Map<String,String> ceaseFieldLabelMap = new Map<String,String>();   
        Map<String,String> ceaseFieldNameMap = new Map<String,String>();    
        Map<String,String> finalSubStageMatrixMap = new Map<String,String>();   
        List<Service_Specification__c> serSpecList = [Select Id, Service__c,Service__r.csordtelcoa__Service_Number__c, Code__c, guid__c from Service_Specification__c where service__c IN:serviceIdList];   
        Map<String,String> specCodeMap = new Map<String,String>();  
        for(Service_Specification__c serSpec : serSpecList) {   
            specCodeMap.put(String.escapeSingleQuotes(serSpec.Service__c),String.escapeSingleQuotes(serSpec.Code__c));  
        }   
        System.debug('specCodeMap=>'+specCodeMap);  
        for(String spec :specCodeMap.keyset()){ 
            if(servtobecancelledMap.get(spec) == 'false'){  
                System.debug('Inside new/modify matrix');   
                for(String fieldName: fieldMap.keySet()) {  
                    fieldLabelMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());  
                    fieldNameMap.put(fieldMap.get(fieldName).getDescribe().getLabel().toLowerCase(UserInfo.getLocale()),fieldName); 
                }   
                System.debug('fieldLabelMap::' + fieldLabelMap);    System.debug('fieldNameMap::' + fieldNameMap);  
                //----- create subStageMatrixMap from Matrix Metadata based on subStageName and specCodes for New/Modify    
                System.debug('UserInfo.getLocale()'+UserInfo.getLocale());  
                //System.debug('subStgeName.toLowerCase(UserInfo.getLocale()'+subStgeName.toLowerCase(UserInfo.getLocale()));   
                if(!fieldNameMap.isEmpty() && !servIdSubstageMap.isEmpty() && fieldNameMap.get(servIdSubstageMap.get(spec))!=null){ 
                    if(fieldNameMap.get(servIdSubstageMap.get(spec)).toLowerCase(UserInfo.getLocale())!= null){ 
                        string field = fieldNameMap.get(servIdSubstageMap.get(spec).toLowerCase(UserInfo.getLocale())); 
                        System.debug('field====>'+field);   
                        String qry = 'Select DeveloperName,'+ String.escapeSingleQuotes(field) + ' from Substage_Matrix__mdt where DeveloperName IN :'+specCodeMap.values()+'and ' + String.escapeSingleQuotes(field) + ' = true '; 
                        System.debug('qry::' + qry);    
                        List<Substage_Matrix__mdt> subStageMatrixList = Database.Query(qry);    
                        for(Substage_Matrix__mdt subStageMatrix : subStageMatrixList) { 
                            finalSubStageMatrixMap.put(subStageMatrix.DeveloperName,fieldLabelMap.get(field).toLowerCase(UserInfo.getLocale()));    
                        }   
                        System.debug('finalSubStageMatrixMap under new/Modify::' + finalSubStageMatrixMap); 
                    }}  
            }   
            else {  
                System.debug('Inside cease matrix');    
                for(String ceaseFieldName: ceaseFieldMap.keySet()){ 
                    ceaseFieldLabelMap.put(ceaseFieldName,ceaseFieldMap.get(ceaseFieldName).getDescribe().getLabel());  
                    ceaseFieldNameMap.put(ceaseFieldMap.get(ceaseFieldName).getDescribe().getLabel().toLowerCase(UserInfo.getLocale()),ceaseFieldName); 
                }   
                System.debug('ceaseFieldLabelMap::' + ceaseFieldLabelMap);    System.debug('ceaseFieldNameMap::' + ceaseFieldNameMap);  
                System.debug('Spec'+spec);  
                if(ceaseFieldNameMap != null && servIdSubstageMap.get(spec) != null && ceaseFieldNameMap.get(servIdSubstageMap.get(spec)) != null && ceaseFieldNameMap.get(servIdSubstageMap.get(spec)).toLowerCase(UserInfo.getLocale()) != null){ 
                    //----- create subStageMatrixMap from Matrix Metadata based on subStageName and specCodes for cancel order  
                    String ceaseField = ceaseFieldNameMap.get(servIdSubstageMap.get(spec).toLowerCase(UserInfo.getLocale()));   
                    System.debug('ceaseField====>'+ceaseField); 
                    String ceaseQry = 'Select DeveloperName,'+ String.escapeSingleQuotes(ceaseField) + ' from Substage_Matrix_Cease_Order__mdt where DeveloperName IN :\''+specCodeMap.values()+'\' and ' + String.escapeSingleQuotes(ceaseField) +' = true';   
                    System.debug('ceaseQry====>'+ceaseQry); 
                    List<Substage_Matrix_Cease_Order__mdt> ceaseSubstageMatrixList = Database.Query(ceaseQry);  
                    Map<String,String> ceaseSubStageMatrixMap = new Map<String,String>();   
                    for(Substage_Matrix_Cease_Order__mdt ceaseSubStageMatrix : ceaseSubstageMatrixList) {   
                        finalSubStageMatrixMap.put(ceaseSubStageMatrix.DeveloperName,ceaseFieldLabelMap.get(ceaseField).toLowerCase(UserInfo.getLocale())); 
                    }   
                    System.debug('finalSubStageMatrixMap under cease::===>' + finalSubStageMatrixMap);  
                }   
            }   
        }   
        return finalSubStageMatrixMap;  
    }   
    @TestVisible    
    private static Map<Id,boolean> checkSubscriptionDeactivation(List<Id>serviceIdList){    
        Map<Id,boolean> servCheckDeactivation = new Map<Id,boolean>();  
        Integer logicalDeactivatedProductCount = 0; 
        Integer specToTrackCount = 0;   
        Map<String,String> specificationCodeMap = new Map<String,String>(); 
        Set<String> specCodeToTrackSet = new Set<String>(); 
        // System.debug('serviceId===>'+serviceId+ 'subscriptionId====>'+subscriptionId+ 'subStageName====>'+subStageName); 
        for(RightToStopProductMetadata__mdt mdata : [select id,offerCode__c,parentSpecCode__c,specificationCode__c,subStageTriggersCeaseBill__c from RightToStopProductMetadata__mdt]){ 
            specificationCodeMap.put(mdata.specificationCode__c, mdata.parentSpecCode__c);  
            System.debug('specificationCodeMap====>'+specificationCodeMap.keyset());    
        }   
        for(String specCodeKey : specificationCodeMap.Keyset()){    
            specCodeToTrackSet.add(specCodeKey);    
            System.debug('specCodeToTrackSet===>'+specCodeToTrackSet);  
        }   
        /*for(csord__Service__c serv :[SELECT Id, Name, csord__Status__c, csord__Subscription__c FROM csord__Service__c WHERE csord__Subscription__c =: subscriptionId AND Id =: serviceId]){   
serviceIdList.add(serv.Id); 
System.debug('serviceIdList===>'+serviceIdList);    
}*/ 
        Map<Id,String> serviceAttachmentMap = new Map<Id,String>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId in :serviceIdList]){    
            serviceAttachmentMap.put(att.parentId,att.body.toString()); 
        }   
        Boolean isSpecvaluePresent = false; 
        Boolean isSpecCodePresent = false;  
        Map<Id,Integer> servlogicalDeactivatedCount = new  Map<Id,Integer>();   
        Map<Id,Integer> servspecToTrackCount = new  Map<Id,Integer>();  
        List<subStageNotification__c>  substageList =[Select Name,Service_Specification__c,Service_Specification__r.service__c, 
                                                      Service_Specification__r.Code__c from subStageNotification__c 
                                                      where Name =:System.Label.LogicalDeactivation AND 
                                                      Service_Specification__r.service__c in: serviceIdList ];  
        if(!substageList.isEmpty()){    
            for(subStageNotification__c subStageNotification : substageList){   
                System.debug('subStageNotification===>'+subStageNotification);  
                //if(servSpec.subStageNotifications__r != null){    
                isSpecvaluePresent = specCodeToTrackSet.Contains(subStageNotification.Service_Specification__r.Code__c);    
                if(isSpecvaluePresent){
                    //EDGE-189974 - Enhanced Cancel logic to handle multiple deactivation notification
                     logicalDeactivatedProductCount++;  
                        if(servlogicalDeactivatedCount.containsKey(subStageNotification.Service_Specification__r.service__c) && servlogicalDeactivatedCount.get(subStageNotification.Service_Specification__r.service__c) != null)
                        {
                            servlogicalDeactivatedCount.put(subStageNotification.Service_Specification__r.service__c,servlogicalDeactivatedCount.get(subStageNotification.Service_Specification__r.service__c)+ logicalDeactivatedProductCount);
                        }
                        else
                        {
                            servlogicalDeactivatedCount.put(subStageNotification.Service_Specification__r.service__c,logicalDeactivatedProductCount);
                        } 
                    System.debug('logicalDeactivatedProductCount==>'+logicalDeactivatedProductCount);   
                }  
                logicalDeactivatedProductCount = 0;   
            }}  
        List<CS_SpecificationDTO.ServiceSpecification> allServSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();  
        for(csord__Service__c srv : [SELECT Id, Name, csord__Status__c, csord__Order__r.csord__Status2__c FROM csord__Service__c WHERE Id IN : serviceIdList]){ 
            // allServSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(srv.id),'FULFILMENT');   
            allServSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(srv.id)),'FULFILMENT');    
            specToTrackCount = 0; //EDGE-167675 
            System.debug('allServSpecList===>'+allServSpecList);    
            for(CS_SpecificationDTO.ServiceSpecification srvSpec : allServSpecList){    
                System.debug('srvSpec.code====>'+srvSpec.code); 
                //String specCodeString = srvSpec.code  
                isSpecCodePresent = specCodeToTrackSet.Contains(srvSpec.code.removeEnd('_Fulfilment')); 
                if(isSpecCodePresent){  
                    specToTrackCount++; 
                    //servspecToTrackCount.put(srv.id,specToTrackCount);    
                    System.debug('specToTrackCount===>'+specToTrackCount);  
                }   
            }   
            servspecToTrackCount.put(srv.id,specToTrackCount);//EDGE-167675 : Moved map out of loop 
        }   
        /* if(logicalDeactivatedProductCount == specToTrackCount ){ 
return true;    
}else{  
return false;   
}*/ 
        for(Id serId :serviceIdList){   
            //EDGE-167675 : added null check    
            if(servlogicalDeactivatedCount.get(serId) != null && servspecToTrackCount.get(serId) != null && (servlogicalDeactivatedCount.get(serId) == servspecToTrackCount.get(serId))){   
                servCheckDeactivation.put(serId,true);                                                                                                                                               }  
            else{servCheckDeactivation.put(serId,false);}   
        }   
        return servCheckDeactivation;   
    }   
    //EDGE-144111,EDGE-181842 Capturing of SIM Serial and IMSI details in number object that's been received as part of event notification  
    public static void updateNumberrecords(List<String> setserviceNumber, map<String,Map<String, String>> mapNotifyAttr){   
        system.debug('Inside updateNumberrecords'); 
        system.debug('mapNotifyAttr>>>>'+mapNotifyAttr);    
        system.debug('setserviceNumber>>>>'+setserviceNumber);  
        if(!setserviceNumber.isEmpty()){    
            List<Number__C> lstNumber=[SELECT Id, Type__c,IMSI__c, Sim_Serial_Number__c,Service_Id__c,Status__c 
                                       FROM Number__c WHERE 
                                       Service_Id__c != null AND Service_Id__c IN:mapNotifyAttr.keySet()];  
            system.debug('lstNumber>>>>'+lstNumber);    
            if(!lstNumber.isEmpty()){   
                for(Number__c numberobj: lstNumber){    
                    map<String,String> attr = new map<String,String>(); 
                    attr = mapNotifyAttr.get(numberobj.Service_Id__c);  
                    if(!attr.isEmpty()){    
                        if(attr.ContainsKey('IMSI')){   
                            numberobj.IMSI__c = attr.get('IMSI');   
                            if(attr.ContainsKey('SIMSerialNumber')) 
                                numberobj.Sim_Serial_Number__c = attr.get('SIMSerialNumber');   
                        }   
                    }   
                }   
                system.debug('lstNumber>>>>'+lstNumber);    
                update lstNumber;   
            }   
        }   
    }   
    public static void getSolutiontosubMap(List<String> OrdersIdList){ //EDGE-187676    
        Map<Id,csord__Subscription__c> subMap = new Map<Id,csord__Subscription__c>();   
        Map<String,csord__Subscription__c> pcTosubMap = new Map<String,csord__Subscription__c>();   
        List<String> pcList = new List<String>();   
        system.debug('OrdersIdList1560'+OrdersIdList);  
        for(csord__Subscription__c sub :[Select Id,Name,csord__status__c ,csord__Order__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,cssdm__solution_association__c,Trigger_RFA__c,Ready_for_Activation_Date__c,csord__Order__r.csord__Order_Number__c   from csord__Subscription__c where csord__Order__r.csord__Order_Number__c IN: OrdersIdList]) 
        {   
            /*if(String.isNotBlank(sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c) && sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){ 
subMap.put(sub.cssdm__solution_association__c, sub);    
}*/ 
            pcList.add(sub.csordtelcoa__Product_Configuration__c);  
            subIdToSubMap.put(sub.id,sub);  
            pcTosubMap.put(sub.csordtelcoa__Product_Configuration__c,sub);  
        }   
        system.debug('pcList1579'+pcList);  
        for(Number__c num :[Select Id,Status__c,Service_Id__c,Service_Number__c,Subscription_number__c,Product_Configuration__c from Number__c where Product_Configuration__c IN :pcList])  
        {   
            if(subIdtoNumberMap.containsKey(pcTosubMap.get(num.Product_Configuration__c).Id))   
            {   
                List<Number__c> tempNumList = subIdtoNumberMap.get(pcTosubMap.get(num.Product_Configuration__c).Id);    
                tempNumList.add(num);   
                subIdtoNumberMap.put(pcTosubMap.get(num.Product_Configuration__c).Id,tempNumList);  
            }else{  
                subIdtoNumberMap.put(pcTosubMap.get(num.Product_Configuration__c).Id,new List<Number__C>{num}); 
            }   
        }   
        //system.debug('subMap1578'+subMap);    
        system.debug('subIdtoNumberMap1579'+subIdtoNumberMap);  
        system.debug('pcTosubMap1579'+pcTosubMap);  
        system.debug('subIdToSubMap1579'+subIdToSubMap);    
        //return subMap;    
    }   
    /** 
* @description Exception Handling Framework 
*/  
    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){ 
        Map<String, Object> eLogMap = new Map<String, Object>();    
        eLogMap.put('interfaceName', CONST_INTERFACENAME);  
        eLogMap.put('elementName', methodName); 
        eLogMap.put('referenceNumber', referenceNumber);    
        eLogMap.put('correlationId', correlationId);    
        eLogMap.put('errorDescription', errorMessage);  
        eLogMap.put('businessDescription', businessDescription);    
        C2O_Utilities.logException(eLogMap, false); 
    }   
}