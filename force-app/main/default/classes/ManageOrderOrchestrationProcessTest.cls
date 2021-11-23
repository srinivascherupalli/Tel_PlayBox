@isTest
private class ManageOrderOrchestrationProcessTest {
    
    @isTest static void test_method_one() {
        Account acc = new Account(Name='Test Account');
        csord__Order__c ord = ProductTestService.getNewOrderForAccount(acc);
        list<CSPOFA__Orchestration_Process_Template__c> orcheList = new list<CSPOFA__Orchestration_Process_Template__c>();
       
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate0 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate0.Name = 'Order Fulfilment Process';
        orchProcessTemplate0.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate0.CSPOFA__Processing_Mode__c = 'Foreground';
        orcheList.add(orchProcessTemplate0);

        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name = 'Subscription Fulfilment Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
        orcheList.add(orchProcessTemplate);
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate1 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate1.Name = 'New User Service Fulfilment Process';
        orchProcessTemplate1.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate1.CSPOFA__Processing_Mode__c = 'Foreground';
        orcheList.add(orchProcessTemplate1);
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate2 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate2.Name = 'New BYO Mobile Service Fulfilment Process';
        orchProcessTemplate2.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate2.CSPOFA__Processing_Mode__c = 'Foreground';
        orcheList.add(orchProcessTemplate2);
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate3 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate3.Name = 'New Unmanaged Device Service Fulfilment Process';
        orchProcessTemplate3.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate3.CSPOFA__Processing_Mode__c = 'Foreground';
        orcheList.add(orchProcessTemplate3);
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate4 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate4.Name = 'New Managed Device Service Fulfilment Process';
        orchProcessTemplate4.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate4.CSPOFA__Processing_Mode__c = 'Foreground';
        orcheList.add(orchProcessTemplate4);
        insert orcheList;
        
        
        List<csord__Subscription__c> subscriptionList = [SELECT Id, Name, csord__Status__c, csordtelcoa__Replaced_Subscription__c, csord__Order__c, (SELECT Id, Name, csord__Status__c, csord__Order__c from csord__Services__r) from csord__Subscription__c WHERE csord__Order__c =: ord.Id];
        subscriptionList[0].Name = 'User Standard Zone 4';


        update subscriptionList;
        List<Id> orderIds = new List<Id>{ord.Id};

        ManageOrderOrchestrationProcessHandler.createOrderOrchestrationProcess(orderIds);

        List<CSPOFA__Orchestration_Process__c> orcProc = [SELECT Id, Name, CSPOFA__Orchestration_Process_Template__c, Order__c from CSPOFA__Orchestration_Process__c];


        System.assert(orcProc.size() > 0);
        System.assertEquals(orchProcessTemplate0.Id, orcProc[0].CSPOFA__Orchestration_Process_Template__c);
        System.assertEquals(ord.Id, orcProc[0].Order__c);
    }
    
    
}