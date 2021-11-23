/*************************************************************************************
    Name: NumberManagementTacticalTransController
    Description: This class implemented as part of DPG-463 and is similar to class NumberManagementController
                Implemented for tactical transition of ISDN30 services
    Author: Harsh Parmar
    ************************************************************************************/

public without sharing class NumberManagementTacticalTransController {
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
    public String rangeFromForISDN30 {get;set;}
    public String rangeToForISDN30 {get;set;}
    public String ReservedNumbersData {get;set;}
    // RPL Changes for ngUC - 24-Jun-2019    
    public Boolean isTCPresent{get;set;}
    List<wrapReservedNumbers> resrvNumbers = new List<wrapReservedNumbers>();
    
    public NumberManagementTacticalTransController(){
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
        //cssClassForPanelMsgs = 'slds-notify slds-notify_toast slds-theme_error';
        displayErrorPanel = false;
        cssClassForPanelMsgs = '';
        PanelMessage = '';
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
            system.debug('@@reservedNumbersList'+reservedNumbersList);
            
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
            
            List<String> ansList = new List<String>();
            ansList = displayRangeonUI(reservedNumbersList);
               /* List<String> temp = new List<String>();
                if(reservedNumbersList.size()>0) {            
                integer i=0,j=0,counter=0; 
                do{
                    j=i+1;
                    while(j<reservedNumbersList.size()){
                        if(long.valueOf(reservedNumbersList[j])-long.valueOf(reservedNumbersList[i])!=j-i)
                            break;
                        counter++;
                        temp.add(reservedNumbersList[j]);
                        j++;
                    }
                    //system.debug('@@Temp'+temp);
                    if(i==j-1)
                        ansList.add(reservedNumbersList[i]);
                    else if(counter<10){
                        ansList.add(reservedNumbersList[i]);
                        ansList.addall(temp);
                    }
                    else
                        ansList.add(reservedNumbersList[i] + ':' + reservedNumbersList[j-1]);
                    counter =0;
                    temp.clear();
                    i=j;
                }while(i<reservedNumbersList.size());
            }*/
            if(wrapAllReservedNumbers!= null)
                wrapAllReservedNumbers.clear();
           /* if(reservedNumbersList!=null && reservedNumbersList.size()>0){
                disableUnreserve = false;
                for(String nums : reservedNumbersList){
                    wrapAllReservedNumbers.add(new wrapReservedNumbers(nums));
                }
            }*/
            if(ansList!=null && ansList.size()>0){
                disableUnreserve = false;
                for(String nums : ansList){
                    wrapAllReservedNumbers.add(new wrapReservedNumbers(nums));
                }
            }
            else{
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
        for(cscfga__product_configuration__c pc:[SELECT Id,Name,cscfga__Product_Basket__c,cscfga__Root_Configuration__c,Quantity_Product_Configuration__c FROM cscfga__product_configuration__c WHERE (cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000074' OR cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_000324') AND cscfga__Root_Configuration__c=:rootConfigId]){
            userConfigListMap.put(pc.id,pc);
        }
        System.debug('userConfigListMap:::'+userConfigListMap);
        Map<String,cscfga__attribute__c> attrListMap = new Map<String,cscfga__attribute__c>();
        for(cscfga__attribute__c attr : [SELECT Id,Name,cscfga__Value__c,cscfga__Product_Configuration__c FROM cscfga__attribute__c where cscfga__Product_Configuration__c IN: userConfigListMap.keySet() OR cscfga__Product_Configuration__c = :rootConfigId]){
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
            
        }
        System.debug('orderSummaryList::' + finalOrderSummaryList);
    }
    
    public void hideSearchResult(){
        fnnFlag = true;
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Sorry, the Number search request has timed out. Please search again.'));
        //return null;
        displayErrorPanel = true;
        cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
        PanelMessage = 'Sorry, the Number search request has timed out. Please search again.';
        
    }
    @TestVisible
    private void validateSiteWithUSers(){
        List<cscfga__attribute__c> attrList = [SELECT Id,Name,cscfga__Value__c,cscfga__Product_Configuration__c FROM 
                                               cscfga__attribute__c WHERE cscfga__Product_Configuration__c =: rootConfigId 
                                               and (Name = 'isNumberEnrichComplete' OR Name = 'TotalNumbers')];
        
        List<cscfga__attribute__c> attrListToUpdate = new  List<cscfga__attribute__c>();
        for(cscfga__attribute__c attr : attrList) {
            if(attr.name.equalsIgnoreCase('isNumberEnrichComplete') && totalUsers<=Integer.valueOf(totalReservedNumber)){
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
    
    @TestVisible
    private void validateSiteWithUSersConsttructor(){
        if(totalUsers<=Integer.valueOf(totalReservedNumber)){
            resrvedNumberGreaterThanUsers = 'true';
        }else{
            resrvedNumberGreaterThanUsers = 'false';
        }
        
    }
    
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
    
/********************************************************************
Name: processSelected
Parameters: null
Return Type: void
Description: Method executed Unreserve button is clicked which unreserves the selected numbers
*******************************************************************/
    public void processSelected() {
        List<String> unReserveNumberList = new List<String>();
        Map<String,wrapReservedNumbers> unReserveNumberMap = new Map<String,wrapReservedNumbers>();
        for(wrapReservedNumbers wrapAccountObj : wrapAllReservedNumbers) {
            unReserveNumberMap.put(wrapAccountObj.unReservedNumber,wrapAccountObj);
            if(wrapAccountObj.selected == true) {
                unReserveNumberList.add(wrapAccountObj.unReservedNumber);
            }
        }
        /*FNNDTO dto = new FNNDTO();
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
                for(String unNums : unReserveNumberList){
                    Boolean found = false;
                    for(FNNResponseDTO.ErrorsDataObject err : fnnRes.errors) {
                        if (err.fnn != null && err.fnn == unNums) {
                            found = true;
                            if (err.message != null &&  (err.message.contains('AVAILABLE') || err.message.contains('NOT_EXIST')))
                                unReserveNumberListNew.add(unNums);
                        }
                    }
                    
                    if (!found)
                        unReserveNumberListNew.add(unNums);
                }
            }
            if (unReserveNumberListNew.size() > 0) {
                deleteExistingNcs(unReserveNumberListNew, unReserveNumberMap, fnnRes, 'Unreserve Numbers finished with some errors: ' + fnnRes.getErrorMessages());
            }
        }*/
            ReservedNumbersData = '';
            FailedUnreserved = true;
            SuccessUnreserved = true;
            cssClassForUnreservePanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            UnreservePanelMessage =  'Please try again!';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='';
            PanelMessage = '';
            
            
            List<String> unReserveNumberListNew = new List<String>();
            /*for(String unNums : unReserveNumberList){
                unReserveNumberListNew.add(unNums);
                }*/
            List<String> tempList = new List<String>();
            Long rangeFromUnNum=0;
            Long rangeToUnNum=0;
            
            for(Integer i=(unReserveNumberList.size()-1);i>=0;i--){
                if(unReserveNumberList[i].contains(':')){
                    tempList.add(unReserveNumberList[i]);
                    unReserveNumberList.remove(i);
                }
            }
            system.debug('##Templist'+tempList);
            system.debug('##unReserveNumberList'+unReserveNumberList);
            if(tempList != null){
                for(String splittedNumbers: tempList){
                system.debug('##rangefrom'+Long.valueOf(splittedNumbers.trim().split(':')[0]));
                system.debug('##rangeto'+Long.valueOf(splittedNumbers.trim().split(':')[1]));
                    rangeFromUnNum = Long.valueOf(splittedNumbers.trim().split(':')[0]);
                    rangeToUnNum = Long.valueOf(splittedNumbers.trim().split(':')[1]);
                }
            }
            for(Long i=rangeFromUnNum;i<=rangeToUnNum;i++){
                unReserveNumberList.add(String.valueOf(i));
            }
            for(String unNums : unReserveNumberList){
                unReserveNumberListNew.add(unNums);
                }
if (unReserveNumberListNew.size() > 0) {
                deleteExistingNcs(unReserveNumberListNew, unReserveNumberMap,'Unreserve Numbers finished with some errors: ');
            }
    }
/********************************************************************
Name: deleteExistingNcs
Parameters: unReserveNumberList,unReserveNumberMap,errorMsg
Return Type: void
Description: Method executed to remove/delete the numbers to be unreserved from the Number management json 
*******************************************************************/      
    private void deleteExistingNcs(List<String> unReserveNumberList,Map<String,wrapReservedNumbers> unReserveNumberMap,String errorMsg) {
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
            UnreservePanelMessage = 'Number Unreserved Successfully';
            
            
            ReservedNumbersData = JSON.serialize(unReserveNumberList);
        }
        else{
            ReservedNumbersData = '';
            FailedUnreserved = true;
            SuccessUnreserved = true;
            cssClassForUnreservePanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            UnreservePanelMessage = respMsg;
            displayErrorPanel = true;
            cssClassForPanelMsgs ='';
            PanelMessage = '';
            
        }
    }
/********************************************************************
Name: manualNumberReserve
Parameters: null
Return Type: void
Description: Method that is called when the numbers entered manually for ISDN30 transition are to be reserved,added to the Number management json
*******************************************************************/        
    public void manualNumberReserve(){
        viewSearchPanel = true;
        SuccessUnreserved = false;
        FailedUnreserved = false;
        List<String> manualList = new List<String>();
        
        if(fnnList!= null)
            fnnList.clear();
        system.debug('@@rangeoutside'+rangeToForISDN30+'@@'+rangeFromForISDN30);
        if(rangeToForISDN30 == '' || rangeFromForISDN30 == ''){
            system.debug('@@range'+rangeToForISDN30+'@@'+rangeFromForISDN30);
            errorMessage = 'Ranges cannot be empty. Please enter the number.';
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            system.debug('Panel msg'+PanelMessage+'@@displayErrorPanel'+displayErrorPanel);
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
            system.debug('@@exitif');
        }else if(!(rangeFromForISDN30.isNumeric()) || !(rangeToForISDN30.isNumeric())){
            system.debug('enter elseif1');
            errorMessage = 'The Ranges should contain only numbers';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
        }else if(!(rangeFromForISDN30.length()==10) || !(rangeToForISDN30.length()==10)){
            system.debug('enter elseif1');
            errorMessage = 'The Ranges should have 10 digits';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
        }else if(long.valueOf(rangeFromForISDN30) <0 || long.valueOf(rangeToForISDN30) <0){
            system.debug('enter elseif2');
            errorMessage = 'The Ranges cannot be negative';
            displayErrorPanel = true;
            cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
            PanelMessage = errorMessage;
            erroredOut = 'true';
            if(fnnList != null)
                fnnList.clear();
            
        }else{
            erroredOut = 'false';
            displayErrorPanel = false;
            system.debug('@@else');
            Long intRangeTo = long.valueof(rangeToForISDN30);
            Long intRangeFrom = long.valueof(rangeFromForISDN30);
            Long tempIntRangeFrom = long.valueof(rangeFromForISDN30);
            Integer blockRange = integer.ValueOf(intRangeTo - intRangeFrom + 1);
            
            
            if(intRangeFrom>0 && intRangeTo>intRangeFrom){
                do {
                    manualList.add(String.valueOf(tempIntRangeFrom).leftPad(10,'0'));
                    tempIntRangeFrom++;
                } while (tempIntRangeFrom <= intRangeTo);
            }
            
            fnnList = new List<String>(manualList);
            
            System.debug('Reserving Now');
            
            String status;
            
            Map<String,List<String>> reservedNumbersMap = NULL;
            
            /*boolean isFNNReserved;
String status;
Map<String,List<String>> reservedNumbersMap = NULL;
FNNDTO dto = new FNNDTO();
FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
FNNResponseDTO fnnRes = new FNNResponseDTO();
fdo.serviceIds = new List<String>();
//fdo.serviceIds = fnnList;
fdo.systemId = 'SFDC';
dto.data = fdo;
FNNService fnnSer = new FNNService();
fnnRes = fnnSer.reserveFNN(dto); */
            
            //reservedFnnList = fnnRes.request.data.serviceIds;
            //System.debug('reservedFnnList::' + reservedFnnList + reservedFnnList.size());
            NumberNCSHelper ncs = new NumberNCSHelper();
            isFNNReserved = ncs.checkForExistingNCS(rootConfigId);
            List<NumberNCSDTO.Configuration> numberList = new List<NumberNCSDTO.Configuration>();
            
            NumberNCSDTO.Configuration numConfig = NULL;
            for(String fnn : fnnList) {
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
                reservedNumbersMap = ncs.getNumbersFromNCS(rootConfigId);
                System.debug('reservedNumbersMap::' + reservedNumbersMap);
                activeNumbersList = reservedNumbersMap.get('ACTIVE');
                reservedNumbersList = reservedNumbersMap.get('RESERVED');
                transitionNumbersList = reservedNumbersMap.get('IN TRANSITION');
                System.debug('activeNumbersList:::'+ activeNumbersList);
                System.debug('reservedNumbersList' + reservedNumbersList);
                System.debug('transitionNumbersList' + transitionNumbersList);
                
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
                    List<String> ansList = new List<String>();
                    ansList = displayRangeonUI(reservedNumbersList);
                    /*List<String> temp = new List<String>();
                    if(reservedNumbersList.size()>0) {            
                    integer i=0,j=0,counter=0; 
                    do{
                        j=i+1;
                        while(j<reservedNumbersList.size()){
                            if(long.valueOf(reservedNumbersList[j])-long.valueOf(reservedNumbersList[i])!=j-i)
                                break;
                            counter++;
                            temp.add(reservedNumbersList[j]);
                            j++;
                        }
                        //system.debug('@@Temp'+temp);
                        if(i==j-1)
                            ansList.add(reservedNumbersList[i]);
                        else if(counter<10){
                            ansList.add(reservedNumbersList[i]);
                            ansList.addall(temp);
                        }
                        else
                            ansList.add(reservedNumbersList[i] + ':' + reservedNumbersList[j-1]);
                        counter =0;
                        temp.clear();
                        i=j;
                    }while(i<reservedNumbersList.size());
                }*/
                if(wrapAllReservedNumbers != null)
                    wrapAllReservedNumbers.clear();
                /*if(reservedNumbersList!=null && reservedNumbersList.size()>0){
                    disableUnreserve = false;
                    for(String nums : reservedNumbersList){
                        wrapAllReservedNumbers.add(new wrapReservedNumbers(nums));
                    }
                }*/
               if(ansList!=null && ansList.size()>0){
                    disableUnreserve = false;
                    for(String nums : ansList){
                        wrapAllReservedNumbers.add(new wrapReservedNumbers(nums));
                    }
                }
                else{
                    disableUnreserve = true;
                }
                resrvNumbers.clear();
                if(wrapAllReservedNumbers != null)
                    resrvNumbers.addAll(wrapAllReservedNumbers);
                
                System.debug('transitionRangeNumbersList::' + transitionRangeNumbersList + ',transitionFnnNumbersList::' + transitionFnnNumbersList);
                
                cscfga__Product_Basket__c basketTactical = [Select Id, Tactical_Handling_Type__c from cscfga__Product_Basket__c where Id =:basketId];
                basketTactical.Tactical_Handling_Type__c = 'CWP-ISDN30-Tactical';
                UPDATE basketTactical;
                
                validateSiteWithUsers();
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'SUCCESS'));
                displayErrorPanel = true;
                cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_success';
                PanelMessage = 'SUCCESS: Numbers Reserved Successfully';
                fnnList.clear();
                fnnFlag= true;
                
                ReservedNumbersData = JSON.serialize(numberList);
                
                System.debug(',transitionNumbersList::' + transitionNumbersList );
            }  else {
                cssClassForPanelMsgs ='slds-notify slds-notify_toast slds-theme_error';
                PanelMessage = 'ERROR: ' + status;
                ReservedNumbersData = '';
                System.debug('ERROR: ' + status);
            }
        }
    }
/********************************************************************
Name: displayRangeonUI
Parameters: reservedNumbersList
Return Type: List<String>
Description: Method that is used to display the numbers reserved as ranges on the UI
*******************************************************************/
    @TestVisible
    private List<String> displayRangeonUI(List<String> reservedNumbersList){
        List<String> ansList = new List<String>();
        List<String> temp = new List<String>();
        if(reservedNumbersList.size()>0) {            
            integer i=0,j=0,counter=0; 
            do{
                j=i+1;
                while(j<reservedNumbersList.size()){
                    if(long.valueOf(reservedNumbersList[j])-long.valueOf(reservedNumbersList[i])!=j-i)
                        break;
                    counter++;
                    temp.add(reservedNumbersList[j]);
                    j++;
                }
                //system.debug('@@Temp'+temp);
                if(i==j-1)
                    ansList.add(reservedNumbersList[i]);
                else if(counter<10){
                    ansList.add(reservedNumbersList[i]);
                    ansList.addall(temp);
                }
                else
                    ansList.add(reservedNumbersList[i].leftPad(10,'0') + ':' + reservedNumbersList[j-1].leftPad(10,'0'));
                counter =0;
                temp.clear();
                i=j;
            }while(i<reservedNumbersList.size());
        }
        return ansList;
    }
}