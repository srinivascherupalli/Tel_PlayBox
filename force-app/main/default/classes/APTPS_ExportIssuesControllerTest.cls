/*****************************************************************
@Name: APTPS_ExportIssuesControllerTest
@Author: Ruchika Patil 
@CreateDate: 16/06/2016 
@Description: This is the Test class for APTPS_ExportIssuesController
@UsedBy: APTPS_ExportIssuesController
******************************************************************/ 
@isTest(SeeAllData=false)
public with sharing class APTPS_ExportIssuesControllerTest{
    /******************************************************************
    @Description: This test method is written for the preventing task delete for running user as System Administrator and Contract Manager.
    *******************************************************************/  
    static testMethod void APTPS_ExportIssuesController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Id recordId = Schema.SObjectType.Apttus_SRM__Issue__c.getRecordTypeInfosByName().get('0 - Inherent Risk').getRecordTypeId();
        Apttus_SRM__Issue__c issue1 = APTPS_TestClassData.issueRecord(agmt.id, acct.id, '0 - Inherent Risk','Not Started');
        Apttus_SRM__Issue__c[] issue2 = [SELECT ID FROM Apttus_SRM__Issue__c where Apttus_SRM__Agreement__c = :agmt.id and RecordTypeId = :recordId];
        System.assertEquals(1, issue2.size());
       
        PageReference pageRef = Page.APTPS_Init_ExportIssues;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        APTPS_ExportIssuesController controller = new APTPS_ExportIssuesController();
        system.assertEquals(agmt.id, controller.parentAgreementId);
        
        controller.generateCSV();
        APTPS_ExportIssuesController.generateCSV(agmt.id);
        
        Test.stopTest();
    }
}