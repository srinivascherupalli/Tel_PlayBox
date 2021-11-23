/**
 * @description LoggingDispatcher sends the logs to the configured appenders
 */
public class LoggingDispatcher {

    private List<LoggingAppender> appenders = new List<LoggingAppender>();

    /**
     * @description dispatch the log to the appenders
     * @param level the log level
     * @param content the log content
     */
    public void dispatch(LoggingLevel level, String content) {
        for (LoggingAppender la: this.appenders) {
            la.append(level, content);
        }
    }

    /**
     * @description calls flush() on all the flushabel appenders
     */
    public void flush() {
        for (LoggingAppender la: this.appenders) {
            if (la instanceof LoggingFlushableAppender) {
                ((LoggingFlushableAppender) la).flush();
            }
        }
    }

    /**
     * @description add an appender to the list of current appenders
     * @param appender the appender to add
     */
    public void addAppender(LoggingAppender appender) {
        if (appender != null) {
            this.appenders.add(appender);
        }
    }
}