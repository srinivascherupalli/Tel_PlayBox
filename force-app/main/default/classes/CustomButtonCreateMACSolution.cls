/*************************************************************************************************
Name : CustomButtonCreateMACSolution 
Description : Used to display all the solution on the account and 
allow the User to select one of many solutions to be added to the basket to be modified.
***************************************************************************************************/
global with sharing class CustomButtonCreateMACSolution extends csbb.CustomButtonExt {
    
    public String performAction(String basketID, String pcrIds) {


        string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();

        System.debug('CustomButtonCreateMACSolution basketID: '+ basketID);
        System.debug('CustomButtonCreateMACSolution pcrIds: '+ pcrIds);

        //List<String> prodConfigRequestIds = (List<String>) System.JSON.deserialize(pcrIds, List<String>.class);
        
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

            if(Site.getSiteId() == null) {
                // Standard
                return '{"status":"ok","text":"", "displayInDialog": true,"size": "l","modalTitle": "Existing Solutions", "redirectURL":"/apex/c__MACSolutionsPage?basketID=' + basketID + '"}';
            } else {
                // Community
                String redirectURI = '/partners/s/sfdcpage/%2Fapex%2Fc__MACSolutionsPage%3FbasketId%3D';
                return '{"status":"ok", "title":"Nothing selected", "redirectURL": "' + redirectURI + basketId + '" }';
            }
        }
           return null;

    }
    
}