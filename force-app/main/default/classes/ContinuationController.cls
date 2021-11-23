/*
* Modified Date: 15/2/2021
* Description : Added vf page end url format in label (Remove '--c.'+Org.InstanceName+'.visual.force.com' and added it into VisualforcePageEndURL label)
* Modified by : Team Hawaii
*/
global without sharing class ContinuationController {
    global ContinuationController() {
        /*
        String hostname = URL.getSalesforceBaseUrl().getHost();
        system.debug(hostname);
        String mydomain;
        if (hostname.indexOf('--c') > -1) {
            mydomain = hostname.substring(0, hostname.indexOf('--c.'));
            //system.debug('***** inside --c'+hostname.substring(0, hostname.indexOf('--c.cs')));
        } 
        else if(hostname.indexOf('.cs') > -1){
            mydomain = hostname.substring(0, hostname.indexOf('.cs'));
            system.debug('***** inside .cs'+mydomain);
        }
        else if(hostname.indexOf('.my') > -1){
            mydomain = hostname.substring(0, hostname.indexOf('.my'));
             system.debug('***** inside .my'+mydomain);
        } 
        system.debug('***** mydomain'+mydomain);
        String lcBaseURL;
        if(network.getNetworkId() == null)
            lcBaseURL = 'https://' + mydomain + '.lightning.force.com';
        else
            lcBaseURL= getVFBaseURL();
       
        system.debug(lcBaseURL);
        Map<String, String> headers = Apexpages.currentPage().getHeaders();
        headers.put('X-Frame-Options', 'ALLOW-FROM ' + lcBaseURL);
        headers.put('Content-Security-Policy', 'frame-ancestors ' + lcBaseURL);
        headers.put('Content-Security-Policy', 'frame-ancestors ' + lcBaseURL);
       */
    }
    @AuraEnabled
    global static String getVFBaseURL() {
        network n=new network();       
            Organization Org=[SELECT IsSandbox,InstanceName FROM Organization LIMIT 1];
            String finalURL=null;

        if(network.getNetworkId() == null){
            system.debug('host ===>'+URL.getSalesforceBaseUrl().getHost());
            //String sfUrl= 'https://'+URL.getSalesforceBaseUrl().getHost();            
            //List<string> lstfragments = sfUrl.split('\\.');
            List<string> lstfragments = ('https://'+URL.getSalesforceBaseUrl().getHost()).split('\\.');
                     
            //remove '--c.'+Org.InstanceName+'.visual.force.com' and added it into VisualforcePageEndURL label
            finalURL=lstfragments[0]+system.label.VisualforcePageEndURL;     
           
            
            //return finalURL;
        }else{
            /*string sFinalURL='';
            system.debug('network getSelfRegUrl'+network.getSelfRegUrl(network.getNetworkId()));
            if(Org.IsSandbox)
                 sFinalURL= network.getSelfRegUrl(network.getNetworkId()).replace('/partners/s/login/SelfRegister','');
            else
                sFinalURL = network.getSelfRegUrl(network.getNetworkId()).replace('/s/login/SelfRegister','');
            */
            finalURL =  network.getSelfRegUrl(network.getNetworkId()).replace('/partners/s/login/SelfRegister','').replace('/s/login/SelfRegister','');

            //return sFinalURL;
        }
        system.debug('finalURL ===>'+finalURL);
        return finalURL;
    }
    
    
    
    public class WrapperState {
        public String request;
        public Object pageParams;
        public String requestBody;
        public String requestCid;
        public DateTime requestTime; //EDGE-127154 - CLF Changes

    }
    // Called via JavaScript Remoting
    @RemoteAction
    global static Object invoke(String methodName, String params) {
        Object response=null;
        string str = null; //'PimsMicroserviceManageOrg'
        if (methodName == 'callPIMS') {           
            response=ManagePIMSController.invoke(params,str);
           
        }
        return response;
    }
    global static Object callbackPIMS(Object state) {
        WrapperState state2 = (WrapperState)state;
        HttpResponse response = Continuation.getResponse(state2.request);
        System.debug('state2:' + state2);
        System.debug('response:' + response);
        Object msResponse = ManagePIMSController.parsePIMSResponse(response, state2);
            
        //Commented Girish testing!
        //String msResponse = ManagePIMSController.parsePIMSResponse(response, state2);
        return msResponse;
    }

}