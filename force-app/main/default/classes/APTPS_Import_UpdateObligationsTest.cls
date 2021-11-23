/*****************************************************************
@Name: APTPS_Import_UpdateObligationsTest
@Author: Ruchika Patil 
@CreateDate: 01/06/2016 
@Description: This class is the Test class for APTPS_Import_UpdateObligationsController
@UsedBy: APTPS_Import_UpdateObligationsController
******************************************************************/ 
@isTest
public with sharing class APTPS_Import_UpdateObligationsTest{
    /******************************************************************
    @Description:This method created a single Account record.
    *******************************************************************/ 
    static testMethod void APTPS_Import_UpdateObligationsController(){
        Savepoint sp = Database.setSavepoint();
        try{
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
            
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
            
        Apttus_SRM__SRMObligation__c obligationRecord1 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
           
        Apttus_SRM__SRMObligation__c obligationRecord2 = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
            
        Profile userProfile = [select Id, Name from profile where Name ='System Administrator'];
        User sysUser = APTPS_TestClassData.userRecord(userProfile.Id, 'test');
              
        Task taskRecord1 = APTPS_TestClassData.taskRecord(sysUser.Id, obligationRecord2.Id, 'Not Started');
       
            
        Apttus_SRM__SRMObligation__c obg =  [select Id, Name from Apttus_SRM__SRMObligation__c where id =:obligationRecord1.id limit 1];                                    
              
        PageReference pageRef = Page.APTPS_Init_ImportObligations;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
       
        Test.startTest();
           
        obligationRecord2.APTPS_Status__c = 'Open';
        //obligationRecord2.APTPS_Due_Date__c=Date.newInstance(2018, 12, 9);
           
        update obligationRecord2;
           
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_Import_UpdateObligationsController controller = new APTPS_Import_UpdateObligationsController();
        controller = new APTPS_Import_UpdateObligationsController(stdCon);
        system.assertEquals(agmt.id, controller.parentAgreement.Id);
        system.assertEquals(agmt.name, controller.agreementName);
        
        controller.importUpdateCSVFile();
        system.assertEquals('block', controller.showFileSelection);
        //Normal scenario
        List<StaticResource> csvResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportObligationsCSVforTestClass'];
                          
        //Checking if the result is returned or not
        if(csvResource.size() == 1)
        {
            controller.csvFileBody = csvResource[0].body;
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        system.assertEquals('none', controller.showFileSelection);
        System.assertEquals(0, controller.obligationsToBeUpdated.size());
        System.assertNotEquals(0, controller.obligationsToBeDisplayed.size());
        
        
        PageReference cancelPageRef = controller.cancel();
        
        system.assertEquals('/'+controller.parentAgreement.Id, cancelPageRef.getUrl());
        
        PageReference confirmPageRef = controller.confirm();
        
        controller.uploadNewDocument();
        system.assertEquals('none',controller.showGrid);
        system.assertEquals('block',controller.showFileSelection);
        system.assertEquals(0,controller.obligationsToBeInserted.size());
        system.assertEquals(0,controller.obligationsToBeUpdated.size());
        system.assertEquals(0,controller.obligationsToBeDisplayed.size());
        
        List<StaticResource> csvResource2 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportUpdateObligationsTestData1'];
                             
        //Checking if the result is returned or not
        if(csvResource2.size() == 1)
        {
            controller.csvFileBody = csvResource2[0].body;
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        system.assertEquals('block', controller.showFileSelection);
        
        List<StaticResource> csvResource3 = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportUpdateObligationsTestData2'];
                           
        //Checking if the result is returned or not
        if(csvResource3.size() == 1)
        {
            controller.csvFileBody = csvResource3[0].body;
            controller.csvAsString = controller.csvFileBody.toString();
        }
        controller.importUpdateCSVFile();
        system.assertEquals('none', controller.showFileSelection);

        //Exception scenario
        List<StaticResource> csvExceptionResource = [SELECT Name, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name = 'APTPS_ImportObligationsCSVExceptionTestClass'];
                           
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
        obligationRecord1.APTPS_Due_Date__c = date.newinstance(9999, 30, 30);
        
        controller.obligationsToBeInserted.add(obligationRecord1);
        
        confirmPageRef = controller.confirm();
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages2.size());     
        
        controller.uploadNewDocument();
        system.assertEquals('none',controller.showGrid);
        system.assertEquals('block',controller.showFileSelection);
        system.assertEquals(0,controller.obligationsToBeInserted.size());
        system.assertEquals(0,controller.obligationsToBeUpdated.size());
        system.assertEquals(0,controller.obligationsToBeDisplayed.size());
        
        Test.stopTest();
    }catch (Exception ex) {
        Database.rollback(sp);
    }
    }
}