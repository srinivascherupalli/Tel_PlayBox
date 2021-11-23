//DIGI-25050
global class MockSyncReqToBDSRespGenerator implements HTTPCalloutMock{  
  global HttpResponse respond(HttpRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    String endPoint = req.getEndpoint();
	String json = '{'+
    '  \"code\": 200,'+
    '  \"status\": 200,'+
    '  \"message\": \"Success\",'+
    '  \"billingAccountNumber\": 700000000012,'+
    '  \"subscriptionId\": \"SN-000033817\",'+
    '  \"chargesDetails\": ['+
    '    {'+
    '      \"instanceId\": \"c846491d-d696-cc07-912a-6f76109be6fc\",'+
    '      \"durationUnit\": \"Months\",'+
    '      \"durationRemaining\": 15,'+
    '      \"chargeRemaining\": 300,'+
    '      \"units\": 1,'+
    '      \"taxTreatment\": \"TAX Exempt\",'+
    '      \"validTill\": \"10-SEP-2021\"'+
    '    },'+
    '    {'+
    '      \"instanceId\": \"c846491d-d696-cc07-912a-6f76109be6fd\",'+
    '      \"durationUnit\": \"Months\",'+
    '      \"durationRemaining\": 10,'+
    '      \"chargeRemaining\": 200,'+
    '      \"units\": 1,'+
    '      \"taxTreatment\": \"TAX Exempt\",'+
    '      \"validTill\": \"10-SEP-2021\"'+
    '    }'+
    '  ]'+
    '}';	
    if(endPoint.contains('fetch-payout-details')) {
      res.setStatusCode(200);
	  res.setBody(json);
    }      
    return res;
  }
}