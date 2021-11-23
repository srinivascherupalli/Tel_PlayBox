global with sharing class CustomButtonCommercialConfiguration extends ValidateBasketStage {
      public String performAction(String basketId) {
        String validateClosedWon = validateBasketStageClosedWon(basketId);
        String validateCancelled = validateBasketStageCancelled(basketId);
        String retVal = validateClosedWon!=null ? validateClosedWon : null;
        retVal = ((retVal==null) && validateCancelled!=null) ? validateCancelled : retVal;
        if(validateClosedWon == null && validateCancelled == null){
            return CustomButtonCommercialConfiguration.setStageCommercialConfiguration(basketId);
        }
        else{
            return retVal;
        }
       
    }
     
   
    public static String setStageCommercialConfiguration(String basketId) {
        
        
        try{

        String queryString = 'select id,csordtelcoa__Basket_Stage__c, cscfga__Products_Id_Qty_In_Basket__c, cscfga__Basket_Status__c, csbb__Account__c ' +
                             ' from cscfga__Product_Basket__c where id = \'' + basketId + '\'';


        cscfga__Product_Basket__c productBasket = Database.query(queryString);
        CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues('CommercialConfiguration');
        String basketStage = customSetting.Enrichment_Basket_Stage__c;
        CustomConfigurationOptions__c customSettingServiceDetailing = CustomConfigurationOptions__c.getValues('ServiceDetailing');
        String serviceStage = customSettingServiceDetailing.Enrichment_Basket_Stage__c;
               
        if(productBasket.cscfga__Products_Id_Qty_In_Basket__c == null) {                          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Empty_Basket));
            return '{"status":"error","text":"'+Label.Empty_Basket+'"}';             
        }else if(productBasket.cscfga__Basket_Status__c != 'Valid') {                          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Enrich_Basket_Error));
            return '{"status":"error","text":"'+Label.Enrich_Basket_Error+'"}';             
        }else if(productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Basket_Already_In_Commercial_Configuration));
            return '{"status":"error","text":"'+Label.Basket_Already_In_Commercial_Configuration+'"}';             
        }else if((productBasket.csordtelcoa__Basket_Stage__c == 'Draft')&& (productBasket.cscfga__Basket_Status__c == 'Valid')) {                          
            productBasket.csordtelcoa__Basket_Stage__c = basketStage;             
        }else if (productBasket.csordtelcoa__Basket_Stage__c == serviceStage) {
            productBasket.csordtelcoa__Basket_Stage__c = basketStage;          
        }

        update productBasket;
        
        PageReference ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
        ref.setRedirect(true);
        return '{"status":"ok","text":"'+Label.Basket_In_Commercial_Configuration+'", "redirectURL":"' + ref.getUrl() + '"}';
        
        } catch(Exception e){
        
            System.debug(e.getStackTraceString());
            Logger.getLogger(CustomButtonEnrichBasket.class).debug(e);
            return '{"status":"error", "text":"'+Label.Validate_Basket_Stage_Exception+'"}';
            
        }

    }

}