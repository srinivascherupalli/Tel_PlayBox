/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
******************************************************************/ 
@isTest
public class QLIAdjustmentResponseDTOTest
{
    @isTest 
    static void qLIAdjustmentRequestTest() {
        String jsonData = '{"creditAdjustmentEligibility":[{"chargeIdentifier":986960,"invoiceLineNumber":1,"maxCreditAmount":100}]}';
      
        QLIAdjustmentResponseDTO res = QLIAdjustmentResponseDTO.parse(jsonData);
        QLIAdjustmentResponseDTO.creditAdjustmentEligibility resChild = new  QLIAdjustmentResponseDTO.creditAdjustmentEligibility();
        resChild.chargeIdentifier   = 986960;
        resChild.invoiceLineNumber  = 1;
        resChild.maxCreditAmount    = 100;
        System.assertNotEquals(res.creditAdjustmentEligibility, null);
    }
}