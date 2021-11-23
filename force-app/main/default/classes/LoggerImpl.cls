/**
 * @description Logger implementation.
 *
 * The default level for the this logger is DEBUG.
 * When a message is logged, it is converted to a LoggingEvent and
 * is passed to each appender for processing.
 *
 * If the level of the message is below the level of this logger then the
 * log is discarded.
 *
 */
public class LoggerImpl implements Logger3 {

    // The no-op builder is a constant to prevent creating a new instance for each log event
    private static final LoggingEventBuilder NOOP_BUILDER = new LoggingEventNoOpBuilder();
    // Reuse the builder to save unecessary instanciations
    private static final LoggingEventBuilderImpl DEFAULT_BUILDER = new LoggingEventBuilderImpl();

    private LoggingLevel threshold;
    private String name;

    // optimisation: memoize threshold levels
    private Boolean errorEnabled;
    private Boolean warnEnabled;
    private Boolean infoEnabled;
    private Boolean debugEnabled;

    /**
     * @description constructor
     *
     * @param name name of the logger.
     * @param level the logger level
     */
    public LoggerImpl(String name, LoggingLevel level) {
        this.name = name;
        this.setLevel(level);
    }

    /**
     * @description returns a LoggingEventBuilder with the specified level
     *
     * @param level the logging level (cannot be null)
     * @return a LoggongEventBuilder with the specified level
     */
    public LoggingEventBuilder build(LoggingLevel level) {
        if (this.threshold.ordinal() > level.ordinal()) {
            return LoggerImpl.NOOP_BUILDER;
        }

        return LoggerImpl.DEFAULT_BUILDER.init(level, this.name);
    }

    /**
     * @description returns a LoggingEventBuilder with a DEBUG level
     * @return a LoggingEventBuilder with a DEBUG level
     */
    public LoggingEventBuilder debug() {
        if (!this.debugEnabled) {
            return LoggerImpl.NOOP_BUILDER;
        }
        return this.build(LoggingLevel.DEBUG);
    }

    /**
     * @description returns a LoggingEventBuilder with a INFO level
     * @return a LoggingEventBuilder with a INFO level
     */
    public LoggingEventBuilder info() {
        if (!this.infoEnabled) {
            return LoggerImpl.NOOP_BUILDER;
        }
        return this.build(LoggingLevel.INFO);
    }

    /**
     * @description returns a LoggingEventBuilder with a WARN level
     * @return a LoggingEventBuilder with a WARN level
     */
    public LoggingEventBuilder warn() {
        if (!this.warnEnabled) {
            return LoggerImpl.NOOP_BUILDER;
        }
        return this.build(LoggingLevel.WARN);
    }

    /**
     * @description returns a LoggingEventBuilder with an ERROR level
     * @return a LoggingEventBuilder with a ERROR level
     */
    public LoggingEventBuilder error() {
        if (!this.errorEnabled) {
            return LoggerImpl.NOOP_BUILDER;
        }
        return this.build(LoggingLevel.ERROR);
    }

    /**
     * @description Returns the logger name
     *
     * @return the logger name
     */
    public String getName() {
        return this.name;
    }

    /**
     * @description Sets the current level of this logger.
     *
     * @param level the level value. if level is null, the current level remains unchanged.
     */
    private void setLevel(LoggingLevel level) {
        if (level != null) {
            this.threshold = level;
            precalculateIndividualThresholdLevels();
        }
    }

    private void precalculateIndividualThresholdLevels() {
        this.errorEnabled = this.isEnabled(LoggingLevel.ERROR);
        this.warnEnabled = this.isEnabled(LoggingLevel.WARN);
        this.infoEnabled = this.isEnabled(LoggingLevel.INFO);
        this.debugEnabled = this.isEnabled(LoggingLevel.DEBUG);
    }

    /**
     * @description Returns the current level of this Logger.
     *
     * @return the current level of this logger.
     */
    public LoggingLevel getLevel() {
        return this.threshold;
    }

    /**
     * @description Logs a message at the DEBUG level.
     *
     * @param message the message to log.
     */
    public void debug(String message) {
        this.debug().write(message);
    }

    /**
     * @description Logs a message at the INFO level.
     *
     * @param message the message to log.
     */
    public void info(String message) {
        this.info().write(message);
    }

    /**
     * @description Logs a message at the WARNING level.
     *
     * @param message the message to log.
     */
    public void warn(String message) {
        this.warn().write(message);
    }

    /**
     * @description Logs a message at the ERROR level.
     *
     * @param message the message to log.
     */
    public void error(String message) {
        this.error().write(message);
    }

    /**
     * @description Captures error/exception details and logs them at the ERROR level.
     *
     * @param severity string.valueof(ExceptionHandlerHelper.Severity.ordinal())
     * @param capability string.valueof(ExceptionHandlerHelper.Capability)
     * @param sourceName string.valueof(ExceptionHandlerHelper.sourceName)
     */
    public void error(String severity, String interfaceName, String elementName, String referenceNumber, 
    String capability, String correlationID, String errorDescription, String destinationSystem, 
    String sourceName, String BusinessDescription, String errorCategory) {

        this.error().writeError(severity, interfaceName, elementName, referenceNumber, capability, correlationID, errorDescription, destinationSystem, sourceName, BusinessDescription, errorCategory);

    }

    public void error(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog){
        this.error().write(excepLog);
    }

    /**
     * @description Returns true if the current level is DEBUG or higher, false otherwise.
     *
     * @return true if the current level is DEBUG or higher, false otherwise.
     */
    public Boolean isDebugEnabled() {
        return this.debugEnabled;
    }

    /**
     * @description Returns true if the current level is INFO or higher, false otherwise.
     *
     * @return true if the current level is INFO or higher, false otherwise.
     */
    public Boolean isInfoEnabled() {
        return this.infoEnabled;
    }

    /**
     * @description Returns true if the current level is WARN or higher, false otherwise.
     *
     * @return true if the current level is WARN or higher, false otherwise.
     */
    public Boolean isWarnEnabled() {
        return this.warnEnabled;
    }

    /**
     * @description Returns true if the current level is ERROR or higher, false otherwise.
     *
     * @return true if the current level is ERROR or higher, false otherwise.
     */
    public Boolean isErrorEnabled() {
        return this.errorEnabled;
    }

    /**
     * @description Returns true if the levelToCheck is equal or above the logger level
     *
     * @param levelToCheck the level to check.
     * @return true if the levelToCheck is equal or above the logger level
     */
    private Boolean isEnabled(LoggingLevel levelToCheck) {
        return isLoggingEnabled()
            && (this.threshold.ordinal() <= levelToCheck.ordinal());
    }

    /**
     * @description Returns true if logging is enabled, false otherwise.
     *
     * Logging is considered enabled when the logger level is
     * different from LoggingLevel.NONE
     *
     * @return  true if logging is enabled, false otherwise.
     */
    private Boolean isLoggingEnabled() {
        return (this.threshold != LoggingLevel.NONE);
    }
}