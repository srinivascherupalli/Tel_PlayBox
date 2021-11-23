/*****************************************************************************
@Author: Sandeep Soni 
@CreateDate: 11/04/2018
@ModifiedByandDate: 
@Description: This test class for soc_SLAUpdateCaseMilestoneSchedule 
*******************************************************************************/
@isTest(seeAllData=false)
public class soc_SLAUpdateCaseMilestoneScheTest {   
    
     /*
    * Method Name: slaUpdateCaseMilestoneTest
    * Input Parameter:  void
    * Output Parameter: Void
    * Description: For creating test data and call to Schedule class
    * Created By:   Sandeep Soni
    * Create Date:  11 April 2019
    */
    static testMethod void slaUpdateCaseMilestoneScheduleTest() 
    {
        integer currentYear = System.Today().year();
        currentYear = currentYear + 5;
        String CRON_EXP = '0 0 0 3 9 ? '+currentYear; 
        Test.startTest();
        String jobId = System.schedule('soc_SLAUpdateCaseMilestoneSchedule', CRON_EXP, new soc_SLAUpdateCaseMilestoneSchedule());
        //validating jobid is not null
        System.assert(jobId!=null);
        Test.stopTest();
    }
}