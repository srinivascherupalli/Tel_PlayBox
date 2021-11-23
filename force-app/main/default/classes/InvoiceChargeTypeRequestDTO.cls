/*************************************************************************************************
Name : InvoiceChargeTypeRequestDTO
Description : Requeste DTO for different charge types in invoice details Callout
Author: Pawan Singh
Story: EDGE-207241
***************************************************************************************************/
public with sharing class InvoiceChargeTypeRequestDTO {
    
        public String statementNumber;
        public String accountNumber;
        public Long chargeId;
        
        public static InvoiceChargeTypeRequestDTO parse(String json) {
            return (InvoiceChargeTypeRequestDTO) System.JSON.deserialize(json, InvoiceChargeTypeRequestDTO.class);
         }
    }