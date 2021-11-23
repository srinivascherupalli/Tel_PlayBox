/**
 * Class for RecordTypeAssignHandler test.
 */
@isTest
private class RecordTypeAssignHandlerTest {

    /**
     * Tests assignRecordTypeToService method
     */
    @isTest static void assignRecordTypeToServiceTest()
    {
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.csord__Service__c; 
        Map<String,Schema.RecordTypeInfo> ServiceRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        System.debug('PP cfrSchema: '+ cfrSchema);
        System.debug('PP ServiceRecordTypeInfo: '+ ServiceRecordTypeInfo);
        List<RecordType> serviceRecordTypeList = new List<RecordType>();
        for(Schema.RecordTypeInfo rtInfo : ServiceRecordTypeInfo.values()){
            String rtName = rtInfo.getName();
            Id rtId = rtInfo.getRecordTypeId();
            System.debug('PP rtName: '+rtName);
            System.debug('PP rtId: '+rtId);
            RecordType rt = new RecordType();
            rt.Id = rtId;
            rt.Name = rtName;
            serviceRecordTypeList.add(rt);
        }
        System.debug('PP serviceRecordTypeList: '+serviceRecordTypeList);
        
        disableCSTrigger();        
        Account acc = AccountTestFactory.buildAccount('Test Account');
        insert acc;
        
        List<Id> serviceIdList = ProductTestService.getNewOrderWithMultipleServicesRealData(acc);
        Test.startTest();
        RecordTypeAssignHandler.assignRecordTypeToService(serviceIdList);
        Test.stopTest();
        System.assertEquals('Test Account',acc.Name);
    }
    
    static void disableCSTrigger()
    {

        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c() ; 
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = true; 
        //subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Closed Won';
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Validated';
        insert subsSettings ; 
        

    }
}