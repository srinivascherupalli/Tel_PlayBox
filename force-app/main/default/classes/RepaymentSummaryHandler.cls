/**************************************************************************
EDGE        -108333
component   -RepaymentSummaryCmp
Description -Controller for Component RepaymentSummaryCmp
Author      -Jawahar M
Team        -Osaka
Modification History 
1. Gnana        25/05/2021      EDGE-215748 - Created a new method getRepaymentResponseDetails
*********************************************************************************/
public with sharing class RepaymentSummaryHandler {
    //     //UI Wrapper for Error and Success Data
    //     public class AdjustmentFullWrapper{
    //         @AuraEnabled
    //         public List<repaymentDataWrapper> lstAddWrapper{get; set;}
    //         @AuraEnabled
    //         public ErrorWrapper errorwr{get; set;}
    
    //     }
    
    //   //UI Wrapper for API response 
    //     public class repaymentDataWrapper{
    
    //         @AuraEnabled
    //         public String deviceName{get; set;}
    //         @AuraEnabled
    //         public String invoicePeriod{get; set;}
    //         @AuraEnabled
    //         public String accountNumber{get; set;}
    //         @AuraEnabled
    //         public String invoiceNumber{get; set;}
    //         @AuraEnabled
    //         public String ariaInvoiceNumber{get; set;}
    //         @AuraEnabled
    //         public String chargedThisInvoice{get; set;}
    //         @AuraEnabled
    //         public String chargedSoFar{get; set;}
    //         @AuraEnabled
    //         public String purchaseDate{get; set;}
    //         @AuraEnabled
    //         public String installment{get; set;}
    //         @AuraEnabled
    //         public String unitPrice{get; set;}
    //         @AuraEnabled
    //         public String totalRemaining{get; set;}
    //         @AuraEnabled
    //         public String isQueryable{get; set;}
    //         @AuraEnabled
    //         public String chargeIdentifier{get; set;}
    //         @AuraEnabled
    //         public String chargeType{get; set;}
    
    //     }
    
    //     //Ui wrapper for Error API response
    //     public class ErrorWrapper
    //     {
    //         @AuraEnabled
    //         public Integer code { get; set; }
    //         @AuraEnabled
    //         public string field { get; set; }
    //         @AuraEnabled
    //         public string message { get; set; }
    //     }
    
    //     /*-------------------------------------------------------- 
    //     EDGE-108333
    //     Method: getRepaymentResponseDetails
    //     Description: Method to generate the repaymentRequestDTO and get the repaymentResponseDTO
    //     Author:Jawahar M
    //   --------------------------------------------------------*/
    
    //     @AuraEnabled
    //     public static AdjustmentFullWrapper getUsageResponseDetails(String invoiceLineItemId){
    
    //         RepaymentRequestDTO requestDto = null;
    //         RepaymentResponseDTO res = null;
    //         List<repaymentDataWrapper> childWrapper = new List<repaymentDataWrapper>();
    //         AdjustmentFullWrapper resultWrapper = new AdjustmentFullWrapper();
    //         List<Invoice_Line_Item__c>  invoiceLineItem = [SELECT Usage_Type_Code__c,Charge_Id__c,Invoice_Transaction_ID__c,Invoice_Line_Number__c,Invoice__r.name,Invoice__r.Aria_Invoice_Number__c,Invoice__r.Billing_Account__r.Billing_Account_Number__c,Invoice__r.Invoice_Period__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c FROM Invoice_Line_Item__c  WHERE id = :invoiceLineItemId];
    //         System.debug('invoiceLineItem: '+invoiceLineItem);
    //         If(!invoiceLineItem.isEmpty()){
    //             requestDto = new RepaymentRequestDTO();
    //             requestDto.chargeId = Integer.ValueOf(invoiceLineItem[0].Charge_Id__c);
    //             requestDto.statementNumber = invoiceLineItem[0].Invoice__r.Name;
    
    //         }
    //         /*** START OF EDGE-125016 ***/
    //         Integer transactionId = invoiceLineItem[0].Invoice_Transaction_ID__c.intValue();
    //         /*** END OF EDGE-125016 ***/
    //         Integer Invoicenumber = Integer.valueof(invoiceLineItem[0].Invoice_Line_Number__c);
    
    //         System.debug('requestDto:'+requestDto);
    //         res = RepaymentCalloutHandler.calloutUsageDetails(requestDto);
    //         System.debug('res final resutl'+res);
    
    //         if(res!= null)
    //                 { 
    //                     repaymentDataWrapper usage = new repaymentDataWrapper();
    //                     usage.deviceName= res.repaymentSummary.deviceName;
    //                     usage.invoicePeriod= res.repaymentSummary.invoicePeriod;
    //                     usage.accountNumber= res.repaymentSummary.accountNumber;
    //                     usage.invoiceNumber= res.repaymentSummary.invoiceNumber;
    //                     usage.ariaInvoiceNumber= ''+res.repaymentSummary.ariaInvoiceNumber;
    //                     usage.chargedThisInvoice= ''+res.repaymentSummary.chargedThisInvoice;
    //                     usage.chargedSoFar= ''+res.repaymentSummary.chargedSoFar;
    //                     usage.totalRemaining=''+res.repaymentSummary.totalRemaining;
    //                     system.debug('Aura controller--->>>>>>');
    //                     RepaymentResponseDTO responseDTO = new RepaymentResponseDTO();
    //                     RepaymentResponseDTO.repaymentDetails repayment = new RepaymentResponseDTO.repaymentDetails();
    //                     List<RepaymentResponseDTO.repaymentDetails> usageDetailsListObj = new List<RepaymentResponseDTO.repaymentDetails>();
    //                     RepaymentResponseDTO.repaymentDetails usageRecord = new RepaymentResponseDTO.repaymentDetails();
    //                     for(RepaymentResponseDTO.repaymentDetails usageDetailsVar : res.repaymentSummary.repaymentDetails){
    
    //                         for(RepaymentResponseDTO.invoiceLineAttributes invoiceAttri: usageDetailsVar.invoiceLineAttributes){
    
    
    //                             if((invoiceAttri.invoiceTransactionId==transactionId) && (invoiceAttri.invoiceLineNumber==Invoicenumber)){
    //                                 system.debug('inside if loop--->>>');
    //                                 usage.purchaseDate= ''+usageDetailsVar.purchaseDate;
    //                                 usage.installment= ''+usageDetailsVar.installment;
    //                                 usage.unitPrice= ''+usageDetailsVar.unitPrice;
    //                                 usage.chargedSoFar= ''+usageDetailsVar.chargedSoFar;
    //                                 usage.totalRemaining = ''+usageDetailsVar.totalRemaining;
    //                                 usage.isQueryable = ''+usageDetailsVar.isQueryable;
    //                                 usage.chargeIdentifier = ''+usageDetailsVar.chargeIdentifier;
    //                                 usage.chargeType = ''+usageDetailsVar.chargeType;
    //                                 usageDetailsListObj.add(usageRecord);
    //                             }
    //                         }
    //                     }
    //                     //repayment = usageDetailsListObj;
    //                     //repayment = usageRecord;
    
    
    //             childWrapper.add(usage);
    
    //                         resultWrapper.lstAddWrapper = childWrapper;
    //                         resultWrapper.errorwr= null;
    //                     }              
    
    
    //             return resultWrapper;
    
    
    //             } */
    
    /*----------------------------------------------------------------
Method     : getRepaymentResponseDetails
Description: Method to get Repayment Response Details for corresponding Invoice
Author     : Gnana
Story      : EDGE-215748 
-------------------------------------------------------------------------------------*/  
    @AuraEnabled
    public static String getRepaymentResponseDetails(Long chargeId, String statementNumber, String accountNumber, String handlerName){
        RepaymentResponseDTO res = new RepaymentResponseDTO();         
        InvoiceChargeTypeRequestDTO requestDTO = new InvoiceChargeTypeRequestDTO();
        requestDTO.accountNumber = accountNumber;
        requestDTO.chargeId = chargeId;
        requestDTO.statementNumber = statementNumber;
        String request = JSON.serialize(requestDTO,true);
        list<RepaymentResponseDTO.repaymentDetails> finalList = new list<RepaymentResponseDTO.repaymentDetails>();
       
        HttpResponse repaymentResponse;
        try{
            
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            String token = ''; 
            Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
            if(handleSettingRecord!=null) {
                if(handleSettingRecord.Enable_Mock_Integration__c) {
                    token=System.Label.QLI_Token; 
                }
                else {
                    token = AuthenticationManager.getOauthToken(handlerName);
                }
            }
            Map < String, String > headerMap = new Map < String, String > {
                'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + token,
                    'correlationId' => correlationId,
                    'caller-app' =>'Salesforce' // check from BDS
                    };
                        
            repaymentResponse=IntegrationRecordHandlerUtil.calloutSync(request, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            if(repaymentResponse!= null){
                Logger2 log = Logger2.getLogger(handlerName);
                DateTime startTime = DateTime.now();
                DateTime endTime = DateTime.now();
                Long requestTime = log.getRequestTimeDifference(startTime, endTime);
                log.logMessages(request, repaymentResponse.getBody(), '', '', '', 
                                '', String.valueOf(repaymentResponse.getStatusCode()), correlationId, '','','Create','',requestTime,'POST',false, false);
                
                logger.exitLogger();
                System.debug('response:repayment'+repaymentResponse); 
                
                
                String responseCode = String.valueOf(repaymentResponse.getStatusCode());
                if (responseCode.startsWith('2')) {
                     RepaymentResponseDTO responseDTO = RepaymentResponseDTO.parse(repaymentResponse.getBody());
                     system.debug('responseDTO-RepaymentSummary' +responseDTO.RepaymentSummary); 
                     system.debug('responseDTO-RepaymentSummary' +responseDTO.repaymentSummary); 
                     RepaymentResponseDTO.RepaymentSummary repSummary =(RepaymentResponseDTO.RepaymentSummary)responseDTO.repaymentSummary;
                     List<RepaymentResponseDTO.RepaymentSummary> recList = new List<RepaymentResponseDTO.RepaymentSummary>();
                     recList.add(repSummary);
                 
                   for(RepaymentResponseDTO.RepaymentSummary repaymentSum:recList)
                    {
                      
                       for(RepaymentResponseDTO.repaymentDetails repaymentDet:repaymentSum.repaymentDetails)
                        {
                            for(RepaymentResponseDTO.invoiceLineAttributes invoiceAttrib: repaymentDet.invoiceLineAttributes)
                            {
                                repaymentDet.excludingGSTcostFmtd = invoiceAttrib.excludingGSTcostFmtd;
                                repaymentDet.includingGSTcostFmtd = invoiceAttrib.includingGSTcostFmtd;
                                repaymentDet.invoiceTransactionId= invoiceAttrib.invoiceTransactionId;
                            }
                            finalList.add(repaymentDet);
                        } 
                    }
                    log.logMessages(request, repaymentResponse.getBody(), '', '', '', '', false, false,Integer.valueof(repaymentResponse.getStatusCode()) , null, null, null);  
                }
            }
            system.debug('finalList'+(String)JSON.serialize(finalList,true));
            return (String)JSON.serialize(finalList,true);
        }
        catch (Exception e) {
            logException('getRecurringChargeDetails', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Request to BDS failed');
            throw e;
        }
        
    }
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', 'Billing Enquiry');
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
}