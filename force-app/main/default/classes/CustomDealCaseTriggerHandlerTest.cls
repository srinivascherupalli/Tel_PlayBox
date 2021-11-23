/************************************************************ 
* @createdBy   - Shreyansh Sharma
* @team         - JAIPUR
* @jirastoryRef - P2OB-3854
* @description: Test Class to validate CustomDealCaseTriggerHandler class
* @update: Shreyansh Sharma/P2OB-11801/Removing bid obj from custom deal module
******************************************************************/
@isTest
public class CustomDealCaseTriggerHandlerTest {
    //method to check bid status set to Pending ERB
    static testMethod void checkCaseBidStatusPendingERB(){
        Account customerAccount=new Account(Name='acc',Customer_Status__c='ACTIVE');
        insert customerAccount;        
        opportunity opp = soc_TestUtility.CreateOpportunity();
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.AccountId =  customerAccount.id;
        caseObj.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('cusdl_Custom_Deal').RecordTypeId;
        caseObj.OpportunityId__c = opp.Id;
        insert caseObj;
        
        caseObj.cusdl_Bid_Status__c = 'Pending ERB Approval';
        update caseObj;
        case cs = [select AccountId,Stage__c,id FROM Case WHERE AccountId=:customerAccount.id];
        system.assertEquals('ORB Solution Review',cs.Stage__c);
    }
    
    //method to check bid status set to Closed
    static testMethod void checkCaseStatusClosed(){
        Account customerAccount=new Account(Name='acc',Customer_Status__c='ACTIVE');
        insert customerAccount;
        opportunity opp = soc_TestUtility.CreateOpportunity();
        Case caseObj = new Case();
        caseObj.AccountId =  customerAccount.id;
        caseObj.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('cusdl_Custom_Deal').RecordTypeId;
        caseObj.OpportunityId__c = opp.Id;
        insert caseObj;
        
        caseObj.Status = 'Closed';
        update caseObj;
        
        case cs = [select AccountId,soc_SFD_Sub_Status__c,id FROM Case WHERE AccountId=:customerAccount.id];
        system.assertEquals('Work Completed',cs.soc_SFD_Sub_Status__c);
    }
    //Added for code coverage
}