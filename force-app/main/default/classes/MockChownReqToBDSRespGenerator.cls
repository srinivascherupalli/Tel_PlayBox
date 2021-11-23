//DIGI-30045
global class MockChownReqToBDSRespGenerator implements HTTPCalloutMock{  
	global HttpResponse respond(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		String endPoint = req.getEndpoint();
		if(endPoint.contains('fetch-payout-details')) {
			res.setStatusCode(200);
		}      
		return res;
	}
}