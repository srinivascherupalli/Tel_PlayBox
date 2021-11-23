/**
* Description : Apex Action to be invoked from flows. This apex class will verify the OTP Code.                   
* Jira        : P2OB - 11853
* Author      : Team Hawaii : Ritika Jaiswal


* Date        : 15-Jan-2021 
* Modified    : DIGI 14124 Irfan Inamdar

**/
public without sharing class PRM_PPV_VerifyCode_Request {
    
    @InvocableMethod
    public static List<FlowOutputParameter> verifyOTPCode(List<FlowInputParameter> flowInputs){


        
        Logger2 logger = Logger2.getLogger('PRM_PPV_VerifyCode_Request.verifyOTPCode');
        


        List<FlowOutputParameter> outputList = new List<FlowOutputParameter>();
        String responseBody;
        String urlParams;
        String httpMethodType = 'POST';
        String event = 'PPVOTPVerificationRequest';
        try {
            for(FlowInputParameter fip : flowInputs){



                FlowOutputParameter op = new FlowOutputParameter();
                
                if(fip.verificationMethod.equalsIgnoreCase('AuthRepCall') || fip.verificationMethod.equalsIgnoreCase('AuthRepProof')){
                    op.errorMessage = '';
                    op.isResultSuccess = true;
                    op.stagingRecords = prepareStagingRecords(fip,''); 
                    outputList.add(op);
                }else if(fip.verificationMethod.equalsIgnoreCase('AuthRepSMS')){


                //P2OB - 11853:Construct request body for PPV_Verify_OTP
                urlParams = '{"data": {"mobileNumber": "'+ fip.custAuthRepDetails+'","verificationCode": "'+fip.OTP_input+'"}}';
                System.debug('***Telstra:PRM_PPV_VerifyCode_Request:verifyOTPCode:URL params:'+urlParams);
                
                //P2OB - 11853:Obtain oauth-token as per the event-name
                String token = AuthenticationManager.getOauthToken(event);
                System.debug('***Telstra:PRM_PPV_VerifyCode_Request:verifyOTPCode:token:'+token);
                
                //P2OB - 11853:Forming header-map
                Map<String,String> headerMap = PRM_PPV_CreateVerificationRequest.create_PPV_request_Header(token);
                
                //P2OB - 11853:Sync-Callout to PPV-API  
                HttpResponse response = IntegrationRecordHandlerUtil.calloutSync(urlParams, httpMethodType, headerMap, event);
                responseBody = response.getBody();
                
                //P2OB - 11853:Parsing the response of API and returning flow-output
                PRM_PPV_VerifyCode_Request.PPV_Response deserializeresponse=(PRM_PPV_VerifyCode_Request.PPV_Response)JSON.deserialize((String) responseBody, PRM_PPV_VerifyCode_Request.PPV_Response.class);                


                    

                    System.debug('***Telstra:PRM_PPV_VerifyCode_Request:verifyOTPCode:deserializeresponse:'+deserializeresponse);
                    if (response.getStatusCode() != 200) {
                        logger.logMessages(urlParams, responseBody, '', 'Technical', '', '', false, false);
                        op.errorMessage = JSON.serialize(deserializeresponse.errors);



                    op.isResultSuccess = false;
                    outputList.add(op);
                }
                else if(deserializeresponse.responseCode =='PPV-SUCCESS'){
                    op.errorMessage = '';
                    op.isResultSuccess = true;
                    op.stagingRecords = prepareStagingRecords(fip,responseBody); 
                    op.ppvData = deserializeresponse.data;
                    outputList.add(op);
                } 
            }


                
            }
        } catch (Exception e) {
            logger.logMessages(urlParams, e.getMessage(), e.getStackTraceString(), 'Technical', '', '', false, false);


            FlowOutputParameter op = new FlowOutputParameter();
            System.debug('***Telstra:PRM_PPV_VerifyCode_Request:verifyOTPCode:exception:'+e.getMessage());
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
* Description : Method to prepare a list of staging-records for the list of secondary numbers provided by user 
* Jira : P2OB - 11853
*/
    public static List<PRM_PPVCheck_Staging__c> prepareStagingRecords(PRM_PPV_VerifyCode_Request.FlowInputParameter inputParam, String responseBody){
        List<PRM_PPVCheck_Staging__c> stagingRecords = new List<PRM_PPVCheck_Staging__c>();
        //P2OB - 11853 : Preparing list of staging-records
        for(String secondary_number : inputParam.numbers_for_porting){
            PRM_PPVCheck_Staging__c stage_record = new PRM_PPVCheck_Staging__c();
            stage_record.Opportunity_Id__c = inputParam.opportunity_ID;
            stage_record.Parent_Number__c = inputParam.custAuthRepDetails;
            stage_record.CA_Form_status__c = inputParam.CA_Form_status;
            stage_record.Is_Processed_in_CSV__c = false ;
            stage_record.Response_Details__c = responseBody;
            stage_record.Secondary_numbers__c = secondary_number;
            stage_record.Requested_by__c = UserInfo.getName();
            stage_record.Method_of_Verification__c = inputParam.verificationMethod;
            stage_record.Secondary_number_PPV_Status__c = inputParam.secondarynumberPPVstatus;//DIGI-14124
            //stage_record.BasketId__c = inputParam.basket_ID;//DIGI-14124


            stagingRecords.add(stage_record);
        }
        System.debug('stagingRecordsverfyotp***'+stagingRecords);
        return stagingRecords;
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
        public String OTP_input;
        @InvocableVariable
        public String opportunity_ID;
        @InvocableVariable



        public String CA_Form_status;
        @InvocableVariable
        public String verificationMethod;
        //DIGI-14124
        @InvocableVariable
        public String basket_ID;
        @InvocableVariable
        public String secondarynumberPPVstatus;
        

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
        @InvocableVariable
        public List<PRM_PPVCheck_Staging__c> stagingRecords;
        @InvocableVariable
        public PPV_Data ppvData;
        
    }

/**    
* Description : Wrapper class to parse API response
* Jira : P2OB - 11853
*/    
    public class PPV_Response{
        String correlationId; 
        String code;
        String status;
        String responseCode;       



        List<PPV_Error> errors;
        PPV_Data data;
    }
    
    public class PPV_Error{
        String message;
        String code;


    }
//
/**    
* Description : Added for getting number of attempts remaining for portin Functionality
* Jira : DIGI-779
* Added by : Irfan Inamdar--8th Sept 2021
*/   
    public class PPV_Data{
        public String attemptsRemaining;
        public String mobileNumber;


    }
}