/*****************************************************************
@Name: APTPS_MergeAgrmntAttachmentsControllerTest
@Author: Ruchika Patil 
@CreateDate: 16/06/2016 
@Description: This is the Test class for APTPS_MergeAgrmntAttachmentsController
@UsedBy: APTPS_MergeAgrmntAttachmentsController
******************************************************************/ 
@isTest
public with sharing class APTPS_MergeAgrmntAttachmentsTest{
    /******************************************************************
    @Description: This test method is written for the preventing task delete for running user as System Administrator and Contract Manager.
    *******************************************************************/  
    static testMethod void APTPS_MergeAgrmntAttachmentsController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        Attachment agmtAttachment1 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmt.id);    
        Attachment agmtAttachment2 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date2', agmt.id);  
        Attachment childAgmt1Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date1', childAgmt1.id);  
        Attachment childAgmt1Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date2', childAgmt1.id); 
        Attachment childAgmt2Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date1', childAgmt2.id);  
        Attachment childAgmt2Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date2', childAgmt2.id);  
        
        PageReference pageRefer = Page.APTPS_Init_MergeAgreementAttachments;
        Test.setCurrentPage(pageRefer); 
        System.assertNotEquals(null, pageRefer);
        
        pageRefer.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_MergeAgrmntAttachmentsController controller = new APTPS_MergeAgrmntAttachmentsController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.id);
        system.assertEquals(agmt.name, controller.agreementName);
        
        List<APTPS_AttachmenttSelectionWrapper> attachmentListToBeDisplayed = controller.getAttachments();
        system.assertNotEquals(null, attachmentListToBeDisplayed.size());
        
        //Scenario 1 where all Inputs are correct.
        integer i = 1;
        for(APTPS_AttachmenttSelectionWrapper attachment : controller.attachmentListToBeDisplayed){
            attachment.selected = true;
            attachment.sequence = i;
            i++;
        }
        PageReference pageRef = controller.createListofAgreementsToMerge();
        system.assertEquals(null, pageRef);
        
        //controller.mergeDocument();
        
        //Scenario 2 where Sequence is not unique.
        for(APTPS_AttachmenttSelectionWrapper attachment : controller.attachmentListToBeDisplayed){
            attachment.sequence = 1;
        }
        pageRef = controller.createListofAgreementsToMerge();
        system.assertEquals(null, pageRef);
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        //Scenario 3 where all Sequences are input as 0.
        for(APTPS_AttachmenttSelectionWrapper attachment : controller.attachmentListToBeDisplayed){
            attachment.sequence = 0;
        }
        pageRef = controller.createListofAgreementsToMerge();
        system.assertEquals(null, pageRef);
        ApexPages.Message[] pageMessages1 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());     
        
        //Scenario 4 where only one attachment is selected for merging.
        i = 1;
        for(APTPS_AttachmenttSelectionWrapper attachment : controller.attachmentListToBeDisplayed){
            if(i==1){
                attachment.selected = true;
            }
            else{
                attachment.selected = false;
            }
            attachment.sequence = i;
            i++;
        }
        pageRef = controller.createListofAgreementsToMerge();
        system.assertEquals(null, pageRef);
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size()); 
        
        PageReference pg = controller.cancel();
        
        Test.stopTest();
    }
}