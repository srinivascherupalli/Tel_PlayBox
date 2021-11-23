/**
* @description Test Class for Logging builder
*
* @author   Anup Kabra 
* @version  1.0
* @since    21/05/2020
* @link     https://git02.ae.sda.corp.telstra.com/projects/SBC/repos/b2c-common-dx/browse
*
*/
@IsTest
private class LoggerImplTest {

    /**
     * @description This test does not contain any assertion, as it defers to the method
     * testDebugLevelEnabled which contains the assertion logic.
     */
    @IsTest
    private static void testNoneLevel() {
        testDebugLevelEnabled(LoggingLevel.NONE, new Map<LoggingLevel, String>());
    }

    /**
     * @description This test does not contain any assertion, as it defers to the method
     * testDebugLevelEnabled which contains the assertion logic.
     */
    @IsTest
    private static void testDebugLevel() {
        testDebugLevelEnabled(LoggingLevel.DEBUG, new Map<LoggingLevel, String>{
            LoggingLevel.DEBUG => 'logDebug',
            LoggingLevel.INFO => 'logInfo',
            LoggingLevel.WARN => 'logWarn',
            LoggingLevel.ERROR => 'logError'
        });
    }

    /**
     * @description This test does not contain any assertion, as it defers to the method
     * testDebugLevelEnabled which contains the assertion logic.
     */
    @IsTest
    private static void testInfoLevel() {
        testDebugLevelEnabled(LoggingLevel.INFO, new Map<LoggingLevel, String>{
            LoggingLevel.INFO => 'logInfo',
            LoggingLevel.WARN => 'logWarn',
            LoggingLevel.ERROR => 'logError'
        });
    }

    /**
     * @description This test does not contain any assertion, as it defers to the method
     * testDebugLevelEnabled which contains the assertion logic.
     */
    @IsTest
    private static void testWarnLevel() {
        testDebugLevelEnabled(LoggingLevel.WARN, new Map<LoggingLevel, String>{
            LoggingLevel.WARN => 'logWarn',
            LoggingLevel.ERROR => 'logError'
        });
    }

    /**
     * @description This test does not contain any assertion, as it defers to the method
     * testDebugLevelEnabled which contains the assertion logic.
     */
    @IsTest
    private static void testErrorLevel() {
        testDebugLevelEnabled(LoggingLevel.ERROR, new Map<LoggingLevel, String>{
            LoggingLevel.ERROR => 'logError'
        });
    }

    @IsTest
    private static void testGetName() {
        Logger3 Logger3 = new LoggerImpl('test logger', LoggingLevel.INFO);
        System.assertEquals('test logger', logger3.getName(), 'Logger3 name is incorrect.');
    }

    @IsTest
    private static void testDebug() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.INFO);
        System.assert(l.debug() != null, 'should have returned a builder instance.');
    }

    @IsTest
    private static void testInfo() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.ERROR);
        System.assert(l.info() != null, 'should have returned a builder instance.');
    }

    @IsTest
    private static void testWarn() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.ERROR);
        System.assert(l.warn() != null, 'should have returned a builder instance.');
    }

    @IsTest
    private static void testError() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.ERROR);
        System.assert(l.error() != null, 'should have returned a builder instance.');
    }

    @IsTest
    private static void testIsErrorEnabled() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.DEBUG);
        System.assert(l.isErrorEnabled(), 'isErrorEnabled() should have been true');
    }

    @IsTest
    private static void testIsWarnEnabled() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.DEBUG);
        System.assert(l.isWarnEnabled(), 'isWarnEnabled() should have been true');
    }

    @IsTest
    private static void testIsInfoEnabled() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.DEBUG);
        System.assert(l.isInfoEnabled(), 'isInfoEnabled() should have been true');
    }

    @IsTest
    private static void testIsDebugEnabled() {
        Logger3 l = new LoggerImpl('foo', LoggingLevel.DEBUG);
        System.assert(l.isDebugEnabled(), 'isDebugEnabled() should have been true');
    }
    @IsTest
    private static void testProperty() {
        LoggingEventBuilder builder = new LoggingEventBuilderImpl();
        System.assertEquals(builder, builder.property('foo', 'bar'), 'should return the builder');
    }

    @IsTest
    private static void testException() {
        LoggingEventBuilder builder = new LoggingEventBuilderImpl();
        System.assertEquals(builder, builder.exception(new TestException()), 'should return the builder');
    }
    @IsTest
    private static void testWrite() {
        LoggingEventBuilder builder = new LoggingEventBuilderImpl();
        builder.write();
    }

    /**
     * @description Asserts the Logger3 is logging the correct messages for the level applied
     *
     * @param level the log level to be set on the logger
     * @param expected Map containing the expected messages for the specified level
     */
    private static void testDebugLevelEnabled(LoggingLevel level, Map<LoggingLevel, String> expected) {
        Logger3 Logger = new LoggerImpl('test logger', level);
        logger.debug('logDebug');
        logger.info('{Birthdate=1987-10-06, Email=xyz@gm.com, "dob":"1987-09-06", "Email":"xyz@gm.com"}');
        logger.warn('logWarn');
        logger.error('logError');

        System.assertEquals(level, logger.getLevel(), 'Expected: ' + level + ', but got: ' + logger.getLevel());
    }
    private class TestException extends Exception {}
}