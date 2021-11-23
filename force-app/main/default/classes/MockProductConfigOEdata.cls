@isTest
global class MockProductConfigOEdata implements HttpCalloutMock{
    
    protected String resType;
    
    public MockProductConfigOEdata(String resType){
        this.resType = resType;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        //String oeResponse='{"status":200,"code":200,"time":"2018-10-31T09:05:05.456+0000","correlationId":"64ad66a9-78da-431a-bd94-a528870c2c02","path":"/v2/logical-resources/reservations/msisdn","method":"POST","responseCode":"LRM-SUCCESS","data":{"requestedQuantity":"5","returnedQuantity":"5","resources":[{"resourceId":"61402022091","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022082","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022093","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022123","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022456","resourceType":"MSISDN","resourceState":"AVAILABLE"}]}}'; 
       String oeResponse='{a3T2N0000004mHfUAI=(Component:[changeType=null, configurations=(Configuration:[addonErrorMessages=null,attributes=(Attribute:[displayValue=a4f2O00000015H8QAI, name=SolutionId, other=, showInUI=false, value=a4f2O00000015H8QAI],Attribute:[displayValue=Sree 20.03 PDUA, name=Operational User, other=, showInUI=true, value=0052O000000vO0OQAU])])])};'; 
        
        HttpResponse res = new HttpResponse();
            res.setBody(oeResponse);
            res.setStatusCode(200);
        
       
        return res;
    }
}