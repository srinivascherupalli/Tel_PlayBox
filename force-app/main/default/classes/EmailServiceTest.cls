/********************************************************
Class Name      :   EmailServiceTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Pratyush Mishra       11/21/19        EDGE-113536 Header Map changes, added Correlation-Id as order Number
2.            Vishal Arbune         25/09/2020      EDGE-169633 : Use NOTIFY to send an FYI email with Order form to the customer
3.            Vishal Arbune         31/12/2020      EDGE-195678 Ensure TM2 call is triggered for MACD Order post Contract Accepted
**********************************************************
*/

@isTest
public class EmailServiceTest {
    
    @Testsetup
    static void dataSetup(){
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User user= new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
        insert user;
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c = 'ACTIVE';
        acc.Account_Status__c = 'Active';
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
        subs.Site__c = site.Id;
        subs.csord__Order_Request__c = ordReq.Id;
        insert subs;
        
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        insert congaTemplate;
        
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
        
         //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp;
        
        //Create Basket
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        lstbasket.add(basket);
        insert lstbasket;
        
        List<ContractJunction__c> cjList = new List<ContractJunction__c>();        
        ContractJunction__c CJ=new ContractJunction__c();
        CJ.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        CJ.Related_Basket__c = basket.id;
        CJ.DocuSign_Signer_3__c = user.Id;
        CJ.name='testCJ';
        CJ.account__c=acc.id;
        CJ.Related_Opportunity__c = basket.cscfga__Opportunity__c;        
        CJ.Customer_Primary_Contact__c = contact.id;        
                    
        cjList.add(CJ);       
        insert cjList;
        
        List<EmailMessage> emailMessage = new List<EmailMessage> ();  
		EmailMessage message = new EmailMessage();
		message.Correlation_ID__c = 'c146de41-5d94-4987-89c4-61c7b0f42d75'; 
		message.Subject='Your Telstra order request';
		emailMessage.add(message);
		insert emailMessage;
    }
    
    public static Integration_Record__c insertRecordBefore(EmailDTO dto){
        Integration_Record__c insertRecord = new Integration_Record__c();
        blob b = Crypto.generateAesKey(128);
        String GUID = EncodingUtil.convertToHex(b);
        insertRecord.params__c =GUID;
        insertRecord.paramPayload__c = JSON.serialize(dto);
        insertRecord.handler__c = 'EmailHandler';
        insertRecord.status__c = IntegrationQueueHandler.PENDING;
        insert insertRecord;
        return insertRecord;
    }
    
    /* @isTest public static void send_WillCreateIntegrationRequest_WhenAllRequiredDataIsThere() {
Test.startTest();
Test.setMock(HttpCalloutMock.class, new SendEmailMockResponse());
EmailService service= new EmailService();
Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
List<String> toList = new List<String>{'to@to.com'};
List<id> attList = new List<Id>{att.id};

APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];



csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];

EmailDTO dto = new EmailDTO('from@from.com', toList, congaTemplate.id, 'Test Subject'
, attList, 'MSISDN', '0412341235', 'SubmitOrder', '0412341234', sub.id, new Map<String, String>{'firstName'=>'test First Name'});


Integration_Record__c insertRecord = insertRecordBefore(dto);
Integration_Record__c itr= new Integration_Record__c();
itr.handler__c = 'EmailHandler';
itr.params__c =sub.id+':'+'to@to.com';
insert itr;

EmailHandler handler = new EmailHandler();
handler.executeWork(new List<String>{itr.params__c});
service.send(dto);
Test.stopTest();

List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c
FROM Integration_Record__c
WHERE handler__c = 'EmailHandler' AND id = :insertRecord.id];
System.assertEquals(1, existingRequests.size());
System.assertEquals(JSON.serialize(dto), existingRequests.get(0).paramPayload__c);
}*/
    //EDGE-143011
    @isTest
    public static void sendEmail_WillSendEmail_WhenAllRequiredDataToMailSend() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendOrderFormEmailMockResponse('testSuccess_OFEmail'));
        EmailService service= new EmailService();
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{'bcc@bcc.com'};
        List<id> attList = new List<Id>{att.id};
                        
        csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
		Contact con = [Select Email from Contact where FirstName = 'Reena' Limit 1];
		EmailMessage emailMessage = [Select Correlation_ID__c from EmailMessage where Subject='Your Telstra order request' Limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList,'', 'Test Subject'
                                    , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'B2B_P2O_MAC_ORDER_RECEIVED', '0412341234', sub.id, new Map<String, String>{'firstName'=>'test First Name'});
        Integration_Record__c insertRecord = insertRecordBefore(dto);
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'EmailHandler';
        itr.params__c =sub.id+':'+'to@to.com';
        insert itr;
        service.send(dto);
		         
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c
                                                        FROM Integration_Record__c
                                                        WHERE handler__c = 'EmailHandler' AND id = :insertRecord.id];
        
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(JSON.serialize(dto), existingRequests.get(0).paramPayload__c);
        EmailService.sendEmail(existingRequests.get(0).params__c);
		EmailService.ProcessEmailDeliveryRecord(con.Email, emailMessage.Correlation_ID__c, sub.id);
		
        Test.stopTest();
        EmailMessage em = [SELECT ID, status__c FROM EmailMessage WHERE Subject='Your Telstra order request' LIMIT 1];
        System.assert(em != null);       
    }
    
    @isTest
    public static void sendEmail_WillSendEmail_WhenAllRequiredDataIsThere() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendEmailMockResponse());
        EmailService service= new EmailService();
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
            List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
                List<String> bccList = new List<String>{'bcc@bcc.com'};
                    List<id> attList = new List<Id>{att.id};
                        
                        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        
        csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
        Contact con = [Select Email from Contact where FirstName = 'Reena' Limit 1];
		EmailMessage emailMessage = [Select Correlation_ID__c from EmailMessage where Subject='Your Telstra order request' Limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList,congaTemplate.id, 'Test Subject'
                                    , attList, 'MSISDN', '0412341235', 'SubmitOrder', '0412341234', sub.id, new Map<String, String>{'firstName'=>'test First Name'});
        Integration_Record__c insertRecord = insertRecordBefore(dto);
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'EmailHandler';
        itr.params__c =sub.id+':'+'to@to.com';
        insert itr;
        // handler.executeWork(new List<String>{insertRecord.params__c});
        service.send(dto);
        //service.send(dto,'New');
         
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c
                                                        FROM Integration_Record__c
                                                        WHERE handler__c = 'EmailHandler' AND id = :insertRecord.id];
        
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(JSON.serialize(dto), existingRequests.get(0).paramPayload__c);
        EmailService.sendEmail(existingRequests.get(0).params__c);
        EmailService.ProcessEmailDeliveryRecord(con.Email, emailMessage.Correlation_ID__c, sub.id);
        Test.stopTest();
        EmailMessage em = [SELECT ID, status__c FROM EmailMessage WHERE Subject='Your Telstra order request' LIMIT 1];
        System.assert(em != null);
        //System.assertEquals(EmailService.IN_PROGRESS, em.status__c);
    }
    
    @isTest
    public static void sendEmail_WillSendEmailWithOrderId_WhenAllRequiredDataIsThere() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendEmailMockResponse());
        EmailService service= new EmailService();
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
            List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
                List<String> bccList = new List<String>{'bcc@bcc.com'};
                    List<id> attList = new List<Id>{att.id};
                        
                        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        
        
        
        csord__Order__c ord = [SELECT Id, Name from csord__Order__c where Name = 'TestOrder' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList,congaTemplate.id, 'Test Subject'
                                    , attList, 'MSISDN', '0412341235', 'SubmitOrder', '0412341234', ord.id, new Map<String, String>{'firstName'=>'test First Name'});
        Integration_Record__c insertRecord = insertRecordBefore(dto);
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'EmailHandler';
        itr.params__c =ord.id+':'+'to@to.com';
        insert itr;
        // handler.executeWork(new List<String>{insertRecord.params__c});
        service.send(dto);
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c
                                                        FROM Integration_Record__c
                                                        WHERE handler__c = 'EmailHandler' AND id = :insertRecord.id];
        
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(JSON.serialize(dto), existingRequests.get(0).paramPayload__c);
        EmailService.sendEmail(existingRequests.get(0).params__c);
        Test.stopTest();
        EmailMessage em = [SELECT ID, status__c FROM EmailMessage WHERE Subject='Your Telstra order request' LIMIT 1];
        System.assert(em != null);
        //System.assertEquals(EmailService.IN_PROGRESS, em.status__c);
    }
    
    @isTest
    public static void sendEmail_WillSendEmailWithNoOrderId_WhenAllRequiredDataIsThere() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SendEmailMockResponse());
        EmailService service= new EmailService();
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
            List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
                List<String> bccList = new List<String>{'bcc@bcc.com'};
                    List<id> attList = new List<Id>{att.id};
                        
                        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        
        
        
        csord__Order__c ord = [SELECT Id, Name from csord__Order__c where Name = 'TestOrder' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList,congaTemplate.id, 'Test Subject'
                                    , attList, 'MSISDN', '0412341235', 'SubmitOrder', '0412341234', ord.id, new Map<String, String>{'firstName'=>'test First Name'});
        Integration_Record__c insertRecord = insertRecordBefore(dto);
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'EmailHandler';
        itr.params__c =':'+'to@to.com';
        insert itr;
        // handler.executeWork(new List<String>{insertRecord.params__c});
        service.send(dto);
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c
                                                        FROM Integration_Record__c
                                                        WHERE handler__c = 'EmailHandler' AND id = :insertRecord.id];
        
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(JSON.serialize(dto), existingRequests.get(0).paramPayload__c);
        EmailService.sendEmail(existingRequests.get(0).params__c);
        Test.stopTest();
        EmailMessage em = [SELECT ID, status__c FROM EmailMessage WHERE Subject='Your Telstra order request' LIMIT 1];
        System.assert(em != null);
        //System.assertEquals(EmailService.IN_PROGRESS, em.status__c);
    }
    
    
    
    @isTest
    public static void sendEmail_WillNotSendEmail_WhenAllRequiredDataIsNotThere()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailErrorMockResponseGenerator());
        EmailService service= new EmailService();
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
            List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
                List<String> bccList = new List<String>{'bcc@bcc.com'};
                    List<id> attList = new List<Id>{att.id};
                        
                        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        
        csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.id, 'Test Subject'
                                    , attList, System.Label.Billing_Enquiry_Event_Type_Resolved, '0412341235', 'SubmitOrder', '0412341234', sub.id, new Map<String, String>{'firstName'=>'test First Name'});
        insertRecordBefore(dto);
        
        Integration_Record__c itr= new Integration_Record__c();
        itr.handler__c = 'EmailHandler';
        itr.params__c =sub.id+':'+'to@to.com';
        insert itr; 
        service.send(dto);
        service.send(dto,'Resolved');
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, paramPayload__c
                                                        FROM Integration_Record__c
                                                        WHERE Handler__c = 'EmailHandler'];
        
        System.assertNotEquals(0, existingRequests.size());
        System.assertEquals(JSON.serialize(dto), existingRequests.get(0).paramPayload__c);
        EmailService.sendEmail(existingRequests.get(0).params__c);
        Test.stopTest();
        List<EmailMessage> em = [SELECT ID, status__c
                                 FROM EmailMessage];
        System.assert(em != null);
    }
}