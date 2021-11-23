/**************************************************************************
EDGE-207239
Description -DTO for recurring charge for billing enquiry 
Author      - Prajakta 
Team        -Munich
*********************************************************************************/
public with sharing class RecurringChargeTypeResponseDTO{
    @AuraEnabled
    public List<RecurringDetails> recurringDetails{get; set;}
    
    @AuraEnabled
    public List<RecurringDetails> invoiceLineAttributes{get; set;}
 
    
    public class RecurringDetails {
        
        @AuraEnabled
        public String orderNumber  {get; set;}
        
        @AuraEnabled
        public String basePlan  {get; set;}
        
        @AuraEnabled
        public String quantity  {get; set;}
        
        @AuraEnabled
        public Double excludingGSTcostFmtd  {get; set;}
        
        @AuraEnabled
        public Double includingGSTcostFmtd {get; set;}
        
        @AuraEnabled
        public String uniqueId  {get; set;}
        
        @AuraEnabled
        public long chargeIdentifier{get; set;}
          	
        @AuraEnabled
        public Integer invoiceTransactionId{get; set;}
        
        @AuraEnabled
        public List<InvoiceLineAttributes> invoiceLineAttributes{get; set;}
        
    }
    
     public class InvoiceLineAttributes {
       	@AuraEnabled
        public Integer invoiceTransactionId{get; set;}
    }
    
    public static RecurringChargeTypeResponseDTO parse(String json) {
        json = json.replace('serviceId', 'uniqueId');
        json = json.replace('amountExGST', 'excludingGSTcostFmtd');
        json = json.replace('amountIncGST', 'includingGSTcostFmtd');
        system.debug('response from DTO'+(RecurringChargeTypeResponseDTO) System.JSON.deserialize(json, RecurringChargeTypeResponseDTO.class));
        return (RecurringChargeTypeResponseDTO) System.JSON.deserialize(json, RecurringChargeTypeResponseDTO.class);
    }
}