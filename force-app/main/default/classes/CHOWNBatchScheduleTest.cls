@istest
public class CHOWNBatchScheduleTest {
public static testMethod void testschedule() {
        Test.StartTest();
        CHOWNBatchSchedule testsche = new CHOWNBatchSchedule();
        String sch = '0 30 21 1/1 * ? *';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
        List<Orchestration_Technical__c> delRecs = [SELECT Id,Field_29__c FROM Orchestration_Technical__c WHERE Field_29__c = 'Response Received from BDS' ];
        system.assert(delRecs.isEmpty());
    }
}