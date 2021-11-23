/*************************************************************************************************
Name : MockUsageCallout
Description : Mock class for Usage API
Author: Sasidhar Devarapalli
Story: EDGE-108332
Team: Osaka
***************************************************************************************************/
@isTest
global class MockUsageCallout implements HttpCalloutMock{
	protected String resType;
    
    global MockUsageCallout(String resType){
        this.resType = resType;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Search ='{   "usageType": "Int roaming day pass - zone 1 (2)",   "invoicePeriod": "01 Jun 19 - 23 Jun 19",   "accountNumber": "700000005112",   "invoiceNumber": "9900000182889",   "ariaInvoiceNumber": 148442927,   "totalExGST": 10,   "totalIncGST": 10,   "usageDetails": [     {       "date": "17 May 2019",       "time": "10:20am",       "amountExGST": 5,       "amountIncGST": 5,       "isTaxable": false,       "isQueryable": true,       "isDisputable": true,       "chargeIdentifier": 10002891,       "chargeType": "UsageDetail",       "invoiceLineAttributes": [         {           "invoiceLineNumber": 9,           "invoiceTransactionId": 197167980,           "chargeExcludingGST": 5,           "chargeIncludingGST": 5         }       ]     },     {       "date": "18 May 2019",       "time": "11:20am",       "amountExGST": 5,       "amountIncGST": 5,       "isTaxable": false,       "isQueryable": true,       "isDisputable": true,       "chargeIdentifier": 10002892,       "chargeType": "UsageDetail",       "invoiceLineAttributes": [         {           "invoiceLineNumber": 9,           "invoiceTransactionId": 197167980,           "chargeExcludingGST": 5,           "chargeIncludingGST": 5         }       ]     },     {       "date": "18 May 2019",       "time": "11:20am",       "amountExGST": 5,       "amountIncGST": 5,       "isTaxable": false,       "isQueryable": true,       "isDisputable": true,       "chargeIdentifier": 10002893,       "chargeType": "UsageDetail",       "invoiceLineAttributes": [         {           "invoiceLineNumber": 10,           "invoiceTransactionId": 197167981,           "chargeExcludingGST": 5,           "chargeIncludingGST": 5         }       ]     }   ] }';
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