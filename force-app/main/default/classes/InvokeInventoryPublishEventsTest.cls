/*
===============================================================================================================================
Class : InvokeInventoryPublishEvents
Developer Name : Prajakta Patil
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.       Prajakta Patil      17/10/2018 
2.       Vaibhav Deshpande   02/04/2020    EDGE-139164 - Change Platform Event type to High Volume
3.      Prajakta patil       22/10/2020    EDGE-184831
===============================================================================================================================
*/

@isTest
public class InvokeInventoryPublishEventsTest {
       
    @Testsetup
    static void dataSetup(){
        Account acc = new Account();
        acc.name='test acc';
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.name = 'testorder' ;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.csord__Status__c = 'Active';
        insert subs;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='Unified Communication Enterprise';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csordtelcoa__Service_Number__c = 'SVC-000007567';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Order__c = ord.Id;
        insert serv;
    }
    
    @isTest
    static void testpublishSubscriptionEventHandler(){
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'testorder' limit 1][0];
        csord__Subscription__c Subscription = [SELECT Id, csord__Status__c, csordtelcoa__Subscription_Number__c, Name from csord__Subscription__c where Name = 'testSubscription' limit 1][0];
        
        //PublishSubscriptionChange__e subEvent= new PublishSubscriptionChange__e(); commented as part of EDGE-139164
        PublishSubscriptionChangeHV__e subEvent= new PublishSubscriptionChangeHV__e(); //added as part of EDGE-139164
        subEvent.Object_Name__c = 'Subscription';
        subEvent.Entity_ID__c = Subscription.Id;
        subEvent.Subscription_Number__c = Subscription.csordtelcoa__Subscription_Number__c;
        subEvent.Operation__c = 'C';
        subEvent.CorrelationID__c = Subscription.csordtelcoa__Subscription_Number__c;
            
        List<Database.SaveResult> saveRes =new List<Database.SaveResult>();
        String param=Subscription.Id+':::'+'C';
        List<String>Parameters = new List<String>();
        Parameters.add(param);
        
      test.startTest();
      InvokeInventoryPublishEvents.publishSubscriptionEventHandler(Parameters);
      test.stopTest();
      system.assertNotEquals(null, subEvent);
      
    }
    
    @isTest
    static void testpublishServiceSpecificationHandler(){
    csord__Order__c order = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'testorder' limit 1][0];
    csord__Service__c service = [SELECT id,name, csordtelcoa__Service_Number__c,csord__Order__c FROM csord__Service__c WHERE Name = 'Unified Communication Enterprise' limit 1];
    String Guid='c9e7b53e-1684-fcb1-b5e4-e482c09d0778';
        
    
        PublishServiceSpecificationChange__e specEvent =new PublishServiceSpecificationChange__e();
        specEvent.Object_Name__c = 'Specification';
        specEvent.Entity_ID__c =Guid;
        specEvent.Operation__c = 'U';
        specEvent.CorrelationID__c = service.csordtelcoa__Service_Number__c+Guid;
        
        List<Database.SaveResult> saveRes =new List<Database.SaveResult>();
        List<String> guidList = new List<String>();
        guidList.add('c9e7b53e-1684-fcb1-b5e4-e482c09d0778');
        guidList.add('k9e7b78h-4564-ytr1-c5y4-e385c08a0765');
        
        test.startTest();
        InvokeInventoryPublishEvents.publishServiceSpecificationHandler(order.Id,guidList);
        test.stopTest();
      system.assertNotEquals(null, specEvent);
    }
    
@isTest
    private static void  testpublishServiceSpecificationHandlerMSUpdate(){
    csord__Service__c service = [SELECT id,name, csordtelcoa__Service_Number__c,csord__Order__c FROM csord__Service__c WHERE Name = 'Unified Communication Enterprise' limit 1];
    String Guid='c9e7b53e-1684-fcb1-b5e4-e482c09d0778';
        
    
        Set<String> guidList = new Set<String>();
        guidList.add('c9e7b53e-1684-fcb1-b5e4-e482c09d0778');
        
        Map<String,Set<String>> servguidMap = new Map<String,Set<String>>();
        String servId = service.id;
        servguidMap.put(servId, guidList);
   
        
        test.startTest();
        InvokeInventoryPublishEvents.publishServiceSpecificationHandlerMSUpdate(servguidMap);
        test.stopTest();
      system.assertNotEquals(null, servguidMap);
    }   

}