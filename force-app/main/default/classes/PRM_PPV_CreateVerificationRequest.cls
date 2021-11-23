/**
* Description : Apex Action to be invoked from flows. This apex class will create and send a PPV_Verification_Request.                   
* Jira        : P2OB - 11853
* Author      : Team Hawaii : Ritika Jaiswal
* Date        : 15-Jan-2021 
**/
public without sharing class PRM_PPV_CreateVerificationRequest {
    private static User userRecord;
    
    @InvocableMethod
    public static List<FlowOutputParameter> sendVerificationRequest(List<FlowInputParameter> flowInputs){
        
        Logger2 logger = Logger2.getLogger('PRM_PPV_CreateVerificationRequest.sendVerificationRequest');
        
        List<FlowOutputParameter> outputList = new List<FlowOutputParameter>();
        String responseBody;
        String urlParams;
        String httpMethodType = 'POST';
        String event = 'PPVCreateVerificationRequest';
        
        try {  
            for(FlowInputParameter fip : flowInputs){
                //P2OB - 11853: Construct request-body for PPV_CreateVerfication_Request
                if(fip.verificationMethod.equalsIgnoreCase('AuthRepSMS') || fip.verificationMethod.containsIgnoreCase('SMS'))
                	urlParams = '{"data": {"mobileNumber": "'+ fip.custAuthRepDetails+'","verificationMethod": "'+fip.verificationMethod+'","smsContext": "Telstra"}}';
                else if(fip.verificationMethod.equalsIgnoreCase('AuthRepCall') || fip.verificationMethod.equalsIgnoreCase('AuthRepProof'))
                    urlParams = '{"data": {"authRepContactNumber": "'+ fip.custAuthRepDetails+'","verificationMethod": "'+fip.verificationMethod+'"}}'; 
                System.debug('***Telstra:PRM_PPV_CreateVerificationRequest:sendVerificationRequest:URL params:'+urlParams);
                
                //P2OB - 11853:Obtain oauth-token as per the event-name
                String token = AuthenticationManager.getOauthToken(event);
                System.debug('***Telstra:PRM_PPV_CreateVerificationRequest:sendVerificationRequest:token:'+token);
                
                //P2OB - 11853:Forming header-map
                Map<String,String> headerMap = create_PPV_request_Header(token);
                System.debug('***Telstra:PRM_PPV_CreateVerificationRequest:sendVerificationRequest:headerMap:'+headerMap);
                
                //P2OB - 11853:Sync-Callout to PPV-API 
                HttpResponse response = IntegrationRecordHandlerUtil.calloutSync(urlParams, httpMethodType, headerMap, event);
                responseBody = response.getBody();
                
                //P2OB - 11853:Parsing the response of API and returning flow-output
                PRM_PPV_CreateVerificationRequest.PPV_Response deserializeresponse=(PRM_PPV_CreateVerificationRequest.PPV_Response)JSON.deserialize((String) responseBody, PRM_PPV_CreateVerificationRequest.PPV_Response.class);                     
                System.debug('***Telstra:PRM_PPV_CreateVerificationRequest:sendVerificationRequest:deserializeresponse:'+deserializeresponse);
                if (response.getStatusCode() != 200) {
                    logger.logMessages(urlParams, responseBody, '', 'Technical', '', '', false, false);
                    FlowOutputParameter op = new FlowOutputParameter();
                    op.errorMessage = JSON.serialize(deserializeresponse.errors);
                    op.isResultSuccess = false;
                    outputList.add(op);
                }
                else if(deserializeresponse.responseCode =='PPV-SUCCESS'){
                    FlowOutputParameter op = new FlowOutputParameter();
                    op.errorMessage = '';
                    op.isResultSuccess = true;     
                    outputList.add(op);
                }
            } 
        } catch (Exception e) {
            logger.logMessages(urlParams, e.getMessage(), e.getStackTraceString(), 'Technical', '', '', false, false);
            System.debug('***Telstra:PRM_PPV_CreateVerificationRequest:sendVerificationRequest:Exception:'+e.getMessage());
            FlowOutputParameter op = new FlowOutputParameter();
            op.errorMessage = e.getMessage();
            op.isResultSuccess = false;
            outputList.add(op);
        }
        finally{
            logger.exitLogger();            
        }
        return outputList;
        
    }
    
    /**    
* Description : Method to prepare the header-map for requests to PPV_API
* Jira : P2OB - 11853
*/
    public static Map<String,String> create_PPV_request_Header(String token){
        if(userRecord == null)
            userRecord = [select id,FederationIdentifier from User where id = :UserInfo.getUserId()];
        
        //P2OB-11853 : Adding OAuth token to header
        Map<String,String> headerMap = new Map<String, String>{'Authorization'=> 'Bearer ' + token};
            
        //P2OB-11853 : Adding OAuth token to header 
        headerMap.put('Accept','application/json');
        
        //P2OB-11853 : Adding content-type to header
        headerMap.put('Content-Type','application/json');
        
        //P2OB-11853 : Adding user's federation-number to header
        headerMap.put('x-agent-id',userRecord.FederationIdentifier);
        
        return headerMap;
    } 
    
    
    /**    
* Description : Wrapper class to hold input parameters received from flow 
* Jira : P2OB - 11853
*/
    public Class FlowInputParameter{
        @InvocableVariable
        public String[] numbers_for_porting;
        @InvocableVariable
        public String custAuthRepDetails;
        @InvocableVariable
        public String verificationMethod;
    }
    
    /**    
* Description : Wrapper class to hold output parameters sent to flow 
* Jira : P2OB - 11853
*/
    public class FlowOutputParameter{
        @InvocableVariable
        public String errorMessage = '';
        @InvocableVariable
        public Boolean isResultSuccess ; 
    }
    
    /**    
* Description : Wrapper class to parese API response 
* Jira : P2OB - 11853
*/    
    public class PPV_Response{
        String correlationId; 
        String code;
        String status;
        String responseCode;
        PRM_PPV_CreateVerificationRequest.Data data;
        List<Error> errors;
    }
    
    /**    
* Description : Sub-Class to store data-section of API-response
* Jira : P2OB - 11853
*/    
    private class Data{
        String mobileNumber; 
    }
    private class Error{
        String code; 
        String message;
    }
    
}