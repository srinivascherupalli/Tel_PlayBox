@IsTest(isParallel=true)
private class LoggingEventNoOpBuilderTest {

    @IsTest
    private static void testProperty() {
        LoggingEventBuilder builder = new LoggingEventNoOpBuilder();
        System.assertEquals(builder, builder.property('foo', 'bar'), 'should return the builder');
    }

    @IsTest
    private static void testException() {
        LoggingEventBuilder builder = new LoggingEventNoOpBuilder();
        System.assertEquals(builder, builder.exception(new TestException()), 'should return the builder');
    }

    /**
     * @description This test does not contain any assertion, as the write method do nothing.
     * However, it has 2 purposes:
     *   - verify that no exception is thrown
     *   - coverage
     */
    @IsTest
    private static void testWrite() {
        LoggingEventBuilder builder = new LoggingEventNoOpBuilder();
        builder.write();
        builder.write('foo');
    }

    private class TestException extends Exception {}
}