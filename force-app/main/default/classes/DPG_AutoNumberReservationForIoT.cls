/*************************************************************************************
Name: DPG_AutoNumberReservationForIoT
Description: This class implemented as part of EDGE-66239 and the class will Invokes the AppointmentPrerequisite callout
Version    Date          Description
1          26/04/2021    EDGE-213120 : Commented the reference OrderObserverUtil class as this class is not in used.
						 Change the reference when the class is re-used again as mentioned in comments below.
************************************************************************************/

global with sharing class DPG_AutoNumberReservationForIoT implements CSPOFA.ExecutionHandler, CSPOFA.Calloutable {
    
    private List<Object> calloutResults;
    //Boolean calloutsPerformed = false;  
    public List<String> calloutStatus = new List<String>();
    public static String REGULAR =  'Regular';
    public static String CONTINUOUS =  'CONTINUOUS';
    public static String PATTERN =  '614';
    public static String POSTPAID =  'Postpaid';
    public static String SEARCH =  'SEARCH';
    public static String AVAILABLE =  'AVAILABLE';
    public static String TELSTRA_NUM =  'Telstra Numbers';
    public static String DIRECT_HOLD =  'DIRECT HOLD';
    public static String IOT_SUBSCRIPTION =  'IOT Subscription';
    public static String SEARCHRESERVEMSISDNHANDLER =  'SearchReserveMSISDNHandler';
    public static String CONTENTTYPE =  'Content-Type';
    public static String APPLICATION_JSON =  'application/json';
    public static String AUTH =  'Authorization';
    public static String BEARER =  'Bearer ';
    public static String CORRELATIONID =  'correlationId';
    public static String COMPLETED =  'Completed';
    public static String STATUS_NEW =  'New';
    public static String STATUS_ERROR =  'ERROR';
    public static String COMPLETE =  'Complete';
    public static String READYFORSUBMIT =  'Ready for Submit';
    //public static String PARTIALSUCCESS =  'UNMSPARTIAL_SUCCESS';
    //public static Integer pendingQuantity {get;set;}
    //public static String basket {get;set;}
    public static Integer newServicesCount {get;set;}
    public Logger2 logger =Logger2.getLogger(SEARCHRESERVEMSISDNHANDLER);
    public Map<Id,List<csord__Service__c>> stepIdServListMap = new Map<Id,List<csord__Service__c>>();
    public DateTime startTime = DateTime.now();
    public DateTime endTime = DateTime.now();
    public Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>();
    public Map<Id, csord__Order__c> failedOrderMap = new Map<Id, csord__Order__c>();
    public Map<Id,Map<List<csord__Service__c>,List<String>>> basketMap = new Map<Id,Map<List<csord__Service__c>,List<String>>>();
    
    public Boolean performCallouts(List<SObject> data) {
        Boolean calloutsPerformed = false;
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
        List<Id> orderIds = new List<Id>();
        List<Id> orchesIds= new List<Id>();
        List<csord__Service__c> serList = new List<csord__Service__c>();
        Map<String, csord__Service__c> msisdnSerivceMap = new  Map<String, csord__Service__c>();
        Map<Id,Id> orchestrationIdStepIdMap = new Map<Id,Id>();
        Map<Id,Id> orderIdOrchestrationIdMap = new Map<Id,Id>();
        Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
        
        for(CSPOFA__Orchestration_Step__c step: stepList) {
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            orchestrationIdStepIdMap.put(step.CSPOFA__Orchestration_Process__c, step.Id);
        }
        for(CSPOFA__Orchestration_Process__c  orch : [Select Id, Name, Order__r.Id from CSPOFA__Orchestration_Process__c where Id IN:orchesIds]) {
            System.debug('<><><>orch'+orch.Order__r.Id);
            orderIds.add(orch.Order__r.Id);
            orderIdOrchestrationIdMap.put(orch.Order__c, orch.Id);
        } 
        System.debug('<><><><>'+orderIds);String searchIoTText = System.Label.IoTSubscription;
        
        /********************
        Author: Ila/Kiran
        Story: DPG-1802& DPG-1797 & DPG-1803
        ********************/
        String ordSoql = 'SELECT Id, csord__Order_Number__c,csord__Status2__c,CreatedById, '+
                                           '(SELECT Id, Name, csord__Order__c, csordtelcoa__Product_Basket__c, csordtelcoa__Service_Number__c,csordtelcoa__Product_Configuration__c'+ 
                                            ' FROM csord__Services__r WHERE serviceMSISDN__c = null '+
                                           ' AND csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name =:searchIoTText LIMIT ' +System.Label.UNMS_SOQL_Limit +')'+
                                          ' FROM csord__Order__c WHERE Id IN : orderIds AND csord__Status2__c!= \'Ready For Submit\'' ;
        
        system.debug('ordSoql+' +ordSoql); 
        
        List<csord__Order__c> orderList = Database.query(ordSoql);
        system.debug('orderList+' +orderList);
        
        for(csord__Order__c ord: orderList) {
            orderMap.put(ord.Id, ord);
            if(orderIdOrchestrationIdMap.containsKey(ord.Id)){
                Id orchId = orderIdOrchestrationIdMap.get(ord.Id);
                if(orchestrationIdStepIdMap.containsKey(orchId)){
                    Id stepId = orchestrationIdStepIdMap.get(orchId);
                    stepIdServListMap.put(stepId, ord.csord__Services__r);
                }                
            }
            
            for(csord__Service__c serv: ord.csord__Services__r){
                serList.add(serv);
            }
            
            String serviceId=serList[0].csordtelcoa__Product_Basket__c;
            system.debug('basketD' +serviceId);
            if(!basketMap.containsKey(serviceId)){
                
                List<String> msisdnList = new List<String>();
                Map<List<csord__Service__c>,List<String>> mapOfServicetoNumber = new Map<List<csord__Service__c>,List<String>>();
                mapOfServicetoNumber.put(serList,msisdnList);
                basketMap.put(serviceId, mapOfServicetoNumber);
             }
            system.debug('basketMap+' +basketMap);
        }
        system.debug('stepIdServListMap>>'+stepIdServListMap);
        
        /* DPG-1803/DPG-1802/DPG-1797: Start - Call to UNMS Bulk API
         * @Author: Ila/Kiran 
         */
        
        String result = '';
        try{
            if(serList !=null && serList.size() >0) {
                newServicesCount = serList.size();    
                result = UNMSNumberReservationUtil.UNMSautoReserveMSISDN(basketMap,newServicesCount);
                system.debug('newServicesCount '+newServicesCount + ' result '+result);
                
                if (result.equalsIgnoreCase('success')){
                    //PP:EDGE-213120 :26/04: Commenting as the reference class is not in use and this class is also not in use.
                    //If in future, the class is re-used, please check OrderObserverUtil_V2.populateNumberService method
                    //OrderObserverUtil.updateNumberService(new List<Id>(orderMap.KeySet()));
                    calloutsPerformed = true; 
                }else{
                    if(result.contains('~'))
                        failedOrderMap.put(Id.valueOf(result.split('~')[1]),orderMap.get(Id.valueOf(result.split('~')[1])));
                    system.debug('failedOrderMap++'+failedOrderMap + Id.valueOf(result.split('~')[1]));
  
                        
                }
            }
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return calloutsPerformed;
    }
    
    public List<sObject> process(List<sObject> data) {
        List<Id> orchesIds= new List<Id>();
        List<sObject> result = new List<sObject>();
        List<Id> orderId = new List<Id>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
        system.debug('stepIdServListMap>>'+stepIdServListMap); 
        List<List<csord__Service__c>> serviceListList = stepIdServListMap.Values();
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        List<csord__order__c> orderListToUpdate= new List<csord__order__c>();
        for(List<csord__Service__c> servList: serviceListList) {
            serviceList.addAll(servList);
        }
        system.debug('serviceList++' +serviceList);
        List<RecordType> orderRecordTypeList =[SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
        Map<String, Id> orderRecordTypeNameToIdMap = new Map<String, Id>();
        for(RecordType recTypeInstance : orderRecordTypeList){
            orderRecordTypeNameToIdMap.put(recTypeInstance.Name, recTypeInstance.Id);      
        }
        
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([Select Id, csordtelcoa__Service_Number__c,serviceMSISDN__c FROM csord__Service__c where Id IN: serviceList]);
        for(CSPOFA__Orchestration_Step__c step : stepList){
            List<csord__Service__c> servList = stepIdServListMap.get(step.Id);
            system.debug('servList+' +servList);
            Integer i = 0;
            for(csord__Service__c serv : servList) {
                csord__Service__c service = serviceMap.get(serv.Id);
                if(service.serviceMSISDN__c!= null){
                    i++;
                }
            }
            
            if( i == servList.size()){
                step.CSPOFA__Status__c = COMPLETE;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = COMPLETED;
                result.add(step);
                if(servList.size() >0 && orderMap.containsKey(servList[0].csord__Order__c)){
                    orderListToUpdate.add(orderMap.get(servList[0].csord__Order__c)); 
                    
                }
            }
            else{
                step.CSPOFA__Status__c = STATUS_ERROR;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = COMPLETED;
                 // DPG-1803 Create Fallback Task For the Orders for which UNMS callout has failed
                UNMSNumberReservationUtil.createFallbackTask(failedOrderMap);
                
                result.add(step);
            }
        }
        OrderFieldsUpdateUtil.changeOrderRecTypeAndStatus(orderListToUpdate, 'IoT MSISDN Reserved', orderRecordTypeNameToIdMap.get('MSISDN Reserved'));
        return result;
    } 
    }