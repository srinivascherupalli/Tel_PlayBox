/*
* DEVELOPER : Vamshi/Hari
* TEAM: Napier
* DESCRIPTION : This class has logic to send request for EligibleRedemAmount response
* EDGE-116222
*/


public without sharing class EligibleRedemptionAmountResponseDTO {
    
    public List<creditAdjustmentEligibility> creditAdjustmentEligibility {get;set;}
    public class creditAdjustmentEligibility
    {
        public Integer chargeIdentifier {get;set;}
        public Integer invoiceLineNumber {get;set;}
        public double maxCreditAmount {get;set;}
    }
    public static EligibleRedemptionAmountResponseDTO parse(String json) {
		return (EligibleRedemptionAmountResponseDTO)System.JSON.deserialize(json, EligibleRedemptionAmountResponseDTO.class);
	}
}