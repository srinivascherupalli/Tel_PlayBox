/*************************************************************************************************
Name : GetCustomerSeedingReqSchedulerTest
Description : Test Class for GetCustomerSeedingRequestBatchScheduler
***************************************************************************************************/
@isTest
global class GetCustomerSeedingReqSchedulerTest {
    
    static testMethod void getCustomerSeedingRecordsBasedonBatchId()
    {
        TestContext.testCase = 'TestCase1';
        Batch_Size__mdt[] rows =[SELECT Size_Value__c FROM Batch_Size__mdt WHERE TestCase_c__c = :TestContext.testCase];
        Test.startTest();
			GetCustomerSeedingRequestBatchScheduler sch = new GetCustomerSeedingRequestBatchScheduler();
			String sch1 = '0 0 6 * * ? *'; 
            String jobid = System.schedule('Test', sch1, sch);
		CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobid];
         System.assertEquals(sch1,ct.CronExpression); 
        Test.stopTest();

    }
}