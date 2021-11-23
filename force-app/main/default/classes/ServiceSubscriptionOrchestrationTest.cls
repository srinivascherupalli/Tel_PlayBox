@isTest
private class ServiceSubscriptionOrchestrationTest {

    static testMethod void processTest() {
         Account acc = new Account(Name='Test Account');
       
        csord__Order__c ord = ProductTestService.getNewOrderForAccount(acc);

        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
       
        parentOrchProcess.Order__c= ord.Id;
        system.debug('step'+parentOrchProcess);
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
    system.debug('step'+step);
        Test.startTest();
        List<SObject> result = ServiceSubscriptionOrchestrationHandler.process((List<SObject>)steps);
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertNotEquals(null,value.CSPOFA__Status__c);
        
        Test.stopTest(); 
    }
}