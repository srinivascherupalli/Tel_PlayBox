/*****************************************************************
@Name: APTPS_Import_UpdateIssuesTest
@Author: Ruchika Patil 
@CreateDate: 17/06/2016 
@Description: This class is the Test class for APTPS_Import_UpdateIssuesController
@UsedBy: APTPS_Import_UpdateIssuesController
******************************************************************/ 
@isTest
public with sharing class APTPS_Import_UpdateIssuesTest{
    /******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
    static testMethod void APTPS_Import_UpdateIssuesController(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Apttus_SRM__Issue__c issue1 = APTPS_TestClassData.issueRecord(agmt.id, acct.id, '0 - Inherent Risk','Not Started');          
        
        PageReference pageRef = Page.APTPS_Init_ImportUpdateIssues;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        
        Test.startTest();
        
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateIssuesController controller = new APTPS_Import_UpdateIssuesController();
        controller = new APTPS_Import_UpdateIssuesController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
        controller.importUpdateCSVFile();
        system.assertEquals('block', controller.showFileSelection);
        //Normal scenario
        List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportIssuesCSVforTestClass'];
                            
        //Checking if the result is returned or not
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        system.assertEquals('none', controller.showFileSelection);
        System.assertNotEquals(0, controller.issuesToBeInserted.size());
        System.assertNotEquals(0, controller.issuesToBeDisplayed.size());
        
        List<StaticResource> csvResource2 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportUpdateIssuesTestData1'];
                            
        //Checking if the result is returned or not
        if(csvResource2.size() == 1)
        {
            controller.csvFileBody = csvResource2[0].body;
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        //system.assertEquals('block', controller.showFileSelection);
        system.assert(controller != null);
        List<StaticResource> csvResource3 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportUpdateIssuesTestData2'];
                            
        //Checking if the result is returned or not
        if(csvResource3.size() == 1)
        {
            controller.csvFileBody = csvResource3[0].body;
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        system.assert(controller != null);
        
        PageReference cancelPageRef = controller.cancel();
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
        PageReference confirmPageRef = controller.confirm();
        
        controller.uploadNewDocument();
        //system.assertEquals('none',controller.showGrid);
        //system.assertEquals('block',controller.showFileSelection);
        system.assertEquals(0,controller.issuesToBeInserted.size());
        system.assertEquals(0,controller.issuesToBeUpdated.size());
        system.assertEquals(0,controller.issuesToBeDisplayed.size());


        //Exception scenario
        List<StaticResource> csvExceptionResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportIssuesCSVExceptionTestClass'];
                            
        //Checking if the result is returned or not
        if(csvExceptionResource.size() == 1)
        {
            controller.csvFileBody = csvExceptionResource[0].body;
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        system.assertEquals('block', controller.showFileSelection);
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());     
        
        cancelPageRef = controller.cancel();
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
        //adding an incorrect date for testing the catch block in confirm() method
        issue1.Apttus_SRM__DateEntered__c = date.newinstance(9999, 30, 30);
        
        controller.issuesToBeInserted.add(issue1);
        
        confirmPageRef = controller.confirm();
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages2.size());     
        
        controller.uploadNewDocument();
        //system.assertEquals('none',controller.showGrid);
        //system.assertEquals('block',controller.showFileSelection);
        system.assertEquals(0,controller.issuesToBeInserted.size());
        system.assertEquals(0,controller.issuesToBeUpdated.size());
        system.assertEquals(0,controller.issuesToBeDisplayed.size());
        
        Test.stopTest();
    }

}