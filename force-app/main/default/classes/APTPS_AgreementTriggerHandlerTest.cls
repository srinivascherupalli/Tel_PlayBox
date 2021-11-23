/*****************************************************************
@Name: APTPS_AgreementTriggerHandlerTest
@Author: Ruchika Patil 
@CreateDate: 01/06/2016 
@Description: This class is the Test class for APTPS_AgreementTriggerHandler
@UsedBy: APTPS_AgreementTriggerHandler
******************************************************************/ 
@isTest
public with sharing class APTPS_AgreementTriggerHandlerTest{

    /******************************************************************
    @Description:This testMethod is for copyObligationFromTemplateObligation method.
    *******************************************************************/  
    /*static testMethod void copyObligationFromTemplateObligation(){
        
        Apttus__APTS_Template__c templateClause = APTPS_TestClassData.templateRecord('Test Template', 'Clause');
        APTPS_Template_Obligations__c templateObligation = APTPS_TestClassData.templateObligationRecord('Test name', templateClause.id);
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus_SRM__SRMObligation__c obligation = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        
        Apttus__Agreement_Clause__c agmtClause = APTPS_TestClassData.agreementClauseRecord(agmt.id, templateClause.id);
        
        Map<id, Apttus__APTS_Agreement__c> mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        mapOldAgreement.put(agmt.id, agmt);
        
        agmt.Apttus__Status_Category__c = 'In Signatures';
        agmt.Apttus__Status__c = 'Fully Signed';
        update agmt;
        
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);  

        Test.startTest();
        
        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);
        
        Test.stopTest();
    }
    /******************************************************************
    @Description:This testMethod is for terminateObligation method.
    *******************************************************************/  
   /* static testMethod void terminateObligation(){
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmtTerminated = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c agmtExpired = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus_SRM__SRMObligation__c obligationTerm = APTPS_TestClassData.obligationRecord(agmtTerminated.id, acct.id);
        Apttus_SRM__SRMObligation__c obligationExp = APTPS_TestClassData.obligationRecord(agmtExpired.id, acct.id);

        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User userSA = APTPS_TestClassData.userRecord(systemAdministrator.id);
        
        Task taskRecordTerminated = APTPS_TestClassData.taskRecord(userSA.id, obligationTerm.id, 'In Progress');
        Task taskRecordExpired = APTPS_TestClassData.taskRecord(userSA.id, obligationExp.id, 'In Progress');
        
        Map<id, Apttus__APTS_Agreement__c> mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        mapOldAgreement.put(agmtTerminated.id, agmtTerminated);
        mapOldAgreement.put(agmtExpired.id, agmtExpired);
        
        agmtTerminated.Apttus__Status_Category__c = 'Terminated';
        agmtTerminated.Apttus__Status__c = 'Terminated';
        update agmtTerminated;
        
        agmtExpired.Apttus__Status_Category__c = 'Expired';
        agmtExpired.Apttus__Status__c = 'Expired';
        update agmtExpired;
        
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmtTerminated); 
        agreementList.add(agmtExpired);
        
        Test.startTest();
        
        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        handler.terminateObligation(agreementList, mapOldAgreement);

        List<Apttus_SRM__SRMObligation__c> obligationList = [Select Id, Name, APTPS_Status__c FROM Apttus_SRM__SRMObligation__c 
                                                                WHERE (Id =:obligationExp.id Or id =: obligationTerm.id) And APTPS_Status__c = 'Terminated'];
        system.assertEquals(2, obligationList.size());
        
        List<Task> taskList = [Select id, status, WhatId FROM Task WHERE Id=:taskRecordTerminated.id Or id=:taskRecordExpired.id];
        system.assertEquals(0, taskList.size());
        
        Test.stopTest();
    }
    /******************************************************************
    @Description:This testMethod is for populateOutputFormat method.
    *******************************************************************/  
    /*static testMethod void populateOutputFormat(){
    
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        
        Test.startTest();
        
        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        handler.populateOutputFormat(agreementList);
        
        Apttus__APTS_Agreement__c updatedAgmt = [Select Id, Apttus__AllowableOutputFormats__c from Apttus__APTS_Agreement__c where id = :agmt.id Limit 1];
        
        system.assertEquals('DOC;DOCX', updatedAgmt.Apttus__AllowableOutputFormats__c);
        
        Test.stopTest();
    }
    /******************************************************************
    @Description:This testMethod is for populateEndDates method.
    *******************************************************************/  
  /*  static testMethod void populateEndDates(){
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        //Scenario 1
        
        Map<id, Apttus__APTS_Agreement__c> mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        mapOldAgreement.put(agmt.id, agmt);
        
        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 10, 11);
        agmt.Apttus__Term_Months__c = 4;
        update agmt;
        
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        
        Test.startTest();
        
        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);
        
        Apttus__APTS_Agreement__c updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                                                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c 
                                                where Id =:agmt.id Limit 1];
        system.assertEquals(updatedAgmt.Apttus__Company_Signed_Date__c, updatedAgmt.Apttus__Contract_Start_Date__c);
        system.assertEquals(Date.newInstance(2017, 2, 11), updatedAgmt.Apttus__Contract_End_Date__c);
        system.assertEquals(updatedAgmt.APTPS_Effective_End_Date__c, updatedAgmt.Apttus__Contract_End_Date__c);
        
        //Scenario 2
        
        mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        mapOldAgreement.put(agmt.id, agmt);
        
        agmt.Apttus__Company_Signed_Date__c = Date.newInstance(2016, 1, 1);
        agmt.Apttus__Term_Months__c = 2;
        update agmt;
        agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);                    
        
        handler = new APTPS_AgreementTriggerHandler();
        handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);
        
        updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                                                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c 
                                                where Id =:agmt.id Limit 1];
        system.assertEquals(updatedAgmt.Apttus__Company_Signed_Date__c, updatedAgmt.Apttus__Contract_Start_Date__c);
        system.assertEquals(Date.newInstance(2016, 3, 1), updatedAgmt.Apttus__Contract_End_Date__c);
        system.assertEquals(updatedAgmt.APTPS_Effective_End_Date__c, updatedAgmt.Apttus__Contract_End_Date__c);
        
        //Scenario 3
        
        mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        mapOldAgreement.put(agmt.id, agmt);
        
        agmt.Apttus__Term_Months__c = 1;
        update agmt;
        agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);                    
        
        handler = new APTPS_AgreementTriggerHandler();
        handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);
        
        updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                                                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c 
                                                where Id =:agmt.id Limit 1];
        system.assertEquals(Date.newInstance(2016, 2, 1), updatedAgmt.Apttus__Contract_End_Date__c);
        system.assertEquals(updatedAgmt.APTPS_Effective_End_Date__c, updatedAgmt.Apttus__Contract_End_Date__c);
        
        //Scenario 4
        
        mapOldAgreement = new Map<id, Apttus__APTS_Agreement__c>();
        mapOldAgreement.put(agmt.id, agmt);
        
        agmt.Apttus__Company_Signed_Date__c = null;
        update agmt;
        agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);                    
        
        handler = new APTPS_AgreementTriggerHandler();
        handler.copyObligationFromTemplateObligation(agreementList, mapOldAgreement);
        
        updatedAgmt = [Select Id, Apttus__Company_Signed_Date__c, Apttus__Term_Months__c, Apttus__Contract_Start_Date__c,
                                                APTPS_Effective_End_Date__c, Apttus__Contract_End_Date__c From Apttus__APTS_Agreement__c 
                                                where Id =:agmt.id Limit 1];
        system.assertEquals(null, updatedAgmt.Apttus__Contract_Start_Date__c);
        system.assertEquals(null, updatedAgmt.Apttus__Contract_End_Date__c);
        system.assertEquals(null, updatedAgmt.APTPS_Effective_End_Date__c);
        
        Test.stopTest();
    }
    /******************************************************************
    @Description:This testMethod is for activateLegacyAgreement method.
    *******************************************************************/ 
   /* static testMethod void activateLegacyAgreement(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
                
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
                                
        Attachment agmtAttachment1 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date1', agmt.id);    
        Attachment agmtAttachment2 = APTPS_TestClassData.attachmentRecord('acct-agmt_Original_date2', agmt.id);  
        Attachment childAgmt1Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1_Original_date1', childAgmt1.id);  
        Attachment childAgmt1Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt1Conformed-Agreement', childAgmt1.id); 
        Attachment childAgmt2Attachment1 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Original_date1', childAgmt2.id);  
        Attachment childAgmt2Attachment2 = APTPS_TestClassData.attachmentRecord('acct-childAgmt2_Conformed-Agreement', childAgmt2.id);        
        
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        agmt.Apttus__Status_Category__c = childAgmt1.Apttus__Status_Category__c = childAgmt2.Apttus__Status_Category__c = 'In Filing';
        agmt.APTPS_Legacy_Agreement__c = childAgmt1.APTPS_Legacy_Agreement__c = childAgmt2.APTPS_Legacy_Agreement__c = true;
        update agmt;
        update childAgmt1; 
        update childAgmt2; 
        
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        agreementList.add(childAgmt1);
        agreementList.add(childAgmt2);
        
        Test.startTest();
        
        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        handler.activateLegacyAgreement(agreementList);
        
        agmtAttachment1.Name = 'acct-agmt_Original_signed.pdf';
        update agmtAttachment1;
        
        agreementList = new List<Apttus__APTS_Agreement__c>();
        agreementList.add(agmt);
        agreementList.add(childAgmt1);
        agreementList.add(childAgmt2);
        
        handler.activateLegacyAgreement(agreementList);
        
        Test.stopTest();
        
    }*/
    
     /******************************************************************
    @Description:This testMethod is for ED Derivated checklist
    *******************************************************************/  
    static testMethod void embeddedDerivaties(){
    
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementRecord(acct1.id);
        Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        agmt1.RecordTypeId = saRecordTypeId ;
		//agmt1.APTPS_ED_Filter_Checklist_Required__c = true;
		agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c ='Activated';
        agmt1.APTPS_Obligations_Copied_After_Variation__c = null; 
        agmt1.Apttus__Status__c = 'Fully Signed'; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Status__c = 'FULLY_SIGNED_STATUS';
        agmt1.APTPS_Obligations_Copied_After_Variation__c = null;
        	
        
        List<Apttus__APTS_Agreement__c> agreementList1 = new List<Apttus__APTS_Agreement__c>();
        agreementList1.add(agmt1);
        
        Test.startTest();
        
        APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
        
        Apttus__APTS_Agreement__c updatedAgmt1 = [Select Id, RecordTypeId, APTPS_Validation_on_Fully_Signed__c,APTPS_ED_Filter_Checklist_Required__c,Apttus__Total_Contract_Value__c,APTPS_Obligations_Copied_After_Variation__C,Apttus__Termination_Date__c,
                                                  APTPS_Title__c from Apttus__APTS_Agreement__c where id = :agmt1.id Limit 1];
        
        system.assertEquals(false, updatedAgmt1.APTPS_ED_Filter_Checklist_Required__c);
        system.assertEquals(false,  updatedAgmt1.APTPS_Obligations_Copied_After_Variation__C);
        system.assertEquals(false,  updatedAgmt1.APTPS_Validation_on_Fully_Signed__c);
        system.assertEquals(updatedAgmt1.APTPS_Title__c, updatedAgmt1.APTPS_Title__c);
              
        
        Test.stopTest();
    }
    
    private static testMethod void beforeDelete_Test(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Test.startTest();
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Agreement_Number__c = '2323';
        agmt.Apttus__Version_Number__c = 2;
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
        Test.stopTest();
        delete agmt;
        
    }
    
    private static testMethod void beforeInsert_Test(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Test.stopTest();
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementParent(acct.id, agmt.Id);
        
    }
    
    private static testMethod void beforeUpdate_Test(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Service Trial');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = APTPS_Constants.FULLY_SIGNED_STATUS; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Version_Number__c = 3;
        update agmt1;
    }
    
    private static testMethod void beforeUpdate_basketCheckboxUpdateTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = APTPS_Constants.FULLY_SIGNED_STATUS; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Version_Number__c = 3;
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
    }
    
    private static testMethod void beforeUpdate_termmonthsTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = APTPS_Constants.FULLY_SIGNED_STATUS; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Term_Months__c = null;
        update agmt1;
        
    }
    
    private static testMethod void beforeUpdate_accountUpdateTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Account acct1 = APTPS_TestClassData.accountRecord('Test Account1', '1230778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Test.stopTest();
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = APTPS_Constants.FULLY_SIGNED_STATUS; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        agmt1.Apttus__Account__c = acct1.Id;
        update agmt1;
         
    }
    
    private static testMethod void beforeUpdate_expiredTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Test.stopTest();
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = APTPS_Constants.EXPIRED_STATUS;
        agmt1.Apttus__Status__c = APTPS_Constants.EXPIRED_STATUS; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
         
    }
    
    private static testMethod void beforeUpdate_terminatedTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Account acct1 = APTPS_TestClassData.accountRecord('Test Account1', '1230778898');
        Contact contactCompanySignedBy = APTPS_TestClassData.contactRecord('George','Washington',acct.id);
        Contact contactOtherPartySigned = APTPS_TestClassData.contactRecord('Robert','Downey',acct1.id);
        Test.stopTest();
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = APTPS_Constants.TERMINATED_STATUS;
        agmt1.Apttus__Status__c = APTPS_Constants.TERMINATED_STATUS ; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        agmt1.Apttus__Account__c = acct1.Id;
        agmt1.Apttus__Company_Signed_By__c = contactCompanySignedBy.Id;
        agmt1.Apttus__Other_Party_Signed_By__c = contactOtherPartySigned.Id;
        update agmt1;
         
    }
    
    private static testMethod void beforeUpdate_RollingTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = APTPS_Constants.FULLY_SIGNED_STATUS; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
        Test.StopTest();
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_EFFECT_STATUS_CATEGORY ;
        agmt1.Apttus__Status__c = 'Rolling'; 
        update agmt1;
         
    }
    
    private static testMethod void beforeUpdate_RollingWithParentAgreementTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementParent(acct.id, agmt.Id);
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = APTPS_Constants.FULLY_SIGNED_STATUS; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = true;
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_EFFECT_STATUS_CATEGORY ;
        agmt1.Apttus__Status__c = 'Rolling'; 
        update agmt1;
         
    }
    
     private static testMethod void beforeUpdate_InEffectStatusTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementParent(acct.id, agmt.Id);
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'In Effect';
        agmt1.Apttus__Status__c = 'Rolling'; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_EFFECT_STATUS_CATEGORY ;
        agmt1.Apttus__Status__c = 'Rolling'; 
        agmt1.APTPS_Effective_End_Date__c = System.today().addDays(200);
        agmt1.APTPS_Effective_End_Date_For_Min_Spend__c = System.today().addDays(100);
        update agmt1;
         
    }
    
    private static testMethod void beforeUpdate_CancelledTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementParent(acct.id, agmt.Id);
        Test.stopTest();
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status_Category__c = 'Cancelled';
        agmt1.Apttus__Status__c = 'Cancelled Request'; 
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
        
         
    }
    
    private static testMethod void beforeUpdate_ScheduleNumberTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status__c = 'Fully Signed - Migrated'; 
        agmt1.Apttus__Status_Category__c = 'In Signatures';
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        agmt1.APTPS_Schedule_Number_Text__c = 'zyz';
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Status__c = APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS ; 
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;
        agmt1.APTPS_Schedule_Number_Text__c = 'xyzsdo';
        update agmt1;
        
         
    }
    
    private static testMethod void beforeUpdate_SentByEsignatureTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status__c = 'Fully Signed - Migrated'; 
        agmt1.Apttus__Status_Category__c = 'In Signatures';
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Status__c = APTPS_Constants.OTHER_PARTY_SIGNATURES_STATUS  ; 
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_SIGNATURES_STATUS_CATEGORY ;
        agmt1.APTPS_Sent_By_E_Signature__c = true;
        update agmt1;
        
         
    }
    
    private static testMethod void beforeUpdate_InEffectSingedTest(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status__c = 'Fully Signed - Migrated'; 
        agmt1.Apttus__Status_Category__c = 'In Signatures';
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Status__c = APTPS_Constants.IN_EFFECT_STATUS  ; 
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_EFFECT_STATUS_CATEGORY  ;
        agmt1.APTPS_Sent_By_E_Signature__c = true;
        update agmt1;
        
         
    }
    
    private static testMethod void afterUpdate_Test(){
        Test.startTest();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt1.Apttus__Version_Number__c = 2;
        agmt1.Apttus__Total_Contract_Value__c = 3000001;	
		agmt1.Apttus__Agreement_Category__c = 'Business Services' ;
        agmt1.Apttus__Status__c = 'Fully Signed - Migrated'; 
        agmt1.Apttus__Status_Category__c = 'In Filing';
        agmt1.APTPS_Is_Custom_Update__c = false;
        agmt1.Apttus__Contract_Start_Date__c = System.today();
        agmt1.Apttus__Contract_End_Date__c = System.today().adddays(180);
        agmt1.Auto_Created_by_Basket__c = false;
        agmt1.APTPS_Legacy_Agreement__c = true;
        update agmt1;
        Test.stopTest();
        agmt1.Apttus__Status__c = APTPS_Constants.IN_EFFECT_STATUS  ; 
        agmt1.Apttus__Status_Category__c = APTPS_Constants.IN_EFFECT_STATUS_CATEGORY  ;
        agmt1.APTPS_Sent_By_E_Signature__c = true;
        update agmt1;
        
         
    }
}