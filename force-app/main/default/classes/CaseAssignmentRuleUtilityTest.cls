/**
* Author: Nilima Borse
* Team: Jaipur
* Sprint: 21.03
* JIRA Story: P2OB-11427
* Date: 9 March 2021
* Description: This Test class will test all test scenario of class "CaseAssignmentRuleUtility".
* Last Modified : Pallavi B ::P2OB-14635 (SFO-Sprint 21.10)  
                  Pallavi B ::DIGI-8623  (SFO-Sprint 21.11)
**/
@isTest
public class CaseAssignmentRuleUtilityTest {
	 @istest
    public static void testSyncMethod(){
        Case case1 = new case();
        case1.Status = 'New';
        case1.Subject= 'test subject';
        case1.salesup_Routing_Enabled__c = true;
        List<case> ListCase = new List<Case>();
        ListCase.add(case1);
        ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = blob.valueof('Test Content Data'),
                IsMajorVersion = true);
            insert cv;
            
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            Map<ID,ContentDocument> documents = new Map<ID,ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);
        	
		List<id> fileIds = new List<id>();
        fileIds.addAll(documents.keySet());
        CaseAssignmentRuleUtility.ScreenInputs screenInput = new CaseAssignmentRuleUtility.ScreenInputs();
        screenInput.isSynchronus = true;
        screenInput.lstCase = ListCase; 
        screenInput.lstFileIds = fileIds;
        screenInput.attachFilestoOpportunity = False;// Added as part of DIGI-8623  (SFO-Sprint 21.11)
        List<CaseAssignmentRuleUtility.ScreenInputs> lstScreenInputs = new List<CaseAssignmentRuleUtility.ScreenInputs>();
        lstScreenInputs.add(screenInput);
        List<CaseAssignmentRuleUtility.ScreenOutputs> strList = CaseAssignmentRuleUtility.processCaseCreation(lstScreenInputs);
        system.assertEquals(strList.size(), 1);
        
 	}
    
     @istest
    public static void testAsyncMethod(){
        Case case1 = new case();
        case1.Status = 'New';
        case1.Subject= 'test subject';
        case1.salesup_Routing_Enabled__c = true;
        List<case> ListCase = new List<Case>();
        ListCase.add(case1);
        CaseAssignmentRuleUtility.ScreenInputs screenInput = new CaseAssignmentRuleUtility.ScreenInputs();
        screenInput.isSynchronus = false;
        screenInput.lstCase = ListCase; 
        screenInput.attachFilestoOpportunity = False;// Added as part of DIGI-8623  (SFO-Sprint 21.11)
        List<CaseAssignmentRuleUtility.ScreenInputs> lstScreenInputs = new List<CaseAssignmentRuleUtility.ScreenInputs>();
        lstScreenInputs.add(screenInput);
        List<CaseAssignmentRuleUtility.ScreenOutputs> strList = CaseAssignmentRuleUtility.processCaseCreation(lstScreenInputs);
        system.assertEquals(strList.size(), 1);
        
 	}
   
/*******************************************************************
@Class Name         :   CaseAssignmentRuleUtilityTest
@Sprint             :   21.10 & P2OB-14635
@Author         	:   SFO Team (Pallavi B) 
@CreateDate     	:   27/07/2021
@Description    	:   Provides Code Coverage When Attaching files to opporunity
*********************************************************************/
    @istest
        public static void testAttachmentsOnOpty(){
           
            Account customerAccount=TestUtil.createAccount('Test Account');
            insert customerAccount;
            Opportunity Opp =TestUtil.createOpportunity(customerAccount.Id);
            Opp.Name='standard opportunity';
            Opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
            Opp.Type = 'Renewal';
            Opp.Billing_Solution__c = 'Standard';
            Opp.Product_Domain__c = 'CLOUD SERVICES';
            Opp.Product_Type__c = 'Non Modular'; 
            Test.startTest();
            insert Opp; 
            Case case1 = new case();
            case1.Status = 'New';
            case1.OpportunityId__c=opp.Id; // Added as part of DIGI-8623  (SFO-Sprint 21.11)
            case1.Subject= 'test subject';
            case1.recordtypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.label.CaseEnterprisePricing_RecordTypeApiName).getRecordTypeId();
            case1.salesup_Routing_Enabled__c = true;
            List<case> ListCase = new List<Case>();
            ListCase.add(case1);
            ContentVersion cv = new ContentVersion(
                    Title = 'Test',
                    PathOnClient = 'Test11.jpg',
                    VersionData = blob.valueof('Test Content Data'),
                    IsMajorVersion = true);
                insert cv;
          
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            Map<ID,ContentDocument> documents = new Map<ID,ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);
            List<id> fileIds = new List<id>();
            fileIds.addAll(documents.keySet());
            CaseAssignmentRuleUtility.ScreenInputs screenInput = new CaseAssignmentRuleUtility.ScreenInputs();
            screenInput.isSynchronus = true;
            screenInput.lstCase = ListCase; 
            screenInput.lstFileIds = fileIds;
            screenInput.attachFilestoOpportunity = True; // Added as part of DIGI-8623  (SFO-Sprint 21.11)
            List<CaseAssignmentRuleUtility.ScreenInputs> lstScreenInputs = new List<CaseAssignmentRuleUtility.ScreenInputs>();
            lstScreenInputs.add(screenInput);
              Test.stopTest();
            List<CaseAssignmentRuleUtility.ScreenOutputs> strList = CaseAssignmentRuleUtility.processCaseCreation(lstScreenInputs);
            system.assertEquals(strList.size(), 1);
        }
        
}