/*------------------------------------------------------------------------ 
Author: Ivan Aerlic 
Description: A test class created to validate the WaitingUserResponse_BatchSchedule
US: EDGE-80291, P2OB-3621
----------------------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class WaitingUserResponse_BatchSchedule_Test {     
    //Tests Schedulable ability
    @isTest public static void scheduleableTest(){
        Test.startTest();
        WaitingUserResponse_BatchSchedule waiting = new WaitingUserResponse_BatchSchedule();
        String timer = '0 5 15 8 2 ?';
        String jobID = System.schedule('Test', timer, waiting);
        Test.stopTest();
        System.assert(true);
    }
}