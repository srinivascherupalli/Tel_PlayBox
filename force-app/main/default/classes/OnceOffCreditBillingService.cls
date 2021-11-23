/*------------------------------------------------------------ 
Author: Mahima Gandhe 
Company: Telstra 
Description: Class to make API callout for Apply one of credit to given case ID
Test Class: OnceoffCreditValidateManagerTest 
History :
<16-04-2019> <Mahima Gandhe> <EDGE 64232> 
------------------------------------------------------------*/
public with sharing class OnceOffCreditBillingService {
        
  /*-------------------------------------------------------- 
    Story: EDGE-149471
    Method: setToken
    Description: Method to set token dynamically
    Returns: String of token value
History:
 <24-06-2020> <Pradeep>
    --------------------------------------------------------*/
public static String setToken(String handlerName) {
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        String token='';
            if(handleSettingRecord!=null) {
                if(handleSettingRecord.Enable_Mock_Integration__c) {
                     token = System.Label.QLI_Token;
                     return token;
                }
               // System.debug('Token for  ' + handlerName + ' is ' +token);
                token =AuthenticationManager.getOauthToken(handlerName);                            
            }
            return token;
    }
    
    
    /*------------------------------------------------------------ 
Metohd: ApplyOnceOffCreditService
Description: Prepare request and response data pre and post the api callout. 
Inputs: OnceOffCreditRequest object record, handler name, billing Account number to be merged in endpoint 
Returns: OnceOffCreditResponse  response record
History 
<16-04-2019> <Mahima Gandhe>
<14-08-2019> <Mahima Gandhe> <EDGE- 104930>
------------------------------------------------------------*/
    public static OnceOffCreditResponse ApplyOnceOffCreditService(OnceOffCreditRequest reqParam, String handler, String Ban)
    {
        OnceOffCreditResponse responseObj=new OnceOffCreditResponse();
        //Logger2 logger = Logger2.getLogger(handler);        
        HttpResponse response;
        String urlOnceoff = getEncodedURLOnceoff(handler);
        if(urlOnceoff == null){
            return null;
        }else{ 
            String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            token = setToken(handler);
            
            String correlationId=IntegrationRecordHandlerUtil.getUUID();
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Correlation-Id'=>correlationId,'Authorization'=> 'Bearer ' + token,'Source-System'=>'SFDC'};
                // response=ApplyOnceOffCredit('POST',headerMap,json.serialize(reqParam))
               system.debug('>>>>>>>>>>>reqParam: '+reqParam);
                String reqBody = JSON.serialize(reqParam);
            system.debug('>>>>>>>>>>>reqBody: '+reqBody);
            //EDGE- 104930-- Mahima- Added last parameter as null for params
            response = ApplyOnceOffCreditCallout(Ban,reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handler,correlationId, null);
            system.debug('CreditResponse::' + response.getBody());
            if(String.isNotBlank(response.getBody()))
            {
                responseObj= (OnceOffCreditResponse)JSON.deserialize(response.getBody(), OnceOffCreditResponse.class);
            }
            else{
                Error err= new Error();
                err.message='Some error occured.';
                err.code='';
                err.field='';
                responseObj.errors=new List<Error>();
                responseObj.errors.add(err);
            }  
        }

        return responseObj;
    }
    
    /*------------------------------------------------------------ 
Metohd: getEncodedURLOnceoff
Description: get endpoint details from handler data
Inputs: handlerName
Returns: endpoint URL
History 
<16-04-2019> <Mahima Gandhe>
------------------------------------------------------------*/
    public static String getEncodedURLOnceoff(String handlerName){
        String UnstructEP = [Select End_Point__c from Integration_Handler__mdt where Label=:handlerName].End_Point__c;
        String encodedUrl = '';
        if(UnstructEP!='' || UnstructEP != null)           
            encodedUrl = UnstructEP;
        
        System.debug('encodedUrl==>' +encodedUrl);
        return encodedUrl; 
        
    }
    
    /*------------------------------------------------------------ 
Metohd: ApplyOnceOffCreditService
Description: Make the API callout to third Party
Inputs: billing Acc number, payload, header map,handler name
Returns: HTTPResponse response record
History 
<16-04-2019> <Mahima Gandhe>
<14-08-2019> <Mahima Gandhe><EDGE- 104930>< Added new parameter for params>
------------------------------------------------------------*/
    public static HTTPResponse ApplyOnceOffCreditCallout (String BAN_number, String reqBody, String method, Map<String,String> headerMap, String handlerName, String correlationId, Map<String,String> params) {
        
        
        String errorMessage;
        String endPoint;
        Logger2 logger = Logger2.getLogger(handlerName +':'+correlationId);
        HTTPResponse res; 
        system.debug('>>>>>>>>>>>reqBody: '+reqBody);
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        if(handleSettingRecord != null) {
            if(handleSettingRecord.Enable_Mock_Integration__c) {
                endPoint = handleSettingRecord.Mock_End_Point__c != null? handleSettingRecord.Mock_End_Point__c : '';
            }
            else {
                endPoint = handleSettingRecord.End_Point__c != null? handleSettingRecord.End_Point__c : '';
            }
        }
        System.debug('EndPoint: ' + endPoint + ', Method: ' + method);
        
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if(String.isBlank(endPoint)) {
            System.debug('Cannot make a callout without an Endpoint');            
            return null;
        }else
        {
            endPoint=  endPoint.replace('{BAN}', BAN_number);
        }
        //104930- Mahima - start
        integer count=0;
        if(params!= null && params.size()>0){
            for(string p: params.keyset()){
                if(count==0)
                endPoint= endPoint +'?'+p+'='+params.get(p);
                else
                   endPoint= endPoint +'&'+p+'='+params.get(p);
                
                count++;
            }
        }
        //104930- Mahima - end
        
        HttpRequest req = new HttpRequest();  
        try {
            req.setEndpoint(endPoint);
            //Added- EDGE-104930
            if(reqBody!= null){
                req.setBody(reqBody);
            }
            
            // @author : Akshay Deuskar | Added to enable MASSL for integration as part of NFB-1218
            if(!test.isRunningTest()){
                if(handleSettingRecord.Enable_MASSL__c) {
                    System.debug('MASSL is enabled for interface');
                    String certificateName = null;
                    certificateName = EnvironmentVariable.get('massl_certificate_name');
                    //System.debug('Setting ' + certificateName + ' certificate for http call');
                    req.setClientCertificateName(certificateName);
                }
            }
            
            req.setMethod(method);
            req.setTimeout(timeout);
            
            if(headerMap != null) {
                for(String hdName : headerMap.keySet()) {
                    req.setHeader(hdName, headerMap.get(hdName));   
                }
            }
            
            
            system.debug('request data==>'+req);
            Http http = new Http();
           DateTime startTime = DateTime.now(); 
            res = http.send(req);
            DateTime endTime = DateTime.now();
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            // Stored enpoint and request body both in Logs as both contains essential request information.
            logger.logMessages(reqBody, res.getBody(), '', '', '', 
                                       '', String.valueOf(res.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
             system.debug('>>>>>>>>>> res : '+res.getBody());
        }
        catch(exception ex)
        { 
            system.debug(ex.getMessage());
            logger.logMessages(endpoint +' : '+ reqBody, ex.getMessage(), ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        logger.exitLogger();
        return res;
    }
    
    
    /*------------------------------------------------------------ 
Class: Inner class OnceOffCreditRequest
Description: Request wrapper  
History :
<16-04-2019> <Mahima Gandhe> 
------------------------------------------------------------*/
    public class OnceOffCreditRequest
    {
        public String description { get; set; }
        public String productId { get; set; }
        public String instanceId { get; set; }
        public String adjustmentType { get; set; }
        public decimal amount { get; set; }
        public String currencyCode { get; set; }
        public String gstIndicator { get; set; }
        public integer reasonCode { get; set; }
        public String caseReferenceNumber { get; set; }
        //EDGE-157139, EDGE-157137. Kalashree Borgaonkar. Added chargeId,externalRateId in request
        public String chargeId ;
        public String externalRateId ;
    }
    
    /*------------------------------------------------------------ 
Class: Inner class Error
Description: Response wrapper  
History :
<16-04-2019> <Mahima Gandhe> 
------------------------------------------------------------*/
    public class Error
    {
        public String code { get; set; }
        public String field { get; set; }
        public String message { get; set; }
    }
    
    /*------------------------------------------------------------ 
Class: Inner class OnceOffCreditResponse
Description: Response wrapper  
History :
<16-04-2019> <Mahima Gandhe> 
------------------------------------------------------------*/
    public class OnceOffCreditResponse
    {
        public String code { get; set; }
        public String status { get; set; }
        public String message { get; set; }
        public List<Error> errors { get; set; }
    }
    
}