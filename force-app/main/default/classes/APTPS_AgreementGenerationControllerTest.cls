/**************************************************************
@Name: APTPS_AgreementGenerationControllerTest
@Author: Akanksha Trivedi 
@CreateDate: 03/06/2017
@Description: This is the Test class for APTPS_AgreementGenerationController
@UsedBy: APTPS_AgreementGenerationController
*************************************************************/ 
@isTest
public with sharing class APTPS_AgreementGenerationControllerTest{
    static Apttus__APTS_Agreement__c agmt ;
    static Apttus__APTS_Agreement__c agmt1 ;
    static void testData() {
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Subtype__c='Insurance';
        // agmt.Apttus__Status__c ='Request';
        // agmt.Apttus__Status_Category__c ='Request';
        update agmt;
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Apttus__Category__c ='Variation';
        template.Apttus__Subcategory__c ='Insurance';
        template.Apttus__Type__c = 'Supporting Document';
        template.Name='SARC Fund';
        insert template;   
      system.assertNotEquals(null, template.Id);        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        /* assert added #JIRA EDGE-14123 */
        System.assertEquals(ApexPages.currentPage().getParameters().get('agreementId'), agmt.Id);
        /* assert added #JIRA EDGE-14123 */       
    }    
    
    static void testData1() {           
        Account acct = APTPS_TestClassData.accountRecord('Test Account1', '1237688898');
        agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Subtype__c='Insurance';
        agmt.Apttus__Version_Number__c =20.0;
        // agmt.Apttus__Version_Number__c =0.0;
        // agmt.Apttus__Status__c ='Request';
        // agmt.Apttus__Status_Category__c ='Request';
        update agmt;
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Apttus__Category__c ='Variation';
        template.Apttus__Subcategory__c ='Insurance';
        template.Apttus__Type__c = 'Supporting Document';
        template.Name='SARC Fund';
        template.Apttus__Keywords__c = 'Variation';
        template.Apttus__Agreement_Types__c = 'SA'; 
        insert template;        
        test.startTest();
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.getTemplates();
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        // childAgmt1.Apttus__Version_Number__c =20.0;
        // update childAgmt1; 
        /* assert added #JIRA EDGE-14123 */
        System.assertEquals(cont.getTemplates().size(), 1);
        test.stopTest();
        /* assert added #JIRA EDGE-14123 */
        
    } 
    static void testData2() {
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account1', '1237688898');
        agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        agmt.Apttus__Subtype__c='Insurance';
        agmt.Apttus__Version_Number__c =20.0;
        // agmt.Apttus__Status__c ='Request';
        // agmt.Apttus__Status_Category__c ='Request';
        update agmt;
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Apttus__Category__c ='Variation';
        template.Apttus__Subcategory__c ='Insurance';
        template.Apttus__Type__c = 'Supporting Document';
        template.Name='SARC Fund';
        template.Apttus__Keywords__c = 'Variation';
        template.Apttus__Agreement_Types__c = 'Schedule';
        insert template;        
        test.startTest(); 
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.getTemplates();
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id); 
        /* assert added #JIRA EDGE-14123 */
        System.assertEquals(cont.getTemplates().size(), 1);
        test.stopTest();
        /* assert added #JIRA EDGE-14123 */       
        
    }
    static void testData3() {
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account1', '1237688898');
        agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Panel');
        agmt.Apttus__Subtype__c='Insurance';
        agmt.Apttus__Version_Number__c =20.0;
        // agmt.Apttus__Status__c ='Request';
        // agmt.Apttus__Status_Category__c ='Request';
        update agmt;
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Apttus__Category__c ='Variation';
        template.Apttus__Subcategory__c ='Insurance';
        template.Apttus__Type__c = 'Supporting Document';
        template.Name='SARC Fund';
        template.Apttus__Keywords__c = 'Variation';
        template.Apttus__Agreement_Types__c = 'Panel';
        insert template;        
        test.startTest(); 
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.getTemplates();
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        /* assert added #JIRA EDGE-14123 */
        System.assertEquals(cont.getTemplates().size(), 1);
        test.stopTest();
        /* assert added #JIRA EDGE-14123 */        
        
    }
    
    static void testData4() {        
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account11', '1237688898');
        agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        agmt.Apttus__Subtype__c='Insurance';
        // agmt.Apttus__Version_Number__c =20.0;
        agmt.Apttus__Version_Number__c =0;
        // agmt.Apttus__Status__c ='Request';
        // agmt.Apttus__Status_Category__c ='Request';
        update agmt;
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Apttus__Category__c ='Variation';
        template.Apttus__Subcategory__c ='Insurance';
        template.Apttus__Type__c = 'Supporting Document';
        template.Name='SARC Fund';
        template.Apttus__Agreement_Types__c = 'Schedule'; 
        insert template;        
        test.startTest(); 
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.getTemplates();
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementGeneration;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('agreementId', agmt.Id);
        
        // childAgmt1.Apttus__Version_Number__c =20.0;
        // update childAgmt1; 
        /* assert added #JIRA EDGE-14123 */
        System.assertEquals(cont.getTemplates().size(), 1);
        test.stopTest();
        /* assert added #JIRA EDGE-14123 */
        
    } 
    
    
    
    /******************************************************************
@Description: This test method is written for the generation of Agreements on Head terms and Schedules.
*******************************************************************/  
    static testMethod void getTemplatesTest(){
        
        test.startTest();
        testData();         
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Apttus__Category__c ='Variation';
        template.Apttus__Subcategory__c ='Insurance';
        template.Apttus__Type__c = 'Agreement';
        template.Name='SARC Fund';
        template.Apttus__Agreement_Types__c = 'Default';
        template.Apttus__IsActive__c = true;
        insert template; 
        system.assertNotEquals(null, template.Id);  
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.getTemplates();
        /* assert added #JIRA EDGE-14123 */
        System.assertEquals(cont.getTemplates().size(), 1);
        /* assert added #JIRA EDGE-14123 */ 
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        cont.getTemplates();
        Test.stopTest();
    }
    static testMethod void getTemplatesTest2(){
        
        test.startTest();
        testData();
        Apttus__APTS_Template__c updateTemp = [SELECT ID,Apttus__Keywords__c FROM Apttus__APTS_Template__c ORDER BY CREATEDDATE DESC LIMIT 1];
        updateTemp.Apttus__Keywords__c = 'Variation';
        updateTemp.Apttus__Agreement_Types__c = 'SA';
        UPDATE updateTemp;
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.parentAgreement.Apttus__Version_Number__c = 1;
        cont.getTemplates();
        /* assert added #JIRA EDGE-14123 */
        System.assertEquals(1, cont.getTemplates().size());       
        /* assert added #JIRA EDGE-14123 */
        Test.stopTest();
    }
    
    static testMethod void getTemplatesTest3(){        
        test.startTest();
        testData();
        Apttus__APTS_Template__c updateTemp = [SELECT ID,Apttus__Keywords__c FROM Apttus__APTS_Template__c ORDER BY CREATEDDATE DESC LIMIT 1];
        updateTemp.Apttus__Keywords__c = 'Variation';
        updateTemp.Apttus__Agreement_Types__c = 'SA';
        UPDATE updateTemp;
        system.assertNotEquals(null, updateTemp.Id);  
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.getTemplates();
        Test.stopTest();
    }
    static testMethod void getTemplatesTest4(){        
        test.startTest();
        testData();
        Id scheduleRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Schedule').getRecordTypeId();
        agmt.RecordtypeId = scheduleRecordTypeId;
        update agmt;
        
        Apttus__APTS_Template__c updateTemp = [SELECT ID,Apttus__Keywords__c FROM Apttus__APTS_Template__c ORDER BY CREATEDDATE DESC LIMIT 1];
        updateTemp.Apttus__Keywords__c = 'Variation';
        updateTemp.Apttus__Agreement_Types__c = 'SA';
        UPDATE updateTemp;
        system.assertNotEquals(null, updateTemp.Id); 
        ApexPages.currentPage().getParameters().put('actionName', 'Supporting');
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        
        cont.getTemplates();
        Test.stopTest();
    }
    
    static testMethod void getCancelAPTPS_AgreementGenerationControllerTest(){
        Test.startTest();
        testData(); 
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.cancel();
        /* assert added #JIRA EDGE-14123 */
        System.assertNotEquals(cont.parentAgreement.Id, null);        
        /* assert added #JIRA EDGE-14123 */ 
        Test.stopTest();
    }
    static testMethod void getcancelAndUpdate(){         
        Test.startTest();
        testData();   
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        
        update agmt; 
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.agreementsToBeUpdated.add(agmt);
        cont.cancelAndUpdate();
        cont.getSelected();
        /* assert added #JIRA EDGE-14123 */
        System.assertNotEquals(cont.parentAgreement.Id, null);  
        System.assertEquals(cont.agreementsToBeUpdated.size() > 0 , true); 
        /* assert added #JIRA EDGE-14123 */ 
        Test.stopTest();
    }
    static testMethod void getgenerateAgreement(){
        
        testData(); 
        Apttus__APTS_Template__c temp =   [select id , name from  Apttus__APTS_Template__c limit 1];
        // APTPS_Constants.GENERATED_ATTACHMENT_ORIGINAL ='Original';
        Attachment attach =APTPS_TestClassData.attachmentRecord('testAttachment Original', agmt.id); 
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);       
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        cont.generatedDocId= attach.id;
        cont.generateAgreement();   
        System.assertNotEquals(cont.parentAgreement.Id, null);  
        System.assertEquals(String.isEmpty(cont.agreementName) == false , true);      
        Test.stopTest();
    }
    
    static testMethod void getgenerateAgreement1(){
        
        testData(); 
        Apttus__APTS_Template__c temp =   [select id , name from  Apttus__APTS_Template__c limit 1];
        // APTPS_Constants.GENERATED_ATTACHMENT_ORIGINAL ='Original';
        Attachment attach =APTPS_TestClassData.attachmentRecord('testAttachment Original', agmt.id); 
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);       
        APTPS_AgreementGenerationController cont= new APTPS_AgreementGenerationController(stdCon);
        APTPS_AgreementGenerationController.TemplateWrapper wrapper = new APTPS_AgreementGenerationController.TemplateWrapper(temp);
        list<APTPS_AgreementGenerationController.TemplateWrapper> wrapperlist;
        
        // cont.templateListToBeDisplayed=wrapperlist;
        system.debug('attach.id='+attach.id);
        cont.generatedDocId= attach.id;
        ApexPages.currentPage().getParameters().put('selectedEmailTemplateId', temp.id);
        cont.getSelected(); 
        cont.generateAgreement();
        System.assertNotEquals(cont.parentAgreement.Id, null);  
        System.assertEquals(String.isEmpty(cont.agreementName) == false , true); 
        Test.stopTest();
        
    }
    
}