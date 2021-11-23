/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test Class to mock HTTP callout
 * Revision :
 * 
 * *****************************************************************************/
@istest
global class ReplicatorResponseMockV2 implements HttpCalloutMock {
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test method to mock callout
 * Parameter : HttpRequest
 * 
 * *****************************************************************************/
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        String endPoint = req.getEndpoint();
        String reqBody = req.getBody();
        String reqHeader = req.getHeader('cidn');
        
       	if(reqHeader.contains('404')) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_404_CODE);
            	}
            if(reqHeader.contains('500')) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_500_CODE);
            }
              else if(reqHeader.contains('503')) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_503_CODE);
            }
            else if(endPoint.contains('errorId')) {
            	res.setBody(getCustomerSites_Error());
            }
             else{
                res.setBody(getCustomerSites_withSuccess());   
                res.setStatusCode(200);
             }
          
     
         return res;  
    }
             
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Method to set json as http body(Success Scenario)
 * Parameter : 
 * 
 * *****************************************************************************/
    private static String getCustomerSites_withSuccess() {
           String jsonString = '{'+
        '    \"cidn\": \"212\",'+
        '    \"correlationId\": \"123456\",'+
        '    \"addressList\": [{'+
        '        \"addressType\": \"111\",'+
        '        \"addressValue\": \"111\",'+
        '        \"replicatorUpdateDateTime\": \"22/05/1992\",'+
     
        '        \"addressCharacteristics\": [{'+
        '            \"name\": \"1245\",'+
        '            \"value\": \"1245\"'+
        '        }]'+
        '    }]'+
        '}';     
        return jsonString;
    }
         /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Method to set json as http body(Error Scenario)
 * Parameter : 
 * 
 * *****************************************************************************/
      private static String getCustomerSites_Error() {
        String jsonString = '{' + 
            ' \"CIDN\": \"212\", ' +
            ' \"Enterprise_Id\": \"553\", ' +
            ' \"Error_Code\": \"\", ' +
            ' \"Error_Description\": \"\" ' +
        '}';
        
        return jsonString;
    }
  
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-75180
 * Date : 4 April 2019
 * Description : Test method : getCustomerSites_withSuccess()
 * Parameter : 
 * 
 * *****************************************************************************/
    static testMethod void test() {
    	Test.startTest();
	  	String jsonString=getCustomerSites_withSuccess();
        Test.stopTest();
        system.assert(jsonString!=null);
    }
}