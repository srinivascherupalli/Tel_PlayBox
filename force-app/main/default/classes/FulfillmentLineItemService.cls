/***********************************
Developer: Chandrakanth, Ravi Shankar
Description: Nov 03,2019
             Changes for EDGE-118625
Class Name: FulfillmentLineItemService
***********************************/

public with sharing class FulfillmentLineItemService {

    @InvocableMethod
    public static void onFulfillmentClosure(List<Id> fulfillmentItemIds){
        List<Id> caseIds = new List<Id>();
        List<Id> subscriptionIds = new List<Id>();
        for(FulfillmentLineItem__c fulfillmentLineItem : [select Id, subscription__c,case__c from FulfillmentLineItem__c where Id IN : fulfillmentItemIds]){
            subscriptionIds.add(fulfillmentLineItem.subscription__c);
            caseIds.add(fulfillmentLineItem.case__c);
        }
        serviceFulfillment(subscriptionIds);
        caseClosure(caseIds);
    }

    public static void serviceFulfillment(List<Id> subscriptionId){
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        for(csord__Subscription__c subscription : [SELECT Id, (SELECT Id,csord__Status__c from csord__Services__r) from csord__Subscription__c where Id IN : subscriptionId]){
            for(csord__Service__c service : subscription.csord__Services__r){
                if(String.isNotBlank(service.csord__Status__c) && 'Pending'.equals(service.csord__Status__c)){
                    service.csord__Status__c = 'In Progress';
                    serviceList.add(service);
                } else if(String.isNotBlank(service.csord__Status__c) && 'In Progress'.equals(service.csord__Status__c)){
                    service.csord__Status__c = 'Connected';
                    serviceList.add(service);
                }
            }
        }
        try{
            if(!serviceList.isEmpty()){
                UPDATE serviceList;
            }
        } catch(DmlException dmlException){
            System.debug(LoggingLevel.ERROR, 'Exception while updating : ' + dmlException.getMessage());
        }
    }

    public static void caseClosure(List<Id> caseIds){
        List<Case> caseList = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>(caseIds);
        for(FulfillmentLineItem__c fulfillmentItem : [SELECT Id, case__c, case__r.Status, Status__c from FulfillmentLineItem__c where Status__c != 'Completed' and case__c IN : caseIds]){
            if(caseIdSet.contains(fulfillmentItem.case__c)){
                caseIdSet.remove(fulfillmentItem.case__c);
            }
        }
        for(Id caseId : caseIdSet){
            Case caseRec = new Case(Id=caseId,Status='Closed');
            caseList.add(caseRec);
        }
        try{
            if(!caseList.isEmpty()){
                UPDATE caseList;
            }
        }  catch(DmlException dmlException){
            System.debug(LoggingLevel.ERROR, 'Exception while updating : ' + dmlException.getMessage());
        }
    }

}