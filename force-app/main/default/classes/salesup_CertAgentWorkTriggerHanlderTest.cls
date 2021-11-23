@isTest
public class salesup_CertAgentWorkTriggerHanlderTest {
    
    @isTest static void CertitudeCase_updateSalesChildSupportOwner(){
 
        List<Id> workItemIds = new List<Id>();
        salesup_CertitudeAgentWorkTriggerHandler.handleRequest(workItemIds);
 
        /*
        opportunity opp = soc_TestUtility.CreateOpportunity();
        Account acc = soc_TestUtility.CreateAccount();
        
        Id rec_SalesChildSupportId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        
        List<Group> lstCertitudeOffShoreOnShoreQueue = [SELECT DeveloperName,Id,Name,OwnerId,Type FROM Group Where (DeveloperName = 'salesup_Certitude_Onshore_Queue' OR DeveloperName = 'salesup_Certitude_Offshore_Queue')];
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = lstCertitudeOffShoreOnShoreQueue[0].Id;
            
            insert member;
            
            GroupMember member1 = new GroupMember();
            member1.UserOrGroupId = UserInfo.getUserId();
            member1.GroupId = lstCertitudeOffShoreOnShoreQueue[1].Id;
            
            insert member1;
        }
        
        Test.startTest();
        
        Case CaseOfCertitude = new Case();
        CaseOfCertitude.Subject = 'Pending Case1';
        CaseOfCertitude.Description = 'sdjshdks1';
        CaseOfCertitude.OpportunityId__c = opp.id;
        CaseOfCertitude.AccountId = acc.id;
        CaseOfCertitude.Status = 'New';
        CaseOfCertitude.Requestor__c = Userinfo.getUserId();
        CaseOfCertitude.salesup_Support_Type__c = 'Feasibility Request';
        CaseOfCertitude.srvsup_Categories__c = 'Feasibility';
        CaseOfCertitude.salesup_Work_Required__c = 'Wideband';
        CaseOfCertitude.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Support').getRecordTypeId();
        insert CaseOfCertitude;
        System.assert(CaseOfCertitude != null);
        
        
        Case CaseOfCertitudeChild = new Case();
        CaseOfCertitudeChild.Subject = 'Pending Case1';
        CaseOfCertitudeChild.Description = 'sdjshdks1';
        CaseOfCertitudeChild.Status = 'New';
        CaseOfCertitudeChild.OpportunityId__c = opp.id;
        CaseOfCertitudeChild.AccountId = acc.id;
        CaseOfCertitudeChild.Requestor__c = Userinfo.getUserId();
        CaseOfCertitudeChild.salesup_Support_Type__c = 'Feasibility Request';
        CaseOfCertitudeChild.srvsup_Categories__c = 'Feasibility';
        CaseOfCertitudeChild.salesup_Work_Required__c = 'Wideband';
        CaseOfCertitudeChild.RecordTypeId = rec_SalesChildSupportId;
        CaseOfCertitudeChild.ParentId = CaseOfCertitude.Id;
        insert CaseOfCertitudeChild;
        System.assert(CaseOfCertitudeChild != null);
        
        salesup_CertitudeAgentWorkTriggerHandler.handleRequest(new List<Id>{CaseOfCertitude.id});
        Test.stopTest();
        */
    }
    
}