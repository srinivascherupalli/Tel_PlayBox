@isTest
private class Orchestration_ProcessedRecords_Test {
    
    private static testmethod void runTest(){
        
        Test.startTest();
        
        Orchestration_ProcessedRecords controller = new Orchestration_ProcessedRecords();
        controller.orderIds = new Set<String>();
        controller.subsIds = new Set<String>();
        controller.serviceIds = new Set<String>();
        controller.attachmentIds = new Set<String>();
        controller.numberIds = new Set<String>();
        controller.chargeLineItems = new Set<String>();
        controller.priceScheduleLineItems = new Set<String>();
        controller.tierLineItems = new Set<String>();
        controller.discountAssociations = new Set<String>();

        System.assert(controller != null);
        
        Test.stopTest();
        
    }
}