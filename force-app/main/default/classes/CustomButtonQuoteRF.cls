/*********************************************************************************************************************************
Class Name: CustomButtonQuoteRF
Description: Invokes Quote generation, sync logic and validates basket.
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Purushottam Sahu        25/09/2019    EDGE-108286  If the basket status is SOW Initiated not updating the Quote status to Quote.
2.        Antun Bartonicek        11/11/2019    EDGE-117966 (Parallel MACD validations)
3.        Tejes Mahajan           02/04/2020    EDGE-141820 (EAP discount end date validation)  
4.        Shubhi V                01/07/2020    EDGE-151354 EDGE-147513    BillingAcc check
5.        Payal Popat             29/09/2020    EDGE-176217 Refactored the existingcode
6.        Payal Popat             10/12/2020    EDGE-190131 - Fix for SOW issue
7.        Pooja Gupta             05/01/2021    EDGE-191824 - PONR Check before initiating Contract/Skip Contract/Quote
7.        Gunjan Aswani           07/01/2021    EDGE-192931 - Stop sync process for Quote/Contract/Skip Contract
8.        Arunkumar V          15/02/2021  EDGE-201334 - Stop performing PONR updates to Heroku during basket journey
9.        Payal         		26/04/21    EDGE-216620 - Updated Attribute name "billingAccountLookup" in config query
10.		  Radhika 			20/09/2021		DIGI-931		Added field cscfga__Product_Definition__r.product_Specification__c in cscfga__Product_Configuration__c query
 *********************************************************************************************************************************
*/
@JsonAccess(serializable='always' deserializable='always')//Added by Pooja to resolve 'Type cannot be desrialized' error due to class version.
global with sharing class CustomButtonQuoteRF extends csbb.CustomButtonExt  {
    global static string callingSource = '';//EDGE-201334
    public String performAction(String basketId) {
        String basketIdNew = basketId;//EDGE-183465 added by Abhishek from Osaka Team
        cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
             
        String recordTypeName = productBasket.recordType.Name;//EDGE-192931 - In-Flight : Stop sync process for Quote/Contract/Skip Contract - By Gunjan
        
        //EDGE-191824 start
        Boolean response = false;
        if(recordTypeName == 'Inflight Change'){
            callingSource = 'Quote';//EDGE-201334
            response  = PONRUtilityClass.ValidatePONRforBasket(productBasket);
            callingSource = '';
        }
        if(response){
            system.debug('inside response');
            return '{"status":"error","text":"' + Label.Order_has_reached_PONR + '"}';
        }      
        //EDGE-191824 end
        
        //check if product attribute is null in the product configs and throw error
        List<cscfga__Product_Configuration__c> configList = [
            SELECT id,
            Name,
            //Girish P: Add the offername
            Marketable_Offer__r.name,
            Marketable_Offer__r.Offer_ID__c,Marketable_Offer__c, Marketable_Offer__r.OfferDefinationName__c,
            cscfga__Configuration_Status__c,
            cscfga__total_contract_value__c,
            cscfga__Product_Basket__r.cscfga__Opportunity__c,
            cscfga__Description__c,
            cscfga__Contract_Term__c,
            Type__c,
            configGUID__c,
            ConfigurationType1__c,
            cscfga__Product_Definition__r.name,
            cscfga__Product_Definition__r.product_Specification__c,//DIGI-931
            (
                SELECT id, Name, cscfga__Value__c
                FROM cscfga__Attributes__r where name IN ('Product','BillingAccountLookup')
            )
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c = :basketId
        ];
        
        
        
        //EDGE-183465 added by Abhishek from Osaka Team Start
        String serviceResponse = quoteServiceValidation(basketIdNew);
            if(!String.isBlank(serviceResponse)){
                return serviceResponse;
            }
        //EDGE-183465 added by Abhishek from Osaka Team End
        ValidationsForBasketOperations validateBasket = new ValidationsForBasketOperations();
        string validationResponse = validateBasket.performValidation(productBasket,configList,'quote');
        if(!String.isBlank(validationResponse) && validationResponse.containsIgnoreCase('ok')){ 
                Boolean isOppHavingAnotherPrimaryBasket = false;
              List<cscfga__product_basket__c> objProductBasket = [
                SELECT id, csbb__Synchronised_with_Opportunity__c, Primary_Basket__c
                FROM cscfga__product_basket__c
                WHERE Primary_Basket__c = TRUE AND cscfga__Opportunity__c = :productBasket.cscfga__Opportunity__c AND Id != :productBasket.id
              ];
              if (objProductBasket.size() > 0) {
                isOppHavingAnotherPrimaryBasket = true;
              }
            string isSyncSuccess='ok';
            Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());    // Custom setting used to disable all the validation rules for the current running user. 
            if (ecCusSetting.No_Validations__c == false) {  
                ecCusSetting.No_Validations__c = true;
                upsert ecCusSetting;
            }
            if(!isOppHavingAnotherPrimaryBasket && productBasket.csordtelcoa__Basket_Stage__c != CustomConfigurationOptions__c.getValues('Quote').Enrichment_Basket_Stage__c){
 

                if (productBasket.csordtelcoa__Basket_Stage__c !='SOW Initiated' && productBasket.csordtelcoa__Basket_Stage__c !='SOW Approved')   //EDGE-108286 >> +, Added SOW Approved Status as part of the defect Fix EDGE-197190

                {productBasket.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('Quote').Enrichment_Basket_Stage__c;}
                //EDGE-192931 - In-Flight : Stop sync process for Quote/Contract/Skip Contract added recordTypeName != 'Inflight Change'- By Gunjan
                System.debug(' >>> recordTypeName >>> Value= ' + recordTypeName);
                if ( recordTypeName != 'Inflight Change'){
                    AfterValidationSyncOperations syncOprts = new AfterValidationSyncOperations(productBasket);
                    isSyncSuccess= syncOprts.performBasketSync();
                    System.debug('Inside >>> recordTypeName not equals Inflight Change');
                }              
            }else{

                if (productBasket.csordtelcoa__Basket_Stage__c !='SOW Initiated' && productBasket.csordtelcoa__Basket_Stage__c !='SOW Approved')   //EDGE-108286 >> +, Added SOW Approved Status as part of the defect Fix EDGE-197190

                {productBasket.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('Quote').Enrichment_Basket_Stage__c;}
                    AfterValidationSyncOperations syncOprts = new AfterValidationSyncOperations(productBasket);
                    syncOprts.updateProductBasket();
                    isSyncSuccess = syncOprts.syncMsg;
            }
            if (ecCusSetting.No_Validations__c == true) {  
                ecCusSetting.No_Validations__c = false;
                upsert ecCusSetting;
            }
            if(isSyncSuccess.containsIgnoreCase('ok')){
                String quoteId = '';
                try{
          			/*boolean isIOT = false;
                    for(cscfga__Product_Configuration__c objConfig :configList){
                        if(objConfig.Marketable_Offer__c != null && objConfig.Marketable_Offer__r.Offer_ID__c == 'DMCAT_Offer_000964'){
                            isIOT = true;
                            break;
                        }
                    }*/
                  //  quoteId = createQuote(basketId,isIOT);
                  quoteId = createQuote(basketId);
                    if(quoteId == null || quoteId == ''){
                        return '{"status":"error","text":"sync' + Label.Quote_Generation_Falied  + '"}';
                    }else{
                        PageReference ref = new PageReference('/' + quoteId);
                        ref.setRedirect(true);
                        return '{"status":"ok","text":"' + Label.QuoteGenerationSuccessful + '", "redirectURL":"' + ref.getUrl() + '"}';
                    }
                }catch(Exception e) {
                    if(quoteId !='' && quoteId != null)
                        rollbackQuote(quoteId);
                    return '{"status":"error", "text":"' + e.getMessage() +'"}';
                }
            }
           
        }else{
            return validationResponse;
        }
        return '{"status":"error","text":"' + Label.Quote_Generation_Falied + '"}';
    }
       
    /*
    * Method: Used to rollbackQuote in case of any issue
    * parameters : quoteId
    * Description: Used to roll back quote in case of any issue in the process
    */
    public static void rollbackQuote(Id quoteId){
        try{   
            Database.delete(quoteId);
        }
        catch(Exception exc) {
            System.debug(LoggingLevel.ERROR, 'rollbackQuote.exc = ' + exc);
        }
    }
    /*
    * Method: Used to createQuote in case of any issue
    * parameters : basketId, flag for checking basket has IOT offer
    * Description: Used to roll back quote in case of any issue in the process
    */
    //EDGE-13934:Moved from CustomButtonQuote class, to resolve 'uncommitted work pending' error
   // public static String createQuote(String basketId,Boolean isIOT){
   public static String createQuote(String basketId){
        String templateID = null;
        //DPG-1618 Added new Quote Template for IoT
       // String templateName = isIOT ? 'IoT Quote': 'Quote';
       String templateName = 'Quote';
        List<APXTConga4__Conga_Template__c> templateList = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c =: templateName ORDER BY APXTConga4__Name__c Limit 1];
        if(templateList.size()>0){
            templateID = templateList[0].id;
            templateID =  templateID.substring(0,templateID.length() - 3);
        }
        return GenerateQuoteHelper.createQuote(templateID, basketId);
    }
    
    /************************************************************************
Name: quoteServiceValidation
Description: Invokes validation after clicking on QUote button..
Story : EDGE-183465
Developer: Abhishek Osaka Team
Description: This method Invokes validations related to services and its associated add-ons
************************************************************************/
    public static String quoteServiceValidation(String basketId){
        System.debug('Basket ID:'+basketId);
        String validationMessage;
        if(basketId != null){
            List<Legacy_Service__c> legacyRecIdList = new List<Legacy_Service__c>([Select id from Legacy_Service__c where Product_basket__c =:basketId]);
            List<Id> legacyId = new List<Id>();
            List<service_add_on__c> addOnRecList = new List<service_add_on__c>();
            List<service_add_on__c> addOnRecSelected = new List<service_add_on__c>();
            List<service_add_on__c> addOnRecNotSelected = new List<service_add_on__c>();
            for(Legacy_Service__c serviceRec : legacyRecIdList){
                legacyId.add(serviceRec.Id);
            }
            addOnRecList = [Select id,status__c,Legacy_Service__r.select__c,Product_End_Date__c from service_add_on__c where Legacy_Service__r.Id in :legacyId];
            for(service_add_on__c addOnRecords : addOnRecList){
                if(addOnRecords.Legacy_Service__r.select__c = false && addOnRecords.status__c == 'Sync Removal Pending'){
                        addOnRecNotSelected.add(addOnRecords);
                } 
                else if(addOnRecords.Legacy_Service__r.select__c = true && addOnRecords.status__c != 'Sync Completed' && addOnRecords.Product_End_Date__c > Date.today().addDays(Integer.valueOf(System.Label.ProductRemainingEndDays))) {
                    addOnRecSelected.add(addOnRecords);
                }
            }      
            System.debug('Selected::'+addOnRecSelected);
            System.debug('Unselected::'+addOnRecNotSelected);
            
            if(!addOnRecSelected.isEmpty() || !addOnRecNotSelected.isEmpty()){
                validationMessage =  '{"status":"error","text":"' + System.Label.Quote_Add_On_Error + '"}';                    
            }     
        }
        return validationMessage;
    }
}