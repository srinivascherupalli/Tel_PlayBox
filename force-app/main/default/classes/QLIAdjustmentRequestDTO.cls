/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
* @description  - The class helps to generate the request payload for BDS.
******************************************************************/ 
public with sharing class QLIAdjustmentRequestDTO {
    
    public String customerAccountNumber;
    public Long ariaInvoiceNumber;
    public List<chargeDetails> chargeDetails;

    public class chargeDetails {
        public Long chargeIdentifier;
        public String chargeType;
        public Long invoiceLineNumber;
    }
    public static QLIAdjustmentRequestDTO parse(String json) {
		return (QLIAdjustmentRequestDTO) System.JSON.deserialize(json, QLIAdjustmentRequestDTO.class);
	}
}