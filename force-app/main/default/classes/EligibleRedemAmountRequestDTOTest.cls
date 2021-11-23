/********************************************************************
EDGE        :EDGE-116222
Controller  : EligibleRedemAmountRequestDTOTest
Description : EligibleRedemAmountRequestDTO
Author      : Hari/Vamshi
*******************************************************************/


@isTest
public class EligibleRedemAmountRequestDTOTest
{
    @isTest 
    static void eligibleRedemAmountRequestTest() {
        String jsonData = '{"customerAccountNumber":"700000006111","ariaInvoiceNumber":179598001,"chargeDetails":[{"chargeIdentifier":986960,"chargeType":"RecurringCharge","invoiceLineNumber":1}]}';
        EligibleRedemAmountRequestDTO req = EligibleRedemAmountRequestDTO.parse(jsonData);
        System.assertEquals(req.customerAccountNumber, '700000006111');
    }
}