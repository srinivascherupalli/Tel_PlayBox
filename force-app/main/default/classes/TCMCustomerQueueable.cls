public class TCMCustomerQueueable implements Queueable,Database.AllowsCallouts {
    public static final String EVENT_ACTION_CREATE = 'Create';
    public static final String EVENT_ACTION_UPDATE = 'Update';
    public static final String EVENT_ACTION_CROSSREF = 'CrossRef';
    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');
    String identifier;
    String req;
    String  event;
    public TCMCustomerQueueable(String req, String event, String identifier) {
        this.req = req;
        this.event = event;
        this.identifier = identifier;
    }
    
    public void execute(QueueableContext qc) {
        Logger log = Logger.getLogger('ManageCustomerRequest'); 
        IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
        String token = '';
        if(is.EnableMocks__c != true){
          token = TCMSearchManager.getTCMToken();
        }
        
        // Prepare Request
        HttpRequest request = new HttpRequest();
        
        if(is.EnableMocks__c == true){
            request.setEndpoint(EnvironmentVariable.get('MockEndpoint'));    
        }
        else {
            String ep = EnvironmentVariable.get('tcm_customerEndpoint');
            if(event != EVENT_ACTION_CREATE && identifier != null && identifier != '') {
                ep = ep + '/'+identifier;
            }
            request.setEndpoint(ep);
        }
        
        if(event == EVENT_ACTION_CREATE){
          request.setMethod('POST');    
        } else {
            request.setMethod('PUT');
        }
          //Set Certificate
        if(Certificate_name != null){
          request.setClientCertificateName(Certificate_name);
        }
        request.setBody(req);
        request.setTimeout(30000);
        
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        
        System.debug('!@#$% Request : ' + request);
        System.debug('!@#$% ManageCustomerRequest Body : ' + request.getBody());
        
        // Send Request
        Http httpClient = new Http();
        HttpResponse resp;
        try{
            resp = httpClient.send(request);
            log.logRequest(request.getBody(), true);
            log.logResponse(resp.getBody(), true);
            System.debug('!@#$% ManageCustomer Response : ' + resp);
        }
        catch(Exception e){
            System.debug(e);
            log.debug(e);
            Logger.exitLogger(); 
        }	
    }

}