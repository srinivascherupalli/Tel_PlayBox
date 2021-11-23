/*****************************************************************
@Name: APTPS_ValidationOnESignatureTest
@Author: Meet Desai 
@CreateDate: 14/09/2016 
@Description: This class is the Test class for APTPS_ValidationOnESignatureController
@UsedBy: APTPS_ValidationOnESignatureController
******************************************************************/
@isTest
public with sharing class APTPS_ValidationOnESignatureTest {
	/******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
    static testMethod void APTPS_ValidationOnESignatureController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        PageReference pageRef = Page.APTPS_ValidationOnESignature;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_ValidationOnESignatureController controller = new APTPS_ValidationOnESignatureController(stdCon);
        
        controller.agmtId = acct.Id;
        system.assertNotEquals(agmt.id, controller.agmtId);
        PageReference validationsOnESignatureRef1 = controller.validationsOnESignature();
        system.assertEquals(0, apexpages.getMessages().size());
        
        controller.agmtId = agmt.Id;
        PageReference validationsOnESignatureRef2 = controller.validationsOnESignature();
        
        controller.agmtId = null;
        PageReference validationsOnESignatureRef3 = controller.validationsOnESignature();
        
        Test.stopTest();
    }
}