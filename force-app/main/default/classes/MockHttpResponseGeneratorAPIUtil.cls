@isTest
global class MockHttpResponseGeneratorAPIUtil implements HttpCalloutMock
    {
        global HTTPResponse respond(HTTPRequest req) 
        {   
            //string json = '';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if(req.getHeader('access_token')==''){
                res.setBody('{"access_token":"lI0peD5B1zfJ6BSQmbJdmp4qRJ8s"}');
                res.setstatuscode(200);
            }
            else{
                res.setBody('{"message":"testmessage"}');
              res.setstatuscode(200);
            }
                       
            return res;
        }
}