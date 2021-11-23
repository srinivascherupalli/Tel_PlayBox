@isTest
public class ProcessMultipleRecipientNotifyTest {

@isTest
    static void testupdateEmailDeliveryStatusOpened(){
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
                
        String statusDescription='';
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        insert contact;
                       
        EmailDeliveryStatus__c Eds = new EmailDeliveryStatus__c();
        Eds.Status__c='OPENED';
        Eds.CorrelationId__c ='388fbcd7-138a-48d5-99e9-b321330bc43c';
        Eds.RecipientContact__c =contact.id;
        insert Eds;
       
        
       Test.startTest();
       ProcessMultipleRecipientNotify.updateEmailDeliveryStatus(Eds.CorrelationId__c,Eds.Status__c,statusDescription);
       Test.StopTest();
       List<EmailDeliveryStatus__c> em = [SELECT ID, status__c
                                 FROM EmailDeliveryStatus__c];
       System.assert(em != null);
       }
@isTest
    static void testupdateEmailDeliveryStatusUnDeliv(){    
    
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
              
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        insert contact;           
       
        String statusDescriptions=contact.email;
     
        EmailDeliveryStatus__c Edsstatus = new EmailDeliveryStatus__c();
        Edsstatus.Status__c='MESSAGE_UNDELIVERED';
        Edsstatus.CorrelationId__c ='388fbcd7-138a-48d5-99e9-b321330bc44c';
        Edsstatus.RecipientContact__c =contact.id;
        insert Edsstatus ;
        
        Test.startTest();
        ProcessMultipleRecipientNotify.updateEmailDeliveryStatus(Edsstatus.CorrelationId__c,Edsstatus.Status__c,statusDescriptions);
        Test.StopTest();
        List<EmailDeliveryStatus__c> em = [SELECT ID, status__c
                                 FROM EmailDeliveryStatus__c];
       System.assert(em != null);
       
       }
       }