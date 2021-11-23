/*********************************************************************************************************************************
Class Name: ordInjAPICreateOrder
Test Class: ordInjAPICreateOrderTest
Description:Create Order API to support Telstra Now SIM Replacement online requests.
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.        Pooja Gupta             16-March-2021   EDGE-209789- Create Order API to support Telstra Now SIM Replacement online requests 
2.        Pooja Gupta             19-April-2021   EDGE-207465- Update Services API to support Telstra Now SIM Replacement online requests.
3.        Ritika Gupta            06-08-2021      DIGI-370- TON: Skip Contract API
4.        Nikhil Kumar            17-09-2021      DIGI-11618- TON: herokuMACDSolution API
5.        Ameer & Gokul           17-09-2021      DIGI-16926 & DIGI-16902
6.        Nikhil Kumar            30-09-2021      DIGI-9360- TON: getConfig API Processing logic
7.        Gokul P                 25-Sept-2021    DIGI-475 - TON Submitt order processing Logic
8.        Gokul P                 29-Oct-2021     DIGI-34844 -<TED-81> CHange in skipContract payload & TON Product Configuration look-up from Secondary MSISDN Number Record-

**********************************************************************************************************************************/

public with sharing class ordInjAPICreateOrder {
    public static final String HANDLER = 'ordInjAPICreateOrderHandler';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
    /*********************************************************************************************************************************
    Method Name: createOrder
    Description: Method to create order and order request after successfull validation of the incoming request.
    Author: Pooja Gupta             
    Date: 16-March-2021 
    **********************************************************************************************************************************/   
    public static RestResponse createOrder(RestRequest request){
        string correlationId = '';
        RestResponse finalRes;
        system.debug('request' + request);
        try{
            correlationId = ordInjAPICreateOrder.getCorrelationId(request);
            finalRes= validateData(correlationId, 'validateData', 'createOrder');
        }
        catch(exception ex){
            system.debug('Exception occured in ordInjAPICreateOrder:' + ex.getMessage() + 'Line' + ex.getLineNumber());
            logger.logMessages('ordInjAPICreateOrder exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);                    
            logger.exitLogger();
        }
        return finalRes; 
    }
    
    /*********************************************************************************************************************************
    Method Name: getCorrelationId
    Description: Method to get correlationID from the request.
    Author: Pooja Gupta             
    Date: 14-April-2021 
    **********************************************************************************************************************************/
    public static string getCorrelationId(RestRequest request){
        string correlationId = '';
        Map<String, Object> dataMap = new Map<String, Object>();
        try{
            if(request.requestBody != null){
                string  jsonString = request.requestBody.toString().replaceAll('^\\p{IsWhite_Space}+|\\p{IsWhite_Space}+$','');
                jsonString = jsonString.normalizeSpace();
                system.debug('jsonString**' + jsonString);
                dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                system.debug('dataMap' + dataMap);
            }
            
            if(!dataMap.isEmpty() && dataMap!=null && dataMap.containsKey('CorrelationId__c')){
                correlationId = (string) dataMap.get('CorrelationId__c');
                system.debug('correlationId' + correlationId);   
            }
        }
        catch(exception ex){
            system.debug('Exception occured in getCorrelationId:' + ex.getMessage() + 'Line' + ex.getLineNumber()); 
        }
        return correlationId;
    }
    
/*********************************************************************************************************************************
Method Name: submitOrder
Description: method to call SubmitOrder API
Author: Gokul P            
Date: 17- Sep-2021 
**********************************************************************************************************************************/   
public static RestResponse submitOrder(RestRequest request){
    string correlationId = '';
    RestResponse finalRes;
    system.debug('request' + request);
    try{
        correlationId = ordInjAPICreateOrder.getCorrelationId(request);
        finalRes= validateData(correlationId, 'basketEnrichment', 'submitOrder');
    }
    catch(exception ex){
        system.debug('Exception occured in ordInjAPICreateOrder:' + ex.getMessage() + 'Line' + ex.getLineNumber());
        logger.logMessages('ordInjAPICreateOrder exception', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage()+';'+ex.getLineNumber(), false, false);                    
        logger.exitLogger();
    }
    return finalRes; 
}
    
    /*********************************************************************************************************************************
    Method Name: getMasterDataFromSession
    Description: Method to get session data.
    Author: Pooja Gupta             
    Date: 20-April-2021 
    **********************************************************************************************************************************/
    public static Map<string, string> getMasterDataFromSession(string correlationId, string methodName){
        Map<String, string> cachedDataMap = new Map<String, string>();
        // Retrieve cache value from session cache
        Map<String, object> cachedData = OC_SessionPayloadValidation.getSessionData(correlationId, methodName);
        system.debug('cachedData' + cachedData);
        try{
            if(cachedData != null){
		        cachedDataMap.put('TonGUID', ((String)cachedData.get('TonGUID')));//DIGI-34844
            	cachedDataMap.put('secondayMSDIDN', ((String)cachedData.get('SecondaryMSDN')));//DIGI-34844
                cachedDataMap.put('Order_Rec_Id', ((String)cachedData.get('Order_Rec_Id')));
                cachedDataMap.put('AccountId', ((String)cachedData.get('AccountId__c')));
                cachedDataMap.put('ReferenceNumber', ((String)cachedData.get('ReferenceNumber__c')));
                cachedDataMap.put('OwnerId', ((String)cachedData.get('OwnerId__c')));
                cachedDataMap.put('Reason', ((String)cachedData.get('Reason__c')));
                cachedDataMap.put('correlationId', ((String)cachedData.get('CorrelationId__c')));
                cachedDataMap.put('ActionType', ((String)cachedData.get('ActionType__c')));
                cachedDataMap.put('BasketId',((String)cachedData.get('Basket_Id__c')));//DIGI-11618
                cachedDataMap.put('SolutionId',((String)cachedData.get('Solution_Id__c')));//DIGI-11618
                cachedDataMap.put('TargetSolutionId',((String)cachedData.get('targetSolutionId')));//DIGI-11618
                cachedDataMap.put('serviceMSISDN', ((String)cachedData.get('Service MSIDN')));//DIGI-11618
                cachedDataMap.put('OldSolutionId', ((String)cachedData.get('oldsolutionId')));//DIGI-11618
                cachedDataMap.put('TargetBasketId', ((String)cachedData.get('targetBasketId')));//DIGI-11618
               if(methodName.equalsIgnoreCase('updateServices')){
                   cachedDataMap.put('orderId', (String)(cachedData.get('id')));
                   cachedDataMap.put('orderRequest', (String)(cachedData.get('orderRequest')));
                   cachedDataMap.put('orderNumber', (String)(cachedData.get('orderNumber')));
                   cachedDataMap.put('services', (String)cachedData.get('services'));   
                } 
                system.debug('cachedDataMap' + cachedDataMap);
            }
        }
        catch(exception ex){
            system.debug('Exception occured in getMasterDataFromSession:' + ex.getMessage() + 'Line' + ex.getLineNumber()); 
        }
        return cachedDataMap;
    }
    
    /*********************************************************************************************************************************
    Method Name: validateData
    Description: Utility method to validate data and perform futher processes..
    Author: Pooja Gupta             
    Date: 20-April-2021 
    **********************************************************************************************************************************/
    
    public static RestResponse validateData(string correlationId, string step, string methodName){
        Map<String, string> cachedDataMap = new Map<String, string>();
        Map<string, string> responseMap = new Map<string, string>();
	Map<String,String> resultMap = new Map<String,String>();//DIGI-16902
        
        try{
            Map<string, string> validationRes = validationController.validateRequest(correlationId, step);
            switch on validationRes.get('code')  {
                when '200'{
                    cachedDataMap = ordInjAPICreateOrder.getMasterDataFromSession(correlationId, methodName);
                    if(cachedDataMap != null && methodName == 'updateServices') {
                        responseMap = orderDMLController.updateServicesData(cachedDataMap);
                    }
                    //DIGI-16902&DIGI-16926 starts                
                    else if(methodName == 'createBasket'){
                        if(cachedDataMap.get('ActionType') == 'Opportunity Less Basket'){
                        responseMap = orderDMLController.createMACDSolution(cachedDataMap);
                        
                        }
                        else{
                            resultMap.put('code','400');
                            resultMap.put('status','Failed');  
                            resultMap.put('description','create Basket with oppty is in future scope');
                            system.debug('Exception occured:');
                        }
                    }
                    //DIGI-16902&DIGI-16926 Ends
    
                    //DIGI-370 Starts
                    else if(methodName == 'skipContract'){
                        responseMap = orderDMLController.skipContractForBasket(cachedDataMap);
                    }
                    //DIGI-370 Ends

                    //DIGI-11618 Starts
                    else if(methodName == 'herokuMACDSolution'){
                        responseMap = orderDMLController.createHerokuMACDSolution(cachedDataMap);
                     }
                     //DIGI-11618 Ends

                    //DIGI-9360 Starts
                      else if(methodName == 'pollAsyncGetConfig'){
                        responseMap = orderDMLController.getConfigurationSolution(cachedDataMap);
                      }
                   //DIGI-9360 Ends
                   //DIGI-475 Starts
                  else if(methodName == 'submitOrder'){
                    String orderid = cachedDataMap.get('Order_Rec_Id');
                        system.debug('orderid'+orderid);
                        responseMap=orderDMLController.submitOrderMain(cachedDataMap);
                    }
                  //DIGI-475 Ends
    
                    else{
                        responseMap = orderDMLController.createOrderRecord(cachedDataMap);
                    }
                }
                
                when else{
                    return OrderInjectionUtility.generateResponse(RestContext.response,validationRes , null);                                
                }
            }
            switch on responseMap.get('code')  {
                when '200'{
                    system.debug('step' + step );
                    if (cachedDataMap != null && cachedDataMap.containsKey('orderId') && methodName == 'updateServices') {
                        orderDMLController.submitOrder((String)cachedDataMap.get('orderId'));
                        OC_SessionPayloadValidation.clearSession(correlationId, methodName);
                    }
                    else{
                        system.debug('here inside else');
                        OC_SessionPayloadValidation.addSessionData(correlationId, methodName, responseMap); 
                        OC_SessionPayloadValidation.stepResult(correlationId, methodName , true);
                    }  
                }
                when else{
                    return OrderInjectionUtility.generateResponse(RestContext.response, responseMap , null);
                }
            }
        }
        
        catch(exception ex){
            system.debug('Exception occured in validateRequest:' + ex.getMessage() + 'Line' + ex.getLineNumber());
        }
        return OrderInjectionUtility.generateResponse(RestContext.response,responseMap , null);
    }
    }