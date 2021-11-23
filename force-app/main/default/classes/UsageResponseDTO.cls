/***************************************************************************************************************************************************************
Name : UsageResponseDTO
Description : Parse response for UsageSummary Callout
Author: Sasidhar Devarapalli
Story: EDGE-108332
Team: Osaka
*****************************************************************************************************************************************************************/
public with sharing class UsageResponseDTO {
    	public String errorKey;
    	public String errorMessage;
    	public String usageType;
        public String invoicePeriod;
        public String accountNumber;
        public String invoiceNumber;
        public String ariaInvoiceNumber;
        public Double totalExGST;
        public Double totalIncGST;
    	public List<usageDetails> usageDetails;
    
    public class InvoiceLineAttributes {
        public Integer invoiceLineNumber;
        public Integer invoiceTransactionId;
        public Double chargeExcludingGST;
        public Double chargeIncludingGST;
    }
    
    public class UsageDetails {
        public String serviceNumber;
        public String date_x;
        public String time_x;
        public Double amountExGST;
        public Double amountIncGST;
        public Boolean isTaxable;
        public Boolean isQueryable;
        public Boolean isDisputable;
        public Integer chargeIdentifier;
        public String chargeType;
        public String numberReceivedCallFrom;
        public String duration;
        public String numberCalled;
        public String numberTexted;
        public String usage;
        public Integer quantityOfTopUps;
        public List<InvoiceLineAttributes> invoiceLineAttributes;
    }
    
    public static UsageResponseDTO parse(String json) {
        return (UsageResponseDTO) System.JSON.deserialize(json, UsageResponseDTO.class);
    }
}