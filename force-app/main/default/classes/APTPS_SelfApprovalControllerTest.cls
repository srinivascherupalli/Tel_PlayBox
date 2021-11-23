/*****************************************************************
@Name: APTPS_SelfApprovalControllerTest
@Author: Akanksha Trivedi
@CreateDate: 8/02/2017 
@Description: This is the Test class for APTPS_SelfApprovalController
******************************************************************/ 
@isTest
public with sharing class APTPS_SelfApprovalControllerTest {
    static testMethod void testData(){
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
       // agmt.Apttus__Account__c =acct.id;
        agmt.Apttus__Agreement_Number__c = '2323';
       // agmt.Apttus__Status_Category__c = 'In Signatures';
       // agmt.Apttus__Status__c = 'Fully Signed';
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
        System.assertEquals(Date.today(), agmt.Apttus__Company_Signed_Date__c); //EDGE-69042 Sonar Fix
         Apttus__APTS_Template__c templateClause = APTPS_TestClassData.templateRecord('Test Template', 'Clause');
        Apttus__Agreement_Clause__c agmtClause = new Apttus__Agreement_Clause__c(Apttus__Clause__c = 'Test Clause', Apttus__Agreement__c = agmt.id,
                                                                        Approval_Status__c='Approval Required',Apttus__Active__c = true, Apttus__Category__c = 'default',
                                                                        Apttus__Subcategory__c = 'Default', Apttus__Action__c = 'Inserted', Apttus__Text__c = 'test',Apttus__Template__c = templateClause.id);
        insert agmtClause;
    }
    
    /******************************************************************
    @Description: This test method is written to test the constuctor of APTPS_SelfApprovalController
    *******************************************************************/  
    
   /*static testMethod void testConstructor(){
      testData();
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        agmt.Apttus__Account__c =acct.id;
        agmt.Apttus__Agreement_Number__c = '2323';
       agmt.Apttus__Status_Category__c = 'In Signatures';
        agmt.Apttus__Status__c = 'Fully Signed';
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
        system.debug('fdff='+agmt.id);
        
        list<Apttus__Agreement_Clause__c> agmtClause = new list<Apttus__Agreement_Clause__c>();
       Apttus__Agreement_Clause__c testing;
       
       testing=new Apttus__Agreement_Clause__c(Apttus__Clause__c = 'Test Clause', Apttus__Agreement__c = agmt.id,
                                                                        Approval_Status__c='Approval Required',Apttus__Active__c = true, Apttus__Category__c = 'default',
                                                                        Apttus__Subcategory__c = 'Default', Apttus__Action__c = 'Inserted', Apttus__Text__c = 'test',createddate=date.today());
  
      agmtClause.add(testing);
      testing=new Apttus__Agreement_Clause__c(Apttus__Clause__c = 'Test Clause1', Apttus__Agreement__c = agmt.id,
                                                                        Approval_Status__c='Approval Required',Apttus__Active__c = true, Apttus__Category__c = 'default',
                                                                        Apttus__Subcategory__c = 'Default', Apttus__Action__c = 'Inserted', Apttus__Text__c = 'test',createddate=date.today());
     
      agmtClause.add(testing);

        insert agmtClause;
       
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
       
        APTPS_SelfApprovalController controller = new APTPS_SelfApprovalController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreementId);
        Test.stopTest();
    }*/
        

    /******************************************************************
    @Description: This test method is written to test the SaveSelfApprovedClause method of APTPS_SelfApprovalController
    *******************************************************************/  
    
   static testMethod void testSaveSelfApprovedClause(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
         Apttus__Agreement_Clause__c cl= [SELECT Id, Name,Approval_Status__c,Apttus__Clause__c,Apttus__Risk_Rating__c,APTPS_Self_Approved__c,Apttus__Text__c,
                              Apttus__PrevText__c,APTPS_Approval_Guidence__c,Apttus__Agreement__c,Apttus__Status__c,Apttus__Comments__c,APTPS_Non_Standard_Legal_Language__c, Apttus__DiffText2__c from Apttus__Agreement_Clause__c limit 1];
        system.debug('rrrrrrr='+cl.Approval_Status__c);
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_SelfApprovalController controller = new APTPS_SelfApprovalController(stdCon);
        APTPS_SelfApprovalController.APTPS_AgreementClauseWrapper cWrapper=new APTPS_SelfApprovalController.APTPS_AgreementClauseWrapper(cl);
        cWrapper.selfApproved=true;
       controller.agreementClauseWrapperList.add(cWrapper);
        controller.saveSelfApprovedClause();
        controller.parentAgreementId=agmt.id;
    // system.assert(controller.parentAgreement !=   null );
    	system.assertNotEquals(null,controller.parentAgreement);
        Test.stopTest();
    }
       static testMethod void testSaveSelfApprovedClause1(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
         Apttus__Agreement_Clause__c cl= [SELECT Id, Name,Approval_Status__c,Apttus__Clause__c,Apttus__Risk_Rating__c,APTPS_Self_Approved__c,Apttus__Text__c,
                              Apttus__PrevText__c,APTPS_Approval_Guidence__c,Apttus__Agreement__c,Apttus__Status__c,Apttus__Comments__c,APTPS_Non_Standard_Legal_Language__c, Apttus__DiffText2__c from Apttus__Agreement_Clause__c  limit 1];
        system.debug('rrrrrrr='+cl.Approval_Status__c);
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_SelfApprovalController controller = new APTPS_SelfApprovalController(stdCon);
        APTPS_SelfApprovalController.APTPS_AgreementClauseWrapper cWrapper=new APTPS_SelfApprovalController.APTPS_AgreementClauseWrapper(cl);
        cWrapper.selfApproved=true;
         
        
       controller.agreementClauseWrapperList.add(cWrapper);
        controller.saveSelfApprovedClause();
        controller.parentAgreementId=agmt.id;
         controller.cancel();  
    //    system.assert(controller.parentAgreement !=   null );
        system.assertNotEquals(null,controller.parentAgreement);
        Test.stopTest();
    }
    
     
       static testMethod void testSaveSelfApprovedClausetry(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
         Apttus__Agreement_Clause__c cl= [SELECT Id, Name,Approval_Status__c,Apttus__Clause__c,Apttus__Risk_Rating__c,APTPS_Self_Approved__c,Apttus__Text__c,
                              Apttus__PrevText__c,APTPS_Approval_Guidence__c,Apttus__Agreement__c,Apttus__Status__c,Apttus__Comments__c,APTPS_Non_Standard_Legal_Language__c, Apttus__DiffText2__c from Apttus__Agreement_Clause__c  limit 1];
        system.debug('rrrrrrr='+cl.Approval_Status__c);
        Apttus__APTS_Template__c templateClause = APTPS_TestClassData.templateRecord('Test Template', 'Clause');
        Apttus__Agreement_Clause__c agmtClause = APTPS_TestClassData.agreementClauseRecord(agmt.id, templateClause.id);
           agmtClause.Apttus__PrevText__c='test';agmtClause.APTPS_Approval_Guidence__c='';agmtClause.Approval_Status__c='Approval Required';update agmtClause;
           Test.startTest();
           
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_SelfApprovalController controller = new APTPS_SelfApprovalController(stdCon);
        APTPS_SelfApprovalController.APTPS_AgreementClauseWrapper cWrapper=new APTPS_SelfApprovalController.APTPS_AgreementClauseWrapper(agmtClause);
        cWrapper.selfApproved=true;
         
        
       controller.agreementClauseWrapperList.add(cWrapper);
        controller.saveSelfApprovedClause();
        controller.parentAgreementId=agmt.id;
         controller.cancel();  
    //    system.assert(controller.parentAgreement !=   null );
        system.assertNotEquals(null,controller.parentAgreement);
        Test.stopTest();
    }
}