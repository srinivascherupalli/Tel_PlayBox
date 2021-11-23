/**
* @description Inserts record into Transaction Log object
*
* @author   Anup Kabra
* @version  1.0
* @since    21/05/2020
* @link     https://git02.ae.sda.corp.telstra.com/projects/SBC/repos/b2c-common-dx/browse
*
*/
public without sharing class LoggingDBAppender implements LoggingFlushableAppender {

    private List<String> events = new List<String>();
    private Boolean hasError = false;
    private Boolean hasWarning = false;
    private Integer LogMaxLength = 131071;
    public static Boolean disableCurrentInstanceLog = False;

    /**
     * @description appends the event to the system logs.
     * @param level the event level
     * @param content the log content
     */
    public void append(LoggingLevel level, String content) {
        if (level == LoggingLevel.ERROR) {
            this.hasError = true;
        }

        if (level == LoggingLevel.WARN) {
            this.hasWarning = true;
        }

        this.events.add(content);
    }

    /**
     * @description Inserts log and should work regardless of the users CRUD permissions
     */
    public void flush() {
        if (this.events.isEmpty() || disableCurrentInstanceLog) {
            return;
        }
        try {
            String joinString = String.join(events, '\n');
            if(joinString.length() > LogMaxLength ){
                joinString = joinString.substring(0, LogMaxLength);
            }
            Transaction_log__c  log   = new Transaction_log__c();
            log.HasWarning__c         = this.hasWarning;
            log.HasError__c           = this.hasError;
            log.CorrelationId__c      = LoggingContext.CONTEXT_ID;
            log.Transaction_Log__c    = joinString;
            insert log;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
        } finally {
            this.events.clear();
        }
    }
}