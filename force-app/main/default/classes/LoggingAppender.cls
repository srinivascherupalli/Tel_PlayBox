/**
 * @description LoggingAppender used to process logging events.
 *
 */

global interface LoggingAppender {
    /**
     * @description Appends the Logging Event to the logs
     *
     * This method gets called when a LoggingEvent has been produced.
     * The appender is responsible for handling the event and processing it.
     *
     * @param level the log level
     * @param content the log content
     */
    void append(LoggingLevel level, String content);
}