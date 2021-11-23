/*
* @Author :  Srujana Durvasula
* @Date   :  9 September 2020
* @Desc   :  Batch Class which executes Product rules to Validate and Save products to basket.
* @Jira   :  1. P2OB-9124
			 2. P2OB-10782 - Commenting auto-sync code for TESA Created Baskets
*/

global class ExecuteRulesInBatch implements Database.batchable<cscfga__Product_Configuration__c> {
    
    global String ProductBasketIdQry; 
    global Set<Id> PcIds = new Set<Id>();// capture all pc ids in this set
    
    Set<Id> pcIdList = new Set<Id>();
     
    //To capture Valid BasketID 
    global ExecuteRulesInBatch(String ProductBasketId) {
        ProductBasketIdQry = ProductBasketId;    
    }   
    
    //Start method which returns list of all ProductConfiguration ID's in the basket
    global Iterable<cscfga__Product_Configuration__c> start(Database.BatchableContext BC){
        // List < cscfga__Product_Configuration__c > prodConfigList = [Select id,cscfga__Product_Basket__c, cscfga__Product_Definition__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c  = :ProductBasketIdQry]; 
        // for (cscfga__Product_Configuration__c prodConfig: prodConfigList) {
        //         PcIds.add(prodConfig.Id);              
        //  }
        // List <cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>([Select Id,Name,cscfga__Product_Bundle__c,cscfga__Configuration_Offer__c,cscfga__Product_Basket__c, cscfga__Product_Definition__c, 
        // (Select Id from cscfga__attributes__r where Name = 'OldProduct') from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c  = :ProductBasketIdQry]);

        for(cscfga__Product_Configuration__c pc: [Select Id,Name,cscfga__Product_Bundle__c,cscfga__Configuration_Offer__c,cscfga__Product_Basket__c, cscfga__Product_Definition__c, 
        (Select Id from cscfga__attributes__r where Name = 'OldProduct') from cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c  = :ProductBasketIdQry]){
            if(pc.cscfga__attributes__r.size() == 0){
                PcIds.add(pc.Id);
            }
        }

        List <cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>([Select Id,Name,cscfga__Product_Bundle__c,cscfga__Configuration_Offer__c,cscfga__Product_Basket__c, cscfga__Product_Definition__c from cscfga__Product_Configuration__c WHERE Id IN:PcIds]);


        return pcList;
     }
    
    //Executes Product rules to Validate and Save products to basket
    global void execute(Database.BatchableContext bc, List<cscfga__Product_Configuration__c> scope){
        System.debug('scope---------------------->'+scope);
        //Start of oldProd Changes
        String pdId = scope[0].cscfga__Product_Definition__c;
        Id oldProductAttId = [Select Id from cscfga__attribute_definition__c where Name =: 'OldProduct' and cscfga__Product_Definition__c =: pdId].Id;
        Map<Id, String> pcToOldProdId = new Map<Id, String>();
        
        Set<Id> commercialProdId = new Set<Id>();
        
        for(cscfga__Product_Configuration__c pc: scope){
            pcIdList.add(pc.Id);
        }
        for(cscfga__attribute__c attRec: [Select Id, cscfga__Product_Configuration__c, cscfga__value__c from cscfga__attribute__c WHERE cscfga__Product_Configuration__c In: pcIdList and Name = 'Product']){
            commercialProdId.add(attRec.cscfga__value__c);
            pcToOldProdId.put(attRec.cscfga__Product_Configuration__c, attRec.cscfga__value__c);
        }
        
        Map<Id, cspmb__Price_Item__c> commercialProdMap = new Map<Id, cspmb__Price_Item__c> ([Select Id, Maxim_Product_Name__c FROM cspmb__Price_Item__c WHERE Id IN: commercialProdId]);
        
        List<cscfga__attribute__c> attToInsert = new List<cscfga__attribute__c>();
        
        for(cscfga__Product_Configuration__c pc: scope){
            cscfga__attribute__c attr = new cscfga__attribute__c();
            attr.cscfga__Attribute_Definition__c = oldProductAttId;
            attr.Name = 'OldProduct';
            attr.cscfga__value__c = commercialProdMap.get(pcToOldProdId.get(pc.Id)).Maxim_Product_Name__c;
            attr.cscfga__display_value__c = commercialProdMap.get(pcToOldProdId.get(pc.Id)).Maxim_Product_Name__c;
            attr.cscfga__Product_Configuration__c = pc.Id ;
            attToInsert.add(attr);
        }
        if(!attToInsert.isEmpty()){
            insert attToInsert;
        }
        //End of Changes
        
        for(cscfga__Product_Configuration__c pc:scope){
             System.debug('scopeInsideFor---------------------->'+scope);
                cscfga.API_1.ApiSession session = cscfga.API_1.getApiSession(pc);
             System.debug('sessionInsideFor---------------------->'+session);
                session.setConfigurationToEdit(pc);
                session.executeRules();
                session.persistConfiguration();
                session.validateConfiguration();
                session.close();
            }
    }   
    
    //Executes TotalCalculation on basket and Sync to Opportunity
    global void finish(Database.BatchableContext bc){
        Set<Id> bundleOrBasketIds = new set<Id>();
        bundleOrBasketIds.add(ProductBasketIdQry);//basketId
        cscfga.ProductConfigurationBulkActions.calculateTotals(bundleOrBasketIds); 
        //P2OB-10782 : Commenting auto-sync code for TESA Created Baskets
        //Sync to Opportunity for PrimaryBasket and BasketStatus is Valid
       /* List<AutoSync__e> syncEvents = new List<AutoSync__e>();
        List < cscfga__Product_Basket__c > updatedBskts = [Select id,Primary_Basket__c,cscfga__Basket_Status__c,csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where Id =: ProductBasketIdQry];
        for (cscfga__Product_Basket__c bas : updatedBskts) {     
        if (bas.Primary_Basket__c && bas.cscfga__Basket_Status__c == 'Valid')
                syncEvents.add(new AutoSync__e(Basket_Id__c = bas.id, SyncFlag__c = false)) ;
         }   
        if (syncEvents.size() > 0)
        EventBus.publish(syncEvents);*/
    }    
}