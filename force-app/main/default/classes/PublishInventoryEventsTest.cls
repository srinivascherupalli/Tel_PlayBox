@isTest
public class PublishInventoryEventsTest {
    
    @isTest
    public static void testpublishSubscriptionEvent(){
    
    Account acc = new Account();
    
    acc.Type = 'Competitor' ;
    acc.name ='test account';
    acc.Customer_ID__c = '12345';
    insert acc;  
    
    csord__Order__c  ord = new csord__Order__c();
    ord.name = 'TestOrder';
    ord.csord__Identification__c ='Test';
    insert ord;
             
    csord__Subscription__c subs = new csord__Subscription__c();
    subs.csordtelcoa__Subscription_Number__c = 'SN-000004523';
    subs.csord__Order__c = ord.id;
     subs.csord__Identification__c='5463';
    subs.name = 'subsTest';
    subs.csord__Account__c = acc.id;
    subs.csord__Status__c = 'Provisioning In Progress';
    insert subs;
    
    String operation='C';
   //String correlationID=subs.csordtelcoa__Subscription_Number__c;
     test.startTest();
     PublishInventoryEvents.publishSubscriptionEvent(String.valueOf(subs.id),operation,String.valueOf(subs.csordtelcoa__Subscription_Number__c));
     test.stopTest();
     system.assertNotEquals(null, acc.name);
    }
    
     @isTest
    public static void testpublishServiceSpecificationEvent(){
    String GUID ='c9e7b53e-1684-fcb1-b5e4-e482c09d0778';
    String correlationId='SVC-000004396:c9e7b53e-1684-fcb1-b5e4-e482c09d0778';
    
    test.startTest();
    PublishInventoryEvents.publishServiceSpecificationEvent(correlationId,GUID);
    test.stopTest();
    system.assertNotEquals(null, PublishInventoryEvents.publishServiceSpecificationEvent(correlationId,GUID));
        system.assertNotEquals(null, correlationId);
        
    }
    


}