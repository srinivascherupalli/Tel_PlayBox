/**
 * @description Common interface for logger implementations.
 *
 * Note: All the levels defined in System.LoggingLevel are supported. The interface
 * does restrict the usage of FINE, FINER and FINEST level through its API, making
 * DEBUG the highest level usable.
 *
 */

global interface Logger3 {
    /**
     * @description Returns the logger name
     *
     * @return the logger name
     */
    String getName();

    /**
     * @description Returns the current level of this Logger.
     *
     * @return the current level of this logger.
     */
    LoggingLevel getLevel();

    /**
     * @description Logs a message at the DEBUG level.
     *
     * @param message the message to log.
     */
    void debug(String message);

    /**
     * @description returns a LoggingEventBuilder with a DEBUG level.
     *
     * @return a LoggingEventBuilder with a DEBUG level
     */
    LoggingEventBuilder debug();

    /**
     * @description Logs a message at the INFO level.
     *
     * @param message the message to log.
     */
    void info(String message);

    /**
     * @description returns a LoggingEventBuilder with an INFO level.
     *
     * @return a LoggingEventBuilder with an INFO level
     */
    LoggingEventBuilder info();

    /**
     * @description Logs a message at the WARNING level.
     *
     * @param message the message to log.
     */
    void warn(String message);

    /**
     * @description returns a LoggingEventBuilder with a WARN level.
     *
     * @return a LoggingEventBuilder with a WARN level
     */
    LoggingEventBuilder warn();

    /**
     * @description Logs a message at the ERROR level.
     *
     * @param message the message to log.
     */
    void error(String message);

    /**
     * @description This method captures error/exeption details and logs them at the ERROR level.
     *
     * @param severity string.valueof(ExceptionHandlerHelper.Severity.ordinal())
     * @param capability string.valueof(ExceptionHandlerHelper.Capability)
     * @param sourceName string.valueof(ExceptionHandlerHelper.sourceName)
     */
    void error(String severity, String interfaceName, String elementName, String referenceNumber, 
        String capability, String correlationID, String errorDescription, String destinationSystem, 
        String sourceName, String BusinessDescription, String errorCategory);
        
    void error(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog);
    /**
     * @description returns a LoggingEventBuilder with an ERROR level.
     *
     * @return a LoggingEventBuilder with an ERROR level
     */
    LoggingEventBuilder error();

    /**
     * @description Returns true if the current level is DEBUG or higher, false otherwise.
     *
     * @return true if the current level is DEBUG or higher, false otherwise.
     */
    Boolean isDebugEnabled();

    /**
     * @description Returns true if the current level is INFO or higher, false otherwise.
     *
     * @return true if the current level is INFO or higher, false otherwise.
     */
    Boolean isInfoEnabled();

    /**
     * @description Returns true if the current level is WARN or higher, false otherwise.
     *
     * @return true if the current level is WARN or higher, false otherwise.
     */
    Boolean isWarnEnabled();

    /**
     * @description Returns true if the current level is ERROR or higher, false otherwise.
     *
     * @return true if the current level is ERROR or higher, false otherwise.
     */
    Boolean isErrorEnabled();
}