/*
===============================================================================================================================
Class : OrderLodgementService
Developer Name : Dheeraj Bhatt
Test Class : OrderLodgementServicetTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1.        Dheeraj Bhatt         06 Sept 2021   DIGI-1939 - Enable an API call to the MS to initiate digi plan configuration
===============================================================================================================================*/
public class OrderLodgementService {
    public static HTTPResponse orderLodgementRequest(string handlerName,string basketId,string solutionName,string offerName){
        HttpResponse response;
        String token= AuthenticationManager.getOauthToken(handlerName);
        String correlationId=IntegrationRecordHandlerUtil.getUUID();
        Map<String,String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('basketId',basketId);
        requestBodyMap.put('solutionName',solutionName);
        requestBodyMap.put('offerName',offerName);
        string requestBody=JSON.serialize(requestBodyMap);
        Map<String,String> headerMap = new Map<String, String>{'ds-application-label'=>'SalesForce','Content-Type' => 'application/json','ds-correlation-id'=>correlationId,'ds-source-system'=>'SFDC','Authorization' => 'Bearer '+token};
            response=orderLodgementCallout(handlerName,requestBody,headerMap,correlationId);
        return response;
    }
    public static HTTPResponse orderLodgementCallout(String handlerName,string requestBody,Map<String,String> headerMap,string correlationId){
        String errorMessage;
        String endPoint;
        HTTPResponse response; 
        Logger2 logger = Logger2.getLogger(handlerName);
        HTTPResponse res; 
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        if(handleSettingRecord != null) {
            if(handleSettingRecord.Enable_Mock_Integration__c) {
                endPoint = handleSettingRecord.Mock_End_Point__c != null? handleSettingRecord.Mock_End_Point__c : '';
            }
            else {
                endPoint = handleSettingRecord.End_Point__c != null? handleSettingRecord.End_Point__c : '';
            }
        }
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        HttpRequest req = new HttpRequest();  
        req.setEndpoint(endPoint);
        req.setBody(requestBody); 
        if(handleSettingRecord.Enable_MASSL__c && !Test.isRunningTest()) {
            String certificateName = '';
            certificateName = EnvironmentVariable.get('massl_certificate_name');
            req.setClientCertificateName(certificateName);
        }
        req.setMethod(handleSettingRecord.oauth_Method__c);
        req.setTimeout(timeout);
        if(headerMap != null) {
            for(String hdName : headerMap.keySet()) {
                req.setHeader(hdName, headerMap.get(hdName));   
            }
        }
        Http http = new Http();
        DateTime startTime = DateTime.now(); 
        response = http.send(req);
        DateTime endTime = DateTime.now();
        Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
        logger.logMessages(requestBody, response.getBody(), '', '', '',  '', String.valueOf(response.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
        logger.exitLogger();
        return response;
    }
    
}