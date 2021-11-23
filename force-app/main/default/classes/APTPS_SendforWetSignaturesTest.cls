/*****************************************************************
@Name: APTPS_SendforWetSignaturesTest
@Author: Meet Desai 
@CreateDate: 14/09/2016 
@Description: This class is the Test class for APTPS_SendforWetSignaturesController
@UsedBy: APTPS_SendforWetSignaturesController
******************************************************************/
@isTest
public with sharing class APTPS_SendforWetSignaturesTest {
	/******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
    static testMethod void APTPS_SendforWetSignaturesController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        PageReference pageRef = Page.APTPS_Init_SendforWetSignatures;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        APTPS_SendforWetSignaturesController controller = new APTPS_SendforWetSignaturesController();
        system.assertEquals(agmt.id, controller.parentAgreementId);
        
        PageReference updateAgreementAndRedirectRef = controller.updateAgreementAndRedirect();
        
        Test.stopTest();
    }
}