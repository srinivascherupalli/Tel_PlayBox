/*
* @Author : Robin Chawla
* @Date : 20 May 2019
* @Desc : Handler class for Trigger class TramasElgibilityCallbackResponseTrigger
* @Jira : EDGE-84282 Notify Sales user when TM1 check has completed.
* @Test class:TramasEligibilityCallbackTriggerTest

*/
public with sharing class TramasElgibilityCallbackTriggerHandler {
    
    
    public void onBeforeInsert(List<TramasElgibilityCallbackResponse__c> newList)
    {
        
        
        
    }
    public void onAfterInsert(List<TramasElgibilityCallbackResponse__c> newList)
    {
        //START: Added by Sajal for DIGI-24043
        Set<Id> productConfigIdSet = new Set<Id>();
        Set<Id> newTmRespIdSet = new set<Id>();
        for(TramasElgibilityCallbackResponse__c tmResp: newList){
            productConfigIdSet.add(tmResp.Product_Configuration__c);
            newTmRespIdSet.add(tmResp.Id);
        }

        List<TramasElgibilityCallbackResponse__c> existingRespList = new List<TramasElgibilityCallbackResponse__c>();
        for(TramasElgibilityCallbackResponse__c tm: [SELECT Id, Eligibility_Criteria__c, Product_Configuration__c FROM TramasElgibilityCallbackResponse__c WHERE Product_Configuration__c IN :productConfigIdSet AND Id NOT IN :newTmRespIdSet]){
            TramasElgibilityCallbackResponse__c tmNew = new TramasElgibilityCallbackResponse__c();
            tmNew.Id = tm.Id;
            tmNew.Eligibility_Criteria__c = 'Reset';
            existingRespList.add(tmNew);
        }
        
        If(!existingRespList.isEmpty()){
            update existingRespList;
        }
        //END for DIGI-24043
        
    }
    
    public void onAfterUpdate( List<TramasElgibilityCallbackResponse__c> newList, List<TramasElgibilityCallbackResponse__c> oldCList, Map<ID, TramasElgibilityCallbackResponse__c> newMap , Map<ID, TramasElgibilityCallbackResponse__c> oldMap )
    {
        //send notification to opportunity owner
       new TramasEligibilityCallBackTriggerAction().sendNotification(newList,oldMap);
        
    }
    public void onBeforeUpdate( List<TramasElgibilityCallbackResponse__c> newList, List<TramasElgibilityCallbackResponse__c> oldList, Map<ID, TramasElgibilityCallbackResponse__c> newMap , Map<ID, TramasElgibilityCallbackResponse__c> oldMap )
    {
        
        
    }
    
    
    }