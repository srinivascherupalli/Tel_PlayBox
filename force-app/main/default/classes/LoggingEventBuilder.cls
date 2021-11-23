/**
 * @description Interface for a logging event builder.
 */

global interface LoggingEventBuilder {

    /**
     * @description adds a propetry to the builder
     * @param key the key
     * @param value the value
     * @return itself
     */
    LoggingEventBuilder property(String key, Object value);

    /**
     * @description adds an exception to the logging event
     * @param ex the exception
     * @return itself
     */
    LoggingEventBuilder exception(Exception ex);

    /**
     * @description create and dispatch the logging event with the given message.
     * @param message the message to add
     */
    void write(String message);

    /**
     * @description create and dispatch the logging event with the given error/exception details.
     * 
     * @param severity string.valueof(ExceptionHandlerHelper.Severity.ordinal())
     * @param capability string.valueof(ExceptionHandlerHelper.Capability)
     * @param sourceName string.valueof(ExceptionHandlerHelper.sourceName)
     */
    void writeError(String severity, String interfaceName, String elementName, String referenceNumber, 
    String capability, String correlationID, String errorDescription, String destinationSystem, 
    String sourceName, String BusinessDescription, String errorCategory);

    void write(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog);
    /**
    * @description create and dispatch the logging event without any message.
    */
    void write();
}