@isTest
public class EmailDeliveryStatusControllerTest {

@isTest
    static void testupdateEmailDeliveryStatusOpened(){
    
         
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        EmailDeliveryStatus__c  deliverstatus = new EmailDeliveryStatus__c();
        deliverstatus.Order__c=ord.id;
        
        Test.startTest();
        EmailDeliveryStatusController.getEmailMessage(ord.id);
        Test.StopTest();
        List<EmailDeliveryStatus__c> em = [SELECT ID, status__c
                                 FROM EmailDeliveryStatus__c];
       System.assert(em != null);
       }
       }