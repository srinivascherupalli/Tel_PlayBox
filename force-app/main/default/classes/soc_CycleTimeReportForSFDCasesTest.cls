/*****************************************************************************
@Author: Preeti Malik
@CreateDate: 04 March 2019
@ModifiedByandDate: Preeti Malik on 22 April 2020
@Description: This Test class contains Test methods for srvsup_ServiceCaseHandler. 
@References
Story:EDGE-68486 : This class captures the time taken by Detailer to close, withdraw or reject the case starting from the time the case was assigned and minus the time case was on hold.
*******************************************************************************/
@isTest
public class soc_CycleTimeReportForSFDCasesTest {
    //Creation of test data 
    public static String recId_OrderRequest=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    public static String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    
    @testSetup static void DataSetup() {
          User thisUser = [ select Id,Name from User where Profile.Name = 'System Administrator' AND isactive =true  LIMIT 1 ];
    System.runAs ( thisUser ) {
          String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'SFD Agent' LIMIT 1];
        Profile profileIdRequestor = [SELECT Id FROM Profile WHERE Name = 'Account Owner' LIMIT 1];
        Group Concierge = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'soc_SFD_Concierge_Offshore' LIMIT 1];
        Group Detailer = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'soc_SIMPLEX_Offshore_Level_1_Detail' LIMIT 1];
        User usr1 = new User(LastName = 'LIVESTON',
                               FirstName='JASON',
                               Alias = 'jliv',
                               Email = 'jason1'+uniqueName + '@test' + orgId + '.org',
                               Username = 'jason1'+uniqueName + '@test' + orgId + '.org',
                               ProfileId = profileId.id,
                               TimeZoneSidKey = 'GMT',
                               LanguageLocaleKey = 'en_US',
                               EmailEncodingKey = 'UTF-8',
                               LocaleSidKey = 'en_US'
                               );
        insert usr1;
        User usr2 = new User(LastName = 'LIVESTONE',
                               FirstName='JASONE',
                               Alias = 'jlive',
                               Email = 'jasone12'+uniqueName + '@test' + orgId + '.org',
                               Username = 'jasone12'+uniqueName + '@test' + orgId + '.org',
                               ProfileId = profileId.id,
                               TimeZoneSidKey = 'GMT',
                               LanguageLocaleKey = 'en_US',
                               EmailEncodingKey = 'UTF-8',
                               LocaleSidKey = 'en_US'
                               );
        insert usr2;
        User usr3 = new User(LastName = 'LIVESTONE',
                               FirstName='Mark',
                               Alias = 'mlive',
                               Email = 'mark'+uniqueName + '@test' + orgId + '.org',
                               Username = 'mark'+uniqueName + '@test' + orgId + '.org',
                               ProfileId = profileIdRequestor.id,
                               TimeZoneSidKey = 'GMT',
                               LanguageLocaleKey = 'en_US',
                               EmailEncodingKey = 'UTF-8',
                               LocaleSidKey = 'en_US',
                               Phone='+121231231234'
                              
                               );
        insert usr3;
        System.runAs(new User(Id=UserInfo.getUserId())){
        GroupMember member1 = new GroupMember();
        member1.UserOrGroupId = usr1.Id;
        member1.GroupId = Concierge.Id;
        insert member1;
        
     
        GroupMember member2 = new GroupMember();
        member2.UserOrGroupId = usr2.Id;
        member2.GroupId = Detailer.Id;
        insert member2;
        }
        opportunity opp = soc_TestUtility.CreateOpportunity();
        soc_SFD_Case_Business_Time__c ss = new soc_SFD_Case_Business_Time__c();
        ss.soc_SFD_Case_Acceptance_Time_Type__c='hh';
        ss.soc_SFD_Case_Acceptance_Time__c = 6;
        ss.Name = 'Case Acceptance';
        insert ss;
        soc_SFD_Case_Business_Time__c ss1 = new soc_SFD_Case_Business_Time__c();
        ss1.soc_SFD_Case_Acceptance_Time_Type__c='hh';
        ss1.soc_SFD_Case_Acceptance_Time__c = 13;
        ss1.Name = 'Case Detailing';
        insert ss1;
        Case case1 = new Case();
        case1.Subject = 'TestCase1';
        case1.OpportunityId__c = opp.id;
        case1.OwnerId = usr1.Id;
        case1.Requestor__c = usr3.Id;
        case1.RecordTypeId = recId_SFD_ProductType;
        case1.Status = 'In Progress';
        case1.Stage__c = 'Detail Order';
        insert case1;
        
        Case case2 = new Case();
        case2.Subject = 'TestCase2';
        BusinessHours lstBusinessHours = [select Id, Name, TimeZoneSidKey FROM BusinessHours WHERE isActive = true AND Name like 'SOC%'LIMIT 1];
        case2.BusinessHoursId = lstBusinessHours.Id;
        case2.OpportunityId__c = opp.id;
        case2.OwnerId = usr1.Id;
        case2.Requestor__c = usr3.Id;
        case2.RecordTypeId = recId_OrderRequest;
        case2.soc_Process_Start_Time__c = system.now();
        case2.soc_OnHold_Start_Time__c = system.now();
        case2.Stage__c = 'Detail Order';
        case2.Status = 'On Hold';
        insert case2;
        
        Case case3 = new Case();
        case3.Subject = 'TestCase3';
        case3.BusinessHoursId = lstBusinessHours.Id;
        case3.OpportunityId__c = opp.id;
        case3.OwnerId = usr1.Id;
        case3.Requestor__c = usr3.Id;
        case3.RecordTypeId = recId_OrderRequest;
        case3.soc_Process_Start_Time__c = system.now();
        case3.soc_OnHold_Start_Time__c = system.now();
        case3.Stage__c = 'Detail Order';
        case3.Status = 'In Progress';
        insert case3;
        
        Case case4 = new Case();
        case4.Subject = 'TestCase4';
        case4.BusinessHoursId = lstBusinessHours.Id;
        case4.OpportunityId__c = opp.id;
        case4.OwnerId = usr1.Id;
        case4.Requestor__c = usr3.Id;
        case4.RecordTypeId = recId_OrderRequest;
        case4.soc_Process_Start_Time__c = system.now();
        case4.soc_OnHold_Start_Time__c = system.now();
        case4.Stage__c = 'Detail Order';
        case4.Status = 'On Hold';
        insert case4;
    }

    }
    //Creating a new case and updating it for positive senario
    @isTest static void SFDCaseDetailingTimeTest_first(){
        test.startTest();
        
        User usr2 = [SELECT Id FROM User WHERE FirstName='JASONE' LIMIT 1];
        Case case1 = [Select OwnerId, Status, Stage__c FROM Case WHERE Subject = 'TestCase1' LIMIT 1];
        case1.OwnerId = usr2.Id;
        case1.Status = 'On Hold';
        update case1;
        
        test.stopTest();
        
        Case Case2 = [Select soc_OnHold_Start_Time__c, Stage__c, Status, Subject FROM Case WHERE Subject = 'TestCase1' limit 1];
        system.assert(case2.Status=='On Hold');
        
    }
    //Testing the positive senario and profile specific senario for child case
    static testMethod void SFDCaseDetailingTimeTest_second(){
        test.startTest();
 
        Case case1 = [Select OwnerId, Status, Stage__c FROM Case WHERE Subject = 'TestCase2' LIMIT 1];
        Case case3 = [Select OwnerId, Status, Stage__c FROM Case WHERE Subject = 'TestCase3' LIMIT 1];
        
        User usr2 = [SELECT Id FROM User WHERE FirstName='JASONE' LIMIT 1];
        case1.OwnerId = usr2.Id;
        case1.Status = 'In Progress';
        update case1;
        
        
        case3.OwnerId = usr2.Id;
        case3.Status = 'Closed';
        update case3;
        test.stopTest();
        
        Case Case2 = [Select soc_Detailing_OnHold_Total_Time__c, Stage__c, Status, Subject FROM Case WHERE Subject = 'TestCase2' limit 1];
        
        system.assert(case2.soc_Detailing_OnHold_Total_Time__c != null);
        
        
    }
    //Testing the positive senario and profile specific senario for parent case
    static testMethod void SFDCaseDetailingTimeTest_third(){
        test.startTest();
        
        Case case1 = [Select OwnerId, Status, Stage__c FROM Case WHERE Subject = 'TestCase4' LIMIT 1];
        
        User usr2 = [SELECT Id FROM User WHERE FirstName='JASONE' LIMIT 1];
        case1.OwnerId = usr2.Id;
        case1.Status = 'Withdrawn';
        update case1;
        test.stopTest();
        Case Case2 = [Select soc_Detailing_OnHold_Total_Time__c FROM Case WHERE id=:case1.Id limit 1];
        system.assert(case2.soc_Detailing_OnHold_Total_Time__c != null);
        
        
    }
    //Testing the bulk senario
    static testMethod void SFDCaseDetailingTimeTest_bulky(){
        test.startTest();
        opportunity opp = soc_TestUtility.CreateOpportunity();
        soc_SFD_Case_Business_Time__c ss = new soc_SFD_Case_Business_Time__c();
        ss.soc_SFD_Case_Acceptance_Time_Type__c='hh';
        ss.soc_SFD_Case_Acceptance_Time__c = 6;
        ss.Name = 'Case Acceptance';
        insert ss;
        soc_SFD_Case_Business_Time__c ss1 = new soc_SFD_Case_Business_Time__c();
        ss1.soc_SFD_Case_Acceptance_Time_Type__c='hh';
        ss1.soc_SFD_Case_Acceptance_Time__c = 13;
        ss1.Name = 'Case Detailing';
        insert ss1;
        
        List<Case> TestCases = new List<Case>();
        User usr1 = [SELECT Id FROM User WHERE LastName = 'LIVESTON' LIMIT 1];
        Id recordTypeID = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
        for(Integer i=0;i<5;i++){
            Case cc = new Case();
            cc.OpportunityId__c = opp.id;
            cc.RecordTypeId = recordTypeID;
            cc.OwnerId = usr1.Id;
            cc.Subject = 'Case'+i;
            cc.Status = 'In Progress';
            cc.Stage__c = 'Detail Order';
            TestCases.add(cc);
        }
        
        insert TestCases;

        User usr2 = [SELECT Id FROM User WHERE FirstName='JASONE' LIMIT 1];
        for(Case cs:TestCases){
            cs.OwnerId = usr2.Id;
            cs.Status = 'On Hold';
        }
        update TestCases;
        test.stopTest();
        Case TestCases1 = [Select Status,soc_OnHold_Start_Time__c FROM Case WHERE Subject = 'Case0' limit 1];
        system.assert(TestCases1.Status == 'On Hold');
    } 
}