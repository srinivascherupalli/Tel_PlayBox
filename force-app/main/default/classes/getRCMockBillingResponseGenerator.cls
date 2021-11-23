/*************************************************************************************************
Name : getRCMockBillingResponseGenerator
Description : generate MOck response for RC
Author: Akanksha Jain
Story: EDGE-207242
***************************************************************************************************/
public class getRCMockBillingResponseGenerator implements HttpCalloutMock{
    public Integer code;
    public String status;
    public String body;
    public Map<String, String> responseHeaders;

    public getRCMockBillingResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String endPoint = req.getEndpoint();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
         if(body.equalsIgnoreCase('200Response')){
          res.setBody('{ "accountNumber":"700000654660", "invoiceNumber":"9900000068954", "ariaInvoiceNumber":"150867579", "serviceType":"Bring your own - national plan (1)", "invoicePeriod":"01 Dec 20 - 31 Dec 20", "totalExGST":77.27, "totalIncGST":85.0, "recurringType":0, "isTaxable":true, "invoiceDate":"02 Jan 21", "recurringDetails":[ { "orderNumber":"CN000-302-212", "amountExGST":77.27, "amountIncGST":85.0, "startDate":"01 Jan 21", "endDate":"31 Jan 21", "quantity":"1", "isDiscounted":false, "isTaxable":true, "isQueryable":true, "isDisputable":true, "chargeIdentifier":76575, "chargeType":"RecurringCharge", "invoiceLineAttributes":[ { "invoiceLineNumber":4, "invoiceTransactionId":205016733, "chargeExcludingGST":77.27, "chargeIncludingGST":85.0, "chargeCharacteristics":{ "serviceInstanceId":"SVC-000123697", "chargeInstanceId":"0d8a0809-7826-7178-9dab-4fce578b64e5", "isRedeemable":false, "orderReference":"CN000-302-212" } } ], "unitPrice":77.27 } ] }');
        } else if(body.equalsIgnoreCase('404Response')){
            res.setBody('{"code":422,"status":422,"message":"Validation failed","errors":[{"code":1002,"field":"billingAccountNumber","message":"Mismatch in URI and request payload billingAccountNumber"}]}');
        }
        else if(body.equalsIgnoreCase('200ResponseFP')){
            res.setBody('{ "accountNumber":"700000654660", "invoiceNumber":"9900000068954", "ariaInvoiceNumber":"150867579", "serviceType":"Bring your own - national plan (1)", "invoicePeriod":"01 Dec 20 - 31 Dec 20", "totalExGST":77.27, "totalIncGST":85.0, "recurringType":0, "isTaxable":true, "invoiceDate":"02 Jan 21", "featurePackDetails":[ { "orderNumber":"CN000-302-212", "amountExGST":77.27, "amountIncGST":85.0, "startDate":"01 Jan 21", "endDate":"31 Jan 21", "quantity":"1", "isDiscounted":false, "isTaxable":true, "isQueryable":true, "isDisputable":true, "chargeIdentifier":76575, "chargeType":"RecurringCharge", "invoiceLineAttributes":[ { "invoiceLineNumber":4, "invoiceTransactionId":205016733, "chargeExcludingGST":77.27, "chargeIncludingGST":85.0, "chargeCharacteristics":{ "serviceInstanceId":"SVC-000123697", "chargeInstanceId":"0d8a0809-7826-7178-9dab-4fce578b64e5", "isRedeemable":false, "orderReference":"CN000-302-212" } } ], "unitPrice":77.27 } ] }');
        }
         else if(body.equalsIgnoreCase('200ResponseRepayment')){
            res.setBody('{ "accountNumber":"700000654660", "invoiceNumber":"9900000068954", "ariaInvoiceNumber":"150867579", "serviceType":"Bring your own - national plan (1)", "invoicePeriod":"01 Dec 20 - 31 Dec 20", "totalExGST":77.27, "totalIncGST":85.0, "recurringType":0, "isTaxable":true, "invoiceDate":"02 Jan 21", "repaymentDetails":[{"purchaseDate":"1 May 19","installment":"2 of 24","unitPrice":55,"chargedSoFar":110,"totalRemaining":1210,"isQueryable":true,"isDisputable":true,"chargeIdentifier":515,"chargeType":"RepaymentDetail","invoiceLineAttributes":[{"invoiceLineNumber":34,"invoiceTransactionId":3452342,"chargeExcludingGST":55,"chargeIncludingGST":55}]}] }');
        }
        else if(body.equalsIgnoreCase('404ResponseFP')){
            res.setBody('{"code":422,"status":422,"message":"Validation failed","errors":[{"code":1002,"field":"billingAccountNumber","message":"Mismatch in URI and request payload billingAccountNumber"}]}');
        }
        else {
            res.setBody('');
        }
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;    
    }
}