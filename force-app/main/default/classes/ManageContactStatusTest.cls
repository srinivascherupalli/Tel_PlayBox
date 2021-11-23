@isTest
public class ManageContactStatusTest {
    
  /*@testSetup static void setup() {
        
    }*/
    
    static testMethod void testDoPostPositiveWithValidContact() {
        
        final Contact c = TestUtil.createContact('Joey', 'Bloggs');
        insert c;
        
        final RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/ManageContactStatus';  
        req.httpMethod = 'POST';
        final String reqBody = '{"request":{"data":{"fault":{"faultcode":"FLT-349","faultString":"Fault occurred","faultActor":"CCB-EAI","serverName":"ccbeai01","processId":"g3h2k1nbu4-j23n4h23i-j2hy2n43jk-k12h87d","threadId":"003267291729276","programName":"Manage Contact","programLocation":"CCB-EAI","timestamp":"2016-07-20 11:31 AM","initiatingEntityId":"34212","programStatusCode":"784596","programStatusDescription":"Invalid","ProgramFaultId":"2345","ProgramFaultDescription":"Validation Failed on Field : Market Segment","faultCategory":"Validation-Minor","entityName":"Contact","entityValue":"{{Contact ID}}"}}}}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
       
        final ManageContactStatusRequest mcsr = new ManageContactStatusRequest();
        mcsr.data = new ManageContactStatusRequest.Data();
        mcsr.data.fault = new ManageContactStatusRequest.Fault();
        mcsr.data.fault.entityValue = c.Id;
       
        ManageContactStatusResponse mcr = ManageContactStatus.doPost(mcsr);
        System.assertEquals('Success',mcr.Status);
    }
    
    static testMethod void testDoPostPositiveWithInvalidContact() {
        
        final Contact c = TestUtil.createContact('Joey', 'Bloggs');
        insert c;
        
        final RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/ManageContactStatus';  
        req.httpMethod = 'POST';
        final String reqBody = '{"request":{"data":{"fault":{"faultcode":"FLT-349","faultString":"Fault occurred","faultActor":"CCB-EAI","serverName":"ccbeai01","processId":"g3h2k1nbu4-j23n4h23i-j2hy2n43jk-k12h87d","threadId":"003267291729276","programName":"Manage Contact","programLocation":"CCB-EAI","timestamp":"2016-07-20 11:31 AM","initiatingEntityId":"34212","programStatusCode":"784596","programStatusDescription":"Invalid","ProgramFaultId":"2345","ProgramFaultDescription":"Validation Failed on Field : Market Segment","faultCategory":"Validation-Minor","entityName":"Contact","entityValue":"{{Contact ID}}"}}}}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
       
        final ManageContactStatusRequest mcsr = new ManageContactStatusRequest();
        mcsr.data = new ManageContactStatusRequest.Data();
        mcsr.data.fault = new ManageContactStatusRequest.Fault();
        mcsr.data.fault.entityValue = '12345';
       
        final ManageContactStatusResponse mcr  = ManageContactStatus.doPost(mcsr);
        System.assertEquals('Success',mcr.Status);
        
    }
    
    static testMethod void testDoPostNegative() {
        
        final Contact c = TestUtil.createContact('Joey', 'Bloggs');
        insert c;
        
        final RestRequest req = new RestRequest(); 
        req.requestURI = System.Url.getSalesforceBaseUrl()+'/services/apexrest/ManageContactStatus';  
        req.httpMethod = 'POST';
        final String reqBody = '{"request":{"data":{"fault":{"faultcode":"FLT-349","faultString":"Fault occurred","faultActor":"CCB-EAI","serverName":"ccbeai01","processId":"g3h2k1nbu4-j23n4h23i-j2hy2n43jk-k12h87d","threadId":"003267291729276","programName":"Manage Contact","programLocation":"CCB-EAI","timestamp":"2016-07-20 11:31 AM","initiatingEntityId":"34212","programStatusCode":"784596","programStatusDescription":"Invalid","ProgramFaultId":"2345","ProgramFaultDescription":"Validation Failed on Field : Market Segment","faultCategory":"Validation-Minor","entityName":"Contact","entityValue":"{{Contact ID}}"}}}}';
        req.requestBody = System.Blob.valueOf(reqBody);
        RestContext.request = req;
        
        final RestResponse res = new RestResponse();
        RestContext.response = res;
       
        final ManageContactStatusRequest mcsr = null;
       
        final ManageContactStatusResponse mcr = ManageContactStatus.doPost(mcsr);
        System.assertEquals('Success',mcr.Status); 
    }   
}