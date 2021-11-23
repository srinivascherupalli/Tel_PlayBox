/*****************************************************************************
@Author: nitesh
@CreateDate: 20/08/2018
@ModifiedByandDate: 
@Description: This Class is created to cover the test coverage
SOC_AgentWorkTriggerHandler = 88%
*******************************************************************************/
@isTest(seeAllData=false)
public class SOC_AgentWorkTriggerHandlerTest {
    
    static testMethod void SOC_AgentWorkTriggerHandlerTest() {
        
        Id socSupportReqWSOCId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
        Id socOrderReqSOCId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');

        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;

        User u = new User(Alias = 'standt', Email=uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');
        
        opportunity opp = soc_TestUtility.CreateOpportunity();
        system.debug('>>> opp... '+opp);
        Case caseObj = new Case();
        Case caseObj1 = new Case();
        system.runAs(u){  
            List<CaseTeamRole> caseTeamRoleList = [select Id from CaseTeamRole where Name = 'SOC Case View Access' limit 1];
            if(caseTeamRoleList.size() == 0){
                CaseTeamRole cst = new CaseTeamRole();
                cst.Name = 'SOC Case View Access';
                cst.AccessLevel = 'Edit';
                insert cst;
            }
            
            
            
                
            caseObj.Status = 'New';
            caseObj.OpportunityId__c = opp.id;
            caseObj.RecordTypeId = socSupportReqWSOCId ;
            caseobj.Requestor__c = u.Id;
            insert caseObj;
            
        }
               
        test.startTest();
         
        
        case cs1 = [select id, ownerid from case limit 1];
        system.debug(' caseobj.OwnerId' + caseobj.OwnerId);
        //caseobj.Requestor__c = userinfo.getUserId();
        update caseObj;
        
        list<CaseTeamMember> cs = [select id from CaseTeamMember where ParentId=:cs1.id And MemberId=:cs1.ownerId];
        if(cs.size() > 0){
            
            system.debug('size ()'+ cs);
            //delete cs;
        }
        // system.debug(' owner cs1' + cs1.OwnerId);
        //Modified By :: SHamikh Hassan:: Omni channel lightning component removed
        //SOC_AgentWorkTriggerHandler.resolveAccesses(caseObj.id);
        SOC_AgentWorkTriggerHandler.handleRequest(new List<Id>{caseObj.id});
        
        //list<CaseTeamMember> cs3 = [Select Id,OwnerId From CaseTeamMember Where ParentId=:cs1.id And MemberId=:cs1.ownerId];
        case csRecord =[select id, status from case where id =: caseObj.id];
        System.assertEquals('In Progress', csRecord.status);
        
        test.stopTest();
        
    }
    
    static testMethod void SOC_AgentWorkTriggerHandlerTest1() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId;
        
        User u = new User(Alias = 'standt', Email=uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');
        
		system.runAs(u){  
            List<CaseTeamRole> caseTeamRoleList = [select Id from CaseTeamRole where Name = 'SOC Case View Access' limit 1];
            if(caseTeamRoleList.size() == 0){
                CaseTeamRole cst = new CaseTeamRole();
                cst.Name = 'SOC Case View Access';
                cst.AccessLevel = 'Edit';
                insert cst;
            }
        }
        
        
        
        Opportunity opportunity = soc_TestUtility.CreateOpportunity();
        system.assertNotEquals(null, opportunity.Id);
        
        List<Case> SFDOrderRequest = soc_CaseTriggerHandlerTest.createCase('Order_request',1,opportunity.Id,UserInfo.getUserId());  
        system.assertNotEquals(null, SFDOrderRequest[0].Id);
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.Stage__c = 'New';
        caseObj.OpportunityId__c = opportunity.Id;
        caseObj.OwnerId = UserInfo.getUserId();
        caseObj.RecordTypeId =Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        insert caseObj;
        system.assertNotEquals(null, caseObj.Id);
        test.startTest();        
        SOC_AgentWorkTriggerHandler.resolveAccesses(new List<Id>{SFDOrderRequest[0].Id,caseObj.Id});        
        List<CaseTeamMember> csTeamList = [select Id, ParentId, MemberId FROM CaseTeamMember];
        system.debug('csTeamList=='+csTeamList);
        system.assert(csTeamList.size() > 0);
        test.stopTest();
        
    }
    
    
}