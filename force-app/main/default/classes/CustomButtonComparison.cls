/*************************************************************************************************
Name : CustomButtonComparison
Description : Used to Compare the product basket configuration attributes .
***************************************************************************************************/
global with sharing class CustomButtonComparison extends csbb.CustomButtonExt implements cssmgnt.RemoteActionDataProvider {
    
    public String performAction(String basketID, String pcrIds) { 
        if(basketID != null){
            string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();
            String url = prodUtilURL.substringBefore('--csbb')+System.Label.LightningURL+basketID;
            String url_new = prodUtilURL.substringBefore('--csbb')+System.Label.LightningURL2+basketID;
            URL currentURL = New URL(prodUtilURL.substringBefore('--csbb')+System.Label.LightningURL+basketID);
            URL currentURL2 = New URL(prodUtilURL.substringBefore('--csbb')+System.Label.LightningURL2+basketID);
            Set<String> whiteListedDomains = new Set<String>();
            String title;
            String spinnerMessage;
            String TransitionVersion = EnvironmentVariable__c.getValues('TransitionVersion').Value__c;
            cscfga__Product_Basket__c bskt = [Select Id, Name,cscfga__Opportunity__r.Type, csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where Id=: basketID];
            //EDGE-185056: Rename order type to Migration for Migration type 
            if(bskt.cscfga__Opportunity__r.Type == 'Migration'){
            title = 'Migration (Basket - '+bskt.Name+' Stage - '+bskt.csordtelcoa__Basket_Stage__c+')';
            spinnerMessage='Opening Migration...';
            }
            else
            {
            title = 'Transition (Basket - '+bskt.Name+' Stage - '+bskt.csordtelcoa__Basket_Stage__c+')';
            spinnerMessage='Opening Transition...';
            }
            if(TransitionVersion=='2'){
                whiteListedDomains.add(currentURL.getHost());
                whiteListedDomains.add('www.salesforce.com');
                whiteLIstedDomains.add('www.google.com');
                if( url == NULL || !whiteListedDomains.contains(New URL(url).getHost())){
                    url = '/home/home.jsp';
                }
                PageReference pageRef = new PageReference(url);
                pageRef.setRedirect(true);
                System.debug('URL--- '+ pageRef.getUrl());
                return '{"status":"ok","text":"", "redirectURL":"' + pageRef.getUrl() +'"}';
            }else if(TransitionVersion=='3'){
                whiteListedDomains.add(currentURL2.getHost());
                whiteListedDomains.add('www.salesforce.com');
                whiteLIstedDomains.add('www.google.com');
                if( url_new == NULL || !whiteListedDomains.contains(New URL(url_new).getHost())){
                    url_new = '/home/home.jsp';
                }
                PageReference pageRef = new PageReference(url_new);
                pageRef.setRedirect(true);
                list<String> offerName = new list<String>();
                offerName.add('CWP Mobility');
                offerName.add('Enterprise Mobility offer');
                Boolean isMobilityProduct = isMobilityProduct(basketID, offerName);
                //  isMobilityProduct = true;
                return '{"status":"ok","text":"'+spinnerMessage+'", "displayInDialog": true,"size": "l","modalTitle": "'+title+'", "redirectURL":"/apex/c__CheckPointPage?id='+basketID+'&isdtp=vw&isMobilityProduct='+isMobilityProduct+'"}';
            }       
        }
        return null;                       
    }
    
    public String performAction(String basketID) {
        /* if(basketID != null){
string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();
String url = prodUtilURL.substringBefore('--csbb')+System.Label.LightningURL+basketID;
URL currentURL = New URL(prodUtilURL.substringBefore('--csbb')+System.Label.LightningURL+basketID);
Set<String> whiteListedDomains = new Set<String>();
whiteListedDomains.add(currentURL.getHost());
whiteListedDomains.add('www.salesforce.com');
whiteLIstedDomains.add('www.google.com');
if( url == NULL || !whiteListedDomains.contains(New URL(url).getHost())){
url = '/home/home.jsp';
}
PageReference pageRef = new PageReference(url);
pageRef.setRedirect(true);
return '{"status":"ok","text":"Redirect Successfully", "redirectURL":"' + pageRef.getUrl() +'"}';    
}*/
        return null;                       
    }
    
    public static boolean isMobilityProduct(String basketID, list<String> OfferName) {
        Boolean isMobilityProduct = false;
        String productSpecMobile = Label.ProductSpecificationMobile;
        List<String> listproductSpecMobile = productSpecMobile.split(',');
        try{
            List<Id> productConfigIds=new List<Id>();
            for(cscfga__Product_Configuration__c productConfig : [SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =:basketID AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile ORDER BY Createddate DESC]){
                productConfigIds.add(productConfig.id);
            }
            if(productConfigIds.size() > 0){
                isMobilityProduct = true;
            }
        }
        catch(exception e){
            
        }
        return isMobilityProduct;                       
    }
    
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {
        boolean isMobileExists = false;
        Map<String, Object> returnMap = new Map<String, Object>();
        Set<String> inputKey = inputMap.keySet();

                String basketId = (String)inputMap.get('GetBasket');     
                list<String> offerName = new list<String>();
                isMobileExists = isMobilityProduct(basketId, offerName); 
                returnMap.put('isMobileExists', isMobileExists);
        return returnMap;
        
    }
    
}