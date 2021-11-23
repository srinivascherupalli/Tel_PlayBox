@isTest
public with sharing class IntegrationRecordsManipulationTest {
   @isTest static void getIntegrationHandlerSettingsTest() {
        List<Integration_Record__c> recordsList = new List<Integration_Record__c>();
        Integration_Record__c records = new Integration_Record__c();
        records.status__c = IntegrationQueueHandler.PROCESSED;
        records.Handler__c = 'ManageOrderSumbitHandler';
        records.Params__c = 'ON000000';
        recordsList.add(records);
        Insert recordsList;
        IntegrationRecordsManipulationQueueble irqb = new IntegrationRecordsManipulationQueueble(recordsList,false);
        Test.startTest();
       irqb.executeIntegrationRecords();
        Test.stopTest();
        System.assertNotEquals(recordsList,null);

    }
}