@isTest
public class Orchestration_UpdateOrderDataTest {
    //Test Data Setup
    @Testsetup
    static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'Test_Account_Orch';
        acc.Customer_Status__c = 'Active';
        insert acc;
        
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000501234';
        billAcc.Account__c = acc.id;
        insert billAcc;
        
        csord__Order__c  ord1 = new csord__Order__c();
        ord1.name = 'TestOrder1';
        ord1.csord__Identification__c = 'Test1';
        ord1.csord__Account__c = acc.Id;
        ord1.csord__Status2__c = 'Started';
        ord1.stage__c = 'Being Fulfilled';
        ord1.csord__Start_Date__c = Date.today();    
        ord1.isTransientComplete__c = false;
        insert ord1;
        
        CSPOFA__Orchestration_Process_Template__c opt = new CSPOFA__Orchestration_Process_Template__c();
        opt.Name = 'Order Fulfilment Process_New';
        opt.CSPOFA__Process_Type__c = 'New Provide';
        opt.CSPOFA__Processing_Mode__c = 'Foreground';
        insert opt;
        
        csord__Subscription__c sub=new csord__Subscription__c();
        sub.name  = 'TestSubscription';
        sub.csord__Identification__c = 'test identity';
        sub.csord__Status__c = 'Pending';
        sub.csord__Order__c = ord1.id;
        sub.Billing_Account__c = billAcc.id;
        sub.csordtelcoa__Replaced_Subscription__c = NULL;
        sub.MarketableOffer__c = NULL;
        //sub.csordtelcoa__Product_Configuration__c=pconfig.id;
        insert sub; 
        
        csord__Service__c serv = new csord__Service__c();
        serv.name  = 'TestService';
        serv.Initial_Activation_Date__c = Date.valueOf('2018-12-30');
        serv.csord__Identification__c  = 'test identity';
        serv.csord__Subscription__c = sub.id;
        serv.Platform_Cache_Timestamp__c = System.now();
        serv.csord__Order__c = ord1.id;
        serv.csordtelcoa__Replaced_Service__c = NULL;
        insert serv;  
        
        CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
        orchProcess.Name = 'Test Orch Process1';
        orchProcess.Order__c = ord1.id;
        orchProcess.csordtelcoa__Subscription__c = sub.id;
        orchProcess.csordtelcoa__Service__c = serv.id;
        orchProcess.has_Inactive_Children__c = 'NA';
        orchProcess.cspofa__account__c = acc.Id;
        orchProcess.CSPOFA__Orchestration_Process_Template__c = opt.id;
        insert orchProcess;        
        
        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.name = 'Orch_step';
        step.CSPOFA__Orchestration_Process__c = orchProcess.Id;
        step.CSPOFA__Completed_Date__c = Date.Today();
        step.JSON__c = '[ "test1", "test2" ]';
        step.CSPOFA__Message__c = 'In Progress';
        insert step;     
    }
    
    @isTest
    static void processTest(){
        Test.startTest();
        csord__Order__c ordId = [SELECT ID FROM csord__Order__c WHERE name =: 'TestOrder1'];
        System.debug('###ordId'+ordId.ID);
        Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(ordId.Id,false);
        List<CSPOFA__Orchestration_Step__c> step1 = [SELECT ID, CSPOFA__Orchestration_Process__r.Order__c, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Step_Order__c, CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.cssdm__solution_association__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.legacy_subscription__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.legacy_subscription__r.cssdm__solution_association__c  FROM CSPOFA__Orchestration_Step__c where name =: 'Orch_step'];
        Orchestration_UpdateOrderData orchUpdate = new Orchestration_UpdateOrderData();
        List<SObject> res = orchUpdate.process(step1);
        Test.stopTest();
        System.assert(res.size() > 0);
    }
}