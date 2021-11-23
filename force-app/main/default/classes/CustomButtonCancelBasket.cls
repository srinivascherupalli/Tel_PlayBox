global with sharing class CustomButtonCancelBasket extends ValidateBasketStage {
    public String performAction(String basketId) {
        String validateClosedWon = validateBasketStageClosedWon(basketId);
        System.debug( 'RRRRR:' +validateClosedWon );
        String validateCancelled = validateBasketStageCancelled(basketId);
        System.debug( 'SSSSS:' + validateCancelled);
        String retVal = validateClosedWon!=null ? validateClosedWon : null;
        retVal = ((retVal==null) && validateCancelled!=null) ? validateCancelled : retVal;
        if(validateClosedWon == null && validateCancelled == null){
            return CustomButtonCancelBasket.CancelBasket(basketId);
        }
        else{
            return retVal;
        }       
    }
     
   
    public static String CancelBasket(String basketId) {
        
        
        try{

        String queryString = 'select id,csordtelcoa__Basket_Stage__c, cscfga__Products_Id_Qty_In_Basket__c, cscfga__Basket_Status__c, csbb__Account__c ' +
                             ' from cscfga__Product_Basket__c where id = \'' + basketId + '\'';

        cscfga__Product_Basket__c productBasket = Database.query(queryString);
        CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues('CancelBasket');
        String basketStage = customSetting.Enrichment_Basket_Stage__c;
               
          if (productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
                          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Basket_Already_In_Cancel_Stage));
            return '{"status":"error","text":"'+Label.Basket_Already_In_Cancel_Stage+'"}';
             
         } else {

            productBasket.csordtelcoa__Basket_Stage__c = basketStage;
            //set the basket stage field once available

        }

        update productBasket;
        
        PageReference ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
        ref.setRedirect(true);
        return '{"status":"ok","text":"'+Label.Basket_Cancellation_Message+'", "redirectURL":"' + ref.getUrl() + '"}';
        
        } catch(Exception e){        
            System.debug(e.getStackTraceString());
            Logger.getLogger(CustomButtonEnrichBasket.class).debug(e);
            return '{"status":"error", "text":"'+Label.Validate_Basket_Stage_Exception+'"}';            
        }

    }

}