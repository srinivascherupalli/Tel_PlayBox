/**
  * Author: Nilima Borse
  * Team: Jaipur
  * Sprint: 20.10
  * Date: 16/07/2020
  * Description: Test class for cpeGetQuoteDetails lightning component - P2OB-7498
  **/
@isTest(seeAllData=false)
public class cpeRequestOrderCtrlTest {
    public static Case caseObj;
    public static soc_Case_Line_Item__c caseLineItem;
    
        
    @isTest
    public  static void test_fetchQuoteDetails(){
        caseObj = [Select Subject, AccountId, Description, OpportunityId__c, salesup_Support_Type__c,salesup_Work_Required__c,
                          srvsup_Categories__c, cpe_Quote_Status__c,RecordTypeId FROM CASE limit 1];
        test.startTest();
        cpeRequestOrderCtrl.CaseLineItemWrapper caseLineItemWrapper= cpeRequestOrderCtrl.fetchQuoteDetails(caseObj.Id);
        test.stopTest();
        system.assert(caseLineItemWrapper!=null);
        
    }
    
    @isTest
    public  static void test_acceptQuote(){
        caseObj = [Select Subject, AccountId, Description, OpportunityId__c, salesup_Support_Type__c,salesup_Work_Required__c,
                          srvsup_Categories__c, cpe_Quote_Status__c,RecordTypeId FROM CASE limit 1];
        test.startTest();
        List<soc_Case_Line_Item__c> quoteList = new List<soc_Case_Line_Item__c>([SELECT cpe_External_System_Quote_Number__c, Id, cpe_Requote_Details__c, 
                                                                 cpe_Accept_Quote__c FROM soc_Case_Line_Item__c 
                                                                 where soc_CaseId__c =: caseObj.Id] );
        List<soc_Case_Line_Item__c> newQuoteList = cpeRequestOrderCtrl.acceptQuotes( quoteList, caseObj.Id);
        test.stopTest();
        system.assert(newQuoteList!=null);
    }
    
    @isTest
    public  static void test_attachDocumentToOpportunity(){
        caseObj = [Select Subject, AccountId, Description, OpportunityId__c, salesup_Support_Type__c,salesup_Work_Required__c,
                          srvsup_Categories__c, cpe_Quote_Status__c,RecordTypeId FROM CASE limit 1];  
        caseLineItem = [Select soc_CaseId__c, cpe_Accept_Quote__c, cpe_Requote_Details__c FROM soc_Case_Line_Item__c limit 1];
        test.startTest();       
        
        
        profile pr = [select id from profile where name = 'System Administrator'];
        user intgUser = new user(firstname = 'testFirstName',
                                 lastname = 'testLastName',
                                 profileid = pr.id,
                                 email = 'testuser@testclass.com',
                                 Username = 'testfirst.lastname@testclass.com',
                                 Alias = 'TfTl',
                                 CommunityNickname = 'test_786user' ,
                                 TimeZoneSidKey = 'America/New_York', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US'
                                );
        insert intgUser;
        system.runAs(intgUser){ 
            ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = blob.valueof('Test Content Data'),
                IsMajorVersion = true
            );
            insert cv;
            
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
             ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=caseLineItem.id;  
             contentlink.ShareType = 'I';             
             contentlink.ContentDocumentId=documents[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;

            System.assertEquals(documents.size(), 1);
        }
        
        List<soc_Case_Line_Item__c> quoteList = new List<soc_Case_Line_Item__c>([SELECT cpe_External_System_Quote_Number__c, Id, cpe_Requote_Details__c, 
                                                                 cpe_Accept_Quote__c FROM soc_Case_Line_Item__c 
                                                                 where soc_CaseId__c =: caseObj.Id] );
        quoteList[0].cpe_Accept_Quote__c = true;
        update quoteList;
        cpeRequestOrderCtrl.attachDocumentToOpportunity( quoteList, caseObj.Id);
       
        test.stopTest();
    }
    
    @testSetup static void setupTestData() {
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE');
        insert acct;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = acct;
        testOpp.AccountId = acct.Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Qualify';
        testOpp.BidStatus__c = 'Bid Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.Proposal_Required_Date__c = System.Date.today();
        insert testOpp;
		Id devRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CPE_Requests').getRecordTypeId();
        
        caseObj= new Case(Subject='CPE Test',
                          AccountId=acct.id,
                          Description='Test',
                          OpportunityId__c=testOpp.id,
                          salesup_Support_Type__c = 'CPE Hardware And Services',
                          salesup_Work_Required__c = 'HW&S Quote Support',
                          srvsup_Categories__c='Pricing And Quote Support',
                          cpe_Quote_Status__c='Awaiting Approval',
                          RecordTypeId = devRecordTypeId
                          );
		test.startTest();
       	insert caseObj;  
		test.stopTest();
        
        caseLineItem = new soc_Case_Line_Item__c(soc_CaseId__c = caseObj.id,
                                                cpe_Accept_Quote__c= false,
                                                cpe_Requote_Details__c = 'requote'
                                                );
        insert caseLineItem;
        
        
    }

}