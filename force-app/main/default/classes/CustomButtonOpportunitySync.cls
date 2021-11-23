/*************************************************************************************************
   Name : CustomButtonOpportunitySync
   Description : Used to Sync the product basket configuration attributes with the opportunity.
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijay      21/08/2019      EDGE-81113 MDM migration order
2.      Ritika Jaiswal    19/08/2019    EDGE-98246 Corrections in SyncMessage method 
3.      Suyash Chiplunkar  18/03/2020   DPG-1618 Added new Quote Template for IoT
4.      Shubhi Vijayvergia  1/04/2020    EDGE-142888
5.      Suyash Chiplunkar  06/04/2020    DPG-1690 Changes Based on governance review comments
6.      Laxmi Rahate       07/04/2020    EDGE-131729 Changes for Incremental Revenue
7.      Laxmi Rahate       15/04/2020    EDGE-133414 COmmented code for Unit Price Calculation
8.    Vijayalakshmi S    28/05/2020    P2OB-4991 Change to remove contact role validation for non modular baskets
9.      Gnana              30/06/2020    EDGE-151354 Added logic for Device Care Contact Details
10.     shubhi             01/07/2020    EDGE-147513    BillingAcc check
**************************************************************************************************/
global with sharing class CustomButtonOpportunitySync extends csbb.CustomButtonExt {
@TestVisible private static String quoteURL;
public static String DisplayMessage;
public static String status;
public static String totalInfo;
public String quoteId = null;
OpportunityProductType productType;
private static cscfga__Product_Basket__c productBasket;
private static Environment_Configurations__c cussetting;
private static List <cscfga__Product_Configuration__c> configList;
private static set <String> setMarketableOffers = new Set<String>();
/*Invoked upon the click of sync button */
public String performAction(String basketId){

    String msg = syncMessage(basketId, false);
    //EDGE-11104, EDGE-55792 - added condition for product type equal to non modular
    if(productBasket != null && msg.contains('ok') &&
       productBasket.cscfga__opportunity__r.Product_Type__c != '' &&
       !productBasket.cscfga__opportunity__r.Product_Type__c.toLowerCase().contains('non')) {
        ModularProductType.updateOpportunityInfo(productBasket);
    }
    //Team Hawaii - Update Last Sync Date on Opportunity
    if(productBasket != null  && productBasket.cscfga__opportunity__c != null){
        try{
    OpportunitySyncUtil.updateSyncOpportunityInfo(productBasket.cscfga__opportunity__c);
        }catch(Exception ex){
            msg = '{"status":"error", "text":"' + ex.getMessage() +'"}';
        }
    }
  //P2OB-4991 changes start
    system.debug('Product_Type__c is ' +productBasket.cscfga__opportunity__r.Product_Type__c);
    //Contact role validation only for modular baskets.
    //if(!productBasket.cscfga__opportunity__r.Product_Type__c.toLowerCase().contains('non')) 
  if(OpportunityProductType.isModularProductType (productBasket))
    {
        system.debug('Inside modular check');
        Boolean hasOpptyContactRoles = OpportunitySyncUtil.checkOppContactRole(Id.valueOf(basketId),productBasket);
        if (hasOpptyContactRoles == false)
            msg = '{"status":"error","text":"' + Label.No_Contact_Role_on_Opportunity + '"}';
    }
    //P2OB-4991 changes end
  
    // added by Shubhi for  EDGE-147513 
    if(productBasket != null  && productBasket.csbb__Account__c != null){
        try{
            Boolean hasinvalidBillingAcc=ValidateMinimumRequirements.validateBasketforBillingAcc(productBasket.id,productBasket.csbb__Account__c);
            if(hasinvalidBillingAcc){
                ValidateMinimumRequirements.makebasketInvalid(productBasket);
               return '{"status":"error","text":"' + Label.BillingAccountStatusValidation + '"}';
            }
        }catch(Exception ex){
            return msg = '{"status":"error", "text":"' + ex.getMessage() +'"}';
        }
    }
    return msg;
    
    
}
//method created for reference to other buttons for doing automatic sync. EDGE-11104
public String syncMessage(String basketId, Boolean isQuote){
    //Ritika: moved the definition outside, as the method getValidProductBasket get called from CustonButtonQuote also
    //setMarketableOffers = new Set<String>();
    Boolean isCOnfigOnlyBasket=false;
    configList = new List<cscfga__Product_Configuration__c>();
    try{
        productBasket = getValidProductBasket(basketId);
        if(DisplayMessage != null) {
            return '{"status":"error", "text":"' + DisplayMessage + '"}';
        }
        cussetting = Environment_Configurations__c.getInstance(Userinfo.getUserId());
        System.debug(LoggingLevel.INFO, '[CustomButtonOpportunitySync] syncMessage DisplayMessage: ' + DisplayMessage + ' Opportunity Product_Type__c ' + productBasket.cscfga__Opportunity__r.Product_Type__c);
        if(DisplayMessage == null && OpportunityProductType.isModularProductType(productBasket)) {
            //Girish P": Fire validation only if atleast offer in basket is NOT config only, ex- MDM config
           //  String validateMessage = ValidateMinimumRequirements.run(productBasket.Id);
           // Aditya Changes Edge - 126937
            String validateMessage = '';
            isCOnfigOnlyBasket = BasketCustomProcess.isConfigOnlyBasket(setMarketableOffers);
             if(!isCOnfigOnlyBasket) {
                validateMessage = ValidateMinimumRequirements.run(productBasket.Id);
                System.debug(LoggingLevel.INFO, 'syncMessage.validateMessage = ' + validateMessage);
                if(validateMessage.contains('error')) {
                    DisplayMessage =  validateMessage.split('-')[1];
                    status = validateMessage.split('-')[0];
                }
             }
                //EDGE-13934:Validate product basket and generate Quote. This was added in this class to resolve the 'uncommitted work pending' error.
            //EDGE-107093 - Failure on Quote for config-only basket    
            if((isCOnfigOnlyBasket && isQuote)|| (DisplayMessage == null && validateMessage!=null && validateMessage.contains('ok') && isQuote) ){
                    quoteId = createQuote(basketId);
                    System.debug(LoggingLevel.INFO, 'syncMessage.quoteId = ' + quoteId);
                    if(quoteId == null || quoteId == '')
                        return '{"status":"error","text":"sync' + Label.Quote_Generation_Falied  + '"}';
                }
            //EDGE-60616 - throw error if basket is not valid during sync process
            if( !isProductBasketValid() ) {
                return '{"status":"' + status + '", "text":"' + DisplayMessage + '"}';
            }
            //EDGE-22590 to check the basket stage and if opportunity linked to this basket has any Primary basket and display error
            string primaryBasketError = makeprimaryBasketError();
            System.debug(LoggingLevel.INFO, 'syncMessage.primaryBasketError = ' + primaryBasketError);
            if(primaryBasketError != null)
                return primaryBasketError;
        }
        // if the setting field is false, update it to disable validation rules
        if (cussetting.No_Validations__c == false) {
            cussetting.No_Validations__c = true;
            upsert cussetting;
        }
        if(DisplayMessage == null) {
            /**Delete Existing Opportunity Produtcs***/
            OpportunityBulkSyncHelper.deleteOLI(new List<String> {productBasket.cscfga__Opportunity__c});
            /***Display Message***/
            //TODO: ambigous/misleading method name
            //Basket rules runs ans auto create OLIs
            displayOppMessage(productBasket);
            /****To create the Opportunity Product****/
            //TODO: ambigous/misleading method name.
            //OLI is upserted and no new OLI gets create from this method
            createOLI(basketId, productBasket);
        }
        /* added cussetting.id!=null for the case when default custom setting
           has no Validations true and user instance is not created in custom setting*/
        if (cussetting.id != null && cussetting.No_Validations__c == true) {
            cussetting.No_Validations__c = false;
            update cussetting;
        }
        Id userId = UserInfo.getProfileId();
        String queryString = 'SELECT id, Name FROM PROFILE WHERE id = :userId';
        List<Profile> profileList = Database.query(queryString);
        System.debug(LoggingLevel.INFO, 'syncMessage.profileList = ' + profileList);
        PageReference ref = null;
        if(profileList != null && profileList.size() > 0 && (profileList[0].Name == Label.PRM_Community_User || profileList[0].Name == Label.PRM_Indirect_Channel_Mangr ||
                                                             profileList[0].Name == Label.PRM_Indirect_channel_mgrIntl || profileList[0].Name == Label.PRM_CommunityAdmin_User))
            ref = new PageReference('/' + productBasket.id);
        else
            ref = new PageReference('/apex/c__NewBasketOverrideRedirectPage?id=' + productBasket.id);
        ref.setRedirect(true);
        if(!status.contains('ok') && quoteId != '' && quoteId != null) {
            System.debug(LoggingLevel.INFO, 'Rollback Quote');
            rollbackQuote(productBasket.Id);
        }
        System.debug(LoggingLevel.INFO, 'syncMessage.tryend = ' + DisplayMessage);
        System.debug(LoggingLevel.INFO, 'syncMessage.status = ' + status);
        return '{"status":"'+ status + '", "text":"' + DisplayMessage + '", "redirectURL":"' + ref.getUrl() +'"}';
    }
    catch(Exception e) {
        if(quoteId !='' && quoteId != null)
            rollbackQuote(productBasket.Id);
        System.debug(LoggingLevel.INFO, 'syncMessage.catch = ' + e.getMessage() + e.getLineNumber() + e.getStackTraceString());
        return '{"status":"error", "text":"' + e.getMessage() +'"}';
    }
}
public static void rollbackQuote(String basketId){
    System.debug(LoggingLevel.INFO, 'rollbacQuote');
    try{
        Quote q = [
            SELECT Id
            FROM Quote
            WHERE Product_Basket__c = :basketId
        ];
        if(q != null)
            Database.delete(q);
    }
    catch(Exception exc) {
        System.debug(LoggingLevel.ERROR, 'rollbackQuote.exc = ' + exc);
    }
}
public static cscfga__Product_Basket__c getValidProductBasket(String basketId){
    cscfga__Product_Basket__c productBasket;
    Boolean updateBasket = false; // Added as part of EDGE-151354
    System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.getValidProductBasket.enter.DisplayMessage = ' + DisplayMessage);
    try{
        String queryString = 'SELECT ';
        queryString += 'id, ';
        queryString += 'cscfga__Opportunity__c, ';
        queryString += 'csordtelcoa__Basket_Stage__c, ';
        queryString += 'csbb__Synchronised_With_Opportunity__c, ';
        queryString += 'Primary_Basket__c, ';
        queryString += 'cscfga__Opportunity__r.Product_Type__c, ';
        queryString += 'cscfga__Opportunity__r.StageName, ';
        queryString += 'cscfga__total_contract_value__c, ';
        queryString += 'cscfga__opportunity__r.pricebook2.isstandard, ';
        queryString += 'cscfga__Basket_Status__c, ';
        queryString += 'Express_Flow__c, '; //added for edge 81113 
        queryString += 'cscfga__Opportunity__r.Model_Change__c, '; //added for edge 81113 
        queryString += 'Is_Device_Care_Contact_Required__c, '; // Added as part of EDGE-151354
        queryString += 'csbb__Account__c '; //EDGE-147513 
        queryString += 'FROM ';
        queryString += 'cscfga__Product_Basket__c ';
        queryString += 'WHERE ';
        queryString += 'id = :basketId ';
        productBasket = Database.query(queryString);
        if (productBasket.csbb__Synchronised_with_Opportunity__c) {
            //StaticUtilForRecursion.autoSyncRunFlag = false;
            productBasket.csbb__Synchronised_with_Opportunity__c = false;
            updateBasket = true; // Added as part of EDGE-151354
            //update productBasket; // Moved to end of this method as part of EDGE-151354
        }
    }
    catch(Exception e) {
        System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.getValidProductBasket.exception = ' + e);
        DisplayMessage = e.getMessage();
        if(DisplayMessage == null || DisplayMessage.contains('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY'))
            DisplayMessage = 'Only the opportunity owner can sync the product basket';
        status = 'error';
        return null;
    }
    //check if product attribute is null in the product configs and throw error
    configList = [
        SELECT id,
        Name,
        //Girish P: Add the offername
       Marketable_Offer__r.name,
        cscfga__Configuration_Status__c,
        cscfga__total_contract_value__c,
        cscfga__Product_Basket__r.cscfga__Opportunity__c,
        cscfga__Description__c,
        cscfga__Contract_Term__c,
        Type__c,
        configGUID__c,
        cscfga__Product_Definition__r.name,
        (
            SELECT id, Name, cscfga__Value__c
            FROM cscfga__Attributes__r
        )
        FROM cscfga__Product_Configuration__c
        WHERE cscfga__Product_Basket__c = :basketId
    ];
    System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.getValidProductBasket.afterconfig.DisplayMessage = ' + DisplayMessage);
    if(configList.size() == 0) {
        DisplayMessage = 'Please add atleast one valid product before sync';
        status = 'error';
    }
    // check if all product configuration are valid
    for (cscfga__Product_Configuration__c config : configList) {
        //Girish P: add unique marketable Offers in set
        system.debug('config.Marketable_Offer__r.Name'+config.Marketable_Offer__r.Name);
        system.debug('config.cscfga__Product_Definition__r.name'+config.cscfga__Product_Definition__r.name);
       if(!String.isEmpty(config.Marketable_Offer__r.Name))
           system.debug('Inside if -config.Marketable_Offer__r.Name');
           setMarketableOffers.add(config.Marketable_Offer__r.Name);        
        if (config.cscfga__Configuration_Status__c != 'Valid') {
            DisplayMessage = 'One or more invalid product configurations in the basket';
            status =  'error';
            break;
        }
        /* Added as part of EDGE-151354 EDGE-151354 - Start */
        if(config.cscfga__Product_Definition__r.name == 'Mobile Device Care' && config.Type__c == 'New'){
            System.debug('DCC is required...');
            productBasket.Is_Device_Care_Contact_Required__c = 'Yes';
            updateBasket = true;
        }
        /* Added as part of EDGE-151354 EDGE-151354 - End */
        for(cscfga__Attribute__c attr : config.cscfga__Attributes__r) {
            System.debug('attr'+attr.id);
            if(attr.Name == 'Product' && attr.cscfga__Value__c == null) {
                System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.getValidProductBasket.atrValue = ' + attr +attr.cscfga__Value__c);
                DisplayMessage = 'Please select  products for all configurations or delete unwanted configurations before sync';
                status = 'error';
                break;
            }
        }
        if (status == 'error') break;
    }
    System.debug('CustomButtonOpportunitySync.getValidProductBasket.beforereturn.DisplayMessage = ' + DisplayMessage);
    /* Added as part of EDGE-151354 EDGE-151354 - Start */
    try{
        if(updateBasket){
            UPDATE productBasket;
        }
    }
    catch(Exception e) {
        System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.getValidProductBasket.exception = ' + e);
        DisplayMessage = e.getMessage();
        if(DisplayMessage == null || DisplayMessage.contains('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY'))
            DisplayMessage = 'Only the opportunity owner can sync the product basket';
        status = 'error';
        return null;
    }
    /* Added as part of EDGE-151354 EDGE-151354 - End */
    return productBasket;
}
//EDGE-13934:Moved from CustomButtonQuote class, to resolve 'uncommitted work pending' error
public static String createQuote(String basketId){
    String templateID = null;
    //DPG-1618 Added new Quote Template for IoT
    //List<String> nameOfTemplates = new list<String> {'Quote','IoT Quote'};
    List<String> nameOfTemplates = new list<String> {'Quote'};
    Map<String,String> mapOfTemplates = getTemplateId(nameOfTemplates,'template');
    if ( null != mapOfTemplates){
        templateID = mapOfTemplates.get('Quote');
        //DPG-1618 Added new Quote Template for IoT
     /*   if(productNameContains(basketId) && mapOfTemplates.containsKey('IoT Quote')){
            templateID = mapOfTemplates.get('IoT Quote');
        }*/
    }
    System.debug(LoggingLevel.DEBUG, '****templateID..' + templateID);        
    return GenerateQuoteHelper.createQuote(templateID, basketId);
}
//DPG-1618 Added new Quote Template for IoT
public static Boolean productNameContains(String basketId){
    //DPG-1690 Updated the logic based of Marketable Offer
    String IOTOfferId = 'DMCAT_Offer_000964';
    List<cscfga__Product_Configuration__c> pc= [SELECT 
                                                    id,Name,Marketable_Offer__r.Offer_ID__c,Marketable_Offer__r.Name, Marketable_Offer__r.OfferDefinationName__c 
                                                FROM 
                                                    cscfga__Product_Configuration__c 
                                                WHERE 
                                                    cscfga__Product_Basket__c=:basketId];
    boolean isIOT=false;
    for(cscfga__Product_Configuration__c row :pc ){
        if(row.Marketable_Offer__c != null && row.Marketable_Offer__r.Offer_ID__c == IOTOfferId){
            System.debug(row.Marketable_Offer__c);
            isIOT = true;
            break;
        }
    }
    system.debug('isIOT---'+isIOT);
    return isIOT;
}
//EDGE-22590 to check the basket stage and if opportunity linked to this basket has any Primary basket and display error
public String makeprimaryBasketError(){
    Id oppId = productBasket.cscfga__Opportunity__c;
    String queryString = 'SELECT ';
    queryString += 'id, ';
    queryString += 'name, ';
    queryString += 'cscfga__Opportunity__c, ';
    queryString += 'Primary_Basket__c, ';
    queryString += 'csordtelcoa__Basket_Stage__c ';
    queryString += 'FROM ';
    queryString += 'cscfga__Product_Basket__c ';
    queryString += 'WHERE ';
    queryString += '(csordtelcoa__Basket_Stage__c = \'Contract Initiated\' ';
    queryString += 'OR ';
    queryString += 'csordtelcoa__Basket_Stage__c = \'Enriched\') ';
    queryString += 'AND ';
    queryString += 'Primary_Basket__c = true ';
    queryString += 'AND ';
    queryString += 'cscfga__Opportunity__c = :oppId';
    List<cscfga__Product_Basket__c> basketList = Database.query(queryString);
    if(basketList != null && basketList.size() > 0)
        return '{"status":"error","text":"' + Label.Make_Primary_Basket_Error.replace('basketId', basketList[0].name) + '"}';
    return null;
}
public Boolean isProductBasketValid(){
    Boolean isValid = true;
    if ((null == productBasket || null == productBasket.cscfga__Basket_Status__c)
        ||(!productBasket.cscfga__Basket_Status__c.equalsIgnoreCase('valid'))) {
        DisplayMessage = Label.Basket_Not_Valid_For_Sync;
        status = 'error';
        isValid = false;
    }
    return isValid;
}
public void displayOppMessage(cscfga__Product_Basket__c productBasket){
    totalInfo = OpportunitySyncUtil.syncWithOpportunity(productBasket, null);
    // totalInfo = OpportunitySyncUtil.syncWithOpportunity(productBasket, productBasket.csordtelcoa__Basket_Stage__c);
    if(totalInfo !=null && totalInfo.split('-').size() == 2) {
        status = totalInfo.split('-')[0];
        DisplayMessage = totalInfo.split('-')[1];
    }
}
/****create new Opportunity Product****/
public void createOLI(String basketId, cscfga__Product_Basket__c productBasket){
    Boolean isStatusWon = true;
    List<String> pcodeList = new List<String>();
    List<String> pMaxNameList = new List<String>();
    Map<String,cspmb__Price_Item__c> codeNamePriceItemMap = new Map<String,cspmb__Price_Item__c>();
    Map<Id, cscfga__Product_Configuration__c> configMap = new Map<Id, cscfga__Product_Configuration__c>();
    String queryString = 'SELECT ';
    queryString += 'Id, ';
    queryString += 'Name, ';
    queryString += 'cscfga__Configuration_Status__c, ';
    queryString += 'cscfga__total_contract_value__c, ';
    queryString += 'cscfga__Product_Basket__r.cscfga__Opportunity__c, ';
    queryString += 'cscfga__Description__c, ';
    queryString += 'cscfga__Contract_Term__c, ';
    queryString += 'Type__c, ';
    queryString += '(';
    queryString += 'SELECT ';
    queryString += 'Id, ';
    queryString += 'Name, ';
    queryString += 'cscfga__Value__c ';
    queryString += 'FROM ';
    queryString += 'cscfga__Attributes__r ';
    queryString += ') ';
    queryString += 'FROM ';
    queryString += 'cscfga__Product_Configuration__c ';
    queryString += 'WHERE ';
    queryString += 'cscfga__Product_Basket__c = :basketId ';
    List<cscfga__Product_Configuration__c> configList = Database.query(queryString);
    //EDGE-13250
    for(cscfga__Product_Configuration__c config : configList) {
        configMap.put(config.Id, config);
        for(cscfga__Attribute__c attr : config.cscfga__Attributes__r) {
            if(attr.Name == 'ProductCode' && attr.cscfga__Value__c != null)
                pCodeList.add(attr.cscfga__Value__c);
            if(attr.Name == 'ProductMaximName' && attr.cscfga__Value__c != null)
                pMaxNameList.add(attr.cscfga__Value__c);
        }
    }
    System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.createOLI.configMap = ' + configMap);
    queryString = 'SELECT Name, ';
    queryString += 'Maxim_Product_Name__c, ';
    queryString += 'Product_Code__c, ';
    queryString += 'Product_Family__c, ';
    queryString += 'Product_Group__c, ';
    queryString += 'Ultimate_Product__c ';
    queryString += 'FROM ';
    queryString += 'cspmb__Price_Item__c ';
    queryString += 'WHERE ';
    queryString += 'Product_Code__c ';
    queryString += 'IN ';
    queryString += ':pCodeList ';
    queryString += 'AND ';
    queryString += 'Maxim_Product_Name__c ';
    queryString += 'IN ';
    queryString += ':pMaxNameList ';
    List<cspmb__Price_Item__c> priceItemList = Database.query(queryString);
    for(cspmb__Price_Item__c priceItem : priceItemList) {
        codeNamePriceItemMap.put(priceItem.Maxim_Product_Name__c + priceItem.Product_Code__c, priceItem);
    }
    System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.createOLI.codeNamePriceItemMap' + codeNamePriceItemMap);
    //EDGE-13250
    //Retrieve all the OLI
    Id oppId = productBasket.cscfga__Opportunity__c;
    List<OpportunityLineItem> olilist = new List<OpportunityLineItem>();
    olilist = [
        SELECT id,
        Name,
        Description,
        New_Income_Revenue__c,
        Avg_Annualised_Revenue__c,
        Incremental_Revenue__c,Once_Off_Revenue__c,
        SRM__c,
        Recurring_Price__c,
        One_Off_Price__c,
        Quantity,
        UnitPrice,
        Product_Status__c,
        Product_Name__c,
        Product_Family__c,
        Product_Group__c,
        Ultimate_Product__c,
        OfferName__c,
        pricebookEntryId,
        OpportunityId,
        TotalPrice,
        cscfga__Attribute__c,
        cscfga__Attribute__r.name,
        cscfga__Attribute__r.cscfga__Product_Configuration__c,
        cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Price__c,
        cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c,
        cscfga__Attribute__r.cscfga__Product_Configuration__r.OfferName__c
        FROM OpportunityLineItem
        WHERE OpportunityId = :oppId
    ];
    System.debug(LoggingLevel.INFO, 'CustomButtonOpportunitySync.createOLI.olilist = ' + olilist);
    //Retrieve Fields from Custom Metadata type 'OpportunitySyncAttribute'
    List<OpportunitySyncAttribute__mdt> syncAttrList =  [
        SELECT DeveloperName, MasterLabel, Datatype__c
        FROM OpportunitySyncAttribute__mdt
    ];
    //Map Key Values of 'OpportunitySyncAttribute'
    Map<String,OpportunitySyncAttribute__mdt> syncattrMap = new Map<String,OpportunitySyncAttribute__mdt>();
    //Put Values from Map OpportunitySyncAttribute__mdt
    for(OpportunitySyncAttribute__mdt syc : syncAttrList) {
        syncAttrMap.put(syc.DeveloperName, syc);
    }
    // EDGE-131729 - Getting the list of IncrementaRevenue Attributes and their values on the Opportunity
    List<cscfga__Attribute_Field__c> attributeFieldList = [select id, cscfga__Attribute__c,  
                                                           cscfga__Value__c from cscfga__Attribute_Field__c 
                                                           where 
                                                           cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c =:oppId  
                                                           and name = 'IncrementalRevenue'];
    for(OpportunityLineItem oli : olilist) {
        isStatusWon = true;
        cscfga__Product_Configuration__c config = configMap.get(oli.cscfga__Attribute__r.cscfga__Product_Configuration__c);
        //Mapping Attributes values
        for(cscfga__Attribute__c attr : config.cscfga__Attributes__r) {
            if(syncAttrMap.containsKey(attr.Name) && attr.cscfga__Value__c != null) {
                if(syncAttrMap.get(attr.Name).Datatype__c== 'Decimal')
                    oli.put(syncAttrMap.get(attr.Name).MasterLabel,Decimal.valueOf(attr.cscfga__Value__c));
                else
                    oli.put(syncAttrMap.get(attr.Name).MasterLabel,attr.cscfga__Value__c);
            }
        }
        System.debug(LoggingLevel.INFO, 'createOLI.Product_Name__c = ' + oli.Product_Name__c);
        //Product Name popuation for Modular products EDGE-11104
        if(oli.Product_Name__c == null || oli.Product_Name__c == '')
            oli.Product_Name__c = oli.Description;
        //EDGE-20138
        if(oli.OfferName__c == 'Connected Workplace Package')
            oli.OfferName__c = 'Connected Workplace';
        //EDGE-13250
        if(oli.Product_Name__c != null && oli.Product_Code__c != null) {
            if(codeNamePriceItemMap.containsKey(oli.Product_Name__c+oli.Product_Code__c)) {
                oli.Product_Family__c = codeNamePriceItemMap.get(oli.Product_Name__c+oli.Product_Code__c).Product_Family__c;
                oli.Product_Group__c = codeNamePriceItemMap.get(oli.Product_Name__c+oli.Product_Code__c).Product_Group__c;
                oli.Ultimate_Product__c = codeNamePriceItemMap.get(oli.Product_Name__c+oli.Product_Code__c).Ultimate_Product__c;
            }
        }
        //EDGE-13250
        // EDGE-131729 - Getting the list of IncrementaRevenue Attributes and their values on the Opportunity in the MAP
        Map<String, String> incrementalRevenueMap = new Map<String, String>();
        for (cscfga__Attribute_Field__c attributeField : attributeFieldList ){
            //EDGE-131729 - Added Map as additional Paremeter in Method Call
            incrementalRevenueMap.put (attributeField.cscfga__Attribute__c, attributeField.cscfga__Value__c);
        }
        //CHanges End - 1317
        //EDGE-2756
        productType = OpportunityProductType.getProductTypeInstance(productBasket.cscfga__Opportunity__r.Product_Type__c);
        System.debug('productType = '+productType);
        if (null != productType){
            //Added for 131729 - The IncremetalRevenueMap needs to be sent only in case of Modular Basket
            oli = productType.updateOpportunityLineItem(oli,incrementalRevenueMap);
        }
            // EDGE-133414 - the below code should be run only for Non Modular
        if (! OpportunityProductType.isModularProductType (productBasket)) {  
        System.debug('oli.UnitPrice, oli.Qualnity' + oli.UnitPrice + ',' + oli.Quantity);
            //added 0 check by shubhi EDGE-142888
            if(oli.Quantity!=0)
        oli.UnitPrice = oli.UnitPrice/oli.Quantity;
            else
                oli.UnitPrice =0;
        }
    }
    upsert olilist;
}
public static String getQueryString(String tableName, List<String> listOfNames){
    List<String> names = listOfNames;
    String queryString = 'SELECT ';
    queryString += 'Id, ';
    queryString += 'APXTConga4__Name__c ';
    queryString += 'FROM ';
    queryString += tableName;
    queryString += ' WHERE ';
    queryString += 'APXTConga4__Name__c ';
    queryString += 'IN ';
    queryString += ':names ';
    queryString += 'ORDER BY ';
    queryString += 'APXTConga4__Name__c';
    return queryString;
}
public static Map<String,String> getTemplateId ( List<String> names, String flag ) {
    String queryString = CustomConstants.EMPTY;
    String recId = CustomConstants.EMPTY;
    Map<String,String> mapOfTemplates = null;
    if ( null != flag && flag.equalsIgnoreCase('template')) {
        queryString = getQueryString('APXTConga4__Conga_Template__c', names);
        List<APXTConga4__Conga_Template__c> templateIdList = Database.query(queryString);
        if ( !templateIdList.isEmpty() ) {
            mapOfTemplates = new Map<String, String>();
            for(APXTConga4__Conga_Template__c templateRecord : templateIdList) {
                if(templateRecord.Id != null ) {
                    recId = templateRecord.Id;
                    recId = recId.substring(0,recId.length() - 3);
                    mapOfTemplates.put(templateRecord.APXTConga4__Name__c,recId);
                }
            }
        }
    } else if ( flag.equalsIgnoreCase('query') ) {
        queryString = getQueryString('APXTConga4__Conga_Merge_Query__c', names);
        List<APXTConga4__Conga_Merge_Query__c> queryList = Database.query(queryString);
        if(!queryList.isEmpty()) {
            mapOfTemplates = new Map<String, String>();
            for(APXTConga4__Conga_Merge_Query__c record : queryList) {
                if(record.Id != null) {
                    recId = record.Id;
                    recId = recId.substring(0,recId.length() - 3);
                    mapOfTemplates.put(record.APXTConga4__Name__c,recId);
                }
            }
        }
    }
    return mapOfTemplates;
}
}