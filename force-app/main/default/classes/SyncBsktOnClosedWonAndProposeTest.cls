/*************************************************************************************************
Name : SyncBsktOnClosedWonAndProposeTest
Description : Test class for SyncBasketOnClosedWonAndProposeOppty class
***************************************************************************************************/
@isTest
public class SyncBsktOnClosedWonAndProposeTest {
    @isTest
    public static void testBasketSyncOnPropose(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.Primary_Basket__c = true;
        insert basket;
        PricebookEntry pbe = createProductAndPricebookEntry();
        createProductConfigAndOtherRelatedData(basket,pbe,opp);
        Test.startTest();
        try{
            opp.StageName = 'Propose';
            update opp;
        }
        catch(Exception e)
        {
           opp = [Select stageName from Opportunity where id=:opp.id]; 
           System.assertNotEquals('Propose', opp.StageName);
           System.debug(' In Exception');
        }
        Test.stopTest(); 
        //basket = [Select csbb__Synchronised_With_Opportunity__c from cscfga__Product_Basket__c];
        //System.assertEquals(true,basket.csbb__Synchronised_With_Opportunity__c);
        
    }
    private static PricebookEntry createProductAndPricebookEntry()
    {
        //Create Product
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create Pricebook
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        //Create PricebookEntry
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        
        insert pbe;
        return pbe;
    } 
  
    private static void createProductConfigAndOtherRelatedData(cscfga__Product_Basket__c basket,PricebookEntry pbe, Opportunity opp)
    {
        //Create Product Configuration
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        update config;
        
        //Create Product Definition
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('test','test');
        insert pd;
        
        //Create Attribute Definition with desynchronised flag
        cscfga__Attribute_Definition__c atrDef = ProductTestFactory.buildAttributeDefinition('test',pd.id);
        atrDef.cscfga__is_Significant__c = true;
        insert atrDef;
        
        //Create Attribute
        cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('Product', 'TestProduct', config.id);
        attr0.cscfga__Attribute_Definition__c = atrDef.id;
        insert attr0;              
        
        //Create Opportunity Product and link attribute
        OpportunityLineItem oli = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityID = basket.cscfga__Opportunity__c, Description = config.cscfga__Description__c,cscfga__Attribute__c = attr0.id,Product_Status__c = 'Lost',Product_Name__c='test prod');
        insert oli;
        
        //Create Product Category
        cscfga__Product_Category__c  pc = ProductTestFactory.buildProductCategory();
        insert pc;
        
        //Create Product Configuration Request
        csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
        pcr.csbb__Product_Category__c = pc.id;
        pcr.csbb__Product_Configuration__c = config.id;
        pcr.csbb__Product_Basket__c = basket.id;
        insert pcr;
        
    }
}