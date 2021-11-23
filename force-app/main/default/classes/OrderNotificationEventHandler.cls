/*********************************************************************************************************************************
*Class Name      :   OrderNotificationEventHandler
Test Class : OrderNotificationEventHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Manish Jha             7/10/2019               EDGE-115930
2.            Prajakta patil         4/2/2020                EDGE-142214
3.           Prajakta Patil          21/04/2020              Billing Notification Fix
*********************************************************************************************************************************
*/
// OrderNotification Platform Event Handler

public without sharing class OrderNotificationEventHandler {

    private static String correlationId = GuidUtil.NewGuid();
  private static final String CONST_INTERFACENAME = 'OrderNotificationEventHandler';
  
 @invocableMethod
 public static void billingNotificationHandler(List<NotificationParameters> paramsList) {
 System.debug('paramsList :: '+paramsList);
    Map < String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Set < Id > allRecsId = new Set < Id > ();
    List<Notification__c> updatedNotifList = new List<Notification__c>();
    Map < Id, Notification__c > notifMap = new Map < Id, Notification__c > ();
    
   for (NotificationParameters params: paramsList) {
      allRecsId.add(params.notificationId);
      Logger2 log = Logger2.getLogger('ProcessSubscriptionNotifications');  
      log.logMessages(JSON.serialize(params, true), '', '', '', '', '', false, false,200,'','','');  
      log.exitLogger(); 
    }
   ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,paramsList);
   
   notifMap = new Map<ID, Notification__c>([Select Id, Name, orderItemId__c, Status__c, Internal_Error_Description__c from Notification__c where Id in: allRecsId]);
   
    for(NotificationParameters params: paramsList) {
       Notification__c notifRec = notifMap.get(params.notificationId);
        if(notifRec!=null){
     notifRec.Status__c = 'Completed'; updatedNotifList.add(notifRec);}
     }
   
   if(!updatedNotifList.isEmpty()){ update updatedNotifList;
   }
   
 }
 
 public static void EventHandler(List<NotificationParameters> paramsList) {
     system.debug('inside paramsList ::'+paramsList);
     
      List < Notification__c > notigRecsUpdated = new List < Notification__c > ();
      Map < Id, Notification__c > notifMap = new Map < Id, Notification__c > ();
      Map < String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
      String toLog ='';
      integer k = 0;
    
     List<String> orderItemIdList = null;
    
     List<Notification__c> notificationList = new List<Notification__c>();
     List<Notification__c> notificationErrorList = new List<Notification__c>();
     Map<string,string> orderItemIdstatusMap = new  Map<string,string>();
     List<String> orderIdList = new List<String>();
     Map<String,List<notificationParameters>> orderidNotificationMap = new Map<String,List<notificationParameters>>();
     list<String>orderNumberList = new list<String>();
     boolean isbill = false;     
     
    try {    
    
        for(notificationParameters noti :paramsList){
           
        orderIdList.add(noti.externalOrderId);}
    
    system.debug('orderIdList::'+orderIdList);
    
     List<csord__Order__c> ordlist= [select id,csord__Order_Number__c from csord__Order__c where csord__Order_Number__c IN:orderIdList];
     system.debug('ordlist::'+ordlist);
    if(ordlist.isEmpty()){
        system.debug('Inside if===');
        for(notificationParameters noti :paramsList){
            
            Notification__c notif = new Notification__c();  
            notif.orderItemId__c = noti.orderItemId;
            notif.notificationAttributes__c = noti.notificationAttributes;
            notif.eventType__c = noti.eventType;
            notif.orderItemDetails__c = noti.orderItemDetails;
            notif.sourceSystem__c = noti.sourceSystem;
            notif.eventTimeStamp__c = noti.eventTimestamp;
            notif.externalOrderId__c = noti.externalOrderId;
            notif.orderItemVersion__c = noti.orderItemVersion;
            notif.errorDetails__c = noti.errorDetails;
            notif.Status__c = 'Error';
            notif.msCorrelationId__c = noti.msCorrelationId;
            notif.externalOrderVersion__c = noti.externalOrderVersion ; //EDGE-170548 
            notif.subscriptionDetails__c = noti.subscriptionDetails ;
            notificationErrorList.add(notif);
              
            orderItemIdstatusMap.put(noti.orderItemId,'Failed');

            toLog += '*'+noti.orderItemId+'-->'+notif.Status__c+'->'+noti.msCorrelationId+'\n';
        }
         if(!notificationErrorList.isEmpty()){
             try {
                insert notificationErrorList;
             }
             catch(DmlException e) {
                logException('EventHandler', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Inserting error notifications failed');
                throw e;
             }
         }
            
        publishEventCallbackMS(paramsList,orderItemIdstatusMap);
        
    }
    
    else{
    
      List<NotificationParameters> tempNotifList = new  List<NotificationParameters>();
    
     
               for(notificationParameters notifparam :paramsList){
                    List<NotificationParameters> notificationsList = new List<NotificationParameters>();
                    if(!orderItemIdNotifMap.isEmpty() && orderItemIdNotifMap.get(notifparam.orderItemId)!= null){
                     system.debug('if===========');
                    
                    notificationsList = orderItemIdNotifMap.get(notifparam.orderItemId);notificationsList.add(notifparam);
                    notificationsList = sort(notificationsList);   
                   
                }
                else {notificationsList.add(notifparam);}
                    system.debug('Else===========');
                orderItemIdNotifMap.put(notifparam.orderItemId, notificationsList);
                }
             system.debug('orderItemIdNotifMap::'+orderItemIdNotifMap);
        
              for(String key :orderItemIdNotifMap.keyset()){
                  system.debug('key=============');
                   tempNotifList.addAll(orderItemIdNotifMap.get(key)); 
                    
              }
              system.debug('tempNotifList ====='+tempNotifList);
              
             for(notificationParameters notifparam :tempNotifList){ if(notifparam.sourceSystem == null){ notifparam.sourceSystem ='Fulfilment';
                  }  }
                 system.debug('before tempNotifList::'+tempNotifList);
                 try{
                      ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,tempNotifList);
                      system.debug('after tempNotifList::'+tempNotifList);
                 }
                 catch(Exception e){
                    logException('EventHandler', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Manage order notifications failed');
                    throw e;
                 }
               
                
        for(notificationParameters notifparam :tempNotifList){
            Notification__c notification = new Notification__c();  
            notification.orderItemId__c = notifparam.orderItemId;
            notification.notificationAttributes__c = notifparam.notificationAttributes;
            notification.eventType__c = notifparam.eventType;
            notification.orderItemDetails__c = notifparam.orderItemDetails;
            notification.sourceSystem__c = notifparam.sourceSystem;
            notification.eventTimeStamp__c = notifparam.eventTimestamp;
            notification.externalOrderId__c = notifparam.externalOrderId;
            notification.orderItemVersion__c = notifparam.orderItemVersion;
            notification.errorDetails__c = notifparam.errorDetails;
            notification.Status__c = 'Completed';
            notification.msCorrelationId__c = notifparam.msCorrelationId;
            notification.externalOrderVersion__c = notifparam.externalOrderVersion ;        //EDGE-170548 
            
            notificationList.add(notification);
            orderItemIdstatusMap.put(notification.orderItemId__c,notification.Status__c);
            
        }      
        
        if(!notificationList.isEmpty()){insert notificationList;
            system.debug('inserted notificationList ::'+notificationList);
          
        }
  
   publishEventCallbackMS(tempNotifList,orderItemIdstatusMap);  
  } }  catch (Exception e) {
        logException('EventHandler', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Handler failed');
        throw e;
    } 

}


 public static void publishEventCallbackMS(List<NotificationParameters> tempNotifList, Map<string,string> orderItemIdstatusMap){
 List<EventMSCallBackDTO> EventMSCallBackList = new List<EventMSCallBackDTO>();
//List<EventMSCallBack__e>EventMSList = new List<EventMSCallBack__e>();
//List<Database.SaveResult> saveList = new List<Database.SaveResult>();
Logger2 log = Logger2.getLogger('EventMSCallBack');
try{
if(!tempNotifList.isEmpty() && !orderItemIdstatusMap.isEmpty()){
for(notificationParameters notif : tempNotifList){
EventMSCallBackDTO EventMSCallBack = new EventMSCallBackDTO();
EventMSCallBack.msCorrelationId = notif.msCorrelationId;
EventMSCallBack.orderItemId = notif.orderItemId;
EventMSCallBack.status = orderItemIdstatusMap.get(notif.orderItemId);
//EventMSCallBackList.add(EventMSCallBack);
EventMSCallBackList.add(EventMSCallBack);
/*EventMSCallBack__e EventMS = new EventMSCallBack__e ();
EventMS.eventresponse__c = JSON.serialize(EventMSCallBack);
EventMSList.add(EventMS);*/}
EventMSCallBack__e EventMS = new EventMSCallBack__e ();
EventMS.eventresponse__c = JSON.serialize(EventMSCallBackList);
 system.debug('EventMSCallBackList::'+EventMSCallBackList);
//system.debug('EventMSList::'+EventMSList);
Database.SaveResult sr  = EventBus.publish(EventMS);

System.debug('Events are published');
log.logMessages(JSON.serialize(EventMS, true), '', '', '', '', '', false, false,200,'','','');
log.exitLogger();
}

}
catch (Exception e) {
    logException('publishEventCallbackMS', '', correlationId,  e.getMessage() + '-' + e.getStackTraceString(), 'Callback failed');
System.debug('Exception:::' + e.getMessage() + '--'+ e.getLineNumber());
throw e;
}
}

   

    public static List<NotificationParameters > sort(List<NotificationParameters > notificationList){
        system.debug('Insidesort=========');
        NotificationParameters swap1 = new NotificationParameters();
        for(integer i = 0; i < notificationList.size(); i++){
            for(integer j = i; j < notificationList.size(); j++) {   
            if(notificationList[i].sequence > notificationList[j].sequence){swap1 = notificationList[i];
                notificationList[i] = notificationList[j];notificationList[j] = swap1;
            }  } 
        }
        system.debug('notificationList========='+notificationList);
        return notificationList;
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