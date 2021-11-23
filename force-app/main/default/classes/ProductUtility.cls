/*
1.  EDGE-79675  :   Jayesh          :               :   Mapping ETC charges in OLIs
2.  EDGE-133414 :   Laxmi Rahate    :   10/04/2020  :   Changes for TCV
3.  EDGE-172955 :   Shweta M        :   18/09/2020  :   Caching custom settings for performance reasons
4.  EDGE-178203 :   Pooja Bhat      :   22/09/2020  :   Technical Refactoring - Opportunity Sync - DML Operations
5.  EDGE-185162 :   Adityen         :  19/10/2020   :   Pricing Service & Frame Agreements Package 
6.  EDGE-185438 :   Jagadeshwary    :   20/10/2020  :   Pricing service & Frame Agreements
7.  EDGE-173495 :   Ankit Goswami   :   10/12/2020  :`  Device Transition configuration
*/
public with sharing class ProductUtility {
    //EDGE-172955 : caching custom settings for performance reasons
    private static OLI_Sync__c OliSyncInstance {
        get {
            if (OliSyncInstance == null) {
                OliSyncInstance = OLI_Sync__c.getInstance(UserInfo.getUserId());
            }
            return OliSyncInstance;
        }
        set;
    }
   @future
   public static void createOLIsAsync(Set<String> setProductBasketId) {
        Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());    // Custom setting used to disable all the validation rules for the current running user. 
        if (ecCusSetting.No_Validations__c == false) {  
            ecCusSetting.No_Validations__c = true;
            upsert ecCusSetting;
        }
        try {
            createOLIs(setProductBasketId);    
            Map<Id,cscfga__Product_Basket__c> mapSyncedProductBasket = new Map<Id,cscfga__Product_Basket__c>([SELECT Id,cscfga__Opportunity__c,csordtelcoa__Basket_Stage__c,cscfga__total_contract_value__c,Primary_Basket__c FROM cscfga__Product_Basket__c WHERE Id IN: setProductBasketId]);            
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
        }
        if (ecCusSetting.Id != null && ecCusSetting.No_Validations__c == true) {    //After Basket sync, enable the validation rules for the current running user.
            ecCusSetting.No_Validations__c = false;
            update ecCusSetting;
        }
   }
    public static void createOLIs(Set<String> setProductBasketId){
        /*
            --select all attributes which are line items
            --check if combinations of Product Family and Line Item Description exist in Product2
            --for the ones which do exist - get Product2.Id
            --for the others - insert and get Product2.Id
            --select standard price book
            --check if there is an existing combination of PriceBook and Product2 in PriceBookEntry
            --if it doesn't exist - create and get PriceBookEntry.Id
            --if it does exist - get PriceBookEntry.Id
            -- enter all PriceBookEntries into OLIs
        */
        Map<String,String> mapProductBasketIdPriceBookId            =   new AssignnPriceBookToProductBasketImpl().AssignPriceBook(setProductBasketId);
        List<cscfga__Attribute__c> lstAttribute                     =   getListOfAttributes(mapProductBasketIdPriceBookId.keySet());   //Changed by Samish for EDGE# 127666
        Map<String,map<String,Product>> mapProductFamilymapProduct  =   CreateProducts2(lstAttribute); //this is the map where the keys are: ProductFamily and ProductName (LineItemDescription) 
        Map<String,map<String,PBEntry>> mapPriceBookIdmapPBEntry    =   MakePriceBookPBEntriesMap(mapProductBasketIdPriceBookId,lstAttribute,mapProductFamilymapProduct); //this is the map where the keys are: PriceBookId and Product2Id
        createPriceBookEntries(mapPriceBookIdmapPBEntry);   //this function is void because it just modifies mapPriceBookIdmapPBEntry, so no need for return
        createOppLineItems(mapProductBasketIdPriceBookId,lstAttribute,mapProductFamilymapProduct,mapPriceBookIdmapPBEntry); //this function takes all structures created before and generates OLIs

        List<cscfga__Product_Configuration__c> pcList               = GetProdConfigs(setProductBasketId);    
        if(!pcList.isEmpty()){
            mapProductFamilymapProduct                              = createProducts2forPREConfigs(pcList);
            mapPriceBookIdmapPBEntry                                = MakePriceBookPBEntriesMapforPREConfig(mapProductBasketIdPriceBookId,pcList,mapProductFamilymapProduct);
            CreateOLIsForPREConfigs(mapProductBasketIdPriceBookId,pcList,mapProductFamilymapProduct,mapPriceBookIdmapPBEntry);
        }

    }   //End of CreateOLIs(Set<String> setProductBasketId)
    //Added by Samish for EDGE# 127666
    private static List<cscfga__Attribute__c> getListOfAttributes(Set<String> productBasketIdKeySet){
        list<cscfga__Attribute__c> lstAttribute = 
                [SELECT Id, Name, cscfga__is_active__c, cscfga__Value__c, cscfga__Is_Line_Item__c, cscfga__Line_Item_Description__c, 
                cscfga__Line_Item_Sequence__c, cscfga__Price__c, cscfga__List_Price__c, cscfga__Recurring__c, 
                cscfga__Attribute_Definition__r.cscfga__Line_Item_Sequence__c, 
                cscfga__Product_Configuration__c, 
                cscfga__Product_Configuration__r.Name, 
                cscfga__Product_Configuration__r.Type__c,
                cscfga__Product_Configuration__r.OfferName__c,
                cscfga__Product_Configuration__r.cscfga__Quantity__c, 
                cscfga__Product_Configuration__r.cscfga__Contract_Term__c,
                cscfga__Product_Configuration__r.cscfga__Product_Family__c, 
                cscfga__Product_Configuration__r.cscfga__Product_Basket__c,
                cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c, 
                cscfga__Product_Configuration__r.Quantity_Product_Configuration__c,
                cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c,
                cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c,
                cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c,
                cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.Name,
                cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.Mobile_Code__c,
                cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName,
				cscfga__Product_Configuration__r.subType__c   // EDGE-173495 added by ankit
				FROM cscfga__Attribute__c
				WHERE (cscfga__Is_Line_Item__c = true OR Name='ProductCode' OR Name='ProductMaximName') AND (NOT Name like '%Price_Adjustment%') 
				AND cscfga__is_active__c = true AND cscfga__Product_Configuration__r.cscfga__Product_Basket__c IN:productBasketIdKeySet];
        return lstAttribute;
    }
    private static void createOppLineItems(map<string,string> mapProductBasketIdPriceBookId, list<cscfga__Attribute__c> lstAttribute, map<string,map<string,Product>> mapProductFamilymapProduct, map<string,map<string,PBEntry>> mapPriceBookIdmapPBEntry) {
        OLI_Sync__c OLISync             =   OliSyncInstance; //EDGE-172955 : AB caching for performance
        Boolean productConfLevel        =   (OLISync != null ? OLISync.Product_Configuration_Level__c : false);  
        Set<Id> oppIdSet                =   new Set<Id>();
        List<String> pcodeList          =   new List<String>();
        List<String> pMaxNameList       =   new List<String>();
        List<OpportunityLineItem> lstOLI=   new List<OpportunityLineItem>(); 
        Map<String,OpportunitySyncAttribute__mdt> syncattrMap   =   new Map<String,OpportunitySyncAttribute__mdt>();    //Map Key Values of 'OpportunitySyncAttribute'
        Map<String,cspmb__Price_Item__c> codeNamePriceItemMap   =   new Map<String,cspmb__Price_Item__c>();
        Map<String, String> incrementalRevenueMap               =   new Map<String, String>();   
        List<OpportunitySyncAttribute__mdt> syncAttrList = [SELECT DeveloperName, MasterLabel, Datatype__c FROM OpportunitySyncAttribute__mdt];    //Retrieve Fields from Custom Metadata type 'OpportunitySyncAttribute'
        for(OpportunitySyncAttribute__mdt syc : syncAttrList) {
            syncAttrMap.put(syc.DeveloperName, syc);    //Put Values from Map OpportunitySyncAttribute__mdt
        }
        //EDGE-13250
        for (cscfga__Attribute__c attr : lstAttribute) {
            if(attr.Name == 'ProductCode' && attr.cscfga__Value__c != null)
                pCodeList.add(attr.cscfga__Value__c);
            if(attr.Name == 'ProductMaximName' && attr.cscfga__Value__c != null)
                pMaxNameList.add(attr.cscfga__Value__c);
            if(attr.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c!=null)
                oppIdSet.add(attr.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c);
        }
        List<cspmb__Price_Item__c> priceItemList    =   [SELECT Name, Maxim_Product_Name__c, Product_Code__c, Product_Family__c, Product_Group__c, Ultimate_Product__c
                                                            FROM cspmb__Price_Item__c 
                                                            WHERE Product_Code__c IN:pCodeList AND Maxim_Product_Name__c IN :pMaxNameList];
        for(cspmb__Price_Item__c priceItem : priceItemList) {
            codeNamePriceItemMap.put(priceItem.Maxim_Product_Name__c + priceItem.Product_Code__c, priceItem);
        }
         // EDGE-131729 - Getting the list of IncrementaRevenue Attributes and their values on the Opportunity
         List<cscfga__Attribute_Field__c> attributeFieldList = [SELECT Id, cscfga__Attribute__c, cscfga__Value__c,Name
                                                                FROM cscfga__Attribute_Field__c 
                                                                WHERE cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c =:oppIdSet  
                                                                    AND name IN ('IncrementalRevenue','TechTransRevenue') ]; // Added TechTransRevenue as part of EDGE-173495 by ankit
        Map<string,string>techRevenuemap=new Map<string,string>();//Added As part of EDGE-173495
        for (cscfga__Attribute_Field__c attributeField : attributeFieldList ){
            if(attributeField.name=='IncrementalRevenue'){
                incrementalRevenueMap.put(attributeField.cscfga__Attribute__c, attributeField.cscfga__Value__c);   //EDGE-131729 - Added Map as additional Paremeter in Method Call
            }else if(attributeField.name=='TechTransRevenue'){ 
                    techRevenuemap.put(attributeField.cscfga__Attribute__c, attributeField.cscfga__Value__c);  //Added As part of EDGE-173495
            }

        }
        for (cscfga__Attribute__c att : lstAttribute) { 
            if(att.cscfga__Is_Line_Item__c) {            
                Double tmpUnitPrice             =   att.cscfga__Price__c;
                String tmpProductFamily         =   att.cscfga__Product_Configuration__r.cscfga__Product_Family__c;
                String tmpProductBasketId       =   att.cscfga__Product_Configuration__r.cscfga__Product_Basket__c;
                string tmpOpportunityId         =   att.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c;
                String tmpLineItemDescription   =   (productConfLevel ? att.cscfga__Product_Configuration__r.Name : att.cscfga__Line_Item_Description__c);//GetOLILineItemDescription(att);
                String tmpPriceBookId           =   mapProductBasketIdPriceBookId.get(tmpProductBasketId);
                Map<string,Product> mapProduct  =   mapProductFamilymapProduct.get(tmpProductFamily);
                Product tmpProduct              =   mapProduct.get(tmpLineItemDescription);
                String tmpProduct2Id            =   tmpProduct.Prod2.Id;
                Map<string,PBEntry> mapPBEntry  =   mapPriceBookIdmapPBEntry.get(tmpPriceBookId);
                PBEntry tmpPBEntry              =   mapPBEntry.get(tmpProduct2Id);
                String tmpPriceBookEntryId      =   tmpPBEntry.PBE.Id;
                OpportunityLineItem oOLI        =   new OpportunityLineItem();
                oOLI.UnitPrice                  =   0.00;
                oOLI.One_Off_Price__c           =   0.00;
                oOLI.Recurring_Price__c         =   0.00;
                oOLI.cscfga__Attribute__c       =   att.Id;
                oOLI.OpportunityId              =   tmpOpportunityId;
                oOLI.PricebookEntryId           =   tmpPriceBookEntryId;
                oOLI.Quantity                   =   att.cscfga__Product_Configuration__r.cscfga__Quantity__c;
                oOLI.Description                =   tmpLineItemDescription;
                oOLI                            =   getTmpOpportunityLineItem(oOLI, att);     //Added by Pawan for EDGE# 127666                                        
                if(syncAttrMap.containsKey(att.Name) && att.cscfga__Value__c != null) {
                    if(syncAttrMap.get(att.Name).Datatype__c== 'Decimal')
                        oOLI.put(syncAttrMap.get(att.Name).MasterLabel,Decimal.valueOf(att.cscfga__Value__c));
                    else
                        oOLI.put(syncAttrMap.get(att.Name).MasterLabel,att.cscfga__Value__c);
                }
                if(oOLI.Product_Name__c == null || oOLI.Product_Name__c == '') {    //Product Name popuation for Modular products EDGE-11104
                    oOLI.Product_Name__c = oOLI.Description;
                } 
                if(oOLI.Product_Name__c != null && oOLI.Product_Code__c != null) {    //EDGE-13250
                    if(codeNamePriceItemMap.containsKey(oOLI.Product_Name__c+oOLI.Product_Code__c)) {
                        oOLI.Product_Family__c      =   codeNamePriceItemMap.get(oOLI.Product_Name__c+oOLI.Product_Code__c).Product_Family__c;
                        oOLI.Product_Group__c       =   codeNamePriceItemMap.get(oOLI.Product_Name__c+oOLI.Product_Code__c).Product_Group__c;
                        oOLI.Ultimate_Product__c    =   codeNamePriceItemMap.get(oOLI.Product_Name__c+oOLI.Product_Code__c).Ultimate_Product__c;

                    }
                }

                if(att.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c == 'Modular') {          
                    oOLI.New_Income_Revenue__c      =   ((oOLI.Recurring_Price__c > 0.00) ? (oOLI.Recurring_Price__c * oOLI.Quantity * Decimal.valueof(Label.Contract_Term_For_New_Income)) : 0.00);    // EDGE-61607
                    oOLI.Avg_Annualised_Revenue__c  =   ((oOLI.Recurring_Price__c > 0.00) ? (oOLI.New_Income_Revenue__c) : 0.00); // EDGE-61607
                    oOLI.Once_Off_Revenue__c        =   ((oOLI.One_Off_Price__c > 0.00) ? (oOLI.One_Off_Price__c * oOLI.Quantity) : 0.00);  // EDGE-61607
                    oOLI.Incremental_Revenue__c     =   ((incrementalRevenueMap.containsKey(oOLI.cscfga__Attribute__c) && String.isNotBlank(incrementalRevenueMap.get(oOLI.cscfga__Attribute__c))) ? Decimal.valueof(incrementalRevenueMap.get(oOLI.cscfga__Attribute__c)) : 0.00); // EDGE-131729 - setting the incremental Revenue field from the MAP incrementalRevenueMap
                    oOLI.OfferName__c               =   (String.isNotBlank(att.cscfga__Product_Configuration__r.OfferName__c) ? att.cscfga__Product_Configuration__r.OfferName__c : '');
                    oOLI.OfferName__c               =   (oOLI.OfferName__c=='Connected Workplace Package'?'Connected Workplace':oOLI.OfferName__c); //EDGE-20138 
					//EDGE-173495  added ordertype || start
                    oOLI.Technology_Transformation_RevenueCur__c   =  ((techRevenuemap.containsKey(oOLI.cscfga__Attribute__c) && String.isNotBlank(techRevenuemap.get(oOLI.cscfga__Attribute__c))) ? Decimal.valueof(techRevenuemap.get(oOLI.cscfga__Attribute__c)) : 0.00); 
                    oOLI.Order_Type__c = (String.isNotBlank(att.cscfga__Product_Configuration__r.subType__c) ? att.cscfga__Product_Configuration__r.subType__c : ''); 
                    //EDGE-173495  added ordertype || end
                } else if(att.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c != 'Modular') { // EDGE-133414 - the below code should be run only for Non Modular
                    oOLI.UnitPrice = ( (String.isNotBlank(oOLI.Product_Status__c) && (oOLI.Product_Status__c == 'Lost' || oOLI.Product_Status__c == 'Withdrawn')) ? 0.00 : (att.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c));
                    oOLI.UnitPrice = ( (oOLI.Quantity!=null && oOLI.UnitPrice!=null && oOLI.Quantity!=0) ? (oOLI.UnitPrice/oOLI.Quantity) : 0.00);  ////added 0 check by shubhi EDGE-142888
                } 
                lstOLI.add(oOLI);
            }
        }   //End of for (cscfga__Attribute__c tmpAttribute : lstAttribute)
        if( !lstOLI.isEmpty()) {
            insert lstOLI;
        }  
    }   //End of createOppLineItems()
    //Added by Pawan for EDGE# 127666
    @TestVisible
    private static OpportunityLineItem getTmpOpportunityLineItem(OpportunityLineItem tmpOpportunityLineItem, cscfga__Attribute__c tmpAttribute){
        if (tmpAttribute.cscfga__Price__c != null){
            if(tmpAttribute.cscfga__Recurring__c)
                tmpOpportunityLineItem.Recurring_Price__c   +=  tmpAttribute.cscfga__Price__c;
            else
                tmpOpportunityLineItem.One_Off_Price__c     +=  tmpAttribute.cscfga__Price__c;
        }  
        //  EDGE-61607  Start    
        if(tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c=='Modular') {
            //EDGE-79675 Start
            if(tmpAttribute.cscfga__Product_Configuration__r.Type__c=='Cancel' && (tmpAttribute.Name.contains('ETC') || tmpAttribute.Name.contains('EarlyTerminationCharge')))
            {
                tmpOpportunityLineItem.Early_Termination_Charge__c  =   Decimal.valueof(tmpAttribute.cscfga__Value__c);
                tmpOpportunityLineItem.One_Off_Price__c             =   0;
                tmpOpportunityLineItem.Once_Off_Revenue__c          =   0;
                tmpOpportunityLineItem.Incremental_Revenue__c       =   0;
                tmpOpportunityLineItem.UnitPrice                    =   0;
            }   //EDGE-79675 End           
            //EDGE - 133414 Added below condition to set Contract Term only when its recurring charge 
            if (tmpAttribute.cscfga__Recurring__c) {
                tmpOpportunityLineItem.Contract_Terms__c = String.valueof(tmpAttribute.cscfga__Product_Configuration__r.cscfga__Contract_Term__c);
            }   //EDGE - 133414  END 
            //code for Indirect/Direct--start here//
            if((tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName).contains('Partner')) {
                tmpOpportunityLineItem.Channel__c       =   'InDirect';
                tmpOpportunityLineItem.Partner_Info__c  =   tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.Name;
                tmpOpportunityLineItem.Dealer_Code__c   =   tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__r.Mobile_Code__c;
            } else {
                tmpOpportunityLineItem.Channel__c       =   'Direct';
            }   //code for Indirect/Direct--End here//
            //EDGE-133414 Added && tmpOpportunityLineItem.One_Off_Price__c > 0 in beflow if
            if(tmpOpportunityLineItem.Recurring_Price__c!=null && tmpOpportunityLineItem.Recurring_Price__c > 0 
                && tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c != null 
                && tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c > 0 ) {
                tmpOpportunityLineItem.Recurring_Price__c = (tmpOpportunityLineItem.Recurring_Price__c/tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c);
            }
            //EDGE-133414 Added && tmpOpportunityLineItem.One_Off_Price__c > 0 in beflow if
            if(tmpOpportunityLineItem.One_Off_Price__c!=null && tmpOpportunityLineItem.One_Off_Price__c > 0 && tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c!=null &&  tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c>0 ){ //Addded not null check by Venkata
                tmpOpportunityLineItem.One_Off_Price__c =   tmpOpportunityLineItem.One_Off_Price__c/tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c;
            }
            //Added as part of EDGE-133414
            Decimal contractTerm = (tmpAttribute.cscfga__Product_Configuration__r.cscfga__Contract_Term__c!=null ? tmpAttribute.cscfga__Product_Configuration__r.cscfga__Contract_Term__c : 0); 
            tmpOpportunityLineItem.UnitPrice        =   (tmpOpportunityLineItem.Recurring_Price__c * contractTerm ) + tmpOpportunityLineItem.One_Off_Price__c;
            tmpOpportunityLineItem.Product_Status__c=   (tmpAttribute.cscfga__Product_Configuration__r.Type__c=='Cancel'?'Lost':'Won');
        }   
        //  EDGE-61607 End
        return tmpOpportunityLineItem;
    }   //End of getTmpOpportunityLineItem()
    //Added by Samish for EDGE# 127666
    @TestVisible
    private static OpportunityLineItem populateOppLineItem() {
        OpportunityLineItem tmpOpportunityLineItem  =   new OpportunityLineItem(); 
        tmpOpportunityLineItem.UnitPrice            =   0;
        tmpOpportunityLineItem.One_Off_Price__c     =   0;
        tmpOpportunityLineItem.Recurring_Price__c   =   0;
        return tmpOpportunityLineItem;
    }
    private static map<string,map<string,PBEntry>> MakePriceBookPBEntriesMap(map<string,string> mapProductBasketIdPriceBookId,list<cscfga__Attribute__c> lstAttribute, 
                                                                             map<string,map<string,Product>> mapProductFamilymapProduct){
        list<PBEntry> lstPBEntry = new list<PBEntry>();
        map<string,map<string,PBEntry>> mapPriceBookIdmapPBEntry = new map<string,map<string,PBEntry>>(); 
        OLI_Sync__c OLISync             =   OliSyncInstance; //EDGE-172955 : AB caching for performance
        Boolean productConfLevel        =   (OLISync != null ? OLISync.Product_Configuration_Level__c : false);  
        for (cscfga__Attribute__c tmpAttribute : lstAttribute){
            if(tmpAttribute.cscfga__Is_Line_Item__c) {
                string tmpProductFamily = tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Family__c;
                string tmpLineItemDescription = (productConfLevel ? tmpAttribute.cscfga__Product_Configuration__r.Name : tmpAttribute.cscfga__Line_Item_Description__c);//GetOLILineItemDescription(tmpAttribute);
                string tmpProductBasketId = tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__c;
                if (mapProductFamilymapProduct.containsKey(tmpProductFamily)){
                    map<string,Product> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
                    if (mapProduct.containsKey(tmpLineItemDescription)){
                        Product tmpProduct = mapProduct.get(tmpLineItemDescription);
                        string tmpProduct2Id = tmpProduct.Prod2.Id;
                        string tmpPriceBookId = mapProductBasketIdPriceBookId.get(tmpProductBasketId);
                        PBEntry tmpPBEntry = new PBEntry();
                        tmpPBEntry.PriceBookId=tmpPriceBookId;
                        tmpPBEntry.Product2Id=tmpProduct2Id;
                        if (tmpAttribute.cscfga__Price__c==null)
                            tmpPBEntry.UnitPrice=0;
                        else
                            tmpPBEntry.UnitPrice=tmpAttribute.cscfga__Price__c;
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
                    }
                }
            }
        }
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
    private static map<string,map<string,Product>> createProducts2(list<cscfga__Attribute__c> lstAttribute){
        map<string,map<string,Product>> mapProductFamilymapProduct = new map<string,map<string,Product>>(); 
        map<String,String> productCodewithFamilyMap= new map<String,String>();
        map<String,String> productTypewithFamilyMap= new map<String,String>();
        OLI_Sync__c OLISync     = OliSyncInstance; //EDGE-172955 : AB caching for performance
        Boolean productConfLevel= (OLISync != null ? OLISync.Product_Configuration_Level__c : false);  
        //String product_code='';
        for (cscfga__Attribute__c tmpAttribute : lstAttribute){
            if(tmpAttribute.cscfga__Is_Line_Item__c) {
                string tmpProductFamily = tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Family__c;
                String product_code=tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                String product_type=tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c;
                string tmpLineItemDescription = (productConfLevel ? tmpAttribute.cscfga__Product_Configuration__r.Name : tmpAttribute.cscfga__Line_Item_Description__c);//GetOLILineItemDescription(tmpAttribute);
                if (mapProductFamilymapProduct.containsKey(tmpProductFamily)){
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
                    Product tmpProduct = new Product();
                    tmpProduct.ProductFamily=tmpProductFamily;
                    tmpProduct.LiniItemDescription=tmpLineItemDescription;
                    mapProduct.put(tmpLineItemDescription,tmpProduct);
                    mapProductFamilymapProduct.put(tmpProductFamily,mapProduct);
                    productCodewithFamilyMap.put(tmpProductFamily,product_code);
                    productTypewithFamilyMap.put(tmpProductFamily,product_type);
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
    /*public static void deleteHardOLIs(set<string> setProductBasketId) {
        list<cscfga__Product_Basket__c> lstPB = [SELECT Id, cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE Id in : setProductBasketId];
        set<Id> setOpportunityId = new set<Id>();
        for(cscfga__Product_Basket__c tmpPB : lstPB) {
            setOpportunityId.add(tmpPB.cscfga__Opportunity__c);
        }
        if (setOpportunityId.size() > 0) {
            delete ([SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityId]);
        }      
    }   //End of deleteHardOLIs() */
    /*  * Method Name   :   deleteOpportunityOLIs
    * Purpose       :   To delete all the Opportunity Products 
    * Params        :   none
    * Return Type   :   String
    * Called from   :   Class -> ProductBasketTriggerHandler, Method: deleteOLIsProductDetailsAfterUpdate
  */
    public static void deleteOpportunityOLIs(Set<Id> setOpportunityIds){
        if (!setOpportunityIds.isEmpty()) {
            List<OpportunityLineItem> lstDeleteOLIs = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityIds];
            if(!lstDeleteOLIs.isEmpty()) {
                delete lstDeleteOLIs;

            }            
        }   
    }   //End of deleteOpportunityOLIs()
    /*@TestVisible
    private static string GetOLILineItemDescription(cscfga__Attribute__c tmpAttribute){
        OLI_Sync__c OLISync     =   OliSyncInstance; //EDGE-172955 : AB caching for performance
        Boolean productConfLevel=   (OLISync != null ? OLISync.Product_Configuration_Level__c : false);  
        String OLIDescription   =   (productConfLevel ? tmpAttribute.cscfga__Product_Configuration__r.Name : tmpAttribute.cscfga__Line_Item_Description__c);
        return OLIDescription;
    }*/
    @TestVisible   
    private static List<cscfga__Product_Configuration__c> GetProdConfigs(set<string> setSyncedProductBasketId){ 
        // Added   cscfga__One_Off_Charge__c in SOQL related to EDGE-185162
        List<cscfga__Product_Configuration__c> pcList =  [SELECT Id, Name,cscfga__Product_Basket__c, cscfga__Product_Family__c, 
                                                          cscfga__Recurring_Charge__c,  cscfga__Quantity__c,Quantity_Product_Configuration__c,  
                                                          cscfga__Product_Definition__r.product_Specification__c, cscfga__Contract_Term__c,     
                                                          cscfga__Product_Basket__r.csbb__Account__r.Mobile_Code__c,    
                                                          cscfga__Product_Basket__r.csbb__Account__r.Name, cscfga__Product_Basket__r.csbb__Account__c,  
                                                          cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName,  
                                                          cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c, 
                                                          cscfga__total_recurring_charge__c,cscfga__total_one_off_charge__c, cscfga__Total_Price__c,    
                                                          cscfga__discounts__c,Type__c,cscfga__One_Off_Charge__c
                                                          FROM cscfga__Product_Configuration__c     
                                                          WHERE cscfga__Product_Basket__c IN :setSyncedProductBasketId];    
        List<cscfga__Product_Configuration__c> prePCList = new List<cscfga__Product_Configuration__c>();    
        for(cscfga__Product_Configuration__c prodConfig : pcList){  
            if(prodConfig.cscfga__discounts__c !=null){ 
                prePCList.add(prodConfig);  
            }   
        }   
        system.debug('prePCList...'+prePCList);
        return prePCList;   
    }   
    /* EDGE-169457
    Method Name : CreateOLIsForPREConfigs
    Creates OLI - populates values from Product configuration
    Map attribute values per PC for RC,OC population */
    
    private static void CreateOLIsForPREConfigs(map<string,string> mapProductBasketIdPriceBookId, list<cscfga__Product_Configuration__c> pcList,   
                               map<string,map<string,Product>> mapProductFamilymapProduct, map<string,map<string,PBEntry>> mapPriceBookIdmapPBEntry){   
        Boolean productConfLevel=false; 
        Boolean SumOneOffAndRecurring=false;    
        OLI_Sync__c OLISync = OLI_Sync__c.getInstance(UserInfo.getUserId());    
        if (OLISync != null){   
        productConfLevel=OLISync.Product_Configuration_Level__c;        
        SumOneOffAndRecurring=OLISync.Sum_One_Off_And_Recurring__c; 
        }   
        system.debug('****OLISync = ' + OLISync);   
        system.debug('****productConfLevel = ' + productConfLevel); 
        system.debug('****SumOneOffAndRecurring = ' + SumOneOffAndRecurring);   
        list<OpportunityLineItem> lstOLI = new list<OpportunityLineItem>(); 
        map<Id,OpportunityLineItem> mapPCIdOLI = new map<Id,OpportunityLineItem>(); 
        OpportunityLineItem tmpOpportunityLineItem; 
        set<string> setProductBasketId = new set<string>(); 
        //EDGE-185438 :begins:  Query attributes for incremental revenue 
        Map<Id,List<cscfga__Attribute_Field__c>> mapOfPcToAttr = new Map<Id,List<cscfga__Attribute_Field__c>>();
        for(cscfga__Attribute_Field__c  att:[SELECT Id, Name,cscfga__Value__c, cscfga__Attribute__r.Name,    
                                                        cscfga__Attribute__r.cscfga__Value__c,cscfga__Attribute__r.cscfga__Product_Configuration__c     
                                                        from cscfga__Attribute_Field__c     
                                                        Where cscfga__Attribute__r.cscfga__Product_Configuration__c in:pcList   
                                                        AND (cscfga__Attribute__r.Name = 'RC' OR cscfga__Attribute__r.Name = 'OC') 
                                                        AND Name = 'IncrementalRevenue' AND cscfga__Value__c != '']){
            if(mapOfPcToAttr.containskey(att.cscfga__Attribute__r.cscfga__Product_Configuration__c)){
                List<cscfga__Attribute_Field__c> tempList = mapOfPcToAttr.get(att.cscfga__Attribute__r.cscfga__Product_Configuration__c);
                tempList.add(att);
                mapOfPcToAttr.put(att.cscfga__Attribute__r.cscfga__Product_Configuration__c,tempList);
            }
            else{
                List<cscfga__Attribute_Field__c> tempList = new List<cscfga__Attribute_Field__c>();
                tempList.add(att);
                mapOfPcToAttr.put(att.cscfga__Attribute__r.cscfga__Product_Configuration__c,tempList);

            }                                         
        } 
        // End of EDGE-185438   
        for (cscfga__Product_Configuration__c pc : pcList){ 
            setProductBasketId.add(pc.cscfga__Product_Basket__c);    
        }   
        map<Id,cscfga__Product_Basket__c> mapProductBasket = new map<Id,cscfga__Product_Basket__c>([select Id,cscfga__Opportunity__c    
                                                                                           from cscfga__Product_Basket__c where Id in : setProductBasketId]);   
        for (cscfga__Product_Configuration__c pc : pcList){ 
        string tmpProductFamily = pc.cscfga__Product_Family__c; 
        string tmpLineItemDescription = pc.Name;    
        string tmpProductBasketId = pc.cscfga__Product_Basket__c;   
        string tmpPriceBookId = mapProductBasketIdPriceBookId.get(tmpProductBasketId);  
        //double tmpUnitPrice = tmpAttribute.cscfga__Price__c;  
        map<string,Product> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);  
        Product tmpProduct = mapProduct.get(tmpLineItemDescription);    
        string tmpProduct2Id = tmpProduct.Prod2.Id; 
        map<string,PBEntry> mapPBEntry = mapPriceBookIdmapPBEntry.get(tmpPriceBookId);  
        PBEntry tmpPBEntry = mapPBEntry.get(tmpProduct2Id); 
        string tmpPriceBookEntryId = tmpPBEntry.PBE.Id; 
        string tmpOpportunityId=mapProductBasket.get(tmpProductBasketId).cscfga__Opportunity__c;    
        if(productConfLevel){   
        tmpOpportunityLineItem = new OpportunityLineItem();  
        if(mapPCIdOLI.containsKey(pc.Id))    
           tmpOpportunityLineItem = mapPCIdOLI.get(pc.Id);  
        else{    
           tmpOpportunityLineItem = populateOppLineItem();  
           mapPCIdOLI.put(pc.Id,tmpOpportunityLineItem);    
        }    
        }   
        else{   
        tmpOpportunityLineItem = populateOppLineItem();  
        lstOLI.add(tmpOpportunityLineItem);  
        }   
        //tmpOpportunityLineItem.cscfga__Attribute__c=tmpAttribute.Id; //?? 
        tmpOpportunityLineItem.OpportunityId=tmpOpportunityId;  
        tmpOpportunityLineItem.PricebookEntryId=tmpPriceBookEntryId; //??   
        tmpOpportunityLineItem.Quantity=pc.cscfga__Quantity__c; 
        tmpOpportunityLineItem.Description=tmpLineItemDescription;  
        //Added by Pawan for EDGE# 127666   
        tmpOpportunityLineItem = getTmpOpportunityLineItemForPREconfigs(tmpOpportunityLineItem, pc, SumOneOffAndRecurring,mapOfPcToAttr.get(pc.Id));    //EDGE-185438 : adding map of PC and list of attributes

            }            
        if (mapPCIdOLI.size() > 0)   
        insert mapPCIdOLI.values();  
        else if (lstOLI.size() > 0)  
        insert lstOLI;   
        }   
    /* EDGE-169457
    Method Name : getTmpOpportunityLineItemForPREconfigs
    Assign field values to Opportunity line item from PC */
    @TestVisible   
    private static OpportunityLineItem getTmpOpportunityLineItemForPREconfigs(OpportunityLineItem tmpOpportunityLineItem,  cscfga__Product_Configuration__c pc, Boolean SumOneOffAndRecurring,List<cscfga__Attribute_Field__c> attrList){   // EDGE-185438 : added additional list parameter for attributes
    
        system.debug('pc.cscfga__Recurring_Charge__c...'+pc.cscfga__Recurring_Charge__c);
        system.debug('pc.cscfga__One_Off_Charge__c...'+pc.cscfga__One_Off_Charge__c);
        tmpOpportunityLineItem.Recurring_Price__c =pc.cscfga__Recurring_Charge__c;    //EDGE-185162 changed from cscfga__total_recurring_charge__c to cscfga__Recurring_Charge__c   
        tmpOpportunityLineItem.One_Off_Price__c =pc.cscfga__One_Off_Charge__c;        // EDGE-185162 changed From cscfga__total_one_off_charge__c to cscfga__One_Off_Charge__c
        system.debug('tmpOpportunityLineItem.Recurring_Price__c...'+tmpOpportunityLineItem.Recurring_Price__c);
        system.debug('tmpOpportunityLineItem.One_Off_Price__c...'+tmpOpportunityLineItem.One_Off_Price__c);
        if(pc.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c=='Modular'){ 
        if (pc.cscfga__Recurring_Charge__c != null || pc.cscfga__Recurring_Charge__c > 0) { 
            tmpOpportunityLineItem.Contract_Terms__c=string.valueof(pc.cscfga__Contract_Term__c);   
        }   
        if((pc.cscfga__Product_Basket__r.csbb__Account__r.RecordType.DeveloperName).contains('Partner')){   
            tmpOpportunityLineItem.Channel__c='InDirect';   
            tmpOpportunityLineItem.Partner_Info__c=pc.cscfga__Product_Basket__r.csbb__Account__r.Name;  
            tmpOpportunityLineItem.Dealer_Code__c=pc.cscfga__Product_Basket__r.csbb__Account__r.Mobile_Code__c; 
        }   
        else{   
            tmpOpportunityLineItem.Channel__c='Direct'; 
        }   
        if(tmpOpportunityLineItem.Recurring_Price__c!=null && tmpOpportunityLineItem.Recurring_Price__c > 0 && pc.cscfga__Quantity__c!=null && pc.cscfga__Quantity__c>0 ){  
            tmpOpportunityLineItem.Recurring_Price__c=tmpOpportunityLineItem.Recurring_Price__c/pc.cscfga__Quantity__c; 
        }   
        //EDGE-133414 Added && tmpOpportunityLineItem.One_Off_Price__c > 0 in beflow if 
        if(tmpOpportunityLineItem.One_Off_Price__c!=null && tmpOpportunityLineItem.One_Off_Price__c > 0 && pc.cscfga__Quantity__c!=null &&  pc.cscfga__Quantity__c>0 ){ //Addded not null check by Venkata  
            tmpOpportunityLineItem.One_Off_Price__c=tmpOpportunityLineItem.One_Off_Price__c/pc.cscfga__Quantity__c; 
        }   
        // Added as part of EDGE-133414 
        Decimal contractTerm = pc.cscfga__Contract_Term__c; 
        if (contractTerm==null) 
        {   
            contractTerm = 0;   
        }   
            System.debug('tmpOpportunityLineItem.One_Off_Price__c...'+tmpOpportunityLineItem.One_Off_Price__c);
            System.debug('contractTerm...'+contractTerm);
            System.debug('tmpOpportunityLineItem.Recurring_Price__c...'+tmpOpportunityLineItem.Recurring_Price__c);
            if(tmpOpportunityLineItem.One_Off_Price__c != null && tmpOpportunityLineItem.Recurring_Price__c !=null){
                tmpOpportunityLineItem.UnitPrice = (tmpOpportunityLineItem.Recurring_Price__c * contractTerm ) + tmpOpportunityLineItem.One_Off_Price__c; 
            }
        //tmpOpportunityLineItem.UnitPrice = (tmpOpportunityLineItem.Recurring_Price__c * contractTerm ) + tmpOpportunityLineItem.One_Off_Price__c;   
        if(tmpOpportunityLineItem.Recurring_Price__c > 0){  
            tmpOpportunityLineItem.New_Income_Revenue__c = tmpOpportunityLineItem.Recurring_Price__c * pc.cscfga__Quantity__c * Decimal.valueof(label.Contract_Term_For_New_Income);    
            tmpOpportunityLineItem.Avg_Annualised_Revenue__c = tmpOpportunityLineItem.New_Income_Revenue__c;    
            tmpOpportunityLineItem.Incremental_Revenue__c = getIncrementalRevenue(attrList,'RC');   //EDGE-185438 get incremental revenue
        }   
        if(tmpOpportunityLineItem.One_Off_Price__c > 0){    
            system.debug('one off <><><>'+tmpOpportunityLineItem.One_Off_Price__c +'<><><>'+pc.cscfga__Quantity__c);    
            system.debug('PC <><>'+pc); 
            system.debug('OLI<><><><>'+tmpOpportunityLineItem); 
            tmpOpportunityLineItem.Once_Off_Revenue__c = tmpOpportunityLineItem.One_Off_Price__c * pc.cscfga__Quantity__c;  
            tmpOpportunityLineItem.Incremental_Revenue__c = getIncrementalRevenue(attrList,'OC');   //EDGE-185438 get incremental revenue
        }   
        //END EDGE-133414   
        if(pc.Type__c=='Cancel')    
            tmpOpportunityLineItem.Product_Status__c='Lost';    
        else    
            tmpOpportunityLineItem.Product_Status__c='Won'; 
        }   
        //  EDGE-61607  
        return tmpOpportunityLineItem;  
    }  
    //EDGE-185438 begins 
    private static Decimal getIncrementalRevenue(List<cscfga__Attribute_Field__c> attrList,String attributeName){    
        Decimal rev = 0;
        if(attrList != null && !attrList.isEmpty()){
            for(cscfga__Attribute_Field__c attr: attrList){
                if(attr.cscfga__Attribute__r.Name == attributeName)
                    rev = Decimal.valueOf(attr.cscfga__Value__c); 
            }  
        }
        // end of EDGE-185438 
        return rev; 
    }   
    
    /* EDGE-169457
    Method Name : createProducts2forPREConfigs
    Create Opp Products values for Oc ,Rc and quantity from product configuration */
    
        private static map<string,map<string,Product>> createProducts2forPREConfigs(list<cscfga__Product_Configuration__c> pclist){ 
        map<string,map<string,Product>> mapProductFamilymapProduct = new map<string,map<string,Product>>(); 
        map<String,String> productCodewithFamilyMap= new map<String,String>();  
        map<String,String> productTypewithFamilyMap= new map<String,String>();  
        //String product_code='';   
        for (cscfga__Product_Configuration__c pc : pclist){ 
        string tmpProductFamily = pc.cscfga__Product_Family__c; 
        String product_code=pc.cscfga__Product_Definition__r.product_Specification__c;  
        String product_type=pc.cscfga__Product_Basket__r.cscfga__Opportunity__r.Product_Type__c;    
        string tmpLineItemDescription = pc.Name;    
        if (mapProductFamilymapProduct.containsKey(tmpProductFamily)){  
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
            Product tmpProduct = new Product(); 
            tmpProduct.ProductFamily=tmpProductFamily;  
            tmpProduct.LiniItemDescription=tmpLineItemDescription;  
            mapProduct.put(tmpLineItemDescription,tmpProduct);  
            mapProductFamilymapProduct.put(tmpProductFamily,mapProduct);    
            productCodewithFamilyMap.put(tmpProductFamily,product_code);    
            productTypewithFamilyMap.put(tmpProductFamily,product_type);    
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
                        tmpProduct2.ProductCode=productCodewithFamilyMap.get(tmpProduct2.Family);   
                        updatemapProduct2.put(tmpProduct2.id,tmpProduct2);  
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
    }   
    private static map<string,map<string,PBEntry>> MakePriceBookPBEntriesMapforPREConfig(map<string,string> mapProductBasketIdPriceBookId,list<cscfga__Product_Configuration__c> pcList,    
                                                                         map<string,map<string,Product>> mapProductFamilymapProduct){   
        list<PBEntry> lstPBEntry = new list<PBEntry>();    
        map<string,map<string,PBEntry>> mapPriceBookIdmapPBEntry = new map<string,map<string,PBEntry>>();  
        for (cscfga__Product_Configuration__c pc : pcList){    
        string tmpProductFamily = pc.cscfga__Product_Family__c;    
        string tmpLineItemDescription = pc.Name;   
        string tmpProductBasketId = pc.cscfga__Product_Basket__c;  
        if (mapProductFamilymapProduct.containsKey(tmpProductFamily)){ 
         map<string,Product> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily); 
         if (mapProduct.containsKey(tmpLineItemDescription)){   
             Product tmpProduct = mapProduct.get(tmpLineItemDescription);   
             string tmpProduct2Id = tmpProduct.Prod2.Id;    
             string tmpPriceBookId = mapProductBasketIdPriceBookId.get(tmpProductBasketId); 
             PBEntry tmpPBEntry = new PBEntry();    
             tmpPBEntry.PriceBookId=tmpPriceBookId; 
             tmpPBEntry.Product2Id=tmpProduct2Id;   
             if (pc.cscfga__Total_Price__c==null)   
                 tmpPBEntry.UnitPrice=0;    
             else   
                 tmpPBEntry.UnitPrice=pc.cscfga__Total_Price__c;    
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
         }  
        }  
        }  
        CreatePriceBookEntries(mapPriceBookIdmapPBEntry);  
        return mapPriceBookIdmapPBEntry;   
    }
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
}   //End of ProductUtility