public class RunTerritoryRules implements Queueable, Database.AllowsCallouts  {
    public Set<String> accntIds = null;
    public String sessionId = null;   
    public static String responseVal=null;
  
    public void execute(QueueableContext context) {
     if(!Test.isRunningTest()){   
	  sessionId = Page.TMGetSessionId.getContent().toString();    
     }
        List<String> lstAccString = new List<String>();
        if(accntIds != null){
            for(String accId:accntIds){
                lstAccString.add(accountTag.replace('{ACCID}', accId)); 
            }
        } 
        requestTemplate = requestTemplate.replace('{ACCLISTS}', String.join(lstAccString, ' ')) ;
      if(!Test.isRunningTest()){ 
        requestTemplate = requestTemplate.replace('{SESSID}', sessionId) ;
      }
        HttpRequest request = new HttpRequest();
	request.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+
			    '/services/Soap/u/41.0/'+UserInfo.getOrganizationId());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
	request.setHeader('SOAPAction', '""');
        request.setBody(requestTemplate);       
 	String s = String.valueOf(new Http().send(request).getBody());
        responseVal=s;
        System.debug('******Received Response val'+responseVal);
    }
    String accountTag = '<urn:sObjects> '+
                        	'<urn1:type>Account</urn1:type>  '+
        			'<urn1:Id>{ACCID}</urn1:Id>   '+
                    	'</urn:sObjects> ' ;    
    String requestTemplate = '<soapenv:Envelope '+
				'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+
				' xmlns:urn="urn:partner.soap.sforce.com"'+
				' xmlns:urn1="urn:sobject.partner.soap.sforce.com">'+
                                '<soapenv:Header> '+
                                  '<urn:AssignmentRuleHeader> '+ 
                                     '<urn:useDefaultRule>true</urn:useDefaultRule> '+
                                     '<urn:assignmentRuleId></urn:assignmentRuleId> '+
                                  '</urn:AssignmentRuleHeader>  '+
                                  '<urn:SessionHeader> '+
        				'<urn:sessionId>{SESSID}</urn:sessionId> '+
                                  '</urn:SessionHeader> '+
                               '</soapenv:Header> '+
                               '<soapenv:Body> '+
        			  '<urn:update> '+
        			   ' {ACCLISTS}'+ 
                                  '</urn:update> '+
                               '</soapenv:Body> '+
                            '</soapenv:Envelope>';

}