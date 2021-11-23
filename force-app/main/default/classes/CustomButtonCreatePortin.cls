/*************************************************************************************************
Name : CustomButtonCreatePortin
Description : Used to check port in numbers for MAC 
Author: Kalashree Borgaonkar
Story: EDGE-80749
***************************************************************************************************/
global with sharing class CustomButtonCreatePortin extends csbb.CustomButtonExt {

/*-------------------------------------------------------- 
EDGE-80749
Method: performAction 
Description: invoke Lightning Component 
Author: Kalashree Borgaonkar
--------------------------------------------------------*/
    public String performAction(String basketID, String pcrIds) {
        string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('ProdUtilURL ------->'+prodUtilURL);
        String returnStr = null;
        if(basketID != null){
            String url = prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_Portin_URL+basketID;
            URL currentURL = New URL(prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_Portin_URL+basketID);
            System.debug('currentURL '+currentURL);
            Set<String> whiteListedDomains = new Set<String>();
            whiteListedDomains.add(currentURL.getHost());
            whiteListedDomains.add('www.salesforce.com');
            whiteLIstedDomains.add('www.google.com');
            if( url == NULL || !whiteListedDomains.contains(New URL(url).getHost())){
                url = '/home/home.jsp';
             }
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            returnStr = '{"status":"ok","text":"", "displayInDialog": true,"size": "l","modalTitle": "Port In Qualification", "redirectURL":"/apex/c__PortInPage?basketID='+ basketID +'"}';  
        }
           return returnStr;                       
    }  
}