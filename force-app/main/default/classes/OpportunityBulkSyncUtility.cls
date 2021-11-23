public class OpportunityBulkSyncUtility {
    public static String DISPLAY_MESSAGE;
    private static Pricebook2 stdPriceBook;
    //public static String status;
    public static String totalInfo;
    
    public static void syncWithOpportunity(List<cscfga__Product_Basket__c> productBaskets) { 
        syncWithOpportunity(productBaskets, '');
    }
    public static void syncWithOpportunity(List<cscfga__Product_Basket__c> productBaskets, String stageName) {        
       try{   
            //String basketStage = stageName;            
            if(productBaskets.isEmpty()) {
                //DISPLAY_MESSAGE = 'One or more invalid product configurations in the basket';
                return;
            }
            
            List<String> basketIds = new List<String>();
            List<String> opptyIds = new List<String>();
            for(cscfga__Product_Basket__c pb: productBaskets){
                basketIds.add(pb.Id);
                opptyIds.add(pb.cscfga__Opportunity__c);
            }
            List<cscfga__Product_Configuration__c> configList = OpportunityBulkSyncHelper.getConfigList(basketIds);
            List<cscfga__Product_Basket__c> newprodBasket = getValidProductBasket(basketIds, configList);
            If(newprodBasket.size() != productBaskets.size()){
                //DISPLAY_MESSAGE = 'One or more invalid product configurations in the basket';
                //return;
                System.debug('There are invalid baskets');
            }
            
            
            
            List<Opportunity> opptys = [SELECT Id, Name, Pricebook2Id, Amount, StageName, Pricebook2.IsStandard from Opportunity where Id in :opptyIds and stageName!='Closed Won' and stageName!='Closed Lost' and stageName!= 'Closed Sales'];
            System.debug('Delete OLI');
            
            
            OpportunityBulkSyncHelper.deleteOLI(opptyIds);

            // Clean up the product configs in the basket
            System.debug('Delete orphanProdConfs');
            deleteOrphanProdConfigs(basketIds);
            
            // Set the oppt price book to standard
            System.debug('Set standard price book');
            setOppToStdPriceBook(opptys);

            // Create temp bundle to support the sync
            List<cscfga__Product_Bundle__c> bundles = OpportunityBulkSyncHelper.createTempBundle(newprodBasket);
            Database.update(newprodBasket,false);
            
            // Sync the oppt with bundle
            System.debug('Syyync.....');
            for(cscfga__Product_Bundle__c bundle: bundles){ 
                System.debug('Sync this : '+bundle);
                cscfga.API_1.syncBundleToOpportunity(bundle.Id);
            }
            
            // Clean up the temp bundle
            System.debug('Clean up temp bundle');
            OpportunityBulkSyncHelper.cleanupTempBundle(newprodBasket, bundles, stageName);

            // Update the oppt info
            System.debug('Update opportunity');
            OpportunityBulkSyncHelper.updateOpptInfo(opptys, newprodBasket, stageName);

            Database.update(newprodBasket,false);
            Database.update(opptys,false);

            configList = null;
            configList = OpportunityBulkSyncHelper.getConfigList(basketIds);
            List<OpportunityLineItem> oliList = OpportunityBulkSyncHelper.getOLIlist(opptyIds);
            OpportunityBulkSyncHelper.updateOLIs(newprodBasket, configList, oliList);  

            //DISPLAY_MESSAGE = 'Basket sync with Opportunity completed successfully';

        } catch (Exception e) {
            Logger.getLogger(OpportunityBulkSyncUtility.class).debug(e);
            //DISPLAY_MESSAGE = e.getMessage();
            //return '{"status":"error", "text":"' + e.getMessage() +'"}';
        }
        //return '{"status":"ok","text":"' + DISPLAY_MESSAGE +'"}';
    }
    
    @TestVisible
    private static void deleteOrphanProdConfigs(List<String> basketIds){
        List<cscfga__Product_Configuration__c> orphanProdConfs = [SELECT c.id 
                                                                     FROM cscfga__Product_Configuration__c c 
                                                                     WHERE cscfga__product_basket__c = : basketIds
                                                                     AND cscfga__root_configuration__c = null 
                                                                     AND id NOT IN (SELECT csbb__product_configuration__c 
                                                                                    FROM csbb__Product_Configuration_Request__c 
                                                                                    WHERE csbb__product_basket__c = :basketIds 
                                                                                    AND csbb__product_configuration__c != null)];
        if(orphanProdConfs.size() > 0){
            Database.delete(orphanProdConfs,false);
        } 
    }
    
    @TestVisible
    private static void setOppToStdPriceBook(List<Opportunity> opptys){
        // attach opportunity to standard pricebook
        String pricebookId = getStdPricebookId();
        for(Opportunity oppty : opptys){
            if(!oppty.Pricebook2.IsStandard){
                oppty.Pricebook2Id = pricebookId;
            }
        }
    }


    public static Pricebook2 getStdPriceBook () {
        if (stdPriceBook == null) {
            stdPriceBook  = [select id, name from Pricebook2 where isStandard = true limit 1];
        }
        return stdPriceBook;    
    }
    
    public static ID getStdPricebookId() {
        if (Test.isRunningTest()){
            return Test.getStandardPricebookId();
        }
        return getStdPricebook().id;
    }  
    
    
    
    @TestVisible
    private static List<cscfga__Product_Basket__c> getValidProductBasket(List<String> basketIds, List<cscfga__Product_Configuration__c> configList){
        
        String queryString = 'SELECT ' + OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard, cscfga__Opportunity__r.stageName ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c where id in :basketIds and cscfga__Opportunity__r.stageName!=\'Closed Won\' and cscfga__Opportunity__r.stageName!= \'Closed Lost\' and cscfga__Opportunity__r.stageName!= \'Closed Sales\'';
        List<cscfga__Product_Basket__c> productBasketList = Database.query(queryString);
        
        for(cscfga__Product_Configuration__c pc: configList){
            //configIds.add(pc.cscfga__Product_Configuration__r);
            if (pc.cscfga__Configuration_Status__c != 'Valid'){
               DISPLAY_MESSAGE = 'One or more invalid product configurations in the basket';
            }
        }
                                                       
        for (cscfga__Product_Configuration__c config: configList) {
            for(cscfga__Attribute__c attr:config.cscfga__Attributes__r){
                if(attr.cscfga__Value__c == null && attr.Name == 'Product'){
                    system.debug('******'+ attr.cscfga__Value__c);
                    DISPLAY_MESSAGE = 'Please select  products for all configurations or delete unwanted configurations before sync';
                }
            }  
        }
        return productBasketList;
    }
    
}