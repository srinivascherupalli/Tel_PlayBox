/*********************************************************************************************************************************
Class Name:     ValidateBasketStage
Description:    Common basket validations class that can be extended by CustomButton implementation classes

===============================================================================================================================
No.       Developer Name        Date            Story Description
1.        Antun Bartonicek      11/11/2019      EDGE-117966: Parallel MACD validations
**********************************************************************************************************************************
*/
global abstract inherited sharing class ValidateBasketStage extends csbb.CustomButtonExt {
//Abstract class to check if the basket stage is closed won
    public String validateBasketStageClosedWon(cscfga__Product_Basket__c productBasket){
        try{
            CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues('ClosedWon');
            String basketStage = customSetting.Enrichment_Basket_Stage__c;
            if(productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
                return '{"status":"error","text":"'+Label.Basket_Closed_Won_Error+'"}';
            }  else {
                return null;
            }
        } catch(Exception e){
            System.debug(e.getStackTraceString());
            Logger.getLogger(ValidateBasketStage.class).debug(e);
            return '{"status":"error", "text":"'+Label.Validate_Basket_Stage_Exception+'"}';
        }
    }
    public String validateBasketStageCancelled(cscfga__Product_Basket__c productBasket){
        try{
            CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues('CancelBasket');
            String basketStage = customSetting.Enrichment_Basket_Stage__c;
            if(productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
                return '{"status":"error","text":"'+Label.Cancelled_Basket+'"}';
            }  else {
                return null;
            }
        } catch(Exception e){
            System.debug(e.getStackTraceString());
            Logger.getLogger(ValidateBasketStage.class).debug(e);
            return '{"status":"error", "text":"'+Label.Validate_Basket_Stage_Exception+'"}';
        }
    }
    public String validateBasketStageClosedWon(String basketId){
        try{
            String queryString = 'select id,csordtelcoa__Basket_Stage__c, cscfga__Basket_Status__c, csbb__Account__c ' +
                                 ' from cscfga__Product_Basket__c where id = \'' + basketId + '\'';

            cscfga__Product_Basket__c productBasket = Database.query(queryString);
            CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues('ClosedWon');
            String basketStage = customSetting.Enrichment_Basket_Stage__c;
            if(productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
                return '{"status":"error","text":"'+Label.Basket_Closed_Won_Error+'"}';
            }  else {
                return null;
            }
        } catch(Exception e){
            System.debug(e.getStackTraceString());
            Logger.getLogger(ValidateBasketStage.class).debug(e);
            return '{"status":"error", "text":"'+Label.Validate_Basket_Stage_Exception+'"}';
        }
    }
    public String validateBasketStageCancelled(String basketId){
        try{
            String queryString = 'select id,csordtelcoa__Basket_Stage__c, cscfga__Basket_Status__c, csbb__Account__c ' +
                                 ' from cscfga__Product_Basket__c where id = \'' + basketId + '\'';

            cscfga__Product_Basket__c productBasket = Database.query(queryString);
            CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues('CancelBasket');
            String basketStage = customSetting.Enrichment_Basket_Stage__c;
            if(productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
                return '{"status":"error","text":"'+Label.Cancelled_Basket+'"}';
            }  else {
                return null;
            }
        } catch(Exception e){
            System.debug(e.getStackTraceString());
            Logger.getLogger(ValidateBasketStage.class).debug(e);
            return '{"status":"error", "text":"'+Label.Validate_Basket_Stage_Exception+'"}';
        }
    }

    /**
     * EDGE-117966: Parallel MACD
     * Checks that basket has no PC that are linked to already replaced subscriptions.
     * Ensures data integrity for parallel MACD scenario as MACD basket that is based on
     * outdated data should not be allowed to progress through stages.
     * Validates only MACD baskets i.e. where csordtelcoa__Change_Type__c has value.
     * @param justValidationMessage if true only validation message is returned instead of JSON
     * @return validation JSON, null if basket is valid
     */
    public String validateMACDbasket(String basketId, Boolean justValidationMessage) {
        cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
        return validateMACDbasket(productBasket, justValidationMessage);
    }

    /**
     * EDGE-117966: Parallel MACD
     * Package validation message wrapper method to give us option to return validation in JSON format suitable for custom button return value.
     */
    public String validateMACDbasket(cscfga__Product_Basket__c productBasket, Boolean justValidationMessage) {
        String retVal;
        if (productBasket == null) {
            retVal = null;
        } else if (String.isNotBlank(productBasket.csordtelcoa__Change_Type__c)) {
            //blank message means MACD basket is valid
            String validationMessage = cssmgnt.API_1.validateBasket(productBasket.Id);
            if (String.isNotEmpty(validationMessage)) {
                validationMessage = validationMessage.replaceAll('\r\n','\\\\n'); //Converting \r\n to JSON supported '\n' string
                retVal = justValidationMessage ? validationMessage : '{"status":"error", "text":"' + validationMessage + '"}';
            }
        }
        return retVal;
    }
}