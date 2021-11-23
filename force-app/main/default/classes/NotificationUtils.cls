/*************************************************************************************************
Name : Notification Utils
Description :Notification Utils Class

Author: Dunna, Uday Kumar
Date: 14/09/2021

***************************************************************************************************/
Public class NotificationUtils {
    
    /******************************************************************
Method: createNotificationParameterList
Description: creates Notification Parametes List 
Author: 
******************************************************************/  
    Public static NotificationParameters getNotificationParameters(OrderNotification__e event) {
        
        String toLog ='';
        NotificationParameters a = new NotificationParameters();
        try{
            a.errorDetails = event.errorDetails__c;
            a.externalOrderId= event.externalOrderId__c;
            a.orderItemVersion = Integer.valueOf(event.orderItemVersion__c);
            a.notificationAttributes = event.notificationAttributes__c;
            a.orderItemDetails = event.orderItemDetails__c;
            a.eventType = event.eventType__c;
            a.orderItemId = event.orderItemId__c;
            a.sourceSystem = event.sourceSystem__c ;
            a.sequence = Integer.valueOf(event.sequence__c);
            a.msCorrelationId = event.msCorrelationId__c;
            a.eventTimestamp = event.eventTimeStamp__c;
            
            a.notifyAttributes =  ManageOrderNotificationUtil.parseAttributes('{'+event.notificationAttributes__c+'}');  
            
            toLog += '*'+event.orderItemId__c+'->'+event.msCorrelationId__c+'\n';
            if(!String.isBlank(toLog)){
                Logger2 log = Logger2.getLogger('NotificationUtils.getNotificationParameters');
                log.logMessages(JSON.serialize(toLog, true), '', '', '', '', '', false, false,200,'','','');
                log.exitLogger();
            }
        	}catch(exception ex){
                C2O_Utilities.createException(ex);
            }       
        return a;
    }
    
}