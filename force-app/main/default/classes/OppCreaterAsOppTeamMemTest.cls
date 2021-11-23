/********************************************************************************************
@Class Name                 :   OppCreatorAsOppTeammemTest
@Description                :   Batch Class to change Opportunity Owner and Opp Team Role from delegated Owner to Sales Rep.
@Date                       :   
@Author                     :   
@Version                    :   1.0
@Comments                   :   Batch Class to change Opportunity Owner and Opp Team Role from delegated Owner to Sales Rep.

@Last Modified By           :   Amar Chakka
@Last Modified Date         :   27-Dec-2019.
@Last Modified Comments     :   Sprint 19.17, P2OB-4310, To Fix Cyclomatic Complexity Issues.
@Last Modified      		: 	07/01/2020 21.01 by Sri, Team SFO
					  			as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      		: 

*********************************************************************************************/
@isTest
public with sharing class OppCreaterAsOppTeamMemTest {
    static testMethod void test() {
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [select id from user where id =: userinfo.getUserId()];
        User u = new User(Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
        
        insert u;
        
        
        
        Account acc=new Account();
        acc.Name='TESTAccount';
        acc.Customer_Status__c='ACTIVE';
        acc.Migrated_Customer__c=true;
        Insert acc;
        
        List<Opportunity> oppList=new List<Opportunity>();
        
        for(integer i =0; i<10; i++){
            oppList.add(new Opportunity(AccountId=acc.Id, Name='Test'+i, closedate=System.today(), StageName='Propose', ownerId=u.id));
        }
        insert OppList; 
        
        List<OpportunityTeamMember> otmList=new List<OpportunityTeamMember>();
        for(Opportunity opp : [SELECT Id from Opportunity]){
            OpportunityTeamMember otm=new OpportunityTeamMember();
            otm.UserId=UserInfo.getUserId();
            otm.OpportunityId=opp.Id;
            otm.TeamMemberRole='Delegated Owner';
            otm.OpportunityAccessLevel='Read';
            otmList.add(otm);
        }
        insert otmList;	
        Test.startTest();
        OppCreatorAsOppTeammem oppteamBatch=new OppCreatorAsOppTeammem();
        database.executeBatch(oppteamBatch);
        Test.stopTest();
        Opportunity opp = [select createdbyId, OwnerId from opportunity LIMIT 1];
        system.assertEquals(Opp.ownerId,opp.createdbyId);
        OpportunityTeamMember oppTeamMemRole = [select TeamMemberRole from OpportunityTeamMember limit 1];
        system.assertEquals('Sales Rep', oppTeamMemRole.TeamMemberRole);
        
    }
}