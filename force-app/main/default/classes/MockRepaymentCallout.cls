/*************************************************************************************************
Name : MockRepaymentCallout
Description : Mock class for Repayment API
Author: Jawahar M
Story: EDGE-108333
Team: Osaka
***************************************************************************************************/
@isTest
global class MockRepaymentCallout implements HttpCalloutMock{
  protected String resType;
    
    global MockRepaymentCallout(String resType){
        this.resType = resType;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Search ='{ \"repaymentSummary\": { \"deviceName\": \"Apple Watch S6 Cell 40mm Blue with Deep Navy Sport Band Repayment (1)\", \"invoicePeriod\": \"1 Nov 21 - 30 Nov 21\", \"accountNumber\": \"700000767918\", \"invoiceNumber\": \"9900000108260\", \"ariaInvoiceNumber\": \"152019882\", \"chargedThisInvoice\": 62.42, \"chargedSoFar\": 312.1, \"totalRemaining\": 187.26, \"isTaxable\": false, \"repaymentType\": 0, \"repaymentDetails\": [ { \"purchaseDate\": \"2 Aug 21\", \"installment\": \"5 of 8\", \"unitPrice\": 62.42, \"chargedSoFar\": 312.10, \"totalRemaining\": 187.26, \"isDisputable\": true, \"isQueryable\": true, \"chargeType\": \"RecurringCharge\", \"chargeIdentifier\": 136710, \"isTaxable\": false, \"chargedThisInvoice\": 0.0, \"invoiceLineAttributes\": [ { \"invoiceLineNumber\": 2, \"invoiceTransactionId\": 207543026, \"chargeExcludingGST\": 62.42, \"chargeIncludingGST\": 62.42 } ] } ] } }';
        String success_Error = '{"errorKey":"usage.data.not.found","errorMessage":"Usage data not found"}';
        String success_Error_503 = '';
        if(resType.contains('success_Search')){
            res.setBody(success_Search);
            res.setStatusCode(200);
        }
        else if(resType.equalsIgnoreCase('success_Error')){
            res.setBody(success_Error);
            res.setStatusCode(500);
        }
        else if(resType.equalsIgnoreCase('success_Error_503')){
            res.setBody(success_Error_503);
            res.setStatusCode(503);
        }
        System.assertEquals(res!=null,true,'Return response');
        return res;
    }
}