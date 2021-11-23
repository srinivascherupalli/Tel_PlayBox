/**
 * @description Creates Logger instances and manage LoggingAppenders.
 *
 * To get a logger instance for your class, use the following snippet
 *
 * <code>
 *     public class MyClass {
 *         private static Logger logger = LoggerFactory.getLogger(MyClass.class);
 *         (...)
 *     }
 * </code>
 *
 * CHANGES TO EXISTING FRAMEWORK:
 *---------------------------------
 * AUTHOR      : Anup Kabra
 * DATE        : 21-May-2020
 * DESCRIPTION : As part of project requirement, correlation ID will be sent from Apex
 * 				 instead of using the one which framework generates in LoggingContext class.
 * 				 flush() method of this class is updated to accept a parameter which is
 * 				 correlation ID and assign it to CONTEXT_ID variable of LoggingContext class
 * 				 which is then used while Inserting record to Transaction Log object.
 *
 */

global class LoggerFactory {

    private static LoggerFactory instance;

    private LoggingLevel defaultLevel;
    private Map<String, LoggingLevel> levels;
    private Map<String, Logger3> loggers;
    private LoggingDispatcher dispatcher;

    /**
     * @description contructor
     * @param conf the configuration provider
     */
    global LoggerFactory(LoggerFactoryConfigurationProvider conf) {
        this.loggers = new Map<String, Logger3>();
        this.defaultLevel = conf.getDefaultLevel();
        this.levels = conf.getLoggerLevels();
        this.dispatcher = new LoggingDispatcher();
        List<LoggingAppender> appenders = conf.getAppenders();
        if (appenders != null) {
            for (LoggingAppender a: conf.getAppenders()) {
                this.dispatcher.addAppender(a);
            }
        }
    }

    /**
     * @description Sets and returns a loggerFactory instance. A new instance is created if needed.
     *
     * @return a LoggerFactory
     */
    global static LoggerFactory getInstance() {
        if (instance == null) {
            instance = new LoggerFactory(new CustomMetadataConfigurationProvider());
        }
        return instance;
    }

    /**
     * @description sets the global factory instance
     * @param factory the factory instance
     */
    global static void setInstance(LoggerFactory factory) {
        LoggerFactory.instance = factory;
    }

    /**
     * @description Returns a logger instance. A new instance is created if needed.
     *
     * @param clazz the logger name will be set to this class name.
     * @return a Logger
     */
    global static Logger3 getLogger(System.Type clazz) {
        return LoggerFactory.getLogger(clazz.getName());
    }

    /**
     * @description Returns a logger instance. A new instance is created if needed.
     *
     * @param name the logger name will be set to this class name.
     * @return a Logger
     */
    global static Logger3 getLogger(String name) {
        LoggerFactory factory = LoggerFactory.getInstance();
        Logger3 logger = factory.loggers.get(name);

        if (logger == null) {
            logger = new LoggerImpl(name, factory.getLevelForLogger(name));
            factory.loggers.put(name, logger);
        }

        return logger;
    }

    /**
     * @description Adds an appender to the existing list of appenders.
     *
     * @param appender the logging appender to be appended
     */
    global static void addAppender(LoggingAppender appender) {
        LoggerFactory.getInstance()
            .dispatcher
            .addAppender(appender);
    }

    /**
     * @description Calls flush() on all appenders.
     * 
     * CHANGE => [ANUP] This method is changed to accept parameter which is
     * 			  assigned to CONTEXT_ID variable of LoggingContext class.
     */
    global static void flush(string correlationIDFromUI) {
        LoggingContext.CONTEXT_ID = correlationIDFromUI;
        LoggerFactory.getInstance()
            .dispatcher
            .flush();
    }

    /**
     * @description dispatches the log to the appenders
     * @param level the level of the log
     * @param content the log content
     */
    public static void dispatch(LoggingLevel level, String content) {
        LoggerFactory.getInstance()
            .dispatcher
            .dispatch(level, content);
    }

    /**
     * @description Returns the LoggingLevel for a given logger name
     *
     * The first time this method is called the loggerLevels are loaded and
     * and stored locally from custom metada.
     * If there is no LoggingLevel stored in the loggerLevel the default
     * Level is returned
     *
     * @param loggerName of the logger.
     * @return LoggingLevel
     */
    private LoggingLevel getLevelForLogger(String loggerName) {
        LoggerFactory factory = getInstance();
        LoggingLevel level = factory.levels.get(loggerName);
        if (level == null) {
            level = factory.defaultLevel;
        }
        return level;
    }
}