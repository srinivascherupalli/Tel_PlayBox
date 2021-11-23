@isTest
public class MockCalloutManagePIMS implements HttpCalloutMock {

    String Status='200';
 public MockCalloutManagePIMS(String Statuscode) {
     Status=Statuscode;
 }

 public MockCalloutManagePIMS() {
     Status='200';
 }

  public static testMethod void TestgetData()
    {
           Test.startTest();
            Account accdis = new Account(Name = 'Test Accountdit',Partner_Type__c='Distributor',Customer_Status__c='ACTIVE');
            insert accdis;
           System.assertEquals(accdis.Name, 'Test Accountdit');
        
         Test.stopTest(); 
    }
 
    public HTTPResponse respond(HTTPRequest req) {
        System.debug('HTTP Endpoint: '+ req.getEndpoint());
        System.debug('HTTP Method: '+ req.getMethod());
        System.debug('HTTP Request: '+ req.getBody());
      
        if(Status=='400')
           return getErrorResponse(200);
        else
           return getDefaultResponse(200);
    }    
    private HttpResponse getDefaultResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(StatusCode);
		res.setBody('{\n' +' "title" :"Success",\n' +' "status" : "200",\n' +' "pimsStatus" : "0",\n' +' "description" : "Success",\n' +' "userIdCreated" : "P12345"\n' +'}');
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    
     private HttpResponse getErrorResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(StatusCode);
		res.setBody('{\n' +' "title" :"Success",\n' +' "status" : "400",\n' +' "pimsStatus" : "0",\n' +' "description" : "Error",\n' +' "userIdCreated" : "P12345"\n' +'}');
        res.setHeader('Content-Type', 'application/json');
        return res;
    }


}