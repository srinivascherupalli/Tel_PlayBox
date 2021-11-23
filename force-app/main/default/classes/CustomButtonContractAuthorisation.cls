/*
* @Author   :   Manish Berad
* @Date     :   23 june 2020
* @Desc     :   EDGE-153347  Apex class linked to "Customer Pre-Authorisation" button on CS Basket to capture Pre-Authorisation details for MACD Orders
* */
global with sharing class CustomButtonContractAuthorisation extends ValidateBasketStage {
    /**
    * This method is called when 'Customer Pre-Authorisation' button click on Product Basket page
    * @param basketId   
    * @return 
    */
    public String performAction(String basketId) {
        cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
        String modalTitle = 'Customer Pre-Authorisation';//EDGE-165471
        String encbasketId = EncodingUtil.urlEncode(productBasket.id,'UTF-8');
        String encOppId = EncodingUtil.urlEncode(productBasket.cscfga__Opportunity__c,'UTF-8');
        String ShowURL = '/apex/c__ContractPreauthUploadPage?basketId='+encbasketId+'&OppId='+encOppId;
        return '{"displayInDialog":true, "size":"m","modalTitle": "' + modalTitle +'", "redirectURL":"' + ShowURL +'", "status":"ok","text":"Select Customer Pre-Authorisation"}';  
    }
}