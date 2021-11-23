/*************************************************************************************************
Name : CustomButtonCreatePortin
Description : Used to check stock available for mobile device 
Author: Aishwarya Yeware
Story: EDGE-80858
***************************************************************************************************/
global with sharing class CustomButtonCheckInventory extends csbb.CustomButtonExt {

/*-------------------------------------------------------- 
EDGE-80858
Method: performAction 
Description: invoke Lightning Component 
Author: Aishwarya Yeware
--------------------------------------------------------*/
    public String performAction(String basketID, String pcrIds) {
        string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('ProdUtilURL ------->'+prodUtilURL);
        String returnStr = null;
        if(basketID != null){
            String url = prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_StockCheck_URL+basketID;
            URL currentURL = New URL(prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_StockCheck_URL+basketID);
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
                        //returnStr = '{"text":"", "displayInDialog": true,"size": "l","modalTitle": "Check Device Availability", "redirectURL":"/apex/c__StockCheckPage?basketID='+ basketID +'"}';  
			 //EDGE-125178. Kalashree Borgaonkar. Fix for Conditionally showing heading
            returnStr = '{"status":"ok","text":"", "displayInDialog": true,"size": "l","modalTitle": "Check Device Availability", "redirectURL":"/apex/c__StockCheckPage?isSC=false&basketID='+ basketID +'"}';  
        }
           return returnStr;                       
    }  
}