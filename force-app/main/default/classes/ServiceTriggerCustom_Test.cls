@isTest
public class ServiceTriggerCustom_Test {
    @isTest static void testMethod2() {
        Account acc= new Account();
        acc.Name = 'TestAccount';
        insert acc;        
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;
        
         List<csord__Service__c> servs = new List<csord__Service__c>();
    csord__Service__c serv = new csord__Service__c();
        serv.name ='IP Network';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csordtelcoa__Service_Number__c = '7';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.substage__c = 'Product Activation and Testing';
        serv.stage__c = 'Being Fulfilled';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        servs.add(serv);
    
    csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='User ---- Fixed Seat';
        serv2.Model__c = 'User ---- Fixed Seat';
        serv2.csord__Identification__c  = 'testIdentify_2';
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.csord__Subscription__c = subs.Id;
        serv2.csord__Status__c = 'Service Created';
        serv2.substage__c = 'Product Activation and Testing';
        serv2.stage__c = 'Being Fulfilled';
        serv2.csord__Order_Request__c = ordReq.Id;
        serv2.csord__Order__c = ord.Id;
        servs.add(serv2);
        insert servs;
        system.assert(!servs.isEmpty());
        
    }
}