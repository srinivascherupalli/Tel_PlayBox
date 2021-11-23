/*************************************************************************************************
Name : InvoiceComponentHandler
Description : Controller for Lightning component - InvoiceComponent.
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/
public with sharing class InvoiceComponentHandler {
    public static object data{get;set;}
    public static  String errorMessage {get;set;}
    public static  Boolean isShowPDF {get;set;}
    public static  Boolean showLoading {get;set;}
    /*-------------------------------------------------------- 
EDGE-88307
Method: getInvoicePDF
Description: Method to make callout to Invoice API
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static void getInvoice(){ 
        map<String,String> param = ApexPages.currentPage().getParameters();
        System.debug('param getInvoice: '+param);
        getInvoicePDF(param.get('custAcc'),param.get('invoice'));
        String myGeneratedFileName = 'SalesforceScool.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+myGeneratedFilename);
        showLoading = false;
    }
    /*-------------------------------------------------------- 
EDGE-88307
Method: getInvoicePDF
Description: Method to make callout to Invoice API
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static PageReference getInvoicePDF(String customerAccountNumber,String invoiceNumber){
        try{ 
            InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload(customerAccountNumber,Long.valueOf(invoiceNumber));            
            HttpResponse httpResp = InvoiceCalloutHandler.calloutInvoicePDF(requestDto);
            if(httpResp!=null && String.valueOf(httpResp.getStatusCode()).startsWith('2')){
                data = getPDF(httpResp);
                isShowPDF = true;
                System.debug('test success');
            }
            else {
                errorMessage =  getErrorResponse(httpResp);
                isShowPDF = false;
                System.debug('errorMessage:'+errorMessage);
            }
        }
        catch(Exception e){
            errorMessage =  'Error in fetching invoice. Please try after sometime.';
            isShowPDF = false;
            System.debug('errorMessage:'+errorMessage);
        }
        
        return null;
    }
    /*-------------------------------------------------------- 
EDGE-88307
Method: getPDF
Description: Method to get PDF from Invoice API
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static Object getPDF(HttpResponse response ){
        System.debug('response: '+response.getBody());
        Object responsePDF='data:application/pdf;base64,' + EncodingUtil.base64Encode(response.getBodyasBlob()); 
        //Object responsePDF='data:application/pdf;headers:filename=SalesforceScool;base64,' + EncodingUtil.base64Encode(response.getBodyasBlob()); 
        
        return responsePDF ;
    }
    
    /*-------------------------------------------------------- 
EDGE-88307
Method: getPDF
Description: Method to get error response from Invoice API
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static String getErrorResponse(HttpResponse response){
        String errorResponse = null;
        if(response!=null){
            if(response.getstatusCode()==500){ 
                InvoiceResponseDTO responseDto = InvoiceResponseDTO.parse(response.getBody() );
                errorResponse = responseDto.errorMessage ;
            }
            else if(String.valueOF(response.getstatusCode()).startsWith('5')){
                errorResponse = 'Error in fetching invoice. Please try after sometime.';
            }             
        } 
        return errorResponse;
    }
    
    /*-------------------------------------------------------- 
EDGE-88307
Method: getInvoiceRequestDetails
Description: Method to get invoice Details for Lightning component
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    @AuraEnabled
    public static RequestWrapper getInvoiceRequestDetails(String invoiceId){
        RequestWrapper requestDto = null;
        List<Invoice__c>  invoice = [SELECT Billing_Account__r.Billing_Account_Number__c,Name FROM Invoice__c WHERE ID=:invoiceId];
        System.debug('invoice: '+invoice);
        If(!invoice.isEmpty()){
            requestDto = new RequestWrapper();
            requestDTO.customerAccountNumber = invoice[0].Billing_Account__r.Billing_Account_Number__c;
            requestDto.invoiceNumber=Long.valueOf(invoice[0].Name);
        }
        System.debug('requestDto:'+requestDto);
        return requestDTO;
    }
    /*-------------------------------------------------------- 
EDGE-88307
Method: getInvoiceRequestBulk
Description: Method to get invoice Details for Trigger
Author:Kalashree Borgaonkar
--------------------------------------------------------*/ 
    public static List<InvoiceRequestDTO> getInvoiceRequestBulk(List<String> invoiceIdList){
        List<InvoiceRequestDTO> requestDtoList = new List<InvoiceRequestDTO>();
        InvoiceRequestDTO requestDto = null;
        //List<Invoice__c>  invoice = [SELECT Billing_Account__r.Billing_Account_Number__c,Name FROM Invoice__c WHERE ID=:invoiceId];
        Map<id,Invoice__c> invoiceMap= new Map<id,Invoice__c>([SELECT Billing_Account__r.Billing_Account_Number__c,Name FROM Invoice__c WHERE ID IN :invoiceIdList]);
        System.debug('invoiceMap: '+invoiceMap);
        for(String invoiceId : invoiceMap.keyset()){
            requestDto = new InvoiceRequestDTO();
            requestDTO.customerAccountNumber = invoiceMap.get(invoiceId).Billing_Account__r.Billing_Account_Number__c;
            requestDto.invoiceNumber=Long.valueOf(invoiceMap.get(invoiceId).Name);
            requestDtoList.add(requestDto);
        }
        System.debug('requestDto:'+requestDtoList);
        return requestDtoList;
    }
    
    //Wrapper to send values to InvoicePdfPage
    public class  RequestWrapper{
        @AuraEnabled
        public String customerAccountNumber;
        @AuraEnabled
        public Long invoiceNumber;
    }
    
}