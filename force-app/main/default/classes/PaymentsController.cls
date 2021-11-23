/*----------------------------------------------------------------------------
EDGE        -88306
Class Name  -PaymentsController
Description -Controller Class for Fetching Billing account payments.
Author      -Dheeraj Bhatt
//EDGE-194644 PaymentType changes added by Ravi Shankar on 22-Feb-2021
//EDGE-212792 Added new method to perform transactional payment service call using billing account number
-------------------------------------------------------------------------------*/
public without sharing class PaymentsController {
    
    /*----------------------------------------------------------------------------
EDGE        -88306
Method Name -getBAN
Description -Get Billing account number
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @AuraEnabled  public static string getBan(String billingAccountId){
        String ban='';
        Try{
            ban=[Select Billing_Account_Number__c from Billing_Account__c where ID =:billingAccountId].Billing_Account_Number__c;
        }
        
        Catch(Exception ex){
            system.debug('Exception Occured in paymentsController class at Line Number '+ex.getLineNumber()+' due to '+ex.getMessage());
        }
        return ban ;
    }
  /*----------------------------------------------------------------------------
EDGE        -88306
Method Name -getPayments
Description -to get the payments by passing the BAN, start and end date in API request
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @AuraEnabled public static responseWrapper getPayments( String handler, String ban,Date fromDate,Date toDate){
        BillingAccountPaymentsResponseDto  responseObj=new BillingAccountPaymentsResponseDto();
        responseWrapper resultResponseWrapper=new responseWrapper();
        Try{
            HttpResponse response=BillingAccountPaymentsService.paymentServiceRequest(handler,ban,fromDate,toDate);            
            if(response != null)
            {
                responseObj= (BillingAccountPaymentsResponseDto)JSON.deserialize(response.getBody(), BillingAccountPaymentsResponseDto.class);
                if(responseObj!=null){
                    if(responseObj.payments != NULL && responseObj.payments.size() > 0){
                        List<responsePayments> listResponsePayments=new List<responsePayments>();
                        for(BillingAccountPaymentsResponseDto.payments paymentResponseDto:responseObj.Payments){
                            responsePayments respPayments=new responsePayments();
                            respPayments.transactionId=string.valueOf(paymentResponseDto.transactionId);
                            respPayments.paymentDate=paymentResponseDto.paymentDate;
                            respPayments.paymentType=paymentResponseDto.paymentType;
                            respPayments.paymentAmount=paymentResponseDto.paymentAmount;
                            respPayments.paymentAppliedAmount=paymentResponseDto.paymentAppliedAmount;
                            respPayments.paymentUnappliedAmount=paymentResponseDto.paymentUnappliedAmount;
                            respPayments.paymentAmountIndicator=paymentResponseDto.paymentAmountIndicator;
                            listResponsePayments.add(respPayments);
                        }
                        resultResponseWrapper.responsePayments=listResponsePayments;
                    }
                    else If(responseObj.Errors != NULL && responseObj.Errors.size() > 0){
                        List<responseErrors> listResponseErrors=new List<responseErrors>();
                        for(BillingAccountPaymentsResponseDto.errors errorsResponseDto:responseObj.errors){
                            responseErrors respError=new responseErrors();
                            respError.code=errorsResponseDto.code;
                            respError.field=errorsResponseDto.field;
                            respError.message=errorsResponseDto.message;
                            listResponseErrors.add(respError);
                        }
                        resultResponseWrapper.responseErrors=listResponseErrors;
                    }
                    
                }
            }
        }
        Catch (Exception ex){
            system.debug('Exception Occured in paymentsController class at Line Number '+ex.getLineNumber()+' due to '+ex.getMessage());
        }
        return  resultResponseWrapper;
    }

    /*-----------------------------------------------------------------------------
    EDGE        -212792
    Method Name -getPaymentByTransactionId
    Description -Creating the auraenabled method to fetch the transaction details related to Billing Account Number. 
    Author      -Kamlesh Kumar
    Created Date-11/05/2021
    -------------------------------------------------------------------------------*/
    @AuraEnabled 
    public static BillingAccountPaymentsResponseDto getPaymentByTransactionId(String handler, String ban,String transactionId) {
        Utility_Settings__c utilSettings = Utility_Settings__c.getInstance();
        BillingAccountPaymentsResponseDto  responseObj=new BillingAccountPaymentsResponseDto();
        responseWrapper resultResponseWrapper=new responseWrapper();
        try{
            HttpResponse response=BillingAccountPaymentsService.transactionalPaymentServiceRequest(handler,ban,transactionId);            
            if(response != null)
            {
                responseObj= (BillingAccountPaymentsResponseDto)JSON.deserialize(response.getBody(), BillingAccountPaymentsResponseDto.class);
            }
            else {
                BillingAccountPaymentsResponseDTO.Errors errorObj = new BillingAccountPaymentsResponseDTO.Errors();
                List<BillingAccountPaymentsResponseDTO.Errors> errorList = new List<BillingAccountPaymentsResponseDTO.Errors>();
                errorList.add(errorObj);
                errorObj.message = String.isNotBlank(utilSettings.Payment_Failure_Message__c) ? utilSettings.Payment_Failure_Message__c : '';
                responseObj.Errors = errorList;
            } 
        }
        catch (Exception e){
            GenericUtilityClass.logException('PaymentsController','transactionalPaymentServiceRequest','',responseObj.Correlation_Id,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception Occured in transactionalPaymentServiceRequest method',C2O_ExceptionHandler.Capability.BSK);
            BillingAccountPaymentsResponseDTO.Errors errorObj = new BillingAccountPaymentsResponseDTO.Errors();
            List<BillingAccountPaymentsResponseDTO.Errors> errorList = new List<BillingAccountPaymentsResponseDTO.Errors>();
            errorList.add(errorObj);
            errorObj.message = String.isNotBlank(utilSettings.Payment_Failure_Message__c) ? utilSettings.Payment_Failure_Message__c : '';
            responseObj.Errors = errorList;
            return responseObj;
        }
        return responseObj;
    }

    /****
     * EDGE         -   215989
     * Method Name  -   checkPaymentDormance
     * Author       -   Pooja Bhat
     * Created Date -   03/Jun/2021
    */
    @AuraEnabled
    public static Boolean checkPaymentDormance(){
        Boolean isDormanceEnabled = false;
        try {
            Utility_Settings__c utilSettings = Utility_Settings__c.getInstance();
            if(utilSettings.Enable_Dormancy__c != null && utilSettings.Enable_Dormancy__c.containsIgnoreCase('BillAccTransactionIdBtn')) {
                isDormanceEnabled   =   true;
            }
        } catch(Exception e) {
            return false;
        }
        return isDormanceEnabled;
    }

    /*UI Wrapper for Error and Success Data */
    public class responseWrapper{
        @AuraEnabled Public List<responsePayments> responsePayments;
        @AuraEnabled  Public List<responseErrors> responseErrors;
    }
    /* class for representing the customer's payments*/
    Public class responsePayments{
        @AuraEnabled  public String transactionId;
        @AuraEnabled  Public String paymentDate;
        @AuraEnabled  Public String paymentType;
        @AuraEnabled  Public Decimal paymentAmount;//EDGE-198859 updated to Decimal from integer as part of INC000094199791
        @AuraEnabled  Public Decimal paymentAppliedAmount;
        @AuraEnabled  Public Decimal paymentUnappliedAmount;//EDGE-198859 updated to Decimal from integer as part of INC000094199791
        @AuraEnabled  Public String paymentAmountIndicator;
        @AuraEnabled  Public String paymentAmountFmtd;

    }

    /* Class for representing error in API Callout*/
    Public Class responseErrors{
        @AuraEnabled public Integer code;
        @AuraEnabled Public string  field;
        @AuraEnabled Public string  message;
    }   
    
}