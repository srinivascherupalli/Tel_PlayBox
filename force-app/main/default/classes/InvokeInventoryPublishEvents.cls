/*
===============================================================================================================================
Class : InvokeInventoryPublishEvents
Developer Name : Prajakta Patil
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.       Prajakta Patil      17/10/2018 
2.       Antun B             29/10/2019    Bulkified code
2.       Vaibhav Deshpande   23/12/2019    EDGE-127367 DML and SOQL inside FOR loop - Added comments
3.       Prajakta Patil      17/03/2020    EDGE-115932
4.       Vaibhav Deshpande   02/04/2020    EDGE-139164 - Change Platform Event type to High Volume
5.       Prajakta Patil      22/10/2020    EDGE-184831
===============================================================================================================================
*/

public with sharing class InvokeInventoryPublishEvents {

    public static Set<Id> eventPublished = new Set<Id>();
    static String operation;
    public static Boolean hasEntityPublished(Id entityId) {
        return eventPublished.contains(entityId) ? true : false;
    }

    public static Set<String> speceventPublished = new Set<String>();
    public static Boolean hasspecEntityPublished(String entity) {
        return speceventPublished.contains(entity) ? true : false;
    }

    @InvocableMethod
    public static void publishSubscriptionEventHandler(List<String>Parameters){

        String subscriptionId = ' ';
        //AntunB: Has to be bulkified
        //EDGE-127367 - DML and SOQL inside FOR loop
        Map<String,String> subIdToOperationMap = new Map<String,String>();
        for (String param: Parameters) {
            subscriptionId = param.substringBefore(':::');
            operation      = param.substringAfter(':::');
            
            subIdToOperationMap.put(subscriptionId,operation);//EDGE-127367 - added subscriptionId and operation in map
        }
        //If no subscription ids then we have nothing to publish
        if (!subIdToOperationMap.keySet().isEmpty()) {
            //List<PublishSubscriptionChange__e> SubEventList = new List<PublishSubscriptionChange__e>(); //code commented as part of EDGE-139164
            List<PublishSubscriptionChangeHV__e> SubEventList = new List<PublishSubscriptionChangeHV__e>(); //added as part of EDGE-139164

            List<csord__Subscription__c> subscriptionList = [SELECT Id,csord__Order__r.csord__Order_Number__c,csordtelcoa__Subscription_Number__c
                                                             FROM csord__Subscription__c
                                                             WHERE Id IN :subIdToOperationMap.keySet()]; //EDGE-127367 - change in Where clause 
            System.debug('subscriptionList::'+subscriptionList);
            String subNumber;
            String correlationID;
            //PublishSubscriptionChange__e event    = new PublishSubscriptionChange__e(); // code commented as part of EDGE-139164
            //PublishSubscriptionChangeHV__e event    = new PublishSubscriptionChangeHV__e(); //code commented as part of EDGE-139164 as this is not being used
            
            List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
            List<Database.SaveResult> saveRes     = new List<Database.SaveResult>();
            //only create events to publish if not already published, add to master list as publish will be done for all at once- AntunB
            for (csord__Subscription__c sub : subscriptionList) {
                if (!hasEntityPublished(sub.Id)) {
                    subNumber = sub.csordtelcoa__Subscription_Number__c;
                    //EDGE-127367 - get operation from map
                    operation = subIdToOperationMap.get(sub.Id);
                    SubEventList.add(PublishInventoryEvents.publishSubscriptionEvent(String.valueOf(sub.Id),operation,subNumber));
                }
            }
            //
            if (!SubEventList.isEmpty()) {
                System.debug('Publish_subevents::'+SubEventList);
                saveResults = EventBus.publish(SubEventList);
                logApplicationLog(SubEventList,null,saveResults);
            }
        }
    }

    public static void publishServiceSpecificationHandler(String srvcNumber,List<String> guidList){
        for (String GUID : guidList ) {
            String correlationID                                            = srvcNumber +':'+GUID;
            List<PublishServiceSpecificationChange__e> ServiceSpecEventList = new List<PublishServiceSpecificationChange__e>();
            List<Database.SaveResult> saveRes                               = new List<Database.SaveResult>();

            ServiceSpecEventList.add(PublishInventoryEvents.publishServiceSpecificationEvent(correlationID,GUID));
            system.debug('Publish_specevents::'+ServiceSpecEventList);
            if (!ServiceSpecEventList.isEmpty() && !hasspecEntityPublished(GUID)) {
                //system.debug('Publish_specevents::'+ServiceSpecEventList);
                saveRes = EventBus.publish(ServiceSpecEventList);
                logApplicationLog(null,ServiceSpecEventList,saveRes);
            }
        }
    }
    
    //added as EDGE-115932
    public static void publishServiceSpecificationHandlerMSUpdate(Map<String,Set<String>> servguidMap){//EDGE-184831
        List<PublishServiceSpecificationChange__e> ServiceSpecEventList = new List<PublishServiceSpecificationChange__e>();
        List<Database.SaveResult> saveRes = new List<Database.SaveResult>();

        for (String servnum : servguidMap.keyset() ) {
            Set<String>guidList = servguidMap.get(servnum); //EDGE-184831 converted List to set
            for(String GUID :guidList){
            String correlationID = servnum +':'+GUID;
            
            ServiceSpecEventList.add(PublishInventoryEvents.publishServiceSpecificationEvent(correlationID,GUID));
            system.debug('Publish_specevents::'+ServiceSpecEventList);
        }}
            if (!ServiceSpecEventList.isEmpty() ) {
                //system.debug('Publish_specevents::'+ServiceSpecEventList);
                saveRes = EventBus.publish(ServiceSpecEventList);
                logApplicationLog(null,ServiceSpecEventList,saveRes);
            }
        
    }
    // End EDGE-115932
    public class PublishEventLog {
        public PublishEventLog(Boolean hasPubishedEvent){
            this.hasPubishedEvent = hasPubishedEvent;
        }
        public Boolean hasPubishedEvent {get; set;}
        public List<EventLog> eventLogList {get; set;}
    }

    public class EventLog {
        //public PublishSubscriptionChange__e subEvent {get; set;} //code commented as part of EDGE-139164
        public PublishSubscriptionChangeHV__e subEvent {get; set;} // code added as part of EDGE-139164
        
        public PublishServiceSpecificationChange__e specEvent {get; set;}
        public Database.Error errorMessage {get; set;}
    }

    //List<PublishSubscriptionChange__e>
    //updated method defination with new platform event - EDGE-139164
    public static void logApplicationLog(List<PublishSubscriptionChangeHV__e> subList,List<PublishServiceSpecificationChange__e>serviceSpecList,List<Database.SaveResult> saveResults){
        Logger2 logger = Logger2.getLogger('INVENTORYEVENTS');
        if (saveResults != null && !saveResults.isEmpty()) {
            PublishEventLog publishEventLogSuccess = new PublishEventLog(true);
            PublishEventLog publishEventLogFailure = new PublishEventLog(false);
            if (subList!=null) {
                for (Integer i = 0; i<subList.size(); i++) {
                    Database.SaveResult saveResult = saveResults[i];
                    EventLog eventlogMessage       = new EventLog();
                    eventlogMessage.subEvent = subList.get(i);
                    if (saveResult.isSuccess()) {
                        eventPublished.add(subList.get(i).Entity_ID__c);
                        system.debug('eventPublished1::'+eventPublished);
                        if (publishEventLogSuccess.eventLogList == null) {
                            publishEventLogSuccess.eventLogList = new List<EventLog>();
                        }
                        publishEventLogSuccess.eventLogList.add(eventlogMessage);
                    } else {
                        eventlogMessage.errorMessage = saveResult.getErrors()[0];
                        if (publishEventLogFailure.eventLogList == null) {
                            publishEventLogFailure.eventLogList = new List<EventLog>();
                        }
                        publishEventLogFailure.eventLogList.add(eventlogMessage);
                    }
                }
            } else {
                for (Integer i = 0; i<serviceSpecList.size(); i++) {
                    Database.SaveResult saveResult = saveResults[i];
                    EventLog eventlogMessage       = new EventLog();
                    eventlogMessage.specEvent = serviceSpecList.get(i);
                    if (saveResult.isSuccess()) {

                        speceventPublished.add(serviceSpecList.get(i).Entity_ID__c);

                        if (publishEventLogSuccess.eventLogList == null) {
                            publishEventLogSuccess.eventLogList = new List<EventLog>();
                        }
                        publishEventLogSuccess.eventLogList.add(eventlogMessage);
                    } else {
                        eventlogMessage.errorMessage = saveResult.getErrors()[0];
                        if (publishEventLogFailure.eventLogList == null) {
                            publishEventLogFailure.eventLogList = new List<EventLog>();
                        }
                        publishEventLogFailure.eventLogList.add(eventlogMessage);
                    }
                }
            }
            logger.logMessages(JSON.serialize(publishEventLogSuccess, true), '', '', '', '', '', false, false,null,'','','');
            logger.logMessages(JSON.serialize(publishEventLogFailure, true), '', '', '', '', '', false, false,null,'','','');
        }

        if (!(System.isBatch() || System.isFuture() || System.isScheduled())) {
            logger.exitLogger();
        }
    }

}