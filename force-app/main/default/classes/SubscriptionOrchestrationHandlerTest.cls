@isTest
public class SubscriptionOrchestrationHandlerTest {
    
       @Testsetup static void dataSetup(){
        
            account acc=new account();
            acc.Name='Test Account';
            acc.Customer_Status__c='Active';
            insert acc;
            
            csord__Order__c ord = new csord__Order__c();
            ord.csord__Identification__c = 'test identification';
            ord.Name = 'test order';
            ord.csord__Status2__c = 'Pending';
            ord.csord__Account__c=acc.id;
            insert ord;
            
            csord__Order__c subord1 = new csord__Order__c();
            subord1.csord__Identification__c = 'test identification sub1';
            subord1.Name = 'sub order 1';
            subord1.csord__Primary_Order__c = ord.Id;
            subord1.csord__Status2__c = 'order created';
            insert subord1;
            
            csord__Order__c subord2 = new csord__Order__c();
            subord2.csord__Identification__c = 'test identification sub2';
            subord2.Name = 'sub order 2';
            subord2.csord__Primary_Order__c = ord.Id;
            subord2.csord__Status2__c = 'order created';
            insert subord2;
            
            csord__Subscription__c subs=new csord__Subscription__c();
            subs.name  = 'test subs';
            subs.csord__Identification__c = 'test identity';
            subs.csord__Status__c = 'Pending';
            subs.csord__Order__c = ord.id;
            subs.csord__Account__c=acc.id;
            insert subs;
            
          
            List<csord__Service__c> servs = new List<csord__Service__c>();
            csord__Service__c serv2 = new csord__Service__c();
            serv2.name ='tst service2';
            serv2.csord__Identification__c  = 'test identify2';
            serv2.csordtelcoa__Service_Number__c = '5';
            serv2.csord__Subscription__c = subs.Id;
            serv2.csord__Status__c = 'In Progress';
            servs.add(serv2);
            
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='tst service1';
            serv1.csord__Identification__c  = 'test identify1';
            serv1.csordtelcoa__Service_Number__c = '4';
            serv1.csord__Subscription__c = subs.Id;
            serv1.csord__Status__c = 'Failed';
            servs.add(serv1);
            
            csord__Service__c serv = new csord__Service__c();
            serv.name ='tst service';
            serv.csord__Identification__c  = 'test identify';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = subs.Id;
            serv.csord__Status__c = 'Cancellation In Progress';
            servs.add(serv);
            
            insert servs;
            
            csord__Subscription__c replacedsubs = new csord__Subscription__c();
            replacedsubs.name  = 'replaced test subs1';
            replacedsubs.csord__Identification__c = 'test identity';
            replacedsubs.csordtelcoa__Replaced_Subscription__c = subs.Id;
            insert replacedsubs;
            
            
            csord__Service__c replacedserv = new csord__Service__c();
            replacedserv.name ='replaced service1';
            replacedserv.csord__Identification__c  = 'test identify2';
            replacedserv.csordtelcoa__Service_Number__c = '5';
            replacedserv.csord__Subscription__c = replacedsubs.Id;
            replacedserv.csord__Status__c = 'In Progress';
            insert replacedserv;
  
    }
    	static testMethod void subscriptionProcessTest() {
       		CSPOFA__Orchestration_Process_Template__c parentTemplate = ProductTestService.getOrchProcessTemplate();
            CSPOFA__Orchestration_Process__c parentOrchProcess = ProductTestService.getNewOrchestrationProcess(parentTemplate);
            List<csord__Subscription__c> subs = [SELECT Id, Name, csord__Status__c from csord__Subscription__c WHERE Name='test subs'];
            parentOrchProcess.csordtelcoa__Subscription__c = subs[0].Id;
            update parentOrchProcess;
            system.debug('step'+parentOrchProcess);
            CSPOFA__Orchestration_Step__c step = ProductTestService.getOrchStep(parentOrchProcess);
            List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
            steps.add(step);
            system.debug('step'+step);
            Test.startTest();
            SubscriptionOrchestrationHandler.AccountStatusUpdate orderClass = new SubscriptionOrchestrationHandler.AccountStatusUpdate();
            List<SObject> result = orderClass.process((List<SObject>)steps);
            CSPOFA__Orchestration_Step__c value = (CSPOFA__Orchestration_Step__c)result[0];
            System.assertEquals(value.CSPOFA__Status__c,'Complete');
            Test.stopTest();
    }

}