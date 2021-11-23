/********************************************************************************************************
Name          : DevicePlanAssociationLookupCustomTest
Created By    : Mahaboob Basha
Created Date  : July 03 2019
Description   : This is a test class to simulate and test the logic of DevicePlanAssociationLookupCustom
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        03-07-2019      Created
1.2         Mahaboob        03-07-2019      Added methods getRequiredAttributesTest, doLookupSearchTest
*******************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class DevicePlanAssociationLookupCustomTest {
    
    /***********************************************************************************************************************
    * Method Name : getRequiredAttributesTest
    * Description : Used to simulate and test the logic of getRequiredAttributes method in DevicePlanAssociationLookupCustom
    * Parameters  : NA
    * Return      : NA                      
    ***********************************************************************************************************************/
    static testmethod void getRequiredAttributesTest() {
        String result;
        Test.startTest();
            DevicePlanAssociationLookupCustom dpaLookup = new DevicePlanAssociationLookupCustom();
            result = dpaLookup.getRequiredAttributes();
        Test.stopTest();
        System.assertEquals('["ParentPriceItem","ManufacturerString","ModelString","ColourString","PaymentTypeString"]', result);
    }
    
    /****************************************************************************************************************
    * Method Name : doLookupSearchTest
    * Description : Used to simulate and test the logic of doLookupSearch method in DevicePlanAssociationLookupCustom
    * Parameters  : NA
    * Return      : NA                      
    ****************************************************************************************************************/
    static testmethod void doLookupSearchTest() {
        Object[] result;
        cspmb__Price_Item__c plan = new cspmb__Price_Item__c(Name = 'Test Plan');
        INSERT plan;
        cspmb__Price_Item__c device = new cspmb__Price_Item__c(Name = 'Test Plan', cspmb__Product_Definition_Name__c = 'Device', Manufacturer__c = 'Test Manufacturer', Model__c = 'Test Model', Colour__c = 'Test Colour', Contract_Type__c = 'Test Contract Type');
        INSERT device;
        Device_Plan_Association__c dpa = new Device_Plan_Association__c(Plan__c = plan.Id, Device__c = device.Id);
        INSERT dpa;
        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('ParentPriceItem', plan.Id);
        searchFields.put('ManufacturerString', 'Test Manufacturer');
        searchFields.put('ModelString', 'Test Model');
        searchFields.put('ColourString', 'Test Colour');
        searchFields.put('PaymentTypeString', 'Test Contract Type');
        Test.startTest();
            DevicePlanAssociationLookupCustom dpaLookup = new DevicePlanAssociationLookupCustom();
            result = dpaLookup.doLookupSearch(searchFields, '', NULL, 1000, 1000);
            searchFields.remove('PaymentTypeString');
            result = dpaLookup.doLookupSearch(searchFields, '', NULL, 1000, 1000);
            searchFields.remove('ColourString');
            result = dpaLookup.doLookupSearch(searchFields, '', NULL, 1000, 1000);
            searchFields.remove('ModelString');
            result = dpaLookup.doLookupSearch(searchFields, '', NULL, 1000, 1000);
            searchFields.remove('ManufacturerString');
            result = dpaLookup.doLookupSearch(searchFields, '', NULL, 1000, 1000);
        Test.stopTest();
    }
}