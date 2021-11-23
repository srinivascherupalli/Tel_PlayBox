/*
 * EDGE-122428 :  Navneet Sanotra
 * Aarathi Iyer   08/12/2020       EDGE 184803   Added condition of isNegotiatedCharge
 * EDGE-211859 : 17/05/2021 Ankush Rana     Map product Family value of the Opportunity product dynamically from DPR offer during sync with opportunity.
 * EDGE-229638 : 09/08/2021 Shivaprasad Patil Active FA’s TCV is not matching with the Opportunity TCV 
 */
public Without sharing class DPRSyncOpptyProductUtility{
    public static void createOLIs(set<string> setProductBasketId){
        /*
        --select all attributes which are line items
        --check if combinations of DPProduct Family and Line Item Description exist in Product2
        --for the ones which do exist - get Product2.Id
        --for the others - insert and get Product2.Id
        --select standard price book
        --check if there is an existing combination of PriceBook and Product2 in PriceBookEntry
        --if it doesn't exist - create and get PriceBookEntry.Id
        --if it does exist - get PriceBookEntry.Id
        -- enter all PriceBookEntries into OLIs
        */
        
        Phoenix_Configurations__c customSetting = Phoenix_Configurations__c.getInstance();
        
        if(customSetting == null) {
        customSetting = new Phoenix_Configurations__c();
        }

        customSetting.Skip_Validation__c = true;
        upsert customSetting;
        
        deleteHardOLIs(setProductBasketId);
        
        map<string,string> mapProductBasketIdPriceBookId = new AssignnPriceBookToProductBasketImpl().AssignPriceBook(setProductBasketId);
        system.debug('****mapProductBasketIdPriceBookId=' + mapProductBasketIdPriceBookId);
        system.debug('****setProductBasketId=' + setProductBasketId);
        
        list<dpr_Offer__c> lstAttribute = [SELECT 
                                                    ID,
                                                    Delegated_Pricing_Request__c,
                                                    Delegated_Pricing_Request__r.Total_Deal_Value_Annual__c,
                                                    Delegated_Pricing_Request__r.Opportunity__r.Product_Type__c,
                                                    delegated_pricing_request__r.opportunity__r.Contract_Term__c,
                                                    delegated_pricing_request__r.Opportunity__r.account.RecordType.DeveloperName,
                                                    delegated_pricing_request__r.Opportunity__r.account.Mobile_Code__c,
                                                    delegated_pricing_request__r.Opportunity__r.account.Name,
                                                    delegated_pricing_request__r.Deal_Status__c,
                                                    DPR_Offer_Type__c,
                                                    DPR_Offer_Unit_Type__c,
                                                    List_Price__c,
                                                    Overridden_Unit_price__c,
                                                    Marketable_Offer__c,
                                                    Marketable_Offer__r.Offer_ID__c,
													Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c, // added condition for EDGE-211859 by team Amsterdam
                                                    Name,
                                                    DPR_Offer_Quantity__c,
                                                    Total_Once_Off_Charge__c,
                                                    Total_Recurring_Charge__c,
													PF_Contract_Term__c,
													Total_Spend_over_Contract_Term__c
                                                    FROM dpr_Offer__c
                                                    WHERE
                                                    isNegotiableCount__c > 0 AND// added condition for EDGE 184803 by team Amsterdam
                                                    Delegated_Pricing_Request__c in : mapProductBasketIdPriceBookId.keyset()];
            
        system.debug('****lstAttribute=' + lstAttribute);
        
        //this is the map where the keys are: ProductFamily and ProductName (LineItemDescription) 
        map<string,map<string,DPProduct>> mapProductFamilymapProduct = createProducts2(lstAttribute);
        system.debug('****mapProductFamilymapProduct=' + mapProductFamilymapProduct);
        
        //this is the map where the keys are: PriceBookId and Product2Id
        map<string,map<string,DPPBEntry>> mapPriceBookIdmapPBEntry = makePriceBookPBEntriesMap(mapProductBasketIdPriceBookId,lstAttribute,mapProductFamilymapProduct);
        system.debug('****makePriceBookPBEntriesMap mapPriceBookIdmapPBEntry=' + mapPriceBookIdmapPBEntry);
        
        //this function is void because it just modifies mapPriceBookIdmapPBEntry, so no need for return
        createPriceBookEntries(mapPriceBookIdmapPBEntry);
        system.debug('****createPriceBookEntries mapPriceBookIdmapPBEntry=' + mapPriceBookIdmapPBEntry);
        
        //this function takes all structures created before and generates OLIs
        createOLIs(mapProductBasketIdPriceBookId,lstAttribute,mapProductFamilymapProduct,mapPriceBookIdmapPBEntry);
        
        customSetting.Skip_Validation__c = false;
        update customSetting;
        
    }
    
    private static void createOLIs(map<string,string> mapProductBasketIdPriceBookId, list<dpr_Offer__c> lstAttribute,
        map<string,map<string,DPProduct>> mapProductFamilymapProduct, map<string,map<string,DPPBEntry>> mapPriceBookIdmapPBEntry){
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
        
        for (dpr_Offer__c tmpAttribute : lstAttribute){
            setProductBasketId.add(tmpAttribute.delegated_pricing_request__c);
        }
        
        map<Id,delegated_pricing_request__c> mapProductBasket = new map<Id,delegated_pricing_request__c>([select Id,Opportunity__c 
            from delegated_pricing_request__c where Id in : setProductBasketId]); 
        
        for (dpr_Offer__c tmpAttribute : lstAttribute){
            //string tmpProductFamily = tmpAttribute.Name;
			
			//EDGE-211859
            string tmpProductFamily = tmpAttribute.Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c ;
			
            string tmpLineItemDescription = getOLILineItemDescription(tmpAttribute);
            string tmpProductBasketId = tmpAttribute.delegated_pricing_request__c;
            string tmpPriceBookId = mapProductBasketIdPriceBookId.get(tmpProductBasketId);
            
            double tmpUnitPrice = tmpAttribute.List_Price__c;
            map<string,DPProduct> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
            DPProduct tmpProduct = mapProduct.get(tmpLineItemDescription);
            string tmpProduct2Id = tmpProduct.Prod2.Id;
            map<string,DPPBEntry> mapPBEntry = mapPriceBookIdmapPBEntry.get(tmpPriceBookId);
            DPPBEntry tmpPBEntry = mapPBEntry.get(tmpProduct2Id);
            string tmpPriceBookEntryId = tmpPBEntry.PBE.Id;
            string tmpOpportunityId=mapProductBasket.get(tmpProductBasketId).Opportunity__c;
			Double tmpTotalDealAnnualValue = (tmpAttribute.Total_Spend_over_Contract_Term__c / tmpAttribute.PF_Contract_Term__c)*12; //EDGE-229638
			
            if(productConfLevel){
                if(mapPCIdOLI.containsKey(tmpAttribute.Id))
                    tmpOpportunityLineItem = mapPCIdOLI.get(tmpAttribute.Id);
                else{
                    tmpOpportunityLineItem = new OpportunityLineItem(); 
                    tmpOpportunityLineItem.UnitPrice=0;
                    tmpOpportunityLineItem.One_Off_Price__c=0;
                    tmpOpportunityLineItem.Recurring_Price__c=0;
                    tmpOpportunityLineItem.Avg_Annualised_Revenue__c=0;
                    tmpOpportunityLineItem.Incremental_Revenue__c = 0;
                    tmpOpportunityLineItem.Current_Revenue__c = 0;
                    mapPCIdOLI.put(tmpAttribute.Id,tmpOpportunityLineItem);
                }
            }
            else{
                tmpOpportunityLineItem = new OpportunityLineItem(); 
                tmpOpportunityLineItem.UnitPrice=0;
                tmpOpportunityLineItem.One_Off_Price__c=0;
                tmpOpportunityLineItem.Recurring_Price__c=0;
                tmpOpportunityLineItem.Avg_Annualised_Revenue__c=0;
                tmpOpportunityLineItem.Incremental_Revenue__c = 0;
                tmpOpportunityLineItem.Current_Revenue__c = 0;
                lstOLI.add(tmpOpportunityLineItem);
            }
            
            tmpOpportunityLineItem.dpr_Offer__c=tmpAttribute.Id;
            tmpOpportunityLineItem.OpportunityId=tmpOpportunityId;
            tmpOpportunityLineItem.PricebookEntryId=tmpPriceBookEntryId;
            tmpOpportunityLineItem.Quantity=tmpAttribute.DPR_Offer_Quantity__c;
            tmpOpportunityLineItem.Description=tmpLineItemDescription;
           

            if (tmpAttribute.List_Price__c != null){
                
                if(tmpAttribute.List_Price__c >0){
                    tmpOpportunityLineItem.Recurring_Price__c+=tmpAttribute.Overridden_Unit_price__c;
                    //EDGE-229638 - Start
                    //tmpOpportunityLineItem.Avg_Annualised_Revenue__c+=tmpAttribute.Delegated_Pricing_Request__r.Total_Deal_Value_Annual__c;
                    //tmpOpportunityLineItem.Incremental_Revenue__c+=tmpAttribute.Delegated_Pricing_Request__r.Total_Deal_Value_Annual__c;
					tmpOpportunityLineItem.Avg_Annualised_Revenue__c+=tmpTotalDealAnnualValue;
                    tmpOpportunityLineItem.Incremental_Revenue__c+=tmpTotalDealAnnualValue;
                    tmpOpportunityLineItem.Current_Revenue__c += tmpAttribute.Total_Spend_over_Contract_Term__c;
                    //EDGE-229638 - End
                }else{
                    tmpOpportunityLineItem.One_Off_Price__c+=tmpAttribute.Overridden_Unit_price__c;
                    //EDGE-229638 - Start
                    //tmpOpportunityLineItem.Avg_Annualised_Revenue__c+=tmpAttribute.Delegated_Pricing_Request__r.Total_Deal_Value_Annual__c;
                    //tmpOpportunityLineItem.Incremental_Revenue__c+=tmpAttribute.Delegated_Pricing_Request__r.Total_Deal_Value_Annual__c;
					tmpOpportunityLineItem.Avg_Annualised_Revenue__c+=tmpTotalDealAnnualValue;
					tmpOpportunityLineItem.Incremental_Revenue__c+=tmpTotalDealAnnualValue;
                    tmpOpportunityLineItem.Current_Revenue__c += tmpAttribute.Total_Spend_over_Contract_Term__c;
                    //EDGE-229638 - End
                }
                
                if (SumOneOffAndRecurring)
                    //EDGE-229638 
                    //tmpOpportunityLineItem.UnitPrice+=tmpAttribute.Overridden_Unit_price__c * tmpAttribute.delegated_pricing_request__r.opportunity__r.Contract_Term__c;
				tmpOpportunityLineItem.UnitPrice+=tmpAttribute.Overridden_Unit_price__c * tmpAttribute.PF_Contract_Term__c;
                else{
                    if (tmpAttribute.List_Price__c > 0)
                        //EDGE-229638 
                        //tmpOpportunityLineItem.UnitPrice+=tmpAttribute.Overridden_Unit_price__c * tmpAttribute.delegated_pricing_request__r.opportunity__r.Contract_Term__c;
					    tmpOpportunityLineItem.UnitPrice+=tmpAttribute.Overridden_Unit_price__c *tmpAttribute.PF_Contract_Term__c;
                }
            }  
           //   EDGE-61607      
            if(tmpAttribute.delegated_pricing_request__r.Opportunity__r.Product_Type__c=='Modular'){
                //EDGE-79675 Start
               /* if(tmpAttribute.cscfga__Product_Configuration__r.Type__c=='Cancel' && (tmpAttribute.Name.contains('ETC') || tmpAttribute.Name.contains('EarlyTerminationCharge')))
                {
                    System.debug('ETC line:'+tmpAttribute);
                    tmpOpportunityLineItem.Early_Termination_Charge__c = decimal.valueof(tmpAttribute.cscfga__Value__c);
                    tmpOpportunityLineItem.One_Off_Price__c = 0;
                    //tmpOpportunityLineItem.Total_One_Off_Price__c = 0;
                    //tmpOpportunityLineItem.ListPrice = 0;
                    //Field is not writeable:
                    tmpOpportunityLineItem.Once_Off_Revenue__c = 0;
                    tmpOpportunityLineItem.Incremental_Revenue__c = 0;
                    tmpOpportunityLineItem.UnitPrice = 0;
                }    */           
                //EDGE-79675 End
                tmpOpportunityLineItem.Contract_Terms__c=string.valueof(tmpAttribute.PF_Contract_Term__c);//string.valueof(tmpAttribute.delegated_pricing_request__r.opportunity__r.Contract_Term__c);
                //tmpOpportunityLineItem.Product_Code__c=tmpAttribute.cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;//commented due to EDGE-98254
                //code for Indirect/Direct--start here//
                if((tmpAttribute.delegated_pricing_request__r.Opportunity__r.account.RecordType.DeveloperName).contains('Partner')){
                tmpOpportunityLineItem.Channel__c='InDirect';
                tmpOpportunityLineItem.Partner_Info__c=tmpAttribute.delegated_pricing_request__r.Opportunity__r.account.Name;
                tmpOpportunityLineItem.Dealer_Code__c=tmpAttribute.delegated_pricing_request__r.Opportunity__r.account.Mobile_Code__c;
                }
                else{
                tmpOpportunityLineItem.Channel__c='Direct';
                }
                //code for Indirect/Direct--End here//
                system.debug('***tmpOpportunityLineItem***'+tmpOpportunityLineItem);
                system.debug('***tmpAttribute***'+tmpAttribute);
                /*if(tmpOpportunityLineItem.Recurring_Price__c!=null && tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c!=0 && tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c!=null){
                tmpOpportunityLineItem.Recurring_Price__c=tmpOpportunityLineItem.Recurring_Price__c/tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c;
                }*/
                
                /*if(tmpOpportunityLineItem.One_Off_Price__c!=null && tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c!=0 && tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c!=null){ //Addded not null check by Venkata
                    
                tmpOpportunityLineItem.One_Off_Price__c=tmpOpportunityLineItem.One_Off_Price__c/tmpAttribute.cscfga__Product_Configuration__r.Quantity_Product_Configuration__c;
                tmpOpportunityLineItem.New_Income_Revenue__c=tmpOpportunityLineItem.Recurring_Price__c;
                }*/
                
               if(tmpAttribute.delegated_pricing_request__r.Deal_Status__c=='Cancelled')
                    tmpOpportunityLineItem.Product_Status__c='Lost';
                else
                    tmpOpportunityLineItem.Product_Status__c='Won';
            }   
            //  EDGE-61607              
        }
        
        if (mapPCIdOLI.size() > 0) 
            insert mapPCIdOLI.values();
        else if (lstOLI.size() > 0) 
            insert lstOLI;
    }
    
    
    private static map<string,map<string,DPPBEntry>> makePriceBookPBEntriesMap(map<string,string> mapProductBasketIdPriceBookId,list<dpr_Offer__c> lstAttribute, 
        map<string,map<string,DPProduct>> mapProductFamilymapProduct){
        list<DPPBEntry> lstPBEntry = new list<DPPBEntry>();
        map<string,map<string,DPPBEntry>> mapPriceBookIdmapPBEntry = new map<string,map<string,DPPBEntry>>(); 
        
        for (dpr_Offer__c tmpAttribute : lstAttribute){
            
            //string tmpProductFamily = tmpAttribute.cspmb_Price_Item__r.ProdSpecId__c;
            //string tmpProductFamily = tmpAttribute.Name;
			
			//EDGE-211859
            string tmpProductFamily = tmpAttribute.Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c;
            string tmpLineItemDescription = getOLILineItemDescription(tmpAttribute);
            string tmpProductBasketId = tmpAttribute.delegated_pricing_request__c;
            
            if (mapProductFamilymapProduct.containsKey(tmpProductFamily)){
                map<string,DPProduct> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
                
                if (mapProduct.containsKey(tmpLineItemDescription)){
                    DPProduct tmpProduct = mapProduct.get(tmpLineItemDescription);
                    string tmpProduct2Id = tmpProduct.Prod2.Id;
                    string tmpPriceBookId = mapProductBasketIdPriceBookId.get(tmpProductBasketId);
                    
                    DPPBEntry tmpPBEntry = new DPPBEntry();
                    tmpPBEntry.PriceBookId=tmpPriceBookId;
                    tmpPBEntry.Product2Id=tmpProduct2Id;
                    
                    if (tmpAttribute.List_Price__c==null)
                        tmpPBEntry.UnitPrice=0;
                    else
                        tmpPBEntry.UnitPrice=tmpAttribute.List_Price__c;
            
                    tmpPBEntry.Name = tmpLineItemDescription;
                    
                    if (mapPriceBookIdmapPBEntry.containsKey(tmpPriceBookId)){
                        map<string,DPPBEntry> mapPBEntry = mapPriceBookIdmapPBEntry.get(tmpPriceBookId);
                        if (!mapPBEntry.containsKey(tmpProduct2Id))
                            mapPBEntry.put(tmpProduct2Id,tmpPBEntry);
                    }
                    else{
                        map<string,DPPBEntry> mapPBEntry = new map<string,DPPBEntry>();
                        mapPBEntry.put(tmpProduct2Id,tmpPBEntry);
                        mapPriceBookIdmapPBEntry.put(tmpPriceBookId,mapPBEntry);
                    }
                    
                }
                
            }
        }
        return mapPriceBookIdmapPBEntry;
    }
    
    
    
    private static void createPriceBookEntries(map<string,map<string,DPPBEntry>> mapPriceBookIdmapPBEntry){
        set<string> setProduct2Id = new set<string>();
        list<PricebookEntry> lstPricebookEntryInsert = new list<PricebookEntry>(); 
        
        for (map<string,DPPBEntry> mapPBEntry : mapPriceBookIdmapPBEntry.values()){
            for (DPPBEntry tmpPBEntry : mapPBEntry.values()){
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
                    map<string,DPPBEntry> mapPBEntry = mapPriceBookIdmapPBEntry.get(tmpPricebook2Id);
                    if (mapPBEntry.containsKey(tmpProduct2Id)){
                        DPPBEntry tmpPBEntry = mapPBEntry.get(tmpProduct2Id);
                        tmpPBEntry.PBEntryId=tmpPricebookEntry.Id;
                    }
                }
            }
            
            for (map<string,DPPBEntry> mapPBEntry : mapPriceBookIdmapPBEntry.values()){
                for (DPPBEntry tmpPBEntry : mapPBEntry.values()){
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
        
    }
    
    private static map<string,map<string,DPProduct>> createProducts2(list<dpr_Offer__c> lstAttribute){
        map<string,map<string,DPProduct>> mapProductFamilymapProduct = new map<string,map<string,DPProduct>>(); 
        map<String,String> productCodewithFamilyMap= new map<String,String>();
        map<String,String> productTypewithFamilyMap= new map<String,String>();
        //String product_code='';
        for (dpr_Offer__c tmpAttribute : lstAttribute){
            //string tmpProductFamily = tmpAttribute.Name;
			
			//EDGE-211859
            string tmpProductFamily = tmpAttribute.Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c;
            //string tmpProductFamily = tmpAttribute.cspmb_Price_Item__r.Product_Family__c;
            String product_code= tmpAttribute.Marketable_Offer__r.Offer_ID__c;
            String product_type=tmpAttribute.Delegated_Pricing_Request__r.Opportunity__r.Product_Type__c;
            string tmpLineItemDescription = getOLILineItemDescription(tmpAttribute);
        
            if (mapProductFamilymapProduct.containsKey(tmpProductFamily)){
                map<string,DPProduct> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
                if (!mapProduct.containsKey(tmpLineItemDescription)){
                    DPProduct tmpProduct = new DPProduct();
                    tmpProduct.ProductFamily=tmpProductFamily;
                    tmpProduct.LiniItemDescription=tmpLineItemDescription;
                    mapProduct.put(tmpLineItemDescription,tmpProduct);
                }
            }
            else{
                map<string,DPProduct> mapProduct = new map<string,DPProduct>();
                DPProduct tmpProduct = new DPProduct();
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
                if(productTypewithFamilyMap.get(tmpProduct2.Family)=='Mobile'){
                    for(String prdcd:productCodewithFamilyMap.keySet()){
                        if(tmpProduct2.Family==prdcd){
                            tmpProduct2.ProductCode=productCodewithFamilyMap.get(tmpProduct2.Family);
                            updatemapProduct2.put(tmpProduct2.id,tmpProduct2);
                        }
                    }
                    
                }
                if (mapProductFamilymapProduct.containsKey(tmpProduct2.Family)){
                    map<string,DPProduct> mapProduct = mapProductFamilymapProduct.get(tmpProduct2.Family);
                    if (mapProduct.containsKey(tmpProduct2.Name)){
                        DPProduct tmpProduct = mapProduct.get(tmpProduct2.Name);
                        tmpProduct.Product2Id = tmpProduct2.Id;
                    }
                }
            }
            if(updatemapProduct2.size()>0)
                update updatemapProduct2.values();
            //EDGE-98254--End
            list<Product2> lstProduct2Insert = new list<Product2>();
            
            for (string tmpProductFamily : mapProductFamilymapProduct.keySet()){
                map<string,DPProduct> mapProduct = mapProductFamilymapProduct.get(tmpProductFamily);
                for (DPProduct tmpProduct : mapProduct.values()){
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
    
    
    public static void deleteHardOLIs(set<string> setProductBasketId){
        list<delegated_pricing_request__c> lstPB = [
            SELECT Id, Opportunity__c
            FROM delegated_pricing_request__c 
            WHERE Id in : setProductBasketId
        ];
        set<Id> setOpportunityId = new set<Id>();
        for(delegated_pricing_request__c tmpPB : lstPB){
            setOpportunityId.add(tmpPB.Opportunity__c);
        }
        if (setOpportunityId.size() > 0){
            System.debug(LoggingLevel.DEBUG, 'deleteHardOLIs.entering oli deletion');
            list<Opportunity> lstOpp = [
                SELECT id, pricebook2id, (SELECT id FROM OpportunityLineItems)
                FROM Opportunity
                WHERE id IN :setOpportunityId
            ];
            if (lstOpp.size()>0){
                list<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>();
                
                System.debug(LoggingLevel.DEBUG, 'deleteHardOLIs.lstOpp = ' + lstOpp.size());
                for(Opportunity opp: lstOpp){
                    System.debug(LoggingLevel.DEBUG, 'deleteHardOLIs.inside lstOpp looppps');
                    if(opp.OpportunityLineItems.size() > 0){
                        for(OpportunityLineItem oli : opp.OpportunityLineItems){
                            lstOLI.add(oli);
                        }
                    }
                }
                if(lstOLI.size() > 0)
                    delete lstOLI;
            }
        }
    }
    
    private static string getOLILineItemDescription(dpr_Offer__c tmpAttribute){
        Boolean productConfLevel=false;
        string OLIDescription;
        
        OLI_Sync__c OLISync = OLI_Sync__c.getInstance(UserInfo.getUserId());
        
        if (OLISync != null)
            productConfLevel = OLISync.Product_Configuration_Level__c;  
        
        if (productConfLevel)
            OLIDescription=tmpAttribute.Name;
        else
            OLIDescription=tmpAttribute.Name;
            
        return OLIDescription;
    }
    
    private class DPProduct{
        public string ProductFamily {get;set;}
        public string LiniItemDescription {get;set;}
        public string Product2Id {get;set;}
        public Product2 Prod2 {get;set;}
    }
    
    private class DPPBEntry{
        public string PBEntryId {get;set;}
        public string PriceBookId {get;set;}
        public string Product2Id {get;set;}
        public double UnitPrice {get;set;}
        public string Name {get;set;}
        public PriceBookEntry PBE {get;set;}
    }
}