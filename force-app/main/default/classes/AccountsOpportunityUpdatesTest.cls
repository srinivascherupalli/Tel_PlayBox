/*
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*/
@isTest
public class AccountsOpportunityUpdatesTest{
    @testSetup
    static void setup()
    {
        Account testAcc1 = new Account(Name='test',Customer_Status__c='ACTIVE');
        Insert testAcc1;
        
        
        Opportunity opp =new Opportunity();
        opp.Name='testopporunity';
        opp.StageName = 'Develop';
        opp.CloseDate = Date.today();
        opp.accountId = testAcc1.id;
        insert opp;        
    }
    @isTest
    static void testUpdateOpportunitiesForInactiveAccounts(){
        List<Account> lsAcc=[select id,Customer_Status__c from Account where name='test'];
        Test.startTest();
        if(lsAcc.size()<>null){lsAcc[0].Customer_Status__c='RETIRED';
                               update lsAcc;}
        system.assertEquals('RETIRED', lsAcc[0].Customer_Status__c);
        
        Test.stopTest();
    }
}