/********************************************************
Class Name : UpdateMRODetailsSchedulerTest
===============================================================================================================================
Change.No.    Developer Name          Date              Story Description
1.             Prajakta              12/11/2020           Test class for UpdateMRODetailsScheduler

**********************************************************
*/
@isTest
private class UpdateMRODetailsSchedulerTest{

 @isTest
 static void testUpdateMRODetailsScheduler(){
            Test.startTest();
            String jobId = System.schedule('UpdateMRODetailsSchedulerTest', '0 1 2 * * ?', new UpdateMRODetailsScheduler());
             Test.stopTest();
     system.assertNotEquals(jobId, null);
    }
}