/*********************************************************************************************************************************
Class Name: OrderInjectionAPIController
Test Class Name: OrderInjectionAPIControllerTest
Description: Exposing API for validate data for Order Injection.
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.        Arinjay Singh           12-April-2021   EDGE-207626- Exposing API for validate data for Order Injection.
2.        Pooja Gupta             14-April-2021   EDGE-209789- Create Order API to support Telstra Now SIM Replacement online requests.
3.        Pooja Gupta             19-April-2021   EDGE-207465- Update Services API to support Telstra Now SIM Replacement online requests.
4.        Ritika Gupta            5-Aug-2021      DIGI-370- TON: Skip Contract API
5.        Nikhil Kumar            17-Sep-2021     DIGI-11618- TON: herokuMACDSolution API
6.        Ameer Basha             17-Sept-2021      DIGI-16902:TON Adding Branching Logic for Oppty Less Basket.
8.		  Arun V				  27-sept-2021	  DIGI-9361 -TON Enrich basket and create order
7.        Nikhil Kumar            30-Sep-2021     DIGI-9360- TON: getConfig API Processing logic
8.        Gokul P                 25-Sept-2021    DIGI-475 -  TON Submitt order processing Logic
*********************************************************************************************************************************
*/
@RestResource(urlMapping='/v1/orderInjectionAPI/*')
global with sharing class OrderInjectionAPIController {
    public static final String HANDLER = 'orderInjectionAPIControllerHandler';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
    @HttpPost
    global static void  doPost(){ 
        RestRequest request = RestContext.request; 
        RestResponse response = RestContext.response;
        String requestType = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        if(requestType.equalsIgnoreCase('validateData')){
            OrdInjAPIDataValidator ordInjAPIDataValidatorObj = new OrdInjAPIDataValidator();
            response = ordInjAPIDataValidatorObj.validateData(request);
            logRequestResponse(response,request);
        }
        //EDGE-209789 starts
        else if(requestType.equalsIgnoreCase('createOrder')){
            response = ordInjAPICreateOrder.createOrder(request);
            logRequestResponse(response,request);
        }
        //EDGE-209789 ends
        
        //EDGE-207465 starts
        else if(requestType.equalsIgnoreCase('updateServices')){
            response = ordInjAPIUpdateServices.updateServices(request);
            logRequestResponse(response,request);
        }
        //EDGE-207465 ends
        
        //DIGI-16902 starts
        else if(requestType.equalsIgnoreCase('createBasket')){
            response = ordInjAPIcreateBaskeTnSolution.createBaskeTnSolution(request);
            logRequestResponse(response,request);
            
        }
        //DIGI-16902 ends
        
        //DIGI-370 Starts
        else if(requestType.equalsIgnoreCase('skipContract')){    
            response = ordInjAPISkipContract.skipContract(request);
            logRequestResponse(response,request);
        }
        //DIGI-370 ends

        //DIGI-11618 Starts
          else if(requestType.equalsIgnoreCase('herokuMACDSolution')){
            response = ordInjAPIherokuMACDSolution.pushHerokuMACDSolution(request);
            logRequestResponse(response,request);
        }
        //DIGI-11618 Ends
        //DIGI-9361 Starts
        else if(requestType.equalsIgnoreCase('basketEnrichment')){
            response = ordInjAPIenrichBaskeTnCreateOrder.enrichBaskeTnCreateOrder(request);
            logRequestResponse(response,request);
        }        
        //DIGI-9361 Ends
        //DIGI-475 starts
        else if(requestType.equalsIgnoreCase('submitOrder')){
            response = ordInjAPICreateOrder.submitOrder(request);
            logRequestResponse(response,request);
        }
       //DIGI-475 Ends      

        //DIGI-9360 Starts
        else if(requestType.equalsIgnoreCase('PollAsyncProcStatus')){
            response = OrdInjAPIpollAsyncProcStatus.pollAsyncGetConfig(request);
            logRequestResponse(response,request);
        }        
        //DIGI-9360 Ends
        else {
            Map<String,String> responseMap = new Map<String,String>();
            responseMap.put('status','failure');
            responseMap.put('code','404');
            responseMap.put('message','Invalid Request');   
            responseMap.put('Description',''); 
            OrderInjectionUtility.generateResponse(RestContext.response, responseMap, null);
            logRequestResponse(RestContext.response,RestContext.request); 
        } 
    }

/**
* @Story  : EDGE-207465
* @Author : Pooja Gupta
* @Description : Utility method to log the request and response in application logs 
* @Date : 05/May/2021
*/
    global static void logRequestResponse(RestResponse response, RestRequest request) {
        logger.logMessages(request.requestBody.toString(),response.responseBody.toString(), '', '', '', '', false, false, Integer.valueOf(response.statusCode),'','', ''); 
        logger.exitLogger();  
    }
}