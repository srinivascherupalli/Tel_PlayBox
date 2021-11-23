@IsTest
public class CISEmailServiceTest {
    @Testsetup
    static void dataSetup(){
       //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.YTD_Total_Revenue__c=15000;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0423456789',
            Email = 'test@tele2.com'   
        );
        insert contact;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp;
        
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate.APXTConga4__Name__c='CISEmailHandler';
        insert congaTemplate;
        
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Send_CIS_for_Contract';
        ev.Value__c='True';
        insert ev;
         EnvironmentVariable__c enVar= new EnvironmentVariable__c();
        enVar.name='Send_OrderForm_for_Contract';
        enVar.Value__c='True';
        insert enVar;
        List<ContractJunction__c> cjList = new List<ContractJunction__c>();
        
        ContractJunction__c CJ=new ContractJunction__c();
        CJ.name='testCJ';
        CJ.account__c=acc.id;
        CJ.Related_Opportunity__c = opp.id;
        CJ.isCISGenerated__c=false;
        CJ.CIS_Dispatched_Offers__c ='Connected Workplace;MDM Offer;IoT Connectivity';
        CJ.Customer_Primary_Contact__c = contact.id;
        
        ContractJunction__c CJ1=new ContractJunction__c();
        CJ1.name='testCJ1';
        CJ1.account__c=acc.id;
        CJ1.Related_Opportunity__c = opp.id;
        CJ1.isCISGenerated__c=false;
        CJ1.CIS_Dispatched_Offers__c ='MDM Offer';
        CJ1.Customer_Primary_Contact__c = contact.id;
        
        ContractJunction__c CJ2=new ContractJunction__c();
        CJ2.name='testCJ2';
        CJ2.account__c=acc.id;
        CJ2.Related_Opportunity__c = opp.id;
        CJ2.isCISGenerated__c=false;
        CJ2.CIS_Dispatched_Offers__c ='Connected Workplace';
        CJ2.Customer_Primary_Contact__c = contact.id;
        
        //Added for DPG-753
         ContractJunction__c CJ3=new ContractJunction__c();
        CJ3.name='testCJ3';
        CJ3.account__c=acc.id;
        CJ3.Related_Opportunity__c = opp.id;
        CJ3.isCISGenerated__c=false;
        CJ3.CIS_Dispatched_Offers__c =Label.IoTOfferName;
        CJ3.Customer_Primary_Contact__c = contact.id;
        

        ContractJunction__c CJ4 = new ContractJunction__c();
        CJ4.name='testCJ3';
        CJ4.account__c=acc.id;
        CJ4.Related_Opportunity__c = opp.id;
        CJ4.isCISGenerated__c=false;
        CJ4.CIS_Dispatched_Offers__c ='Adaptive Collaboration'; //DIGI-3352 B2B-1762 - Offer Name Change
        CJ4.Customer_Primary_Contact__c = contact.id;
        
        ContractJunction__c CJ5 = new ContractJunction__c();
        CJ5.name='testCJ5';
        CJ5.account__c=acc.id;
        CJ5.Related_Opportunity__c = opp.id;
        CJ5.isCISGenerated__c=false;
        CJ5.CIS_Dispatched_Offers__c ='Telstra Internet Direct';
        CJ5.Customer_Primary_Contact__c = contact.id;
            
        cjList.add(CJ);
        cjList.add(CJ1);
        cjList.add(CJ2);
        cjList.add(CJ3);
        cjList.add(CJ4);
        cjList.add(CJ5);
        insert cjList;
        System.assertNotEquals(cjList.size(), 0);
    
    }
    
    @isTest
    public static void processCISMailTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testSuccess_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{'bcc@bcc.com'};
        List<id> attList = new List<Id>{att.id};
        
        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        ContractJunction__c CJ = [Select account__c,isCISGenerated__c,CIS_Dispatched_Offers__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ' limit 1];
         ContractJunction__c CJ1 = [Select account__c,isCISGenerated__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ1' limit 1];
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.APXTConga4__Name__c, 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'EDGESF_ORDER_2', '', CJ.id, null);
            Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            insRec.params__c = GUID;
            insRec.paramPayload__c = JSON.serialize(dto);
            insRec.handler__c = 'CISEmailHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            insert insRec;
            Boolean isLinkvalue=CISEmailService.isCSILinkedToAccountWithOffers(CJ.account__c,'check',CJ.CIS_Dispatched_Offers__c);//INC000092359622 --Changes
         
            CISEmailService.processCISMail(new List<String>{CJ.Id});
            CISEmailService.sendEmail(CJ.Id+':test@tele2.com');
            Test.stopTest();

            List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'CISEmailHandler' AND id = :insRec.id];
            system.assertEquals(false,isLinkvalue);//INC000092359622 --Changes
            System.assertEquals(1, existingRequests.size());
            System.assertEquals(1, existingRequests.size());
            System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
            List<EmailMessage> ems = [SELECT id, Subject FROM EmailMessage];
            System.assertEquals(1, ems.size());
            System.debug('ems'+ems);
            System.assertEquals('Your Critical Information Summary', ems.get(0).Subject);
    }
    
    @isTest
    public static void processCISMailTestFailure() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testFail_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{'bcc@bcc.com'};
        List<id> attList = new List<Id>{att.id};
        
        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        ContractJunction__c CJ = [Select account__c,isCISGenerated__c,CIS_Dispatched_Offers__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ' limit 1];
         ContractJunction__c CJ1 = [Select account__c,isCISGenerated__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ1' limit 1];
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.APXTConga4__Name__c, 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'EDGESF_ORDER_2', '', CJ.id, null);
        Boolean isLinkvalue=CISEmailService.isCSILinkedToAccountWithOffers(CJ.account__c,'check',CJ.CIS_Dispatched_Offers__c);//INC000092359622 --Changes
            Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            insRec.params__c = GUID;
            insRec.paramPayload__c = JSON.serialize(dto);
            insRec.handler__c = 'CISEmailHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            insert insRec;

         
            CISEmailService.processCISMail(new List<String>{CJ.Id});
            CISEmailService.sendEmail(CJ.Id+':test@tele2.com');
            Test.stopTest();

            List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'CISEmailHandler' AND id = :insRec.id];
            System.assertEquals(1, existingRequests.size());
            system.assertEquals(false,isLinkvalue);//INC000092359622 --Changes
            //System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
            List<EmailMessage> ems = [SELECT id, Subject FROM EmailMessage];
            System.assertEquals(1, ems.size());
            System.debug('ems'+ems);
            System.assertEquals('Your Critical Information Summary', ems.get(0).Subject);
    }
      @isTest
    public static void processCISMailMDMTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testSuccess_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{'bcc@bcc.com'};
        List<id> attList = new List<Id>{att.id};
        
        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
       ContractJunction__c CJ1 = [Select account__c,isCISGenerated__c,CIS_Dispatched_Offers__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ1' limit 1];
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.APXTConga4__Name__c, 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'EDGESF_ORDER_2', '', CJ1.id, null);
            Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            insRec.params__c = GUID;
            insRec.paramPayload__c = JSON.serialize(dto);
            insRec.handler__c = 'CISEmailHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            insert insRec;
        Boolean isLinkvalue=CISEmailService.isCSILinkedToAccountWithOffers(CJ1.account__c,'check',CJ1.CIS_Dispatched_Offers__c);//INC000092359622 --Changes
         
            CISEmailService.processCISMail(new List<String>{CJ1.Id});
            CISEmailService.sendEmail(CJ1.Id+':test@tele2.com');
            Test.stopTest();

            List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'CISEmailHandler' AND id = :insRec.id];
            System.assertEquals(1, existingRequests.size());
            System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
            List<EmailMessage> ems = [SELECT id, Subject FROM EmailMessage];
            System.assertEquals(1, ems.size());
            system.assertEquals(false,isLinkvalue);//INC000092359622 --Changes
            System.debug('ems'+ems);
            System.assertEquals('Your Critical Information Summary', ems.get(0).Subject);
    }
    //EDGE-117742 Start
    @isTest
    public static void processCISMailTIDTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testSuccess_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{'bcc@bcc.com'};
        List<id> attList = new List<Id>{att.id};
        
        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
       ContractJunction__c CJ1 = [Select account__c,isCISGenerated__c,Customer_Primary_Contact__c,CIS_Dispatched_Offers__c from  ContractJunction__c where name ='testCJ5' limit 1];
       Boolean isLinkvalue=CISEmailService.isCSILinkedToAccountWithOffers(CJ1.account__c,'check',CJ1.CIS_Dispatched_Offers__c);//INC000092359622 --Changes
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.APXTConga4__Name__c, 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'EDGESF_ORDER_2', '', CJ1.id, null);
            Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            insRec.params__c = GUID;
            insRec.paramPayload__c = JSON.serialize(dto);
            insRec.handler__c = 'CISEmailHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            insert insRec;

         
            CISEmailService.processCISMail(new List<String>{CJ1.Id});
            CISEmailService.sendEmail(CJ1.Id+':test@tele2.com');
            Test.stopTest();

            List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'CISEmailHandler' AND id = :insRec.id];
            System.assertEquals(1, existingRequests.size());
            System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
            List<EmailMessage> ems = [SELECT id, Subject FROM EmailMessage];
            system.assertEquals(CJ1.CIS_Dispatched_Offers__c ,'Telstra Internet Direct');
            System.assertEquals(1, ems.size());
            System.debug('ems'+ems);
            system.assertEquals(false,isLinkvalue);//INC000092359622 --Changes
            System.assertEquals('Your Critical Information Summary', ems.get(0).Subject);
    }
    
    @isTest
    public static void processCISMailTIDTestFailure() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testFail_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{'bcc@bcc.com'};
        List<id> attList = new List<Id>{att.id};
        
        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        ContractJunction__c CJ = [Select account__c,isCISGenerated__c,Customer_Primary_Contact__c,CIS_Dispatched_Offers__c from  ContractJunction__c where name ='testCJ5' limit 1];
        Boolean isLinkvalue=CISEmailService.isCSILinkedToAccountWithOffers(CJ.account__c,'check',CJ.CIS_Dispatched_Offers__c);//INC000092359622 --Changes
         ContractJunction__c CJ1 = [Select account__c,isCISGenerated__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ1' limit 1];
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, congaTemplate.APXTConga4__Name__c, 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'EDGESF_ORDER_2', '', CJ.id, null);
            Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            insRec.params__c = GUID;
            insRec.paramPayload__c = JSON.serialize(dto);
            insRec.handler__c = 'CISEmailHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            //insert insRec;

         
            CISEmailService.processCISMail(new List<String>{CJ.Id});
            CISEmailService.sendEmail(CJ.Id+':test@tele2.com');
            Test.stopTest();

            List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'CISEmailHandler' AND id = :insRec.id];
            System.assertEquals(0, existingRequests.size());
            system.assertEquals(false,isLinkvalue);//INC000092359622 --Changes
            //System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
            //List<EmailMessage> ems = [SELECT id, Subject FROM EmailMessage];
            //System.assertEquals(1, ems.size());
            //System.debug('ems'+ems);
            //System.assertEquals('Your Critical Information Summary', ems.get(0).Subject);
    }
    //EDGE-117742 End
    
 }