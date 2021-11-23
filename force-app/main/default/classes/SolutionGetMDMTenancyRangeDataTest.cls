/***********************************************************************************************
Name          : SolutionGetMDMTenancyRangeDataTest
Created By    : Laxmi Rahate
Created Date  : August 2, 2019
Description   : This is a test class to simulate and test the logic of SolutionGetMDMTenancyRangeData
**********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionGetMDMTenancyRangeDataTest {
    
    static testmethod void getDataTest() {
        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> inputMap = new Map<String,Object>();

        Test.startTest();
        result = SolutionGetMDMTenancyRangeData.getData(inputMap);
        Test.stopTest();
        System.assertNotEquals(NULL, result);

    }
}