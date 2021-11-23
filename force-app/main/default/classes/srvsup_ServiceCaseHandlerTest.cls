/*****************************************************************************
@Author: Preeti Malik
@CreateDate: 12-June-2019
@ModifiedByandDate:  Shreyansh Sharma on 23-3-2020 code fix coverage for P2OB-3669
@Description: This Test class contains Test methods for srvsup_ServiceCaseHandler. 
@References
Story:EDGE-84328 Esclations Queue and Queue Changes by Service & Sales Support Team Managers
*******************************************************************************/
@isTest(seeAllData=False)
public class srvsup_ServiceCaseHandlerTest {
    
    public static String recId_ServiceSupport = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('srvsup_Service_Support').getRecordTypeId();
    public static String recId_MobileSupportRequest = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('mm_Mobile_Support_Request').getRecordTypeId();
    public static final String CASE_STATUS_ESCALATED = 'Escalated';
    public static final String CASE_STATUS_ON_HOLD = 'On Hold';
    
    
    /**
      * This method is used to create the cases as required in the test methods.
      * @Author: Preeti Malik
      * @Date: 12-June-2019
      */
    @testSetup public static void DataSetup() {
        opportunity opp = soc_TestUtility.CreateOpportunity();
        Account acc = soc_TestUtility.CreateAccount();
         test.startTest();
        Integer NumberOfCases = 10;
        List<Case> CasesOfService = new List<Case>();
        for(Integer i=0;i<NumberOfCases;i++){
            Case CaseOfService = new Case();
            CaseOfService.Subject = 'Pending Case : '+ i;
            CaseOfService.Description = 'sdjshdks : '+ i;
            CaseOfService.OpportunityId__c = opp.id;
            CaseOfService.AccountId = acc.id;
            CaseOfService.Status = 'New';
            CaseOfService.Requestor__c = Userinfo.getUserId();
            CaseOfService.salesup_Support_Type__c = 'Disputes';
            CaseOfService.srvsup_Categories__c = 'Disputes';
            CaseOfService.salesup_Work_Required__c = 'Credit Management Dispute';
            CaseOfService.RecordTypeId = recId_ServiceSupport;
            CasesOfService.add(CaseOfService);
        }
        for(Integer i=0;i<NumberOfCases;i++){
            Case CaseOfService = new Case();
            CaseOfService.Subject = 'Escalated Case : '+ i;
            CaseOfService.Description = 'gnkfjem : '+ i;
            CaseOfService.OpportunityId__c = opp.id;
            CaseOfService.AccountId = acc.id;
            CaseOfService.Status = 'New';
            CaseOfService.Requestor__c = Userinfo.getUserId();
            CaseOfService.salesup_Support_Type__c = 'Mobile Support Requests';
            CaseOfService.srvsup_Categories__c = 'Add Services';
            CaseOfService.salesup_Work_Required__c = 'Barrings';
            CaseOfService.RecordTypeId = recId_MobileSupportRequest;
            CasesOfService.add(CaseOfService);
        }
        insert CasesOfService;
        test.stopTest();
    }
    /**
      * This method tests the positive senario by inserting and updating sales cases.
      * @Author: Preeti Malik
      * @Date: 12-June-2019
      */
    @isTest static void ServiceCase_testPositive(){
        test.startTest();
        Integer NumberOfCases = 20;
        List<Case> CasesOfService = [SELECT Id,Status FROM Case LIMIT :NumberOfCases];
        for(Case CaseOfService: CasesOfService){
            CaseOfService.Status = CASE_STATUS_ESCALATED;
        }
        update CasesOfService;
        test.stopTest();
        Case CaseOfService = [SELECT Id,Status,OwnerId FROM Case LIMIT 1];
        Group serviceEscalations = [SELECT DeveloperName,Id,Name FROM Group Where Type = 'Queue' AND DeveloperName = 'srvsup_Service_Escalations' LIMIT 1];
        system.assert(CaseOfService.OwnerId == serviceEscalations.Id);
    }
    /**
      * This method tests the negative senario by inserting and updating sales cases.
      * @Author: Preeti Malik
      * @Date: 12-June-2019
      */
    @isTest static void ServiceCase_testNegative(){
        test.startTest();
        Integer NumberOfCases = 20;
        List<Case> CasesOfService = [SELECT Id,Status FROM Case LIMIT :NumberOfCases];
        for(Case CaseOfService: CasesOfService){
            CaseOfService.Status = CASE_STATUS_ON_HOLD;
        }
        update CasesOfService;
        test.stopTest();
        Case CaseOfService = [SELECT Id,Status,OwnerId FROM Case LIMIT 1];
        Group serviceEscalations = [SELECT DeveloperName,Id,Name FROM Group Where Type = 'Queue' AND DeveloperName = 'srvsup_Service_Escalations' LIMIT 1];
        system.assert(CaseOfService.OwnerId != serviceEscalations.Id);
    }

}