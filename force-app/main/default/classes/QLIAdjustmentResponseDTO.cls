/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
* @description   - The class helps to generate the response for BDS.
******************************************************************/ 
public without sharing class QLIAdjustmentResponseDTO {
    
    public List<creditAdjustmentEligibility> creditAdjustmentEligibility {get;set;}
    public class creditAdjustmentEligibility
    {
        public Long chargeIdentifier {get;set;}
        public Long invoiceLineNumber {get;set;}
        public Decimal maxCreditAmount {get;set;}
    }
    public static QLIAdjustmentResponseDTO parse(String json) {
		return (QLIAdjustmentResponseDTO)System.JSON.deserialize(json, QLIAdjustmentResponseDTO.class);
	}
}