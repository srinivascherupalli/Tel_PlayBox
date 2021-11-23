/*************************************************************************************************
Name        : AllocatedBillingAccountSchedulerTest
Description : Test class for AllocatedBillingAccountScheduler 
Author      : Veena Putta
Story       : EDGE-170032
***************************************************************************************************/
@isTest
public class AllocatedBillingAccountSchedulerTest {
    public static testMethod void testschedule() {
        Test.StartTest();
        AllocatedBillingAccountScheduler testsche = new AllocatedBillingAccountScheduler();
        String sch = '0 30 21 1/1 * ? *';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
        List<Billing_Account__c> delRecs = [SELECT Id,Name FROM Billing_Account__c WHERE Status__c = 'Allocated' AND Createddate <= YESTERDAY];
        system.assert(delRecs.isEmpty());
    }
}