/*----------------------------------------------------------------------------
EDGE        -88306
Name        -BillingAccountPaymentsResponseDTOTest
Description -test Class for BillingAccountPaymentsResponse class.
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
@IsTest
public class BillingAccountPaymentsResponseDTOTest {
    @IsTest public static void classData(){
        String json='{"code":200,"status":200,"message":"Success","billingAccountNumber":700000335518,"payments":[{"transactionId":198632330,"paymentAmount":15,"paymentDate":"09/07/2019","paymentUnappliedAmount":0},{"transactionId":198632190,"paymentAmount":10,"paymentDate":"09/07/2019","paymentUnappliedAmount":0},{"transactionId":198630533,"paymentAmount":10,"paymentDate":"09/07/2019","paymentUnappliedAmount":0},{"transactionId":197617063,"paymentAmount":1705,"paymentDate":"06/03/2019","paymentUnappliedAmount":0},{"transactionId":197617060,"paymentAmount":1,"paymentDate":"06/03/2019","paymentUnappliedAmount":0},{"transactionId":197617051,"paymentAmount":10,"paymentDate":"06/03/2019","paymentUnappliedAmount":0},{"transactionId":196475020,"paymentAmount":6,"paymentDate":"24/09/2018","paymentUnappliedAmount":0},{"transactionId":196309100,"paymentAmount":1000,"paymentDate":"30/08/2018","paymentUnappliedAmount":0},{"transactionId":196286349,"paymentAmount":2916,"paymentDate":"28/08/2018","paymentUnappliedAmount":0},{"transactionId":196286155,"paymentAmount":1000,"paymentDate":"28/08/2018","paymentUnappliedAmount":0}]}';
        Test.startTest();
        BillingAccountPaymentsResponseDTO response=(BillingAccountPaymentsResponseDTO) System.JSON.deserialize(json, BillingAccountPaymentsResponseDTO.class);
        Test.stopTest();
        System.assert(response.Correlation_Id==null);
        System.assert(response.billingAccountNumber==700000335518.00);
        System.assert(response.code==200);
        System.assert(response.message=='success');
        System.assert(response.status=='200');
        System.assert(response.payments[0].paymentAmount==15);
        System.assert(response.payments[0].paymentDate=='09/07/2019');
        System.assert(response.payments[0].paymentUnappliedAmount==0);
        System.assert(response.payments[0].transactionId==198632330);
        System.assert(response.payments[0].paymentApplicationDetails==null);
        System.assert(response.errors==null);
        
    }
}