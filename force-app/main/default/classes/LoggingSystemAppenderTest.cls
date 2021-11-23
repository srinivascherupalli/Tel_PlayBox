/**
 * 
 *  CHANGES TO EXISTING FRAMEWORK:
 *---------------------------------
 * AUTHOR      : Anup Kabra
 * DATE        : 21-May-2020
 * DESCRIPTION : Added new method, testDoAppendWithException() to cover 
 *               exception scenario.
 * 
 */
@IsTest
private class LoggingSystemAppenderTest {

    /**
     * @description This test does not contain any assertion, as we cannot mock System.debug().
     * However, it has 2 purposes:
     *   - verify that no exception is thrown
     *   - coverage
     */
    @IsTest
    private static void testDoAppendWithoutException() {
        LoggingSystemAppender appender = new LoggingSystemAppender();
        appender.append(LoggingLevel.INFO, '');
    }
    @IsTest
    private static void testDoAppendWithException() {
        LoggingSystemAppender appender = new LoggingSystemAppender();
        appender.append(NULL, '');
    }
}