/*******************************************************************************************************************
    Class Name : flushCacheCotroller 
====================================================================================================================
Sr.No.    Developer Name           Date            Story Description
1.        Shubhi V                05/07/2021        EDGE-224336
====================================================================================================================
********************************************************************************************************************/
public without sharing class flushCacheController {
    private ApexPages.StandardController stdController;
    public flushCacheController( ApexPages.StandardController stdController) {
        this.stdController = stdController;
	}
    public PageReference onload(){
        cssmgnt__SM_Options__c processingOptions =cssmgnt__SM_Options__c.getInstance(UserInfo.getUserId());
        HttpRequest req = new HttpRequest();
        req.setHeader('content-type', cssmgnt.Constants.HEROKU_CONTENT_TYPE);
        req.setHeader('Organization', UserInfo.getOrganizationId().substring(0, 15));
        req.setTimeout(30000);
        req.setMethod('POST');
        if(processingOptions!=null)
        	req.setEndpoint(processingOptions.cssmgnt__endpoint__c + '/flushCache');
        Map<String, Object> requestMap = new Map<String, Object>();
        String body = JSON.serialize(requestMap);
        String payloadHash = cssmgnt.ConfiguratorHerokuServiceSecurity.calculateRsaPayloadHash(body,cssmgnt.Constants.HEROKU_CONTENT_TYPE);
        req.setBody(body);
        req.setHeader(
            'Authorization', cssmgnt.ConfiguratorHerokuServiceSecurity.generateRsaAuthorizationHeader(processingOptions.cssmgnt__certificate_name__c,
                UserInfo.getOrganizationId().substring(0, 15), cssmgnt.Constants.HTTP_POST, '/flushCache', payloadHash)
        );
        Http http = new Http();
        if(!Test.isRunningTest())
        {	HTTPResponse res = http.send(req);
        	System.debug('response-->'+ res.getBody());
        }
        String currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
		PageReference pdpage = new PageReference('/' +currentRecordId);
        pdpage.setRedirect(true);
        return pdpage;
     }
}