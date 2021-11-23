/**
 * @description Configuration Provider which fetched its values from
 * Custom Metadata
 */
public without sharing class CustomMetadataConfigurationProvider implements LoggerFactoryConfigurationProvider {
    private Map<String, LoggingLevel> levels;
    private List<LoggingAppender> appenders;

    /**
     * @description returns the default logging level.
     * @return the default logging level
     */
    public LoggingLevel getDefaultLevel() {
        LoggingLevel defaultLevel = this.getLoggerLevels().get('default_logger_level');
        if (defaultLevel == null) {
            defaultLevel = LoggingLevel.ERROR;
        }
        return defaultLevel;
    }

    /**
     * @description returns the configured loggerlevels
     * @return the configured loggerlevels
     */
    public Map<String, LoggingLevel> getLoggerLevels() {
        if (this.levels == null) {
            this.loadLevels();
        }
        return new Map<String, LoggingLevel>(this.levels);
    }

    /**
     * @description return the configured appenders
     * @return the configured appenders
     */
    public List<LoggingAppender> getAppenders() {
        if (this.appenders == null) {
            this.loadAppenders();
        }
        return new List<LoggingAppender>(this.appenders);
    }

    private void loadAppenders() {
        this.appenders = new List<LoggingAppender>();
        for (Default_Logger_Factory_Appender__mdt appender : [SELECT MasterLabel, Enabled__c FROM Default_Logger_Factory_Appender__mdt WHERE Enabled__c=true]) {
            LoggingAppender a = this.createAppender(appender.MasterLabel);
            if (a != null) {
                appenders.add(a);
            }
        }
    }

    private void loadLevels() {
        this.levels = new Map<String, LoggingLevel>();
        for (Logger_Setting__mdt ls : [SELECT MasterLabel, Logging_Level__c FROM Logger_Setting__mdt]) {
            if (ls.Logging_Level__c != null) {
                this.levels.put(ls.MasterLabel, this.levelForName(ls.Logging_Level__c));
            }
        }
    }

    private LoggingLevel levelForName(String levelName) {
        for (LoggingLevel ll: LoggingLevel.values()) {
            if (ll.name() == levelName) {
                return ll;
            }
        }
        return this.getDefaultLevel();
    }

    private LoggingAppender createAppender(String typeName) {
        Type t = Type.forName(typeName);
        if (t == null) {
            System.debug(LoggingLevel.WARN, 'Unknown LoggingAppender Type: ' + typeName);
            return null;
        }
        try {
            Object app = t.newInstance();
            return (LoggingAppender) app;
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Could not instantiate class, or instance is not a LoggingAppender: ' + t.getName() + '. ' + e.getMessage());
            return null;
        }
    }
}