/***********************************************************
Class Name      :   EmailTransformerTest
==========================================================
Change.No.    Developer Name          Date          Story Description
1.            Vishal Arbune         25/09/2020      EDGE-169633 : Use NOTIFY to send an FYI email with Order form to the customer
***********************************************************/
@isTest
public class EmailTransformerTest {
    
     @Testsetup
    static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        insert site;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        subs.csord__Order_Request__c = ordReq.Id;
        subs.Site__c = site.Id;
        insert subs;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        insert contact;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='IP Site';
        serv.Primary_Contact__c = contact.id;
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        insert serv;
        
        APXTConga4__Conga_Email_Template__c congaTemplate = new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        insert congaTemplate;
    }
    
    @isTest
    private static void fromEmailDToToEmailRequest_WillReturnRequest() {
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
            List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
                List<String> bccList = new List<String>{'bcc@bcc.com'};
                    List<id> attList = new List<Id>{att.id};
                        
                        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        
        
        
        csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.id, 'Test Subject'
                                    , attList, 'MSISDN', '0412341235', 'SubmitOrder', '0412341234', sub.id, new Map<String, String>{'firstName'=>'test First Name'});
        
        EmailRequest req = EmailTransformer.fromEmailDToToEmailRequest(dto);
        // System.assertEquals('0412341234', req.Recipient.msisdn);
        //  System.assertEquals('to@to.com', req.Recipient.emailAddress);
        //  System.assertEquals('to@to.com', req.Recipient.emailAddress);
        //  System.assertEquals(3, req.contentParameters.size());
        System.assertEquals('email_subject', req.contentParameters.get(0).name);
        System.assertEquals('Test Subject', req.contentParameters.get(0).value);
        System.assertEquals(1, req.attachmentParameters.size());
        System.assertEquals('Test File', req.attachmentParameters.get(0).filename);
        System.assertEquals('text/html', req.attachmentParameters.get(0).contentType);
        System.assertEquals('0412341235', req.entityId);
        System.assertEquals('MSISDN', req.entityType);
        //EDGE-169633 : Use NOTIFY to send an FYI email with Order form to the customer
        System.assertEquals('SubmitOrder', req.notificationEventType);
        
    }
    
    //EDGE-169633 : Use NOTIFY to send an FYI email with Order form to the customer
    @isTest
    private static void fromEmailDToToEmailRequest_WillReturnRequestTest() {
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
            List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
                List<String> bccList = new List<String>{};
                    List<id> attList = new List<Id>{att.id};                        
                       
        csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, '', 'Test Subject'
                                    , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'B2B_P2O_MAC_ORDER_RECEIVED', '0412341234', sub.id, new Map<String, String>{'firstName'=>'test First Name'});
        
        EmailRequest req = EmailTransformer.fromEmailDToToEmailRequest(dto);
        System.assertEquals('B2B_P2O_MAC_ORDER_RECEIVED', req.notificationEventType);        
        System.assertEquals(1, req.attachmentParameters.size());
        System.assertEquals('Test File', req.attachmentParameters.get(0).filename);
        System.assertEquals('text/html', req.attachmentParameters.get(0).contentType);
        
        System.assertNotEquals('Test', req.notificationEventType);
    }
}