/**
 * @description Logging Event Builder that doesn't do anything.
 */
public class LoggingEventNoOpBuilder implements LoggingEventBuilder {
    /**
     * @description adds a property to the logging event
     * @param key not used
     * @param value not used
     * @return itself
     */
    public LoggingEventBuilder property(String key, Object value) {
        return this;
    }

    /**
     * @description does nothing
     * @param ex not used
     * @return itself
     */
    public LoggingEventBuilder exception(Exception ex) {
        return this;
    }

    /**
     * @description does nothing
     * @param message not used
     */
    public void write(string message) {
        // does nothing
    }

    /**
     * @description does nothing
     * params are not used
     */
    public void writeError(String severity, String interfaceName, String elementName, String referenceNumber, 
    String capability, String correlationID, String errorDescription, String destinationSystem, 
    String sourceName, String BusinessDescription, String errorCategory) {
        // does nothing
    }  

    public void write(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog) {
        //does nothing
    }
    /**
     * @description does nothing
     */
    public void write() {
        // does nothing
    }
}