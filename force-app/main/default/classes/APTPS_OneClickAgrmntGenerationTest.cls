/*************************************************************
@Name: APTPS_OneClickAgrmntGenerationTest
@Author: Ruchika Patil 
@CreateDate: 08/06/2016 
@Description: This is the Test class for APTPS_OneClickAgrmntGenerationController
@UsedBy: APTPS_OneClickAgrmntGenerationController
*********************************************************/  
@isTest
public with sharing class APTPS_OneClickAgrmntGenerationTest{
    /******************************************************************
    @Description: This test method is written for the generation of Agreements on Head terms and Schedules.
    *******************************************************************/  
    static testMethod void APTPS_OneClickAgrmntGenerationController(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        APTPS_TestClassData.createQueryTemplateData();
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
        
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt1.Apttus__Status_Category__c = 'In Authoring';
        childAgmt1.Apttus__Status__c = 'Author Contract';
        update childAgmt1;
        update childAgmt2;
        
        //Attachment creation for passing as Apttus.MergeWebService.generateDoc returned value.
        Attachment generateddocument = new Attachment();    
        generateddocument.Name ='Account-Agreement_Original_date';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        generateddocument.body = bodyBlob;
        generateddocument.parentId = childAgmt1.id;
        insert generateddocument;
        system.assertNotEquals(null, generateddocument.Id);
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_OneClickAgrmntGenerationController controller = new APTPS_OneClickAgrmntGenerationController(stdCon);
        
        system.assertEquals(agmt.id, controller.parentAgreement.id);
        system.assertEquals(agmt.recordtypeid, controller.recordtypeid);
        system.assertEquals(agmt.name, controller.agreementName);
        
        List<APTPS_AgreementSelection> agmtSelectionList = controller.getAgreements();
        system.assertNotEquals(0, agmtSelectionList.size());
        
        PageReference cancelPageRef = controller.cancel();
        system.assertEquals('/'+agmt.Id, cancelPageRef.getUrl());
        
        controller.agreementsToBeUpdated.add(childAgmt1);
        PageReference cancelAndUpdatePageRef = controller.cancelAndUpdate();
        system.assertEquals('/'+agmt.Id, cancelAndUpdatePageRef.getUrl());
        
        PageReference genListPageRef = controller.createListForGenerateAgreements();
        system.assertEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);
    
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected  = true;
        }
        genListPageRef = controller.createListForGenerateAgreements();
        system.assertNotEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);

        controller.generateAgreementAsync();
        //Scenario for Child Agreement generation
        //controller = new APTPS_OneClickAgrmntGenerationController(stdCon);
        
        ApexPages.currentPage().getParameters().put('agreementId', childAgmt1.Id);
        
        agmtSelectionList = controller.getAgreements();
        system.assertNotEquals(0, agmtSelectionList.size());
        
        genListPageRef = controller.createListForGenerateAgreements();
        
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected  = true;
        }
        genListPageRef = controller.createListForGenerateAgreements();
        system.assertNotEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);
        
        controller.generatedDocId = generateddocument.id;
        system.assertNotEquals(null, controller.generatedDocId);
        
        controller.generateAgreementAsync();
        
        //controller.generateAgreement(agmt.id, template.id);
        
        Test.stopTest();
    }
    static testMethod void APTPS_OneClickAgrmntGenerationController1(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account1', '1237778899');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Panel');
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        APTPS_TestClassData.createQueryTemplateData();
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
        
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt1.Apttus__Status_Category__c = 'In Authoring';
        childAgmt1.Apttus__Status__c = 'Author Contract';
        update childAgmt1;
        update childAgmt2;
        
        //Attachment creation for passing as Apttus.MergeWebService.generateDoc returned value.
        Attachment generateddocument = new Attachment();    
        generateddocument.Name ='Account-Agreement_Original_date';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        generateddocument.body = bodyBlob;
        generateddocument.parentId = childAgmt1.id;
        insert generateddocument;
        system.assertNotEquals(null, generateddocument.Id);
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_OneClickAgrmntGenerationController controller = new APTPS_OneClickAgrmntGenerationController(stdCon);
        
        system.assertEquals(agmt.id, controller.parentAgreement.id);
        system.assertEquals(agmt.recordtypeid, controller.recordtypeid);
        system.assertEquals(agmt.name, controller.agreementName);
        
        List<APTPS_AgreementSelection> agmtSelectionList = controller.getAgreements();
        system.assertNotEquals(0, agmtSelectionList.size());
         controller.agreementsToBeUpdated.add(childAgmt1);
        PageReference cancelPageRef = controller.cancel();
        system.assertEquals('/'+agmt.Id, cancelPageRef.getUrl());
        
        PageReference cancelAndUpdatePageRef = controller.cancelAndUpdate();
        system.assertEquals('/'+agmt.Id, cancelAndUpdatePageRef.getUrl());
        
        PageReference genListPageRef = controller.createListForGenerateAgreements();
        system.assertEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);
    
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected  = true;
        }
        genListPageRef = controller.createListForGenerateAgreements();
        system.assertNotEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);

        controller.generateAgreementAsync();
        //Scenario for Child Agreement generation
        //controller = new APTPS_OneClickAgrmntGenerationController(stdCon);
        
        ApexPages.currentPage().getParameters().put('agreementId', childAgmt1.Id);
        
        agmtSelectionList = controller.getAgreements();
        system.assertNotEquals(0, agmtSelectionList.size());
        
        genListPageRef = controller.createListForGenerateAgreements();
        
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected  = true;
        }
        genListPageRef = controller.createListForGenerateAgreements();
        system.assertNotEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);
        
        controller.generatedDocId = generateddocument.id;
        system.assertNotEquals(null, controller.generatedDocId);
        
        controller.generateAgreementAsync();
        
        //controller.generateAgreement(agmt.id, template.id);
        
        Test.stopTest();
    }
   static testMethod void APTPS_OneClickAgrmntGenerationController2(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account1', '1237778899');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Panel');
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        APTPS_TestClassData.createQueryTemplateData();
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
        
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt1.Apttus__Status_Category__c = 'In Authoring';
        childAgmt1.Apttus__Status__c = 'Author Contract';
        update childAgmt1;
        update childAgmt2;
        
        //Attachment creation for passing as Apttus.MergeWebService.generateDoc returned value.
        Attachment generateddocument = new Attachment();    
        generateddocument.Name ='Account-Agreement_Original_date';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        generateddocument.body = bodyBlob;
        generateddocument.parentId = childAgmt1.id;
        insert generateddocument;
        system.assertNotEquals(null, generateddocument.Id);
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_OneClickAgrmntGenerationController controller = new APTPS_OneClickAgrmntGenerationController(stdCon);
        
        system.assertEquals(agmt.id, controller.parentAgreement.id);
        system.assertEquals(agmt.recordtypeid, controller.recordtypeid);
        system.assertEquals(agmt.name, controller.agreementName);
        controller.parentAgreement=null;
      
      
        PageReference genListPageRef = controller.createListForGenerateAgreements();
        controller.selectedAgreementList=null;
         controller.generateAgreementAsync();
         List<APTPS_AgreementSelection> agmtSelectionList = controller.getAgreements();
       
       
        Test.stopTest();
    }
    static testMethod void APTPS_OneClickAgrmntGenerationController3(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account1', '1237778899');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Panel');
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        APTPS_TestClassData.createQueryTemplateData();
        
        List<Apttus__APTS_Agreement__c> agmtList = [Select id, recordtypeid, recordtype.name from Apttus__APTS_Agreement__c where id =:agmt.id or id=: childAgmt1.id or id=:childAgmt2.id];
        
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt1.Apttus__Status_Category__c = 'In Authoring';
        childAgmt1.Apttus__Status__c = 'Author Contract';
        update childAgmt1;
        update childAgmt2;
        Apttus__APTS_Template__c template1 = new Apttus__APTS_Template__c();
                 
        template1.Name = 'Aptpstemplate';
        template1.Apttus__IsActive__c = true;
        template1.Apttus__Type__c = 'Agreement';
        template1.Apttus__Agreement_Types__c ='Default';
        
         
        Insert template1;
        Apttus__QueryTemplate__c Qtemplate = new Apttus__QueryTemplate__c();
        //Qtemplate. ='';
        Qtemplate.Apttus__Active__c = true;
        Qtemplate.Apttus__SObjectLabel__c='Agreement Template';
        Qtemplate.Apttus__Type__c ='Agreement Template Filter';
        Qtemplate.Apttus__Sequence__c =1.0;
        Insert Qtemplate;
        
        Apttus__QueryTemplateFilter__c Qtemplatefltr = new Apttus__QueryTemplateFilter__c();
        Qtemplatefltr.Apttus__QueryTemplate__c = Qtemplate.id;
        Qtemplatefltr.Apttus__Field__c ='Testfield';
        Qtemplatefltr.Apttus__CompOper__c ='equal to';
        Qtemplatefltr.Apttus__BooOper__c ='AND';
        //Qtemplate.Apttus__SObjectLabel__c = 'Agreement Template'; 
        //Qtemplate.Apttus__Type__c = 'Agreement Template Filter';
        //Qtemplate.Name = 'Testtemplate'; 
        Qtemplatefltr.Apttus__Sequence__c =1.0;
        Insert Qtemplatefltr;
        //Attachment creation for passing as Apttus.MergeWebService.generateDoc returned value.
        Attachment generateddocument = new Attachment();    
        generateddocument.Name ='Account-Agreement_Original_date';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        generateddocument.body = bodyBlob;
        generateddocument.parentId = childAgmt1.id;
        insert generateddocument;
        system.assertNotEquals(null, generateddocument.Id);
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_OneClickAgrmntGenerationController controller = new APTPS_OneClickAgrmntGenerationController(stdCon);
        
        system.assertEquals(agmt.id, controller.parentAgreement.id);
        system.assertEquals(agmt.recordtypeid, controller.recordtypeid);
        system.assertEquals(agmt.name, controller.agreementName);
        
        List<APTPS_AgreementSelection> agmtSelectionList = controller.getAgreements();
        system.assertNotEquals(0, agmtSelectionList.size());
         controller.agreementsToBeUpdated.add(childAgmt1);
        PageReference cancelPageRef = controller.cancel();
        system.assertEquals('/'+agmt.Id, cancelPageRef.getUrl());
        
        PageReference cancelAndUpdatePageRef = controller.cancelAndUpdate();
        system.assertEquals('/'+agmt.Id, cancelAndUpdatePageRef.getUrl());
        
        PageReference genListPageRef = controller.createListForGenerateAgreements();
        system.assertEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);
    
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected  = true;
        }
        genListPageRef = controller.createListForGenerateAgreements();
        system.assertNotEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);

        controller.generateAgreementAsync();
        //Scenario for Child Agreement generation
        //controller = new APTPS_OneClickAgrmntGenerationController(stdCon);
        
        ApexPages.currentPage().getParameters().put('agreementId', childAgmt1.Id);
        
        agmtSelectionList = controller.getAgreements();
        system.assertNotEquals(0, agmtSelectionList.size());
        
        genListPageRef = controller.createListForGenerateAgreements();
        
        for(APTPS_AgreementSelection agrGen : controller.agreementListToBeDisplayed){
            agrGen.selected  = true;
        }
        genListPageRef = controller.createListForGenerateAgreements();
        system.assertNotEquals(0, controller.selectedAgreementList.size());
        system.assertEquals(null, genListPageRef);
        
        controller.generatedDocId = generateddocument.id;
        system.assertNotEquals(null, controller.generatedDocId);
        
        controller.generateAgreementAsync();
        
        //controller.generateAgreement(agmt.id, template.id);
        
        Test.stopTest();
    }

}