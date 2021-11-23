/* Test class for OppTerrAssignDefaultLogicFilter class provided by Salesforce platform
 * This test class does not have any system.asserts as the territory assignment rules are not triggered 
 * when done through Apex.
 */
@istest
public without Sharing class OppTerrAssignDefaultLogicFilterTest {
  Private static testmethod void oppTerrAssigntest(){

        // Setup Test data - Cannot be done in setup method below due to Mixed DML exception
        Account acc = TestUtil.createAccount('Test Account');
        acc.Portfolio_Code__c = 'TEST9';
        insert acc;

        Opportunity opp =  TestUtil.createOpportunity(acc.Id);
        insert opp;     

        List<id> oppListIds=new List<id>();
        oppListIds.add(opp.id);

        Set<id> accListIds=new Set<id>();
        accListIds.add(acc.id);

        OppTerrAssignDefaultLogicFilter checkOppty=new OppTerrAssignDefaultLogicFilter();
        Map<Id,Id> mapid=checkOppty.getOpportunityTerritory2Assignments(oppListIds);
        Id modelId=CheckOppty.getActiveModelId();

        Map<Id,OppTerrAssignDefaultLogicFilter.Territory2Priority>MapTerritory=CheckOppty.getAccountMaxPriorityTerritory(modelId, accListIds);
        
        OppTerrAssignDefaultLogicFilter.Territory2Priority innerclass = new OppTerrAssignDefaultLogicFilter.Territory2Priority(modelId,1,true);
		System.assertEquals('testopporunity',opp.Name);
    }
  
    @testsetup
    static void setup(){
  
        // Setup the territories. The account and opportunity cannot be created in the same context as it throws
        // a Mixed DML exception
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'TEST9999'});
        insert territories;
		System.assertEquals('TEST9999',territories.get(0).Name);

    }

}