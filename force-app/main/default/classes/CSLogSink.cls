global class CSLogSink implements cscfga.Log.Sink {
    global void logMessage(LoggingLevel level, String message){
        System.debug(level, message);
    }
}