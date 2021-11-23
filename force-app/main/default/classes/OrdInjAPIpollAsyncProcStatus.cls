/*********************************************************************************************************************************
Class Name: OrdInjAPIpollAsyncProcStatus
Test Class Name: 
Description: 
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.       Nikhil Kumar           24.09.2021          DIGI-9360
*********************************************************************************************************************************
*/
    global with sharing class OrdInjAPIpollAsyncProcStatus{
    public static final String HANDLER = 'OrdInjAPIpollAsyncProcStatus';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
    public static RestResponse pollAsyncGetConfig(RestRequest request){
    string correlationId = '';
    RestResponse finalRes;
    try{
        correlationId = ordInjAPICreateOrder.getCorrelationId(request);
        finalRes= ordInjAPICreateOrder.validateData(correlationId, 'herokuMACDSolution','pollAsyncGetConfig');
    }
    catch(exception ex){
        system.debug('Exception occured in createMACDSolutinOnHeroku:' + ex.getMessage() + 'Line' + ex.getLineNumber());
    //       logger.logMessages('ordInjAPIAddSolution exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);
    //    logger.exitLogger();
    }
return finalRes;
    }
}