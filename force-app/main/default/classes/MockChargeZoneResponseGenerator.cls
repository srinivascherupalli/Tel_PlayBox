/***********************************************************************************************************
Name          : MockChargeZoneResponseGenerator
Created By    : Aman Soni
Created Date  : Dec 04 2019
Description   : This is a Mock class to simulate the callouts of ChargeZoneController
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Aman            04-12-2019      Created
1.2 `       Ajith Kumar     13-10-2021      Modified
1.3         Ajith Kumar     26-10-2021      Modified
**********************************************************************************************************/
/*
Story Number: DIGI-15723 
Created By: Aman Soni
Modified By: Ajith Kumar
Description: Created mock response and method to throw exception
@Param: 
*/
@isTest(SeeAllData=FALSE)
global class MockChargeZoneResponseGenerator implements HttpCalloutMock{
 
        protected Integer r_code;
        protected String testCheck;
        protected String r_status;
        protected String r_bodyAsString;
        protected Blob r_bodyAsBlob;
        protected Map<String, String> r_responseHeaders;
    	//DIGI-15723 created Mock response for charge zone api
        //DIGI-33904 Added Product list in the mock response
        String mockBody_Success = '{"esaId":1,"czpId":1,"contractStartDate":"2019-11-08","lastVerificationDate":"2021-10-20","zone":{"rental":"zone 1","sla":"URBAN","mdn":"URBAN","products":[{"availability":"Available", "name":"BIP Adapt"},{"availability":"Available","name":"TID Adapt"}]},"maintenance":[{"vendor":"Cisco Smartnet","availability":"24X7X2"},{"vendor":"Cisco Telstra Onsite","availability":"24X7X4"},{"vendor":"Juniper","availability":"24X7X4"},{"vendor":"Riverbed","availability":"24X7X4"}]}';        
		String nullZone_Success ='{"esaId":1,"czpId":1,"contractStartDate":"2019-11-08","lastVerificationDate":"2021-10-20","zone":null,"maintenance":[{"vendor":"Cisco Smartnet","availability":"24X7X2"},{"vendor":"Cisco Telstra Onsite","availability":"24X7X4"},{"vendor":"Juniper","availability":"24X7X4"},{"vendor":"Riverbed","availability":"24X7X4"}]}';
        String productEmpty_Success = '{"esaId":1,"czpId":1,"contractStartDate":"2019-11-08","zone":{"rental":"zone 2","sla":"URBAN","mdn":"URBAN","products":[]},"maintenance":[{"vendor":"Cisco Smartnet","availability":"24X7X2"},{"vendor":"Cisco Telstra Onsite","availability":"24X7X4"},{"vendor":"Juniper","availability":"24X7X4"},{"vendor":"Riverbed","availability":"24X7X4"}]}';        
        string rentalInvalid_Success = '{"zone":{"sla":"Urban","rental":"1","products":[{"name":"TID Adapt","availability":"Available"}],"mdn":"Rural"},"maintenance":[{"vendor":"Cisco Smartnet","availability":"24X7X2"}],"lastVerificationDate":"2021-10-28T09:49:17.601Z","esaId":9999,"czpId":1,"contractStartDate":"2021-10-28"}';
        string product_NotAvailable = '{"zone":{"sla":"Rural","rental":"ZONE 1","products":[{"name":"BIP Adapt","availability":"Not Available"},{"name":"DC Rate Card","availability":"Available"},{"name":"TID Adapt","availability":"Available"},{"name":"TID Lite Adapt","availability":"Available"}],"mdn":"Rural"},"maintenance":[{"vendor":"Cisco Smartnet","availability":"8X5X4"},{"vendor":"Cisco Telstra Onsite","availability":"8X5X4"},{"vendor":"Juniper","availability":"24X5XNBD"},{"vendor":"Riverbed","availability":"8X5XNBD"}],"lastVerificationDate":"2021-10-27T12:48:39.121Z","esaId":46,"czpId":1,"contractStartDate":"2021-10-27"}';
        string zoneProduct_Available = '{"zone":{"sla":"Rural","rental":"ZONE 2","products":[{"name":"BIP Adapt","availability":"Available"},{"name":"DC Rate Card","availability":"Not Available"},{"name":"TID Adapt","availability":"Available"},{"name":"TID Lite Adapt","availability":"Available"}],"mdn":"Rural"},"maintenance":[{"vendor":"Cisco Smartnet","availability":"8X5X4"},{"vendor":"Cisco Telstra Onsite","availability":"8X5X4"},{"vendor":"Juniper","availability":"24X5XNBD"},{"vendor":"Riverbed","availability":"8X5XNBD"}],"lastVerificationDate":null,"esaId":3,"czpId":1,"contractStartDate":"2021-01-01"}';
        string zoneSLA_Product ='{"zone":{"sla":"Rural","rental":"ZONE 3","products":[{"name":"SLA","availability":"Available"},{"name":"DC Rate Card","availability":"Not Available"},{"name":"TID Adapt","availability":"Available"},{"name":"TID Lite Adapt","availability":"Available"}],"mdn":"Rural"},"maintenance":[{"vendor":"Cisco Smartnet","availability":"8X5X4"},{"vendor":"Cisco Telstra Onsite","availability":"8X5X4"},{"vendor":"Juniper","availability":"24X5XNBD"},{"vendor":"Riverbed","availability":"8X5XNBD"}],"lastVerificationDate":"2021-10-20T18:11:36.627Z","esaId":4565,"czpId":1,"contractStartDate":"2021-10-21"}';
    	string zoneDC_Rate_Card ='{"zone":{"sla":"Not available","rental":"DC Rate Card","products":[{"name":"DC Rate Card","availability":"Available"}],"mdn":"Not available"},"maintenance":[{"vendor":"Cisco Smartnet","availability":"NOT AVAILABLE"},{"vendor":"Cisco Telstra Onsite","availability":"NOT AVAILABLE"},{"vendor":"Juniper","availability":"NOT AVAILABLE"},{"vendor":"Riverbed","availability":"NOT AVAILABLE"}],"lastVerificationDate":"2021-11-02T05:59:00.952Z","esaId":5078,"czpId":1,"contractStartDate":"2021-11-02"}';
    	String mockException_Error =null;

        public MockChargeZoneResponseGenerator (){
        }
        //DIGI-15723 changed Parameter type to string
        public MockChargeZoneResponseGenerator (String testCheck) {
            this.testCheck = testCheck;
        }

        public MockChargeZoneResponseGenerator (Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
            this.r_code = code;
            this.r_status = status;
            this.r_bodyAsString = body;
            this.r_bodyAsBlob = null;
            this.r_responseHeaders = responseHeaders;
        }
 
 
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(testCheck.contains('mockBody')){
           return getCalloutResponse();
        }
        else if(testCheck.contains('errorZone')){
            return getExceptionError(500);
        }
        else if(r_code == IntegrationRecordHandlerUtil.ERROR_500_CODE || r_code == IntegrationRecordHandlerUtil.ERROR_404_CODE || r_code == IntegrationRecordHandlerUtil.ERROR_503_CODE){
            return getDefaultResponse(r_code);
        }
        else if(testCheck.contains('product')){
            res.setBody(productEmpty_Success);
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
        else if(testCheck.contains('rentalInvalid')){
            return getInvalidRental();
        }
        else if(testCheck.contains('NotAvailable')){
            return getProductNotAvailable();
        }
        else if(testCheck.contains('zoneProducts')){
            return getProductAvailable();
        }
        else if(testCheck.contains('zoneSLA')){
            return getSLAProducts();
        }
        else if(testCheck.contains('zoneDC')){
            return getDCRateCard();
        }
        return getDefaultResponse(200);
    }

    private HttpResponse getCalloutResponse(){
        HttpResponse res = getDefaultResponse(200);
        //DIGI-33904 Added Product list in the mock response
        res.setBody('{"esaId":1,"czpId":1,"contractStartDate":"2019-11-08","lastVerificationDate":"2021-10-20","zone":{"rental":"zone 1","sla":"URBAN","mdn":"URBAN","products":[{"availability":"Available", "name":"BIP Adapt"},{"availability":"Available","name":"TID Adapt"}]},"maintenance":[{"vendor":"Cisco Smartnet","availability":"24X7X2"},{"vendor":"Cisco Telstra Onsite","availability":"24X7X4"},{"vendor":"Juniper","availability":"24X7X4"},{"vendor":"Riverbed","availability":"24X7X4"}]}');
        return res;
    }
    
    private HttpResponse getDefaultResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setBody(mockBody_Success);
        res.setStatusCode(StatusCode);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    //DIGI-15723 Method to return null zone response
    private HttpResponse getNullResponse(Integer statusCode){
        HttpResponse res = new HttpResponse();
        res.setBody(nullZone_Success);
        res.setStatusCode(StatusCode);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    //DIGI-15723 Method to throw exception
    private HttpResponse getExceptionError(Integer statusCode){
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Test exception from test class');
        throw e;
    }
    //DIGI-33904 Method to check Empty Product
    private HttpResponse getEmptyProductResponse(){
        HttpResponse res = new HttpResponse();
        res.setBody(productEmpty_Success);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    //DIGI-33904 Method to check Invalid Rental
    private HttpResponse getInvalidRental(){
        HttpResponse res = new HttpResponse();
        res.setBody(rentalInvalid_Success);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    //DIGI-33904 Method to check Product Not Available
    private HttpResponse getProductNotAvailable(){
        HttpResponse res = new HttpResponse();
        res.setBody(product_NotAvailable);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    //DIGI-33904 Method to check Product  Available
    private HttpResponse getProductAvailable(){
        HttpResponse res = new HttpResponse();
        res.setBody(zoneProduct_Available);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    //DIGI-33904 Method to check Product  Available
    private HttpResponse getSLAProducts(){
        HttpResponse res = new HttpResponse();
        res.setBody(zoneSLA_Product);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    //DIGI-33904 Method to DC Rate Card Available
    private HttpResponse getDCRateCard(){
        HttpResponse res = new HttpResponse();
        res.setBody(zoneDC_Rate_Card);
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
}