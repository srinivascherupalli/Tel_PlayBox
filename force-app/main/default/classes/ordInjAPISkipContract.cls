/*********************************************************************************************************************************
Class Name: ordInjAPISkipContract
Test Class: ordInjAPISkipContractTest
Description:TON: Skip Contract API
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.        Ritika Gupta             5-Aug-2021   DIGI-370- TON: Skip Contract API
2.        Gokul P                  29-Oct-2021  DIGI-34844 - <TED-81> CHange in skipContract payload & TON Product Configuration look-up from Secondary MSISDN Number Record -
**********************************************************************************************************************************/

public with sharing class ordInjAPISkipContract {
    public static final String HANDLER = 'skipContract';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);

    //DIGI-370 starts
    public static RestResponse skipContract(RestRequest request){
        string correlationId = '';
        RestResponse finalRes;
        Map<String, Object> dataMap = null;//DIGI-34844
          
        try{
            //DIGI-34844 - Starts
            String jsonString = request.requestBody.toString().replaceAll('^\\p{IsWhite_Space}+|\\p{IsWhite_Space}+$','');
            jsonString = jsonString.normalizeSpace();
            dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                String guid;
                List<Object> entriesArray =( List<Object> ) dataMap.get('solutions');
                for(Object inidividualEntries : entriesArray){
                    Map<String,Object> inside = (Map<String,Object> )inidividualEntries;
                    List<Object> entriesArray2 =( List<Object> ) inside.get('components');
                    for (Object inidividualEntries2: entriesArray2 ){
                        Map<String,Object> inside2 = (Map<String,Object>)inidividualEntries2;
                        List<Object> entriesArray3 = (List<Object>) inside2.get('configurations');
                        for (Object inidividualEntries3 : entriesArray3){
                            Map<String,Object> inside3 = (Map<String,Object>)inidividualEntries3;      
                            for(Object inidividualEntries4 : (List<Object>)inside3.get('relatedProducts')){
                                Map<String,Object> inside4 = (Map<String,Object>)inidividualEntries4;
                                if(inside4.get('relatedProductName') == 'Telstra One Number'){
                                    guid = String.valueOf(inside4.get('guid'));
                                }
                            }
                        }   
                    }
                }  
                system.debug('guid++'+guid);
            //DIGI-34844 ends
            correlationId = ordInjAPICreateOrder.getCorrelationId(request);
            OC_SessionPayloadValidation.addSessionData(correlationId, 'skipContract', 'TonGUID',guid );//DIGI-34844
            finalRes= ordInjAPICreateOrder.validateData(correlationId, 'pollAsyncGetConfig', 'skipContract');
        }
        catch(exception ex){
            system.debug('Exception occured in skipContract:' + ex.getMessage() + 'Line' + ex.getLineNumber());
           // logger.logMessages('skipContract exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);                    
            //logger.exitLogger();
        }
        return finalRes;
    }
    //DIGI-371 ends
}