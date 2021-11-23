/*****************************************************************
@Name: APTPS_RelatedCompaniesControllerTest
@Author: Ruchika Patil 
@CreateDate: 30/05/2016 
@Description: This is the Test class for APTPS_RelatedCompaniesController
@UsedBy: APTPS_RelatedCompaniesController
******************************************************************/ 
@isTest
public with sharing class APTPS_RelatedCompaniesControllerTest{
    /******************************************************************
    @Description: This test method is for scenario where Account on Agreement has Related as well as unrelated Accounts.
    *******************************************************************/  
    static testMethod void RelatedCompaniesController(){
        PageReference pageRef = Page.APTPS_RelatedCompanies;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        
        List<Account> relAccountList = new List<Account>();
        Account grandparentAcct = APTPS_TestClassData.accountRecord('Grand parent Account', '1234567890');
        relAccountList.add(grandparentAcct);
        Account parentAcct = APTPS_TestClassData.accountParent('Parent Account', '1234567898', grandparentAcct.id);
        relAccountList.add(parentAcct);
        Account acct = APTPS_TestClassData.accountParent('Main Account', '1237778898', parentAcct.id);
        relAccountList.add(acct);
        Account childAcct = APTPS_TestClassData.accountParent('Child Account', '1237878898', acct.id);
        relAccountList.add(childAcct);
        Account grandchildAcct = APTPS_TestClassData.accountParent('Grand child Account', '1237478898', childAcct.id);
        relAccountList.add(grandchildAcct);
        Account siblingAcctA = APTPS_TestClassData.accountParent('Sibling Account A', '1230088998', parentAcct.id);
        relAccountList.add(siblingAcctA);
        Account siblingAcctB = APTPS_TestClassData.accountParent('Sibling Account B', '1232778898', parentAcct.id);
        relAccountList.add(siblingAcctB);
        System.assertNotEquals(0, relAccountList.size());
        
        List<Account> unrelAccountList = new List<Account>();
        Account unrelatedAcctA = APTPS_TestClassData.accountRecord('Unrelated Account A', '1424567890');
        unrelAccountList.add(unrelatedAcctA);
        Account unrelatedAcctB = APTPS_TestClassData.accountRecord('Unrelated Account B', '1424777890');
        unrelAccountList.add(unrelatedAcctB);
        System.assertNotEquals(0, unrelAccountList.size());

        Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        agmt.Apttus__Agreement_Category__c ='Business Services';
        agmt.APTPS_Agreement_Subcategory__c ='Company Group';
        agmt.APTPS_Unrelated_Companies__c = True;
        agmt.RecordTypeId = saRecordTypeId;
        update agmt;
        
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        Apttus__APTS_Agreement__c agmtSiblingAcc = APTPS_TestClassData.agreementRecord(siblingAcctB.id);
        
        List<APTPS_Related_Companies__c> relComList = new List<APTPS_Related_Companies__c>();
        relComList.add(APTPS_TestClassData.relatedCompaniesRecord(acct.id, agmt.id));
        relComList.add(APTPS_TestClassData.relatedCompaniesRecord(siblingAcctB.id, agmtSiblingAcc.id));
        System.assertNotEquals(0, relComList.size());
        
        Test.startTest();
        
        APTPS_RelatedCompaniesController controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        
        pageRef.getparameters().put('alpha','A');
        System.assertEquals('A', apexpages.currentpage().getparameters().get('alpha'));
        controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        
        string noAlpha = null;
        pageRef.getparameters().put('alpha', noAlpha);
        System.assertEquals(null, apexpages.currentpage().getparameters().get('alpha'));
        controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        String whereQuery = controller.buildWhere(null);
        //System.assertNotEquals('', whereQuery);
        
        pageRef.getparameters().put('alpha','Other');
        System.assertEquals('Other', apexpages.currentpage().getparameters().get('alpha'));
        controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        
        Id agreementId = controller.getagreementId();
        System.assertEquals(agreementId, agmt.id);
        
        controller.fetchRelatedAccounts();
        
        List<Account> childAccountList = APTPS_RelatedCompaniesController.getAllChildAccounts(acct.id);
        System.assertNotEquals(0, childAccountList.size());
        
        APTPS_RelatedCompaniesController.addChildAccountsToList(acct.id);
        
        Pagereference pg = controller.insertRelatedCompanies();
        System.assertEquals(null , pg);
        
        APTPS_RelatedCompaniesWrapper relWrapper = APTPS_TestClassData.wrapperRecord(true, parentAcct);
        controller.relAccWrapperList.add(relWrapper);
        System.assertNotEquals(0, controller.relAccWrapperList.size());
        
        APTPS_RelatedCompaniesWrapper unrelWrapper = APTPS_TestClassData.wrapperRecord(true, unrelatedAcctA);
        controller.unrelAccWrapperList.add(unrelWrapper);
        System.assertNotEquals(0, controller.unrelAccWrapperList.size());
        
        pg = controller.insertRelatedCompanies();
        System.assertEquals('/'+agreementId, pg.getUrl());
        
        ApexPages.StandardSetController setconRCTest = controller.setConRC;
        System.assertEquals(0, controller.setConRC.getRecords().size());
        ApexPages.StandardSetController setconUCTest = controller.setConUC;
        System.assertEquals(0, controller.setConRC.getRecords().size());
        
        Boolean totalRCrecords = controller.getRCrecordsFound();
        System.assertEquals(true, totalRCrecords);
        Boolean totalUCrecords = controller.getUCrecordsFound();
        System.assertEquals(true, totalUCrecords);
        
        List<APTPS_RelatedCompaniesWrapper> currentRCWrapList = controller.getCurrentRCAccountList();
        System.assertEquals(0, currentRCWrapList.size());
        List<APTPS_RelatedCompaniesWrapper> currentUCWrapList = controller.getCurrentUCAccountList();
        System.assertEquals(0, currentUCWrapList.size());
        
        controller.setConRC = new ApexPages.StandardSetController(relAccountList);
        System.assertNotEquals(0, controller.setConRC.getRecords().size());
        controller.setConUC = new ApexPages.StandardSetController(unrelAccountList);
        System.assertNotEquals(0, controller.setConUC.getRecords().size());
        
        Boolean totalRCrecordsA = controller.getRCrecordsFound();
        System.assertEquals(false, totalRCrecordsA);
        Boolean totalUCrecordsA = controller.getUCrecordsFound();
        System.assertEquals(false, totalUCrecordsA);
        
        List<APTPS_RelatedCompaniesWrapper> currentRCWrapListA = controller.getCurrentRCAccountList();
        System.assertNotEquals(0, currentRCWrapListA.size());
        List<APTPS_RelatedCompaniesWrapper> currentUCWrapListA = controller.getCurrentUCAccountList();
        System.assertNotEquals(0, currentUCWrapListA.size());
        
        controller.RecPerPageRC = 25;
        controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));   
        
        Test.stopTest();
    }
    /******************************************************************
    @Description: This test method is for scenario where Account on Agreement has no Related or unrelated Accounts.
    *******************************************************************/  
    static testMethod void noRelatedUnrelatedAccount(){
        PageReference pageRef = Page.APTPS_RelatedCompanies;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        agmt.Apttus__Agreement_Category__c ='Business Services';
        agmt.APTPS_Agreement_Subcategory__c ='Company Group';
        agmt.APTPS_Unrelated_Companies__c = True;
        agmt.RecordTypeId = saRecordTypeId;
        update agmt;
                
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        List<APTPS_Related_Companies__c> relComList = new List<APTPS_Related_Companies__c>();
        System.assertEquals(0, relComList.size());
        
        Test.startTest();
        
        APTPS_RelatedCompaniesController controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        
        Id agreementId = controller.getagreementId();
        System.assertEquals(agreementId, agmt.id);
        controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        
        controller.fetchRelatedAccounts();
        
        Set<Account> childAccountSet = new Set<Account>();
        childAccountSet.addAll(APTPS_RelatedCompaniesController.getAllChildAccounts(acct.id));
        System.assertEquals(1, childAccountSet.size());
        
        APTPS_RelatedCompaniesController.addChildAccountsToList(acct.id);
        
        Pagereference pg = controller.insertRelatedCompanies();
        System.assertEquals(null , pg);
        
        ApexPages.StandardSetController setconRCTest = controller.setConRC;
        System.assertEquals(0, controller.setConRC.getRecords().size());
        ApexPages.StandardSetController setconUCTest = controller.setConUC;
        System.assertEquals(0, controller.setConRC.getRecords().size());
        
        Boolean totalRCrecords = controller.getRCrecordsFound();
        System.assertEquals(true, totalRCrecords);
        Boolean totalUCrecords = controller.getUCrecordsFound();
        System.assertEquals(true, totalUCrecords);
        
        List<APTPS_RelatedCompaniesWrapper> currentRCWrapList = controller.getCurrentRCAccountList();
        System.assertEquals(0, currentRCWrapList.size());
        List<APTPS_RelatedCompaniesWrapper> currentUCWrapList = controller.getCurrentUCAccountList();
        System.assertEquals(0, currentUCWrapList.size());
        
        controller.getSortDirection();
        controller.setSortDirection('test');
        controller.getUCsectionMoreThanFiveK1();
        Test.stopTest();
        
    }


  static testMethod void noRelatedUnrelatedAccountTest(){
        PageReference pageRef = Page.APTPS_RelatedCompanies;
        Test.setCurrentPage(pageRef); 
        System.assertNotEquals(null, pageRef);
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Id stRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Service Trial').getRecordTypeId();
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acct.id);
        agmt.Apttus__Agreement_Category__c ='Managed Services';
        agmt.APTPS_Agreement_Subcategory__c ='Company Group';
        //agmt.APTPS_Unrelated_Companies__c = True;
        agmt.RecordTypeId = stRecordTypeId;
        update agmt;
                
        pageRef.getParameters().put('id', agmt.id);
        System.assertEquals(agmt.id, apexpages.currentpage().getparameters().get('id'));
        
        List<APTPS_Related_Companies__c> relComList = new List<APTPS_Related_Companies__c>();
        System.assertEquals(0, relComList.size());
        
        Test.startTest();
        
        APTPS_RelatedCompaniesController controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        
        Id agreementId = controller.getagreementId();
        System.assertEquals(agreementId, agmt.id);
        controller = new APTPS_RelatedCompaniesController(new ApexPages.StandardSetController(relComList));
        
        controller.fetchRelatedAccounts();
      Set<Account> childAccountSet = new Set<Account>();
        childAccountSet.addAll(APTPS_RelatedCompaniesController.getAllChildAccounts(acct.id));
        System.assertEquals(1, childAccountSet.size());
        
        APTPS_RelatedCompaniesController.addChildAccountsToList(acct.id);
        
        Pagereference pg = controller.insertRelatedCompanies();
        System.assertEquals(null , pg);
        
       Test.stopTest();
  }
}