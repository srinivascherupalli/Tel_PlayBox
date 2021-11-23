/*****************************************************************
@Name: APTPS_ExportSchedulesCtrTest
@Author: Ruchika Patil 
@CreateDate: 20/06/2016 
@Description: This is the Test class for APTPS_ExportSchedulesController
@UsedBy: APTPS_ExportSchedulesController
******************************************************************/ 
@isTest
public with sharing class APTPS_ExportSchedulesCtrTest{
    /******************************************************************
    @Description: This test method is written for the preventing task delete for running user as System Administrator and Contract Manager.
    *******************************************************************/  
    static testMethod void APTPS_ExportSchedulesController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus__APTS_Agreement__c childAgmt1 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        
        childAgmt1.Apttus__Parent_Agreement__c = childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        update childAgmt1;
        update childAgmt2;
        
        PageReference pageRef = Page.APTPS_Init_ExportSchedules;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        APTPS_ExportSchedulesController controller = new APTPS_ExportSchedulesController();
        system.assertEquals(agmt.id, controller.parentAgreementId);
        
        controller.generateCSV();
        system.assertEquals(2, controller.schedules.size());
        
        Test.stopTest();
    }
}