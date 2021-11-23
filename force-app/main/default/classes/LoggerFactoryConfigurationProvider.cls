/**
 * @description Configuration Provider for LoggerFactory
 */

global interface LoggerFactoryConfigurationProvider {
    /**
     * @description returns the configured LoggingLevel by Logger name
     * @return the configured LoggingLevel by Logger name (cannot be null)
     */
    Map<String, LoggingLevel> getLoggerLevels();

    /**
     * @description returns the configured appenders
     * @return the configured appenders
     */
    List<LoggingAppender> getAppenders();

    /**
     * @description returns the default logger level
     * used for loggers that are not present in getLoggerLevels()
     * @return the default logger level
     */
    LoggingLevel getDefaultLevel();
}