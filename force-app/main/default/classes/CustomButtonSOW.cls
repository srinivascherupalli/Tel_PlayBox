/**************************************************************************************************************
   Name          : CustomButtonSOW
   Created By    : Purushottam Sahu
   Created Date  : Sep 23 2019
   Description   : EDGE-108286 - Create SOW ,SOW Items and validates basket.
   -------
   History
   -------
   VERSION     AUTHOR             DATE            DETAIL
   -------     ------             -----           ---------
   1.1         Purushottam        23-09-2019      EDGE-108286: Created
   2.1         Shubhi			 01/07/2020   EDGE-147513    BillingAcc checks
   3.1         shubhi				16/07/2020			Pc name validation fix EDGE-162182
**************************************************************************************************************/
global with sharing class CustomButtonSOW extends ValidateBasketStage {
public String performAction(String basketId){
    String response;
    try {
        cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
         // EDGE-14751 start-------added by shubhi to verify billing acc 
            if(productBasket != null  && productBasket.csbb__Account__c != null){
                try{
                system.debug('inside quote sync ---?');
                    Boolean hasinvalidBillingAcc=ValidateMinimumRequirements.validateBasketforBillingAcc(productBasket.id,productBasket.csbb__Account__c);
                    if(hasinvalidBillingAcc){
                         ValidateMinimumRequirements.makebasketInvalid(productBasket);
                        return '{"status":"error","text":"' + System.Label.BillingAccountStatusValidation + '"}';
                    }
                }catch(Exception ex){
                    return  '{"status":"error", "text":"' + ex.getMessage() +'"}';
                }
            }
        // EDGE-14751 end-------
        Boolean hasOpptyContactRoles = OpportunitySyncUtil.checkOppContactRole(Id.valueOf(basketId), productBasket);
        if (hasOpptyContactRoles == false)
        {
            return '{"status":"error","text":"' + Label.No_Contact_Role_on_Opportunity + '"}';
        }
        GetSOWClauses sowClauses = new GetSOWClauses();
        Map<String,cscfga__Product_Configuration__c> productConfigurationDetails = sowClauses.getProfessionalServiceConfiguration(basketId);
        if (!productConfigurationDetails.isEmpty())
        {
            //EDGE-137491 START
            boolean tcPresent = false;
            boolean uctPresent = false;
            
            for(cscfga__Product_Configuration__c pc : [select OfferName__c,Name,ConfigurationType1__c,Type__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basketId and OfferName__c != null]){
                if(pc.OfferName__c == System.Label.NextGenUC /*&& pc.Name.contains(System.Label.NextGenUC)*/  &&pc.ConfigurationType1__c=='SolutionComponent' && String.isNotBlank(pc.Type__c) && pc.Type__c == 'New') 
                { // commented PC name condition for EDGE-162182
                    tcPresent = true;
              }else if(pc.OfferName__c == System.Label.UnifiedCommunicationTenancy){  uctPresent = true; }}
            if(tcPresent){
                if(!uctPresent){
                    return '{"status":"error","text":"' + Label.Label_UnifiedCommunicationTenancyNotPresent_Error + '"}';
                }
            }
            else if(uctPresent){
                return '{"status":"error","text":"' + Label.Label_UnifiedCommunicationTenancyPresent_Error + '"}';
            }           
            //EDGE-137491 END           
            Map<String,List<Clauses__c> > offerSOWClausesMapping = sowClauses.loadMarketableOfferClause(productConfigurationDetails.keySet());
            List<SOW__c> result= sowClauses.loadSOWClauses(offerSOWClausesMapping,productConfigurationDetails);
            System.debug('result: '+result);
            if (!result.isEmpty())
            {   SOW__c sowCreatedRec = result[0];
                PageReference ref = new PageReference('/' + sowCreatedRec.Id);
                ref.setRedirect(true);
                productBasket.csordtelcoa__Basket_Stage__c = 'SOW Initiated';
                update productBasket;
                response = '{"status":"ok","text":"'+Label.SOW_Initiated+'","redirectURL":"' + ref.getUrl() + '"}';
            }else
            {
                response = '{"status":"error","text":"'+Label.SOW_Failed+'"}';
            }
        }
        else
        {
            response = '{"status":"error","text":"'+Label.SOW_Failed_PC+'"}';
        }
    }
    catch (Exception e) {
        System.debug('Exception while SOW Initiate the basket : ' + e.getMessage());
        response = '{"status":"error","text":"' + e.getMessage() + '"}';
    }
    System.debug('Response: '+response);
    return response;
}
}