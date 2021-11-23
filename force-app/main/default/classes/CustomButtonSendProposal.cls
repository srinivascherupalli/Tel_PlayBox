global with sharing class CustomButtonSendProposal extends csbb.CustomButtonExt {

    public String performAction(String basketId) 
    {

        String status = OpportunitySyncUtil.syncWithOpportunity(basketId,'Proposal Sent');
        String DISPLAY_MESSAGE = OpportunitySyncUtil.DISPLAY_MESSAGE;
        System.debug('PP DISPLAY_MESSAGE : '+DISPLAY_MESSAGE);
        PageReference ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
        ref.setRedirect(true);
        return '{"status":"'+ status + '","text":"' + DISPLAY_MESSAGE + '", "redirectURL":"' + ref.getUrl() +'"}';
    }
    /*
    @InvocableMethod
    public static void syncWithOpportunity(List<Id> basketIds)
    {
        if(basketIds!=null && basketIds.size()>0)
        {
            syncWithOpportunity(basketIds.get(0));
        }
    }
    
    public static String syncWithOpportunity(String basketId) 
    {        
        try 
        {            
            // Clean up the product configs in the basket
            deleteOrphanProdConfigs(basketId);
            
            //If any product config is invalid return error.
            cscfga__Product_Basket__c productBasket = getValidProductBasket(basketId);
            if(productBasket == null)
            {
                DISPLAY_MESSAGE = 'One or more invalid product configurations in the basket';
                return 'error';
            }
            
            // Set the oppt price book to standard
            setOppToStdPriceBook(productBasket);
            
            // Create temp bundle to support the sync
            cscfga__Product_Bundle__c bundle = createTempBundle(productBasket);
    
            // Sync the oppt with bundle        
            cscfga.API_1.syncBundleToOpportunity(bundle.Id);
            
            // Clean up the temp bundle
            cleanupTempBundle(productBasket, bundle);
    
            // Clean up the baskets
            cleanupOtherBaskets(productBasket);
            
            // Update the oppt info
            updateOpptInfo(productBasket);
            DISPLAY_MESSAGE = 'Basket sync with Opportunity completed successfully';
        } 
        catch (Exception e) 
        {
            DISPLAY_MESSAGE = e.getMessage();
            return 'error';
        }        
        return 'ok';
     }
    
     // Get a comma separated SObject Field list
     @TestVisible
     public static String getSobjectFields(String so) 
     {
        String fieldString;
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        List < Schema.SObjectField > fields = sot.getDescribe().fields.getMap().values();
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
     }
    
     @TestVisible
     private static void deleteOrphanProdConfigs(String basketId) 
     {
       List < cscfga__Product_Configuration__c > orphanProdConfs = [SELECT c.id 
                                                                     FROM cscfga__Product_Configuration__c c 
                                                                     WHERE cscfga__product_basket__c = : basketId 
                                                                        AND cscfga__root_configuration__c = null 
                                                                        AND id NOT IN (SELECT csbb__product_configuration__c 
                                                                                       FROM csbb__Product_Configuration_Request__c 
                                                                                       WHERE csbb__product_basket__c = : basketId 
                                                                                           AND csbb__product_configuration__c != null)];
       if (orphanProdConfs.size() > 0) 
       {
            delete orphanProdConfs;
       } 
    }
    
    @TestVisible
    private static cscfga__Product_Basket__c getValidProductBasket(String basketId) 
    {
        String queryString = 'SELECT ' + CustomButtonSynchronizeWithOpportunity.getSobjectFields('cscfga__Product_Basket__c') +
        ', cscfga__opportunity__r.pricebook2.isstandard ' +
        ', (SELECT cscfga__product_definition__r.name ' +
        ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
        getSobjectFields('cscfga__Product_Configuration__c') +
        ' FROM cscfga__Product_Configurations__r) ' +
        ' FROM cscfga__Product_Basket__c where id = \'' + basketId + '\'';
        List <cscfga__Product_Basket__c> productBasketList = Database.query(queryString);
        // check if all product configuration are valid
        for (cscfga__Product_Configuration__c pc: productBasketList[0].cscfga__Product_Configurations__r)
        {
            if (pc.cscfga__Configuration_Status__c != 'Valid') 
            {
                return null; 
            }
        }
        return productBasketList[0];
    }
    
    @TestVisible
    private static void setOppToStdPriceBook(cscfga__Product_Basket__c productBasket)
    {
        // if pricebook attached to the opportunity is not standard delete all 
        // opportunity line items and attach opportunity to standard pricebook
        if (!productBasket.cscfga__Opportunity__r.Pricebook2.IsStandard) 
        {
             Opportunity opp = [SELECT id, pricebook2id,(SELECT id FROM OpportunityLineItems)
                                FROM Opportunity
                                WHERE id = :productBasket.cscfga__Opportunity__c];
             if (opp.OpportunityLineItems.size() > 0) 
             {
                delete opp.OpportunityLineItems;
             }
             // get Id of standard pricebook and attach it to the opportunity 
             opp.Pricebook2Id = [SELECT id FROM Pricebook2 WHERE isstandard = true].Id;
             update opp;
        }
    }
    
    @TestVisible
    private static cscfga__Product_Bundle__c createTempBundle(cscfga__Product_Basket__c productBasket) 
    {
        cscfga__Product_Bundle__c bundle = new cscfga__Product_Bundle__c(Name = productBasket.Name, cscfga__Opportunity__c = productBasket.cscfga__Opportunity__c, cscfga__Bundle_Status__c = 'Valid');
        insert bundle;
        List < cscfga__Product_Configuration__c > configList = new List < cscfga__Product_Configuration__c > ();
        for (cscfga__Product_Configuration__c pc: productBasket.cscfga__Product_Configurations__r) 
        {
         pc.cscfga__Product_Bundle__c = bundle.Id;
         configList.add(pc);
        }
        update configList;
        update bundle;
        return bundle;
    }
    @TestVisible
    private static void cleanupTempBundle(cscfga__Product_Basket__c productBasket, cscfga__Product_Bundle__c bundle) {
        productBasket.csbb__synchronised_with_opportunity__c = true;
        List < cscfga__Product_Configuration__c > configList = new List < cscfga__Product_Configuration__c > ();
        for (cscfga__Product_Configuration__c pc: productBasket.cscfga__Product_Configurations__r) {
            pc.cscfga__Product_Bundle__c = null;
            configList.add(pc);
        }
        
        productBasket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('Proposal Sent').Enrichment_Basket_Stage__c;
        update configList;
        update productBasket;
        delete bundle;
    }
    
    @TestVisible
    private static void cleanupOtherBaskets(cscfga__Product_Basket__c productBasket) {
        // clear synchronized with opportunity flag for baskets attached to the opportunity 
        List <cscfga__Product_Basket__c> productBasketList = [SELECT id, csbb__synchronised_with_opportunity__c
                                                              FROM cscfga__Product_Basket__c
                                                              WHERE cscfga__opportunity__c = : productBasket.cscfga__Opportunity__c 
                                                                  AND csbb__synchronised_with_opportunity__c = true 
                                                                  AND id != : productBasket.Id];
        if (productBasketList.size() > 0) {
            for (Integer i = 0; i < productBasketList.size(); i++) {
                productBasketList[i].csbb__Synchronised_with_Opportunity__c = false;
            }
            update productBasketList;
        }
    }
    
    @TestVisible
    private static void updateOpptInfo(cscfga__Product_Basket__c productBasket) {
        Opportunity opp = [SELECT id, pricebook2id,(SELECT id FROM OpportunityLineItems)
                                FROM Opportunity
                                WHERE id = :productBasket.cscfga__Opportunity__c];
        opp.StageName = CustomConfigurationOptions__c.getValues('Proposal Sent').Opportunity_Stage__c;
        opp.Amount = productBasket.cscfga__total_contract_value__c;
        update opp;
    }*/
}