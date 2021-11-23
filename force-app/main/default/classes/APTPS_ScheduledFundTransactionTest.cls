@isTest
public class APTPS_ScheduledFundTransactionTest {
    static testMethod void ScheduledFundTransactionTest(){
        Test.StartTest();
		APTPS_ScheduledFundTransaction sh1 = new APTPS_ScheduledFundTransaction();
		String sch = '0 0 23 * * ?';
 		String fundCheck = system.schedule('Test FundTransaction Check', sch, sh1); 
        system.assertNotEquals('',fundCheck);
        Test.stopTest();
    }

}