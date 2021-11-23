@isTest
private class Orchestration_LimitsUtilityTest {
    
    @TestSetup
    static void makeData(){
        
        Orchestration_TestUtility.buildLimits();
    }

    private static testmethod void test_LimitsMethdos(){
        
        Test.startTest();

        Orchestration_LimitsUtility.getOrchestrationProcessLimit();
        System.assert(!Orchestration_LimitsUtility.checkSoqlLimit());
        System.assert(!Orchestration_LimitsUtility.checkDmlLimit());
        System.assert(!Orchestration_LimitsUtility.checkCalloutLimit());
        System.assert(!Orchestration_LimitsUtility.checkCpuLimit());
        System.assert(!Orchestration_LimitsUtility.checkHeapSizeLimit());
        System.assert(!Orchestration_LimitsUtility.checkDmlRowsLimit());
        System.assert(!Orchestration_LimitsUtility.areLimitsViolated());
        System.assert(!Orchestration_LimitsUtility.areCallOutLimitsViolated());
        System.assert(!Orchestration_LimitsUtility.areAsyncLimitsViolated());
        System.assert(!Orchestration_LimitsUtility.checkAsyncSoqlLimit());
        System.assert(!Orchestration_LimitsUtility.checkAsyncCpuLimit());
        System.assert(!Orchestration_LimitsUtility.checkAsyncCpuLimit());
        System.assert(!Orchestration_LimitsUtility.checkDmlRowsLimit());        
        Test.stopTest();
    }
}