@isTest
public class MergeReordJobTest {
    static testmethod void testmergejob(){
        Test.startTest();
        {
   		MergeRecordJob sch = new MergeRecordJob(MergeRecordFactory.type.ACCOUNT);
      	Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
      	System.schedule('Test', CRON_EXP, sch);
        }
      	Test.stopTest();
    }

}