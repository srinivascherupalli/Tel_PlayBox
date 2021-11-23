@isTest ()//seeAllData is set to true to ensure cscfga.API_1.syncBundleToOpportunity
private class OpportunityBulkSyncBatchableTest{

    @isTest
    static void test_BulkSyncOpportunityBatchTest(){
        Test.startTest();
        OpportunityBulkSyncBatchable batchClass = new OpportunityBulkSyncBatchable();
        Account acc = new Account(Name = 'Test Account2',Customer_Status__c = 'ACTIVE',Migrated_Customer__c = true);
        insert acc;
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test';
        objOpp.StageName = 'Propose';
        objOpp.closedate = system.today()+5;
        objOpp.AccountId = acc.Id;
        insert objOpp;
        List<cscfga__Product_Basket__c> syncbasketList1 = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c objProductbask = new cscfga__Product_Basket__c();
        objProductbask.Name = 'Test Basket BulkSync';
        objProductbask.cscfga__Opportunity__c = objOpp.Id;
        objProductbask.csordtelcoa__Synchronised_with_Opportunity__c = false;
        syncbasketList1.add(objProductbask);
        insert syncbasketList1;
        System.assertEquals('Test Basket BulkSync', objProductbask.Name);
        Database.executeBatch(batchClass, 1);
        Test.stopTest();
          
    }
}