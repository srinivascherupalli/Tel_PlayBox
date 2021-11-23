/*****************************************
S.No    Date              Modified by     Change Description
1 .     22-09-2019 .      Venkat .       Added check for Number reservation relaxation for NgUC MTS - EDGE 114158
******************************************/

public with sharing class NumberManagementController {
    public Boolean isNumberAvailable{get;set;}  //variable to be used for rendering time
    public Integer quantity {get;set;}
    public String pattern {get; set;}
    public String adborId {get; set;}
    public List<String> fnnList {get; set;}
    public List<String> reservedFnnList {get;set;}
    public List<OrderSummary> orderSummaryList {get;set;}
    public List<OrderSummary> finalOrderSummaryList{get;set;}
    public String selectedSite {get;set;}
    public boolean test{get; set;}
    public Boolean  fnnFlag{get; set;}
    public string errorMessage{get;set;}
    public String erroredOut{get;set;}
    public boolean isFNNReserved{get;set;}
    public String unreserveMessage{get;set;}
    public String basketId {get;set;}
    public String rootConfigId {get;set;}
    public String contextName {get;set;}
    public Boolean esaDisabled{get;set;}
    public String selectedPatternType{get;set;}
    public String resrvedNumberGreaterThanUsers{get;set;}
    public List<String> activeNumbersList {get;set;}
    public List<String> activeNumbersListCollap {get;set;}
    public List<String> transitionNumbersList {get;set;}
    public List<String> transitionRangeNumbersList {get;set;}
    public List<String> transitionFnnNumbersList {get;set;}
    public List<String> reservedNumbersList {get;set;}
    public List<wrapReservedNumbers> ReservedNumbersListWrap {get;set;}
    public boolean viewSearchPanel{get;set;}
    public Integer totalUsers{get;set;}
    public boolean displayNumberSearch{get;set;}
    public Integer totalUserQtyfromUCE{get;set;}
    public boolean unreserve{get;set;}
    public boolean unreserveNumbers{get;set;}
    public List<wrapReservedNumbers> wrapAllReservedNumbers {get; set;}
    public List<String> selectedReservedNumbers{get;set;}
    public Boolean enableUnreserve{get;set;}
    public Boolean SuccessUnreserved{get;set;}
    public Boolean FailedUnreserved{get;set;}
    public Boolean disableUnreserve{get;set;}
    public Boolean displayErrorPanel{get;set;}
    public String PanelMessage{get;set;}
    public String cssClassForPanelMSgs{get;set;}
    public String cssClassForUnreservePanelMsgs{get;set;}
    public String UnreservePanelMessage{get;set;}
    public Boolean disableSrcPattern{get;set;}
    public String introduceUnreserve{get;set;}
    public String totalReservedNumber{get;set;}
    public Integer totalReservedNumberInt{get;set;}
    public Boolean isReservedCollapsed{get;set;}
    public String colReserveValue{get;set;}
    public Boolean isActiveCollapsed{get;set;}
    public String activePanelLabel{get;set;}
    public Boolean isTransitionCollapsed{get;set;}
    public Boolean isCancelOrder{get;set;}
    
    public String ReservedNumbersData {get;set;}
    // RPL Changes for ngUC - 24-Jun-2019    
    public Boolean isTCPresent{get;set;}
    List<wrapReservedNumbers> resrvNumbers = new List<wrapReservedNumbers>();
    public NumberManagementController(){
        test = false;
        totalReservedNumber = '0';
        colReserveValue='+';
        activePanelLabel='- Active Numbers';
        isReservedCollapsed = false;
        isActiveCollapsed = false;
        isTransitionCollapsed = false;
        totalReservedNumberInt = 0;
        introduceUnreserve= 'slds-size_1-of-4';
        disableSrcPattern = true;
        cssClassForPanelMsgs = 'slds-notify slds-notify_toast slds-theme_error';
        displayErrorPanel = true;
        disableUnreserve =  true;
        unreserveMessage = '';
        fnnFlag =  true;
        FailedUnreserved= false;
        SuccessUnreserved = false;
        enableUnreserve = false;
        unreserve =  false;
        unreserveNumbers = false;
        displayNumberSearch = true;
        viewSearchPanel = false;
        isCancelOrder = false;
        isTCPresent = false; //RPL Changes for ngUC - 24-Jun-2019
        transitionNumbersList = new List<String>();
        wrapAllReservedNumbers = new List<wrapReservedNumbers>();
        resrvNumbers = new List<wrapReservedNumbers>();
        transitionFnnNumbersList = new List<STring>();
        transitionRangeNumbersList = new List<String>();
        activeNumbersList = new List<String>();
        
        
        reservedNumbersList = new List<String>();
        resrvedNumberGreaterThanUsers = 'false';
        totalUserQtyfromUCE = 0;
        String unescapedBasketId = ApexPages.currentPage().getParameters().get('basketId');
        String unescapedConfigId = ApexPages.currentPage().getParameters().get('configId');
        //String unescapedcontextName  = ApexPages.currentPage().getParameters().get('contextName');
        System.debug('unescapedBasketId::'+ unescapedBasketId + '::unescapedConfigId::' + unescapedConfigId);
        //Assing the subscription Id and operation to the global variables
        //basketId = 'a3Q2O0000007HeCUAU';
        //rootConfigId = 'a3T2O000000929dUAA';
        basketId = EncodingUtil.urlEncode(unescapedBasketId,'UTF-8');
        rootConfigId = EncodingUtil.urlEncode(unescapedConfigId,'UTF-8');
        //contextName = EncodingUtil.urlEncode(unescapedcontextName,'UTF-8');
        System.debug('basketId::'+ basketId + '::rootConfigId::' + rootConfigId);
        esaDisabled = true;
        isNumberAvailable =false;
        errorMessage = '';
        erroredOut = 'false';
        Map<String,List<String>> reservedNumbersMap = new Map<String,List<String>>();
        NumberNCSHelper ncs = new NumberNCSHelper();
        isFNNReserved = ncs.checkForExistingNCS(rootConfigId);
        System.debug('--Reserve Status :'+ isFNNReserved);
        if(isFNNReserved == true){
            reservedNumbersMap = ncs.getNumbersFromNCS(rootConfigId);
            
            reservedNumbersList = reservedNumbersMap.get('RESERVED');
            transitionNumbersList = reservedNumbersMap.get('IN TRANSITION');
            activeNumbersList = reservedNumbersMap.get('ACTIVE');
            
            if(transitionNumbersList != NULL)
                for(String fnn : transitionNumbersList){
                    if(fnn.contains(':')){
                        transitionRangeNumbersList.add(fnn);
                    }
                    else{
                        transitionFnnNumbersList.add(fnn);
                    }
                }
            
            if(reservedNumbersList != null)
                totalReservedNumberInt = totalReservedNumberInt + reservedNumbersList.size();
            if(transitionRangeNumbersList != null){
                Integer rangeNumbers=0;
                for(String splittedNumbers: transitionRangeNumbersList){
                    Double rangeFrom = Double.valueOf(splittedNumbers.trim().split(':')[0]);
                    Double rangeTo = Double.valueOf(splittedNumbers.trim().split(':')[1]);
                    rangeNumbers = rangeNumbers + Integer.ValueOf(rangeTo - rangeFrom + 1);
                }
                totalReservedNumberInt = totalReservedNumberInt + rangeNumbers;
            }
            
            if(transitionFnnNumbersList != null)
                totalReservedNumberInt = totalReservedNumberInt + transitionFnnNumbersList.size();
            if(activeNumbersList != null)
                totalReservedNumberInt = totalReservedNumberInt + activeNumbersList.size();
            
            totalReservedNumber = String.valueOf(totalReservedNumberInt);
            
            if(wrapAllReservedNumbers!= null)
                wrapAllReservedNumbers.clear();
            if(reservedNumbersList!=null && reservedNumbersList.size()>0){
                disableUnreserve = false;
                for(String nums : reservedNumbersList){
                    wrapAllReservedNumbers.add(new wrapReservedNumbers(nums));
                }
            }else{
                disableUnreserve = true;
            }
            resrvNumbers.addAll(wrapAllReservedNumbers);
            
            
            System.debug('activeNumbersList::' + activeNumbersList + ',transitionNumbersList::' + transitionNumbersList + ',reservedNumbersList::' + reservedNumbersList );
        }
        getbasketSummary();
        
        System.debug('resrvedNumberGreaterThanUsers '+resrvedNumberGreaterThanUsers);
        // System.debug('----'+orderSummaryList.size()+'-----'+reservedNumbersList.size());
        totalUsers = 0;
        for(OrderSummary ord:orderSummaryList) {
            System.debug('---OrderSummary----'+ord.total);
            totalUsers = totalUsers+ord.total;
        }
        //RPL Changes for ngUC: 20-jun-2019    
        System.debug('::isTCPresent'+isTCPresent);    
        if(quantity == null && isTCPresent){ // RPL Changes for ngUC    
            quantity= totalUsers;    
        }
        validateSiteWithUSersConsttructor();
        
        //System.debug('totalUsersConstr'+totalUsers+''+reservedNumbersList.size());
        /*if(reservedNumbersList != null && totalUsers<=reservedNumbersList.size()){
resrvedNumberGreaterThanUsers = 'true';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please note that required quantity of numbers have been reserved already'));
}else if(reservedNumbersList != null && totalUsers>reservedNumbersList.size()){
resrvedNumberGreaterThanUsers = 'false';
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Number reservation is partially completed. You may save and exit the process.'));
}*/
        
        if(resrvedNumberGreaterThanUsers == 'true'){
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_warning';
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please note that required quantity of numbers have been reserved already'));
            PanelMessage = 'Please note that required quantity of numbers have already been reserved, proceeding with excess numbers will result in adhoc allocation and unused numbers will be returned to the pool';
        }else if(isFNNReserved && resrvedNumberGreaterThanUsers == 'false'){
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_warning';
            PanelMessage = 'Number reservation is partially completed. You may save and exit the process and complete later';
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Number reservation is partially completed. You may save and exit the process.'));
        }else{
            displayErrorPanel = true;
            cssClassForPanelMsgs ='';
            PanelMessage = '';
        }
    }
    
    public List<SelectOption> getSiteList(){
        List<SelectOption> siteOptions = new List<SelectOption>();
        siteOptions.add(new SelectOption('none','--None--'));
        for(OrderSummary ord : orderSummaryList){
            //siteOptions.add(new SelectOption(ord.siteId,ord.siteName));
        }
        System.debug('siteOptions '+siteOptions);
        
        return siteOptions;
    }
    //----- DTO for Order Details
    public class OrderSummary{
        public String siteName {get;set;}
        public String siteID {get;set;}
        public String siteAddress {get;set;}
        public Integer totalfixedSeatCount {get;set;}
        public Integer totalfaxLineCount {get;set;}
        public String configId {get;set;}
        public Integer totalHuntGrpCount{get;set;}
        //RPL Changes for ngUC: adding user variable    
        public Integer totalUserCount{get;set;}
        public Integer totalAutoAttendantCount{get;set;}
        public Integer totalMBNCount{get;set;}
        public Integer total{get;set;}
    }
    
    //----- Get Basket Summary (SiteId, SiteName, SiteAddress, FixedSeat & FaxLine Count)
    private void getbasketSummary()
    {
        
        //selectedSite = '141300861';
        //String basketId = 'a3Q2O0000007HeCUAU';
        String seatName;
        String seatCount;
        Map<String,String> rootConfigMap = new Map<String,String>();
        Map<String,String> attrMap;
        Map<String,Map<String,String>> configAttrMap = new Map<String,Map<String,String>>();
        Map<Id,List<cscfga__attribute__c>> attributeMap = new Map<Id,List<cscfga__attribute__c>> ();
        
        orderSummaryList = new List<OrderSummary>();
        finalOrderSummaryList = new List<OrderSummary>();
        //List<cscfga__product_configuration__c> rootConfigList = [select id,name,type__c,cscfga__Product_Basket__c,cscfga__Product_Definition__c from cscfga__product_configuration__c where cscfga__Product_Basket__c =: basketId and cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductOffering_000304' and id = :rootConfigId and name like '%IP%']; 
        // RPL Changes for ngUC - 06/20/2019            
        List<cscfga__product_configuration__c> rootConfigList = [select id,name,type__c,cscfga__Product_Basket__c,cscfga__Product_Definition__c, cscfga__Parent_Configuration__r.Offername__c from cscfga__product_configuration__c where cscfga__Product_Basket__c =: basketId  AND id = :rootConfigId  AND 
                                                                 ((cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductOffering_000304' AND name like '%IP%') OR (cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductOffering_000323' AND name like '%Unified%'))];
        
        System.debug('rootConfigList::' + rootConfigList.size() + ' : ' + rootConfigList);
        for(cscfga__product_configuration__c rootConfig : rootConfigList){
            OrderSummary summary = new OrderSummary();
            summary.total = 0; 
            summary.configId = rootConfig.Id;
            orderSummaryList.add(summary);
            if(rootConfig.type__c == 'Cancel')
                isCancelOrder = true; 
            else
                isCancelOrder = false;
        }
        Map<Id,cscfga__product_configuration__c> userConfigListMap=new Map<Id,cscfga__product_configuration__c>();
        for(cscfga__product_configuration__c pc:[SELECT Id,Name,cscfga__Product_Basket__c,cscfga__Root_Configuration__c,Quantity_Product_Configuration__c FROM cscfga__product_configuration__c WHERE (cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000074' OR cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000324' OR cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000657' OR cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000656') AND cscfga__Root_Configuration__c=:rootConfigId]){
            userConfigListMap.put(pc.id,pc);
        }
        System.debug('userConfigListMap:::'+userConfigListMap);
        Map<String,cscfga__attribute__c> attrListMap = new Map<String,cscfga__attribute__c>();
        for(cscfga__attribute__c attr : [SELECT Id,Name,cscfga__Value__c,cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.cssdm__solution_association__r.Name FROM cscfga__attribute__c where cscfga__Product_Configuration__c IN: userConfigListMap.keySet() OR cscfga__Product_Configuration__c = :rootConfigId]){
            attrListMap.put(attr.Name,attr);
        }
        for(OrderSummary summary : orderSummaryList){
            //List<cscfga__product_configuration__c> userConfigList = [SELECT Id,Name,cscfga__Product_Basket__c,cscfga__Root_Configuration__c,Quantity_Product_Configuration__c FROM cscfga__product_configuration__c WHERE cscfga__Root_Configuration__c =: summary.configId AND (cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000074' OR cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000324')];
            //System.debug('userConfigList::' + userConfigList.size() + ' : '  + userConfigList);
            if(userConfigListMap.values() != null){
                for(cscfga__product_configuration__c userConfig : userConfigListMap.values()){
                    //Future story to get typeSelected from other custom field of Product Configuration, instead of splitting and trimming the name
                    //String typeSelected = userConfig.name.split('-')[1].trim();
                    if(userConfig.cscfga__Root_Configuration__c==summary.configId){
                        if(userConfig.Name.contains('Fixed Seat')){
                            //Please ensure proper type conversion of quantity
                            summary.totalfixedSeatCount = Integer.valueOf(userConfig.Quantity_Product_Configuration__c);
                        }else if(userConfig.Name.contains('Fax Line')){
                            //Please ensure proper type conversion of quantity
                            summary.totalfaxLineCount = Integer.valueOf(userConfig.Quantity_Product_Configuration__c);
                        }else if(userConfig.Name.contains('Hunt Group')){
                            summary.totalHuntGrpCount = Integer.valueOf(userConfig.Quantity_Product_Configuration__c);
                        }
                        // RPL Changes for ngUC - 06/20/2019    
                        else if(userConfig.Name.contains('User')){    
                            summary.totalUserCount = Integer.valueOf(userConfig.Quantity_Product_Configuration__c);    
                        }
                        else if(userConfig.Name.contains('Auto Attendant')){
                            summary.totalAutoAttendantCount = Integer.valueOf(userConfig.Quantity_Product_Configuration__c);    
                        }
                        else if(userConfig.Name.Contains('Main Business Number')){
                            summary.totalMBNCount = Integer.valueOf(userConfig.Quantity_Product_Configuration__c);    
                        }
                    }
                    
                }
            }
            
            // List<cscfga__attribute__c> attrList = [SELECT Id,Name,cscfga__Value__c,cscfga__Product_Configuration__c FROM cscfga__attribute__c WHERE cscfga__Product_Configuration__c =: summary.configId];
            // System.debug('attrList::' + attrList.size() + ' : '  + attrList);
            if(attrListMap.values() != null){
                for(cscfga__attribute__c attr : attrListMap.values()){
                    
                    //System.debug('attr: ' + attr.name);
                    
                    if(attr.cscfga__Product_Configuration__c == rootConfigId){
                        if(attr.name.contains('Site Name')){
                            summary.siteName = attr.cscfga__Value__c;
                            
                        }
                        else if(attr.name.contains('Offer Name')){ // RPL Changes for ngUC  - 06/20/2019  
                            summary.siteName = attr.cscfga__Value__c;    
                            // RPL Changes for ngUC - 24-Jun-2019    
                            if(summary.siteName != null && summary.siteName == 'Telstra Collaboration'){    
                                isTCPresent = true;    
                            }    
                            
                        }
                        else if(attr.cscfga__Product_Configuration__r.cssdm__solution_association__r.Name != null && attr.cscfga__Product_Configuration__r.cssdm__solution_association__r.Name.contains('Telstra Collaboration')){
                             isTCPresent = true;  
                        }
                        if(attr.name.contains('AdborID')){
                            summary.siteId = attr.cscfga__Value__c;
                            selectedSite = summary.siteId;
                            
                            System.debug('AdborID: ' + selectedSite);
                        }               
                    }
                    
                }
            }
            
            if(summary.totalfixedSeatCount != NULL){summary.total = summary.totalfixedSeatCount;}
            if(summary.totalfaxLineCount != NULL){summary.total += summary.totalfaxLineCount;}
            if(summary.totalHuntGrpCount != NULL){summary.total += summary.totalHuntGrpCount;}
            // RPL Changes for ngUC - 06/20/2019    
            if(summary.totalUserCount != NULL){summary.total += summary.totalUserCount;}
            if(summary.totalAutoAttendantCount != NULL){summary.total += summary.totalAutoAttendantCount;}
            if(summary.totalMBNCount != NULL){summary.total += summary.totalMBNCount;}
            
        }
        System.debug('orderSummaryList::' + finalOrderSummaryList);
    }
    
    
    //----- Search FNN API Call
    public void searchFNN(){
        
        // selectedSite = '50789509';
        
        System.debug('selectedSite:'+selectedSite);
        viewSearchPanel = true;
        SuccessUnreserved = false;
        FailedUnreserved = false;
        if(fnnList!= null)
            fnnList.clear();
        if(quantity== null){
            errorMessage = 'Quantity Cannot be empty. Please populate quantity field';
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
        }else if(Quantity <= 0 ||  quantity > 50){
            errorMessage = 'Please make sure quantity is in the range 1 - 50 ';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
        }else if(selectedPatternType.equalsIgnoreCase('Equals' ) && pattern!=null && !(pattern.length()==9)){
            errorMessage = 'For pattern type \'Equals\' 10 digits are required to be entered in search pattern field';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
        }else if(!selectedPatternType.equalsIgnoreCase('None' ) && pattern!=null && (pattern.length() < 2 || pattern.length()>9)){
            errorMessage = 'When pattern type is populated Search pattern should have minimum 2 digits and maximum 9 digits';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
        }
        else{
            erroredOut = 'false';
            displayErrorPanel = false;
            fnnFlag = false;
            System.debug('Quantity::' + quantity  + 'Pattern::' + pattern );
            FNNResponseDTO fnnRes = new FNNResponseDTO();
            FNNDTO dto = new FNNDTO();
            FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
            // RPL : to pass Geoparam instead of ADBORIDs
System.debug('Inside searchFNN::isTCPresent..' + isTCPresent);            
            if(!isTCPresent)
            {
              System.debug('Inside searchFNN::CWP loop..' );                      
                fdo.addressId = selectedSite;
            }
            else
            {
System.debug('Inside searchFNN::TC loop..' );                                   
            fdo.geoParam = Label.GeoParam_Name;
            fdo.geoParamValue = Label.GeoParam_Value;
            }
            
                
            fdo.quantity = quantity;
            if(pattern!=null && pattern.length()>0 && selectedPatternType.equalsIgnoreCase('Equals'))
                fdo.pattern = pattern;
            else if(pattern!=null && pattern.length()>0 && selectedPatternType.equalsIgnoreCase('Begins With'))
                fdo.pattern = '*'+pattern;
            else if(pattern!=null && pattern.length()>0 && selectedPatternType.equalsIgnoreCase('Ends With'))
                fdo.pattern = pattern+'*';
            else if(pattern!=null && pattern.length()>0 && selectedPatternType.equalsIgnoreCase('Contains'))
                fdo.pattern = '*'+pattern+'*';
            
            fdo.searchType = 'RANDOM';
            fdo.systemId = 'SFDC';
            dto.data = fdo;
            FNNService fnnSer = new FNNService();
            fnnRes = fnnSer.searchFNN(dto);
            if(fnnRes != NULL && fnnRes.data != NULL){
                fnnList = fnnRes.data.fnns;
            }
            
            System.debug('fnnList::' + fnnList);
            test = true;
            if(fnnList!= null && fnnList.size() > 0 && quantity>fnnList.size()){
                updateUIafterSearch(true, false, true, 'slds-notify slds-notify_toast slds-theme_warning',
                        System.Label.NMC_SearchWarningMsg, true, false);
                /*
                displayErrorPanel = true;
                cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_warning';
                PanelMessage = 'Please find that insufficient numbers returned.You may search again with different quantity / pattern';
                isNumberAvailable =  true;
                fnnFlag = false;
                viewSearchPanel = true;
                displayNumberSearch = false;*/
            }
            else if(fnnList != NULL && fnnList.size() > 0){
                /*
                isNumberAvailable =  true;
                fnnFlag = false;
                displayErrorPanel = true;
                cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_success';
                PanelMessage = 'SUCCESS: Search Complete';
                viewSearchPanel = true;
                displayNumberSearch = false;
                */
                updateUIafterSearch(true, false, true, 'slds-notify slds-notify_toast slds-theme_success',
                        'SUCCESS: Search Complete', true, false);
                
            }else{
                /*
                displayErrorPanel = true;
                cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
                PanelMessage = 'No Numbers found.Please search again with different quantity / pattern';
                */
                erroredOut = 'true';

                updateUIafterSearch(isNumberAvailable, fnnFlag, true, 'slds-notify slds-notify_toast slds-theme_error',
                        System.Label.NMC_SearchNoResult,
                        viewSearchPanel, displayNumberSearch);
            }
        }
        
    }

    @TestVisible
    private void updateUIafterSearch(Boolean isNumberAvailableParam, Boolean fnnFlagParam, Boolean displayErrorPanelParam, String cssClassForPanelMsgsParam,
            String panelMessageParam, Boolean viewSearchPanelParam, Boolean displayNumberSearchParam) {
        isNumberAvailable =  isNumberAvailableParam;
        fnnFlag = fnnFlagParam;
        displayErrorPanel = displayErrorPanelParam;
        cssClassForPanelMsgs = cssClassForPanelMsgsParam;
        PanelMessage = panelMessageParam;
        viewSearchPanel = viewSearchPanelParam;
        displayNumberSearch = displayNumberSearchParam;
    }

    
    //-----Reserve FNN API Call
    public void reserveFNN(){
        System.debug('in Reserve');
        boolean isFNNReserved;
        String status;
        Map<String,List<String>> reservedNumbersMap = NULL;
        FNNDTO dto = new FNNDTO();
        FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        FNNResponseDTO fnnRes = new FNNResponseDTO();
        fdo.serviceIds = new List<String>();
        fdo.serviceIds = fnnList;
        fdo.systemId = 'SFDC';
        dto.data = fdo;
        FNNService fnnSer = new FNNService();
        fnnRes = fnnSer.reserveFNN(dto);
        System.debug('---Initiated---'+fnnRes);
        
        if(fnnRes != NULL && fnnRes.status != NULL && String.Valueof(fnnRes.status).startsWith('2') && fnnRes.request != NULL && fnnRes.request.data != NULL){
            reservedFnnList = fnnRes.request.data.serviceIds;
            System.debug('reservedFnnList::' + reservedFnnList + reservedFnnList.size());
            NumberNCSHelper ncs = new NumberNCSHelper();
            isFNNReserved = ncs.checkForExistingNCS(rootConfigId);
            List<NumberNCSDTO.Configuration> numberList = new List<NumberNCSDTO.Configuration>();
            NumberNCSDTO.Configuration numConfig = NULL;
            for(String fnn : reservedFnnList) {
                numConfig = new NumberNCSDTO.Configuration();
                numConfig.fnn = fnn;
                numConfig.listCode = 'No Entry Line';
                numConfig.status = 'RESERVED';
                numberList.add(numConfig);
            }
            System.debug('numberList::' + numberList);
            System.debug('isFNNReserved::' + isFNNReserved);
            if(isFNNReserved == true){
                status = ncs.updateExistingNCS(rootConfigId,'NumberManagementv1',numberList);
                System.debug('status_Update::' + status);
            }
            else{
                status = ncs.createNewNCS(rootConfigId,'NumberManagementv1', numberList);
                System.debug('status_CreateNew::' + status);
                
            }
            
            if('Success'.equals(status)){
                System.debug('rootConfigId::' +rootConfigId);
                reservedNumbersMap = ncs.getNumbersFromNCS(rootConfigId);
                System.debug('reservedNumbersMap::' + reservedNumbersMap);
                activeNumbersList = reservedNumbersMap.get('ACTIVE');
                reservedNumbersList = reservedNumbersMap.get('RESERVED');
                transitionNumbersList = reservedNumbersMap.get('IN TRANSITION');
                System.debug('activeNumbersList:::'+ activeNumbersList);
                System.debug('reservedNumbersList' + reservedNumbersList);
                System.debug('transitionNumbersList' + transitionNumbersList);
                createFixedNumberRecord(reservedFnnList,basketId,rootConfigId);
                //New Change
                
                if(transitionNumbersList != NULL)
                    for(String fnn : transitionNumbersList){
                        if(fnn.contains(':')){
                            transitionRangeNumbersList.add(fnn);
                        }
                        else{
                            transitionFnnNumbersList.add(fnn);
                        }
                    }
                totalReservedNumberInt = 0;
                if(reservedNumbersList != null)
                    totalReservedNumberInt = totalReservedNumberInt + reservedNumbersList.size();
                if(transitionRangeNumbersList != null){
                    Integer rangeNumbers=0;
                    for(String splittedNumbers: transitionRangeNumbersList){
                        Double rangeFrom = Double.valueOf(splittedNumbers.trim().split(':')[0]);
                        Double rangeTo = Double.valueOf(splittedNumbers.trim().split(':')[1]);
                        rangeNumbers = rangeNumbers + Integer.ValueOf(rangeTo - rangeFrom + 1);
                    }
                    totalReservedNumberInt = totalReservedNumberInt + rangeNumbers;
                }
                
                if(transitionFnnNumbersList != null)
                    totalReservedNumberInt = totalReservedNumberInt + transitionFnnNumbersList.size();
                if(activeNumbersList != null)
                    totalReservedNumberInt = totalReservedNumberInt + activeNumbersList.size();
                
                totalReservedNumber = String.valueOf(totalReservedNumberInt);
                
                //End Change
                
                transitionRangeNumbersList.clear();
                transitionFnnNumbersList.clear();
                if(transitionNumbersList != NULL)
                    for(String tranFnn : transitionNumbersList){
                        if(tranFnn.contains(':')){
                            
                            transitionRangeNumbersList.add(tranFnn);
                        }
                        else{
                            
                            transitionFnnNumbersList.add(tranFnn);
                        }
                    }
                if(wrapAllReservedNumbers != null)
                    wrapAllReservedNumbers.clear();
                if(reservedNumbersList!=null && reservedNumbersList.size()>0){
                    disableUnreserve = false;
                    for(String nums : reservedNumbersList){
                        wrapAllReservedNumbers.add(new wrapReservedNumbers(nums));
                    }
                }else{
                    disableUnreserve = true;
                }
                resrvNumbers.clear();
                if(wrapAllReservedNumbers != null)
                    resrvNumbers.addAll(wrapAllReservedNumbers);
                
                System.debug('transitionRangeNumbersList::' + transitionRangeNumbersList + ',transitionFnnNumbersList::' + transitionFnnNumbersList);

                validateSiteWithUSers (totalReservedNumber, totalUsers);
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'SUCCESS'));
                displayErrorPanel = true;
                cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_success';
                PanelMessage = 'SUCCESS: Numbers Reserved Successfully';
                fnnList.clear();
                fnnFlag= true;
                
                ReservedNumbersData = JSON.serialize(numberList);
                
                System.debug('activeNumbersList::' + activeNumbersList + ',transitionNumbersList::' + transitionNumbersList + ',reservedNumbersList::' + reservedNumbersList );
            }  else {
                cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
                PanelMessage = 'ERROR: ' + status;
                ReservedNumbersData = '';
                System.debug('ERROR: ' + status);
            }
        } else {
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = fnnRes.Message + ' ' + fnnRes.getErrorMessages();
            ReservedNumbersData = '';
            System.debug('ERROR: ' + fnnRes.Message + ' ' + fnnRes.getErrorMessages());
            
        }
        //return null;
    }
    
    //-----
    public void hideSearchResult(){
        fnnFlag = true;
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Sorry, the Number search request has timed out. Please search again.'));
        //return null;
        displayErrorPanel = true;
        cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
        PanelMessage = 'Sorry, the Number search request has timed out. Please search again.';
        
    }
    @TestVisible
    private void validateSiteWithUSers(String totalReservedNumberParam, Integer totalUsersParam){
        List<cscfga__attribute__c> attrList = [SELECT Id,Name,cscfga__Value__c,cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name FROM 
                                               cscfga__attribute__c WHERE cscfga__Product_Configuration__c =: rootConfigId 
                                               and (Name = 'isNumberEnrichComplete' OR Name = 'TotalNumbers')];
        
        List<cscfga__attribute__c> attrListToUpdate = new  List<cscfga__attribute__c>();
        for(cscfga__attribute__c attr : attrList) {
            if((attr.name.equalsIgnoreCase('isNumberEnrichComplete') && totalUsersParam<=Integer.valueOf(totalReservedNumberParam)) || (attr.name.equalsIgnoreCase('isNumberEnrichComplete') && attr.cscfga__Product_Configuration__r.name.contains('Broadsoft'))){ //Added by Venkat for NgUC MTS version - EDGE 114158
                attr.cscfga__Value__c = 'true';
                attr.cscfga__Display_Value__c = 'true';
                resrvedNumberGreaterThanUsers = 'true';
            }else if(attr.name.equalsIgnoreCase('isNumberEnrichComplete')){
                attr.cscfga__Value__c = 'false';
                attr.cscfga__Display_Value__c = 'false';
                resrvedNumberGreaterThanUsers = 'false';
            }else If(attr.name.equalsIgnoreCase('TotalNumbers')){
                attr.cscfga__Value__c = totalReservedNumberParam;
                attr.cscfga__Display_Value__c  = totalReservedNumberParam;
            }
            attrListToUpdate.add(attr);
        }
        update attrListToUpdate;
    }
    
    @TestVisible
    private void validateSiteWithUSersConsttructor(){
        if(totalUsers<=Integer.valueOf(totalReservedNumber)){
            resrvedNumberGreaterThanUsers = 'true';
        }else{
            resrvedNumberGreaterThanUsers = 'false';
        }
        
    }
	
	//INC000090679656
    public void validateSiteWithUSersPageAction(){
		System.debug('Page Action ::'+totalReservedNumber+'::::'+totalUsers);
        List<cscfga__attribute__c> attrList = [SELECT Id,Name,cscfga__Value__c,cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name FROM 
                                               cscfga__attribute__c WHERE cscfga__Product_Configuration__c =: rootConfigId 
                                               and (Name = 'isNumberEnrichComplete' OR Name = 'TotalNumbers')];
        
        List<cscfga__attribute__c> attrListToUpdate = new  List<cscfga__attribute__c>();
        for(cscfga__attribute__c attr : attrList) {
            if((attr.name.equalsIgnoreCase('isNumberEnrichComplete') && totalUsers<=Integer.valueOf(totalReservedNumber)) || (attr.name.equalsIgnoreCase('isNumberEnrichComplete') && attr.cscfga__Product_Configuration__r.name.contains('Broadsoft'))){ //Added by Venkat for NgUC MTS version - EDGE 114158
                attr.cscfga__Value__c = 'true';
                attr.cscfga__Display_Value__c = 'true';
                resrvedNumberGreaterThanUsers = 'true';
            }else if(attr.name.equalsIgnoreCase('isNumberEnrichComplete')){
                attr.cscfga__Value__c = 'false';
                attr.cscfga__Display_Value__c = 'false';
                resrvedNumberGreaterThanUsers = 'false';
            }else If(attr.name.equalsIgnoreCase('TotalNumbers')){
                attr.cscfga__Value__c = totalReservedNumber;
                attr.cscfga__Display_Value__c  = totalReservedNumber;
            }
            attrListToUpdate.add(attr);
        }
        update attrListToUpdate;
    }
    /*  public void saveAndExit(){
if(totalUsers>reservedNumbersList.size()){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please note that the required quantity of FNN is not reserved.The Record is saved'));
}else{
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The changes made were successfully saved'));
}
}*/
    
    public void clearAll(){
        quantity = 0;
        pattern ='';
        selectedSite='None';
        SuccessUnreserved = false;
        FailedUnreserved = false;
        displayErrorPanel = true;
        cssClassForPanelMsgs ='';
        PanelMessage = '';
    }
    public void switchReserveNumbersAction(){
        System.debug('Reserve Numbers '+unreserveNumbers);
        if(unreserveNumbers){
            unreserve =  true;
            introduceUnreserve= 'slds-size_1-of-8';
        }else{
            unreserve = false;
            SuccessUnreserved =false;
            FailedUnreserved = false;
            introduceUnreserve= 'slds-size_1-of-4';
        }
        
    }
    
    public class wrapReservedNumbers {
        public String unReservedNumber {get; set;}
        public Boolean selected {get; set;}
        
        
        public wrapReservedNumbers(String num) {
            unReservedNumber = num;
            selected = false;
        }
    }
    
    public void processSelected() {
        List<String> unReserveNumberList = new List<String>();
        Map<String,wrapReservedNumbers> unReserveNumberMap = new Map<String,wrapReservedNumbers>();
        for(wrapReservedNumbers wrapAccountObj : wrapAllReservedNumbers) {
            unReserveNumberMap.put(wrapAccountObj.unReservedNumber,wrapAccountObj);
            if(wrapAccountObj.selected == true) {
                unReserveNumberList.add(wrapAccountObj.unReservedNumber);
            }
        }
        FNNDTO dto = new FNNDTO();
        FNNResponseDTO fnnRes = new FNNResponseDTO();
        FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
        fdo.serviceIds = unReserveNumberList;
        fdo.systemId = 'MSPA';
        dto.data = fdo;
        FNNService fnnSer = new FNNService();
        fnnRes = fnnSer.unReserveFNN(dto);
        System.debug('Response ' +fnnRes);
        if(fnnRes != NULL &&  fnnRes.status!=NULL && String.Valueof(fnnRes.status).startsWith('2')){
            
            deleteExistingNcs(unReserveNumberList, unReserveNumberMap, fnnRes, '');
            
        } else {
            ReservedNumbersData = '';
            FailedUnreserved = true;
            SuccessUnreserved = true;
            cssClassForUnreservePanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            UnreservePanelMessage =  fnnRes.getErrorMessages();
            displayErrorPanel = true;
            cssClassForPanelMsgs ='';
            PanelMessage = '';
            System.debug(fnnRes.getErrorMessages());
            
            //but still we can remove our reserved numbers if we got status active or available
            List<String> unReserveNumberListNew = new List<String>();
            if (fnnRes.errors != null) {
                unReserveNumberListNew = getValidNumbersToUnreserve(fnnRes.errors, unReserveNumberList);
            }
            if (unReserveNumberListNew.size() > 0) {
                deleteExistingNcs(unReserveNumberListNew, unReserveNumberMap, fnnRes, 'Unreserve Numbers finished with some errors: ' + fnnRes.getErrorMessages());
            }
        }
    }
    @TestVisible
    private List<String> getValidNumbersToUnreserve(List<FNNResponseDTO.ErrorsDataObject> errors, List<String> unReserveNumberList) {
        List<String> unReserveNumberListNew = new List<String>();
        for(String unNums : unReserveNumberList){
            Boolean found = false;
            for(FNNResponseDTO.ErrorsDataObject err : errors) {
                if (err.fnn != null && err.fnn == unNums) {
                    found = true;
                    if (err.message != null &&  (err.message.contains('AVAILABLE') || err.message.contains('NOT_EXIST')))
                        unReserveNumberListNew.add(unNums);
                }
            }

            if (!found)
                unReserveNumberListNew.add(unNums);
        }

        return unReserveNumberListNew;
    }

    @TestVisible
    private void deleteExistingNcs(List<String> unReserveNumberList,  Map<String,wrapReservedNumbers> unReserveNumberMap, FNNResponseDTO fnnRes, String errorMsg) {
        for(String unNums : unReserveNumberList){
            unReserveNumberMap.remove(unNums);
        }
        
        NUmberNCSHelper ncs = new NumberNCSHelper();
        String respMsg = ncs.deleteExistingNCS(rootConfigId,unReserveNumberList);
        System.debug('wrapAllReservedNumbers.size() ::: '+wrapAllReservedNumbers.size()+'unReserveNumberMap.values().size()::' +unReserveNumberMap.values().size());
        if(unReserveNumberMap.values().size() == 0){
            unreserve = false;
            unreserveNumbers = false;
        }
        
        if(respMsg == 'Success'){
             deleteFixedNumberRecord( unReserveNumberList,basketid);
            wrapAllReservedNumbers = unReserveNumberMap.values();
            if(wrapAllReservedNumbers.size()>0)
                disableUnreserve = false;
            else
                disableUnreserve = false;
            SuccessUnreserved = true;
            FailedUnreserved = false;
            unreserveMessage = 'Number Unreserved Successfully';
            cssClassForUnreservePanelMsgs ='slds-notify slds-notify_toast slds-theme_success';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='';
            PanelMessage = '';
            if (errorMsg.length() > 0) {
                cssClassForUnreservePanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
                UnreservePanelMessage = errorMsg;
            }
            else {
                UnreservePanelMessage = 'Number Unreserved Successfully';
            }
            
            ReservedNumbersData = JSON.serialize(unReserveNumberList);
        }
        else{
            updateUIOnErrorStatus(respMsg, fnnRes.getErrorMessages());
        }
    }

    @TestVisible
    private void updateUIOnErrorStatus(String respMsg, String fnnResErrorMessage) {
        ReservedNumbersData = '';
        FailedUnreserved = true;
        SuccessUnreserved = true;
        cssClassForUnreservePanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
        UnreservePanelMessage = respMsg + ', ' + fnnResErrorMessage;
        displayErrorPanel = true;
        cssClassForPanelMsgs ='';
        PanelMessage = '';
        System.debug(respMsg + ', ' +  fnnResErrorMessage);
    }
    
    public void patternTypeChange(){
        System.debug('Change '+selectedPatternType);
        if(!selectedPatternType.equalsIgnoreCase('None')){
            disableSrcPattern = false;
        }else{
            disableSrcPattern = true;
        }
    }
/*******************************************************************
    EDGE        -121868
    Method      -createFixedNumberRecord
    Description -Storing new CWP IP Site Fixed Numbers on Number Object 
    Author      -Dheeraj Bhatt
 *********************************************************************/
    public static void createFixedNumberRecord(List<string>numberList,string basketId,String prodConfigId){
        Try{
            if(numberList.size()>0 && String.isNotBlank(basketId) && String.isNotBlank(prodConfigId)){
                List<Number__c>fnnNumberList=new List<Number__c>();
                List<cscfga__Product_Basket__c> basketDetail = [SELECT cscfga__Opportunity__c,csbb__Account__c,Billing_Account__c FROM cscfga__Product_Basket__c WHERE ID=:basketid ]; 
                for(String num:numberList){
                    Number__c fnnNumber = new Number__c();
                    fnnNumber.Basket__c = basketid;
                    fnnNumber.Account__c = !basketDetail.isEmpty()? basketDetail[0].csbb__Account__c : null;
                    fnnNumber.Service_Number__c =num;
                    fnnNumber.Status__c = 'RESERVED';
                    fnnNumber.Mobile__c='Fixed';
                    fnnNumber.Type__c='FNN';
                    fnnNumber.Product_Configuration__c=prodConfigId;
                    //EDGE-108230:New Billing account field added
                    fnnNumber.Billing_Accounts__c=!basketDetail.isEmpty()? basketDetail[0].Billing_Account__c : null;
                    fnnNumberList.add(fnnNumber);
                }
                if(fnnNumberList.size() > 0){
                    insert fnnNumberList;
                }
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger('NumberManagementController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);  
        }
    }
/*******************************************************************
    EDGE        -121868
    Method      -deleteFixedNumberRecord
    Description -Delete number record for IP Site Fixed Numbers Unreserve  
    Author      -Dheeraj Bhatt
 *********************************************************************/
    public static void deleteFixedNumberRecord(List<String> unreserveNumberList,String basketid){
        Try{
            if(unreserveNumberList.size() > 0 && string.isNotBlank(basketid)){
                List<Number__c> fnnNumberList=new List<Number__c>();
                fnnNumberList = [SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c = :basketid AND  Service_Number__c IN :unreserveNumberList];  
                if(fnnNumberList.size()> 0){
                    delete fnnNumberList;  
                }
            }
        }
        Catch (Exception ex){
            Logger2 log = Logger2.getLogger('NumberManagementController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);  
    
        }
    }
}