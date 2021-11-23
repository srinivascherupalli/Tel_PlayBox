@isTest
private without sharing class BatchUpdateProgramRecordsTest {
    private static List<BatchUpdateProgramRecords.OrderHistoryWrapper> ordHistoryList = new List<BatchUpdateProgramRecords.OrderHistoryWrapper>();
      //private static BatchUpdateProgramRecords obj = new BatchUpdateProgramRecords();
    @TestSetup
    static void makeData(){
        Id generalRecTypeId = Schema.SObjectType.Program_Account__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '2022012339';
        Database.insert(acc);
        
        List<BDS_Notify_Settings__c> bdsNotifySettings = new List<BDS_Notify_Settings__c>();
        bdsNotifySettings.add(createCustomSettings('Feature Level', 'FeatureLevelShadow', false));
        bdsNotifySettings.add(createCustomSettings('Technical Support', 'TechnicalSupportShadow', true));
        insert bdsNotifySettings;
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        for(Integer i=0; i<50; i++){
            csord__Order__c ord = new csord__Order__c();
            ord.csord__Account__c = acc.Id;
            ord.Name = 'Test Batch'+i;
            ord.csord__Status2__c = 'Completed';
            ord.csord__Identification__c = 'Order_test'+i;
            orderList.add(ord);
        }
        if(!orderList.isEmpty()){
            Database.insert(orderList);
        }

        Program__c programRec = new Program__c(Name='Test Program 1');
        Database.insert(programRec);
        List<Program_Account__c> programRecList = new List<Program_Account__c>();
        List<Program_Account__c> programRecListToUpdate = new List<Program_Account__c>();
        for(Integer i=0; i<10; i++){
            Program_Account__c progAcc = new Program_Account__c();
            progAcc.Account__c = acc.Id;
            progAcc.Digital_Program_Type__c = 'Transition';
            progAcc.Digital_Products_Start_Date__c = date.newinstance(2021,05,06);
            progAcc.Enable_to_digital_products__c = true;
            progAcc.Status__c = 'Discovery';
            progAcc.Program__c = programRec.Id;
            programRecList.add(progAcc);
        }
        if(!programRecList.isEmpty()){
            Database.insert(programRecList);
        }
        for(Program_Account__c progAcc: programRecList){
            progAcc.recordTypeId = generalRecTypeId;
            programRecListToUpdate.add(progAcc);
        }
        if(!programRecListToUpdate.isEmpty()){
            update programRecListToUpdate;
        }
    }
    private static testMethod void WhenBatchUpdateProgramRecordsSuccess() 
    {
        
        List<csord__Order__c> orderList = new List<csord__Order__c>([SELECT Id FROM csord__Order__c WHERE csord__Status2__c = 'Completed']);
        String oldValue = '';
        String newValue = '';
        Id parentId;
        String field = '';

        
        for(Integer i=0; i<10; i++){
            oldValue = 'On Hold';
            newValue = 'Completed';
            ParentId = orderList[i].Id;
            field = 'csord__Status__c';
            BatchUpdateProgramRecords.OrderHistoryWrapper ordHistory = new BatchUpdateProgramRecords.OrderHistoryWrapper(oldValue, newValue, parentId, field);
            ordHistoryList.add(ordHistory);
        }
        BatchUpdateProgramRecords obj = new BatchUpdateProgramRecords();
        BatchUpdateProgramRecords.orderHistoryWrap = ordHistoryList;
        Test.startTest();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }

    private static testMethod void WhenBatchUpdateProgramRecordsFailure() 
    {
        
        List<csord__Order__c> orderList = new List<csord__Order__c>([SELECT Id FROM csord__Order__c WHERE csord__Status2__c = 'Completed']);
        String oldValue = '';
        String newValue = '';
        Id parentId;
        String field = '';

        
        for(Integer i=0; i<10; i++){
            oldValue = 'Active';
            newValue = 'Suspended';
            ParentId = orderList[i].Id;
            field = 'csord__Status__c';
            BatchUpdateProgramRecords.OrderHistoryWrapper ordHistory = new BatchUpdateProgramRecords.OrderHistoryWrapper(oldValue, newValue, parentId, field);
            ordHistoryList.add(ordHistory);
        }
        BatchUpdateProgramRecords obj = new BatchUpdateProgramRecords();
        BatchUpdateProgramRecords.orderHistoryWrap = ordHistoryList;
        Test.startTest();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
    private static BDS_Notify_Settings__c createCustomSettings(String name, String value, boolean isSI5Offer) {
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.Name = name;
        bds.Value__c = value;
        bds.Is_SI5_Offer__c = isSI5Offer;
        return bds;
        }
}