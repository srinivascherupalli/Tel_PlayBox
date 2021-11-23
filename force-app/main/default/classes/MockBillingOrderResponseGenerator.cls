@isTest
public class MockBillingOrderResponseGenerator implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockBillingOrderResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
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
        if(body.equalsIgnoreCase('retrieveFullSuccessResponse')){
          res.setBody('{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","code":200,"status":200 ,"billingAccount": {"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678","billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS","paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", "companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", "state": "NSW", "country": "Australia" }}}');
         }
        else if(endPoint.contains('/billing-accounts') && code == 200 || code == 201) {
            res.setBody('{"billingAccountNumber" : "123456789321"}');
        } 
        else if(endPoint.contains('/billing-accounts') && code == 400){
            res.setBody('{"code": "400","message": "No BAN Available","errors": [{"code":"1000","field":"ban","message":"no BAN available"}]}');
        }
        else if(endPoint.contains('v2.0/billing-accounts') && code == 200 || code == 201){
            res.setBody('{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917", "billingAccount": {"billingAccountNumber": "123456789321","billCommMethod": "email","customerAccountNumber": "2000345678","billToEmailAddress":"abc@gmail.com","startDate": "2017-09-29T05:00:16.000Z","billCycleDay": "1","paymentMethod": "NETS","paymentTerms": "14","billingAccountOwner": {"title": "Mr", "firstName": "Joe", "lastName": "Bloggs", "companyName": "Company Ltd."}, "billingAddress": {"address": "Unit 1 1234 Lostmy Way", "locality": "Sydney", "postcode": "2000", "state": "NSW", "country": "Australia" }}}');
        }
        else if(endPoint.contains('v2.0/billing-accounts') && code == 400)
        {
            res.setBody('{"code": "422","message": "Validation failed","errors": [{"code":"1000","field":"billingAccountNumber","message":"billingAccountNumber is a mandatory field"}]}'); 
        }
        else if(endPoint.contains('v2.0/billing-accounts') && code == 202){
            res.setBody('{"code": 202, "status": 202, "message": "Success", "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917ON123456", "eventId": "123fbcbb9-a4e5-4c4c-b72f-0be6b9421233"}');
        }
        else if(endPoint.contains('v2.0/billing-accounts') && code == 400){
            res.setBody('{"code": 422, "status": 422, "message": "Validation failed", "errors": [{"code": 1002, "field":"billingAccountNumber", "message":"billingAccountNumber is a mandatory field"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}');
        }
        else if(endPoint.contains('v2.0/billing-accounts') && code == 202){
            res.setBody('{"code": 202, "status": 202, "message": "Success", "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917ON123456", "eventId": "123fbcbb9-a4e5-4c4c-b72f-0be6b9421233"}');
        }
        else if (endPoint.contains('token')) {
       	  res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');       
       }
         
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}