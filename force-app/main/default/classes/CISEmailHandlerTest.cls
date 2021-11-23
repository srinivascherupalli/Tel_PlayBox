//updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
@isTest
public class CISEmailHandlerTest {
    @Testsetup
    static void dataSetup(){
       //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
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
        
        ContractJunction__c CJ=new ContractJunction__c();
        CJ.name='testCJ';
        CJ.account__c=acc.id;
        CJ.Related_Opportunity__c = opp.id;
        CJ.isCISGenerated__c=false;
        CJ.CIS_Dispatched_Offers__c = 'MDM Offer';
        CJ.Customer_Primary_Contact__c = contact.id;
        insert CJ;
    }
    
    @isTest
    public static void executeWorkTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testSuccess_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
		List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
		List<String> bccList = new List<String>{'bcc@bcc.com'};
        List<id> attList = new List<Id>{att.id};
        
        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c limit 1];
        ContractJunction__c CJ = [Select account__c,isCISGenerated__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList,congaTemplate.APXTConga4__Name__c, 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'EDGESF_ORDER_2', '', CJ.id, null);
            Integration_Record__c insRec = new Integration_Record__c();
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            insRec.params__c = GUID;
            insRec.paramPayload__c = JSON.serialize(dto);
            insRec.handler__c = 'CISEmailHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            insert insRec;

            CISEmailHandler handler = new CISEmailHandler();
            handler.executeWork(new List<String>{insRec.params__c});
            Test.stopTest();

            List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'CISEmailHandler' AND id = :insRec.id];
            System.assertEquals(1, existingRequests.size());
            System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
            List<EmailMessage> ems = [SELECT id, Subject FROM EmailMessage WHERE FromAddress = :dto.fromEmail];
            System.assertEquals(1, ems.size());
            System.assertEquals('Test Subject', ems.get(0).Subject);
    }
        
}