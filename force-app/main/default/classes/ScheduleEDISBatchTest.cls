/********************************************************
Class Name : ScheduleEDISBatchTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Pawan Devaliya         08-July-2021    DIGI-869
2.				Pawan Devaliya	     04/08/2021		Updates batch frequency logic to dynamic
**********************************************************
*/
@isTest
private class ScheduleEDISBatchTest{

 @isTest
 static void testScheduleEDISBatchExecute(){
            Test.startTest();
            System.schedule('EDIS_Batch', '0 1 2 * * ?', new ScheduleEDISBatch());
             Test.stopTest();
    }
}