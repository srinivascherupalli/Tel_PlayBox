public class DocusignClientRESTCall {
    private static  String USERNAME = '';
    private static  String PASSWORD = '';    
    private static  String INTEGRATOR_KEY = '';
    private static  String ACCOUNT_ID = '';
    private static  String BASE_URL = '';
    private static  String AUTH_TEMPLATE = '';
    private static  String STATUS_VOID = 'voided';
    
    
    public HttpResponse voidEnvelope(String envelopeId, String voidReason, DocuSign_REST_API__mdt docuSignDetails){
        USERNAME = docuSignDetails.USERNAME__c;
        PASSWORD = docuSignDetails.PASSWORD__c;
        INTEGRATOR_KEY = docuSignDetails.INTEGRATOR_KEY__c;
        ACCOUNT_ID = docuSignDetails.ACCOUNT_ID__c;
        BASE_URL = docuSignDetails.BASE_URL__c;
        AUTH_TEMPLATE = '<DocuSignCredentials><Username>'+USERNAME+'</Username><Password>'+PASSWORD+'</Password><IntegratorKey>'+INTEGRATOR_KEY+'</IntegratorKey></DocuSignCredentials>';
        
        //   String endpoint = String.format('{0}/accounts/{1}/envelopes/{2}', new String[]{BASE_URL, ACCOUNT_ID, envelopeId});
        String endpoint = BASE_URL+'accounts/'+ACCOUNT_ID+'/envelopes/'+envelopeId;
        system.debug('*****endpoint-->'+endpoint);
        DocusignStatusRequest statusUpdate = new DocusignStatusRequest();
        statusUpdate.status = STATUS_VOID;
        statusUpdate.voidedReason = voidReason;
        
        string jsonBody = '{'+
            '"status":"voided",'+
            ' "voidedReason": "The reason for voiding the envelope "'+ 
            '}';
        
        // initialize the api client for the desired environment
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('PUT');
        request.setHeader('Accept','application/json'); 
        request.setHeader('Content-Type','application/json'); 
        request.setHeader('X-DocuSign-Authentication', String.format(AUTH_TEMPLATE, new String[]{USERNAME,PASSWORD,INTEGRATOR_KEY}));
        // request.setHeader('X-DocuSign-Authentication',jsonString);
        request.setBody(JSON.serialize(statusUpdate));
        // request.setBody(jsonBody);
        system.debug('********jsonBody-->'+jsonBody);
        system.debug('********request-->'+request);
        system.debug('********statusUpdate-->'+statusUpdate);
        system.debug('********statusUpdateJson-->'+JSON.serialize(statusUpdate));
        //system.debug('********Response-->'+h.send(request));
        // return h.send(request);
        return h.send(request);
    }
    
    public class DocusignStatusRequest{
        public String status {get; set;}
        public String voidedReason {get; set;}
    }
}