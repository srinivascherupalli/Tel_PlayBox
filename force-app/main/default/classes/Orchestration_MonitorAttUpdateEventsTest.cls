@isTest
public class Orchestration_MonitorAttUpdateEventsTest {
    //Test Data Setup
    @Testsetup
    static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'Test_Account_Pre-Req';
        acc.Customer_Status__c = 'Active';
        insert acc;
        
        csord__Order__c  ord1 = new csord__Order__c();
        ord1.name = 'TestOrder_Pre-Req1';
        ord1.csord__Identification__c = 'Test1';
        ord1.csord__Account__c = acc.Id;
        ord1.csord__Status2__c = 'Started';
        ord1.stage__c = 'Being Fulfilled';
        ord1.csord__Start_Date__c = Date.today();    
        ord1.isTransientComplete__c = false;
		insert ord1;
       
        CSPOFA__Orchestration_Process_Template__c opt = new CSPOFA__Orchestration_Process_Template__c();
        opt.Name = 'Test Template';
        opt.CSPOFA__Process_Type__c = 'New Provide';
        opt.CSPOFA__Processing_Mode__c = 'Foreground';
        insert opt;

        List<CSPOFA__Orchestration_Process__c> orchList = new List<CSPOFA__Orchestration_Process__c>();
        CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
        orchProcess.Name = 'Test Orch Process Pre-Req';
        orchProcess.Order__c = ord1.id;
        orchProcess.has_Inactive_Children__c = 'NA';
        orchProcess.cspofa__account__c = acc.Id;
        orchProcess.CSPOFA__Orchestration_Process_Template__c = opt.id;
        orchList.add(orchProcess);
        
        CSPOFA__Orchestration_Process__c orchProcess1 = new CSPOFA__Orchestration_Process__c();
        orchProcess1.Name = 'Test Orch Process Pre-Req1';
        orchProcess1.has_Inactive_Children__c = 'NA';
        orchProcess1.cspofa__account__c = acc.Id;
        orchProcess1.CSPOFA__Orchestration_Process_Template__c = opt.id;
        orchList.add(orchProcess1);
        
        insert orchList;
        
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.name = 'Orch_step';
        step.CSPOFA__Orchestration_Process__c = orchList[0].Id;
        step.CSPOFA__Completed_Date__c = Date.Today();
        step.JSON__c = '[ "test1", "test2" ]';
        step.CSPOFA__Message__c = 'In Progress';
        orchStepList.add(step);
        
        CSPOFA__Orchestration_Step__c step1 = new CSPOFA__Orchestration_Step__c();
        step1.name = 'Orch_step1';
        step1.CSPOFA__Orchestration_Process__c = orchList[1].Id;
        step1.CSPOFA__Completed_Date__c = Date.Today();
        step1.JSON__c = '[ "test11", "test22" ]';
        step1.CSPOFA__Message__c = 'In Progress';
        orchStepList.add(step1);
        
        insert orchStepList;
        
        List<Orchestration_Technical__c> orchTechList = new List<Orchestration_Technical__c>();
        Orchestration_Technical__c orchTech = new Orchestration_Technical__c();
        orchTech.Field_19__c = ord1.id;
        orchTech.Field_3__c = 'Error';
        orchTech.Field_14__c = 'PreREQ';
		orchTechList.add(orchTech);
        Orchestration_Technical__c orchTech1 = new Orchestration_Technical__c();
        orchTech1.Field_19__c = ord1.id;
        orchTech1.Field_3__c = 'status';
        orchTech1.Field_14__c = 'PreREQ';
		orchTechList.add(orchTech1);
        Orchestration_Technical__c orchTech2 = new Orchestration_Technical__c();
        orchTech2.Field_19__c = ord1.id;
        orchTech2.Field_3__c = 'Started';
        orchTech2.Field_14__c = 'PreREQ';
		orchTechList.add(orchTech2);
        
        insert orchTechList;
    }
    
    @isTest
    static void processTest(){
        Test.startTest();
        List<CSPOFA__Orchestration_Step__c> step1 = [SELECT ID FROM CSPOFA__Orchestration_Step__c WHERE Name = 'Orch_step' OR Name = 'Orch_step1'];
        Orchestration_MonitorAttUpdateEvents orchMonitor = new Orchestration_MonitorAttUpdateEvents();
        List<SObject> res = orchMonitor.process(step1);
        Test.stopTest();
        System.assert(res.size() > 0);
    }
}