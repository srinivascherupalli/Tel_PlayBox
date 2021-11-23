/**
 * @description tests for LoggingContext
 */
@IsTest(isParallel=true)
private class LoggingContextTest {

    @IsTest
    private static void testPut() {
        LoggingContext.put('foo', 'bar');
        System.assertEquals(1, LoggingContext.getMapping().size(), 'Context should only have 1 item');
        System.assertEquals('bar', LoggingContext.get('foo'), 'Context should contain "foo" with a value of "bar"');
    }

    @IsTest
    private static void testPutWithNullKey() {
        LoggingContext.put(null, 'bar');
        System.assertEquals(0, LoggingContext.getMapping().size(), 'Context should be empty');
    }

    @IsTest
    private static void testRemove() {
        LoggingContext.put('foo', 'bar');
        System.assertEquals(1, LoggingContext.getMapping().size(), 'Context should only have 1 item');
        System.assertEquals('bar', LoggingContext.get('foo'), 'Context should contain "foo" with a value of "bar"');
        LoggingContext.remove('foo');
        System.assertEquals(0, LoggingContext.getMapping().size(), 'Context should be empty');

    }
}