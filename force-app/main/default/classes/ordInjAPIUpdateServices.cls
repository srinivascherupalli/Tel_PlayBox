/*********************************************************************************************************************************
Class Name: ordInjAPIUpdateServices
Test Class: ordInjAPIUpdateServicesTest
Description:Update Services API to support Telstra Now SIM Replacement online requests.
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.        Pooja Gupta             19-April-2021   EDGE-207465- Update Services API to support Telstra Now SIM Replacement online requests.
**********************************************************************************************************************************/

public with sharing class ordInjAPIUpdateServices {
    //public static final String HANDLER = 'ordInjAPIUpdateServicesHandler';
    //public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
    /*********************************************************************************************************************************
Method Name: updateServices
Description: Method to update services and submit order after validation.
Author: Pooja Gupta             
Date: 19-April-2021 
**********************************************************************************************************************************/  
    public static RestResponse updateServices(RestRequest request){
        RestResponse finalRes;
        string correlationId = '';
       // try{
            correlationId = ordInjAPICreateOrder.getCorrelationId(request);
            finalRes= ordInjAPICreateOrder.validateData(correlationId, 'createOrder', 'updateServices');
        // }
        // catch(exception ex){
        //     system.debug('Exception occured in updateServices:' + ex.getMessage() + 'Line' + ex.getLineNumber());
        //     logger.logMessages('ordInjAPIUpdateServices exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);                    
        //     logger.exitLogger();
        // }
        system.debug('finalRes' + finalRes.responseBody.toString());
        return finalRes;
    } 
}