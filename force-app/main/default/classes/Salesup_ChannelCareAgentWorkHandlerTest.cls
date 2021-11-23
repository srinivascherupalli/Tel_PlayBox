/*****************************************************************************
@Author: Nilima Borse
@CreateDate: 21-Feb-2020
@ModifiedByandDate: 
@Description: This Test class is for Salesup_ChannelCareAgentWorkHandler class
@References
Story:P2OB-4968
<Tech Story> Change Channel Care Case Team Member's access to Read only when Case
assigned from Queue to User through Omni Channel
*******************************************************************************/
@isTest
public class Salesup_ChannelCareAgentWorkHandlerTest {
    
    @isTest static void testChannelCareCaseTeamAccess(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];        
        User u =[Select id from user where ProfileId =: p.Id AND IsActive = true limit 1 ];
        List<CaseTeamRole> caseTeamRoleList = new List<CaseTeamRole>();
		system.runAs(u){  
            List<String> caseTeamNames = new List<String>{'Channel Care Write Access'};
            caseTeamRoleList = [select Id from CaseTeamRole where Name IN : caseTeamNames limit 1];
        }
        
        //P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
        Account customerAccount=TestUtil.createAccount('Testacc');
        insert customerAccount;
        
        Opportunity opportunity = soc_TestUtility.CreateOpportunity();
        system.assertNotEquals(null, opportunity.Id);
        
        Case caseObj = new Case();
        caseObj.Status = 'New';
        //caseObj.Stage__c = 'New';
        caseObj.OpportunityId__c = opportunity.Id;
        caseObj.OwnerId = UserInfo.getUserId();
        caseObj.AccountId =customerAccount.id;//P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
        caseObj.RecordTypeId =Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        insert caseObj;
        system.assertNotEquals(null, caseObj.Id);
        system.runAs(u){  
            if([select count() from CaseTeamMember where ParentId=:caseObj.Id And MemberId=:u.Id]==0){
                CaseTeamMember newMember=new CaseTeamMember(ParentId = caseObj.Id, MemberId = u.Id, TeamRoleId = caseTeamRoleList[0].Id);
                insert newMember;
            } 
        }
        test.startTest();        
        Salesup_ChannelCareAgentWorkHandler.handleChannelCareRequest(new List<Id>{caseObj.Id});        
        List<CaseTeamMember> csTeamList = [select Id, ParentId, MemberId FROM CaseTeamMember];
        system.debug('csTeamList=='+csTeamList);
        system.assert(csTeamList.size() > 0);
        test.stopTest();
    }

}