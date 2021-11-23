/********************************************************
Class Name : ProcessOrderNotificationsSchedulableTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Pawan Devaliya         06-Dec-2019    Test class for ProcessOrderNotificationsSchedulable

**********************************************************
*/
@isTest
private class ProcessOrderNotificationsSchedulableTest{

 @isTest
 static void testProcessNotificationExecute(){
            Test.startTest();
            System.schedule('queueOrderNotificationstest', '0 1 2 * * ?', new ProcessOrderNotificationsSchedulable());
             Test.stopTest();
    }
}