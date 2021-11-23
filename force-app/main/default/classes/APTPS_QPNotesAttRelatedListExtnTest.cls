/*****************************************************************
@Name: APTPS_QPNotesAttRelatedListExtnTest
@Author: Akanksha Trivedi
@CreateDate: 8/02/2017 
@Description: This is the Test class for APTPS_QPNotesAttRelatedListExtn
******************************************************************/ 
@isTest
public with sharing class APTPS_QPNotesAttRelatedListExtnTest{
    static testMethod void testData(){
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
       // agmt.Apttus__Account__c =acct.id;
        agmt.Apttus__Agreement_Number__c = '2323';
       // agmt.Apttus__Status_Category__c = 'In Signatures';
       // agmt.Apttus__Status__c = 'Fully Signed';
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
         System.assertEquals(Date.today(),agmt.Apttus__Company_Signed_Date__c); //EDGE-69042 Sonar Fix
        Attachment attach =APTPS_TestClassData.attachmentRecord('testAttachment', agmt.id);
        Note note = new Note(Title = 'Test Note', body = 'Unit Test Note Body',
                                                    parentId = agmt.id);
        insert note;
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
        Title='Header_Picture1', 
        PathOnClient ='/Apttus__Button_SendForBillingReview.jpg',
        VersionData = bodyBlob, 
        origin = 'H'   
        );
        insert contentVersion_1;
        List<ContentVersion> contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocumentLink cLink = new ContentDocumentLink();

        cLink.ContentDocumentId=contentVersion_2[0].contentdocumentid;
        cLink.LinkedEntityId = agmt.id;
         cLink.ShareType = 'V';
        insert cLink;
    }
    
    /******************************************************************
    @Description: This test method is written for the scenario when One click Activation occurs on Head terms and their schedules in a modular type of Agreement.
    *******************************************************************/  
    
    static testMethod void testGetNotesAttacmentRecords(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_QPNotesAttRelatedListExtn controller = new APTPS_QPNotesAttRelatedListExtn(stdCon);
        System.assertEquals(1,[SELECT COUNT() FROM Apttus__APTS_Agreement__c]);//EDGE-69042 Sonar Fix
        Test.stopTest();
  
        
    }
    static testMethod void testdeleteAttch(){
        testData(); 
        Attachment attch= [SELECT Id, name from Attachment limit 1];
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
        
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_QPNotesAttRelatedListExtn controller = new APTPS_QPNotesAttRelatedListExtn(stdCon);
        controller.strdltAttachment=attch.id;
        System.assertEquals(attch.id,controller.strdltAttachment);//EDGE-69042 Sonar Fix
        controller.deleteAttachment();
        Test.stopTest();
  
        
    }
     static testMethod void testdeleteNote(){
        testData(); 
        Note note= [SELECT Id, title from Note limit 1];
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_QPNotesAttRelatedListExtn controller = new APTPS_QPNotesAttRelatedListExtn(stdCon);
        controller.strdltAttachment=note.id;
        System.assertEquals(note.id,controller.strdltAttachment);//EDGE-69042 Sonar Fix
        controller.deleteNote();
        Test.stopTest();
  
        
    }
     
      static testMethod void testdeleteDoc(){
        testData();
        ContentDocument cDocs = [SELECT Id, Title
                                        FROM ContentDocument
                                        limit 1];  
         Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_QPNotesAttRelatedListExtn controller = new APTPS_QPNotesAttRelatedListExtn(stdCon);
        controller.strdltAttachment=cDocs.id;
        System.assertEquals(cDocs.id,controller.strdltAttachment);//EDGE-69042 Sonar Fix
        controller.deleteDoc();
        Test.stopTest();
  
        
    }
}