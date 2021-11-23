/*******************************************************************************
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
*******************************************************************************/
@IsTest
public class OpportunityTeamTriggerHandlerTest {
    private static testMethod void  spEventPublishOnOppCreationTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        User usr1 = new User(Email='telsta1@test.com', 
                             EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_AU', ProfileId = p.Id, 
                             TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863471',username='telsta1@test.com.Test',alias = 'Use1T1');
        
        insert usr1;
        PermissionSet perSet = new PermissionSet();
        perSet.Name = 'TestSharepointPermission';
        perSet.Label = 'TestSharepointPermission';
        insert perSet;
        CustomPermission cp=[select Id from CustomPermission where DeveloperName = 'SharePointOpportunityCreate'];
        SetupEntityAccess setEA = new SetupEntityAccess();
        setEA.ParentId = perSet.Id;
        setEA.SetupEntityId =cp.Id;
        insert setEA;
        /*Sprint 19.03 , EDGE-63675
* Date : 28/02/2019
* @Description: Added Custom permission in test class.
*/
        CustomPermission cpOppDel=[select Id from CustomPermission where DeveloperName = 'SharePointOppRemoveMember'];
        SetupEntityAccess setEA1 = new SetupEntityAccess();
        setEA1.ParentId = perSet.Id;
        setEA1.SetupEntityId =cpOppDel.Id;
        insert setEA1;
        
        CustomPermission cpOppTeamUp=[select Id from CustomPermission where DeveloperName = 'SharePointOppUpdateMember'];
        SetupEntityAccess setEA2 = new SetupEntityAccess();
        setEA2.ParentId = perSet.Id;
        setEA2.SetupEntityId =cpOppTeamUp.Id;
        insert setEA2;
        
        CustomPermission cpOppTeamCre=[select Id from CustomPermission where DeveloperName = 'SharePointOppNewMember'];
        SetupEntityAccess setEA3 = new SetupEntityAccess();
        setEA3.ParentId = perSet.Id;
        setEA3.SetupEntityId =cpOppTeamCre.Id;
        insert setEA3;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr.Id;
        psa.PermissionSetId = perSet.Id;
        insert psa;
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        system.runas(usr){
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.Customer_Status__c = 'ACTIVE';
            acc.RecordTypeId = accRecordTypeId;        
            Insert acc;
            //id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            //opp.recordTypeId=oppRecordTypeId;
            opp.Name='TestOppCreateForEventCreate';
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName=System.Label.Opp_Stage_Develop;
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            insert opp;
            OpportunityTeamMember otm=new OpportunityTeamMember();
            otm.OpportunityId=opp.id;
            otm.OpportunityAccessLevel='Read';
            otm.UserId=usr1.Id;
            insert otm;
            system.assertEquals(otm.OpportunityAccessLevel,'Read');
            otm.OpportunityAccessLevel='Edit';
            update otm;
            system.assertEquals(otm.OpportunityAccessLevel,'Edit');
            delete otm;
        }
        
        Test.StopTest();
    }
    
    private static testMethod void  spEventPublishOnOppUpdateTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        PermissionSet perSet = new PermissionSet();
        perSet.Name = 'TestSharepointPermission';
        perSet.Label = 'TestSharepointPermission';
        insert perSet;
        CustomPermission cp=[select Id from CustomPermission where DeveloperName = 'SharePointOpportunityCreate'];
        SetupEntityAccess setEA = new SetupEntityAccess();
        setEA.ParentId = perSet.Id;
        setEA.SetupEntityId =cp.Id;
        insert setEA;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr.Id;
        psa.PermissionSetId = perSet.Id;
        insert psa;
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        //id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
        System.runas(usr){
            Account acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Customer_Status__c = 'ACTIVE';
            Insert acc;
            
            Opportunity opp=new Opportunity();
            opp.AccountId=acc.Id;
            //opp.recordTypeId=oppRecordTypeId;
            opp.Name='TestOppCreateForEventCreate';            
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName=System.Label.Opp_Stage_Develop;
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            insert opp;
            
            opp.Name='TestOppCreateForEventUpdate';
            update opp;
            system.assertEquals(opp.Name,'TestOppCreateForEventUpdate');
        }
        Test.StopTest();
    }
}