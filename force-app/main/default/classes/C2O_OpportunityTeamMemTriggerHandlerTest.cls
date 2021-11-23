/*******************************************************************************
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 15/09/2021 Added this dummy comment for code coverage issue
*******************************************************************************/
@IsTest
public class C2O_OpportunityTeamMemTriggerHandlerTest { 
    public static final String OPP_TEAMROLE_SALES_REP = 'Sales Rep';
    private static testMethod void spEventPublishOnOppCreationTest(){
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
            opp.SubmittoPartnerStatus__c = 'Approved';
            opp.Opportunity_Source__c = 'Marketing';
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
        
        List<CaseTeamMember> lstCaseTeamMember = new List<CaseTeamMember>();
        List<Account> lstAcc = new List<Account>();
        List<Case> lstCase = new List<Case>();
        List<Opportunity> lstOpp=new List<Opportunity>();
        //get presales solution record Type id for case
        Id preSalesCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').getRecordTypeId();
        //get opportunity record Type if for opportunity
        Id standardRecordTyped = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        
        //get case team member role
        List<CaseTeamRole> lstCaseTeamRole = [SELECT ID, Name FROM CaseTeamRole WHERE Name in ('Sales Rep', 'Qualification Lead','Account Manager')];
        
        //List<User> lstuser = soc_TestUtility.createListUser(10, p.Id);
        //insert lstuser;
        //validate lstuser should not be null and size should be grater than zero.
        //if(lstuser!=null && lstuser.size() > 0){
            //run as user
            System.runAs(usr){
                lstAcc = soc_TestUtility.createListAccount(1, accRecordTypeId);
                if(lstAcc!=null && lstAcc.size()>0){
                    Insert lstAcc;
                    //create opportunity
                    lstOpp = soc_TestUtility.createListOpportunity(1, standardRecordTyped, lstAcc.get(0).id);
                    if(lstOpp !=null && lstOpp.size() > 0){
                        insert lstOpp;
                        //create case
                        lstCase = soc_TestUtility.createListCase(1, preSalesCaseRecordTypeId, lstAcc.get(0).id, lstOpp.get(0).id);
                        insert lstCase;
                    }
                }
            }
        //}
        
        Test.StopTest();
    }
    
    private static testMethod void spEventPublishOnOppUpdateTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        PermissionSet perSet = new PermissionSet();
        perSet.Name = 'TestSharePointOppNewMember';
        perSet.Label = 'TestSharePointOppNewMember';
        insert perSet;
        CustomPermission cp=[select Id from CustomPermission where DeveloperName = 'SharePointOppNewMember'];
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
            opp.Opportunity_Source__c = 'Marketing';
            opp.SubmittoPartnerStatus__c = '';
            insert opp;
            
            OpportunityTeamMember otm=new OpportunityTeamMember();
            otm.OpportunityId=opp.id;
            otm.OpportunityAccessLevel='Read';
            otm.UserId=usr.Id;
            otm.TeamMemberRole = Label.Telstra_Purple;
            insert otm;
            
            OpportunityTeamMember otm1=new OpportunityTeamMember();
            otm1.OpportunityId=opp.id;
            otm1.OpportunityAccessLevel='Read';
            otm1.UserId=usr.Id;
            otm1.TeamMemberRole = Label.nonTelstraPurple;
            insert otm1;
        }
        Test.StopTest();
    }
    
    private static testMethod void updateOppIndividualTelstraTest(){
        Test.StartTest();
        map<Id,String> oppIdMap = new map<Id,String>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
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
            opp.Opportunity_Source__c = 'Marketing';
            opp.SubmittoPartnerStatus__c = '';
            insert opp;
            
            OpportunityTeamMember otm1=new OpportunityTeamMember();
            otm1.OpportunityId=opp.id;
            otm1.OpportunityAccessLevel='Read';
            otm1.UserId=usr.Id;
            otm1.TeamMemberRole = Label.nonTelstraPurple;
            insert otm1;
            oppIdMap.put(opp.Id,otm1.TeamMemberRole);
            C2O_OpportunityTeamRoleTriggerHelper.updateOppIndividualTelstra(oppIdMap);
        }
        Test.StopTest();
    }
    
    private static testMethod void negativeTest(){
        C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemCreation(null);
        C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemUpdate(null,null);
        C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemRemove(null,null);
        C2O_OpportunityTeamMemberTriggerHelper.offShoreRestrictedRolAndAccountCheck(null);
    }
    
    
    @testSetup static void setup() {
        List<User> users = new List<User>();
        while(users.size()<10){
            User user = TestUtil.createUser('test'+users.size()+'@test.com.portfoliotest', 'test'+users.size(), System.Label.Profile_SalesEnterprise);
              user.phone='+121231231234';
            users.add(user);
        }
        User user1 = TestUtil.createUser('testsales1@test.com.portfoliotest', 'sales1', System.Label.Profile_SalesEnterprise);
        user1.phone='+121231231234';
        users.add(user1);
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');        
        users.add(admin);
        insert users;
        system.runAs(admin){
            List<Account> listAcc=new List<Account>();
            List<Opportunity> listOpp=new List<Opportunity>();
            Account acc = TestUtil.createAccount('Test Account 1');
            id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
            acc.RecordTypeId =accRecordTypeId;
            listAcc.add(acc);
            Account acc2 = TestUtil.createAccount('Test Account 2');
            acc2.RecordTypeId =accRecordTypeId;
            listAcc.add(acc2);
            insert listAcc;
            Opportunity opp =  TestUtil.createOpportunity(acc.Id);
            Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
            opp.RecordTypeId =myRecordTypeStandard;
            opp.OwnerId=user1.id;
            listOpp.add(opp);
            Opportunity opp1 =  TestUtil.createOpportunity(acc2.Id);
            opp1.RecordTypeId =myRecordTypeStandard;
            opp1.OwnerId=user1.id;
            listOpp.add(opp1);
            insert listOpp;
        }
        system.runAs(user1){
            Map<id,Opportunity> oppMap = new Map<id,Opportunity>([SELECT id,Purple_Opportunity__c FROM Opportunity]);
            List<OpportunityTeamMember> oppTeamMemList = new List<OpportunityTeamMember>();
            while(oppTeamMemList.size()<5){
                OpportunityTeamMember oppTeam = TestUtil.createOpportunityTeamMember(users.get(oppTeamMemList.size()).id,'All',OPP_TEAMROLE_SALES_REP,oppMap.values()[0].id);
                oppTeamMemList.add(oppTeam);
                OpportunityTeamMember oppTeam1 = TestUtil.createOpportunityTeamMember(users.get(oppTeamMemList.size()).id,'All',Label.Telstra_Purple,oppMap.values()[1].id);
                oppTeamMemList.add(oppTeam1);
            }
            while(oppTeamMemList.size()<10){
                OpportunityTeamMember oppTeam = TestUtil.createOpportunityTeamMember(users.get(oppTeamMemList.size()).id,'All',Label.Telstra_Purple,oppMap.values()[0].id);
                oppTeamMemList.add(oppTeam);
                OpportunityTeamMember oppTeam1 = TestUtil.createOpportunityTeamMember(users.get(oppTeamMemList.size()).id,'All',OPP_TEAMROLE_SALES_REP,oppMap.values()[1].id);
                oppTeamMemList.add(oppTeam1);
            }
            insert oppTeamMemList;
        }
        
    }
  /*   Method Description  : Test Coverage for OpportunityTeamMember delete scenarios on Telstra Purple teamrole
    Sprint Details    : Sprint-20.01,EDGE-3264   */ 
    private static testMethod void  opportunityTeamRoleTelstraPurpleIns_DelTest(){
        List<User> users = [Select id,IsActive from user where Alias Like 'sales%' and IsActive =true ];
        system.runAs(users[0]){
            Map<id,Opportunity> oppMap = new Map<id,Opportunity>([SELECT id,Purple_Opportunity__c FROM Opportunity]);
            List<OpportunityTeamMember> oppTeamMemList = new List<OpportunityTeamMember>([SELECT id,TeamMemberRole,OpportunityId FROM OpportunityTeamMember]);
            
            Test.StartTest();
            Delete oppTeamMemList;
            Test.StopTest();
        }
    }
    
  /*   Method Description  : Test Coverage for OpportunityTeamMember update scenarios on Telstra Purple teamrole
    Sprint Details    : Sprint-20.01,EDGE-3264   */ 
    private static testMethod void  opprtunityTeamRoleTelstraPurpleUpdateTest(){
        
        List<User> users = [Select id,IsActive from user where Alias Like 'sales%' and IsActive =true ];
        system.runAs(users[0]){
            Map<id,Opportunity> oppMap = new Map<id,Opportunity>([SELECT id,Purple_Opportunity__c FROM Opportunity]);
            List<OpportunityTeamMember> oppTeamMemList = new List<OpportunityTeamMember>([SELECT id,TeamMemberRole,OpportunityId FROM OpportunityTeamMember]);
            
            for(OpportunityTeamMember oppteam :oppTeamMemList){
                if(oppteam.TeamMemberRole==Label.Telstra_Purple && oppteam.OpportunityId ==oppMap.values()[0].id){
                    oppteam.TeamMemberRole=OPP_TEAMROLE_SALES_REP;
                }
            }
            Test.StartTest();            
            update oppTeamMemList;
          
            List<OpportunityTeamMember> oppTeamMemList1 = new List<OpportunityTeamMember>([SELECT id,TeamMemberRole,OpportunityId FROM OpportunityTeamMember Where OpportunityId = :oppMap.values()[1].id]);
            for(OpportunityTeamMember oppteam: oppTeamMemList){
                if(oppteam.TeamMemberRole ==Label.Telstra_Purple){
                    oppTeamMemList1[0].TeamMemberRole = OPP_TEAMROLE_SALES_REP;
                }
                if(oppteam.TeamMemberRole ==OPP_TEAMROLE_SALES_REP){
                    oppTeamMemList1[1].TeamMemberRole = Label.Telstra_Purple;
                }
            }
            update oppTeamMemList1;
            Test.StopTest();

        }
        
    }
     
    private static testMethod void negativeTest2(){
        C2O_OpportunityTeamRoleTriggerHelper.oppIdCheck(null,null,null);
        C2O_OpportunityTeamRoleTriggerHelper.oppTelstraIndividualCheck(null);
        C2O_OpportunityTeamRoleTriggerHelper.updateOppIndividualTelstra(null);
        C2O_OpportunityTeamRoleTriggerHelper.updateOppOnTeamMemDeletePurpleRole(null);
    }
    
    private static testMethod void updateOppOnTeamMemDeletePurpleRoleTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        PermissionSet perSet = new PermissionSet();
        perSet.Name = 'TestSharePointOppNewMember';
        perSet.Label = 'TestSharePointOppNewMember';
        insert perSet;
        CustomPermission cp=[select Id from CustomPermission where DeveloperName = 'SharePointOppRemoveMember'];
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
            opp.Opportunity_Source__c = 'Marketing'; 
            insert opp;
                        
            OpportunityTeamMember otm=new OpportunityTeamMember();
            otm.OpportunityId=opp.id;
            otm.OpportunityAccessLevel='Read';
            otm.UserId=usr.Id;
            insert otm; 
            
            otm.TeamMemberRole = Label.Telstra_Purple;
            update otm;
            OpportunityTeamMember oteam = [Select Id From OpportunityTeamMember Where Id = :otm.Id];
            delete oteam;
        }
        Test.StopTest();
    }
    
    private static testMethod void createSPEventOnOppTeamMemRemoveTest(){
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
        
        insert usr;
        PermissionSet perSet = new PermissionSet();
        perSet.Name = 'TestSharePointOppNewMember';
        perSet.Label = 'TestSharePointOppNewMember';
        insert perSet;
        CustomPermission cp=[select Id from CustomPermission where DeveloperName = 'SharePointOppRemoveMember'];
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
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
            oppMap.put(opp.Id,opp);
			Opportunity Oppty = [Select Id From Opportunity Where Id = :opp.Id];            
            OpportunityTeamMember otm=new OpportunityTeamMember();
            otm.OpportunityId=Oppty.id; 
            otm.OpportunityAccessLevel='Read';
            otm.UserId=usr.Id;
            insert otm; 
            
            opp.Opportunity_Source__c = 'Marketing';
            update otm;
            List<OpportunityTeamMember> listOppsTM1 = new List<OpportunityTeamMember>();
            Map<Id,OpportunityTeamMember> OldOppTeamMem= new Map<Id,OpportunityTeamMember>();
            listOppsTM1.add(otm);
            OldOppTeamMem.put(otm.Id,otm);
            C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemCreation(listOppsTM1); 
            C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemUpdate(listOppsTM1,OldOppTeamMem);
            C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemRemove(listOppsTM1,oppMap);
            C2O_OpportunityTeamMemberTriggerHelper.prmAddPermissionSetToAccountOwner(listOppsTM1);
            OpportunityTeamMember oteam = [Select Id From OpportunityTeamMember Where Id = :otm.Id];
            delete oteam;
        }
        Test.StopTest();
    }
}