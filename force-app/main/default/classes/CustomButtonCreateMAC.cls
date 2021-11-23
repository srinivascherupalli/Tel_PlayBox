/*************************************************************************************************
Name : CustomButtonCreateMAC
Description : Used to display all the subscription on the account and 
allow the User to select one of many subscriptions to be added to the basket to be modified.
***************************************************************************************************/
global with sharing class CustomButtonCreateMAC extends csbb.CustomButtonExt {
    
    public String performAction(String basketID, String pcrIds) {
        string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        if(basketID != null){
            String url = prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_MAC_URL+basketID;
            URL currentURL = New URL(prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_MAC_URL+basketID);
            Set<String> whiteListedDomains = new Set<String>();
            whiteListedDomains.add(currentURL.getHost());
            whiteListedDomains.add('www.salesforce.com');
            whiteLIstedDomains.add('www.google.com');
            if( url == NULL || !whiteListedDomains.contains(New URL(url).getHost())){
                url = '/home/home.jsp';
             }
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);

            return '{"status":"ok","text":"", "displayInDialog": true,"size": "l","modalTitle": "Existing Subscriptions", "redirectURL":"/apex/c__MACPage?basketID='+ basketID +'"}';  
        }
        
        
           return null;                       
    }
    
}