/**
  * Author: Sandeep Soni  
  * Team: Jaipur
  * Sprint: 20.06
  * JIRA Story: P2OB-6036
  * Date: 22 April 2020
  * Class Name: cusdl_AddOppTeamMemBatchScheduleTest
  * Description: This Test class will test all test scenario of schedular class.
  **/
@isTest(SeeAllData=false)
public class cusdl_AddOppTeamMemBatchScheduleTest {
    /*This is test class for schedular class*/
    static testMethod void executeTest(){
        cusdl_AddOppTeamMemBatchSchedule sch = new cusdl_AddOppTeamMemBatchSchedule();
        Test.startTest();
        String CRON_EXP = '0 0 0,3,8,12,16,20 * * ?';

        String jobId =  System.schedule('cusdl_AddOppTeamMemBatch', CRON_EXP, sch);

        Test.stopTest();
        /*validate job is schedule or not*/
        System.assert(jobId!=null);
    }
}