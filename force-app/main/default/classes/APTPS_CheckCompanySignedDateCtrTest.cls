/*****************************************************************
@Name: APTPS_CheckCompanySignedDateCtrTest
@Author: Ruchika Patil 
@CreateDate: 31/08/2016 
@Description: This is the Test class for APTPS_CheckCompanySignedDateController
@UsedBy: APTPS_CheckCompanySignedDateController
******************************************************************/ 
@isTest
public with sharing class APTPS_CheckCompanySignedDateCtrTest{
    /******************************************************************
    @Description: This test method is written for the preventing task delete for running user as System Administrator and Contract Manager.
    *******************************************************************/  
    static testMethod void validationsOnActivate(){        
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        PageReference pageRefer = Page.APTPS_CheckCompanySignedDate;
        Test.setCurrentPage(pageRefer); 
        System.assertNotEquals(null, pageRefer);
        
        /*pageRefer.getParameters().put('id', null);
        System.assertEquals(null, apexpages.currentpage().getparameters().get('id')); */
        
        Test.startTest();
        
        APTPS_CheckCompanySignedDateController  controller = new APTPS_CheckCompanySignedDateController (new ApexPages.StandardController(agmt));
        
        PageReference pageRef = Page.APTPS_CheckCompanySignedDate;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
                
        //Scenario 1 - Where Company signed date is null.
        agmt.Apttus__Company_Signed_Date__c = null;
        agmt.Apttus_Approval__Approval_Status__c = 'Approved';
        update agmt;
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        controller = new APTPS_CheckCompanySignedDateController (new ApexPages.StandardController(agmt));
        
        Pagereference pg = controller.validationsOnActivate();
        system.assertEquals(null, pg);
        
        //Scenario 2 - where Approval status is "Pending Approval"
        agmt.Apttus_Approval__Approval_Status__c  = 'Pending Approval' ;
        agmt.Apttus__Company_Signed_Date__c = Date.newinstance(2016, 7, 10);
        update agmt;
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        controller = new APTPS_CheckCompanySignedDateController (new ApexPages.StandardController(agmt));
        
        Pagereference pgRef = controller.validationsOnActivate();

        //Scenario 3 - where both are incorrect     
        agmt.Apttus_Approval__Approval_Status__c = 'Pending Approval';
        agmt.Apttus__Company_Signed_Date__c = null;
        update agmt;
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        controller = new APTPS_CheckCompanySignedDateController (new ApexPages.StandardController(agmt));
        
        Pagereference pgRefr = controller.validationsOnActivate();
        system.assertEquals(null, pgRefr);
        
        //Scenario 4 - where both are correct     
        agmt.Apttus_Approval__Approval_Status__c = 'Approved';
        agmt.Apttus__Company_Signed_Date__c = Date.newinstance(2016, 7, 10);
        update agmt;
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        controller = new APTPS_CheckCompanySignedDateController (new ApexPages.StandardController(agmt));
        
        Pagereference pgRefre = controller.validationsOnActivate();
        system.assertEquals('/apex/Apttus__AgreementActivate?id='+agmt.id, pgRefre.getUrl());
        
        //Scenario 5 - when agreement id is null          
        pageRef.getParameters().put('id',null);
        System.assertEquals(null, apexpages.currentpage().getparameters().get('id'));
        
        controller = new APTPS_CheckCompanySignedDateController (new ApexPages.StandardController(agmt));
        
        Pagereference pgReferen = controller.validationsOnActivate();
        system.assertEquals(null, pgReferen);
        
        Test.stopTest();
    }
}