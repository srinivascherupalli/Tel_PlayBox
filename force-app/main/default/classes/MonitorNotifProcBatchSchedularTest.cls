/********************************************************
Class Name : MonitorNotifProcBatchSchedularTest
===============================================================================================================================
Change.No.    Developer Name          Date              Story Description
1.             vaibhav              15/02/2021          Test class for MonitorNotifProcBatchSchedular

**********************************************************
*/
@isTest
public class MonitorNotifProcBatchSchedularTest {
    
 @isTest
 static void testMonitorNotifProcBatchSchedular(){
            Test.startTest();
            String jobId = System.schedule('MonitorNotifProcBatchSchedularTest', '0 1 2 * * ?', new MonitorNotifProcBatchSchedular());
             Test.stopTest();
     system.assertNotEquals(jobId, null);
    }

}