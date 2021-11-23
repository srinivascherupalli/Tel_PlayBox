@isTest
public class Orchestration_MockBillingOrderResponse implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public Orchestration_MockBillingOrderResponse(Integer code, String status, String body, Map<String, String> responseHeaders) {
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
        } else if(body.equalsIgnoreCase('404Response')){
            res.setBody('{"code": "404","message": "No BAN Available","errors": [{"code":"404","field":"ban","message":"no BAN available"}]}');
        } else {

            res.setBody('');
        }
         
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}