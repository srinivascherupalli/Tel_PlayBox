/*******************************************************************
@Class Name			: ScheduleBatchSyncContactOptOutsTest
@Sprint 			: 21.08  & P2OB-13388
@Author				: SFO Team (Pallavi B)
@CreateDate			: 21/06/2021
@description		: Test class for ScheduleBatchSyncContactOptOuts.
@Last Modified      : 
*********************************************************************/
@istest
public class ScheduleBatchSyncContactOptOutsTest {
    
     /*******************************************************************
    @Method Name    :   testscheduleBatchSyncContactOptOuts
    @Sprint         :   21.09 & P2OB-13388
    @Author         :   SFO Team (Pallavi B)
    @CreateDate     :   21-06-2021
    @TestCoverage   :   Coverage for ScheduleBatchSyncContactOptOuts
    @Description    :   tests the scheduled batch apex with cron expression
    @Last Modified Info :   
    *********************************************************************/  
    @istest
  public static void testscheduleBatchSyncContactOptOuts() {
		Test.StartTest();
		ScheduleBatchSyncContactOptOuts testScheduleBatchSyncContactOptOuts = new ScheduleBatchSyncContactOptOuts();
		String CRON_EXP = '0 0 23 ? * 7';  // Cron exprssion that runs batch class on every saturday 11pm 
		String jobId = system.schedule('Test status Check', CRON_EXP, testScheduleBatchSyncContactOptOuts);
      
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP,ct.CronExpression);

      // Verify the job has not run
       System.assertEquals(0, ct.TimesTriggered);
      
     Test.stopTest();
  }
    
}