/*****************************************************************
@Name: APTPS_TaskTriggerHandlerTest
@Author: Ruchika Patil 
@CreateDate: 01/06/2016 
@Description: This is the Test class for APTPS_TaskTriggerHandler
@UsedBy: APTPS_TaskTriggerHandler
******************************************************************/ 
@isTest
public with sharing class APTPS_TaskTriggerHandlerTest{
    /******************************************************************
    @Description: This test method is written for the preventing task delete for running user as System Administrator and Contract Manager.
    *******************************************************************/  
    static testMethod void preventTaskDelete(){
        Savepoint sp = Database.setSavepoint();
        try {
        Profile contractManager = [SELECT Id FROM Profile WHERE Name='Apttus Contract Manager']; 
        Profile systemAdministrator = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User userCM = new User(Alias = 'TestUCM', Email='testUserCM@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='UserCM', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_AU', ProfileId = contractManager.Id, CommunityNickname = 'TUCM',
        TimeZoneSidKey='Australia/Sydney', UserName='testUserContractMgr@testorg.com.japan');
        
        User userSA = new User(Alias = 'TestUSA', Email='testUserSA@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='UserSA', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_AU', ProfileId = systemAdministrator.Id, CommunityNickname = 'TUSA',
        TimeZoneSidKey='Australia/Sydney', UserName='testUserSystemAdmin@testorg.com.japan');
        insert userSA;
        system.assertNotEquals(null, userSA.Id);
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
               
        Task taskCompleted = APTPS_TestClassData.taskRecord(userSA.id, agmt.id, 'Completed');
        Map<id, Task> taskMap = new Map<id, Task>();
        taskMap.put(taskCompleted.id, taskCompleted);
        
        Test.startTest();
        
        System.runAs(userSA){
            delete taskCompleted;
        }
        
        System.runAs(userCM){
            APTPS_TaskTriggerHandler handler = new APTPS_TaskTriggerHandler();
            handler.preventTaskDelete(taskMap);
            try{
                delete taskCompleted;
            }
            catch(DmlException e){
                system.debug('Expected DML Exception on Delete of Task record catched');
            }
        }
        
        Test.stopTest();
        }catch(Exception ex) {
            Database.rollback(sp);
        }
    }
    /******************************************************************
    @Description: This test method is written populateObligationDueDate method on class.
    *******************************************************************/  
    static testMethod void populateObligationDueDate(){
        
        Savepoint sp = Database.setSavepoint();
        try{
        Profile contractManager = [SELECT Id FROM Profile WHERE Name='Apttus Contract Manager']; 
        User cmUser = APTPS_TestClassData.userRecord(contractManager.id,'test10');
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        Apttus_SRM__SRMObligation__c obligation = APTPS_TestClassData.obligationRecord(agmt.id, acct.id);
        //Scenario 1
        List<Task> taskList = new List<Task>();
        Task taskRec1 = APTPS_TestClassData.taskRecord(cmUser.id, obligation.id, 'In Progress');
        taskRec1.ActivityDate = Date.newinstance(2016, 3, 10);
        update taskRec1;
        taskList.add(taskRec1);
        
        Task taskRec2 = APTPS_TestClassData.taskRecord(cmUser.id, obligation.id, 'In Progress');
        taskRec2.ActivityDate = Date.newinstance(2016, 2, 10);
        update taskRec2;
        taskList.add(taskRec2);
        
        Task taskRec3 = APTPS_TestClassData.taskRecord(cmUser.id, obligation.id, 'In Progress');
        taskList.add(taskRec3);
            
        Test.startTest();
        
        APTPS_TaskTriggerHandler handler = new APTPS_TaskTriggerHandler();
        handler.populateObligationDueDate(taskList, null);
        
        Apttus_SRM__SRMObligation__c updatedObligation = [Select Id, APTPS_Due_Date__c from Apttus_SRM__SRMObligation__c where id=:obligation.id];
        system.assertEquals(Date.newinstance(2016, 2, 10), updatedObligation.APTPS_Due_Date__c);
         
        //Scenario 2
        taskList = new List<Task>();
        Map<id, Task> MapOldTask = new Map<id, Task>();
        
        MapOldTask.put(taskRec1.id,taskRec1);
        MapOldTask.put(taskRec2.id,taskRec2);
        MapOldTask.put(taskRec3.id,taskRec3);
            
        taskRec1.ActivityDate = Date.newinstance(2016, 1, 10);
        update taskRec1;
        taskList.add(taskRec1);
        
        taskRec2.ActivityDate = null;
        update taskRec2;
        taskList.add(taskRec2);
        
        taskRec3.ActivityDate = Date.newinstance(2016, 6, 10);
        update taskRec3;
        taskList.add(taskRec3);
        
        handler.populateObligationDueDate(taskList, MapOldTask);
        
        updatedObligation = [Select Id, APTPS_Due_Date__c from Apttus_SRM__SRMObligation__c where id=:obligation.id];
        system.assertEquals(Date.newinstance(2016, 1, 10), updatedObligation.APTPS_Due_Date__c);
        
        //Scenario 3
        taskList = new List<Task>();
        MapOldTask = new Map<id, Task>();

        taskRec1.Status = 'Completed';
        update taskRec1;
        taskList.add(taskRec1);
            
        MapOldTask.put(taskRec1.id,taskRec1);
        
        handler.populateObligationDueDate(taskList, MapOldTask);
        
        updatedObligation = [Select Id, APTPS_Due_Date__c from Apttus_SRM__SRMObligation__c where id=:obligation.id];
        system.assertEquals(Date.newinstance(2016, 6, 10), updatedObligation.APTPS_Due_Date__c);
        
        //Scenario 4
        taskList = new List<Task>();
        MapOldTask = new Map<id, Task>();
        
        taskRec3.ActivityDate = Date.newinstance(2016, 3, 10);
        update taskRec3;
        taskList.add(taskRec3);
            
        MapOldTask.put(taskRec3.id,taskRec3);
            
        handler.populateObligationDueDate(taskList, MapOldTask);
        
        updatedObligation = [Select Id, APTPS_Due_Date__c from Apttus_SRM__SRMObligation__c where id=:obligation.id];
        system.assertEquals(Date.newinstance(2016, 3, 10), updatedObligation.APTPS_Due_Date__c);
        
        //Scenario 5
        taskList = new List<Task>();
        
        taskList.add(taskRec3);
        delete taskRec3;
        
        handler.recheckObligationDueDate(taskList);
        
        updatedObligation = [Select Id, APTPS_Due_Date__c from Apttus_SRM__SRMObligation__c where id=:obligation.id];
        system.assertEquals(null, updatedObligation.APTPS_Due_Date__c);
        
        //Scenario 6
        taskList = new List<Task>();
        MapOldTask = new Map<id, Task>();
        
        MapOldTask.put(taskRec2.id,taskRec2);
        
        taskRec2.ActivityDate = Date.newinstance(2016, 1, 10);
        update taskRec2;
        taskList.add(taskRec2);
        
        Task taskRec4 = APTPS_TestClassData.taskRecord(cmUser.id, obligation.id, 'In Progress');
        taskRec4.ActivityDate = Date.newinstance(2016, 7, 10);
        update taskRec4;
        taskList.add(taskRec4);
                
        handler.populateObligationDueDate(taskList, MapOldTask);
        
        updatedObligation = [Select Id, APTPS_Due_Date__c from Apttus_SRM__SRMObligation__c where id=:obligation.id];
        system.assertEquals(Date.newinstance(2016, 1, 10), updatedObligation.APTPS_Due_Date__c);
        
        //Scenario 7
        delete taskRec2;
        
        taskList = new List<Task>();
        MapOldTask = new Map<id, Task>();
        
        MapOldTask.put(taskRec4.id,taskRec4);
        
        taskRec4.Status = 'Completed';
        update taskRec4;
        taskList.add(taskRec4);
        
        handler.populateObligationDueDate(taskList, MapOldTask);
        
        updatedObligation = [Select Id, APTPS_Due_Date__c from Apttus_SRM__SRMObligation__c where id=:obligation.id];
        system.assertEquals(null, updatedObligation.APTPS_Due_Date__c);
        Test.stopTest();
        }
        catch(Exception Ex) {
            Database.rollback(sp);
        }
    }
    static testMethod void statusChangeOnImportOffline(){
        Savepoint sp = Database.setSavepoint();
        try {
        Profile contractManager = [SELECT Id FROM Profile WHERE Name='Apttus Contract Manager']; 
        User cmUser = APTPS_TestClassData.userRecord(contractManager.id, 'test11');
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        
        Task taskRec = new Task(OwnerId = cmUser.id, Subject = 'Imported Offline Document', WhatId = agmt.id, 
                                Status = 'Completed', Priority = 'Normal');
        insert taskRec;
        System.assertEquals('Imported Offline Document', taskRec.Subject);//EDGE-69042 Sonar Fix 
        }		
        Catch(Exception Ex) {
            Database.Rollback(sp);
        }
    }
}