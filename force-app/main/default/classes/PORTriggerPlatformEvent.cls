public with sharing class PORTriggerPlatformEvent{

    @InvocableMethod
             
        public static void publishCreateEvents(List<Partner_of_Record__c> newList){
        //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newList,EventConstants.BUSINESS_ENTITY_ACCOUNT,EventConstants.UPDATE_OPERATION);
        publishIntface.createEvent(); 
    }

     }