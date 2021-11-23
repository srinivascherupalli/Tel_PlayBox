/**********************************************************************
Class Name  : NumberDisconnectedHandler
Test Class  : NumberDisconnectedHandlerTest
Created By  : Nikhil Sharma
Description : created a class for retry mechanism

1. Team Apple : Adding IsDisconnected__c field as 1636 design issue : 8th June 2021
************************************************************************
*/
public with sharing class NumberDisconnectedHandler extends IntegrationQueueHandler{

    public NumberDisconnectedHandler() {
        super(NumberDisconnectedHandler.class.getName());
    }
    
    public override void executeWork(List<String> params) {
        //system.debug('params NumberDisconnectedHandler'+params);
        if(!params.isEmpty()){
            callout(params.get(0));
        }
    }

    @future(callout=true)
    public static void callout(String param) {
        //system.debug('callout(String param) NumberDisconnectedHandler'+param);
        //Get Integration Record for retry method
        List<Integration_Record__c> paramRequest = getIntegrationRecord(param); 
        //system.debug('callout(String param) paramRequest'+paramRequest);   
        Long requestTime;
        String errorMessage;
        HttpResponse bdsResponse;
        //Create ApplicationLogs
        Logger2 logger = Logger2.getLogger(paramRequest.get(0).Handler__c);
        //Get Access token 
        String token = AuthenticationManager.getOauthToken(paramRequest.get(0).Handler__c);
        //Get Correlation-Id to be generated uniquely for every request  
        String correlationId =IntegrationRecordHandlerUtil.getCorrelationId();
        //Convert request body into JSON format
        String reqBody = paramRequest.get(0).paramPayload__c;
        List<Number__c> numberList = new List<Number__c>();
        String httpMethod = 'POST';
        numberList = getDisconnectedNumberList(paramRequest.get(0).paramPayload__c);
        try{
            //BDS Services API Header Map 
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation-Id'=>correlationId,'Source-System'=>'SFDC'}; 
            //request Time Start
            DateTime startTime = DateTime.now();
            //Sync Callout
            bdsResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, httpMethod, headerMap, paramRequest.get(0).Handler__c);
            //request Time END
            DateTime endTime = DateTime.now();
            //Get Request Time Difference
            requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            if(bdsResponse != null && bdsResponse.getStatusCode() != null){
                // Get BDS Service Response in map
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(bdsResponse.getBody());
                
                //Check BDS Services API Response code equal to 202
                if(bdsResponse.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_ACCEPTED){
                    errorMessage = 'A HTTP error occurred' +  '\n' + 'Status Code: ' + bdsResponse.getStatusCode() + '\n' + 'Status Message: ' + bdsResponse.getStatus(); 
                    //Called retry method
                    //system.debug('IntegrationQueuableUtils.retry'+errorMessage);
                    IntegrationQueuableUtils.retry(paramRequest.get(0).Handler__c, new List<String>{paramRequest.get(0).params__c}, errorMessage); 
                   
                }else{
                    //update Numbers list with BDS Event Id and Status
                    for(Number__c num : numberList){
                        num.BDS_EventId__c = String.valueOf(response.get('eventId'));
                        num.IsDisconnected__c = true; //  Design fix 1636 @Apple
                        num.Status__c = 'Bill Readiness In Progress';
                    }
                    Update numberList;

                    paramRequest[0].Status__c = IntegrationQueueHandler.PROCESSED;
                    update paramRequest;
                 }
                //ApplicationLog Body
                logger.logMessages(reqBody, bdsResponse.getBody(), '', '', '', 
                                    '', String.valueOf(bdsResponse.getStatusCode()), correlationId, '','','Read','',requestTime ,httpMethod,false, false);
            }
            //End ApplicationLog
            logger.exitLogger();
        }catch (Exception e) {
            //ApplicationLog Body
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);           
            logger.exitLogger();
        }
    }

    //Method to get Provisioned Number lisr based on param payload
    private static List<Number__c> getDisconnectedNumberList(String paramPayload){
        //Payload deserialize
        BDSDisconnectedServicePayload disconnectedNumberServices = new BDSDisconnectedServicePayload();
        disconnectedNumberServices = (BDSDisconnectedServicePayload) JSON.deserializeStrict(paramPayload, BDSDisconnectedServicePayload.class);
        List<Number__c> numberList = new List<Number__c>();
        Set<String> serviceNumbers = new Set<String>();
        for(DisconnectedPayloadWrapper payload : disconnectedNumberServices.services){
            serviceNumbers.add(payload.serviceNumber);
        }
        //get number which mobile is Fixed and status is Provisioned
        numberList = [SELECT Id,BDS_EventId__c,Status__c,IsDisconnected__c FROM Number__c WHERE Service_Number__c IN : serviceNumbers AND Mobile__c = 'Fixed' AND Status__c = 'Disconnected'];
        
        return numberList;
    }

    //Method to get Integration Record
    private static List<Integration_Record__c> getIntegrationRecord(String param){
        return [SELECT Id, Handler__c, params__c, paramPayload__c FROM Integration_Record__c WHERE params__c = :param LIMIT 1 ];
    }
    
    //Wrapper class for request body
    public class BDSDisconnectedServicePayload{
        List<DisconnectedPayloadWrapper> services;
        public BDSDisconnectedServicePayload(){
            services = new List<DisconnectedPayloadWrapper>(); 
        }
    }
    public class DisconnectedPayloadWrapper {
        public string serviceNumber; 
    
        public DisconnectedPayloadWrapper(string serviceNumber){
            this.serviceNumber = serviceNumber;
        }
    }
    
}