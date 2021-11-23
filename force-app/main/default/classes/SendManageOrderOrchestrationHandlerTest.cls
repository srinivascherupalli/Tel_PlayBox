@isTest
public class SendManageOrderOrchestrationHandlerTest {

    static testMethod void processTest(){
        Account acc = new Account(Name='Test Account');
       
        csord__Order__c ord = ProductTestService.getNewOrderForAccount(acc);

        csord__Subscription__c sub = [SELECT Id, Name from csord__Subscription__c];

       
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
       
        parentOrchProcess.Order__c= ord.Id;
        
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);

        Test.startTest();
        SendManageOrderOrchestrationHandler submitOrder = new SendManageOrderOrchestrationHandler();
        List<SObject> result = submitOrder.process((List<SObject>)steps);
        Test.stopTest();
 	System.assertEquals(result,submitOrder.process((List<SObject>)steps));
    }
    
    static testMethod void performCalloutsTest(){
        Account acc = new Account(Name='Test Account');
       
        csord__Order__c ord = ProductTestService.getNewOrderForAccount(acc);

        csord__Subscription__c sub = [SELECT Id, Name from csord__Subscription__c];

       
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
       
        parentOrchProcess.Order__c= ord.Id;
        
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);

        Test.startTest();
        SendManageOrderOrchestrationHandler submitOrder = new SendManageOrderOrchestrationHandler();
        Boolean result = submitOrder.performCallouts((List<SObject>)steps);
        Test.stopTest();

 	System.assertEquals(True,result);
    }
    
}