/*****************************************************************
@Name: AgreementApprovalControllerTest
@Author: Akanksha Trivedi
@CreateDate: 8/02/2017 
@Description: This is the Test class for AgreementApprovalController
******************************************************************/ 
@isTest
public with sharing class AgreementApprovalControllerTest {
    static void testData(){
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        agmt.Apttus__Agreement_Number__c = '2323';
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        update agmt;
        Apttus_Approval__Approval_Request__c aprReq= new Apttus_Approval__Approval_Request__c();
        insert aprReq;
    }
    

    static testMethod void testGetAgreementApproval(){
        testData();
         Apttus_Approval__Approval_Request__c aprReq= [SELECT Id, name from Apttus_Approval__Approval_Request__c limit 1];        
        Test.startTest();       
        AgreementApprovalController controller = new AgreementApprovalController();
        controller.approvalRequest =aprReq;
        Apttus_Approval__Approval_Request__c approvalReq =controller.approvalRequest;
        system.assertEquals(approvalReq, aprReq);
        Test.stopTest();
    }
}