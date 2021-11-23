public class BulkifiedOrderNotifications {
    public void sendBulkNotifications(List<Notification__c> listNotifications){
        List<OrderNotification__e> listOrderNotifyEvents = new List<OrderNotification__e>();
        setNotificationProcessingStatus(listNotifications);
        for(Notification__c notify : listNotifications){
            listOrderNotifyEvents.add(getOrderNotifyEvent(notify));
        }
        if(listOrderNotifyEvents.size() > 0){
            EventBus.publish(listOrderNotifyEvents);
        }
        
    }
    
    private void setNotificationProcessingStatus(List<Notification__c> listNotifications){
        for (Notification__c notification : listNotifications){
            notification.Status__c = 'Queued';
        }
        update listNotifications;
    }
    
    private OrderNotification__e getOrderNotifyEvent(Notification__c notify){
        OrderNotification__e orderNotifyEvent = new OrderNotification__e();
        orderNotifyEvent.errorDetails__c = notify.errorDetails__c;
        orderNotifyEvent.eventTimeStamp__c = notify.eventTimeStamp__c;
        orderNotifyEvent.eventType__c = notify.eventType__c;
        orderNotifyEvent.externalOrderId__c = notify.externalOrderId__c;
        orderNotifyEvent.Internal_Error_Description__c = notify.Internal_Error_Description__c;
        orderNotifyEvent.notificationAttributes__c = notify.notificationAttributes__c;
        orderNotifyEvent.Notification_Id__c = notify.id;
        orderNotifyEvent.orderItemDetails__c = notify.orderItemDetails__c;
        orderNotifyEvent.orderItemId__c = notify.orderItemId__c;
        orderNotifyEvent.orderItemVersion__c = notify.orderItemVersion__c;
        orderNotifyEvent.Request__c = notify.Request__c;
        orderNotifyEvent.sourceSystem__c = notify.sourceSystem__c;
        orderNotifyEvent.status__c = notify.Status__c;
        return orderNotifyEvent;
    }
}