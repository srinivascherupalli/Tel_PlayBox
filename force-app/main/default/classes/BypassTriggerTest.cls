@isTest
public class BypassTriggerTest {
        @isTest static void testC2O_OrderRequestTrigger() {
            test.starttest();
            Boolean check = BypassTrigger.bypassTriggerAtOG;
            Boolean check1 = BypassTrigger.isTriggeredByIncompleteOrder;
            Boolean check2 = BypassTrigger.isRunningTestCheck;
            Integer check3 = BypassTrigger.incompleteOrderCounter;
            System.assertEquals(false, check);
            System.assertEquals(false, check1);
            System.assertEquals(false, check2);
            System.assertEquals(0, check3);
            test.stoptest();
        }
}