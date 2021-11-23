/**
* Author: Karan jugtawat
* Team: Jaipur
* Sprint: 20.12
* JIRA Story: P2OB-8990
* Date: 29 Aug 2020 
* Description : This Test class will test all test scenario of class "CaseAssignmentRuleHandler".
**/
@isTest
public class CaseAssignmentRuleHandlerTest {
 
    @istest
    public static void MethodOne(){
        Case case1 = new case();
        case1.Status = 'New';
        case1.Subject= 'test subject';
        case1.salesup_Routing_Enabled__c = true;
        List<case> ListCase = new List<Case>();
        //Testing Empty senerio
        CaseAssignmentRuleHandler.processCaseCreation(ListCase);
        ListCase.add(case1);
        //Testing positive senerio
        System.assertEquals(CaseAssignmentRuleHandler.processCaseCreation(ListCase).get(0).contains('Error'), false);
        //test Error(Negteive) senerio
        System.assertEquals(CaseAssignmentRuleHandler.processCaseCreation(ListCase).get(0).contains('Error'), true);
    }
    
    @istest
    public static void testCbs(){
        Account acct = new Account(Name='Acme corp', Customer_Status__c='ACTIVE');
        insert acct;
         Opportunity testOpp = new Opportunity();
        testOpp.Account = acct;
        testOpp.AccountId = acct.Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Qualify';
        testOpp.BidStatus__c = 'Bid Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.Proposal_Required_Date__c = System.Date.today();
        insert testOpp;
            ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = blob.valueof('Test Content Data'),
                IsMajorVersion = true);
            insert cv;
            
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            

            System.assertEquals(documents.size(), 1);
        test.startTest();
        String cbsRecordtypeid  = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('CBS').RecordTypeId;
        
        Case case1 = new case();
        case1.Status = 'New';
        case1.Subject= 'test subject';
        case1.RecordTypeId = cbsRecordtypeid;
        case1.srvsup_Categories__c = 'Billing Solution Contract Implementation';
        case1.salesup_Routing_Enabled__c = true;
        case1.OpportunityId__c = testOpp.id;
        
        Case case2 = new case();
        case2.Status = 'New';
        case2.Subject= 'test subject';
        case2.RecordTypeId = cbsRecordtypeid;
        case2.srvsup_Categories__c = 'Billing Solution Design';
        case2.salesup_Routing_Enabled__c = true;
        case2.OpportunityId__c = testOpp.id;
        insert case2;
        
        List<case> ListCase = new List<Case>();
        
        ListCase.add(case1);
        CaseAssignmentHandler.ScreenInputs screenInput = new CaseAssignmentHandler.ScreenInputs();
        screenInput.isSynchronus = false;
        screenInput.lstCase = ListCase;   
        List<CaseAssignmentHandler.ScreenInputs> lstScreenInputs = new List<CaseAssignmentHandler.ScreenInputs>();
        lstScreenInputs.add(screenInput);
        List<string> strList = CaseAssignmentHandler.processCaseCreation(lstScreenInputs);
        system.assertEquals(strList.size(), 1);
        test.stopTest();
       
    }
   
    @istest
    public static void cbsTestSync(){
        Case case1 = new case();
        case1.Status = 'New';
        case1.Subject= 'test subject';
        case1.salesup_Routing_Enabled__c = true;
        List<case> ListCase = new List<Case>();
        ListCase.add(case1);
        CaseAssignmentHandler.ScreenInputs screenInput = new CaseAssignmentHandler.ScreenInputs();
        screenInput.isSynchronus = true;
        screenInput.lstCase = ListCase;   
        List<CaseAssignmentHandler.ScreenInputs> lstScreenInputs = new List<CaseAssignmentHandler.ScreenInputs>();
        lstScreenInputs.add(screenInput);
        List<string> strList = CaseAssignmentHandler.processCaseCreation(lstScreenInputs);
        system.assertEquals(strList.size(), 1);
        
    }
    
    @istest
    public static void CaseAssignmentRuleUtilityTest(){
        Case case1 = new case();
        case1.Status = 'New';
        case1.Subject= 'test subject';
        case1.salesup_Routing_Enabled__c = true;
        List<case> ListCase = new List<Case>();
        ListCase.add(case1);
        CaseAssignmentRuleUtility.ScreenInputs screenInput = new CaseAssignmentRuleUtility.ScreenInputs();
        screenInput.isSynchronus = true;
        screenInput.lstCase = ListCase;   
        List<CaseAssignmentRuleUtility.ScreenInputs> lstScreenInputs = new List<CaseAssignmentRuleUtility.ScreenInputs>();
        lstScreenInputs.add(screenInput);
        List<CaseAssignmentRuleUtility.ScreenOutputs> lstScreenOutputs = CaseAssignmentRuleUtility.processCaseCreation(lstScreenInputs);
        system.assertEquals(lstScreenOutputs.size(), 1);
        
    }
}