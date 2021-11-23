/*-------------------------------------------------------------------------------
EDGE        -150285
Class       -CustomButtonGenerateCAform
Description -Ability to regenerate CA form for Port-In and Port out reversal orders
Author      -Aishwarya yeware
---------------------------------------------------------------------------------*/
global with sharing class CustomButtonGenerateCAform extends csbb.CustomButtonExt {
    public static Boolean isPortOut{get;set;}
    public static Boolean isPortIn{get;set;}
    
/*-------------------------------------------------------------------------------
EDGE        -150285
Method      -checkPortInPortOutBasket
Description -Ability to regenerate CA form for Port-In and Port out reversal orders
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------*/
    public static void checkPortInPortOutBasket(){
        String basketId = apexpages.currentpage().getparameters().get('basketId');
        getPortInPortOut(basketId);
       
    }
    /*-------------------------------------------------------------------------------
EDGE        -149259
Method      -getPortInPortOut
Description -Ability to regenerate CA form for Port-In and Port out reversal orders
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------*/
    Public static void getPortInPortOut(String basketId){
        isPortOut=false;
        isPortIn=false;
        List<cscfga__Product_Basket__c> portOutBasketList=[SELECT id,Primary_Basket__c,cscfga__Opportunity__c, 
                                                           (SELECT id,Type__c,Basket__c,Service_Id__c FROM Numbers__r
                                                            WHERE Type__c =:label.PortOutReversal  AND Product_Configuration__c != NULL) 
                                                           FROM cscfga__Product_Basket__c WHERE  Id =:basketId LIMIT 1];
        List<cscfga__Product_Basket__c> portInBasketList=[SELECT id,Primary_Basket__c,cscfga__Opportunity__c, (SELECT id,Type__c,Basket__c,Service_Id__c FROM Numbers__r WHERE Type__c ='Port In' AND Product_Configuration__c != NULL) FROM cscfga__Product_Basket__c WHERE  Id =:basketId LIMIT 1];
        if(!portOutBasketList.isEmpty() && !portOutBasketList[0].Numbers__r.isEmpty()){
            isPortOut=true;
        }
        else if(!portInBasketList.isEmpty() && !portInBasketList[0].Numbers__r.isEmpty()){
            isPortIn=true;
        }  
    }
/*-------------------------------------------------------------------------------
EDGE        -150285
Method      -performAction
Description -Navigate to regenerate CA form component from solution console.
Author      -Aishwarya yeware
---------------------------------------------------------------------------------*/  
    public String performAction(String basketID) {
        String modelTitle='';
        getPortInPortOut(basketID);
        if(isPortIn){
          modelTitle='Customer Authorisation(CA) and Pre-Port Verification(PPV)';   
        }
        else {
         modelTitle  ='Upload new CA form' ;
        }
        string prodUtilURL = URL.getSalesforceBaseUrl().toExternalForm();
        String returnStr = null;
        if(basketID != null){
            String url = prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_RegenerateCA_URL+basketID;
            URL currentURL = New URL(prodUtilURL.substringBefore('--csbb')+System.Label.Lightning_RegenerateCA_URL+basketID);
            Set<String> whiteListedDomains = new Set<String>();
            whiteListedDomains.add(currentURL.getHost());
            if( url == NULL || !whiteListedDomains.contains(New URL(url).getHost())){
                url = '/home/home.jsp';
            }
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            returnStr = '{"status":"ok","text":"Opening regenarte CA form Screen", "displayInDialog": true,"size": "l","modalTitle": "'+ modelTitle +'", "redirectURL":"/apex/c__regenerateCA?isSC=false&basketID='+ basketID +'"}';  
        }
        return returnStr;                       
    }  
    
}