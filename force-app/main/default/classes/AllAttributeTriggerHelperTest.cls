/*********************************************************************************************************************************
 
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Gnana                   20.07.2020    CS Spring 20 upgrade                    
 *********************************************************************************************************************************
*/
@IsTest
public class AllAttributeTriggerHelperTest {
    //test method to create test data    
    @testsetup static void testdata() { 
        Account acc = AccountTestFactory.buildAccount('Test Account');
        acc.Customer_Status__c = 'Active';
        insert acc;
        PricebookEntry pbe = createProductAndPricebookEntry();
        Opportunity opp = createOpportunity(acc);
        cscfga__Product_Basket__c basket = createBasket(acc,opp);
        createProductConfigAndOtherRelatedData(basket,pbe,opp); 
    }
    
    @isTest
    public static void deleteSyncAttributes(){
        cscfga__Attribute__c attr = [Select id from cscfga__Attribute__c];
        OpportunityLineItem oli= [Select id,cscfga__Attribute__c, cscfga__Attribute__r.cscfga__Product_Configuration__c from OpportunityLineItem];
        
        Test.startTest();
        try
        {
            delete attr;
        }
        Catch (Exception e)
        {
            system.debug('Exception-'+e);
        }    
        Test.stopTest();
        //attribute is not deleted
        System.assertNotEquals(null,attr.id); 
    }

    /*
     * Gnana: CS Spring'20 Upgrade Start
     * Commented out below test method as not required anymore
    @isTest
    public static void updateProductBasketSyncFlag(){
        cscfga__Product_Basket__c bas = [Select id, csbb__synchronised_with_opportunity__c from cscfga__Product_Basket__c];
        //update sync flag to true;
        bas.csbb__synchronised_with_opportunity__c =true;
        update bas;
        System.assertEquals(true,bas.csbb__synchronised_with_opportunity__c);
        cscfga__Attribute__c attr = [Select id,name,cscfga__value__c from cscfga__Attribute__c];
        System.assertEquals('TestProduct',attr.cscfga__value__c);
        
        Test.startTest();
        //update value
        attr.cscfga__Value__c = 'Test Product 1';
        update attr;
        
        Test.stopTest();
        //sync flag on basket is updated to false
        //bas = [Select id, csbb__synchronised_with_opportunity__c from cscfga__Product_Basket__c];
        //System.assertEquals(false,bas.csbb__synchronised_with_opportunity__c);
    }*/

    private static PricebookEntry createProductAndPricebookEntry(){
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

    private static Opportunity createOpportunity(Account acc){
        //Create Opportunity
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Commercial Configuration';
        insert opp;
        System.assertNotEquals(null,opp);
        return opp;
    }
    
    private static cscfga__Product_Basket__c createBasket(Account acc,Opportunity opp){
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;  
        return basket;
    }

    private static void createProductConfigAndOtherRelatedData(cscfga__Product_Basket__c basket,PricebookEntry pbe, Opportunity opp){
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration'); 
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_1';
        customSetting.Opportunity_Stage__c = 'Define';
        insert customSetting;
    
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