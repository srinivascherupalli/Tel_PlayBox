/*********************************************************************************************************************************
 * Class Name   :   DisplayMessageControllerTest
 * Description  :   Test Class for DisplayMessageController
 SL.No.     Developer Name      Date            Story Description
 1.         Pooja Bhat          5/July/2021     EDGE-221053: B2B-1179 Case Attachment size to be aligned as per T-Connect
**********************************************************************************************************************************/
@isTest
private class DisplayMessageControllerTest {
    
    @testSetup
    static void testdata() {
        
        Account testAccount =   TestDataFactory.generateAccount();
        
        Contact testContact =   TestDataFactory.generateContact('Test',testAccount.Id,'Active','User1',System.today(),'Mobile');
        insert testContact;
        
        List<Billing_Account__c> lstBillAccs = new List<Billing_Account__c>();
        Billing_Account__c  billAcc1 = TestDataFactory.generateBillingAccount('700000017897','Created',testAccount.Id,testContact.Id);
        Billing_Account__c  billAcc2 = TestDataFactory.generateBillingAccount('700000017898','Created',testAccount.Id,testContact.Id);
        lstBillAccs.add(billAcc1);
        lstBillAccs.add(billAcc2);
        insert lstBillAccs;
        
        List<Case> caseList = new List<Case>();
        String caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing_Enquiry').getRecordTypeId();  
        Case oCase1 = TestDataFactory.generateCase(testAccount.Id,testContact.Id,'Email','Medium','New',billAcc1.Id,'Billing Enquiry Case' + billAcc1.Billing_Account_Number__c,'test case 1');
        Case oCase2 = TestDataFactory.generateCase(testAccount.Id,testContact.Id,'Email','Medium','New',billAcc2.Id,'Billing Enquiry Case' + billAcc2.Billing_Account_Number__c,'test case 2');
        oCase1.RecordTypeId         =   caseRecTypId;
        oCase2.RecordTypeId         =   caseRecTypId;
        caseList.add(oCase1);
        caseList.add(oCase2);
        insert caseList;

        String testMsg  =   'Unit Test Attachment Body ';
        Blob bodyBlob1  =   Blob.valueOf(testMsg);
        Blob bodyBlob2  =   Blob.valueOf('a'.repeat(5000000));
        Blob bodyBlob3  =   bodyBlob2;

        List<ContentVersion> contentVerList     =   new List<ContentVersion>();
        ContentVersion contentVer1              =   new ContentVersion();
        contentVer1.Title                       =   'Test File Less Than 10MB';
        contentVer1.ContentLocation             =   'S';
        contentVer1.PathOnClient                =   'Test File Less Than 10MB.pdf';
        contentVer1.Accessibility__c            =   'Telstra Connect';
        contentVer1.versiondata                 =   bodyBlob1;
        contentVerList.add(contentVer1);
        ContentVersion contentVer2              =   new ContentVersion();
        contentVer2.Title                       =   'Test File Greater Than 10MB';
        contentVer2.ContentLocation             =   'S';
        contentVer2.PathOnClient                =   'Test File Greater Than 10MB.pdf';
        contentVer2.Accessibility__c            =   'Telstra Connect';
        contentVer2.versiondata                 =   bodyBlob2;
        contentVerList.add(contentVer2);
        insert contentVerList;

        List<ContentDocumentLink> contentDocLinkList    =   new List<ContentDocumentLink>();
        List<ContentVersion> contentVersionList         =   [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 2];
        for(ContentVersion contentVer : contentVersionList) {
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ContentDocumentId = contentVer.ContentDocumentId;
            conDocLink.LinkedEntityId = caseList[0].Id;
            contentDocLinkList.add(conDocLink);
        }
        insert contentDocLinkList;
    }

    @isTest
    static void fectchContentVersionTest() {
        Utility_Settings__c utilSettings    =   new Utility_Settings__c();
        utilSettings.File_Size_Message__c   =   'File will not be shared on Telstra Connect because the size exceeds 10MB';
        insert utilSettings;
    
        List<ContentVersion> contentVerList =   [SELECT Id,Title,Accessibility__c,ContentSize,ContentDocumentId 
                                                    FROM ContentVersion];
        String contentDocIdLT10 =   '';     
        String contentDocIdGT10 =   '';
        for(ContentVersion conVersn : contentVerList) {
            if(conVersn.Title.equalsIgnoreCase('Test File Less Than 10MB')) {
                contentDocIdLT10    =   conVersn.ContentDocumentId;
            } else {
                contentDocIdGT10    =   conVersn.ContentDocumentId;
            }
        }
        System.assertEquals(2, contentVerList.size());
        Test.startTest();
            try {
                String message1 = DisplayMessageController.fectchContentVersion(contentDocIdLT10);
            } catch (Exception e) {
                System.debug('exception**** ' + e.getLineNumber() + ' '+ e.getMessage());
            }
            try {
                String message2 = DisplayMessageController.fectchContentVersion(contentDocIdGT10);
            } catch (Exception e) {
                System.debug('exception**** ' + e.getLineNumber() + ' '+ e.getMessage());
            }
        Test.stopTest();
    }
}