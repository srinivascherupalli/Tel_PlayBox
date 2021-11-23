/********************************************************************
EDGE        :EDGE-116222
Controller  : EligibleRedemAmountResponseDTOTest
Description : EligibleRedemAmountResponseDTO
Author      : Nagamani
*******************************************************************/
@isTest
public class EligibleRedemptionAmountResponseDTOTest {
    
    
   @isTest 
    static void EligibleRedemptionAmountResponseTest() {
        String jsonData = '{"creditAdjustmentEligibility":[{"chargeIdentifier":986960,"invoiceLineNumber":1,"maxCreditAmount":100}]}';
      
        EligibleRedemptionAmountResponseDTO res = EligibleRedemptionAmountResponseDTO.parse(jsonData);
        EligibleRedemptionAmountResponseDTO.creditAdjustmentEligibility resChild = new  EligibleRedemptionAmountResponseDTO.creditAdjustmentEligibility();
        resChild.chargeIdentifier   = 986960;
        resChild.invoiceLineNumber  = 1;
        resChild.maxCreditAmount    = 100;
        System.assertNotEquals(res.creditAdjustmentEligibility, null);
    }

}