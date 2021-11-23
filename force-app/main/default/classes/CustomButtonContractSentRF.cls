/************************************************************************
Name: CustomButtonContractSent
Description: Invokes Contract generation, sync logic and validates basket.
Revisions:
RaviTeja:             24-09-2019:    EDGE-111290: Enable checks for Contract if SOW related offers are in the basket
Antun Bartonicek:     11/11/2019,    EDGE-117966 (Parallel MACD validations)
Tejes Mahajan (Napier Team):         EDGE-129011 checks if sufficient OneFund balance is available
Romil Anand           02/04/2020     EDGE-141820 (EAP discount end date validation)
Shubhi                01/07/2020     EDGE-147513    BillingAcc check
Kamlesh               25/09/2020     EDGE-176216 Rfactoring for first checking required validation for contract and than doing dml
Shweta Mamadapure     26/09/2020     EDGE-179488 Refactoring dml logic
Pooja Gupta           05/01/2021     EDGE-191824 - PONR Check before initiating Contract/Skip Contract/Quote
Gunjan Aswani         07/01/2021     EDGE-192931 - Stop sync process for Quote/Contract/Skip Contract

Gokul          23/02/21  EDGE-195270 - Added Opportunity_Type__c in basket Query
Payal                26/04/21    EDGE-216620 - Updated Attribute name "billingAccountLookup" in config query
Purushottama Sahu    08/09/2021      DIGI-16205 - Stop Contract Generation for Insolvency Cancellation 
Radhika 			20/09/2021		DIGI-931		Added field cscfga__Product_Definition__r.product_Specification__c in cscfga__Product_Configuration__c query
************************************************************************/

global with sharing class CustomButtonContractSentRF extends csbb.CustomButtonExt {
    public String agreementGenerationFlag = '';
    public static boolean isSQQualified = false;
    public static Map<String, Sync_Control_and_Constants__c> syncConstMap;
    public string performAction(String basketId) {
        
        
        String basketIdNew = basketId;//EDGE-183465 added by Abhishek from Osaka Team
        String response = '';
        syncConstMap = Sync_Control_and_Constants__c.getAll();
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Basket__c productBasket = new cscfga__Product_Basket__c();
        //productBasket = ProductUtil.getBasket(basketId);
        
        //queryString commented as a part of fix from Istanbul Team(Kamlesh Kumar) to resolve P1 deployment issue as a part of EDGE-183465
        /*String queryString = 'select cscfga__Opportunity__c,cscfga__Opportunity__r.AccountId,id,cscfga__Opportunity__r.Basket_Redemption_amount__c, Name,csbb__Account__c, cscfga__Opportunity__r.Owner.Email,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.OwnerId,Maxim_Opportunity_ID__c,Customer_Request_Date__c,cscfga__Basket_Status__c,csbb__Account__r.OwnerId,csbb__Account__r.Name,csbb__Account__r.Owner.Name,csbb__Account__r.Owner.Email,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c' +',cscfga__total_contract_value__c'+
',cscfga__Opportunity__r.Model_Change__c,Express_Flow__c,csordtelcoa__Change_Type__c,cscfga__pricing_status__c  from cscfga__Product_Basket__c where id =:basketId';                                             //\'' + String.escapeSingleQuotes(basketId) + '\''; // Sr. No 1 ////updated query for edge 81113  // updated query for EDGE-147513

productBasket = Database.query(queryString);*/
        //EDGE-195270 - Added Opportunity_Type__c in basket Query
        if(basketId != null){

           productBasket = [select cscfga__Opportunity__c,Opportunity_Type__c,cscfga__Opportunity__r.AccountId,id,cscfga__Opportunity__r.isInsolvencyCancel__c,cscfga__Opportunity__r.Basket_Redemption_amount__c, Name,csbb__Account__c, cscfga__Opportunity__r.Owner.Email,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__r.Product_Type__c,cscfga__Opportunity__r.OwnerId,Maxim_Opportunity_ID__c,Customer_Request_Date__c,cscfga__Basket_Status__c,csbb__Account__r.OwnerId,csbb__Account__r.Name,csbb__Account__r.Owner.Name,csbb__Account__r.Owner.Email,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c,cscfga__total_contract_value__c
                             ,cscfga__Opportunity__r.Model_Change__c,Express_Flow__c,csordtelcoa__Change_Type__c,cscfga__pricing_status__c, recordType.Name,Primary_Basket__c  from cscfga__Product_Basket__c where id =:basketId];//added recordType.Name in the query as part of EDGE-191824

        }
        
        //EDGE-191824 start
        string res = ValidationsForBasketOperations.CheckPONRforServices(productBasket);
        if(res!= null && !res.containsIgnoreCase('ok')){
                return '{"status":"error","text":"' + Label.Order_has_reached_PONR + '"}';
        }
        //String redirectURL = '/apex/c__PONRValidationBeforeContractCreation?';
        //return '{"displayInDialog":true,"size":"s","modalTitle":"PONR Status Check", "redirectURL":"' + redirectURL + '", "status":"ok","text":"Sync Status"}';       
        //EDGE-191824 end
        
        String accOwnerId = productBasket.csbb__Account__r.OwnerId;
        String oppOwnerId = productBasket.cscfga__Opportunity__r.OwnerId;
        String loggeduserId = UserInfo.getUserId();
        //EDGE-192931 - In-Flight : Stop sync process for Quote/Contract/Skip Contract added recordTypeName != 'Inflight Change'- By Gunjan
        String recordTypeName = productBasket.recordType.Name;
        configList = [
            SELECT
            Id,
            Name,
            Marketable_Offer__r.name,
            Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c, //EDGE-202824
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

        //DIGI-16205 start - added by Purushottam from Alexanrdia
		Boolean isInsolvencyCancel = productBasket.cscfga__Opportunity__r.isInsolvencyCancel__c ;
        if(isInsolvencyCancel){
            productBasket.csordtelcoa__Basket_Stage__c =CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c; 
            productBasket.csordtelcoa__Synchronised_with_Opportunity__c = true;
            productBasket.csbb__Synchronised_with_Opportunity__c = true;
            productBasket.Primary_Basket__c = true;
            update productBasket; 
            return '{"status":"ok","text":"Product basket contract stage is bypassed for insolvency cancellation scenario"}';
        }
        //DIGI-16205 end
        
        //Performing Validations
        //EDGE-183465 added by Abhishek from Osaka Team Start
        String serviceResponse = contractServiceValidation(basketIdNew);

        if(!String.isBlank(serviceResponse)){
            return serviceResponse;
        }
        //EDGE-183465 added by Abhishek from Osaka Team End
        ValidationsForBasketOperations valdBasketOps = new ValidationsForBasketOperations();
        response = valdBasketOps.performValidation(productBasket, configList, 'Contract');
        
        //Performing Basket Sync/Unsync Operation
        // On Validation "error"->  Basket is desynced and validation error message is shown to the user
        // On Validation "ok"   ->  Basket is desynced to delete OLI's, resyncing and checking primary basket flag to create new OLI's, update parent Opportunity Details, desync the the other baskets(if any) related with the same parent opportunity.
        AfterValidationSyncOperations syncBasketOps = new AfterValidationSyncOperations(productBasket);
        Environment_Configurations__c ecCusSetting = Environment_Configurations__c.getInstance(UserInfo.getUserId()); // Custom setting used to disable all the validation rules for the current running user.
        if (ecCusSetting.No_Validations__c == false) {
            ecCusSetting.No_Validations__c = true;
            upsert ecCusSetting;
        }
        if (response.contains('error')) {
            syncBasketOps.performBasketUnsync();
             //EDGE-202824 Start : Added by Purushottam to Validate Partner
            if(response.contains('isValidPartner')){
                response='{"status":"ok","text":"This basket has been sent for CE review as there is another active Partner of Record agreement in place"}';
            }
             //EDGE-202824 End
        } else {
            response = syncBasketOps.performBasketUnsync();
            if (response.contains('ok')) {
                try {
                    agreementGenerationFlag = EnvironmentVariable__c.getValues('AgreementGeneration').Value__c;
                    if (agreementGenerationFlag == 'true' && CustomConfigurationOptions__c.getValues('ContractInitiate')!=null) {
                        CALMSDataPush dataPush = new CALMSDataPush();
                        dataPush.pushData(productBasket.Id);
                        productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c;
                        //EDGE-192931 - In-Flight : Stop sync process for Quote/Contract/Skip Contract added recordTypeName != 'Inflight Change' By Gunjan
                        System.debug(' >>> recordTypeName >>> Value= ' + recordTypeName);
                        if (recordTypeName != 'Inflight Change' ){
                            productBasket.csordtelcoa__Synchronised_with_Opportunity__c = true;
                            productBasket.csbb__Synchronised_with_Opportunity__c = true;
                            productBasket.Primary_Basket__c = true;
                            System.debug('Inside >>> recordTypeName not equals Inflight Change');
                        }
                        try{
                            System.debug(' >>>recordTypeName'+ productBasket.csordtelcoa__Synchronised_with_Opportunity__c + ' ANDD ' +   productBasket.csbb__Synchronised_with_Opportunity__c + ' ANDD ' +  productBasket.Primary_Basket__c );
                            update productBasket; 
                        }catch(Exception e)
                        {
                            String displayMessage = e.getMessage();
                            return '{"status":"error","text":" Error: ' + displayMessage + '"}';
                        }
                        
                    } else {
                        //productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c;
                        //EDGE-192931 - In-Flight : Stop sync process for Quote/Contract/Skip Contract added recordTypeName != 'Inflight Change'
                        if (recordTypeName != 'Inflight Change' ){
                        productBasket.csordtelcoa__Synchronised_with_Opportunity__c = true;
                        productBasket.csbb__Synchronised_with_Opportunity__c = true;
                        productBasket.Primary_Basket__c = true;
                        System.debug('Inside ELSE>>> recordTypeName not equals Inflight Change');
                       }else{
                            System.debug('Outside ELSE>>>recordTypeName equals to Inflight Change');
                       }
                        try{
                            System.debug(' >>>recordTypeName ELSE'+ productBasket.csordtelcoa__Synchronised_with_Opportunity__c + ' ANDD ' +   productBasket.csbb__Synchronised_with_Opportunity__c + ' ANDD ' +  productBasket.Primary_Basket__c );
                            update productBasket; 
                        }catch(Exception e)
                        {
                            String displayMessage = e.getMessage();
                            return '{"status":"error","text":" Error: ' + displayMessage + '"}';
                        }
                        //GenerateContract genContract = New GenerateContract();
                        //map<string, Id> ContractSignatories = new map<string, Id>();
                        //response = genContract.createContract(productBasket.Id, ContractSignatories, 'basket');
                        /*--- EDGE-81600 --*/
                        if (EnvironmentVariable__c.getValues('CheckTramasResponseValid').Value__c == 'true') {
                            if (isTramasResponseValid(basketId, '') != true && syncConstMap.get('TramasResponseMsg')!=null)
                                return '{"status":"error","text":"' + syncConstMap.get('TramasResponseMsg').value__c + '"}';
                        }
                        /*------EDGE-43747 , EDGE-43745---------------*/
                        Integer cancelAndPureModifyOrderFlag = cancelAndPureModifyOrderCounterSignDisplay(productBasket.id);
                        String display = '';
                        if (cancelAndPureModifyOrderFlag == 1) {
                            display = EncodingUtil.urlEncode('None', 'UTF-8');
                        } else if (cancelAndPureModifyOrderFlag == 2) {
                            display = EncodingUtil.urlEncode('PureModify', 'UTF-8');
                        }
                        
               
    
                // --EDGE-191773 | Maq |Tech Story : <Identify if variation is required and Delta identification 
                        
                        String modalTitle = 'Assign Contract Signatories';
                        // String modalTitle = 'Assign Contract Signatories';
                        /* String ShowURL = '/apex/c__ContractSignatoriesSetup?basketId='+productBasket.id+'&basketName='+productBasket.Name+'&AccountName='+productBasket.csbb__Account__r.Name+'&AccountOwnerId='+accOwnerId+'&AccountOwnerName='+productBasket.csbb__Account__r.Owner.Name+'&AccountId='+productBasket.csbb__Account__c+'&isdtp=vw'; */
                        //  String encAccountName = EncodingUtil.urlEncode(productBasket.csbb__Account__r.Name,'UTF-8');
                        String encbasketId = EncodingUtil.urlEncode(productBasket.id, 'UTF-8');
                        String encbasketName = EncodingUtil.urlEncode(productBasket.Name, 'UTF-8');
                        String encAccountName = EncodingUtil.urlEncode(productBasket.csbb__Account__r.Name, 'UTF-8');
                        String encAccountOwnerId = EncodingUtil.urlEncode(accOwnerId, 'UTF-8');
                        String encAccountOwnerName = EncodingUtil.urlEncode(productBasket.csbb__Account__r.Owner.Name, 'UTF-8');
                        String encAccountOwnerEmail = '';
                        if (productBasket.csbb__Account__r.Owner.Email != null) {
                            encAccountOwnerEmail = EncodingUtil.urlEncode(productBasket.csbb__Account__r.Owner.Email, 'UTF-8');
                        } else {
                            encAccountOwnerEmail = EncodingUtil.urlEncode('test@team.telstra.com', 'UTF-8');
                        }
                        String encAccountId = EncodingUtil.urlEncode(productBasket.csbb__Account__c, 'UTF-8');
                        /*-- EDGE-66515 :  Default contract recipient as Order requestor for Modify and Cancel orders --*/
                        String encOppId = EncodingUtil.urlEncode(productBasket.cscfga__Opportunity__c, 'UTF-8');
                        /*------ EDGE-76151 ----------------*/
                        String adboreIdCount = EncodingUtil.urlEncode(String.valueOf(countAdborId(productBasket.id, productBasket.csbb__Account__c)), 'UTF-8');
                        /*  String ShowURL = '/apex/c__ContractSignatoriesSetup?basketId='+productBasket.id+'&basketName='+productBasket.Name+'&AccountName='+productBasket.csbb__Account__r.Name+'&AccountOwnerId='+accOwnerId+'&AccountOwnerName='+productBasket.csbb__Account__r.Owner.Name+'&AccountOwnerEmail='+productBasket.csbb__Account__r.Owner.Email+'&AccountId='+productBasket.csbb__Account__c+'&isdtp=vw';
return '{"displayInDialog":true, "size":"m","modalTitle": "' + modalTitle +'", "redirectURL":"' + ShowURL +'", "status":"ok","text":"Select Signatories"}';  */
                        String ShowURL =
                            '/apex/c__ContractSignatoriesSetup?basketId=' +
                            encbasketId +
                            '&basketName=' +
                            encbasketName +
                            '&AccountName=' +
                            encAccountName +
                            '&AccountOwnerId=' +
                            encAccountOwnerId +
                            '&AccountOwnerName=' +
                            encAccountOwnerName +
                            '&AccountOwnerEmail=' +
                            encAccountOwnerEmail +
                            '&AccountId=' +
                            encAccountId +
                            '&OppId=' +
                            encOppId +
                            '&adboreIdCount=' +
                            adboreIdCount +
                            '&cancelOrderVar=' +
                            display +
                            '&isdtp=vw';
                        /*  if(isSQQualified){
return '{"displayInDialog":true, "size":"m","modalTitle": "' + modalTitle +'", "redirectURL":"' + ShowURL +'", "status":"ok","text":"Site service qualification complete"}';                             
} */
                        return '{"displayInDialog":true, "size":"m","modalTitle": "' +
                            modalTitle +
                            '", "redirectURL":"' +
                            ShowURL +
                            '", "status":"ok","text":"Select Signatories"}';
                        /*--------------------------------------------*/
                    }
                    
                } catch (DMLException e) {
                    if(syncConstMap.get('Contract_Initiated_Failed')!=null){
                        return '{"status":"error","text":"' + syncConstMap.get('Contract_Initiated_Failed').value__c + '"}';
                    }
                }
                OpportunitySyncUtil.updateOpptInfo(productBasket, 'ContractInitiate');
                //Id userId = UserInfo.getProfileId();
                // List<Profile> profileList = [Select Name from Profile where Id =: userId];
                // system.debug('Profile name ' + profileList[0].Name);
                PageReference ref = null;
                if (agreementGenerationFlag == 'true') {
                    ref = new PageReference('/' + productBasket.id);
                } else {
                    //ref = new PageReference('/apex/c__NewBasketOverrideRedirectPage?id=' + productBasket.id);
                    ref = new PageReference('/' + response);
                }
                ref.setRedirect(true);
                if(syncConstMap.get('ContractInitiatedSuccessfully')!=null){
                    return '{"status":"ok","text":"' + syncConstMap.get('ContractInitiatedSuccessfully').value__c + '", "redirectURL":"' + ref.getUrl() + '"}';
                }
            } else if (!response.contains('null')) {
                return '{"status":"error","text":"'+syncBasketOps.syncMsg+'"}';
            } else {
                if(syncConstMap.get('Contract_Initiated_Failed')!=null){
                    return '{"status":"error","text":"' + syncConstMap.get('Contract_Initiated_Failed').value__c + '"}';
                }
            }
        }
        if (ecCusSetting.Id != null && ecCusSetting.No_Validations__c == true) {
            //After Basket sync, enable the validation rules for the current running user.
            ecCusSetting.No_Validations__c = false;
            update ecCusSetting;
        }
        return response;
    }
    
    //Defect EDGE-116355 : Modified condifiton to query PCs from basket
    public static Integer cancelAndPureModifyOrderCounterSignDisplay(String basketId) {
        Integer disabled = 0;
        //EDGE-76402 made changes in condition to handle Pure Modify case
        if (basketId != null) {
            Integer modifycount = 0;
            Integer cancelcount = 0;
            Integer newCount = 0;
            //  EDGE-79676 - Added mobility clause
            for (cscfga__Product_Configuration__c prloop : [
                SELECT id, type__c, csordtelcoa__Replaced_Product_Configuration__c
                FROM cscfga__Product_Configuration__c
                WHERE cscfga__Product_Basket__c = :basketId AND cscfga__Root_Configuration__c = NULL AND ConfigurationType1__c != 'SolutionComponent'
            ]) {
                if (prloop.Type__c == 'Cancel' && prloop.csordtelcoa__Replaced_Product_Configuration__c != null) {
                    cancelcount = cancelcount + 1;
                } else if (prloop.Type__c == 'Modify' && prloop.csordtelcoa__Replaced_Product_Configuration__c != null) {
                    modifycount = modifycount + 1;
                } else if (prloop.Type__c == 'New' && prloop.csordtelcoa__Replaced_Product_Configuration__c == null) {
                    newCount += 1;
                }
            }
            if (cancelcount > 0 && modifycount == 0 && newCount == 0)
                disabled = 1;
            else if (cancelcount == 0 && modifycount > 0 && newCount == 0)
                disabled = 2;
        }
        return disabled;
    }
    
    /* ****************************************************************************
* Author : Manoj Kumar : EDGE-66038
* Date : 18 March 2019
* Description :Calculate the set of adborid's of PC : IPSite
* Parameters : String BasketId
* Return type : Integer
* *****************************************************************************/
    public static Integer countAdborId(String basketId, String AccountId) {
        List<String> adborId_List = new List<String>();
        List<String> qualifiedAdborId_List = new List<String>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        cscfga__Product_Basket__c prdBasket = ProductUtil.getBasket(basketId);
        String accId = prdBasket.csbb__Account__c;
        //System.debug('AccountId : ' + AccountId);
        SiteSQContractCallout stCallout = new SiteSQContractCallout();
        // EDGE-88536 : Added Type__c in where clause : Manoj Kumar
        List<cscfga__Product_Configuration__c> prdConfList = [
            SELECT id, Name, type__c, Technology_Type__c, (SELECT id, name, cscfga__Value__c FROM cscfga__Attributes__r WHERE Name = 'AdborID')
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c = :basketId AND Name = 'IP Site' AND Technology_Type__c = 'NBN Access' AND Type__c = 'New'
        ];
        if (!prdConfList.IsEmpty()) {
            for (cscfga__Product_Configuration__c pcRec : prdConfList) {
                if (!pcRec.cscfga__Attributes__r.IsEmpty()) {
                    attrList.add(pcRec.cscfga__Attributes__r);
                }
            }
            for (cscfga__Attribute__c att : attrList) {
                if (att.cscfga__Value__c != null) {
                    adborId_List.add(att.cscfga__Value__c);
                }
            }
            if (!adborId_List.IsEmpty()) {
                qualifiedAdborId_List = stCallout.getConfigurableAddressIdList(adborId_List, AccountId);
                return qualifiedAdborId_List.Size();
            }
        }
        return 0;
    }
    
    /* ****************************************************************************
* Author : Robin Chawla : EDGE-88535
* Date : 07 June 2019
* Description : Show error if the TRAMAS response if not valid
* Parameters : String BasketId
* Return type : Boolean
* *****************************************************************************/
    public static Boolean isTramasResponseValid(String basketId, String accountId) {
        List<TransitionDataDTO.productListDTO> productDTOList = new List<TransitionDataDTO.productListDTO>();
        List<TransitionDataDTO.SiteDTOMobile> siteDTOList = new List<TransitionDataDTO.SiteDTOMobile>();
        List<TransitionDataDTO.serviceListDTOMobile> serviceDTOList = new List<TransitionDataDTO.serviceListDTOMobile>();
        List<TransitionDataDTO.groupDTOMobile> groupDTOList = new List<TransitionDataDTO.groupDTOMobile>();
        List<TransitionDataDTO.serviceDTOMobile> mobileDTOList = new List<TransitionDataDTO.serviceDTOMobile>();
        List<TransitionDataDTO.groupDTOMobile> mobileCheckValueList = new List<TransitionDataDTO.groupDTOMobile>();
        Boolean isValidResponse = true;
        //Get all PCR corresponds to that basket having name IP Site
        List<Id> pcIds = new List<Id>();
        //EDGE-80772 : Updated query for Solution Console retrofit
        for (cscfga__Product_Configuration__c pc : [SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId]) {
            pcIds.add(pc.id);
        }
        //Getting TransitionJSONData.json attachments and parsing it
        List<ReplicatorGetServiceDataObject_V2> TransitionJSONList = new List<ReplicatorGetServiceDataObject_V2>();
        List<TransitionDataDTO> TransitionJsonDataList = new List<TransitionDataDTO>();
        for (Attachment attachments : [
            SELECT id, body, name, parentid
            FROM Attachment
            WHERE ParentId IN :pcIds AND (Name = 'TransitionJSONData.json' OR Name = :system.label.NgUcTransitionName)
        ]) {
            if (attachments.name == 'TransitionJSONData.json') {
                TransitionJSONList.add(ReplicatorGetServiceDataObject_V2.parse(attachments.body.toString()));
            } else if (attachments.name == system.label.NgUcTransitionName) {
                TransitionJsonDataList.add(TransitionDataDTO.parse(attachments.body.toString()));
            }
        }
        if (!TransitionJSONList.isEmpty()) {
            List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteList = new List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();
            for (ReplicatorGetServiceDataObject_V2 data : TransitionJSONList) {
                siteList.addAll(data.site);
            }
            if (!siteList.isEmpty()) {
                List<ReplicatorGetServiceDataObject_V2.productListDTO> productList = new List<ReplicatorGetServiceDataObject_V2.productListDTO>();
                for (ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site : siteList) {
                    productList.addAll(site.productList);
                }
                if (!productList.isEmpty()) {
                    // return false if non eligible status found
                    for (ReplicatorGetServiceDataObject_V2.productListDTO products : productList) {
                        if (products.eligibilityStatus != 'Eligible' && products.checkValue == true) {
                            return false;
                        }
                    }
                }
            }
        }
        
        if (!TransitionJsonDataList.isEmpty()) {
            for (TransitionDataDTO transitionDTO : TransitionJsonDataList) {
                productDTOList.addAll(transitionDTO.productList);
            }
            if (!productDTOList.isEmpty()) {
                for (TransitionDataDTO.productListDTO product : productDTOList) {
                    siteDTOList.addAll(product.site);
                }
            }
            if (!siteDTOList.isEmpty()) {
                for (TransitionDataDTO.SiteDTOMobile site : siteDTOList) {
                    serviceDTOList.addAll(site.serviceList);
                }
            }
            if (!serviceDTOList.isEmpty()) {
                for (TransitionDataDTO.serviceListDTOMobile service : serviceDTOList) {
                    groupDTOList.addAll(service.groupType);
                }
            }
            if (!groupDTOList.isEmpty()) {
                for (TransitionDataDTO.groupDTOMobile groupMob : groupDTOList) {
                    if (groupMob.checkValue == true) {
                        mobileCheckValueList.add(groupMob);
                    }
                }
            }
            if (!mobileCheckValueList.isEmpty()) {
                for (TransitionDataDTO.groupDTOMobile gp : mobileCheckValueList) {
                    mobileDTOList.addAll(gp.service);
                }
            }
            if (!mobileDTOList.isEmpty()) {
                for (TransitionDataDTO.serviceDTOMobile mobile : mobileDTOList) {
                    if (mobile.Eligibility_status != 'Eligible') {
                        return false;
                    }
                }
            }
        }
        // if all products eligible or if no TransitionJSONData.json found (in case of new order) or if  TransitionJSONData.json
        // found with empty product list (in case of no legacy products) return true
        return isValidResponse;
    }
    /************************************************************************
Name: contractServiceValidation
Description: Invokes validation after clicking on QUote button..
Story : EDGE-183465
Developer: Abhishek Osaka Team
Description: This method Invokes validations related to services and its associated add-ons
************************************************************************/
    public static String contractServiceValidation(String basketId){
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
            //START: Added Product_End_Date__c for EDGE-215103    
            addOnRecList = [Select id,status__c,Legacy_Service__r.select__c,Product_End_Date__c from service_add_on__c where Legacy_Service__r.Id in :legacyId];
            //END for EDGE-215103    
            for(service_add_on__c addOnRecords : addOnRecList){
                if(addOnRecords.Legacy_Service__r.select__c == false && addOnRecords.status__c == 'Sync Removal Pending'){
                    addOnRecNotSelected.add(addOnRecords);
                }
                //START: Added check for Product_End_Date__c for EDGE-215103    
                else if(addOnRecords.Legacy_Service__r.select__c == true && addOnRecords.status__c != 'Sync Completed' && addOnRecords.Product_End_Date__c > Date.today().addDays(Integer.valueOf(System.Label.ProductRemainingEndDays))) {
                    addOnRecSelected.add(addOnRecords);
                }
                //END for EDGE-215103    
            }      
            System.debug('Selected::'+addOnRecSelected);
            System.debug('Unselected::'+addOnRecNotSelected);
            
            if(!addOnRecSelected.isEmpty() || !addOnRecNotSelected.isEmpty()){
                validationMessage =  '{"status":"error","text":"' + System.Label.Contract_Add_On_Error + '"}';                    
            }     
        }
        return validationMessage;
    }

}