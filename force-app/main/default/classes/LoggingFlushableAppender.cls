/**
 * @description describe an appender that can be flushed
 */

global interface LoggingFlushableAppender extends LoggingAppender {

    /**
     * @description flush the appender
     */
    void flush();
}