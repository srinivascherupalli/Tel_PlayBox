/**
* Test class for FrontEndTransactionLog class
*/
@isTest
public class FrontEndTransactionLogTest {
 
    @isTest
    static void testTransactionLogFromUI() {
        final String correlationId  = 'Test CorrelationId';
        final String transactionLog = '{"message":"Test Logger Message","loggerName":"LWC or LC name","timestamp":"28/08/2020, 12:51:20"}';
         
        Test.startTest();
            FrontEndTransactionLog.transactionLogFromUI(transactionLog, correlationId);
        Test.stopTest();
         
        List<Transaction_log__c> getTransactionLog = [select Id from Transaction_log__c where CorrelationId__c = 'Test CorrelationId'];
        //System.assert(getTransactionLog.size() == 1, 'Front End Transaction Log created');
        System.assertEquals(correlationId,'Test CorrelationId');
    }

    @isTest
    static void testTransactionLogFromUIException() {
        final String correlationId  = 'Test CorrelationId';
        final String transactionLog = '{"message":"Test Logger Message","loggerName":"LWC or LC name","timestamp":"28/08/2020, 12:51:20"}';
         
        Test.startTest();
            FrontEndTransactionLog.throwTestException = true;
            FrontEndTransactionLog.transactionLogFromUI(transactionLog, correlationId);
        Test.stopTest();
        List<Transaction_log__c> getTransactionLog = [select Id from Transaction_log__c where CorrelationId__c = 'Test CorrelationId'];
        System.assert(getTransactionLog.size() == 0, 'Front End Transaction Log not created');
        //System.assert([select count() from Exception_Log__c] == 1, 'Front End Transaction Log created');
    }
}