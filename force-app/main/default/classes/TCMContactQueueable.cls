public class TCMContactQueueable  {
/*
    public static final String EVENT_ACTION_CREATE = 'Create';
    public static final String EVENT_ACTION_UPDATE = 'Update';
    public static final String EVENT_ACTION_CROSSREF = 'CrossRef';
    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');
    
    public String req;
    public String event;
    public String identifier;
    public TCMContactQueueable(String req, String event, String identifier) {
        this.req = req;
        this.event =  event;
        this.identifier = identifier;
    }
    
    public void execute(QueueableContext qc) {
        Logger log = Logger.getLogger('ManageContactRequest');  
        Boolean callout = true;
      IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
        String token = '';
        if(is.EnableMocks__c != true){
          token = TCMSearchManager.getTCMContactToken();
            System.debug('++token=='+token);
        }
        
        // Prepare Request
        HttpRequest request = new HttpRequest();
        
        if(is.EnableMocks__c == true){
          request.setEndpoint(EnvironmentVariable.get('MockEndpoint'));    
        }
        else {
            String ep = EnvironmentVariable.get('tcm_contactEndpoint');
            System.debug('++ep='+ep);
            if(event != EVENT_ACTION_CREATE) {
                if(identifier != null && identifier != '') {
                  ep = ep + '/'+identifier;    
                }
                else {
                    callout = false;
                }
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
        
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        
        System.debug('!@#$% Request : ' + request);
        System.debug('!@#$% ManageContactRequest Body : ' + request.getBody());
        
        // Send Request
        if(callout){
            Http httpClient = new Http();
            HttpResponse resp;
            try{
                resp = httpClient.send(request);
                log.logRequest(request.getBody(), true);
                log.logResponse(resp.getBody(), true);
                System.debug('!@#$% ManageContact Response : ' + resp); 
            } catch(Exception e){
                System.debug(e);
                log.debug(e);
                Logger.exitLogger(); 
            }
        }
        
    }
*/
}