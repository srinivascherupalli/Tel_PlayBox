@isTest
public class CancelSubscriptionOrcestratorUtilTest {
    
    @isTest
    static void processTest(){
        Account acc = new Account(Name='Test Account');
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc);
        Account parentAcc = new Account(Name='Test Account');
        csord__Subscription__c parentSub = ProductTestService.getNewSubscriptionForAccount(parentAcc);
        update parentSub;
        
        sub.Parent_Subscription__c = parentSub.Id;
        update sub;
        
        CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process_Template__c childTemplate = ProductTestService.getOrchProcessTemplate();
        CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
        CSPOFA__Orchestration_Process__c childOrchProcess1 = ProductTestService.getNewOrchestrationProcess(childTemplate);
        CSPOFA__Orchestration_Process__c childOrchProcess2 = ProductTestService.getNewOrchestrationProcess(childTemplate);
        childOrchProcess1.csordtelcoa__Subscription__c = parentSub.Id;
        childOrchProcess1.Parent_Orchestration_Process__c = parentOrchProcess.Id;
        childOrchProcess2.csordtelcoa__Subscription__c = sub.Id;
        childOrchProcess2.Parent_Orchestration_Process__c = parentOrchProcess.Id;
        update childOrchProcess1;
        update childOrchProcess2;
        CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);

        Test.startTest();
        CancelSubscriptionOrcestratorUtil.ActivateChildProcesses activateChildProcess = new CancelSubscriptionOrcestratorUtil.ActivateChildProcesses();
        List<SObject> result = activateChildProcess.process((List<SObject>)steps);
        Test.stopTest();
    }
    
}