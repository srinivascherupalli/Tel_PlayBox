/*********************************************************************************************************************************
Class Name: ordInjAPIherokuMACDSolution
Test Class Name: 
Description: 
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.       Nikhil Kumar           17.09.2021          DIGI-11618
*********************************************************************************************************************************
*/
	global with sharing class ordInjAPIherokuMACDSolution{
    public static final String HANDLER = 'ordInjAPIherokuMACDSolution';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
	public static RestResponse pushHerokuMACDSolution(RestRequest request){
    string correlationId = '';
    RestResponse finalRes;
    try{
        correlationId = ordInjAPICreateOrder.getCorrelationId(request);
        finalRes= ordInjAPICreateOrder.validateData(correlationId, 'createBasket','herokuMACDSolution');
    }
    catch(exception ex){
        system.debug('Exception occured in createMACDSolutinOnHeroku:' + ex.getMessage() + 'Line' + ex.getLineNumber());
          // logger.logMessages('ordInjAPIAddSolution exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);
       // logger.exitLogger();
    }
return finalRes;
}

    }