/*************************************************************************************************
Name : OrdsNotifTrigger 
Description : Trigger to process notifications from Miro Service
TestClass : OrdsNotifTriggerTest 
===============================================================================================================================
Sr.No.    Developer Name      Date          Story              Description
1.        Team Munich       01-July-2020    Updated             Logic to Process notifications in a batch of 5
2.        Pawan/Gnana       10-July-2020    EDGE-161437         Updated code as per review comments
3.           Pawan          19-Mar-2021                         Logging for Notifications from MS
===============================================================================================================================
***************************************************************************************************/
/*
* Processing 5 notifications at a time, sending remaining back to event and will be processed in subsequent transactions in a batch of 5.
*/

trigger OrdsNotifTrigger on OrderNotification__e(after insert) {

    private static final String CONST_INTERFACENAME = 'OrdsNotifTrigger';

    List<NotificationParameters> notificationParametersList = new List<NotificationParameters>();
    String ReplayIdOfPreviousEvent = '';
    Integer counter = 0;
    String toLog ='';
    String toLogAllEvents ='';
    Integer fixedSize = Integer.valueOf(System.Label.fixedSize);
    Integer fullBatchSize = trigger.new.size();
    List<OrderNotification__e> eventList = new List<OrderNotification__e>();
    eventList.addAll(trigger.new);
    if(!eventList.isEmpty()){
         Logger2 log = Logger2.getLogger('All_HVMSNotifications');
                        log.logMessages(JSON.serialize(eventList.toString(), true), '', '', '', '', '', false, false,200,'','','');
                        log.exitLogger();
    }
    for(OrderNotification__e event : trigger.new){
        try {
            System.debug('Platform Event counter'+counter);
            System.debug(counter + 'Event ExternalId'+event.externalOrderId__c);
            fullBatchSize = fullBatchSize - 1;
            if((counter < fixedSize) && (fullBatchSize != 0)){  //First 4 notification will be processed in this block
                System.debug('Event ExternalId'+event.externalOrderId__c);
                toLog += '*'+event.orderItemId__c+'->'+event.msCorrelationId__c+'\n';
                NotificationParameters notificationParameters = OrdsNotifTriggerHelper.createNotificationParameterList(event);
                notificationParametersList.add(notificationParameters);
                ReplayIdOfPreviousEvent = event.ReplayId;
            }   
            else if(fullBatchSize == 0){    //last notification in case of notification equal or less than 6 will be processed in this block
                toLog += '*'+event.orderItemId__c+'->'+event.msCorrelationId__c+'\n';
                NotificationParameters notificationParameters = OrdsNotifTriggerHelper.createNotificationParameterList(event);
                notificationParametersList.add(notificationParameters);
                
             EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
                
                if(!notificationParametersList.isEmpty()){
                  try{
                        if(!String.isBlank(toLog)){
                               Logger2 log = Logger2.getLogger('HVMSEvents');
                        log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false,200,'','','');
                        log.exitLogger();
                        }
                        OrderNotificationEventHandler.EventHandler(notificationParametersList);
                  }
                  catch(Exception e){logException('OrdsNotifTrigger', event.externalOrderId__c, event.msCorrelationId__c, e.getMessage() + '-' + e.getStackTraceString(), 'Error while processing notification');
                  }
                }
                counter = 0;
                notificationParametersList = new List<NotificationParameters>();
                break;
            }
            else {      //Incase of Notifications more than 6 batch of for batch of 5 notifications method call will happen from this block
            
                    if(String.isNotBlank(ReplayIdOfPreviousEvent)){
                    EventBus.TriggerContext.currentContext().setResumeCheckpoint(ReplayIdOfPreviousEvent);
                    }
                if(!notificationParametersList.isEmpty()){
                  try{
                        if(!String.isBlank(toLog)){
                               Logger2 log = Logger2.getLogger('HVMSEvents');
                        log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false,200,'','','');
                        log.exitLogger();
                        }
                        OrderNotificationEventHandler.EventHandler(notificationParametersList);
                  }
                  catch(Exception e){logException('OrdsNotifTrigger', event.externalOrderId__c, event.msCorrelationId__c,  e.getMessage() + '-' + e.getStackTraceString(), 'Error while processing notification');
                  }
                }

                //Commenting this because event will be set to 6th event which is wrong, it should be set to 5th as the next event will be picked in further transaction
                //EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
                counter = 0;
                notificationParametersList = new List<NotificationParameters>();
                break;
            }
            counter++;
          //  EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);   //Sending events other than first 5, remaining will be send back to event to process in susequent transactions
        }
        catch(Exception e) {logException('OrdsNotifTrigger', event.externalOrderId__c, event.msCorrelationId__c,  e.getMessage() + '-' + e.getStackTraceString(), 'Error while processing notification');
        }      
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