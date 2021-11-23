/*****************************************************************
@Name: APTPS_SubmitToCMTeamTest
@Author: Meet Desai 
@CreateDate: 08/09/2016 
@Description: This class is the Test class for APTPS_SubmitToCMTeamController
@UsedBy: APTPS_SubmitToCMTeamController
******************************************************************/ 
@isTest
public with sharing class APTPS_SubmitToCMTeamTest {
	/******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
    static testMethod void APTPS_SubmitToCMTeamController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        PageReference pageRef = Page.APTPS_Init_SubmitToCMTeam;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_SubmitToCMTeamController controller = new APTPS_SubmitToCMTeamController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        
        acct.APTPS_Tier__c = '3';
        update acct;
        PageReference confirmPageRef1 = controller.changeOwner();
        
        acct.APTPS_Tier__c = '1';
        update acct;
        PageReference confirmPageRef2 = controller.changeOwner();
        
        Test.stopTest();
    }
}