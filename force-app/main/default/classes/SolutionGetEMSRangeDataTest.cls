/***********************************************************************************************
Name          : SolutionGetEMSRangeDataTest
Created By    : Laxmi Rahate
Created Date  : October 17, 2019
Description   : EDGE-116138 This is a test class to simulate and test the logic of SolutionGetEMSRangeData
**********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionGetEMSRangeDataTest {
    
    static testmethod void getDataTest() {
       // Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> inputMap = new Map<String,Object>();
		inputmap.put ('externalId', '851' );
        Test.startTest();
        List<cspmb__Price_Item__c> priceList = SolutionGetEMSRangeData.getData(inputMap);
        Test.stopTest();
        System.assertNotEquals(NULL, priceList );

    }
    
        static testmethod void getDataTestNull() {
       // Map<String,Object> result = new Map<String,sObject>();
        Map<String,Object> inputMap = new Map<String,Object>();
		inputmap.put ('externalId', '979' );
        Test.startTest();
        List<cspmb__Price_Item__c> priceList = SolutionGetEMSRangeData.getData(inputMap);
        Test.stopTest();
        System.assertEquals(0, priceList.size () );

    }
    
}