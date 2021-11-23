/**
 Class Name: CS_OrchUtilsTest
 Description: Test Class for Class: CS_OrchUtils
  
==============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
  1.      RaviTeja           27/052/20      EDGE-146794 Optimization part of Scalability Backlog 
===============================================================================================================================


* */


@isTest
private class CS_OrchUtilsTest {
 static testMethod void OrchUtilsTest() {
        Account acc = new Account(Name='Test Account',Account_Status__c='Active');
        csord__Order__c ord = ProductTestService.getNewOrderForAccount(acc);
        String ProcessingMode='Foreground';
       
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name = 'Service Fulfilment Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = ProcessingMode;
           
        insert orchProcessTemplate;
        
        list<csord__Service__c> serviceSubsList =  [SELECT Id, Name, csord__Status__c, Scenario_Type__c,csord__Order__c,csord__Subscription__c,
                                                    csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name,
                                                    csord__Subscription__r.toBeCancelled__c FROM csord__Service__c 
                                                    WHERE csord__Order__c =: ord.Id];
       
          map<String, CSPOFA__Orchestration_Process_Template__c> TemplateMap=CS_OrchUtils.getorchesTemplates();
          system.assert(TemplateMap.values().size()>0);
           
          CSPOFA__Orchestration_Process__c  orch=CS_OrchUtils.createOchestrationProcess(TemplateMap.get('Service Fulfilment Process').id,null,null,serviceSubsList[0].id);
          system.assertequals(orch.csordtelcoa__Service__c,serviceSubsList[0].id);
    }
}