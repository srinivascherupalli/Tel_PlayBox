/***************************************************************************************************************************************************************
Name : RepaymentResponseDTO
Description : Parse response for Repayment Callout
Author: Jawahar M
Story: EDGE-108333
Team: Osaka
*****************************************************************************************************************************************************************/
public with sharing class RepaymentResponseDTO{
    
    @AuraEnabled	
    public RepaymentSummary repaymentSummary{get; set;}
    
    @AuraEnabled	
    public List<RepaymentDetails> repaymentDetails{get; set;}
     
     @AuraEnabled	
    public List<InvoiceLineAttributes> invoiceLineAttributes{get; set;}
 
     public class InvoiceLineAttributes {
         @AuraEnabled
         public Integer invoiceTransactionId{get; set;}
         @AuraEnabled
         public Double excludingGSTcostFmtd{get; set;}
         @AuraEnabled
         public Double includingGSTcostFmtd{get; set;}
     }
 
     public class RepaymentSummary {
         @AuraEnabled
         public list<RepaymentDetails> repaymentDetails{get; set;}
     }
 
     public class RepaymentDetails {
         @AuraEnabled
         public String purchaseDate{get; set;}
         @AuraEnabled
         public String installment{get; set;}
          @AuraEnabled
         public String uniqueId{get; set;}
         @AuraEnabled
         public Double unitPrice{get; set;}
         @AuraEnabled
         public Double chargedSoFar{get; set;}
         @AuraEnabled
         public String orderNumber{get; set;}
         @AuraEnabled
         public Integer chargeIdentifier{get; set;}
         @AuraEnabled
         public Double chargedThisInvoice{get; set;}
          @AuraEnabled
         public Double excludingGSTcostFmtd{get; set;}
         @AuraEnabled
         public Double includingGSTcostFmtd{get; set;}
         @AuraEnabled
         public Double invoiceTransactionId{get; set;}
         @AuraEnabled
         public Double quantity{get; set;}
         @AuraEnabled
         public list<InvoiceLineAttributes> invoiceLineAttributes{get; set;}
     }
 
     
     public static RepaymentResponseDTO parse(String json) {
         json = json.replace('deviceId', 'uniqueId');
          json = json.replace('chargeExcludingGST', 'excludingGSTcostFmtd');
          json = json.replace('chargeIncludingGST', 'includingGSTcostFmtd');
         return (RepaymentResponseDTO) System.JSON.deserialize(json, RepaymentResponseDTO.class);
     }
 }