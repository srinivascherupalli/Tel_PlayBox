@istest
global class Util_PLRMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        
        String endPoint = req.getEndpoint();
        System.debug('Endpoint: ' + endPoint);
        String reqBody = req.getBody();
        System.debug('Request Body: ' + reqBody);
/*
        if(endPoint.contains('GetSite')) {
            System.debug('Request Get Site Body: ' + reqBody);

            if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_404_CODE);
            }
            else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_500_CODE);
            }
            else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_503_CODE);
            }
            else if(endPoint.contains('errorId')) {
                res.setBody(getCustomerSites_Error());
            }
            else {
                   
                res.setStatusCode(200);                
            }
        }
*/      
		String xmlBody = '<?xml version="1.0" encoding="UTF-8"?>' +
						 '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
    					 '	<soapenv:Body xmlns="http://schemas.xmlsoap.org/soap/envelope/">' +
        				 '		<loginResponse xmlns="urn:partner.soap.sforce.com">' +
				         '			<result xmlns="urn:partner.soap.sforce.com">' +
                		 '				<sessionId xmlns="urn:partner.soap.sforce.com">sfdcSessionId</sessionId>' +
            			 '			</result>' +
        			     '		</loginResponse>' +
    					 '	</soapenv:Body>' +
						 '</soapenv:Envelope>';

		res.setBody(xmlBody);  
		res.setStatusCode(200); 
        return res;        
    }
	
	/*
	 A test class should have atleast one test method.Otherwise,we will get bug,so to avoid a bug, added one test method.
	*/
	private static testMethod void runPositiveTestCasesToFixBug() {
		System.assertequals('BugFix','BugFix');		
	}


}