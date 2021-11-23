/********************************************************
Class Name  : NumberProvisionedQueueable
Test Class  : NumberProvisionedQueueableTest
Created By  : Nikhil Sharma
Description : created Queueable class for Push Numbers to BDS when Number Status is “Provisioned”
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Nikhil Sharma        11 March 2021    EDGE-202844
************************************************************************
*/

public with sharing class NumberProvisionedQueueable implements Queueable,Database.AllowsCallouts {
    
    public String handlerName;
    public String statusType;
    public List<Number__c> numberList;
    public BDSProvisionedServicePayload bdsProvisionedServices;
    public BDSDisconnectedServicePayload bdsDisconnectedServices;
    
    public NumberProvisionedQueueable(List<Number__c> provisionedNumberList,String status) {

        statusType = status;
        //MetaData record name 
        handlerName =  statusType.equalsIgnoreCase('Provisioned') ? 'NumberProvisionedHandler' : 'NumberDisconnectedHandler';
        //Used for send payload to BDS Services
        bdsProvisionedServices = new BDSProvisionedServicePayload();
        bdsDisconnectedServices = new BDSDisconnectedServicePayload();
        //Used for update number records with BDS eventId
        numberList = new List<Number__c>([SELECT Id,BDS_EventId__c,Status__c FROM Number__c WHERE Id In : provisionedNumberList]);
        //fill wrapper 
        for(Number__c num : provisionedNumberList){
            if(num.Status__c.equalsIgnoreCase('Provisioned')){
                ProvisionedPayloadWrapper payload = new ProvisionedPayloadWrapper(num.Service_Number__c,'FNN',num.Subscription_number__c);
                bdsProvisionedServices.services.add(payload);
            }else{
                DisconnectedPayloadWrapper payload = new DisconnectedPayloadWrapper(num.Service_Number__c);
                bdsDisconnectedServices.services.add(payload);
            }
           
        }
    }
    public void execute(QueueableContext context) {

        Long requestTime;
        String errorMessage;
        HttpResponse bdsResponse;
        //Create ApplicationLogs
        Logger2 logger = Logger2.getLogger(handlerName);
        //Get Access token 
        String token = AuthenticationManager.getOauthToken(handlerName);
        //Get Correlation-Id to be generated uniquely for every request  
        String correlationId =IntegrationRecordHandlerUtil.getCorrelationId();
        //filled param list
        List<String> params = new List<String>{correlationId+'|'+statusType};

        String httpMethod =  IntegrationRecordHandlerUtil.HTTP_METHOD_POST;
        //Convert request body into JSON format
        String reqBody = statusType.equalsIgnoreCase('Provisioned') ? JSON.serialize(bdsProvisionedServices,true) : JSON.serialize(bdsDisconnectedServices,true);
        
        try{
            //BDS Services API Header Map 
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation-Id'=>correlationId,'Source-System'=>'SFDC'}; 
            //request Time Start
            DateTime startTime = DateTime.now();
            //Sync Callout
            bdsResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, httpMethod, headerMap, handlerName);
             //request Time END
            DateTime endTime = DateTime.now();
            //Get Request Time Difference
            requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            if(bdsResponse != null && bdsResponse.getStatusCode() != null){
                // Get BDS Service Response in map
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(bdsResponse.getBody());
                //Check BDS Services API Response code equal to 202
                if(bdsResponse.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_ACCEPTED){
                    //called method for creating Integration Record
                    createIntegrationRecord(correlationId, statusType, handlerName, reqBody);
                    errorMessage = 'A HTTP error occurred' +  '\n' + 'Status Code: ' + bdsResponse.getStatusCode() + '\n' + 'Status Message: ' + bdsResponse.getStatus(); 
                    //Called retry method
                    IntegrationQueuableUtils.retry(handlerName, params, errorMessage); 
                }else{
                   //update Numbers list with BDS Event Id and Status
                   for(Number__c num : numberList){
                        num.BDS_EventId__c = String.valueOf(response.get('eventId'));
                        num.Status__c = 'Bill Readiness In Progress';
                        if( handlerName == 'NumberDisconnectedHandler'){
                        	num.IsDisconnected__c = true; //  Design fix 1636 @Apple
                       }
                   }
                   Update numberList;
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
            //End ApplicationLog
            logger.exitLogger();
        }
    }
    

    //Method to create Integration Record
    private Void createIntegrationRecord(String correlationId ,String numberType, String handlerName , String requestBody){
        Integration_Record__c insRec = new Integration_Record__c();
        insRec.params__c = correlationId +'|'+numberType;
        insRec.paramPayload__c = requestBody;
        insRec.handler__c = handlerName;
        insRec.status__c = IntegrationQueueHandler.IN_PROGRESS;
        insert insRec;
    }

    //Wrapper class for request body
    public class BDSProvisionedServicePayload{
        List<ProvisionedPayloadWrapper> services;

        public BDSProvisionedServicePayload(){
            services = new List<ProvisionedPayloadWrapper>(); 
        }
    }
    public class ProvisionedPayloadWrapper {
        public string serviceNumber; 
        public string subscriptionId; 
        public string serviceType;
    
        public ProvisionedPayloadWrapper(string serviceNumber, string serviceType, string subscriptionId){
            this.serviceNumber = serviceNumber;
            this.serviceType = serviceType;
            this.subscriptionId = subscriptionId;
        }
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