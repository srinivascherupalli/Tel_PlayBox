/**
 Class Name: CS_OrchUtils
 Description: Utility class for CS Orchestration Utility Methods
 TestClass: CS_OrchUtilsTest
  
==============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
  1.      RaviTeja           27/052/20      EDGE-146794 Optimization part of Scalability Backlog 
===============================================================================================================================


* */

public without sharing class CS_OrchUtils {
 private static map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = null; 

/*Method for returning Orchestration template map*/
 public static map<String, CSPOFA__Orchestration_Process_Template__c> getorchesTemplates() {
        if(orchesTemplates == null){
            orchesTemplates= new map<String, CSPOFA__Orchestration_Process_Template__c>();
          for(CSPOFA__Orchestration_Process_Template__c orctemp: [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c]){
            orchesTemplates.put(orctemp.Name, orctemp);
        }
        }
      return orchesTemplates;
    }
    
/*Method for returning Orchestration Process Instance*/
public static CSPOFA__Orchestration_Process__c createOchestrationProcess(String templateid,String OrderId,String SubscriptionId,String ServiceId){
        
        CSPOFA__Orchestration_Process__c orches;
        if(templateid!=null){
            orches  = new CSPOFA__Orchestration_Process__c();
            
            orches.CSPOFA__State__c = 'Active';
            if(OrderId!=null){
               orches.Order__c = orderId;}
            if(SubscriptionId!=null){
               orches.csordtelcoa__Subscription__c = SubscriptionId;}
            if(ServiceId!=null){
               orches.csordtelcoa__Service__c = ServiceId;}
            
            orches.CSPOFA__Orchestration_Process_Template__c =templateid;
        }
        
        return orches;
    }
    

}