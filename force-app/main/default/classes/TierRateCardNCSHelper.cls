/********************************************************
    Class Name      :   TierRateCardNCSHelper
    Test Class : TierRateCardNCSHelperTest
    ===============================================================================================================================
    Change.No.    Developer Name          Date          Story Description
    1.            Venkata Ramanan G     11/10/2019      EDGE-112869  Created for Rate Card population Framework
    2.          Shubhi Vijay            06/11/2019      Edge-117563
    3.          Varun/Monali            12/12/2019      EDGE-123778 Uncommented attribute External_Id__c in class populateRateCardList
    4.          Rohit Tripathi          13/02/2020      EDGE-135705 NGUC NEW_RTB failed at BDS due to duplicate/incorrect sequence for custom rates
    5.          Shubhi Vijayvergia      30/4/2020       Edge-137067 NGUC consumption based model
    ********************************************************************/
    
    global with sharing class TierRateCardNCSHelper implements cssmgnt.RemoteActionDataProvider{
    
     //String offerId;
    static Map<String,String> priceitemfiltermap = new Map<String,String>();
    static List<CustomRateCard__mdt> rateCardMetadataList = new List<CustomRateCard__mdt>();
    public static string offerId;
    static List<cspmb__price_item__c> priceItemList = new List<cspmb__price_item__c>();
    static Map<String,Set<String>> ncsNameConfigCountMap = new Map<String,Set<String>>();
    static Map<String,csoe__Non_Commercial_Schema__c> ncsmap = new Map<String,csoe__Non_Commercial_Schema__c>();
    static Set<String> prodspecids = new Set<String>();
    static Map<Id,List<Object>> OEConfigMap = new Map<Id,List<Object>>();
    static Map<Id,List<Object>> oeMapUpdate = new Map<Id,List<Object>>();
    static Map<String,Map<String,TierRateCardNCSDTO.Configuration>> existingExternalIdMap = new Map<String,Map<String,TierRateCardNCSDTO.Configuration>>();//// added by shubhi  Edge-137067
    static Map<String,List<String>> ExternalIdListTobeUpsertedMap = new Map<String,List<String>>();// added by shubhi  Edge-137067
    static List<String> NCSnameslst = new List<String>(); // added by shubhi  Edge-137067
    static List<String> NCSNametoBenewInsertedList = new List<String>();
      
      /* Method to fetch all the required data for population of Rate Card. 
      Gets the input map & fetches all the PCs associated to the Basket & solution.
      Fetches all CustomRateCard__mdt based on the Offer ID & fetches the associated NCS(Non-commercial Schema).
      Fetches the details of the NCS based on the above result.
      Return param is null since its invoked from the Solution JS & it doesnt need to return any data to front end. 
      */
    @RemoteAction
        global static Map<String,Object> getData(Map<String,Object> inputMap) {
            Boolean res = false;
            TierRateCardNCSHelper ncshelper = new TierRateCardNCSHelper();
            Map<String, Object> returnMap = new Map<String, Object>();        
            List<String> attrnames = new List<String>();
            Map<String,String> attrvalue = new Map<String,String>() ; 
            offerId = (inputMap.containsKey('Offer_Id__c') && inputMap.get('Offer_Id__c') != '')? (String)inputMap.get('Offer_Id__c'):'';
            String SolutionId = (inputMap.containsKey('SolutionId') && inputMap.get('SolutionId') != '')? (String)inputMap.get('SolutionId'):'';
            String basketId = (inputMap.containsKey('basketid') && inputMap.get('basketid') != '')? (String)inputMap.get('basketid'):'';
            rateCardMetadataList = fetchRateCardMetadata();
            system.debug('rateCardMetadataList-->'+rateCardMetadataList);          
            for(CustomRateCard__mdt mdata : rateCardMetadataList){
                if(String.isNotBlank(mdata.DependentAttributeName__c)){
                    List<String> attList = new List<String>();
                    attList = (mdata.DependentAttributeName__c.contains(',')) ? mdata.DependentAttributeName__c.split(',') : new List<String>{mdata.DependentAttributeName__c};
                    attrnames.addAll(attList);
                }
                if(String.isNotBlank(mdata.NCSName__c)){
                    NCSnameslst.add(mdata.NCSName__c);
                }
            }
            TierRateCardNCSUtility ncsutility = new TierRateCardNCSUtility();
            ncsmap = ncsutility.fetchNCSInstance(NCSnameslst);  
            String Query = null;
            if(attrnames != null){
                system.debug('SolutionId'+SolutionId);
                system.debug('basketId'+basketId);
                Query = 'select id,Type__c,csordtelcoa__Replaced_Product_Configuration__c,name,cscfga__Product_Definition__r.product_Specification__c, Marketable_Offer__r.Offer_ID__c,(Select id,cscfga__Value__c,Name from cscfga__Attributes__r where name in :attrnames) from cscfga__product_configuration__c where cssdm__solution_association__c =:SolutionId and cscfga__Product_Basket__c =: basketId LIMIT 999';
            }else 
                Query = 'select id,Type__c,csordtelcoa__Replaced_Product_Configuration__c,name,cscfga__Product_Definition__r.product_Specification__c, Marketable_Offer__r.Offer_ID__c from cscfga__product_configuration__c where cssdm__solution_association__c =:SolutionId and cscfga__Product_Basket__c =: basketId LIMIT 999';
            List<cscfga__product_configuration__c> configlst = database.query(Query);              
            List<Id> configids = new List<Id>();
            for(cscfga__product_configuration__c config :configlst){
                prodspecids.add(config.cscfga__Product_Definition__r.product_Specification__c);
                configids.add(config.id);
            }
            system.debug('configlst-->'+configlst);         
            ncsNameConfigCountMap = checkForExistingNCS(configids);
            priceItemList = fetchPriceItemEntries();
            for(cscfga__product_configuration__c config: configlst){
                if(config.cscfga__Attributes__r != null && !config.cscfga__Attributes__r.isEmpty()){
                    for(integer i=0;i<config.cscfga__Attributes__r.size();i++){
                    attrvalue.put(config.cscfga__Attributes__r[i].Name,config.cscfga__Attributes__r[i].cscfga__Value__c);
                    }
                }
                if(config.csordtelcoa__Replaced_Product_Configuration__c!=null){
                    res = ncshelper.upsertRateCardNCS(basketId,config,offerId,attrvalue);
                }else{
                    res = ncshelper.createRateCardNCS(basketId,config,offerId,attrvalue);
                }
            }            
            try{
                if(configlst!=null && !configlst.isEmpty()){
                    ncshelper.populateToBeDeletedrateCardList();
                    if(oeMapUpdate != null && !oeMapUpdate.isEmpty()){
                        //csoe.API_1.updateOEData(oeMapUpdate);
                    }
                }
                if(OEConfigMap != null && !OEConfigMap.isEmpty()){
                    csoe.API_1.createOEData(OEConfigMap);
                    
                }               
            }catch(Exception e){
                system.debug('Error in creating Non Commerical Schema attachments '+e.getCause()+' stack trace'+e.getStackTraceString());
            }
            return null;
        }          
       /*
       Method to fetch the rate card entries & associate to the PC record. Association of NCS to PC is done by invoking TierRateCardNCSUtility class.
       Call will be performed only if there is no existing attachment created for that NCS.
       */
        public Boolean createRateCardNCS(String basketId, cscfga__product_configuration__c configRecord,String offerId,Map<String,String> attrvalue){
            try{
               List<Object> OETempList = new List<Object>();
                    for(CustomRateCard__mdt rateMetadata : rateCardMetadataList){
                        if(configRecord!=null && rateMetadata.ProductSpecId__c == configRecord.cscfga__Product_Definition__r.product_Specification__c && rateMetadata.ncsName__c != '' && ((offerId != null && rateMetadata.offerId__c == offerId) || (configRecord.Marketable_Offer__c != null && rateMetadata.offerId__c == configRecord.Marketable_Offer__r.Offer_ID__c))){
                            List<TierRateCardNCSDTO.Configuration> rateCardList = new List<TierRateCardNCSDTO.Configuration>();
                            if(ncsNameConfigCountMap == null || (ncsNameConfigCountMap != null && ((!ncsNameConfigCountMap.containsKey(configRecord.id)) || (ncsNameConfigCountMap.containsKey(configRecord.id) && !ncsNameConfigCountMap.get(configRecord.id).contains(rateMetadata.ncsName__c+'_schema'))))){
                                 rateCardList = populateRateCardList(rateMetadata,attrvalue);
                            }
                            if(rateCardList!=null && rateCardList.size()>0){
                                csoe__Non_Commercial_Schema__c ncs = ncsmap.containskey(rateMetadata.NCSName__c)? ncsmap.get(rateMetadata.NCSName__c) : null;
                              OETempList = new TierRateCardNCSUtility().createNewNCS(configRecord.id,rateMetadata.ncsName__c,rateCardList,ncs);   
                              
                              if(OETempList != null && OEConfigMap != null && OEConfigMap.containsKey(configRecord.id)){
                                    List<Object> templst = OEConfigMap.get(configRecord.id);
                                    templst.addAll(OETempList);
                                    OEConfigMap.remove(configRecord.id);
                                    OEConfigMap.put(configRecord.id,templst);
                              } 
                              else if (OETempList != null && (OEConfigMap == null || !OEConfigMap.containsKey(configRecord.id))){
                                  OEConfigMap.put(configRecord.id,OETempList);
                              }
                            }    
                        }
                    } 
                return true;
            }catch(Exception e){
                return false;
            }
        }
        /*
       Method to fetch the rate card entries & associate to the PC record. Association of NCS to PC is done by invoking TierRateCardNCSUtility class.
       Call will be performed only if there is no existing attachment created for that NCS.
       
       Added by shubhi to handle modify scenario Edge-137067
       
       */
        public Boolean upsertRateCardNCS(String basketId, cscfga__product_configuration__c configRecord,String offerId,Map<String,String> attrvalue){
            try{  
               List<Object> OETempList = new List<Object>();
                    for(CustomRateCard__mdt rateMetadata : rateCardMetadataList){
                        if(configRecord!=null && rateMetadata.ProductSpecId__c == configRecord.cscfga__Product_Definition__r.product_Specification__c && rateMetadata.ncsName__c != '' && ((offerId != null && rateMetadata.offerId__c == offerId) || (configRecord.Marketable_Offer__c != null && rateMetadata.offerId__c == configRecord.Marketable_Offer__r.Offer_ID__c))){
                            List<TierRateCardNCSDTO.Configuration> rateCardList = new List<TierRateCardNCSDTO.Configuration>(); 
                            rateCardList = populateExistingRateCardList(rateMetadata,attrvalue,configRecord.id);
                            if(rateCardList!=null && rateCardList.size()>0){
                                csoe__Non_Commercial_Schema__c ncs = ncsmap.containskey(rateMetadata.NCSName__c)? ncsmap.get(rateMetadata.NCSName__c) : null;
                                OETempList = new TierRateCardNCSUtility().createNewNCS(configRecord.id,rateMetadata.ncsName__c,rateCardList,ncs);                                   
                                if(OETempList != null ){
                                    if(ncsNameConfigCountMap != null && ncsNameConfigCountMap.containsKey(configRecord.id) && ncsNameConfigCountMap.get(configRecord.id).contains(rateMetadata.ncsName__c+'_schema')){
                                        if(NCSNametoBenewInsertedList!=null && NCSNametoBenewInsertedList.contains(rateMetadata.ncsName__c)){
                                            if(OEConfigMap != null && OEConfigMap.containsKey(configRecord.id)){
                                                List<Object> templst = OEConfigMap.get(configRecord.id);
                                                templst.addAll(OETempList);
                                                OEConfigMap.remove(configRecord.id);
                                                OEConfigMap.put(configRecord.id,templst);
                                            }else{
                                                OEConfigMap.put(configRecord.id,OETempList);
                                            }
                                        }else{
                                            if(oeMapUpdate != null && oeMapUpdate.containsKey(configRecord.id)){
                                            List<Object> templst = oeMapUpdate.get(configRecord.id);
                                            templst.addAll(OETempList);
                                            oeMapUpdate.remove(configRecord.id);
                                            oeMapUpdate.put(configRecord.id,templst);
                                            }else{
                                            oeMapUpdate.put(configRecord.id,OETempList);
                                            }
                                        }
                                    }else{
                                        if(OEConfigMap != null && OEConfigMap.containsKey(configRecord.id)){
                                            List<Object> templst = OEConfigMap.get(configRecord.id);
                                            templst.addAll(OETempList);
                                            OEConfigMap.remove(configRecord.id);
                                            OEConfigMap.put(configRecord.id,templst);
                                        }else{
                                            OEConfigMap.put(configRecord.id,OETempList);
                                        }
                                        
                                        
                                    }
                                } 
                             
                            } 
                            
                           
                        }
                    } 
                       
                system.debug('oeMapUpdate--->'+oeMapUpdate);
                system.debug('OEConfigMap--->'+OEConfigMap);
                
                return true;
            }catch(Exception e){
                return false;
            }
        }
        public static List<cspmb__price_item__c> fetchPriceItemEntries(){
                List<cspmb__price_item__c> priceItemsList = [select id, name,rangeFrom__c, rangeTo__c,cspmb__Recurring_Charge__c,Billing_Description__c,Unit_Of_Measure__c,External_Id__c ,Offer_Id__c,Charge_Id__c,Plan__c,Mode__c,ProdSpecId__c,Feature_Level__c,Technical_Support__c from cspmb__price_item__c where Offer_Id__c =:offerId and ProdSpecId__c in :prodspecids and cspmb__Effective_End_Date__c >= TODAY AND cspmb__Effective_Start_Date__c <= TODAY AND Check_todays_date__c = true order by cspmb__Recurring_Charge__c DESC];// qury updated for Edge-117563 // Updated by shubhi for Edge-137067
             return priceItemsList;
        }
        //Method to fetch all the Rate card entries from the custom metadata.
        public static List<CustomRateCard__mdt> fetchRateCardMetadata(){
            try{
                List<CustomRateCard__mdt> rateCardMetadataList = [select OfferId__c,isActive__c,filterCriteria__c,Commercial_Product_Code__c, ProductSpecId__c,NCSName__c, DependentAttributeName__c, PriceItemFilters__c,charge_Id__c from CustomRateCard__mdt where OfferId__c=:offerId AND isActive__c=true]; // Added isActive__c by shubhi for Edge-137067
                return rateCardMetadataList;
            }catch(Exception e){
                return null;
            }
        }
        //Method to fetch the Price item entries for Rate card & associating the correct rate card entries to each of the NCS using the data from the custom metadata record.
        public List<cspmb__price_item__c> getRateCardRecords(CustomRateCard__mdt rateMetadata,String oeschemadesc,Map<String,String> attrvalue){
            List<String> priceitemfieldlst = new List<String>();
            String queryfieldsString;
            String query = null;
            String chargeId = rateMetadata.charge_Id__c;//EDGE-135705
            List<cspmb__price_item__c> priceItemListfiltered = new List<cspmb__price_item__c>();
            String oeschemadescstring = oeschemadesc;
            /// Edge-137067 start ///////////
            for(cspmb__price_item__c pi : priceItemList){
                if(rateMetadata.filterCriteria__c != null && String.isNotBlank(rateMetadata.filterCriteria__c)){
                    List<String> filterCriteriaList =new List<String>();
                    filterCriteriaList = (rateMetadata.filterCriteria__c.contains(';')) ? rateMetadata.filterCriteria__c.split(';') : new List<String>{rateMetadata.filterCriteria__c};                     
                    if(filterCriteriaList!=null){
                        system.debug('fields inside if comparision-->'+filterCriteriaList);                                 
                        if(attrvalue!=null && !attrvalue.isEmpty()){
                            Boolean isAllConditionSatisfied=true;   
                            for(string filterString:filterCriteriaList){
                                String attIdentifier=filterString.substringAfter(':');
                                String fieldTofiltered= filterString.substringBefore(':');
                                system.debug('inside if att'+pi.get(fieldTofiltered)+'@@'+attrvalue.get(attIdentifier));
                                if(attrvalue.containskey(attIdentifier)){
                                    if( pi.get(fieldTofiltered)!=attrvalue.get(attIdentifier)){              
                                        isAllConditionSatisfied=false;
                                    }
                                }else{
                                    isAllConditionSatisfied=false;
                                }                           
                            }
                            system.debug(isAllConditionSatisfied);
                            if(isAllConditionSatisfied && rateMetadata.OfferId__c==pi.Offer_Id__c && rateMetadata.Charge_Id__c==pi.Charge_Id__c){
                                priceItemListfiltered.add(pi);
                            }
                        }
                    }
                }else{
                    system.debug('inside else');
                    if(rateMetadata.OfferId__c==pi.Offer_Id__c && rateMetadata.Charge_Id__c==pi.Charge_Id__c){
                        priceItemListfiltered.add(pi);
                    }
                }               
            }       
            /// Edge-137067 end /////////////
            system.debug('filtered list-->'+priceItemListfiltered);
            return priceItemListfiltered;
        }
        //Method to create an wrapper with the price item entries.  
        public List<TierRateCardNCSDTO.Configuration> populateRateCardList(CustomRateCard__mdt rateMetadata,Map<String,String> attrvalue){
            List<TierRateCardNCSDTO.Configuration> rateCardList = new List<TierRateCardNCSDTO.Configuration>();
            try{
            TierRateCardNCSUtility ncsutility = new TierRateCardNCSUtility();
                //csoe__Non_Commercial_Schema__c ncs =ncsutility.fetchNCSInstance(rateMetadata.NCSName__c);
                //List<cspmb__price_item__c> priceItemList = getRateCardRecords(rateMetadata.offerId__c,rateMetadata.productSpecId__c,rateMetadata.commercial_product_code__c);
                for(cspmb__price_item__c priceItem : getRateCardRecords(rateMetadata,null,attrvalue)){
                    TierRateCardNCSDTO.Configuration numConfig = new TierRateCardNCSDTO.Configuration();
                    numConfig = new TierRateCardNCSDTO.Configuration();
                    numConfig.rangeFrom = priceItem.rangeFrom__c;
                    numConfig.rangeTo = priceItem.rangeTo__c;
                    numConfig.price = priceItem.cspmb__Recurring_Charge__c;
                    numConfig.externalId = priceItem.External_Id__c;  //EDGE-123778
                    rateCardList.add(numConfig);
                }
                return rateCardList;
            }catch(Exception e){
             system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
                return null;
            }
        }
        //Method to create an wrapper with the price item entries in case of modify Edge-137067.  
        public List<TierRateCardNCSDTO.Configuration> populateExistingRateCardList(CustomRateCard__mdt rateMetadata,Map<String,String> attrvalue,String pcId){
            List<TierRateCardNCSDTO.Configuration> rateCardList = new List<TierRateCardNCSDTO.Configuration>();
            try{
            TierRateCardNCSUtility ncsutility = new TierRateCardNCSUtility();
            List<String> externalIdListTobeUpserted=new List<String>();
                for(cspmb__price_item__c priceItem : getRateCardRecords(rateMetadata,null,attrvalue)){
                    TierRateCardNCSDTO.Configuration numConfig = new TierRateCardNCSDTO.Configuration();
                    numConfig = new TierRateCardNCSDTO.Configuration();
                    numConfig.rangeFrom = priceItem.rangeFrom__c;
                    numConfig.rangeTo = priceItem.rangeTo__c;
                    numConfig.price = priceItem.cspmb__Recurring_Charge__c;
                    numConfig.externalId = priceItem.External_Id__c;  //EDGE-123778                 
                    if(ncsNameConfigCountMap!=null && ncsNameConfigCountMap.containskey(pcId) && ncsNameConfigCountMap.get(pcId)!=null && ncsNameConfigCountMap.get(pcId).contains(rateMetadata.ncsName__c+'_schema') && existingExternalIdMap!=null && existingExternalIdMap.containsKey(rateMetadata.ncsName__c)){
                        if(existingExternalIdMap.get(rateMetadata.ncsName__c)!=null && existingExternalIdMap.get(rateMetadata.ncsName__c).containsKey(numConfig.externalId)){
                            numConfig.guid=existingExternalIdMap.get(rateMetadata.ncsName__c).get(numConfig.externalId).guid;
                        }else{
                            NCSNametoBenewInsertedList.add(rateMetadata.ncsName__c);
                        }
                        externalIdListTobeUpserted.add(numConfig.externalId);
                    }                                   
                    rateCardList.add(numConfig);
                }
                if(ExternalIdListTobeUpserted!=null && !ExternalIdListTobeUpserted.isEmpty())
                    ExternalIdListTobeUpsertedMap.put(rateMetadata.ncsName__c,ExternalIdListTobeUpserted);  
                
                system.debug('rate card list'+rateCardList);
                return rateCardList;
            }catch(Exception e){
             system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
                return null;
            }
        }
        //Method to check if the PC has attachment record for the rate card entries.
        public static Map<String,Set<String>> checkForExistingNCS(List<Id> prodConfigIdlst){
            //try{
                Set<String> jsonschemanames = new Set<String>();
                if(prodConfigIdlst!=null){
                    String attname = '%schema%';
                    for(attachment att : [select id,body,Name,ParentId from attachment where ParentId in :prodConfigIdlst and Name like :attname order by ParentId]){
                        String jsonStr = att.body.toString();
                        String jsonschemaname = att.name.split('.json')[0];
                        string ncsName=jsonschemaname.split('_schema')[0];
                        if(NCSnameslst.contains(ncsName)){
                            TierRateCardNCSDTO ncsDTO = TierRateCardNCSDTO.parse(jsonStr);
                            if(ncsDTO!=null && ncsDTO.configurations!=null && ncsDTO.configurations.size()>0){
                                if(ncsNameConfigCountMap.containskey(att.ParentId)){
                                        jsonschemanames = ncsNameConfigCountMap.get(att.ParentId);
                                        jsonschemanames.add(jsonschemaname);
                                        ncsNameConfigCountMap.remove(att.ParentId);
                                        ncsNameConfigCountMap.put(att.ParentId,jsonschemanames);
                                }
                                else {
                                        ncsNameConfigCountMap.put(att.ParentId,new Set<String>{jsonschemaname});
                                }
                                //Edge-137067 start ------------------------
                                Map<String,TierRateCardNCSDTO.Configuration> extIdMap=new Map<String,TierRateCardNCSDTO.Configuration>();
                                for(TierRateCardNCSDTO.Configuration config:ncsDTO.configurations){
                                    extIdMap.put(config.externalId,config);
                                }
                                if(extIdMap!=null && !extIdMap.isEmpty()){
                                    existingExternalIdMap.put(ncsName,extIdMap);
                                }
                                //Edge-137067 end ------------------------
                            }
                        }
                    }
                    system.debug('existing external id list-->'+existingExternalIdMap);
                }
                return ncsNameConfigCountMap;
            /*}catch(Exception e){
                system.debug('Exception in checkForExistingNCS ' + e);
                return null;
            }*/
        }
         
         
        /*edge-137067 method to delete existing ncs */
        public void populateToBeDeletedrateCardList(){
            Map<Id,List<Object>> oeMapDelete = new Map<Id,List<Object>>();      
            if(ncsNameConfigCountMap !=null && !ncsNameConfigCountMap.isEmpty() && rateCardMetadataList!=null && !rateCardMetadataList.isEmpty()&& existingExternalIdMap!=null && !existingExternalIdMap.isEmpty()){
                for(String pcid:ncsNameConfigCountMap.keyset()){
                    if(ncsNameConfigCountMap.get(pcid)!=null){
                        List<Object> nceList = new List<Object>();
                        for(CustomRateCard__mdt rateMetadata : rateCardMetadataList){
                            List<String> populateConfigListTobeDeleted = new List<String>();
                            if(ncsmap!=null){
                                csoe__Non_Commercial_Schema__c ncs = ncsmap.containskey(rateMetadata.NCSName__c)? ncsmap.get(rateMetadata.NCSName__c) : null;
                                if(existingExternalIdMap.containsKey(rateMetadata.NCSName__c)&& existingExternalIdMap.get(rateMetadata.NCSName__c)!=null && ExternalIdListTobeUpsertedMap!=null && ExternalIdListTobeUpsertedMap.containsKey(rateMetadata.NCSName__c)){
                                    for(String extID:existingExternalIdMap.get(rateMetadata.NCSName__c).keySet()){
                                        if(ExternalIdListTobeUpsertedMap!=null && !ExternalIdListTobeUpsertedMap.get(rateMetadata.NCSName__c).contains(extID)){
                                            TierRateCardNCSDTO.Configuration conf = new TierRateCardNCSDTO.Configuration();
                                            conf=existingExternalIdMap.get(rateMetadata.NCSName__c).get(extID);
                                            Map<String, Object> config = new Map<String, Object>();
                                            /*config.put('rangeFrom', conf.rangeFrom );
                                            config.put('rangeTo', conf.rangeTo);
                                            config.put('price', conf.price);
                                            config.put('externalId', conf.externalId);  //EDGE-123778*/
                                            //config.put('guid', conf.guid);  //EDGE-123778
                                            populateConfigListTobeDeleted.add(conf.guid);
                                        }
                                    }
                                   
                                    if(populateConfigListTobeDeleted!=null && !populateConfigListTobeDeleted.isEmpty()){
                                        Map<String,Object> nce = new Map<String,Object>();
                                        nce.put('name', (Object) rateMetadata.NCSName__c);
                                        nce.put('id', (Object) ncs.Id);
                                        nce.put('configurations', populateConfigListTobeDeleted);
                                        nceList.add((Object) nce);
                                    }
                                }
                            }
                        }
                        Id attParentId=pcid;
                        if(nceList!=null && !nceList.isEmpty()){
                            oeMapDelete.put(attParentId,nceList);
                        }
                        system.debug('oeMapDelete--->'+oeMapDelete);
                    }                   
                }
                csoe.API_1.deleteOEData(oeMapDelete);
            }
        
        }
    }