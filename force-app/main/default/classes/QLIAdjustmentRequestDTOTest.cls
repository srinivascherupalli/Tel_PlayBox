/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
******************************************************************/ 
@isTest
public class QLIAdjustmentRequestDTOTest
{
    @isTest 
    static void qLIAdjustmentRequestTest() {
        String jsonData = '{"customerAccountNumber":"700000006111","ariaInvoiceNumber":179598001,"chargeDetails":[{"chargeIdentifier":986960,"chargeType":"RecurringCharge","invoiceLineNumber":1}]}';
        QLIAdjustmentRequestDTO req = QLIAdjustmentRequestDTO.parse(jsonData);
        System.assertEquals(req.customerAccountNumber, '700000006111');
    }
}