/*Story number: EDGE-206
Description:Inserting and updating price items

ChagneSet No   Name      Date           Description
CH-1      Abinash     10/15/2018        EDGE-45053 CS adaptor changes to support assurance phase flag and EDM package upgrades      
*/

public with sharing class UpsertPricingDatafromSigmaObj {
    
    public static void uppsertPricingData(cs_SigmaToCSJSON obj) {
        //try{
            Map<String,cs_SigmaToCSJSON.cls_products> mapProductwithSpecId = new Map<String,cs_SigmaToCSJSON.cls_products>();
            Map < String,List < cs_SigmaToCSJSON.cls_charges >> mapProducttoCharges = new Map < String,List < cs_SigmaToCSJSON.cls_charges>>();
            List<String> listOfExternalID = new List<String>();
            Map<String, String> childSpecToParentProdSpecMap = new Map<String, String>();
            cs_SigmaToCSJSON jsonobj = new cs_SigmaToCSJSON();
            jsonobj = obj;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            jsonobjPrdtOff = jsonobj.productOffering;
            List < cs_SigmaToCSJSON.cls_charges > chargelist = new List < cs_SigmaToCSJSON.cls_charges > ();
            
            for (cs_SigmaToCSJSON.cls_products prod: jsonobjPrdtOff.products) {
                childSpecToParentProdSpecMap.put(prod.specId,prod.specId);
                mapProductwithSpecId.put(prod.name,prod);
                // Change for EDGE-12675
                if (prod.charges != null && (prod.action !='None' /*&& prod.action != 'Affected'*/)) {
                    mapProducttoCharges.put(prod.name, prod.charges);
                    
                    for(cs_SigmaToCSJSON.cls_charges charge : prod.charges)
                    {
                        if(charge.prices != null)
                        {
                            for(cs_SigmaToCSJSON.cls_prices pri : charge.prices)
                            {
                                listOfExternalID.add(pri.externalId);
                            }
                        }
                    }
                }
                if (prod.products != null) {
                    for (cs_SigmaToCSJSON.cls_products prods: prod.products) {
                        childSpecToParentProdSpecMap.put(prods.specId,prod.specId);
                        mapProductwithSpecId.put(prods.name,prods);
                        system.debug('check prod name' + prods.name);
                        if (prods.charges != null && (prods.action !='None' /*&& prods.action != 'Affected'*/)) {
                            mapProducttoCharges.put(prods.name, prods.charges);
                            
                            for(cs_SigmaToCSJSON.cls_charges chargeX : prods.charges)
                            {
                                if(chargeX.prices != null)
                                {
                                    for(cs_SigmaToCSJSON.cls_prices priX : chargeX.prices)
                                    {
                                        listOfExternalID.add(priX.externalId);
                                    }
                                }
                            }
                        }
                        if (prods.products != null) {
                            for (cs_SigmaToCSJSON.cls_products prodsZ: prods.products) {
                                childSpecToParentProdSpecMap.put(prodsZ.specId,prods.specId);
                                mapProductwithSpecId.put(prodsZ.name,prodsZ);
                                if (prodsZ.charges != null && (prodsZ.action !='None' /*&& prodsZ.action != 'Affected'*/)) {
                                    mapProducttoCharges.put(prodsZ.name, prodsZ.charges);
                                    
                                    for(cs_SigmaToCSJSON.cls_charges chargeZ : prodsZ.charges)
                                    {
                                        if(chargeZ.prices != null)
                                        {
                                            for(cs_SigmaToCSJSON.cls_prices priZ : chargeZ.prices)
                                            {
                                                listOfExternalID.add(priZ.externalId);
                                            }
                                        }
                                    }
                                }
                                if (prodsZ.products != null) {
                                    for (cs_SigmaToCSJSON.cls_products prodsY: prodsZ.products) {
                                        childSpecToParentProdSpecMap.put(prodsY.specId,prodsZ.specId);
                                        mapProductwithSpecId.put(prodsY.name,prodsY);
                                        if (prodsY.charges != null && (prodsY.action !='None'/* && prodsY.action != 'Affected'*/)) {
                                            mapProducttoCharges.put(prodsY.name, prodsY.charges);
                                            
                                            for(cs_SigmaToCSJSON.cls_charges chargeY : prodsY.charges)
                                            {
                                                if(chargeY.prices != null)
                                                { 
                                                    for(cs_SigmaToCSJSON.cls_prices priY : chargeY.prices)
                                                    {
                                                        listOfExternalID.add(priY.externalId);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Map<String,cscfga__Product_Definition__c> mapProductDef = getAllProductDefination(childSpecToParentProdSpecMap);
            System.debug('mapProductDef =====>'+mapProductDef);
            System.debug('childSpecToParentProdSpecMap =====>'+childSpecToParentProdSpecMap);
            System.debug('childSpecToParentProdSpecMap KeySet=====>'+childSpecToParentProdSpecMap.keyset());
            System.debug('listOfExternalID =====>'+listOfExternalID);
            List < cs_SigmaToCSJSON.cls_charges > attlistfinal = new List < cs_SigmaToCSJSON.cls_charges > ();
            for (List < cs_SigmaToCSJSON.cls_charges > attlists: mapProducttoCharges.values()) {
                Integer intSizeInnerStringTokens = attlists.size();
                Integer intInnerListIndex = 0;
                
                while (intInnerListIndex < intSizeInnerStringTokens) {
                    if (attlists.get(intInnerListIndex) != null) {
                        attlistfinal.add(attlists.get(intInnerListIndex));
                    }
                    intInnerListIndex++;
                }
                
            }
            
            List < cspmb__Price_Item__c > pilist = new List < cspmb__Price_Item__c > ([Select Id, External_Id__c from cspmb__Price_Item__c where External_Id__c IN : listOfExternalID ]);
            
            Map < String,
                Id > PriceItemExternalIdtoIdMap = new Map < String,
                Id > ();
            for (cspmb__Price_Item__c pi: pilist) {
                System.debug('pilist ===>'+pilist);
                if (pi.External_Id__c != '' && pi.External_Id__c != null) {
                    PriceItemExternalIdtoIdMap.put(pi.External_Id__c, pi.id);
                }
            }
            
            
            List < cspmb__Add_On_Price_Item__c > Addonlist = new List < cspmb__Add_On_Price_Item__c > ([Select Id, External_Id__c from cspmb__Add_On_Price_Item__c where External_Id__c IN : listOfExternalID ]);
            
            Map < String,Id > AddonItemExternalIdtoIdMap = new Map < String,Id > ();
            for (cspmb__Add_On_Price_Item__c addon: Addonlist ) {
                System.debug('pilist ===>'+addon);
                if (addon.External_Id__c != '' && addon.External_Id__c != null) {
                    AddonItemExternalIdtoIdMap.put(addon.External_Id__c, addon.id);
                }
            }
            
            Map < String,
                cs_SigmaToCSJSON.cls_prices > JSONExtIdtoPriceMap = new Map < String,
                cs_SigmaToCSJSON.cls_prices > ();
            
            for (cs_SigmaToCSJSON.cls_charges chrg: attlistfinal) {
                if (chrg.prices != null) {
                    for (cs_SigmaToCSJSON.cls_prices chrgprice: chrg.prices) {
                        JSONExtIdtoPriceMap.put(chrgprice.externalid, chrgprice);
                    }
                }
            }
            
            List <cspmb__Price_Item__c> insertpriceLov = new List <cspmb__Price_Item__c> ();
            List <cspmb__Add_On_Price_Item__c> insertAddOnPI = new List <cspmb__Add_On_Price_Item__c> ();
            
            System.debug('mapProductDef>>>>'+ mapProductDef);
            System.debug('mapProductwithSpecId>>>>'+ mapProductwithSpecId);
            Set<String> UniqueAddExternalIds = new Set<String>();
            for (String prodname: mapProducttoCharges.keyset()) {
                List < cs_SigmaToCSJSON.cls_charges > chargelists = new List < cs_SigmaToCSJSON.cls_charges > ();
                chargelists = mapProducttoCharges.get(prodname);
                for (cs_SigmaToCSJSON.cls_charges att: chargelists) {
                    system.debug('SpecId>>>>>>' + mapProductwithSpecId.get(prodname).specId);
                    system.debug('ProdName>>>>>>' + mapProductwithSpecId.get(prodname));
                    system.debug('SpecId Exist>>>>>>' + mapProductDef.containsKey(mapProductwithSpecId.get(prodname).specId));
                    if(mapProductDef.containsKey(mapProductwithSpecId.get(prodname).specId)){
                        if (att.prices != null ) {
                            List < cs_SigmaToCSJSON.cls_prices > attlovvalues = att.prices;
                            for (cs_SigmaToCSJSON.cls_prices attlovvalue: attlovvalues) {
                                
                                system.debug('SpecId Prices>>>>>>' + mapProductDef.containsKey(mapProductwithSpecId.get(prodname).specId));
                                //if(attlovvalue.attributes != null/* mapProductDef.containsKey(mapProductwithSpecId.get(prodname).specId)*/)
                                //{
                                    List < cs_SigmaToCSJSON.cls_prices_attribute > attPricevalue = attlovvalue.attributes; 
                                   
                                    cspmb__Price_Item__c attlov = new cspmb__Price_Item__c();
                                    attlov.cspmb__Effective_Start_Date__c =date.valueOf(attlovvalue.startdate); 
                                    attlov.cspmb__Effective_End_Date__c = date.valueOf(attlovvalue.endDate);
                                    if (PriceItemExternalIdtoIdMap != null && PriceItemExternalIdtoIdMap.get(attlovvalue.externalId) != null) {
                                        system.debug('attlovvalue.externalId====>'+PriceItemExternalIdtoIdMap.get(attlovvalue.externalId));
                                        attlov.id = PriceItemExternalIdtoIdMap.get(attlovvalue.externalId);
                                    } else {
                                        attlov.External_Id__c = attlovvalue.externalId;
                                    }
                                    attlov.Package_Name__c = jsonobjPrdtOff.name;
                                    attlov.cspmb__Product_Definition_Name__c = prodname;
                                    if (att.type_x == 'RC') {
                                        attlov.cspmb__Recurring_Charge__c = decimal.valueof(JSONExtIdtoPriceMap.get(attlovvalue.externalId).rateExcludeGST);
                                    } else if (att.type_x == 'OC') {
                                        attlov.cspmb__One_Off_Charge__c = decimal.valueof(JSONExtIdtoPriceMap.get(attlovvalue.externalId).rateExcludeGST);
                                    }
                                    attlov.cspmb__Billing_Frequency__c = att.frequency_x;
                                    attlov.ChargeType__c = att.type_x;
                                    attlov.Currency__c = att.currency_x;
                                    attlov.ChargeFrequency__c = att.frequency_x;
                                    attlov.BillingSpecId__c = att.billingSpecId;
                                    attlov.BillInAdvance__c = att.billInAdvance;
                                    attlov.taxTreatment__c=att.taxTreatment; //added for edge 33964
                                    attlov.Prorate__c = att.prorate;
                                	attlov.billingSubtype__c = att.billingSubType;
                                    attlov.Billing_Description__c = attlovvalue.billDescription;
                                    attlov.Unit_Of_Measure__c= att.unitofMeasure; // Edge-38256
                                    String attName='';
                                    /***************Tactical changes for Sigma Launch price attribute renaming-Recommended by Akshay and pankaj *****************************/
                                    attlov.cspmb__Contract_Term__c = attlovvalue.term;
                                    attlov.OP_Contract_Term__c = attlovvalue.term;
                                    attlov.cspmb__Price_Item_Code__c = prodname;
                                    attlov.Frequency__c = att.frequency_x; 
                                    // CH-1 Start
                                    attlov.Offer_Name__c = jsonobjPrdtOff.name;
                                    attlov.Offer_Id__c = jsonobjPrdtOff.specId;  
                                    attlov.ProdSpecId__c = mapProductwithSpecId.get(prodname).specId;
                                    attlov.Name = prodname;
                                    // CH-1 End
                                    Boolean isPriceItemCorrect = false;                                         
                                    if (attlovvalue.attributes != null && mapProductDef.containsKey(mapProductwithSpecId.get(prodname).specId)) 
                                    {
                                        for (cs_SigmaToCSJSON.cls_prices_attribute priceatt: attlovvalue.attributes)
                                        {
                                            if(String.isNotBlank(priceatt.name) && priceatt.name=='term')
                                            {
                                                attlov.cspmb__Contract_Term__c = priceatt.value;
                                                attlov.OP_Contract_Term__c = priceatt.value;
                                                //isPriceItemCorrect = true; 
                                            }
                                            /*else{
                                                isPriceItemCorrect = false;  
                                            }*/
                                           else if(String.isNotBlank(priceatt.name) && priceatt.name!='term' && String.isNotBlank(priceatt.value) )
                                            {
                                               
                                                attName= priceatt.name+'__c';
                                                System.debug('attName========>'+attName);
                                                if(priceatt.name == 'From_Duration' || priceatt.name == 'To_Duration')
                                                    attlov.put(attName, Decimal.valueOf(priceatt.value));
                                                else if(priceatt.name == 'Handset_and_Accessories_Type')
                                                    attlov.put('Type__c', priceatt.value);
                                                else
                                                    attlov.put(attName, priceatt.value);
                                                System.debug('priceatt.value====>'+priceatt.value);
                                                
                                                //isPriceItemCorrect = true; 
                                            }/*else{
                                                isPriceItemCorrect = false;  
                                            }  */                     
                                        }
                                        System.debug('isPriceItemCorrect====>'+isPriceItemCorrect);
                                    }
                                    /***********************************************************************************************/
                                    /*if(isPriceItemCorrect){
                                        insertpriceLov.add(attlov);
                                    }*/
                                    insertpriceLov.add(attlov);                                  
                                //} 
                                
                            }
                        }
                    }
                    else if(!mapProductDef.containsKey(mapProductwithSpecId.get(prodname).specId)){
                        if (att.prices != null ) {
                            List < cs_SigmaToCSJSON.cls_prices > attlovvalues = att.prices;
                            for (cs_SigmaToCSJSON.cls_prices attlovvalue: attlovvalues) {
                                if(!UniqueAddExternalIds.contains(attlovvalue.externalId)){
                                cspmb__Add_On_Price_Item__c addonPriceItem = new cspmb__Add_On_Price_Item__c();
                                addonPriceItem.cspmb__Effective_Start_Date__c =date.valueOf(attlovvalue.startdate); 
                                addonPriceItem.cspmb__Effective_End_Date__c = date.valueOf(attlovvalue.endDate);
                                if (AddonItemExternalIdtoIdMap != null && AddonItemExternalIdtoIdMap.get(attlovvalue.externalId) != null) {
                                    system.debug('attlovvalue.externalId====>'+AddonItemExternalIdtoIdMap.get(attlovvalue.externalId));
                                    addonPriceItem.id = AddonItemExternalIdtoIdMap.get(attlovvalue.externalId); // TODO
                                } else {
                                    addonPriceItem.External_Id__c = attlovvalue.externalId;
                                }
                                addonPriceItem.cspmb__Product_Definition_Name__c = prodname;
                                if (att.type_x == 'RC') {
                                    addonPriceItem.cspmb__Recurring_Charge__c = decimal.valueof(JSONExtIdtoPriceMap.get(attlovvalue.externalId).rateExcludeGST);
                                } else if (att.type_x == 'OC') {
                                    addonPriceItem.cspmb__One_Off_Charge__c = decimal.valueof(JSONExtIdtoPriceMap.get(attlovvalue.externalId).rateExcludeGST);
                                }
                                addonPriceItem.cspmb__Billing_Frequency__c = att.frequency_x;
                                addonPriceItem.BillingSpecId__c = att.billingSpecId;
                                addonPriceItem.BillInAdvance__c = att.billInAdvance;
                                addonPriceItem.taxTreatment__c=att.taxTreatment; 
                                addonPriceItem.Prorate__c = att.prorate;
                                addonPriceItem.Billing_Description__c = attlovvalue.billDescription;
                                addonPriceItem.billingSubtype__c = att.billingSubType;
                                addonPriceItem.Unit_Of_Measure__c= att.unitofMeasure;
                                addonPriceItem.cspmb__Contract_Term__c = attlovvalue.term;
                                addonPriceItem.Name = attlovvalue.billDescription;
                                addonPriceItem.Frequency__c = att.frequency_x; 
                                addonPriceItem.Offer_Name__c = jsonobjPrdtOff.name;
                                addonPriceItem.Offer_Id__c = jsonobjPrdtOff.specId;  
                                addonPriceItem.cspmb__Add_On_Price_Item_Code__c= mapProductwithSpecId.get(prodname).name;
                                addonPriceItem.ProdSpecId__c = mapProductwithSpecId.get(prodname).specId;
                                 String attPName = '';  
                                if (attlovvalue.attributes != null /*&& mapProductDef.containsKey(mapProductwithSpecId.get(prodname).specId)*/) 
                                    {
                                        for (cs_SigmaToCSJSON.cls_prices_attribute priceatt: attlovvalue.attributes)
                                        {
                                            if(String.isNotBlank(priceatt.name) && priceatt.name=='term')
                                            {
                                                addonPriceItem.cspmb__Contract_Term__c = priceatt.value;
                                            }
                                           else if(String.isNotBlank(priceatt.name) && priceatt.name!='term' && String.isNotBlank(priceatt.value) )
                                            {
                                               
                                                attPName= priceatt.name+'__c';
                                                System.debug('attPName========>'+attPName);
                                                if(priceatt.name == 'From_Duration' || priceatt.name == 'To_Duration')
                                                    addonPriceItem.put(attPName, Decimal.valueOf(priceatt.value));
                                                else if(priceatt.name == 'Handset_and_Accessories_Type')
                                                    addonPriceItem.put('Type__c', priceatt.value);
                                                else if(priceatt.name == 'Plan')
                                                    addonPriceItem.put('Plan_Name__c', priceatt.value);
                                                else
                                                    addonPriceItem.put(attPName, priceatt.value); 
                                                System.debug('priceatt.value====>'+priceatt.value);
                                                
                                                //isPriceItemCorrect = true; 
                                            }                     
                                        }
                                    }   
                                 
                                
                                insertAddOnPI.add(addonPriceItem);
                                }
                            }
                        }
                    }
                }
            }
            system.debug('insertAddOnPI>>>'+insertAddOnPI);
            system.debug('insertpriceLov>>>'+insertpriceLov);
            if (!insertpriceLov.isEmpty()) {
                upsert insertpriceLov;
            }
            if (!insertAddOnPI.isEmpty()) {
                upsert insertAddOnPI;
            }
            system.debug('insertpriceLov>>>>>>' + insertpriceLov);
        system.debug('insertAddOnPI>>>>>>' + insertAddOnPI);
            if (!insertAddOnPI.isEmpty() && !insertpriceLov.isEmpty()) {
                prepareAddonAssociation(insertAddOnPI,insertpriceLov,childSpecToParentProdSpecMap);
            }
       /*     
        }
        // Change for EDGE-12675
        catch (Exception e) {
            
            Logger.getLogger(UpsertPricingDatafromSigmaObj.class).debug(e);
            Logger.exitLogger();
        }*/
    }
    Public static map<String,cscfga__Product_Definition__c> getAllProductDefination(Map<String, String> childSpecToParentProdSpecMap){
        Map<String,cscfga__Product_Definition__c> mapProductDef = new Map<String,cscfga__Product_Definition__c>();
        for(cscfga__Product_Definition__c def: [SELECT id,product_Specification__c FROM cscfga__Product_Definition__c
                                                WHERE product_Specification__c!= '' 
                                                AND product_Specification__c IN:childSpecToParentProdSpecMap.keyset()
                                                AND cscfga__IsArchived__c=FALSE]){
                  system.debug('Def Spec ID>>>>' + def.product_Specification__c);
                                                    mapProductDef.put(def.product_Specification__c,def);                                  
        }
        return mapProductDef;
    }
    
    Public static void prepareAddonAssociation(List<cspmb__Add_On_Price_Item__c> lstAddon, List<cspmb__Price_Item__c> lstPI,Map<String, String> childSpecToParentProdSpecMap){
        system.debug('lstAddon>>>>>>' + lstAddon);
        system.debug('lstPI>>>>>>' + lstPI);
        Set<Id> setAddonIds = new Set<Id>();
        Set<Id> setPriceItemIds = new Set<Id>();
        for(cspmb__Price_Item__c PI: lstPI){
            setPriceItemIds.add(PI.Id);
        }
        for(cspmb__Add_On_Price_Item__c Addon: lstAddon){
            setAddonIds.add(Addon.Id);
        }
        
        
        List <cspmb__Price_Item_Add_On_Price_Item_Association__c> insertAssociationItem = new List <cspmb__Price_Item_Add_On_Price_Item_Association__c> ();
        map<String,List<cspmb__Price_Item__c>> mapPriceItem = new map<String,List<cspmb__Price_Item__c>>();
        for(cspmb__Price_Item__c PI: [SELECT id,ProdSpecId__c,External_Id__c FROM cspmb__Price_Item__c WHERE id IN: setPriceItemIds]){
            if(mapPriceItem.containskey(PI.ProdSpecId__c))
                mapPriceItem.get(PI.ProdSpecId__c).add(PI);
            else
                mapPriceItem.put(PI.ProdSpecId__c, new List<cspmb__Price_Item__c>{PI}); 
        }
        for(cspmb__Add_On_Price_Item__c addonPI: [SELECT id,ProdSpecId__c,External_Id__c FROM  cspmb__Add_On_Price_Item__c 
                                                  WHERE Id IN: setAddonIds]){
            List<cspmb__Price_Item__c> lstMatchedPriceItem = new List<cspmb__Price_Item__c>();
            lstMatchedPriceItem = getPriceItemId(addonPI.ProdSpecId__c,childSpecToParentProdSpecMap,mapPriceItem);
            system.debug('After lstMatchedPriceItem>>>>' + lstMatchedPriceItem);
            if(!lstMatchedPriceItem.isEmpty()){
                for(cspmb__Price_Item__c item: lstMatchedPriceItem){
                    cspmb__Price_Item_Add_On_Price_Item_Association__c objassociation = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
                    objassociation.cspmb__Add_On_Price_Item__c = addonPI.id;
                    objassociation.cspmb__Price_Item__c = item.id;
                    system.debug('Ids>>>>' + item.External_Id__c + '===' + addonPI.External_Id__c);
                    objassociation.External_Id__c = item.External_Id__c + addonPI.External_Id__c;
                    system.debug('External Ids>>>>' + objassociation.External_Id__c);
                    insertAssociationItem.add(objassociation);
                }
            }          
        }
        system.debug('insertAssociationItem>>>>>' + insertAssociationItem);
        if (!insertAssociationItem.isEmpty()) {
            Database.upsert (insertAssociationItem,false);
        }
        
    }
    Public static List<cspmb__Price_Item__c> getPriceItemId(String currentSpecId,map<String,String> childSpecToParentProdSpecMap, map<String,List<cspmb__Price_Item__c>> mapPriceItem){
        List<cspmb__Price_Item__c> lstMatchedPriceItem = new List<cspmb__Price_Item__c>();
        system.debug('Outside Loop' + currentSpecId);
        String SpecId = currentSpecId;
        for(Integer i =0; i<4 ; i++){
            system.debug('Inside Loop' + SpecId);
            if(mapPriceItem.containsKey(SpecId)){
                system.debug('lstMatchedPriceItem>>>>>' + mapPriceItem.get(SpecId));
                system.debug('lstMatchedPriceItem>>>>>' + mapPriceItem.get(SpecId).size());
                lstMatchedPriceItem = mapPriceItem.get(SpecId);
                return lstMatchedPriceItem;
            }else{
                SpecId = childSpecToParentProdSpecMap.get(SpecId);
            }
        }
        
        return lstMatchedPriceItem;
    }
}