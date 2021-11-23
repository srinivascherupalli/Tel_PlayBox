/*
 * Test class for InvokeEASTCalloutBatch
 */
 @IsTest
public class InvokeEASTCalloutBatch_Test{
    
    	@isTest
        static void positiveBatchTest(){
            cscrm__Address__c address1 = new cscrm__Address__c();
            address1.AddressCorrection__c=true;
            insert address1;
            cscrm__Address__c address2 = new cscrm__Address__c();
            address2.AddressCorrection__c=true;
            insert address2;
            test.StartTest();
            InvokeEASTCalloutBatch invokeEastObj = new InvokeEASTCalloutBatch();
            Id jobid = Database.executeBatch(invokeEastObj);
            Test.setMock(HttpCalloutMock.class, new InvokeEastMock());
            System.assertNotEquals(null,jobid);
            test.StopTest();
            System.abortJob(jobid);
        }
        @isTest
        static void negativeBatchTest(){
            test.StartTest();
            InvokeEASTCalloutBatch invokeEastObj = new InvokeEASTCalloutBatch();
            Id secondBatchId = Database.executeBatch(invokeEastObj);
            System.assertNotEquals(null,secondBatchId);
            test.StopTest();
            System.abortJob(secondBatchId);
        }
        
}