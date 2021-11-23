/*****************************************************************************
@Author: Sandeep Soni
@CreateDate: 06/09/2019
@ModifiedByandDate: 
@Description: This Class is created to cover the test coverage
Story Number: P2OB:931
salesup_CaseClosedCSATSurvey = 94%
*******************************************************************************/
@isTest(seeAllData=false)
public Without Sharing class salesup_CaseClosedCSATSurveyTest {
    
    /*For creating testdata*/
    @testSetup
    static void createTestData() {
        List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
        //P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
        Account customerAccount=TestUtil.createAccount('Testacc');
        insert customerAccount;
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.AccountId =customerAccount.id;//P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
        caseObj.OpportunityId__c = oppLine[0].OpportunityId;
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();    
        insert caseObj; 
        
    }
    /*For positive test case scenario*/
    static testMethod void invokeSurveyFlowsPositiveTest() {
        List<Case> lstCase = [SELECT ID FROM Case];
        lstCase.get(0).status='Closed';
        update lstCase; 
        Test.startTest();
        salesup_CaseClosedCSATSurvey.invokeSurveyFlows(lstCase);
        Test.stopTest();
        System.assert(lstCase.get(0).status=='Closed');
    }
    /*For negative test case scenario*/
    static testMethod void invokeSurveyFlowsNegativeTest() {
        List<Case> lstCase = new List<Case>();
        Test.startTest();
        salesup_CaseClosedCSATSurvey.invokeSurveyFlows(lstCase);
        Test.stopTest();
        System.assert(lstCase.size()<1);
    }
}