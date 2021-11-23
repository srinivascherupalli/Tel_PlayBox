/*
* @Author : Ritika Jaiswal
* @Date : 15 Mar 2019
* @Desc : Handler of REST API created under REST_DisconnectOrderServiceUtil 
* @Jira : EDGE - 66139 REST API for Disconnect Request
* Updates : Ritika jaiswal : 19/09/2019 : EDGE - 66137 : For capturing BillCycleDay on the DisconnectRequest-record. 
*/

public with sharing class DisconnectOrderHandler{
    //EDGE-106276 - <Disconnection API> Unique error codes to be provided to downstream system in case of failure scenarios
    public Map<String, String> errorCodesAndMessages = new Map<String,String>{'406'=>'Port out request already inprogress for the selected MSISDN',
                                                    '403'=>'Invalid character detected in request parameter',
                                                    '404'=>'Subscription is not locked, hence unable to initiate disconnect order',
                                                    '405'=>'We did not find any MSISDN related to the data sent and hence unable to initiate disconnect order'};
    public Logger2 logger;
    public  RestRequest request;
    
    //Logic to insert request-record, based on the status of subscription in SFDC
    public void getSubcriptionDetailsForDisconnectRequest(DisconnectOrderRequestDTO disconnectRequest){        
        logger = Logger2.getLogger('DisconnectOrder');
        request = RestContext.request;
        
        List<DisconnectionRequest__c> requestsToInsert = new List<DisconnectionRequest__c>();
        Map<String, String> dataStrings = new Map<String, String>{disconnectRequest.Data.correlationID => 'correlationID', disconnectRequest.Data.serviceMSISDN => 'serviceMSISDN',disconnectRequest.Data.subscriptionID =>'subscriptionID',disconnectRequest.Data.originatingSystem=>'originatinSystem',disconnectRequest.Data.requestedDate=>'requestedDate',disconnectRequest.Data.requestReason=>'requestReason'};
        
        Boolean result=false;
       
        for(String dString:dataStrings.keyset()){
            if(dString!=null){
                result=dString.containsAny(system.label.DisconnectionSpecialCharacterNotAllowed);
                if(result==true){                   
                     break;
                }
            }
        }
        if(result){
            //EDGE-106276 - <Disconnection API> Unique error codes to be provided to downstream system in case of failure scenarios
            setResponse(true,'FAILURE', '403', errorCodesAndMessages.get('403') , disconnectRequest.Data.correlationID , '' );
        }
        else{
            // start  EDGE-76399 Either ServiceMSISDN or SubscriptionID needed for Creating record in DisconnectRequest
                List<csord__Subscription__c> subsrecordlist;
                if(disconnectRequest.Data.serviceMSISDN!=null &&  disconnectRequest.Data.serviceMSISDN!='')                    
                    subsrecordlist=[select id,csordtelcoa__Subscription_Number__c, csord__Status__c,serviceMSISDN__c,Billing_Account__r.Billing_Account_Number__c from csord__Subscription__c where serviceMSISDN__c=:disconnectRequest.Data.serviceMSISDN ];//or id=:disconnectRequest.Data.subscriptionID];
                /*else if(disconnectRequest.Data.subscriptionID!=null && disconnectRequest.Data.subscriptionID!='')
                    subsrecordlist=[select id,csordtelcoa__Subscription_Number__c, csord__Status__c,serviceMSISDN__c from csord__Subscription__c where id=:disconnectRequest.Data.subscriptionID];*/  
                if(subsrecordlist.size()>0){
                    
                    List<DisconnectionRequest__c> checkExistingRequest = [SELECT MSISDN__c,Subscription__c FROM DisconnectionRequest__c WHERE MSISDN__c = :disconnectRequest.Data.serviceMSISDN ];
                    if (checkExistingRequest.size() > 0 ) {                        
                        //EDGE-106276 - <Disconnection API> Unique error codes to be provided to downstream system in case of failure scenarios
                        setResponse(true,'FAILURE', '406', errorCodesAndMessages.get('406') , disconnectRequest.Data.correlationID , '' );
                    }                    
                    else{
                        Boolean setSuccessResponse=False;
                        for(csord__Subscription__c subsrecord:subsrecordlist){
                            //check if the subscription is locked in order to be disconnected
                            
                            if( (subsrecord.csord__Status__c==Label.Subscription_status_for_PortOut)){
                                
                                setSuccessResponse=True;
                                //subscription is found in locked state, insert a request-record  
                                //EDGE-106276 - <Disconnection API> Unique error codes to be provided to downstream system in case of failure scenarios                        
                                setResponse(false,Label.Subscription_status_for_PortOut, '200', '', disconnectRequest.Data.correlationID ,subsrecord.serviceMSISDN__c );         
                                //create a record of disconnect-request
                                requestsToInsert.add(createNewRequestRecord(disconnectRequest,subsrecord));
                            }
                            
                        }
                        //EDGE-106276 - <Disconnection API> Unique error codes to be provided to downstream system in case of failure scenarios                        
                        if(!setSuccessResponse) 
                            setResponse(true,'FAILURE', '404', errorCodesAndMessages.get('404'), disconnectRequest.Data.correlationID , '' );
                    }
                }
                else
                    setResponse(true,'FAILURE', '405', errorCodesAndMessages.get('405'), disconnectRequest.Data.correlationID , '' ); 
                //EDGE-106276 - <Disconnection API> Unique error codes to be provided to downstream system in case of failure scenarios                        
                // end EDGE-76399
                
                if(requestsToInsert.size() > 0){
                    
                    insert requestsToInsert; 
                }
        }
    }  
    
    //set the response in the rest-context
    public void setResponse(Boolean isError,String status, String statusCode, String statusMessage, String correlationID , String serviceMSISDN ){
        DisconnectOrderResponseDTO responseDTO;    
        RestResponse response = RestContext.response;
        if(isError){
            responseDTO= new DisconnectOrderResponseDTO('Error');
            responseDTO.error.status=status;
            responseDTO.error.Code=statusCode;
            responseDTO.error.message=statusMessage;
            responseDTO.error.correlationID=correlationID;                
            response.Statuscode=Integer.valueOf(statusCode);
            response.responseBody = Blob.valueOf(json.serialize(responseDTO));
        }
        else{
            responseDTO= new DisconnectOrderResponseDTO('Success');
            responseDTO.data.serviceMSISDN= serviceMSISDN ;
            responseDTO.data.status= status;
            responseDTO.data.transactionDate= System.now().format();
            responseDTO.data.correlationID= correlationID ;
            response.Statuscode=Integer.valueOf(statusCode);
            response.responseBody = Blob.valueOf(json.serialize(responseDTO));    
        }
        logger.logMessages((request.requestBody).toString(), (response.responseBody).toString(), '', '', '', '', true, false,Integer.valueof(response.Statuscode) , null, null, null);
        
    }
    
    //create a request-record by mapping all the data-values
    private DisconnectionRequest__c createNewRequestRecord(DisconnectOrderRequestDTO disconnectRequest,csord__Subscription__c subsrecord){
        DisconnectionRequest__c newRequestRecord = new DisconnectionRequest__c();
        newRequestRecord.E2ECorrelationID__c = disconnectRequest.Data.correlationID;
        newRequestRecord.MSISDN__c = subsrecord.serviceMSISDN__c;
        newRequestRecord.Originating_System__c = disconnectRequest.Data.originatingSystem;
        newRequestRecord.Requested_DateTime__c = disconnectRequest.Data.requestedDate;
        //sudbcription-number and id for CS-API
        
        newRequestRecord.Subscription__c= subsrecord.id;
        newRequestRecord.Request_Reason__c = disconnectRequest.Data.requestReason;
        newRequestRecord.Disconnect_Type__c = 'Port Out';        
        newRequestRecord.BillingCycleDay__c = '1';
        //EDGE - 66137
        BillingAccountDetailsDTO billAccDTO = BillingOrderService.requestBillingAccountDetails(subsrecord.Billing_Account__r.Billing_Account_Number__c);
        System.debug('***Telstra:DisconnectOrderHandler:billAccDTO** '+billAccDTO);        
        if(billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.code == IntegrationRecordHandlerUtil.HTTP_SUCCESS){         
            //String dayValue = billAccDTO.BillingAccount.startDate;
            newRequestRecord.BillingCycleDay__c = String.valueOf(billAccDTO.BillingAccount.billCycleDay);
        }
        return newRequestRecord ;
    }
    
    

}