/*********************************************************************************************************************************
Class Name      :   CustomButtonContractAccepted
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Antun Bartonicek        11/11/2019    EDGE-117966 (Parallel MACD)
 *********************************************************************************************************************************
*/
global with sharing class CustomButtonContractAccepted extends ValidateBasketStage {
    
   public String performAction(String basketId) {
      PageReference ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
      ref.setRedirect(true);
      //Checks if the basket stage is closed won. If so, returns error
      cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
      //EDGE-117966 (Parallel MACD): first validate basket so that we don't waste SOQLs on other checks if basked shouldn't be moved forward
      String macdValidation = validateMACDbasket(productBasket, true);
      if (String.isNotEmpty(macdValidation)) {
         return '{"status":"error", "text":"' + macdValidation + '", "redirectURL":"' + ref.getUrl() + '"}';
      }
       String validateClosedWon = validateBasketStageClosedWon(productBasket);
       String validateCancelled = validateBasketStageCancelled(productBasket);
       String retVal = validateClosedWon!=null ? validateClosedWon : null;
       System.debug('validateClosedWon : ' + retVal);
       if(validateClosedWon == null && validateCancelled == null){
           system.debug('before sync====////');
           CustomButtonOpportunitySync sync= new CustomButtonOpportunitySync();
           String syncMsg = sync.performAction(basketId);
           system.debug('after sync====////');
           productBasket.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c;
           if(syncMsg.contains('ok'))
             {
                update productBasket;
                return '{"status":"ok","text":"Contract Accepted Successful", "redirectURL":"' + ref.getUrl() +'"}';
             }
           else if (!syncMsg.contains('null'))
             {
             
                return syncMsg;
             }

       }
       return '{"status":"error","text":"Contract Accepted Error"}';
    }
    

}