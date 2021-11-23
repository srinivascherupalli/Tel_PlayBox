@isTest
public class EmailHandlerTest {
    
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
        
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        insert congaTemplate;
        
        
        
    }

    @isTest
    public static void executeWork_WillRunAndExecute_WhenTheParametersProvided() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testSuccess'));
            Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
            List<String> toList = new List<String>{'to@to.com'};
            List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
            List<String> bccList = new List<String>{'bcc@bcc.com'};
            List<id> attList = new List<Id>{att.id};
            
            APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        
           
          
            csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
            
            EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.id, 'Test Subject'
                                    , attList, 'MSISDN', '0412341235', 'SubmitOrder', '0412341234', sub.id, new Map<String, String>{'firstName'=>'test First Name'});
            Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            insRec.params__c = GUID;
          insRec.paramPayload__c = JSON.serialize(dto);
            insRec.handler__c = 'EmailHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            insert insRec;

            EmailHandler handler = new EmailHandler();
            handler.executeWork(new List<String>{insRec.params__c});
        Test.stopTest();

        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c
                                                       FROM Integration_Record__c
                                                       WHERE handler__c = 'EmailHandler'
                                                           AND id = :insRec.id];
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
        List<EmailMessage> ems = [SELECT id, Subject FROM EmailMessage WHERE FromAddress = :dto.fromEmail];
        System.assertEquals(1, ems.size());
        System.assertEquals('Test Subject', ems.get(0).Subject);
    }

}