/*
*/

@isTest
private class AuthorizeContactForAccountUtilTest {
    private static OnlineOrderingTestData testData = null;

    static {
        String strTestData = [select Name, Body from StaticResource where Name in ('OnlineOrderingTestData')].body.toString();
        testData = (OnlineOrderingTestData) system.json.deserialize(strTestData, OnlineOrderingTestData.class);

        Integer numScenarios = testData.scenarios.size();
        for(Integer i=0; i<numScenarios; i++) {
        
            final Account a = testData.scenarios.get(i).test_data.account;
            insert a;
    
            final Contact c = testData.scenarios.get(i).test_data.contact;
            c.accountid=a.id;
            insert c;
    
            final AccountContactRelation acr = [select accountid, contactid, roles from AccountContactRelation where accountid = :a.id and contactid = :c.id];
            acr.Contact_Usage__c = 'Business';
            acr.IsActive = true;
            acr.roles = testData.scenarios.get(i).test_data.account_contact_relation.roles;
            upsert acr;
    
        }
    }

    static testMethod void testScenarios() {
        Integer numScenarios = testData.scenarios.size();
        for(Integer i=0; i<numScenarios; i++) {
            
            AccountContactRelation expectedACR = testData.scenarios.get(i).test_data.account_contact_relation;
            Contact expectedContact = testData.scenarios.get(i).test_data.contact;
            Account expectedAccount = testData.scenarios.get(i).test_data.account;
            try {
                AccountContactRelation acr = AuthorizeContactForAccountUtil.getACR(expectedContact.email, expectedAccount.cidn__c);
                system.assert(acr.accountid == expectedAccount.id &&
                              acr.contactid == expectedContact.id &&
                              acr.roles     == expectedACR.roles, 
                              'test failed: \nexpected: ' + expectedACR + '\ngot: ' + acr);
            } catch (AuthorizationException aex) {
                system.debug('expected exception: ' + aex);
            }
        }
        
    }
    
    static testMethod void testNegativeScenarios() {
        AccountContactRelation acr;
        
        try {
            acr = AuthorizeContactForAccountUtil.getACR('contact_does_not_exist@team.telstra.com', '9436029158');
        } catch(AuthorizationException aex) {
            system.debug('expected exception: ' + aex);
        }

        system.assert(acr == null, 'expected acr to be null');
    }
    
    private class OnlineOrderingTestData {
        list<scenario> scenarios { get; set; }
    }

    private class scenario {
        String name { get; set; }
        String api { get; set; }
        ScenarioTestData test_data { get; set; }
    }
    
    private class ScenarioTestData {
        Account account { get; set; }
        Contact contact { get; set; }
        AccountContactRelation account_contact_relation { get; set; }
    }
}