/****************************************************************************
@Author: Shambo Ray
@CreateDate: 24/04/2018.
@Description: AccountIndustryRelationshipHandler For Microservice
********************************************************************************/
public without sharing class AccountIndustryRelationshipHandler {
    
    public void onAfterInsert(List<Account_Industry_Relationship__c> newList){
        publishCreateEvents(newList,EventConstants.UPDATE_OPERATION);
    }
    
    public void onAfterUpdate(List<Account_Industry_Relationship__c> newList){
        publishCreateEvents(newList,EventConstants.UPDATE_OPERATION);
    }    
    
    private void publishCreateEvents(List<Account_Industry_Relationship__c> newList,String event){
        //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newList,EventConstants.BUSINESS_ENTITY_ACCOUNT,event);
        publishIntface.createEvent();
        
    }
}