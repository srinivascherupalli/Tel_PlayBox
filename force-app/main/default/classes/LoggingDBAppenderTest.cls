/**
 * 
 *  CHANGES TO EXISTING FRAMEWORK:
 *---------------------------------
 * AUTHOR      : Anup Kabra
 * DATE        : 21-May-2020
 * DESCRIPTION : As part of project requirement, we will be creating new object
 *               which is Transaction Log to capture apex transaction logs. 
 *               Therefore, changing object from Log__c to Transaction_Log__c and
 *               commenting out attachment part as we are not attaching logs.
 *
 */
@IsTest
private class LoggingDBAppenderTest {

    @IsTest
    private static void testCreateLogObjectWithAttachment() {
        LoggingDBAppender appender = new LoggingDBAppender();

        appender.append(LoggingLevel.DEBUG, 'this is a debug');
        appender.append(LoggingLevel.WARN, 'this is a warning');
        appender.append(LoggingLevel.ERROR, 'this is an error');
        appender.flush();

        List<Transaction_Log__c> logs = [SELECT Id, Name, HasError__c, HasWarning__c FROM Transaction_Log__c];
        System.assertEquals(1, logs.size(), 'No Transaction_Log__c was created.');
        System.assertEquals(true, logs[0].HasWarning__c, 'Transaction_Log__c does not have a Warning');
        System.assertEquals(true, logs[0].HasError__c, 'Transaction_Log__c does not have a Error');
        /*List<Attachment> attachments = [SELECT Id, Body, ContentType FROM Attachment WHERE ParentID = :logs[0].Id LIMIT 1];
        String content = attachments[0].Body.toString();
        System.assert(content.contains('this is a debug'), 'Transaction_Log__c content does not contain the log message');
        System.assert(content.contains('this is a warning'), 'Transaction_Log__c content does not contain the log message');
        System.assert(content.contains('this is an error'), 'Transaction_Log__c content does not contain the log message');*/
    }
}