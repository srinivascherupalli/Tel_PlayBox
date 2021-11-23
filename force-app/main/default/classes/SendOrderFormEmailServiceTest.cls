/**************************************************************************************
 * Author      : Vishal Arbune
 * Class Name  : SendOrderFormEmailServiceTest
 * Related Class : SendOrderFormEmailService 
 * Description : Test class for the class SendOrderFormEmailService. 
 * Story       : EDGE-169633 : Use NOTIFY to send an FYI email with Order form to the customer 
 **************************************************************************************/
@IsTest
public class SendOrderFormEmailServiceTest {
    @TestSetup
    static void dataSetup(){
    
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User user= new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
        insert user;
               
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
            Email = 'test@tele2.com'   
        );
        insert contact;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp;
        System.debug('opp :'+opp);
        
        //Environment Variable
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Send_OrderForm_for_Contract';
        ev.Value__c='True';
        insert ev;
        
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
        System.assertNotEquals(cjList.size(), 0); 
        System.debug('cjList :'+cjList);
        
        list<ContentVersion> ContentVersionList = New list<ContentVersion>();
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Contract - Order Form',
                PathOnClient = 'Contract - Order Form.docx',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            ContentVersionList.add(contentVersion);
        insert ContentVersionList;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        list<ContentDocumentLink> ContentDocumentLinkList = New list<ContentDocumentLink>();
        for(ContentDocument document : documents){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = cjList[0].id;
            cdl.ContentDocumentId = document.Id;
            cdl.shareType = 'V';
            ContentDocumentLinkList.add(cdl);
        }                      
    }
    
    @isTest
    static void processSendOrderFormEmailTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testSuccess_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{};
        List<id> attList = new List<Id>{att.id};
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        System.debug('fields :'+fields);
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c';           
            
            List<id> ids = new List<id>();
            List<ContractJunction__c> queryData = Database.query(soql);
            for(integer i=0; i<queryData.size(); i++){
                ids.add(queryData[i].id);
            }     
        
        ContractJunction__c CJ = [Select account__c,isCISGenerated__c,CIS_Dispatched_Offers__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, '', 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'B2B_P2O_MAC_ORDER_RECEIVED', '', CJ.id, null);
        
        Integration_Record__c insRec = new Integration_Record__c();
        Blob b = Crypto.GenerateAESKey(128);
        String GUID = EncodingUtil.ConvertTohex(b);
        insRec.params__c = GUID;
        insRec.paramPayload__c = JSON.serialize(dto);
        insRec.handler__c = 'EmailHandler';
        insRec.status__c = IntegrationQueueHandler.PENDING;
        insert insRec;
        
        SendOrderFormEmailService.processSendOrderFormEmail(ids);
        Test.stopTest();
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'EmailHandler' AND id = :insRec.id];
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);
        System.assert(ids != null);     
    }   
    
    @isTest
    static void processSendOrderFormEmailTestFailure() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailSuccessMockResponseGenerator('testFail_CISEmail'));
        Attachment att = AttachmentTestUtils.createAttachment('Test File', 'This is test body', 'text/html');
        List<String> toList = new List<String>{'to@to.com'};
        List<String> ccList = new List<String>{'cc1@cc.com','cc2@cc.com'};
        List<String> bccList = new List<String>{};
        List<id> attList = new List<Id>{att.id};
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        System.debug('fields :'+fields);
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c';           
            
            List<id> ids = new List<id>();
            List<ContractJunction__c> queryData = Database.query(soql);
            for(integer i=0; i<queryData.size(); i++){
                ids.add(queryData[i].id);
            }     
        
        ContractJunction__c CJ = [Select account__c,isCISGenerated__c,CIS_Dispatched_Offers__c,Customer_Primary_Contact__c from  ContractJunction__c where name ='testCJ' limit 1];
        
        EmailDTO dto = new EmailDTO('from@from.com', toList,ccList,bccList, '', 'Test Subject' , attList, 'NOT_APPLICABLE', 'NOT_APPLICABLE', 'B2B_P2O_MAC_ORDER_RECEIVED', '', CJ.id, null);
        
        Integration_Record__c insRec = new Integration_Record__c();
        Blob b = Crypto.GenerateAESKey(128);
        String GUID = EncodingUtil.ConvertTohex(b);
        insRec.params__c = GUID;
        insRec.paramPayload__c = JSON.serialize(dto);
        insRec.handler__c = 'EmailHandler';
        insRec.status__c = IntegrationQueueHandler.PENDING;
                
        SendOrderFormEmailService.processSendOrderFormEmail(ids);
        Test.stopTest();
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c FROM Integration_Record__c WHERE handler__c = 'EmailHandler' AND id = :insRec.id];
        System.assertEquals(0, existingRequests.size());        
    }
 }