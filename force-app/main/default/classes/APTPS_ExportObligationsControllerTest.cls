/*****************************************************************
@Name: APTPS_ExportObligationsControllerTest
@Author: Ruchika Patil 
@CreateDate: 15/06/2016 
@Description: This is the Test class for APTPS_ExportObligationsController
@UsedBy: APTPS_ExportObligationsController
******************************************************************/ 
@isTest(SeeAllData=false)
public with sharing class APTPS_ExportObligationsControllerTest{
    /******************************************************************
    @Description: This test method is written for the preventing task delete for running user as System Administrator and Contract Manager.
    *******************************************************************/  
    static testMethod void APTPS_ExportObligationsController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus_SRM__SRMObligation__c obligationRecord1 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        Apttus_SRM__SRMObligation__c obligationRecord2 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        
        PageReference pageRef = Page.APTPS_Init_ExportObligations;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        APTPS_ExportObligationsController controller = new APTPS_ExportObligationsController();
        system.assertEquals(agmt.id, controller.parentAgreementId);
        
        controller.generateCSV();
        APTPS_ExportObligationsController.generateCSV(agmt.id);
        system.assertEquals(2, controller.obligations.size());
       
        Test.stopTest();
    }
}