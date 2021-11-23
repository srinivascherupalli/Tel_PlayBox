/**================================================================
Name: CoBABatchHandler
Description: Batch class to sbmit CoBA request to BDS
Test class: CoBABillHandlerTest
Created Date: April 20, 2021
Created By: Akanksha Jain
==================================================================*/
public with sharing class CoBABatchHandler implements Database.batchable<Sobject>,Database.Stateful,Database.AllowsCallouts {
    public Id caseId;
    public List<Id> listFailedSubs = new List<Id>();
    boolean isResBlank = true;
    public CoBABatchHandler(Id cobaCaseId)
    {
        this.caseId =cobaCaseId;
    }
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        try{
            String subQuery ='';
            Set<String> subStatus = new Set<String>{'Pending','In Error'};
            if(caseId!=null)
            {
                subQuery = 'Select csord_Subscription__r.csordtelcoa__Subscription_Number__c,csord_Subscription__r.Id,Billing_Account_Number__c,csord_Subscription__r.csord__Order__r.csord__Order_Number__c from Subscriptions_to_Case_Association__c where case__r.Id=:caseId and status__C IN:subStatus';
            }
            return Database.getQueryLocator(subQuery); 
        }
        catch(Exception e){
            CoBABillHandler.logException('Start', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Error in start method');throw e;
        }
        
    }
    public void execute(Database.BatchableContext BC, list<Subscriptions_to_Case_Association__c> lstSubIds)
    {
        try {
            List<Id> subIdList = new List<Id>();
            list<Subscriptions_to_Case_Association__c> updateSubList = new List<Subscriptions_to_Case_Association__c>();
            String targetBillAccNum ='';
            String orderNum ='';
            String statusCode ='';
            String responseBody='';
            HttpResponse calloutResponse ;
            for(Subscriptions_to_Case_Association__c subCaseObj: lstSubIds)
            {
                subIdList.add(subCaseObj.csord_Subscription__r.Id);
                targetBillAccNum = subCaseObj.Billing_Account_Number__c;
                orderNum = subCaseObj.csord_Subscription__r.csord__Order__r.csord__Order_Number__c;
            }
            if(subIdList!= null && !subIdList.isEmpty())
            {
                calloutResponse =CoBABillHandler.processBillingCalloutCOBA(subIdList,targetBillAccNum,orderNum);
            }
            if(calloutResponse!=null)
            {
                statusCode = String.valueOf(calloutResponse.getStatusCode());
                responseBody = calloutResponse.getBody();
                isResBlank = false;
                BillingPostSubscriptionResponseDTO billingPostSubscriptionResponseJson;
                if(responseBody != null){
                    billingPostSubscriptionResponseJson = BillingPostSubscriptionResponseDTO.parse(responseBody);
                }
                if(statusCode.equals('202')){
                    CoBAResponseHandler.updateEventId(subIdList, billingPostSubscriptionResponseJson.eventId);
                }
                List<Id> subCaseObjIdLst = new List<Id>();
                for(Subscriptions_to_Case_Association__c subCaseObj :lstSubIds)
                {
                    if(statusCode.equals('202'))
                    {
                        subCaseObj.Status__c ='In Progress';
                        subCaseObj.Response_Code__c =billingPostSubscriptionResponseJson.code;
                        subCaseObj.Response_Message__c =billingPostSubscriptionResponseJson.message;
                    }
                    else if(!statusCode.equals('202'))
                    {
                        subCaseObj.Status__c ='In Error';
                        subCaseObj.Response_Code__c =billingPostSubscriptionResponseJson.code;
                        subCaseObj.Response_Message__c =billingPostSubscriptionResponseJson.message;
                        listFailedSubs.add(subCaseObj.Id);
                    } 
                    updateSubList.add(subCaseObj);
                }
                update updateSubList;
            }
        }
        catch(Exception e){
            CoBABillHandler.logException('execute', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Error in execute method');throw e;
        }
    }
    public void finish(Database.BatchableContext BC)
    { 
        try
        {
            case caseRec = [Select Id,Status from case where Id=: caseId];
            if(listFailedSubs.isEmpty() && !isResBlank && !caseRec.status.equalsIgnoreCase('In Progress'))
            {
                caseRec.status = 'In Progress'; 
            } 
            else
            {
                caseRec.status = 'In Error'; 
            }
            update caseRec;
        }
        catch(Exception e){
            CoBABillHandler.logException('finish', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Error in finish method');throw e;
        }
        
    }
}