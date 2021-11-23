/*****************************************************************************************************************
Sr.No.      Author              Date            Sprint          Story Number    Description
1           Aditya              30/08/2021       21.11           DIGI-3162      Test Class of ScheduleBatchCleanupTransactionLog
*******************************************************************************************************************/
@IsTest
public class ScheduleBatchCleanupTransactionLogsTest
{
    
    @isTest
    static void testMyBatch()
    {
        
        Test.startTest();
        ScheduleBatchCleanupTransactionLogs  m = new ScheduleBatchCleanupTransactionLogs ();
        String sch = '0 31 20 * * ?';
        String jobID = system.schedule('TestTransactionLogDelete', sch, m);
        Test.stopTest();
    
    }
   
}