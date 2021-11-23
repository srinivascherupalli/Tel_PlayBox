/**
 *
 * CHANGES TO EXISTING FRAMEWORK:
 *---------------------------------
 * AUTHOR      : Anup Kabra
 * DATE        : 21-May-2020
 * DESCRIPTION : Updated test class to accomodate change to flush() method where
 *               a parameter should be passed to execute the method.
 *
 */
@IsTest
private class LoggerFactoryTest {

    @IsTest
    private static void testGetLoggerByName() {
        Logger3 Logger3 = LoggerFactory.getLogger('test logger');
        System.assert(Logger3 != null, 'Logger3 should not be null');
        System.assertEquals('test logger', logger3.getName(), 'Logger3 has an unexpected name');
    }

    @IsTest
    private static void testGetLoggerByNameTwiceReturnsTheSameInstance() {
        Logger3 Logger3 = LoggerFactory.getLogger('test logger');
        Logger3 logger2 = LoggerFactory.getLogger('test logger');
        System.assert(Logger3 === logger2, 'Loggers should not be different instances');
    }

    @IsTest
    private static void testGetLoggerByType() {
        Logger3 Logger3 = LoggerFactory.getLogger(LoggerFactoryTest.class);
        System.assert(Logger3 != null, 'Logger3 should not be null');
        System.assertEquals('LoggerFactoryTest', logger3.getName(), 'Logger3 name should not be different from class name');
    }

    @IsTest
    private static void testGetLoggerByTypeTwiceReturnsTheSameInstance() {
        Logger3 Logger3 = LoggerFactory.getLogger(LoggerFactoryTest.class);
        Logger3 logger2 = LoggerFactory.getLogger(LoggerFactoryTest.class);
        System.assert(Logger3 === logger2, 'Loggers should not be different instances');
    }

    @IsTest
    private static void testAddAppenderIsPassedToExistingLoggers() {
        Logger3 Logger3 = LoggerFactory.getLogger(LoggerFactoryTest.class);
        TestAppender testAppender = new TestAppender();
        LoggerFactory.addAppender(testAppender);
        Logger3.error('test log');
        System.assert(testAppender.appendCalled, 'append() should have been called');
    }
	/**
     * CHANGE => [ANUP] parameter should be passed to execute flush() method.
     *           As part of this change, cID is passed as a parameter.
     * 
     */
    @IsTest
    private static void testFlushCallsFlushOnAppenders() {
        Logger3 Logger3 = LoggerFactory.getLogger(LoggerFactoryTest.class);
        TestAppender testAppender = new TestAppender();
        LoggerFactory.addAppender(testAppender);
        STRING cId = '2345-090';
        LoggerFactory.flush(cId);
        System.assert(testAppender.flushed, 'Logger3 should be flushed');
    }

    @IsTest
    private static void testGetSetInstance() {
        LoggerFactory lf = new LoggerFactory(new TestConfiguration());
        LoggerFactory.setInstance(lf);
        System.assertEquals(lf, LoggerFactory.getInstance(), 'getInstance() did not return the value set by setInstance()');
    }

    @IsTest
    private static void testGetInstance() {
        System.assert(LoggerFactory.getInstance() != null, 'getInstance() should have returned a default instance');
    }

    private class TestAppender implements LoggingFlushableAppender {
        public Boolean appendCalled = false;
        public Boolean flushed = false;

        /**
         * @description append a logging content
         *
         * @param level the logging level
         * @param content the log content
         */
        public void append(LoggingLevel level, String content) {
            this.appendCalled = true;
        }

        /**
         * @description Returns the name of this appender.
         *
         * @return the name of this appender
         */
        public String getName() {
            return 'TestAppender';
        }

        /**
         * @description Flush the appender.
         */
        public void flush() {
            this.flushed = true;
        }
    }

    private class TestConfiguration implements LoggerFactoryConfigurationProvider {
        /**
         * @description for testing
         * @return an empty map
         */
        public Map<String, LoggingLevel> getLoggerLevels() {
            return new Map<String, LoggingLevel>();
        }
        /**
         * @description for testing
         * @return an empty list
         */
        public List<LoggingAppender> getAppenders() {
            return new List<LoggingAppender>();
        }
        /**
         * @description for testing
         * @return LoggingLevel.ERROR
         */
        public LoggingLevel getDefaultLevel() {
            return LoggingLevel.ERROR;
        }
    }
}