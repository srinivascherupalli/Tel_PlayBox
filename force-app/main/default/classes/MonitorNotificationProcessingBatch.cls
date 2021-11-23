/********************************************************
Class Name : MonitorNotificationProcessingBatch
===============================================================================================================================
Change.No.    Developer Name          Date              Story Description
1.             vaibhav              15/02/2021          EDGE-201432
2.             Pawan/Jawahar        17/09/2021          Notification Batch FIx.
**********************************************************/
global with sharing class MonitorNotificationProcessingBatch implements Database.Batchable<sObject>,Database.Stateful{
  Public Integer totlRecordsProcessed = 0;
  public Database.QueryLocator start(Database.BatchableContext BC){
    DateTime last_hr_updated = Datetime.now().addHours(-1);
    String query = 'SELECT Id, Name, csord__Order__c,csord__Status__c,eventId__c,triggerBill_RTB__c,toBeCancelled__c,LastModifiedDate,Trigger_RTS__c,'; 
        query += ' cssdm__solution_association__c, csordtelcoa__Replaced_Subscription__c,csordtelcoa__Subscription_Number__c,csord__Order__r.csord__Order_Number__c'; 
        query += ' FROM csord__Subscription__c WHERE LastModifiedDate >= :last_hr_updated';
        system.debug('query ' + query);
        return Database.getQueryLocator(query);
  }
    
  global void execute(Database.BatchableContext BC, List<csord__Subscription__c> scope){
    Set<string> ordnumSet = new Set<string>();
    Map<Id,csord__Subscription__c> subWithProvisioned = new Map<Id,csord__Subscription__c>();
    Map<Id,csord__Subscription__c> subWithBillreadyInProgress = new Map<Id,csord__Subscription__c>();
        Map<Id,csord__Subscription__c> subWithUpdateInProgress = new Map<Id,csord__Subscription__c>();
    List<String> subList = new List<String>(); 
    Map<String,ApplicationLog__c> subToAppLogMap =new Map<String,ApplicationLog__c>();
    Map<Id,csord__Subscription__c> allSubMap =new Map<Id,csord__Subscription__c>();
        totlRecordsProcessed = scope.size();
        Map <String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
        List <NotificationParameters> paramsList = new List<NotificationParameters>();
    for(csord__Subscription__c sub : scope)
    {
      
        if((sub.csord__Status__c == 'Provisioned' || sub.csord__Status__c == 'Bill Readiness In Progress') && (sub.triggerBill_RTB__c == true || sub.Trigger_RTS__c == true) && sub.eventId__c == null)
        {
         subWithProvisioned.put(sub.id,sub);
         ordnumSet.add(sub.csord__Order__r.csord__Order_Number__c);
         subList.add(sub.id);
         
        }else if((sub.csord__Status__c == 'Provisioned' || sub.csord__Status__c == 'Bill Readiness In Progress') && (sub.triggerBill_RTB__c == true || sub.Trigger_RTS__c == true) && sub.eventId__c != null)
        {subWithBillreadyInProgress.put(sub.id,sub);}
            else if(sub.csord__Status__c == 'Update In Progress'){subList.add(sub.id);}
    }
  
    for(ApplicationLog__c appLog : [Select id,correlationId__c,Reference_Info__c,Related_Record_Id__c,Request_Message__c,Request_Method__c,Message__c,Status_Code__c from ApplicationLog__c where (correlationId__c IN :ordnumSet and Related_Record_Id__c IN :subList and Reference_Info__c ='PostSubscriptionHandler' and Status_Code__c = '202') OR (Reference_Info__c ='ProcessSubscriptionNotifications' and Status_Code__c = '200')])
    {
             string reqbody = '';
            if(appLog.Request_Message__c!=null){reqbody = appLog.Request_Message__c;}
      if(string.isNotBlank(reqbody) && reqbody.contains('requestType')){BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(reqbody);
         if(billSpecDTO.requestType == 'RTB')
        {subToAppLogMap.put(appLog.Related_Record_Id__c,appLog);}
      }else if(string.isNotBlank(reqbody) && reqbody.contains('subscriptionDetails')){
            System.debug('contains subs details...'+reqbody);
            NotificationParameters notif = MonitorNotificationProcessingBatchHelper.parseSubsNotification(reqbody);
            if(!String.isBlank(notif.subscriptionDetails)){
             
              System.debug('notif:: '+notif);
                  paramsList.add(notif);
              }
          }else{subToAppLogMap.put(appLog.Related_Record_Id__c,appLog);}
      
    }
      allSubMap.putAll(subWithProvisioned);
      allSubMap.putAll(subWithBillreadyInProgress);
      if(paramsList != null && paramsList.size() > 0){
                System.debug('Calling processSubscriptionNotification...'+paramsList);
                ManageBillingSubsNotificationHelper.processSubscriptionNotification(orderItemIdNotifMap,paramsList);
            }
            else{
                MonitorNotificationProcessingBatchHelper.processRecords(allSubMap,subToAppLogMap);
            }
  
  }
  
  global void finish(Database.BatchableContext BC){
    AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email   FROM AsyncApexJob where Id =:BC.getJobId()];

    //if(a.NumberOfErrors >0 ||Test.isRunningTest()){
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { Label.DLforNotificationBatch };
        //String[] toAddresses = new String[] { 'Vaibhav.deshpande@team.telstra.com','jawahar.muthuadaikalam@team.telstra.com' };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Alert: MonitorNotificationProcessingBatch process failure ' + a.Status  + 'Batch ID : '+BC.getJobId());
        mail.setPlainTextBody('Batch processed : '+ a.TotalJobItems + ' records processed  :' + totlRecordsProcessed +   '  with :'+ a.NumberOfErrors + ' failures.  Error Details : '+ a.ExtendedStatus + ' Org url : '+baseUrl);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  // } 
  }



}