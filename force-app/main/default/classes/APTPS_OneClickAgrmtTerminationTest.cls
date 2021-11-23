/*****************************************************************
@Name: APTPS_OneClickAgrmtTerminationTest
@Author: Meet Desai 
@CreateDate: 08/09/2016 
@Description: This class is the Test class for APTPS_OneClickAgrmtTerminationController
@UsedBy: APTPS_OneClickAgrmtTerminationController
******************************************************************/
@isTest
public with sharing class APTPS_OneClickAgrmtTerminationTest {
	/******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
    static testMethod void APTPS_OneClickAgrmtTerminationController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus__APTS_Agreement__c agmtChild = APTPS_TestClassData.agreementParent(acct.id, agmt.id);
        
        PageReference pageRef = Page.APTPS_Init_OneClickAgreementTermination;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_OneClickAgrmtTerminationController controller = new APTPS_OneClickAgrmtTerminationController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        
        controller.getAgreements();
        
        PageReference cancelPageRef = controller.cancel();
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
        PageReference confirmPageRef = controller.confirmTermination();
        
        Test.stopTest();
    }
}