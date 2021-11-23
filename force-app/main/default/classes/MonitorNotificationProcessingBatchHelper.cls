/********************************************************
Class Name : MonitorNotificationProcessingBatchHelper
===============================================================================================================================
Change.No.    Developer Name          Date              Story Description
1.             vaibhav              15/02/2021          EDGE-201432

**********************************************************/
public class MonitorNotificationProcessingBatchHelper{
    
    public static void processRecords(Map<Id,csord__Subscription__c> allSubMap,Map<String,ApplicationLog__c> subToAppLogMap){
        Map<String,csord__Subscription__c> subWithEventID = new Map<String,csord__Subscription__c>();
        Map<Id,csord__Subscription__c> subTobeUpdated = new Map<Id,csord__Subscription__c>();
        List<String> subNumList = new List<String>();
        
        for(csord__Subscription__c sub :allSubMap.values())
        {
            if(sub.eventId__c!=null)
            {
                subWithEventID.put(sub.eventId__c,sub);
            }else{
                String subId = sub.id;
                if(subToAppLogMap.containsKey(subId)){
                    ApplicationLog__c applLog = subToAppLogMap.get(subId);
                    BillingPostSubscriptionResponseDTO responseDTO = BillingPostSubscriptionResponseDTO.parse(applLog.Message__c);
                    sub.eventId__c = responseDTO.eventId;
                    subWithEventID.put(responseDTO.eventId,sub);
                    subTobeUpdated.put(sub.id, sub);
                }
                
            }
            subNumList.add(sub.csordtelcoa__Subscription_Number__c);
        }
        if(!subTobeUpdated.isEmpty())
        {
            update subTobeUpdated.values();
        }
        if(!subWithEventID.isEmpty()){
            List<Number__c> numList=[Select id,name,Service_Number__c,Status__c,Subscription_number__c,Service_Id__c,Product_ID__c,toBeCancelled__c,IsUpdatedFromBatch__c  From Number__c where Subscription_number__c IN:subNumList];
            processNumbers(numList);
            processSubscriptions(subWithEventID);
            updateOrchStep(subWithEventID);
        }
        
        
    }//end of method    

    public static NotificationParameters parseSubsNotification(String json){
        return (NotificationParameters) System.JSON.deserialize(json, NotificationParameters.class);
    }
    
    public static void processSubscriptions(Map<String,csord__Subscription__c> subWithEventID){  
        Map<Id,csord__Subscription__c>  subWithFinalStatusnew =new Map<Id,csord__Subscription__c> ();
        List<NotificationParameters> paramsList =new List<NotificationParameters>();
        Map<String,List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
        for(Notification__c notif : [select id,eventType__c,externalOrderId__c,notificationAttributes__c,orderItemId__c,sourceSystem__c,Status__c,orderItemDetails__c,eventTimeStamp__c,orderItemVersion__c,errorDetails__c from Notification__c where orderItemId__c IN :subWithEventID.keyset() and  sourceSystem__c = 'Billing'])    
        {
            NotificationParameters notifParam =new NotificationParameters();
            notifParam.orderItemId = notif.orderItemId__c;
            notifParam.externalOrderId = notif.externalOrderId__c;
            notifParam.sourceSystem = notif.sourceSystem__c;
            notifParam.eventType = notif.eventType__c;
            notifParam.notificationAttributes = notif.notificationAttributes__c;
            notifParam.errorDetails = notif.errorDetails__c;
            notifParam.orderItemDetails = notif.orderItemDetails__c;
            notifParam.eventTimestamp = notif.eventTimeStamp__c;
            paramsList.add(notifParam);
            
        }
        if(!paramsList.isEmpty()){
             ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,paramsList);
        }
       
        
    }
    
    
    public static void processNumbers(List<Number__c> numList){
        Map<Id,Number__c> numTobeUpdated = new Map<Id,Number__c>();
        for(Number__c num :numList){
            num.IsUpdatedFromBatch__c = 'true';
            numTobeUpdated.put(num.id,num);
        }
        
        if(!numTobeUpdated.isEmpty()){update numTobeUpdated.values();
        }
        
        
    }
    
    public static void updateOrchStep(Map<String,csord__Subscription__c> subWithEventID){
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Process__c> orchProcessList = new List<CSPOFA__Orchestration_Process__c>();
        for(CSPOFA__Orchestration_Step__c step :[select id,Name,CSPOFA__Status__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.CSPOFA__Status__c,CSPOFA__Message__c from CSPOFA__Orchestration_Step__c where CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c IN :subWithEventID.values() and CSPOFA__Status__c = 'error' and Name LIKE '%Post Subscription API%']){
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Message__c = 'Success : Updated from Batch';
            step.CSPOFA__Orchestration_Process__r.CSPOFA__Status__c ='In Progress';
            stepList.add(step);
            orchProcessList.add(step.CSPOFA__Orchestration_Process__r);
        }
        
        if(!stepList.isEmpty())
        {
            update stepList;
        }   
        if(!orchProcessList.isEmpty())
        {
            update orchProcessList;
        }
        
    }
}