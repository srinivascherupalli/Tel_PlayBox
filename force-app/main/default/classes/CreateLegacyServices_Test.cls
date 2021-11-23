@isTest
public class CreateLegacyServices_Test {
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
		
		EnvironmentVariable__c setting = new EnvironmentVariable__c();
		setting.Name = 'engageSNRMFallout';
		setting.Value__c = 'FALSE';
        insert setting;
        
        Test.startTest();
        CreateLegacyServices objClsaa = new CreateLegacyServices();
        List<SObject> result = objClsaa.process((List<SObject>)steps);
        
        UpdateSpecificationAttachments objClsaa2 = new UpdateSpecificationAttachments();
        List<SObject> result2 = objClsaa2.process((List<SObject>)steps);
        
        OrderNextAvailableStatus objClsaa3 = new OrderNextAvailableStatus();
        List<SObject> result3 = objClsaa3.process((List<SObject>)steps);
        
        CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
        System.assertEquals(value.CSPOFA__Status__c,'Complete');
        
        Test.stopTest(); 
    }
}