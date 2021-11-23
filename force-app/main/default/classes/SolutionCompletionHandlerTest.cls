/********************************************************
Class Name      :   SolutionCompletionHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.			   Prajakta Patil        22/10/19      	EDGE-81140
**********************************************************
*/

@isTest
public class SolutionCompletionHandlerTest {

    @testsetup 
    public static void dataSetup(){
        Account acc = new Account(Name='Test Account');

        csord__Order__c  ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Account__c = acc.id;
        ord.csord__Status2__c = 'Created';
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';  
        insert ord;
                
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.name = 'TestOrder';
        subs.csord__Account__c = acc.id;
        subs.csord__Order__c = ord.id;
        subs.csord__Identification__c = 'IDE1322';
        insert subs;
        
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name='Subscription Fulfillment Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
        insert orchProcessTemplate;
        
      
        CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
        orchProcess.Name = 'Test Orch Process';
        orchProcess.csordtelcoa__Subscription__c= subs.Id;
        orchProcess.has_Inactive_Children__c = 'NA';
        orchProcess.CSPOFA__Orchestration_Process_Template__c = orchProcessTemplate.Id;
        insert orchProcess;
        
    }
           
    @isTest static void processTest(){
         
        List<CSPOFA__Orchestration_Process__c> orchProcess = [Select id,Name from CSPOFA__Orchestration_Process__c where name ='Test Orch Process'];
        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = orchProcess[0].Id;
           
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
              
        Test.startTest();
        SolutionCompletionHandler sol = new SolutionCompletionHandler();
        List<SObject> result1 = sol.process((List<SObject>)steps);
        Boolean result = sol .performCallouts((List<SObject>)steps);
        Test.stopTest();
        System.assertEquals(result1,sol.process((List<SObject>)steps));
        System.assertEquals(True,result);
    }
    
}