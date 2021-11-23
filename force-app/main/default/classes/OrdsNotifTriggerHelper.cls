/*************************************************************************************************
Name : OrdsNotifTriggerHelper
Description :Helper class for OrdsNotifTrigger
Author: Gnana
Story: INC000093288418 
Test Class: OrdsNotifTriggerHelperTest

===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Pawan                  30/11/2020      EDGE-170548 : added externalOrderVersion
***************************************************************************************************/
public class OrdsNotifTriggerHelper {
    
    /******************************************************************
    Method: createNotificationParameterList
    Description: creates Notification Parametes List 
    Author: Gnana
    ******************************************************************/  
    public static NotificationParameters createNotificationParameterList(OrderNotification__e event) {
        String toLog ='';
        NotificationParameters notificationParameters = new NotificationParameters();
        notificationParameters.errorDetails = event.errorDetails__c;
        notificationParameters.externalOrderId= event.externalOrderId__c;
        notificationParameters.orderItemVersion = Integer.valueOf(event.orderItemVersion__c);
        notificationParameters.notificationAttributes = event.notificationAttributes__c;
        notificationParameters.orderItemDetails = event.orderItemDetails__c;
        notificationParameters.eventType = event.eventType__c;
        notificationParameters.orderItemId = event.orderItemId__c;
        notificationParameters.sourceSystem = event.sourceSystem__c ;
        notificationParameters.sequence = Integer.valueOf(event.sequence__c);
        notificationParameters.msCorrelationId = event.msCorrelationId__c;
        notificationParameters.eventTimestamp = event.eventTimeStamp__c;
        notificationParameters.externalOrderVersion = Integer.valueOf(event.externalOrderVersion__c);       //EDGE-170548

        toLog += '*'+event.orderItemId__c+'->'+event.msCorrelationId__c+'\n';
        if(!String.isBlank(toLog)){
            Logger2 log = Logger2.getLogger('OrdsNotifTriggerHelper');
            log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false,200,'','','');
            log.exitLogger();
        }
        return notificationParameters;
    }

}