/**
 * @Author : Shambo Ray/ChandraKanth B./Anu Yadav
 * @User Story : EDGE-863
 * @Description : Interface For Published Events
 * @Date : 05-05-2018
 */
/**Update By : Team Lisbon - Ravi Dodiya
 * @User Story : P2OB-11660
 * @Description : Added new fields Record_LastModified_Date__c Field In Platform Event 
 * @Date : 12-11-2020
 */
public without sharing class PublishEventsImpl implements PublishEvents{
    
    private Set<Id> eventPublished = null;
    private static PublishEventsImpl instance = null;
	private List<CustomerMicroServiceEventHV__e> customerHVList = null; //EDGE-194261

    @TestVisible
    private PublishEventsImpl(){
        eventPublished = new Set<Id>();
		customerHVList=new List<CustomerMicroServiceEventHV__e>(); //EDGE-194261
    }
    
    public static PublishEventsImpl getInstance(){
        if(instance == null){
            instance = new PublishEventsImpl();    
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
		public CustomerMicroServiceEventHV__e customerHVEvent{get;set;} // EDGE-194261
        public Database.Error errorMessage{get;set;}
    }
       
    //Creating Event Objects
    public void createEventObject(List<sObject> eventRecords,String businessEntityName, String eventAction){
        for(sObject sObjectIterator : eventRecords){
            Id entityId = getEntityID(sObjectIterator);
            String entityString = String.valueOf(entityId);
            if(!hasEntityPublished(entityId)){
                if(EventConstants.ACCOUNT_CONTACT_RELATIONSHIP.equals(sObjectIterator.getSObjectType().getDescribe().getName())){
                    AccountContactRelation acr=(AccountContactRelation)sObjectIterator;
                    customerHVList.add(getMappingOfHVEvents(EventConstants.BUSINESS_ENTITY_ACCOUNT,acr.accountid,sObjectIterator,eventAction)); //EDGE-194261
                    customerHVList.add(getMappingOfHVEvents(EventConstants.BUSINESS_ENTITY_CONTACT,acr.contactid,sObjectIterator,eventAction)); //EDGE-194261
                } else if(!(EventConstants.ACCOUNT_CONTACT_RELATIONSHIP.equals(sObjectIterator.getSObjectType().getDescribe().getName()))){
                   customerHVList.add(getMappingOfHVEvents(businessEntityName,entityId,sObjectIterator,eventAction)); //EDGE-194261
                }   
            }
            else if(entityString.startsWith('003') && eventAction== EventConstants.CREATE_OPERATION){
                customerHVList.add(getMappingOfHVEvents(businessEntityName,entityId,sObjectIterator,eventAction)); //EDGE-194261
            }
    }
    }
 
    public void createEvent(){
		/*EDGE-194261 Starts here */
        List<Database.SaveResult> saveResultsHV = null;
        if(!customerHVList.isEmpty() ){
		//&& !Test.isRunningTest()
            system.debug('PublishEventsImpl---createEvent()--published--events'+customerHVList);
            saveResultsHV = EventBus.publish(customerHVList);
            logApplicationLogHV(saveResultsHV);
        }
        customerHVList.clear();		
		/*EDGE-194261 Ends Here */
    }
    
    private Boolean hasEntityPublished(Id entityId){
        return eventPublished.contains(entityId) ? true : false;
    }
    
    //Getting ID of Entity
    private ID getEntityID(sObject sObjectIterator){
        if(EventConstants.FUNCTIONAL_CONTACT_ROLE.equals(sObjectIterator.getSObjectType().getDescribe().getName())){
            Functional_Contact_Role__c fcr=(Functional_Contact_Role__c)sObjectIterator;
            return fcr.ContactID__c;
        } else if(EventConstants.CONTACT_ADDRESS_RELATIONSHIP.equals(sObjectIterator.getSObjectType().getDescribe().getName())){
            cscrm__Contact_Address_Relationship__c conAdd=(cscrm__Contact_Address_Relationship__c)sObjectIterator;
            return conAdd.cscrm__Contact__c;
        } else if(EventConstants.BILLING_ACCOUNT.equals(sObjectIterator.getSObjectType().getDescribe().getName())){
            Billing_Account__c billAcc=(Billing_Account__c)sObjectIterator;
            return billAcc.Account__c;
        } else if(EventConstants.ACCOUNT_ADDRESS_RELATIONSHIP.equals(sObjectIterator.getSObjectType().getDescribe().getName())){
            cscrm__Account_Address_Relationship__c accAdd=(cscrm__Account_Address_Relationship__c)sObjectIterator;
            return accAdd.cscrm__Account__c;
        } else if(EventConstants.ACCOUNT_INDUSTRY_RELATIONSHIP.equals(sObjectIterator.getSObjectType().getDescribe().getName())){
            Account_Industry_Relationship__c air=(Account_Industry_Relationship__c)sObjectIterator;
            return air.AccountID__c;
        }return sObjectIterator.ID;  
    } 
    
   /* EDGE-194261 Starts Here */
    //Mapping Of Events
    private CustomerMicroServiceEventHV__e getMappingOfHVEvents(String businessEntity,Id ids,SObject objs,String eventAction){
        CustomerMicroServiceEventHV__e eventHV = new CustomerMicroServiceEventHV__e();
        eventHV.Business_Entity__c= businessEntity;
        eventHV.Entity_ID__c = ids;
        eventHV.Object_Name__c=objs.getSObjectType().getDescribe().getName();
        eventHV.Operation__c= eventAction;
        eventHV.Reference_To__c=objs.id; //Added Part of EDGE-131532
        eventHV.Record_LastModified_Date__c=(Datetime)objs.get('LastModifiedDate');// added by Ravi Dodiya For P2OB-11660
        return eventHV;
    }
    
        //Capture application log.
    @TestVisible 
    private void logApplicationLogHV(List<Database.SaveResult> saveResults){
        Logger2 logger = Logger2.getLogger('MICROSERVICE');
        if(saveResults != null && !saveResults.isEmpty()){
            PublishEventLog publishEventLogSuccess = new PublishEventLog(true);
            PublishEventLog publishEventLogFailure = new PublishEventLog(false);
            for(Integer i=0; i<customerHVList.size(); i++){
                Database.SaveResult saveResult = saveResults[i];
                EventLog eventlogMessage = new EventLog();
                eventlogMessage.customerHVEvent = customerHVList.get(i);
                if(saveResult.isSuccess()){
                    eventPublished.add(customerHVList.get(i).Entity_ID__c);
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
		/* EDGE-194261 Ends Here */
    
}