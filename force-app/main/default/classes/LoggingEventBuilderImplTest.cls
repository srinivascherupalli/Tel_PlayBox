@IsTest(isParallel=true)
@SuppressWarnings('PMD.ExcessivePublicCount')
private class LoggingEventBuilderImplTest {
    @IsTest
    private static void testProperty() {
        LoggingEventBuilder builder = new LoggingEventBuilderImpl();
        System.assertEquals(builder, builder.property('foo', 'bar'), 'should return the builder');
    }

    @IsTest
    private static void testException() {
        LoggingEventBuilderImpl builder = new LoggingEventBuilderImpl();
        builder.init(LoggingLevel.DEBUG, 'logger');
        System.assertEquals(builder, builder.exception(new TestException()), 'should return the builder');
        builder.throwTestException=true;
        builder.write();
    }

    @IsTest
    private static void testWrite() {
        TestAppender appender = new TestAppender();
        LoggerFactory.addAppender(appender);
        LoggingEventBuilderImpl builder = new LoggingEventBuilderImpl();
        builder.init(LoggingLevel.DEBUG, 'logger');
        builder.throwTestException=true;
        builder.write();
        System.assert(appender.appendCalled, 'append has not been called after a write()');
    }

    @IsTest
    private static void testWriteMessage() {
        TestAppender appender = new TestAppender();
        LoggerFactory.addAppender(appender);
        LoggingEventBuilderImpl builder = new LoggingEventBuilderImpl();
        builder.init(LoggingLevel.DEBUG, 'logger');
        builder.throwTestException=true;
        builder.write('foo');
        System.assert(appender.appendCalled, 'append has not been called after a write()');
    }
    
    @IsTest
    private static void testWriteException() {
        TestAppender appender = new TestAppender();
        LoggerFactory.addAppender(appender);
        LoggingEventBuilderImpl builder = new LoggingEventBuilderImpl();
        builder.init(LoggingLevel.DEBUG, 'logger');
        builder.throwTestException=true;
        String correlationId = '1234';
        TestException e = new TestException();
        LoggingEventBuilderImpl loggingEventBuilderImpl = new LoggingEventBuilderImpl();
            ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepHand = new ExceptionHandlerHelper.ExceptionLogHandlerWrapper();
            excepHand.severity            = ExceptionHandlerHelper.Severity.LOW;
            excepHand.interfaceName       = 'FronEndTransactionLog';
            excepHand.elementName         = 'transactionLogFromUI';
            excepHand.referenceNumber     = correlationId;
            excepHand.capability          = ExceptionHandlerHelper.Capability.SYS_LOG;
            excepHand.endPointURL         = '';
            excepHand.integrationPayload  = '';
            excepHand.correlationID       = correlationId;
            excepHand.httpStatusCode      = '';
            excepHand.errorCode           = '';
            excepHand.errorDescription    = e.getMessage()+e.getStackTraceString();
            excepHand.destinationSystem   = 'Front End Transaction Logging';
            excepHand.responseMessage     = '';
            excepHand.sourceName          = ExceptionHandlerHelper.SourceName.OTHERS;
            excepHand.BusinessDescription = 'Front End Transaction Logging';
            excepHand.errorCategory       = 'Technical';
            //logger.error(excepHand);
            //LoggerFactory.dispatch(LoggingLevel.ERROR, loggingEventBuilderImpl.getErrorContent(excepHand));
        builder.write(excepHand);
        System.assert(appender.appendCalled, 'append has not been called after a write()');
    }
    
    @IsTest
    private static void testWriteError() {
        String correlationID = '1234';
        String severity = 'LOW';
        String interfaceName = 'FronEndTransactionLog';
        String elementName = 'transactionLogFromUI';
        String referenceNumber = correlationID;
        String capability = 'SYS_LOG';
        //String correlationID = correlationId;
        String errorDescription = 'Test Exception';
        String destinationSystem = 'Front End Transaction Logging';
        String sourceName = 'OTHERS';
        String BusinessDescription = 'Front End Transaction Logging';
        String errorCategory = 'Technical';
        TestAppender appender = new TestAppender();
        LoggerFactory.addAppender(appender);
        LoggingEventBuilderImpl builder = new LoggingEventBuilderImpl();
        builder.writeError(severity,interfaceName,elementName,referenceNumber, 
        capability,correlationID,errorDescription,destinationSystem, 
        sourceName,BusinessDescription,errorCategory);
        System.assert(appender.appendCalled, 'append has not been called after a write()');
    }
    
    @IsTest
    private static void testLogPlatformEvent() {
        TestAppender appender = new TestAppender();
        LoggerFactory.addAppender(appender);
        LoggingEventBuilderImpl builder = new LoggingEventBuilderImpl();
        builder.init(LoggingLevel.DEBUG, 'logger');
        builder.throwTestException=true;
        String correlationId = '1234';
        TestException e = new TestException();
        //LoggingEventBuilderImpl loggingEventBuilderImpl = new LoggingEventBuilderImpl();
            ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepHand = new ExceptionHandlerHelper.ExceptionLogHandlerWrapper();
            excepHand.severity            = ExceptionHandlerHelper.Severity.LOW;
            excepHand.interfaceName       = 'FronEndTransactionLog';
            excepHand.elementName         = 'transactionLogFromUI';
            excepHand.referenceNumber     = correlationId;
            excepHand.capability          = ExceptionHandlerHelper.Capability.SYS_LOG;
            excepHand.endPointURL         = '';
            excepHand.integrationPayload  = '';
            excepHand.correlationID       = correlationId;
            excepHand.httpStatusCode      = '';
            excepHand.errorCode           = '';
            excepHand.errorDescription    = e.getMessage()+e.getStackTraceString();
            excepHand.destinationSystem   = 'Front End Transaction Logging';
            excepHand.responseMessage     = '';
            excepHand.sourceName          = ExceptionHandlerHelper.SourceName.OTHERS;
            excepHand.BusinessDescription = 'Front End Transaction Logging';
            excepHand.errorCategory       = 'Technical';
            //logger.error(excepHand);
            //LoggerFactory.dispatch(LoggingLevel.ERROR, loggingEventBuilderImpl.getErrorContent(excepHand));
        LoggingEventBuilderImpl.LogPlatformEvent(excepHand);
        System.assert(builder.throwTestException, 'append has not been called after a write()');
    }

    private class TestException extends Exception {}

    private class TestAppender implements LoggingAppender {
        public Boolean appendCalled = false;
        /**
         * @description for testing
         * @param level the level
         * @param content the content
         */
        public void append(LoggingLevel level, String content) {
            this.appendCalled = true;
        }
    }
}