public with sharing class OpportunityBulkSyncHelper {

    /****Delete Existing Opportunity Products and PriceBook Entry****/ 
    public static void deleteOLI(List<String> opptyIds){
        List<OpportunityLineItem> oppLIs = [SELECT id,name, pricebookEntryId FROM OpportunityLineItem WHERE OpportunityId in :opptyIds];                  
        if(!oppLIs.isEmpty()){
            Database.delete(oppLIs,false);
        }
    }
    
    public static List<OpportunityLineItem> getOLIlist(List<Id> opptyIds){
        List<OpportunityLineItem> olilist = [SELECT id,name,Description,SRM__c,Quantity,UnitPrice,
                                             pricebookEntryId,OpportunityId,TotalPrice,cscfga__Attribute__c,cscfga__Attribute__r.cscfga__Product_Configuration__c
                                             FROM OpportunityLineItem
                                             WHERE OpportunityId in :opptyIds];
        return olilist;
    }

    public static List<cscfga__Product_Configuration__c> getConfigList(List<String> basketIds){
        List<cscfga__Product_Configuration__c> configList  = [SELECT id, Name, cscfga__Product_Bundle__c, cscfga__Key__c, cscfga__Product_Basket__r.cscfga__Opportunity__c,
                       cscfga__Description__c,cscfga__Contract_Term__c,contract_amount__c,cscfga__Configuration_Status__c,
                       (SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r)
                       FROM  cscfga__Product_Configuration__c
                       WHERE cscfga__Product_Basket__c in:basketIds];

        return configList;
    }
    
    /****create new Opportunity Product****/
    public static void updateOLIs(List<cscfga__Product_Basket__c> productBaskets, List<cscfga__Product_Configuration__c> configList, List<OpportunityLineItem> olilist){
        Boolean isStatusWon = true;
        Boolean isUpdated = false;
        
        for(OpportunityLineItem oli: olilist){
            isStatusWon = true;     
            for(cscfga__Product_Configuration__c config: configList) {
                System.debug('******'+oli.Description +'******'+config.cscfga__Contract_Term__c);
                //Mapping Product Configuration from attribute on OLI with the corresponding product configurations on attribute.  
                if(oli.cscfga__Attribute__r.cscfga__Product_Configuration__c == config.Id) {
                    System.debug('******'+oli.Description +'******'+config.cscfga__Contract_Term__c);
                    
                    //Mapping Attributes values 
                    updateAttributes(oli, config, isStatusWon);
                } 
            }
            oli.UnitPrice = oli.UnitPrice/oli.Quantity;
        }
        if(!olilist.isEmpty())
        	Database.update(olilist,false);
    }

    public static String getSobjectFields(String so){
        String fieldString;
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        List < Schema.SObjectField > fields = sot.getDescribe().fields.getMap().values();
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
    }
    
    public static List<cscfga__Product_Bundle__c> createTempBundle(List<cscfga__Product_Basket__c> productBaskets) {
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
        Map<String, cscfga__Product_Bundle__c> bundleBasketMap = new Map<String, cscfga__Product_Bundle__c>();
        for(integer x=0; x<productBaskets.size(); x++){
            cscfga__Product_Bundle__c bundle = new cscfga__Product_Bundle__c(Name = productBaskets[x].Name, cscfga__Opportunity__c = productBaskets[x].cscfga__Opportunity__c, cscfga__Bundle_Status__c = 'Valid');
            
            bundleBasketMap.put(productBaskets[x].Id, bundle);
        }
        if(!bundleBasketMap.isEmpty())
        	Database.insert(bundleBasketMap.values(),false);
        
        
        for(integer y=0; y<productBaskets.size(); y++){
            for(cscfga__Product_Configuration__c pc: productBaskets[y].cscfga__Product_Configurations__r) {
                pc.cscfga__Product_Bundle__c = bundleBasketMap.get(productBaskets[y].Id).Id;
                System.debug('Bundle-PC Id : '+ pc.cscfga__Product_Bundle__c + '<==>' + pc.Id);
                configList.add(pc);
        }}
         if(!configList.isEmpty())
       		 Database.update(configList,false);
        return bundleBasketMap.values();
    }

    public static void cleanupTempBundle(List<cscfga__Product_Basket__c> productBaskets, List<cscfga__Product_Bundle__c> bundles, String basketStage) {
        
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
        for(cscfga__Product_Basket__c productBasket:productBaskets){
            productBasket.csbb__synchronised_with_opportunity__c = true;
            for(cscfga__Product_Configuration__c pc: productBasket.cscfga__Product_Configurations__r){
                pc.cscfga__Product_Bundle__c = null;
                configList.add(pc);
            }
            System.debug('PP basketStage : '+basketStage);
            if(!String.isEmpty(basketStage)){
                productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues(basketStage).Enrichment_Basket_Stage__c;
            }
        }
        if(!configList.isEmpty())
        	Database.update(configList,false);
        //update productBasket;
        Database.delete(bundles,false);
    }
    
    public static void updateOpptInfo(List<Opportunity> opps, List<cscfga__Product_Basket__c> productBaskets, String basketStage) {
        System.debug('PP basketStage : '+basketStage);
        for(cscfga__Product_Basket__c productBasket: productBaskets){
            for(Opportunity opp: opps){
                if(productBasket.cscfga__Opportunity__c == opp.Id){
                    if(!String.isEmpty(basketStage)){
                        opp.StageName = CustomConfigurationOptions__c.getValues(basketStage).Opportunity_Stage__c;
                    }
                    opp.Amount = productBasket.cscfga__total_contract_value__c;
                }
            }
        }
    } 
    
    @TestVisible
    private static void updateAttributes(OpportunityLineItem oli, cscfga__Product_Configuration__c config, Boolean isStatusWon){
    //Retrieve Fields from Custom Metadata type 'OpportunitySyncAttribute'
        List<OpportunitySyncAttribute__mdt> syncAttrList =[SELECT DeveloperName, MasterLabel, Datatype__c FROM OpportunitySyncAttribute__mdt];                   
        
      //Map Key Values of 'OpportunitySyncAttribute'
        Map<String,OpportunitySyncAttribute__mdt> syncattrMap = new Map<String,OpportunitySyncAttribute__mdt>();
        
      //Put Values from Map OpportunitySyncAttribute__mdt
            for(OpportunitySyncAttribute__mdt syc:syncAttrList)
            {
                syncAttrMap.put(syc.DeveloperName,syc);
              } 
        
        
        for(cscfga__Attribute__c attr: config.cscfga__Attributes__r){
            if(syncAttrMap.containsKey(attr.Name)){ 
                if(attr.cscfga__Value__c != null) {
                    if(syncAttrMap.get(attr.Name).Datatype__c== 'Decimal'){
                        oli.put(syncAttrMap.get(attr.Name).MasterLabel,Decimal.valueOf(attr.cscfga__Value__c));
                    }else
                        oli.put(syncAttrMap.get(attr.Name).MasterLabel,attr.cscfga__Value__c);
                }
            } 
        } 
    }
}