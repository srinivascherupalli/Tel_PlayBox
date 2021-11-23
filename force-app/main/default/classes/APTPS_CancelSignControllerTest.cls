/*****************************************************************
@Name: APTPS_CancelSignControllerTest
@Author: Akanksha Trivedi
@CreateDate: 8/02/2017 
@Description: This is the Test class for APTPS_CancelSignController
******************************************************************/ 
@isTest
public with sharing class APTPS_CancelSignControllerTest {
    static testMethod void testData(){
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 5;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        System.assertNotEquals(null, agmt);
                
    }
    
    /******************************************************************
    @Description: This test method is written to test the UpdateAgreement of APTPS_SelfApprovalController
    *******************************************************************/  
    
    static testMethod void testUpdateAgreement(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id,  Apttus__APTS_Agreement__c.Apttus__Status_Category__c ,name from Apttus__APTS_Agreement__c limit 1];
        
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_CancelSignController controller = new APTPS_CancelSignController(stdCon);
        controller.updateAgreement();
        system.assertEquals(APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY, controller.parentAgreement.Apttus__Status_Category__c);
        system.assertEquals(APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS, controller.parentAgreement.Apttus__Status__c);
        Test.stopTest();
    }
        

}