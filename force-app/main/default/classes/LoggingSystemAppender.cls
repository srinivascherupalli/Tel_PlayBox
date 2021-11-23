/**
 * @description LoggingAppender which uses System.debug() to process message.
 */
public class LoggingSystemAppender implements LoggingAppender {
    /**
     * @description Process the event.
     *
     * @param level the level of the event to process.
     * @param content the log content
     */
    public void append(LoggingLevel level, String content) {
        if (level == null) {
            // if logging level is null, this appender triggers an internal Salesforce error
            // To prevent this, we set a default logging level and add an error prefix.
            level = LoggingLevel.ERROR;
            System.debug(LoggingLevel.ERROR, '*** LoggingLevel was null ***');
        }
        System.debug(level, content);
    }
}