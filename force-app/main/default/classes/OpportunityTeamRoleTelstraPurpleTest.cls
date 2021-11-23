/********************************************************************************************
@Class Name                 :   OpportunityTeamRoleTelstraPurpleTest
@Description                :   Sprint-20.01,P2OB-3264
@Date                       :   09th Jan, 2020
@Author                     :   Team SFO(Sravanthi Velagapudi)
@Version                    :   1.0
@Comments                   :   This tests the scenarios implemented in OpportunityTeamRoleTelstraPurple 
for Telstra Purple Opps
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Updating API version to 50.
*********************************************************************************************/
@isTest
public class OpportunityTeamRoleTelstraPurpleTest {
    public static final String OPP_TEAMROLE_SALES_REP = 'Sales Rep';
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
            
            for(OpportunityTeamMember oppteam: oppTeamMemList){
                if(oppteam.TeamMemberRole ==Label.Telstra_Purple){
                    system.assert(oppMap.get(oppteam.OpportunityId).Purple_Opportunity__c,True);
                }
            }
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
            system.assert(oppMap.values()[0].Purple_Opportunity__c ,False);
            
            for(OpportunityTeamMember oppteam: oppTeamMemList){
                if(oppteam.TeamMemberRole ==Label.Telstra_Purple){
                    system.assert(oppMap.get(oppteam.OpportunityId).Purple_Opportunity__c,True);
                }
            }
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
    
}