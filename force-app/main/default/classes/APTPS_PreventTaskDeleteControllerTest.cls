/*****************************************************************
@Name: APTPS_PreventTaskDeleteControllerTest
@Author: Ruchika Patil 
@CreateDate: 01/06/2016 
@Description: This is the Test class for APTPS_PreventTaskDeleteController
@UsedBy: APTPS_PreventTaskDeleteController
******************************************************************/ 
@isTest
public with sharing class APTPS_PreventTaskDeleteControllerTest{
    /******************************************************************
    @Description: This test method is written for the preventing task delete for running user as System Administrator and Contract Manager.
    *******************************************************************/  
    static testMethod void PreventTaskDelete(){
        Savepoint sp = Database.setSavepoint();
        try{
            
        Profile contractManager = [SELECT Id FROM Profile WHERE Name='Contract Manager']; 
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User userCM = new User(Alias = 'TestUCM', Email='testUserCM@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='UserCM', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_AU', ProfileId = contractManager.Id, CommunityNickname = 'TUCM',
        TimeZoneSidKey='Australia/Sydney', UserName='testUser3CM@testorg.com.japan');
        insert userCM;
        system.assertNotEquals(null, userCM.Id);
        
        User userSA = new User(Alias = 'TestUSA', Email='testUserSA@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='UserSA', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_AU', ProfileId = systemAdministrator.Id, CommunityNickname = 'TUSA',
        TimeZoneSidKey='Australia/Sydney', UserName='testUser3SA@testorg.com.japan');
        insert userSA;
        system.assertNotEquals(null, userSA.Id);
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
               
        Task taskCompleted = APTPS_TestClassData.taskRecord(userSA.id, agmt.id, 'Completed');
        Task taskCompleted2 = APTPS_TestClassData.taskRecord(userCM.id, agmt.id, 'Completed');
        
        PageReference pageRefer = Page.APTPS_PreventTaskDelete;
        Test.setCurrentPage(pageRefer); 
        System.assertNotEquals(null, pageRefer);
                
        Test.startTest();
        
        APTPS_PreventTaskDeleteController  controller = new APTPS_PreventTaskDeleteController (new ApexPages.StandardController(taskCompleted));
        
        pageRefer.getParameters().put('id', null);
        System.assertEquals(null, apexpages.currentpage().getparameters().get('id')); 
        controller = new APTPS_PreventTaskDeleteController (new ApexPages.StandardController(taskCompleted));
        Pagereference pg1 = controller.onDeletion();
        system.assertEquals(null, pg1);
        
        pageRefer.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id')); 
        controller = new APTPS_PreventTaskDeleteController (new ApexPages.StandardController(taskCompleted));
        Pagereference pg2 = controller.onDeletion();
        system.assertEquals(null, pg2);
        
        System.runAs(userCM){
        
            PageReference pageRef = Page.APTPS_PreventTaskDelete;
            Test.setCurrentPage(pageRef); 
            System.assertNotEquals(null, pageRef);
            
            pageRef.getParameters().put('id', taskCompleted2.id);
            System.assertEquals(taskCompleted2.id, apexpages.currentpage().getparameters().get('id'));
            
            controller = new APTPS_PreventTaskDeleteController (new ApexPages.StandardController(taskCompleted2));
            
            Pagereference pg = controller.onDeletion();
            system.assertEquals(null, pg);
            
        }
        
        System.runAs(userSA){
        
            PageReference pageRef = Page.APTPS_PreventTaskDelete;
            Test.setCurrentPage(pageRef); 
            System.assertNotEquals(null, pageRef);          
            
            pageRef.getParameters().put('id', taskCompleted.id);
            System.assertEquals(taskCompleted.id, apexpages.currentpage().getparameters().get('id'));
            
            controller = new APTPS_PreventTaskDeleteController (new ApexPages.StandardController(taskCompleted));
            
            Pagereference pgRef = controller.onDeletion();
            system.assertEquals('/'+taskCompleted.WhatId, pgRef.geturl());

        }
        
        Test.stopTest();

        }
        catch(Exception Ex) {
            Database.rollback(sp);
        }
    }
   
}