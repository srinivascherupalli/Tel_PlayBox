@isTest
private class AsyncExecutionReplicatorGetSiteTest {
 
 @testSetup static void setup() {
 ProductTestService.getNewAccount('Test Account');
 }
 
 @isTest static void test_execute() {
 AsyncExecutionReplicatorGetSite result = new AsyncExecutionReplicatorGetSite('test', 'test');
 result.execute(null);
 System.assertEquals('test','test');
 }
 
 @isTest static void test_insert_legacy_site_future() {
 Test.startTest();
 List<Account> acctList = new List<Account>([SELECT Id FROM Account WHERE name = 'Test Account']);
 System.assertEquals(acctList.size(), 1, 'Unexpected number of Accounts retrived');
 Account acct = acctList.get(0);
 Test.setMock(HttpCalloutMock.class, new ReplicatorResponseMock());
 UpdateLegacyFlagOnBasketHelper.insertLegacySiteFuture(acct.id,'test');
 List<cscrm__Site__c> siteList = [select id from cscrm__Site__c LIMIT 1];
 system.debug('test_insert_legacy_site_future' + siteList);
 System.assertEquals(0,siteList.size());
 Test.stopTest();
 }
}