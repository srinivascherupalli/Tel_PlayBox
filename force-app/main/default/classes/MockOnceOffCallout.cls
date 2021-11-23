/*************************************************************************************************
Name : MockOnceOffCallout
Description : to generate mock response for Once-Off charge
Author: Pawan Singh
EDGE : 215747
***************************************************************************************************/
@istest
global class MockOnceOffCallout implements HttpCalloutMock{
	protected String resType;
    
    global MockOnceOffCallout(String resType){
        this.resType = resType;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String successResponse ='{"accountNumber":"700000015101","invoiceNumber":"9900000530358","ariaInvoiceNumber":"149267726","serviceType":"Professional Service Installation 24x7 (2)","invoicePeriod":"01 Jun 20 - 30 Jun 20","totalExGST":600,"totalIncGST":660,"orderType":1,"isTaxable":true,"orderDetails":[{"orderNumber":"ORD-127","poNum":"REF123","quantity":"3.5 hrs","unitRate":100,"date":"15 Jul 20","amountExGST":350,"amountIncGST":385,"isTaxable":true,"isQueryable":true,"isDisputeable":true,"chargeType":"OnceOffCharge","chargeIdentifier":166201,"deviceId":"12345","caseId":"6747353","invoiceLineAttributes":[{"invoiceLineNumber":37,"invoiceTransactionId":24320,"chargeExcludingGST":350,"chargeIncludingGST":385,"chargeCharacteristics":{"serviceInstanceId":"a4e2O0000003PBJQA5","chargeInstanceId":"2c110lp9-0dd0-127d-b6a8-6babx42b0244","isRedeemable":false,"orderReference":"ORD-127"}}]}]}';
        String errorResponse = '{"errorKey":"once.off.data.not.found","errorMessage":"Once off data not found"}';
        
        if(resType.contains('success_Search')){
            res.setBody(successResponse);
            res.setStatusCode(200);
        }
        else if(resType.equalsIgnoreCase('success_Error')){
            res.setBody(errorResponse);
            res.setStatusCode(400);
        }
        else{
            res.setBody('');
            res.setStatusCode(503);
        }
       
        return res;
    }
}