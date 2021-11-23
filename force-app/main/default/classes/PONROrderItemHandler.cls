/*******************************************************************************************************************
Name : PONROrderItemHandler
EDGE-> 186512,186513
Description : To make a callout to Check Order line item PONR status for the specific order number.
====================================================================================================================
Sr.No.    Developer Name          Date                  Story Description
1.        Rajiv Singh          29/10/2020       As a salesforce user, I want to Perform PONR status Check for specific
                                                     order number: PONR status Enquiry API Consumption
2.         Arunkumar V & Martand 25/01/2021     EDGE-199064                                                  
====================================================================================================================
********************************************************************************************************************/

public without sharing class PONROrderItemHandler{
    public static final String HANDLER = 'PONROrderDetailsHandler';
    public static String orderNum = null;
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
    @AuraEnabled
    public static Boolean syncExecute(String OrderId) {//token request
        orderNum = OrderId;
        Boolean resDtd; //EDGE-199064
        try{
            if(!String.isBlank(orderNum)){
                 String token;
                Integration_Handler__mdt mdtRecord = [SELECT DeveloperName,Enable_Mock_Integration__c FROM Integration_Handler__mdt WHERE DeveloperName='PONROrderDetailsHandler'];
                if(mdtRecord.Enable_Mock_Integration__c){
                    token = 'api-b5fc7100-4c12-449a-b71f-4080016a9c56';
                system.debug('Token received mock'+ token);
                }else{
                    token = AuthenticationManager.getOauthToken(HANDLER);
                    //token='ehvk9P232g8xQFZ0tBA0i4KXLEas';
                    system.debug('Token received'+ token);
                }
                
                resDtd = callPONRStatusCheckService(token);
                system.debug('response '+resDtd);
            }
            
        }
        catch(exception e){
            system.debug(e.getMessage() + ';' + string.valueOf(e.getLineNumber()));
            logger.logMessages('StockCheckTokenRequestCalloutException', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        return resDtd;
    }
    
    public static Boolean callPONRStatusCheckService(String token){//api call
        getPONROrderItemDTD responseDTD =null;        
        Boolean servResponse = true; //EDGE-199064
        HttpResponse res;
        String payload = '';
        try{
      String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            payload = orderNum+'/PONR';
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> +correlationId};
      DateTime startTime = DateTime.now();  
            res = IntegrationRecordHandlerUtil.callout(payload,'GET',headerMap,HANDLER,null,null);
            System.debug('res '+res);
      DateTime endTime = DateTime.now();
      Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            //system.debug('outer'+res.getStatusCode()); 
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {
                system.debug('inner'+res.getStatusCode()); 
                responseDTD = getPONROrderItemDTD.parse(res.getBody());
                PONRReturnCheckHandler ponrCheck = new PONRReturnCheckHandler();
                servResponse = ponrCheck.updateOrderService(responseDTD.externalOrderId, responseDTD.OrderItemsinPONR); // EDGE-199064 collected the value from the method updateOrderSerice
                //logger.logMessages(payload, res.getBody(), '', '', '', '', false, false,Integer.valueof('200') , null, null, null);
        logger.logMessages(payload, res.getBody(), '', '', '', 
                                       '', String.valueOf(res.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
                  
            }
            else {
                responseDTD = getPONROrderItemDTD.parse(res.getBody());
                //logger.logMessages(payload, res.getBody(), '', '', '', '', false, false, Integer.valueOf('111') , null, null, null);
        logger.logMessages(payload, res.getBody(), '', '', '', 
                                       '', String.valueOf(res.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
            
            }
           
        }catch (Exception e) {
            logger.logMessages('StockCheckCalloutException', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);            
        }       
        logger.exitLogger();
        system.debug('Final response'+responseDTD);
        return servResponse ; //EDGE-199064 changed the responseDTD to servResponse(Boolean).
        
    }
    
}