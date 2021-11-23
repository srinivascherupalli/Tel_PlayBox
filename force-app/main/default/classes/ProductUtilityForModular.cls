/*
Name : ProductUtilityForModular  
TestClass:productUtilityForModularTest      
No.       Developer Name        Date            Story Description   
1.        Ankit Goswami     19/11/2020     EDGE-178204:External ID & Order Type Framework   
2.        Gokul             2/12/2020      EDGE-178211,187998,181998,188858,187313- Create OLIS for RatecardLineItems - TC,MS,MDM   
3.        Aditya            24/12/2020     EDGE-187655    
4.        Ankit             04/01/2021     EDGE-196640        
5.      Gokul        27/01/2021  EDGE-200086

6.      Gokul      10/02/2021  EDGE-203443

7.        Gokul             24/02/2021     EDGE-195270 - Capture Order type for Chown OLIs
8.        Gokul             11/03/2021     EDGE-205510 -  Capture RategroupIdentifier in OLIs
9.        Payal             19/03/2021     EDGE-207998
10.        Kamlesh           22/3/2021      EDGE-205509 - Added updateBasketwithJobId method
11.      Pawan Singh         06/08/2021     DIGI-5648    Updated Offer Name from Telstra_Collaboration to Adaptive Collaboration
12.		Natasha Ambre		25/10/2021		DIGI-32161	 Added chargeFrequency For DMS offer
*/
public with sharing class ProductUtilityForModular {  
    Map<Id,cscfga__Product_Basket__c>mapSyncedProductBasket=new Map<Id,cscfga__Product_Basket__c>();
    set<id> json_sio_ids = new set<id>();
    List<OLIWrapper>OLIWrapperList=new list<OLIWrapper>();
    list<opportunitylineitem>oldOlis = new list<opportunitylineitem>();
    List<cscfga__Attribute__c>lstAttribute=new List<cscfga__Attribute__c>();
    Map<String,String> mapProductBasketIdPriceBookId =new  Map<String,String> (); 
    Map<String,map<String,Product>> mapProductFamilymapProduct=new Map<String,map<String,Product>>();
    Map<String,map<String,PBEntry>> mapPriceBookIdmapPBEntry=new Map<String,map<String,PBEntry>>();
    Map<String,String> afdMap=new Map<String,String>();
    Map<string,OLISyncAttributeMapping__mdt> OLIMapped=new map<string,OLISyncAttributeMapping__mdt>();
    Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper> newPCIdOLIWrapperMap = new Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper>();// EDGE - 192806
    static boolean isInflight = false;// EDGE - 192806
    final static String NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c; // DIGI-5648 
    @future
    public  static void createOLIsAsync(Set<String> setProductBasketId) {
        Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());    // Custom setting used to disable all the validation rules for the current running user. 
        if (ecCusSetting.No_Validations__c == false) {  
            ecCusSetting.No_Validations__c = true;
            upsert ecCusSetting;
        }
        productUtilityForModular prodUtill= new productUtilityForModular();
        prodUtill.syncProductBaskt(setProductBasketId, ecCusSetting);
        
    }
    // EDGE - 192806
    public void syncInflightBasket(set<String> setProductBasketId, Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper> mapNewPCIdOLIWrapper,list<opportunitylineitem>oldOLIList){
      
        isInflight = true;
        newPCIdOLIWrapperMap = mapNewPCIdOLIWrapper;
        oldOlis = oldOLIList;
        list<cscfga__Product_Basket__c>prodBasketList = [SELECT Id,csordtelcoa__Basket_Stage__c,cscfga__total_contract_value__c,Primary_Basket__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c,csbb__Account__c,csbb__Account__r.Name,csbb__Account__r.Mobile_Code__c,csbb__Account__r.RecordType.DeveloperName FROM cscfga__Product_Basket__c WHERE Id IN: setProductBasketId];             
            for(cscfga__Product_Basket__c prodBas: prodBasketList){
                mapSyncedProductBasket.put(prodBas.id,prodBas);  
            }
        createOLIsNew(setProductBasketId);
    }
    
    public void syncProductBaskt(Set<String> setProductBasketId,Environment_Configurations__c ecCusSetting){
        try {
            
            list<cscfga__Product_Basket__c>prodBasketList = [SELECT Id,csordtelcoa__Basket_Stage__c,cscfga__total_contract_value__c,Primary_Basket__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c,csbb__Account__c,csbb__Account__r.Name,csbb__Account__r.Mobile_Code__c,csbb__Account__r.RecordType.DeveloperName FROM cscfga__Product_Basket__c WHERE Id IN: setProductBasketId];             
            for(cscfga__Product_Basket__c prodBas: prodBasketList){
                mapSyncedProductBasket.put(prodBas.id,prodBas);  
            }
            //sp = Database.setSavepoint();
            createOLIsNew(setProductBasketId);
            if(!mapSyncedProductBasket.isEmpty()) {
                Set<Id> setOpportunityId    =   new Set<Id>();
                for(cscfga__Product_Basket__c oPB: mapSyncedProductBasket.values()) {
                    if(oPB.cscfga__Opportunity__c!=null) {
                        setOpportunityId.add(oPB.cscfga__Opportunity__c);
                    }
                }
                if(!setOpportunityId.isEmpty()) {
                    BasketOpportunityUpdateHelper.updateOpportunityDetails(mapSyncedProductBasket,setOpportunityId);  
                }
            }
        } catch (Exception e) {
            System.debug('OLI Aync Creation Exception ***' + e.getMessage() + ' ' + e.getStackTraceString());
            List<cscfga__Product_Basket__c> productBasketList   =   new List<cscfga__Product_Basket__c>();
            for(String basketId : setProductBasketId) {
                cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Id=basketId,csbb__Synchronised_With_Opportunity__c=false,csordtelcoa__Synchronised_with_Opportunity__c=false);
                productBasketList.add(basket);
            }
            update productBasketList;
            if (ecCusSetting.Id != null && ecCusSetting.No_Validations__c == true) {    //After Basket sync, enable the validation rules for the current running user.
                ecCusSetting.No_Validations__c = false;
                update ecCusSetting;
            }
        }
        
    }
    //EDGE-178204 added by ankit || start
    public  void createOLIsNew(Set<String> setProductBasketId){
        mapProductBasketIdPriceBookId                            =   new AssignnPriceBookToProductBasketImpl().AssignPriceBook(setProductBasketId);
        attributeFieldSelectorHelper attrFieldObj                =   new attributeFieldSelectorHelper();
        attrFieldObj.basketIdSet                                 =   setProductBasketId;
        Map<string,cscfga__Attribute_Field__c>attrfieldMap       =   attrFieldObj.attributeCondition('byFieldNameList'); 
        attributeSelectorHelper attrObj                          =   new attributeSelectorHelper();
        attrObj.basketIdSet                                      =   setProductBasketId;
        attrObj.attributeIdSet                                   =   attrfieldMap.keyset();
        lstAttribute                                             =   attrObj.attributeCondition('byAFD'); 
        if(lstAttribute !=null && !lstAttribute.isEmpty()){
            mapProductFamilymapProduct                               =   CreateProducts2(lstAttribute);
            if(mapProductBasketIdPriceBookId !=null){
                mapPriceBookIdmapPBEntry                                 =   MakePriceBookPBEntriesMap(mapProductBasketIdPriceBookId,lstAttribute,mapProductFamilymapProduct); 
                if(mapPriceBookIdmapPBEntry != null && !mapPriceBookIdmapPBEntry.isEmpty()){
                    createPriceBookEntries(mapPriceBookIdmapPBEntry);   
                    populateOLIWrapper();
                    fetchAFDMetadata();
                    createOppLineItemsNew();
                }
            }
        }
    }
    public void fetchAFDMetadata(){
        list<OLISyncAttributeMapping__mdt>oliList=[select id,From_Field__c,Object__c,To_Field__c,Datatype__c,DeveloperName From OLISyncAttributeMapping__mdt];
        for(OLISyncAttributeMapping__mdt OLI : oliList){
            OLIMapped.put(OLI.DeveloperName,OLI);
        }
    }
    //EDGE-178204 added by ankit || End
    private  void createOppLineItemsNew() {
        Set<Id> oppIdSet                =   new Set<Id>();
        List<String> pcodeList          =   new List<String>();
        List<String> pMaxNameList       =   new List<String>();
        List<OpportunityLineItem> lstOLI=   new List<OpportunityLineItem>(); 
        Map<String,cspmb__Price_Item__c> codeNamePriceItemMap   =   new Map<String,cspmb__Price_Item__c>();
        for(OLIWrapper oliWrap : oliWrapperList){
            Double tmpUnitPrice             =   oliWrap.unitPrice;
            String tmpPriceBookId           =   mapProductBasketIdPriceBookId.get(oliWrap.ProductBasketId);
            Map<string,Product> mapProduct  =   mapProductFamilymapProduct.get(oliWrap.ProductBasketFamily);
            Product tmpProduct              =   mapProduct.get(oLiWrap.oliDescription);
            String tmpProduct2Id            =   tmpProduct.Prod2.Id;
            Map<string,PBEntry> mapPBEntry  =   mapPriceBookIdmapPBEntry.get(tmpPriceBookId);
            PBEntry tmpPBEntry              =   mapPBEntry.get(tmpProduct2Id);
            String tmpPriceBookEntryId      =   tmpPBEntry.PBE.Id;
            OpportunityLineItem oOLI        =   new OpportunityLineItem();
            oOLI.UnitPrice                  =   0.00;
            oOLI.One_Off_Price__c           =   0.00;
            oOLI.Recurring_Price__c         =   0.00;
            oOLI.cscfga__Attribute__c       =   oliWrap.attributeId;
            oOLI.OpportunityId              =   mapSyncedProductBasket.get(oliWrap.ProductBasketId).cscfga__Opportunity__c;
            oOLI.PricebookEntryId           =   tmpPriceBookEntryId;
            oOLI.Quantity                   =   oLiWrap.Quantity;
            oOLI.Description                =   oLiWrap.oliDescription;
            //EDGE-205510 -- Start
            if(oLiWrap.rateCardGroupIdentifier != null)
                oOLI.rateGroupIdentifier__c = oLiWrap.rateCardGroupIdentifier;
            //EDGE-205510 -- End
            oOLI.Product_Configuration__c   =   oLiWrap.productConfigId;
            oOLI                            =   getTmpOpportunityLineItem(oOLI, oliWrap); 
            if(oOLI.Product_Name__c == null || oOLI.Product_Name__c == '') {    //Product Name popuation for Modular products EDGE-11104
                oOLI.Product_Name__c = oOLI.Description;
            }
            if(oOLI.Product_Name__c != null && oOLI.Product_Code__c != null && codeNamePriceItemMap.containsKey(oOLI.Product_Name__c+oOLI.Product_Code__c)) {    //EDGE-13250
                oOLI.Product_Family__c      =   codeNamePriceItemMap.get(oOLI.Product_Name__c+oOLI.Product_Code__c).Product_Family__c;
                oOLI.Product_Group__c       =   codeNamePriceItemMap.get(oOLI.Product_Name__c+oOLI.Product_Code__c).Product_Group__c;
                oOLI.Ultimate_Product__c    =   codeNamePriceItemMap.get(oOLI.Product_Name__c+oOLI.Product_Code__c).Ultimate_Product__c;    
            }
            oOLI                            =  opportunityLineItemMapping(oOLI,oliWrap);
            
            lstOLI.add(oOLI);
        }
        ////EDGE-192806
        
        if(isInflight){
            InflightProductUtilityForModular.processOLIs(lstOLI,newPCIdOLIWrapperMap,oldOlis);
        }
        
        if( !lstOLI.isEmpty() && !isInflight) {
            SobjectFactory.insertSobjectList(lstOLI);
        }  
        
        
    }
    //EDGE-178204 added by ankit || start
    @TestVisible
    private  OpportunityLineItem opportunityLineItemMapping(OpportunityLineItem oOLI,OLIWrapper oLiWrap){
        
        oOLI.Once_Off_Revenue__c        =   ((oOLI.One_Off_Price__c > 0.00) ? (oOLI.One_Off_Price__c * oOLI.Quantity) : 0.00);  // 
        oOLI.OfferName__c               =   (String.isNotBlank(oLiWrap.offerName) ? oLiWrap.offerName : ''); 
        List<string> subTypeList=label.pcSubType.split(',');
        if(subTypeList.contains(oLiWrap.pcSubType)) 
            oOLI.Order_Type__c =  oLiWrap.pcSubType; 
        else 
            oOLI.Order_Type__c =  oLiWrap.prodConfigType;
        if(oLiWrap.afdMapWarp !=null && !oLiWrap.afdMapWarp.isEmpty()){
            for(string oliKey:OLIMapped.keyset()){
                if(oLiWrap.afdMapWarp.containsKey(oliKey) && OLIMapped.get(oliKey).Datatype__c== 'Decimal' && oLiWrap.afdMapWarp.get(oliKey) != null ){
                    oOLI.put(OLIMapped.get(oliKey).To_Field__c,Decimal.valueOf(oLiWrap.afdMapWarp.get(oliKey)));
                }
                else if(oLiWrap.afdMapWarp.containsKey(oliKey) && OLIMapped.get(oliKey).Datatype__c == 'Date'  && oLiWrap.afdMapWarp.get(oliKey) != null){
                    oOLI.put(OLIMapped.get(oliKey).To_Field__c,Date.valueOf(oLiWrap.afdMapWarp.get(oliKey)));
                    
                }
                else if(oLiWrap.afdMapWarp.containsKey(oliKey) && oLiWrap.afdMapWarp.get(oliKey) != null){
                    oOLI.put(OLIMapped.get(oliKey).To_Field__c,oLiWrap.afdMapWarp.get(oliKey));
                    
                }
            }
        }
        //EDGE-195671 
        if(!json_sio_ids.contains(oOLI.cscfga__Attribute__c))
            oOLI.New_Income_Revenue__c      =   ((oOLI.Delta_Recurring__c  > 0.00) ? (oOLI.Delta_Recurring__c  * oOLI.Quantity * Decimal.valueof(Label.Contract_Term_For_New_Income)) : 0.00);
           
        List<string> orderTypeList=label.migrationOrderType.split(',');
        if(orderTypeList.contains(oLiWrap.pcSubType)){
        //Updated as a part of EDGE-187655
            if(oOLI.Technology_Transformation_RevenueCur__c == null){
                oOLI.Technology_Transformation_RevenueCur__c    =   oOLI.New_Income_Revenue__c+ oOLI.Once_Off_Revenue__c;     
            }
            oOLI.New_Income_Revenue__c                          =   null;
            oOLI.Once_Off_Revenue__c                            =null;
        }
        Integer diffMonth=0;
        if(oOLI.Activation_Date__c != null){
            Date today = Date.today();
            Date mydate = oOLI.Activation_Date__c ;
            diffMonth = mydate.monthsBetween(today);
        }
         //EDGE-178211,187998,181998,188858,187313
        if(!json_sio_ids.contains(oOLI.cscfga__Attribute__c)){
           // oOLI.New_Income_Revenue__c      =   ((oOLI.Delta_Recurring__c  > 0.00) ? (oOLI.Delta_Recurring__c  * oOLI.Quantity * Decimal.valueof(Label.Contract_Term_For_New_Income)) : 0.00);
            oOLI.Avg_Annualised_Revenue__c  =   ((oOLI.Recurring_Price__c > 0.00) ? (oOLI.New_Income_Revenue__c) : 0.00); 
            oOLI.Renewal_Revenue__c=((oLiWrap.replacedConfig!= null && oOLI.Recurring_Price__c != null && oOLI.Delta_Recurring__c != null && diffMonth   >= 12) ? (12 *(oOLI.Recurring_Price__c -oOLI.Delta_Recurring__c) * oOLI.Quantity) : null);
            //checking below to avoid override of non-zero value of downgrade revenue set by AFD
            if(oOLI.Downgrade_Revenue__c == null || oOLI.Downgrade_Revenue__c == 0)
            {
            oOLI.Downgrade_Revenue__c=((oOLI.Recurring_Price__c != null && oOLI.Delta_Recurring__c != null && oOLI.Delta_Recurring__c  < 0.00) ? (12 * (-1) *oOLI.Delta_Recurring__c * oOLI.Quantity) : null);
            }
            oOLI.PreviousAnnuityRevenue__c=((oLiWrap.replacedConfig != null && oOLI.Recurring_Price__c != null && oOLI.Delta_Recurring__c !=null /*&& oOLI.Renewal_Revenue__c != null && oOLI.Renewal_Revenue__c > 0.00*/) ? (12 *(oOLI.Recurring_Price__c - oOLI.Delta_Recurring__c) * oOLI.Quantity) : null); // commented oOLI.Renewal_Revenue__c as part of EDGE-196640
            
        }
        return oOLI;
        
    }
    //EDGE-178204 added by ankit || end
    //Added by Pawan for EDGE# 127666
    @TestVisible
    private  OpportunityLineItem getTmpOpportunityLineItem(OpportunityLineItem tmpOpportunityLineItem, OLIWrapper tmpAttribute){
        
        if(tmpAttribute.isRecurring)
            tmpOpportunityLineItem.Recurring_Price__c   +=  tmpAttribute.UnitPrice;
        else
            tmpOpportunityLineItem.One_Off_Price__c     +=  tmpAttribute.UnitPrice;
		 //Changes for DIGI - 32161 by Natasha
        if(tmpAttribute.chargeFrequency!= Null &&  tmpAttribute.chargeFrequency == 'Daily')
        {            
            tmpOpportunityLineItem.New_Income_Revenue__c = 365 * tmpAttribute.UnitPrice * tmpAttribute.expectedSio;
        }
        else
        {
            tmpOpportunityLineItem.New_Income_Revenue__c = 12 * tmpAttribute.UnitPrice * tmpAttribute.expectedSio;
        } 
        /** Start **/
        //EDGE-178211,187998,181998,188858,187313
        if(tmpAttribute.attributeName == 'json_sios' && tmpAttribute.prodConfigType != 'cancel'){
            if(tmpAttribute.rateLineItemID != null){
            tmpOpportunityLineItem.RateLineItemID__c = tmpAttribute.rateLineItemID;
                tmpOpportunityLineItem.ExternalID__c = tmpAttribute.rateLineItemID;//EDGE-203443
            }
            
            if(tmpAttribute.prodConfigType.equalsIgnoreCase('Modify')){
                Integer monthDiff = 0;
                if( tmpAttribute.initialActivationDate != null){
                    Date a = tmpAttribute.initialActivationDate;
                    Date b = Date.today();
                    monthDiff = a.monthsBetween(b);
                    if (b.day() > a.day()) monthDiff++;    
                }
                
                if(tmpAttribute.actualSio>0)
                    tmpOpportunityLineItem.quantity = tmpAttribute.actualSio;
                //upgrade-- EDGE-200086
                if(tmpAttribute.actualSio * tmpAttribute.CurrentRate >= tmpAttribute.expectedSio * tmpAttribute.previousRate){
                    
                    tmpOpportunityLineItem.PreviousAnnuityRevenue__c  = tmpAttribute.expectedSio * tmpAttribute.previousRate * 12;
                    tmpOpportunityLineItem.New_Income_Revenue__c = tmpAttribute.actualSio * tmpAttribute.UnitPrice * 12;
                    if(monthDiff>12)
                    tmpOpportunityLineItem.Renewal_Revenue__c  = tmpAttribute.actualSio * tmpAttribute.CurrentRate * 12;
                    //downgrade
                }else{

                        tmpOpportunityLineItem.Downgrade_Revenue__c = tmpAttribute.actualSio * tmpAttribute.UnitPrice * 12;
                        tmpOpportunityLineItem.PreviousAnnuityRevenue__c  = tmpAttribute.expectedSio * tmpAttribute.previousRate * 12;
                        tmpOpportunityLineItem.New_Income_Revenue__c = 0;
                        if(monthDiff>12)
                        tmpOpportunityLineItem.Renewal_Revenue__c = tmpAttribute.actualSio * tmpAttribute.CurrentRate * 12;
                }
            }else{
                
                if(tmpAttribute.expectedSio>0)
                {   
                    tmpOpportunityLineItem.quantity = tmpAttribute.expectedSio;
                    tmpAttribute.UnitPrice = (tmpAttribute.UnitPrice==null)?0.00:tmpAttribute.UnitPrice;
                    tmpAttribute.expectedSio = (tmpAttribute.expectedSio==null)?0.00:tmpAttribute.expectedSio;
                    //Changes by Natasha DIGI-32161
                    if(tmpAttribute.chargeFrequency!= Null &&  tmpAttribute.chargeFrequency == 'Daily')
                    {            
                        tmpOpportunityLineItem.New_Income_Revenue__c = 365 * tmpAttribute.UnitPrice * tmpAttribute.expectedSio;
                    }//End of Changes by Natasha DIGI-32161
                    else
                    { 
                        tmpOpportunityLineItem.New_Income_Revenue__c = 12 * tmpAttribute.UnitPrice * tmpAttribute.expectedSio;
                    }
                }
                
            }
            
            
        }
        /** End **/
        if (tmpAttribute.isRecurring) {//isrecurring
            tmpOpportunityLineItem.Contract_Terms__c = String.valueof(tmpAttribute.contarctTerm);
        } 
        if(tmpAttribute.isPatner.contains('Partner')) {
            tmpOpportunityLineItem.Channel__c       =   'InDirect';
            tmpOpportunityLineItem.Partner_Info__c  =    mapSyncedProductBasket.get(tmpAttribute.ProductBasketId).csbb__Account__r.Name;
            tmpOpportunityLineItem.Dealer_Code__c   =    mapSyncedProductBasket.get(tmpAttribute.ProductBasketId).csbb__Account__r.Mobile_Code__c;
        } else {
            tmpOpportunityLineItem.Channel__c       =   'Direct';
        }   
        if(tmpOpportunityLineItem.Recurring_Price__c!=null && tmpOpportunityLineItem.Recurring_Price__c > 0 
           && tmpAttribute.Quantity != null 
           && tmpAttribute.Quantity > 0 ) {
               tmpOpportunityLineItem.Recurring_Price__c = (tmpOpportunityLineItem.Recurring_Price__c/tmpAttribute.Quantity);
           }
        if(tmpOpportunityLineItem.One_Off_Price__c!=null && tmpOpportunityLineItem.One_Off_Price__c > 0 && tmpAttribute.Quantity!=null &&  tmpAttribute.Quantity>0 ){
            tmpOpportunityLineItem.One_Off_Price__c =   tmpOpportunityLineItem.One_Off_Price__c/tmpAttribute.Quantity;
        }
        Decimal contractTerm = (tmpAttribute.contarctTerm !=null ? decimal.valueof(tmpAttribute.contarctTerm) : 0); 
        tmpOpportunityLineItem.UnitPrice        =   (tmpOpportunityLineItem.Recurring_Price__c * contractTerm ) + tmpOpportunityLineItem.One_Off_Price__c;
        tmpOpportunityLineItem.Product_Status__c=   (tmpAttribute.prodConfigType=='Cancel'?'Lost':'Won');
        
        return tmpOpportunityLineItem;
    }  
    //Added by Samish for EDGE# 127666
    
    private static map<string,map<string,PBEntry>> MakePriceBookPBEntriesMap(map<string,string> mapProductBasketIdPriceBookId,list<cscfga__Attribute__c> lstAttribute,map<string,map<string,Product>> mapProductFamilymapProduct){
        list<PBEntry> lstPBEntry = new list<PBEntry>();
        map<string,map<string,PBEntry>> mapPriceBookIdmapPBEntry = new map<string,map<string,PBEntry>>(); 
        for (cscfga__Attribute__c tmpAttribute : lstAttribute){
            string tmpProductFamily = tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Family__c;
            string tmpLineItemDescription =  tmpAttribute.cscfga__Line_Item_Description__c;
            string tmpProductBasketId = tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__c;
            if (mapProductFamilymapProduct.containsKey(tmpProductFamily)){
                map<string,Product> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
                Boolean isRateLineItem = false;
                for(cscfga__Attribute_Field__c attrField: tmpAttribute.cscfga__Attribute_Fields__r){
                    if(attrField.Name.equalsIgnoreCase('isRateCardLineItem') && attrField.cscfga__Value__c.equalsIgnoreCase('True')){
                        isRateLineItem=true;
                    }
                }
                if (mapProduct.containsKey(tmpLineItemDescription)&& !isRateLineItem){
                    Product tmpProduct = mapProduct.get(tmpLineItemDescription);
                    string tmpProduct2Id = tmpProduct.Prod2.Id;
                    string tmpPriceBookId = mapProductBasketIdPriceBookId.get(tmpProductBasketId);
                    PBEntry tmpPBEntry = new PBEntry();
                    tmpPBEntry.PriceBookId=tmpPriceBookId;
                    tmpPBEntry.Product2Id=tmpProduct2Id;
                    if (tmpAttribute.cscfga__Value__c==null)
                        tmpPBEntry.UnitPrice=0;
                    else
                        tmpPBEntry.UnitPrice=decimal.valueOf(tmpAttribute.cscfga__Value__c);
                    tmpPBEntry.Name = tmpLineItemDescription;
                    if (mapPriceBookIdmapPBEntry.containsKey(tmpPriceBookId)){
                        map<string,PBEntry> mapPBEntry = mapPriceBookIdmapPBEntry.get(tmpPriceBookId);
                        if (!mapPBEntry.containsKey(tmpProduct2Id))
                            mapPBEntry.put(tmpProduct2Id,tmpPBEntry);
                    }
                    else{
                        map<string,PBEntry> mapPBEntry = new map<string,PBEntry>();
                        mapPBEntry.put(tmpProduct2Id,tmpPBEntry);
                        mapPriceBookIdmapPBEntry.put(tmpPriceBookId,mapPBEntry);
                    }
                }else{
                    /** Start**/
                    //EDGE-178211,187998,181998,188858,187313
                    if(isRateLineItem){
                        List<RateCardSIOWrapper.wrapSIO> siovalues = new  List<RateCardSIOWrapper.wrapSIO>();
                        if(tmpAttribute.Name == 'json_sios' && tmpAttribute.cscfga__Product_Configuration__r.Type__c != 'Cancel'){//EDGE-187988,EDGE-187313
                            string jsonsio = tmpAttribute.cscfga__Value__c;
                            jsonsio = jsonsio.replaceall('\'','\"');
                            if(String.isNotBlank(jsonsio))
                                siovalues = (List<RateCardSIOWrapper.wrapSIO>) JSON.deserialize(jsonsio, List<RateCardSIOWrapper.wrapSIO>.class);
                            
                            for(RateCardSIOWrapper.wrapSIO obj : siovalues){
                                PBEntry tmpPBEntry = new PBEntry();
                                if(obj.previousRate != null)
                                    decimal previousRate  = obj.previousRate;
                                if(obj.currentRate != null)
                                    decimal CurrentRate  = obj.currentRate;
                                string tmpProduct2Id;
                                if(obj.rateCardName != null && mapProduct.containskey(obj.rateCardName)){
                                    Product tmpProduct = mapProduct.get(obj.rateCardName);
                                    tmpProduct2Id = tmpProduct.Prod2.Id;   
                                }
                                
                                string tmpPriceBookId;
                                if(mapProductBasketIdPriceBookId.containskey(tmpProductBasketId))
                                    tmpPriceBookId = mapProductBasketIdPriceBookId.get(tmpProductBasketId);

                                tmpPBEntry.PriceBookId=tmpPriceBookId;
                                tmpPBEntry.Product2Id=tmpProduct2Id;
                                tmpPBEntry.Name = tmpLineItemDescription;
                                tmpPBEntry.UnitPrice = 0;

                                if(obj.rateCardName != null)
                                    tmpPBEntry.Name = obj.rateCardName;
                                if (mapPriceBookIdmapPBEntry.containsKey(tmpPriceBookId)){
                                    map<string,PBEntry> mapPBEntry = mapPriceBookIdmapPBEntry.get(tmpPriceBookId);
                                    if (!mapPBEntry.containsKey(tmpProduct2Id))
                                        mapPBEntry.put(tmpProduct2Id,tmpPBEntry);
                                }
                                else{
                                    map<string,PBEntry> mapPBEntry = new map<string,PBEntry>();
                                    mapPBEntry.put(tmpProduct2Id,tmpPBEntry);
                                    mapPriceBookIdmapPBEntry.put(tmpPriceBookId,mapPBEntry);
                                }
                            }
                            continue;
                        }
                        
                    }
                   /** End **/ 
                }
            }
        }
        system.debug('mapPriceBookIdmapPBEntry:::'+mapPriceBookIdmapPBEntry);
        
        return mapPriceBookIdmapPBEntry;
    }
    private static void createPriceBookEntries(map<string,map<string,PBEntry>> mapPriceBookIdmapPBEntry){
        set<string> setProduct2Id = new set<string>();
        list<PricebookEntry> lstPricebookEntryInsert = new list<PricebookEntry>(); 
        for (map<string,PBEntry> mapPBEntry : mapPriceBookIdmapPBEntry.values()){
            for (PBEntry tmpPBEntry : mapPBEntry.values()){
                setProduct2Id.add(tmpPBEntry.Product2Id);
            }
        }
        if (setProduct2Id.size() > 0){
            map<Id,PricebookEntry> mapPricebookEntry = new map<Id,PricebookEntry> ([select Id, IsActive, Name, Pricebook2Id, Product2Id, UnitPrice 
                                                                                    from PricebookEntry
                                                                                    where Product2Id in : setProduct2Id]);
            for (PricebookEntry tmpPricebookEntry : mapPricebookEntry.values()){
                string tmpPricebook2Id = tmpPricebookEntry.Pricebook2Id;
                string tmpProduct2Id = tmpPricebookEntry.Product2Id;
                if (mapPriceBookIdmapPBEntry.containsKey(tmpPricebook2Id)){
                    map<string,PBEntry> mapPBEntry = mapPriceBookIdmapPBEntry.get(tmpPricebook2Id);
                    if (mapPBEntry.containsKey(tmpProduct2Id)){
                        PBEntry tmpPBEntry = mapPBEntry.get(tmpProduct2Id);
                        tmpPBEntry.PBEntryId=tmpPricebookEntry.Id;
                    }
                }
            }
            for (map<string,PBEntry> mapPBEntry : mapPriceBookIdmapPBEntry.values()){
                for (PBEntry tmpPBEntry : mapPBEntry.values()){
                    if ((tmpPBEntry.PBEntryId=='') || (tmpPBEntry.PBEntryId==null)){
                        PricebookEntry tmpPricebookEntry = new PricebookEntry();
                        tmpPricebookEntry.IsActive = true;
                        tmpPricebookEntry.Pricebook2Id = tmpPBEntry.PriceBookId;
                        tmpPricebookEntry.Product2Id = tmpPBEntry.Product2Id;
                        tmpPricebookEntry.UnitPrice = tmpPBEntry.UnitPrice;
                        tmpPBEntry.PBE = tmpPricebookEntry;
                        lstPricebookEntryInsert.add(tmpPricebookEntry);
                    }   
                    else{
                        PricebookEntry tmpPricebookEntry = mapPricebookEntry.get(tmpPBEntry.PBEntryId);
                        tmpPBEntry.PBE=tmpPricebookEntry;
                    }   
                }
            }
        }
        if (lstPricebookEntryInsert.size() > 0) 
            insert lstPricebookEntryInsert;
    }   //End of createPriceBookEntries()
    private  map<string,map<string,Product>> createProducts2(list<cscfga__Attribute__c> lstAttribute){
        map<string,map<string,Product>> mapProductFamilymapProduct = new map<string,map<string,Product>>(); 
        map<String,String> productCodewithFamilyMap= new map<String,String>();
        map<String,String> productTypewithFamilyMap= new map<String,String>();
        for (cscfga__Attribute__c tmpAttribute : lstAttribute){
            string tmpProductFamily = tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Family__c;
            String product_code=tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
            String product_type=mapSyncedProductBasket.get(tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__c).cscfga__Opportunity__r.Product_Type__c;
            string tmpLineItemDescription = tmpAttribute.cscfga__Line_Item_Description__c;//GetOLILineItemDescription(tmpAttribute);
            //EDGE-178211,187998,181998,188858,187313
            if (mapProductFamilymapProduct.containsKey(tmpProductFamily)&& tmpAttribute.Name != 'json_sios'){
                map<string,Product> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
                if (!mapProduct.containsKey(tmpLineItemDescription)){
                    Product tmpProduct = new Product();
                    tmpProduct.ProductFamily=tmpProductFamily;
                    tmpProduct.LiniItemDescription=tmpLineItemDescription;
                    mapProduct.put(tmpLineItemDescription,tmpProduct);
                }
            }
            else{
                map<string,Product> mapProduct = new map<string,Product>();
                productCodewithFamilyMap.put(tmpProductFamily,product_code);
                productTypewithFamilyMap.put(tmpProductFamily,product_type);
                /** Start**/
                //EDGE-178211,187998,181998,188858,187313

                List<RateCardSIOWrapper.wrapSIO> siovalues = new  List<RateCardSIOWrapper.wrapSIO>();
                Map<string,object> sioValueMap = new Map<string,object>(); 
                if(tmpAttribute.Name == 'json_sios' && tmpAttribute.cscfga__Product_Configuration__r.Type__c != 'Cancel'){//EDGE-178211,187998,181998,188858,187313
                    string jsonsio = tmpAttribute.cscfga__Value__c;
                    jsonsio = jsonsio.replaceall('\'','\"');

                    if(String.isNotBlank(jsonsio))
                        siovalues = (List<RateCardSIOWrapper.wrapSIO>) JSON.deserialize(jsonsio, List<RateCardSIOWrapper.wrapSIO>.class);
                    
                    for(RateCardSIOWrapper.wrapSIO obj : siovalues){
                        Product tmpProduct = new Product();
                        tmpProduct.ProductFamily=tmpProductFamily;
                        if(obj.rateCardName != null)
                            tmpProduct.LiniItemDescription=obj.rateCardName;

                            if(mapProductFamilymapProduct.containsKey(tmpProductFamily)){
                                Map<String,Product> mapProductName = mapProductFamilymapProduct.get(tmpProductFamily);
                                mapProductName.put(tmpProduct.LiniItemDescription,tmpProduct);
                                mapProductFamilymapProduct.put(tmpProductFamily,mapProductName);
                            }else{

                        mapProduct.put(tmpProduct.LiniItemDescription,tmpProduct);
                        mapProductFamilymapProduct.put(tmpProductFamily,mapProduct);
                    }
                        
                    }
                    /** End **/
                }else if(tmpAttribute.Name != 'json_sios'){
                    
                    Product tmpProduct = new Product();
                    tmpProduct.ProductFamily=tmpProductFamily;
                    tmpProduct.LiniItemDescription=tmpLineItemDescription;
                    mapProduct.put(tmpLineItemDescription,tmpProduct);
                    mapProductFamilymapProduct.put(tmpProductFamily,mapProduct);
                }
                
            }
            
        }
        if (mapProductFamilymapProduct.size() > 0){
            map<id,Product2> updatemapProduct2=new map<id,Product2>();
            map<Id,Product2> mapProduct2 = new map<Id,Product2>([select Family, Id, IsActive, Name,ProductCode 
                                                                 from Product2
                                                                 where IsActive=true and Family in : mapProductFamilymapProduct.keySet()]);
            system.debug('mapProduct2'+mapProduct2);
            //EDGE-98254--Start
            for (Product2 tmpProduct2 : mapProduct2.values()){
                if(productTypewithFamilyMap.get(tmpProduct2.Family)=='Modular'){
                    for(String prdcd:productCodewithFamilyMap.keySet()){
                        if(tmpProduct2.Family==prdcd){
                            if(tmpProduct2.ProductCode != productCodewithFamilyMap.get(tmpProduct2.Family)) {
                                tmpProduct2.ProductCode=productCodewithFamilyMap.get(tmpProduct2.Family);
                                updatemapProduct2.put(tmpProduct2.id,tmpProduct2);
                            }
                        }
                    }
                }
                if (mapProductFamilymapProduct.containsKey(tmpProduct2.Family)){
                    map<string,Product> mapProduct = mapProductFamilymapProduct.get(tmpProduct2.Family);
                    if (mapProduct.containsKey(tmpProduct2.Name)){
                        Product tmpProduct = mapProduct.get(tmpProduct2.Name);
                        tmpProduct.Product2Id = tmpProduct2.Id;
                    }
                }
            }
            if(updatemapProduct2.size()>0)
                update updatemapProduct2.values();
            //EDGE-98254--End
            list<Product2> lstProduct2Insert = new list<Product2>();
            for (string tmpProductFamily : mapProductFamilymapProduct.keySet()){
                map<string,Product> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
                for (Product tmpProduct : mapProduct.values()){
                    if ((tmpProduct.Product2Id=='') || (tmpProduct.Product2Id==null)){
                        Product2 tmpProduct2 = new Product2();
                        tmpProduct2.Family=tmpProductFamily;
                        tmpProduct2.Name = tmpProduct.LiniItemDescription;
                        tmpProduct2.IsActive = true;
                        tmpProduct.Prod2 = tmpProduct2;
                        System.debug('tmpProduct2'+tmpProduct+' '+tmpProduct.LiniItemDescription);
                        lstProduct2Insert.add(tmpProduct2);
                    }
                    else{
                        Product2 tmpProduct2 = mapProduct2.get(tmpProduct.Product2Id);
                        tmpProduct.Prod2 = tmpProduct2;
                    }
                }
            }
            if (lstProduct2Insert.size() > 0)                 
                insert lstProduct2Insert;
        }       
        return mapProductFamilymapProduct;
    }   //End of createProducts2()
    
    public static void deleteOpportunityOLIs(Set<Id> setOpportunityIds){
        if (!setOpportunityIds.isEmpty()) {
            List<OpportunityLineItem> lstDeleteOLIs = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityIds];
            if(!lstDeleteOLIs.isEmpty()) {
                delete lstDeleteOLIs;
                
            }            
        }   
    } 
    //EDGE-178204 added by ankit || start 
    public void populateOLIWrapper(){
        List<OLIWrapper> tempList = new List<OLIWrapper>();
        
        for(cscfga__Attribute__c temp:lstAttribute){
            Map<string,string>attrFieldMap=new Map<string,string>();
            //EDGE-178211,187998,181998,188858,187313
            if(temp.Name != 'json_sios'){
                OLIWrapper oLiWrap=new OLIWrapper();
                oLiWrap.attributeId=temp.id;
                oLiWrap.attributeName=temp.Name;
                oLiWrap.productConfigId=temp.cscfga__Product_Configuration__c;
                oLiWrap.productConfigName=temp.cscfga__Product_Configuration__r.Name;
                oLiWrap.unitPrice=(temp.cscfga__Value__c !=null?decimal.valueOf(temp.cscfga__Value__c):0.00);
                oLiWrap.ProductBasketFamily=temp.cscfga__Product_Configuration__r.cscfga__Product_Family__c;
                oLiWrap.oliDescription=temp.cscfga__Line_Item_Description__c;
                oLiWrap.contarctTerm=string.valueOf(temp.cscfga__Product_Configuration__r.cscfga__Contract_Term__c); 
                oLiWrap.ProductBasketId=temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__c;
                oLiWrap.Quantity=temp.cscfga__Product_Configuration__r.cscfga__Quantity__c;
                oLiWrap.isRecurring=temp.cscfga__Recurring__c;
                oLiWrap.prodConfigType=temp.cscfga__Product_Configuration__r.Type__c;
                
                //EDGE-195270 - Start


                if(temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Description__c != null && temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Description__c.containsIgnoreCase('CHOWN Incoming')){
                  oLiWrap.prodConfigType= 'CHOWN';    
                }
                if(temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Description__c != null && temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Description__c.containsIgnoreCase('CHOWN Outgoing')){



                  oLiWrap.prodConfigType= 'CHOWN OUT';    
                }
                //EDGE-195270 - End
                oLiWrap.offerName=temp.cscfga__Product_Configuration__r.OfferName__c;
                oLiWrap.pcSubType=temp.cscfga__Product_Configuration__r.subType__c;
                //start : DIGI-25857
                Boolean newOrderType =  FeatureEligibilityChecker.determineFeatureEligiblity('newOrderType',null);
                if(newOrderType){
                    List<PermissionSetAssignment> perAssignments = [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment 
                                                            WHERE  PermissionSet.Name = 'ReactiveService_PS' AND AssigneeId=:UserInfo.getUserId()];
                    if(!perAssignments.isEmpty())
                    oLiWrap.pcSubType='New';
                }
                //END : DIGI-25857
                oLiWrap.isPatner=temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName;
                oLiWrap.replacedConfig=temp.cscfga__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c;
                oLiWrap.isRateLineItem=false;
                
                for(cscfga__Attribute_Field__c attrField: temp.cscfga__Attribute_Fields__r){
                    if(attrField.Name.equalsIgnoreCase('isRateLineItem') && attrField.cscfga__Value__c.equalsIgnoreCase('True')){
                        oLiWrap.isRateLineItem=true;
                    }
                    if(attrField.cscfga__Value__c !='' && attrField.cscfga__Value__c !=null){
                        attrFieldMap.put(attrField.Name,attrField.cscfga__Value__c);
                        oLiWrap.afdMapWarp=attrFieldMap;
                    }
                }
                
                oliWrapperList.add(oLiWrap);
                /** Start**/
            }else if (temp.Name == 'json_sios' && temp.cscfga__Product_Configuration__r.Type__c != 'Cancel'){//EDGE-178211,187998,181998,188858,187313
                json_sio_ids.add(temp.id);
                oliWrapperList.addall(createOLIsforRateCardLine(temp));
                continue;
            }
             /** End **/
        }
    }
     /** Start **/
    //EDGE-178211,187998,181998,188858,187313
    Public static list<OLIWrapper> createOLIsforRateCardLine(cscfga__Attribute__c temp){

        List<RateCardSIOWrapper.wrapSIO> siovalues = new  List<RateCardSIOWrapper.wrapSIO>();
        list<OLIWrapper> oliWrapList = new list<OLIWrapper>();
        string jsonsio = temp.cscfga__Value__c;
        jsonsio = jsonsio.replaceall('\'','\"');
        if(String.isNotBlank(jsonsio))
            siovalues = (List<RateCardSIOWrapper.wrapSIO>) JSON.deserialize(jsonsio, List<RateCardSIOWrapper.wrapSIO>.class);
        
        for(RateCardSIOWrapper.wrapSIO obj : siovalues){
            
            if(obj.expectedSIO >0 || obj.actualSIO >0){
                OLIWrapper oLiWrap_sios =new OLIWrapper();

                oLiWrap_sios.attributeId=temp.id;
                oLiWrap_sios.attributeName=temp.Name;
                oLiWrap_sios.productConfigId=temp.cscfga__Product_Configuration__c;
                oLiWrap_sios.productConfigName=temp.cscfga__Product_Configuration__r.Name;
                oLiWrap_sios.ProductBasketFamily=temp.cscfga__Product_Configuration__r.cscfga__Product_Family__c;
                oLiWrap_sios.oliDescription=temp.cscfga__Line_Item_Description__c;
                oLiWrap_sios.contarctTerm=string.valueOf(temp.cscfga__Product_Configuration__r.cscfga__Contract_Term__c); 
                oLiWrap_sios.ProductBasketId=temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__c;
                oLiWrap_sios.isRecurring=temp.cscfga__Recurring__c;
                oLiWrap_sios.prodConfigType=temp.cscfga__Product_Configuration__r.Type__c;
                oLiWrap_sios.offerName=temp.cscfga__Product_Configuration__r.OfferName__c;
                oLiWrap_sios.Quantity= 1;
                //Changes for DIGI - 32161 by Natasha
                if(obj.chargeFrequency != null)
                {
                    oLiWrap_sios.chargeFrequency = obj.chargeFrequency;
                }
                // if(temp.cscfga__Product_Configuration__r.OfferName__c != 'Telstra Collaboration'){ 
                if(temp.cscfga__Product_Configuration__r.OfferName__c != NGUC_OFFER_NAME){     // DIGI-5648
                    oLiWrap_sios.pcSubType=temp.cscfga__Product_Configuration__r.subType__c;   
                    
                }
                
                oLiWrap_sios.isPatner=temp.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName;
                oLiWrap_sios.replacedConfig=temp.cscfga__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c;


                oLiWrap_sios.initialActivationDate = temp.cscfga__Product_Configuration__r.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c;
                oLiWrap_sios.isRateLineItem=false;
                
                for(cscfga__Attribute_Field__c attrField: temp.cscfga__Attribute_Fields__r){
                    if(attrField.Name.equalsIgnoreCase('isRateCardLineItem') && attrField.cscfga__Value__c.equalsIgnoreCase('True')){
                        oLiWrap_sios.isRateLineItem=true;
                    } 
                } 

                if(obj.expectedSIO != null)
                    oLiWrap_sios.expectedSio  = obj.expectedSIO;
                if(obj.actualSIO != null)
                    oLiWrap_sios.actualSio  = obj.actualSIO;
                if(obj.previousRate != null)
                    oLiWrap_sios.previousRate  = obj.previousRate;
                if(obj.currentRate != null)
                    oLiWrap_sios.CurrentRate  = obj.currentRate;
                if(obj.rateCardId != null)
                    oLiWrap_sios.rateLineItemID  = obj.rateCardId;
                if(obj.rateCardName != null)
                    oLiWrap_sios.oliDescription = obj.rateCardName;

                //EDGE-205510 - Start
                if(obj.rateGroupIdentifier != null)
                    oLiWrap_sios.rateCardGroupIdentifier = obj.rateGroupIdentifier;
        //EDGE-205510 - End

                oLiWrap_sios.UnitPrice = math.abs(oLiWrap_sios.CurrentRate - oLiWrap_sios.previousRate);
                oliWrapList.add(oLiWrap_sios);    
            }
            
        }
        return oliWrapList;
    }
     /** End **/
    //EDGE-178204 added by ankit || End
    private class Product {
        public string ProductFamily {get;set;}
        public string LiniItemDescription {get;set;}
        public string Product2Id {get;set;}
        public Product2 Prod2 {get;set;}
    }
    private class PBEntry {
        public string PBEntryId {get;set;}
        public string PriceBookId {get;set;}
        public string Product2Id {get;set;}
        public double UnitPrice {get;set;}
        public string Name {get;set;}
        public PriceBookEntry PBE {get;set;}
    } 
    //EDGE-178204 added by ankit || start
    public class OLIWrapper{
        public String attributeId;
        public String attributeName;
        public String productConfigId;
        public String productConfigName;
        public Double UnitPrice;
        public String ProductBasketId; 
        public String ProductBasketFamily;
        public String OpportunityId; 
        public String LineItemDescription;
        public string contarctTerm;         
        public Double OneOffPrice;
        public Boolean isRecurring;
        public Boolean isRateLineItem;
        public String oliDescription;
        public String priceBookId;
        public Double Quantity;
        public String prodConfigType;
        public String offerName;
        public String isPatner;
        public String pcSubType;
        public String replacedConfig;
        public String chargeFrequency='Monthly'; //Changes for DIGI - 32161 by Natasha

        public date initialActivationDate;
        public Map<String,String> afdMapWarp; 
        //EDGE-178211,187998,181998,188858,187313
        /** Start **/
        public decimal expectedSio = 0.00;
        public decimal actualSio = 0.00;
        public decimal previousRate = 0.00;
        public decimal CurrentRate = 0.00;
        public String rateLineItemID;
        //EDGE-205510 - Added new variable to capture rateCardGroupIdentifier in OLI
        public String rateCardGroupIdentifier;
        /** End **/
    }
    //EDGE-178204 added by ankit || end
    /*
     * Created By: Payal Popat as a part of EDGE-198027/EDGE-199074/EDGE-205509
     * Modified By : Kamlesh Kumar
     * Purpose: Added this method to update Basket Job Id
     */ 
   public static void updateBasketwithJobId(String jobId,String jobName,Set<String> basketid,Map<String,String> updateBasketMap){
        //Disable ProductBasketTrigger for this user
        No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
        notriggers.Flag__c = true;
        upsert notriggers;
        
        List<cscfga__Product_Basket__c> lstProdBasket = new List<cscfga__Product_Basket__c>();
        //EDGE : 199074/205509 Added check for inflight operation
        if(updateBasketMap.size() > 0) {
            for(Id bskId : updateBasketMap.keySet()) {
               cscfga__Product_Basket__c objProdBas = new cscfga__Product_Basket__c(Id=bskId);
               objProdBas.sync_job_Id__c = updateBasketMap.get(bskId);
               lstProdBasket.add(objProdBas);
            }
        }
        //EDGE : 205509 For inflight basket
        else if(jobId.contains('syncJobId') || jobId.contains('fundJobId') || jobId.contains('submitJobId')) {
            for(cscfga__Product_Basket__c basket : [Select id,sync_job_Id__c from cscfga__Product_Basket__c  where Id =:basketid]) {
                if(String.isNotBlank(basket.sync_job_Id__c)) { //Added to fix Attempt to deference error while running test class. Needs to be handled
                     String jsonString = basket.sync_job_Id__c.replace(']', '');
                     jsonString = jsonString.replace('[','');
                     if(jobId.contains('syncJobId') && (!jobId.contains('fundJobId') || !jobId.contains('submitJobId'))) {
                            jobId = jobId;
                         }
                        
                     else if(jobId.contains('fundJobId') || jobId.contains('submitJobId')) {
                         String jobMsg = jobId;
                         jobId = '['+jsonString+','+jobMsg+']';
                     }
                     system.debug('updated jobId' +jobId);
                     cscfga__Product_Basket__c objProdBas = new cscfga__Product_Basket__c(Id=basket.id);
                     objProdBas.sync_job_Id__c = jobId;
                     lstProdBasket.add(objProdBas);
                     
                 }
                 else {
                    cscfga__Product_Basket__c objProdBas = new cscfga__Product_Basket__c(Id=basket.id);
                    objProdBas.sync_job_Id__c = jobId;
                    lstProdBasket.add(objProdBas);
                 }
            }    
        }
        //END : 199074
        //Update Product Basket - Opportunity sync
        else if(String.isNotBlank(jobId)) {
          for(String bktId :basketid){
            cscfga__Product_Basket__c objProdBas = new cscfga__Product_Basket__c(Id=bktId);
            objProdBas.sync_job_Id__c = jobId;
            lstProdBasket.add(objProdBas);
           }
        }
       if(lstProdBasket.size()>0) {
          update lstProdBasket;
         }
        
        //Enable Trigger again
        notriggers.Flag__c = false;
        update notriggers;
    }
}