/*****************************************************************************
@Author : Sanjay Thakur 
@CreateDate: 21/09/2021
@ModifiedByandDate: 
@Description:This class is used to cover the code the functionality of prm_CaseTriggerHelper.
*******************************************************************************/
@isTest
public class prm_CaseTriggerHelperTest {
	
    
    public static String recId_CustomDeal= Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();
    static testMethod void executeORBApprovalTest(){
        prm_CaseTriggerHelper.flagCase = true;
        System.debug('prm_CaseTriggerHelperTest Entry+++++++');
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE');
        insert acct;
        Opportunity optyObj = new Opportunity();
        optyObj.Account = acct;
        optyObj.AccountId = acct.Id;
        optyObj.Name = 'testOpp';
        optyObj.StageName = 'Closed Lost';
        optyObj.Proposal_Required_Date__c = System.now().addDays(30);
        oppList.add(optyObj);
        
        
        /*Opportunity optyObj1 = new Opportunity();
        optyObj1.Account = acct;
        optyObj1.AccountId = acct.Id;
        optyObj1.Name = 'testOppty';
        optyObj1.StageName = 'Closed Lost';
        optyObj1.Proposal_Required_Date__c = System.now().addDays(-30);
        oppList.add(optyObj1);*/
        //insert optyObj1;
        insert oppList;
        
        List<Case> csList = new List<Case>();
        Case caseObj = new Case();
        caseObj.OpportunityId__c = oppList[0].Id;
        caseObj.Stage__c = 'Pending ORB Approval';
        caseObj.cusdl_Approval_Board__c = 'Autogate';
        caseObj.cusdl_Bid_Status__c = 'BRM Review';
        caseObj.RecordTypeId = recId_CustomDeal;
        csList.add(caseObj);
        system.assertNotEquals(csList.size(), null);
        /*Case caseObj1 = new Case();
        caseObj1.OpportunityId__c = oppList[1].Id;
        caseObj1.Stage__c = 'Pending ORB Approval';
        caseObj1.cusdl_Approval_Board__c = 'Deal Review Board';
        caseObj1.cusdl_Bid_Status__c = 'BRM Review';
        caseObj1.RecordTypeId = recId_CustomDeal;
        csList.add(caseObj1);*/
        //system.assertNotEquals(csList.size(), null);
        insert csList;
        //insert oppList;
        //List<Case> results = prm_CaseTriggerHelper.executeORBApproval(csList);
        Test.stopTest();
    }
    static testMethod void executeORBApprovalTestNew(){
        Test.startTest();
        prm_CaseTriggerHelper.flagCase =true;
        List<Opportunity> oppListNew = new List<Opportunity>();
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE');
        insert acct;
        

        Opportunity optyObj1 = new Opportunity();
        optyObj1.Account = acct;
        optyObj1.AccountId = acct.Id;
        optyObj1.Name = 'testOppty';
        optyObj1.StageName = 'Closed Lost';
        optyObj1.Proposal_Required_Date__c = System.now().addDays(30);
        oppListNew.add(optyObj1);
        //insert optyObj1;
        insert oppListNew;
        
        
        List<Case> csListNew = new List<Case>();
        Case caseObj1 = new Case();
        caseObj1.OpportunityId__c = oppListNew[0].Id;
        caseObj1.Stage__c = 'Pending ORB Approval';
        caseObj1.cusdl_Approval_Board__c = 'Deal Review Board';
        //caseObj1.cusdl_Bid_Status__c = 'BRM Review';
        caseObj1.RecordTypeId = recId_CustomDeal;
        csListNew.add(caseObj1);
        system.assertNotEquals(csListNew.size(), null);
        insert csListNew;
        Test.stopTest();
    }
}