/*
* DEVELOPER : Vamshi/Hari
* TEAM: Napier
* DESCRIPTION : This class has logic to send request for EligibleRedemAmount
* EDGE-116222
*/
public with sharing class EligibleRedemAmountRequestDTO {

    
    public String customerAccountNumber;
    public Long ariaInvoiceNumber;
    public List<ChargeDetails> chargeDetails;

    public class ChargeDetails {
        public Integer chargeIdentifier;
        public String chargeType;
        public Long invoiceLineNumber;
    }
    public static EligibleRedemAmountRequestDTO parse(String json) {
		return (EligibleRedemAmountRequestDTO) System.JSON.deserialize(json, EligibleRedemAmountRequestDTO.class);
	}

}