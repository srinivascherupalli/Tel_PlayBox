/*************************************************************************************************
Name : CustomButtonCancelBasketNC
TestClass:CustomButtonCancelBasketNCTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Ankit              2-Nov-2020        EDGE-181979 (New)
2.      Gokul        02-Feb-2021    EDGE-192945
3.      Gokul        17-Feb-2021    EDGE-203212
4.       Arinjay Singh      23/02/2021     EDGE-201409 In-Flight: Reset Amend Allowed Heroku PONR flag 
===============================================================================================================================
***************************************************************************************************/    
global with sharing class  CustomButtonCancelBasketNC extends csbb.CustomButtonExt {
    public String performAction(String basketId) {
        Map<string,SharedDisplayMessage__c>errorDisplaySet=SharedDisplayMessage__c.getAll();
        try{
            cscfga__Product_Basket__c prodBas = Model_ProductBasket.getProductBasket(basketId);
            
                if (prodBas.csordtelcoa__Basket_Stage__c == 'Cancelled')         
                 return '{"status":"error","text":"'+errorDisplaySet.get('alreadySubmittedBasket').value__c+'"}';   
           //EDGE-192945 -- Start
            if(prodBas.recordtype.developername == 'Inflight_Change'){
                InflightProcessHelper inflHelper = new InflightProcessHelper();
                inflHelper.performInflightDiscard(prodBas);  
                prodBas.isCancelled__c = true;//EDGE-203212
            }
            //EDGE-192945 - End
            prodBas.csordtelcoa__Basket_Stage__c = 'Cancelled';
            update prodBas;        
            
            // Arinjay EDGE-201409
            HerokuConfigurationsUtility.resetAllowAmendInHeroku(basketId);
            PageReference ref = new PageReference('/' + prodBas.csbb__Account__c);
            ref.setRedirect(true);
            return '{"status":"ok","text":"'+''+'", "redirectURL":"' + ref.getUrl() + '"}';     
            
                                 
        }catch(Exception err){
                return '{"status":"error","text":"'+err+'"}';
        }
   
    }
 
}