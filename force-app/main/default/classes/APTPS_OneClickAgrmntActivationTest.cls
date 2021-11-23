/*****************************************************************
@Name: APTPS_OneClickAgrmntActivationTest
@Author: Ruchika Patil 
@CreateDate: 13/06/2016 
@Description: This is the Test class for APTPS_OneClickAgrmntActivationController
@UsedBy: APTPS_OneClickAgrmntActivationController 
******************************************************************/ 
@isTest
public with sharing class APTPS_OneClickAgrmntActivationTest{
    /******************************************************************
    @Description: This test method is written for the scenario when One click Activation occurs on Head terms and their schedules in a modular type of Agreement.
    *******************************************************************/  
    static testMethod void modularActivation(){
        
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Agreement_Number__c = '2323';
        update agmt;
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        //List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt.id];
                
        Attachment agmtAttachment1 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmt.id);    
        Attachment agmtAttachment2 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date2', agmt.id);  
        Attachment childAgmt1Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date1', childAgmt1.id);  
        Attachment childAgmt1Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date2', childAgmt1.id); 
        Attachment childAgmt2Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date1', childAgmt2.id);  
        Attachment childAgmt2Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date2', childAgmt2.id);        
        
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'In Signatures';
        agmt.Apttus__Status__c = childAgmt1.Apttus__Status__c = childAgmt2.Apttus__Status__c = 'Fully Signed';
        agmt.Apttus__Company_Signed_Date__c = childAgmt1.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
        update childAgmt1; 
        update childAgmt2; 
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_OneClickAgrmntActivationController controller = new APTPS_OneClickAgrmntActivationController(stdCon);
        controller.parentAgreement.Apttus_Approval__Approval_Status__c = 'Approval Required';
        controller.parentAgreement.Apttus_Approval__Approval_Status__c = 'Pending Approval';
        controller.parentAgreement.Apttus_Approval__Approval_Status__c = 'Rejected';
        system.assertEquals(null, controller.pageName);
        
        PageReference cancelPageRef = controller.cancel();
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementActivation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', agmt.Id);
        //when we have id added
        controller = new APTPS_OneClickAgrmntActivationController(stdCon);
        
        system.assertEquals(agmt.id, controller.parentAgreement.id);
        system.assertEquals(agmt.Name, controller.agreementName);
        
        List<APTPS_AgreementSelection> agmtSelectionList = controller.getAgreements();
        system.assertNotEquals(0, agmtSelectionList.size());
        
        map<Id, APTPS_AgreementSelection> selectedAgreementList1 = new Map<Id, APTPS_AgreementSelection>();
        selectedAgreementList1.put(agmt.Id, new APTPS_AgreementSelection(agmt));
        Map<Id, string> failedAgreementsForActivation1  = new Map<Id, String>();
        failedAgreementsForActivation1.put(agmt.ID, 'asdasd');
        controller.failedAgreementsForActivation = failedAgreementsForActivation1;
        controller.selectedAgreementList = selectedAgreementList1;
        controller.sendMail();
        //Scenario 1 for createListForActivateAgreements
        PageReference activatePageRef = controller.createListForActivateAgreements();
        system.assertEquals(true, controller.selectedAgreementList.isEmpty());
        system.assertEquals(0, controller.selectedAgreementListIds.size());
        system.assertEquals(0, controller.selectedAgreementListSize);
        system.assertEquals(true, controller.displayError);
        
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected = true;
        }
        //Scenario 2 for createListForActivateAgreements
        activatePageRef = controller.createListForActivateAgreements();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());     
        
        //Scenario 3 for createListForActivateAgreements
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected = true;
            Boolean first = true;
            for(APTPS_AgreementAttachmentWrapper attach : agrGen.attachmentsForActivation){
                if(first){
                    attach.selected = true;
                }
                first = false;
            }
            first = true;
            for(APTPS_AgreementAttachmentWrapper attach : agrGen.attachmentsForRemoving){
                if(!first){
                    attach.selected = true;
                }
                first = false;
            }
        }
        
        activatePageRef = controller.createListForActivateAgreements();
        system.assertEquals(false, controller.selectedAgreementList.isEmpty());
        system.assertNotEquals(0, controller.selectedAgreementListIds.size());
        system.assertEquals(false, controller.displayError);
        
        //Checking for activateAgreementAsync 
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        controller.activateAgreementAsync();
        
        cancelPageRef = controller.cancel();

        ApexPages.currentPage().getParameters().put('agreementId', childAgmt1.Id);
        controller.activateAgreementAsync(); 
        
        cancelPageRef = controller.cancel();
        
        //system.assertEquals(false, controller.failedAgreementsForActivation.isEmpty());
        
        //Scenario 4 for createListForActivateAgreements
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            Boolean first = true;
            for(APTPS_AgreementAttachmentWrapper attach : agrGen.attachmentsForRemoving){
                if(first){
                    attach.selected = true;
                }
                else{
                    attach.selected = false;
                }
                first = false;
            }
        }
        
        activatePageRef = controller.createListForActivateAgreements();
        system.assertEquals(true, controller.selectedAgreementList.isEmpty());
        system.assertEquals(0, controller.selectedAgreementListIds.size());
        system.assertEquals(0, controller.selectedAgreementListSize);
        system.assertEquals(true, controller.displayError);
        
        //Scenario 5 for createListForActivateAgreements
        childAgmt2.Apttus__Company_Signed_Date__c = Date.today();
        
        activatePageRef = controller.createListForActivateAgreements();
        
        Test.stopTest();
  
        
    }
    /******************************************************************
    @Description:This test method is for the scenario when Activation occurs on Legacy system Agreement mass Activation.
    *******************************************************************/  
    static testMethod void massLegacyAgmtActivation(){
        
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;        
        //When page is not null
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        List<Apttus__APTS_Agreement__c> testAgmtList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agmtTest = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        testAgmtList.add(agmtTest);
        Apttus__APTS_Agreement__c childAgmtTest1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule'); 
        childAgmtTest1.Apttus__Parent_Agreement__c = agmtTest.id;
        testAgmtList.add(childAgmtTest1);
        Apttus__APTS_Agreement__c childAgmtTest2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        testAgmtList.add(childAgmtTest2);
        Apttus__APTS_Agreement__c childAgmtTest3 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        testAgmtList.add(childAgmtTest3);
        Apttus__APTS_Agreement__c childAgmtTest4 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        testAgmtList.add(childAgmtTest4);
        Apttus__APTS_Agreement__c childAgmtTest5 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        testAgmtList.add(childAgmtTest5);
        
        Attachment agmtTestAttachment1 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmtTest.id);    
        Attachment agmtTestAttachment2 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date2', agmtTest.id);  
        
        Attachment childAgmtTest1Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date1', childAgmtTest1.id);  
        Attachment childAgmtTest1Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date2', childAgmtTest1.id);
        
        Attachment childAgmtTest2Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date1', childAgmtTest2.id);  
        Attachment childAgmtTest2Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date2', childAgmtTest2.id);
        
        Attachment childAgmtTest3Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt3_Original_date1', childAgmtTest3.id);  
        Attachment childAgmtTest3Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt3_Original_date2', childAgmtTest3.id);
        
        Attachment childAgmtTest4Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt4_Original_date1', childAgmtTest4.id);  
        Attachment childAgmtTest4Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt4_Original_date2', childAgmtTest4.id);
        
        Attachment childAgmtTest5Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt5_Original_date1', childAgmtTest5.id);  
        Attachment childAgmtTest5Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt5_Original_date2', childAgmtTest5.id);
        
        for(Apttus__APTS_Agreement__c agreement : testAgmtList){
            agreement.Apttus__Status_Category__c = 'In Signatures';
            agreement.Apttus__Status__c = 'Fully Signed – Migrated';
            agreement.Apttus__Company_Signed_Date__c = Date.today();
        }
        testAgmtList[5].Apttus__Company_Signed_Date__c = null;
        update testAgmtList; 
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmtTest);
        APTPS_OneClickAgrmntActivationController controller = new APTPS_OneClickAgrmntActivationController(stdCon);
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementActivation;
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('Id', agmt.Id);
        
        ApexPages.currentPage().getParameters().put('Page', 'Home');        
        controller = new APTPS_OneClickAgrmntActivationController(stdCon);
        
        system.assertEquals('Home', controller.pageName);
        system.assertNotEquals(0, controller.agreementListToBeDisplayed.size());
        system.assertNotEquals(0, controller.genericList.size());
        system.assertNotEquals(0, controller.fullGenericList.size());
        
        PageReference cancelPageRef = controller.cancel();
        system.assertEquals('/home/home.jsp', cancelPageRef.getUrl());
        
        PageReference nextPage = controller.nextPage();
        PageReference prevPage = controller.previousPage();
        PageReference updatePage = controller.updatePage();
        PageReference chngDataPage = controller.changeData();
        
        //Scenario 1 for createListForActivateAgreements
        PageReference activatePageRef = controller.createListForActivateAgreements();
        system.assertEquals(true, controller.selectedAgreementList.isEmpty());
        system.assertEquals(0, controller.selectedAgreementListIds.size());
        system.assertEquals(0, controller.selectedAgreementListSize);
        system.assertEquals(false, controller.displayError);
        
        //Scenario 2 for createListForActivateAgreements
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected = true;
        }
        
        activatePageRef = controller.createListForActivateAgreements();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size()); 
        
        //Scenario 3 for createListForActivateAgreements
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected = true;
            Boolean first = true;
            for(APTPS_AgreementAttachmentWrapper attach : agrGen.attachmentsForActivation){
                if(first){
                    attach.selected = true;
                }
                first = false;
            }
            first = true;
            for(APTPS_AgreementAttachmentWrapper attach : agrGen.attachmentsForRemoving){
                if(!first){
                    attach.selected = true;
                }
                first = false;
            }
        }
        
        activatePageRef = controller.createListForActivateAgreements();
        system.assertEquals(false, controller.selectedAgreementList.isEmpty());
        system.assertNotEquals(0, controller.selectedAgreementListIds.size());
        system.assertEquals(false, controller.displayError);
        
        //Checking for activateAgreementAsync 
        ApexPages.currentPage().getParameters().put('agreementId', agmtTest.Id);
        controller.activateAgreementAsync();
        
        cancelPageRef = controller.cancel();
        
        ApexPages.currentPage().getParameters().put('agreementId', childAgmtTest1.Id);
        controller.activateAgreementAsync(); 
        
        cancelPageRef = controller.cancel();
        
        //system.assertEquals(false, controller.failedAgreementsForActivation.isEmpty());
        
        //Scenario 4 for createListForActivateAgreements
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            Boolean first = true;
            for(APTPS_AgreementAttachmentWrapper attach : agrGen.attachmentsForRemoving){
                if(first){
                    attach.selected = true;
                }
                else{
                    attach.selected = false;
                }
                first = false;
            }
        }
        
        activatePageRef = controller.createListForActivateAgreements();
        system.assertEquals(true, controller.selectedAgreementList.isEmpty());
        system.assertEquals(0, controller.selectedAgreementListIds.size());
        system.assertEquals(0, controller.selectedAgreementListSize);
        system.assertEquals(true, controller.displayError);
        
        //Scenario 5 for createListForActivateAgreements
        testAgmtList[5].Apttus__Company_Signed_Date__c = Date.Today();
        update testAgmtList; 
        
        activatePageRef = controller.createListForActivateAgreements();
        
        Test.stopTest();
        
    }
}