/**
 * @Author : Ila Verma/Anu Yadav
 * @User Story : EDGE-50235
 * @Description : Interface For Billing Published Events
 * @Date : 05-12-2018
 */
public without sharing class BillingPublishEventsImpl implements BillingPublishEvents{
    
    private Set<Id> eventPublished = null;
    private static BillingPublishEventsImpl instance = null;
  private List<BillingAccountMSEventHV__e> billingHVList = null; //EDGE-194261

    @TestVisible
    private BillingPublishEventsImpl(){
        eventPublished = new Set<Id>();
    billingHVList=new List<BillingAccountMSEventHV__e>(); //EDGE-194261
    }
    
    public static BillingPublishEventsImpl getInstance(){
        if(instance == null){
            instance = new BillingPublishEventsImpl();    
        }
        return instance;
    }
    
    public class PublishEventLog{
        public PublishEventLog(Boolean hasPubishedEvent){
            this.hasPubishedEvent = hasPubishedEvent;
        }
        public Boolean hasPubishedEvent{get;set;}
        public List<EventLog> eventLogList{get;set;}
    }
    
    public class EventLog{
    public BillingAccountMSEventHV__e billingHVEvent{get;set;} //EDGE-194261
        public Database.Error errorMessage{get;set;}
    }
       
    //Creating Event Objects
    public void createBillingEventObject(List<sObject> eventRecords,String businessEntityName, String eventAction){
        for(sObject sObjectIterator : eventRecords){
            if(!hasEntityPublished(sObjectIterator.Id)){
                        Billing_Account__c billAcc = (Billing_Account__c)sObjectIterator;
            billingHVList.add(getMappingOfHVEvents(EventConstants.BILLING_ACCOUNT,sObjectIterator.Id, sObjectIterator,eventAction)); //EDGE-194261
                        
               }
        }
    }  
    
    public void addressEventObject(List<cscrm__Address__c> eventRecords,String businessEntityName, String eventAction){
        Set<Id> addIds = new Set<Id>();
        for(cscrm__Address__c add : eventRecords){
            addIds.add(add.Id);
        }
        Map<Id,Billing_Account__c> mapBillingAccountId = new Map<Id,Billing_Account__c>([Select id, Billing_Address__c from Billing_Account__c where Billing_Address__c IN: addIds]);
        for(sObject sObjectIterator : eventRecords){
                for(Id bId :mapBillingAccountId.keyset()){
           billingHVList.add(getMappingOfHVEvents(EventConstants.BILLING_ACCOUNT,bId,sObjectIterator,eventAction));  //EDGE-194261
                    
                }
         }
 }  
    
    public void createBillingEvent(){  
    /*EDGE-194261 Starts */
    List<Database.SaveResult> saveHVResults = null;
        if(!billingHVList.isEmpty() ){
//if(!billingHVList.isEmpty() && !Test.isRunningTest()){
            system.debug('PublishBillingEventsImpl---createBillingEvent()--published--events'+billingHVList);
            saveHVResults = EventBus.publish(billingHVList);
            logApplicationLogHV(saveHVResults);
        }
        billingHVList.clear();
    /*EDGE-194261 Ends*/
    }
    
    private Boolean hasEntityPublished(Id entityId){
        return eventPublished.contains(entityId) ? true : false;
    }
   
   
  /* EDGE-194261 - Upgrading the customer MS platform event to HV platform event - Starts */
    private BillingAccountMSEventHV__e getMappingOfHVEvents(String businessEntity,Id ids,SObject objs,String eventAction){
        BillingAccountMSEventHV__e hvEvent = new BillingAccountMSEventHV__e();
        hvEvent.Business_Entity__c= businessEntity;
        hvEvent.Entity_ID__c = ids;
        hvEvent.Object_Name__c=objs.getSObjectType().getDescribe().getName();
        hvEvent.Operation__c= eventAction;
        System.debug('hvEvent::'+hvEvent);
        return hvEvent;
    }
  
    @TestVisible
    private void logApplicationLogHV(List<Database.SaveResult> saveResults){
        Logger2 logger = Logger2.getLogger('MICROSERVICE');
        if(saveResults != null && !saveResults.isEmpty()){
            PublishEventLog publishEventLogSuccess = new PublishEventLog(true);
            PublishEventLog publishEventLogFailure = new PublishEventLog(false);
            for(Integer i=0; i<billingHVList.size(); i++){
                Database.SaveResult saveResult = saveResults[i];
                EventLog eventlogMessage = new EventLog();
                eventlogMessage.billingHVEvent = billingHVList.get(i);
                if(saveResult.isSuccess()){
                    eventPublished.add(billingHVList.get(i).Entity_ID__c);
                    if(publishEventLogSuccess.eventLogList == null){
                        publishEventLogSuccess.eventLogList = new List<EventLog>();
                    }
                    publishEventLogSuccess.eventLogList.add(eventlogMessage);
                } else {
                    eventlogMessage.errorMessage = saveResult.getErrors()[0];
                    if(publishEventLogFailure.eventLogList == null){
                        publishEventLogFailure.eventLogList = new List<EventLog>();
                    }
                    publishEventLogFailure.eventLogList.add(eventlogMessage);
                }
            }

            logger.logMessages(JSON.serialize(publishEventLogSuccess, true), '', '', '', '', '', false, false,null,'','','');
            logger.logMessages(JSON.serialize(publishEventLogFailure, true), '', '', '', '', '', false, false,null,'','','');
        }
        //Insert application log.
        if(!(System.isBatch() || System.isFuture() || System.isScheduled())){
            logger.exitLogger();
        }
    }
    /* EDGE-194261 - Upgrading the customer MS platform event to HV platform event - Ends */
}