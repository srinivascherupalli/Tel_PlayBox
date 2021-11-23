@isTest
public class DirectoryFalloutHandlerTest {
    static testMethod void processTest(){
         Account acc = new Account(Name='Test Account');
        
        csord__Order__c  ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Account__c = acc.id;
        ord.csord__Status2__c = 'Created';
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';       
        insert ord;
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name='Directory Fallout Handling Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
        insert orchProcessTemplate;
        
      
        CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
        orchProcess.Name = 'Test Orch Process';
        orchProcess.Order__c= ord.Id;
        orchProcess.has_Inactive_Children__c = 'NA';
        orchProcess.CSPOFA__Orchestration_Process_Template__c = orchProcessTemplate.Id;
        insert orchProcess;
        
        
    
        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = orchProcess.Id;
        
        
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
        
         Test.startTest();
        DirectoryFalloutHandler.FailedDirectoryListing dir = new DirectoryFalloutHandler.FailedDirectoryListing();
        dir.process(steps);
        
        DirectoryFalloutHandler.ResendFailedDirectoryListing resend = new DirectoryFalloutHandler.ResendFailedDirectoryListing();
        resend.process(steps);
        Test.stopTest(); 
      System.assertEquals('Test Orch Process',orchProcess.Name);
        
        
    }

}