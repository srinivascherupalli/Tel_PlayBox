/********************************************************
Class Name : ManageBillingSubsNotificationHelper
Test Class : ManageBillingSubsNotificationUtilTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Gnana                  15/04/2021      created as part of EDGE-205529
***************************************************************/

public with sharing class ManageBillingSubsNotificationHelper {
    public static Map<String,Subscriptions_to_Case_Association__c> subsNumberToAssocMap = new Map<String,Subscriptions_to_Case_Association__c>();
    public static List<String> listOfSubsNumbers = new List<String>();
    public static Set<Id> caseIdList = new Set<Id>();
    private static final String CONST_INTERFACENAME = 'ManageBillingSubsNotificationHelper';
    
    public static void processSubscriptionNotification(Map<String,List<NotificationParameters>> orderItemIdNotifMap, List<NotificationParameters> paramsList){
        System.debug('inside processSubscriptionNotification...'+paramsList);
        Map<String,Map<String,String>> subsIdToSubsDetailsMap = new Map<String,Map<String,String>>();
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        List<csord__Service__c> servList = new List<csord__Service__c>();
        List<Number__c> numbList = new List<Number__c>();
        List<Subscriptions_to_Case_Association__c> listOfSubsToCaseAssoc = new List<Subscriptions_to_Case_Association__c>();
        try{
            for(NotificationParameters notif :paramsList){
                List<ManageOrderNotificationUtil.SubsDetails> listOfSubsDetails = ManageOrderNotificationUtil.parseSubsDetails(notif.subscriptionDetails);
                System.debug('listOfSubsDetails...'+listOfSubsDetails);
                
                for(ManageOrderNotificationUtil.SubsDetails subsDetail: listOfSubsDetails){
                    Map<String,String> subsDetailsMap = new Map<String,String>();
                    listOfSubsNumbers.add(subsDetail.subscriptionId);
                    subsDetailsMap.put('responseCode',subsDetail.responseCode);
                    subsDetailsMap.put('responsesDescription',subsDetail.responsesDescription);
                    subsDetailsMap.put('subscriptionId',subsDetail.subscriptionId);
                    System.debug('subsDetailsMap..'+subsDetailsMap.values());
                    subsIdToSubsDetailsMap.put(subsDetail.subscriptionId,subsDetailsMap);
                }
                System.debug('subsIdToSubsDetailsMap...'+subsIdToSubsDetailsMap.values());
            }
            if(!listOfSubsNumbers.isEmpty()){
                subsList = [SELECT Id, Name,Sub_status__c,eventId__c,csord__Status__c,csordtelcoa__Subscription_Number__c,Suspension_reason__c,CreatedDate,toBeCancelled__c 
                            FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c IN:listOfSubsNumbers order by createdDate DESC ];
                System.debug('subsList...'+subsList);
                servList = [SELECT Id,Name,csord__Order__c,cssdm__solution_association__c,csordtelcoa__Product_Configuration__r.configGUID__c,csordtelcoa__Product_Configuration__c,Scenario_Type__c,csord__Service__c,toBeCancelled__c,csord__Subscription__r.eventId__c,Action_Type__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c  FROM csord__Service__c WHERE csord__Subscription__r.csordtelcoa__Subscription_Number__c IN:listOfSubsNumbers for update];
                System.debug('servList...'+servList);
                numbList=[Select id,name,Service_Number__c,Status__c,Subscription_number__c,Service_Id__c,Product_ID__c,toBeCancelled__c  From Number__c where Subscription_number__c IN:listOfSubsNumbers];
                System.debug('numbList...'+numbList);
                listOfSubsToCaseAssoc = [SELECT Id,Billing_Account_Number__c,csord_Subscription__c,csord_Subscription__r.csordtelcoa__Subscription_Number__c,Case__c,Status__c,Billing_Account__c FROM Subscriptions_to_Case_Association__c WHERE csord_Subscription__r.csordtelcoa__Subscription_Number__c IN:listOfSubsNumbers AND Status__c=:Label.In_Progress_Status]; 
                System.debug('listOfSubsToCaseAssoc...'+listOfSubsToCaseAssoc);
            }
            
            for(Subscriptions_to_Case_Association__c subsToCase : listOfSubsToCaseAssoc){
                subsNumberToAssocMap.put(subsToCase.csord_Subscription__r.csordtelcoa__Subscription_Number__c,subsToCase);
                caseIdList.add(subsToCase.Case__c);
            }
            
            if(!subsList.isEmpty()){
                ManageBillingSubsNotificationUtil.updateSubscription(subsList,subsIdToSubsDetailsMap,subsNumberToAssocMap);
            }
            
            if(!servList.isEmpty()){
                ManageBillingSubsNotificationUtil.updateService(servList,subsIdToSubsDetailsMap,subsNumberToAssocMap);
                ManageBillingSubsNotificationUtil.updatePCAttributes_Custom(servList,subsIdToSubsDetailsMap,subsNumberToAssocMap);
            }
            
            if(!numbList.isEmpty()){
                ManageBillingSubsNotificationUtil.updateNumber(numbList,subsIdToSubsDetailsMap,subsNumberToAssocMap);
            }
            
            if(!listOfSubsToCaseAssoc.isEmpty()){
                ManageBillingSubsNotificationUtil.updateSubsToCaseAssoc(listOfSubsToCaseAssoc,subsIdToSubsDetailsMap,subsNumberToAssocMap);
            }
            
            ManageBillingSubsNotificationUtil.updateCase(caseIdList,listOfSubsNumbers);
        } 
        catch(Exception e){
            logException('processSubscriptionNotification', '', '', e.getMessage(), 'Exception occured while processing Subscription Notification from BDS');
        }
    }
    
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