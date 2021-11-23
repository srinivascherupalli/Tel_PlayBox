/*
 * 
 * @Author      : Srujana Durvasula
 * @Date        : 9 September 2020
 * @Description : Test class for ExecuteRulesInBatch
 * @Jira        : P2OB-9124
 */

 @IsTest
public class ExecuteRulesInBatchTest {
    
       @testsetup static void testdata() {
       //private void setup() { 
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        System.assertNotEquals(null, acc);
    
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
    
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
    
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod, pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        cscfga__Product_Basket__c prodbasket = new cscfga__Product_Basket__c();
        prodbasket.csbb__Account__c = acc.id;
        prodbasket.cscfga__Opportunity__c = opp.id;
        prodbasket.Name = 'basket2';
        prodbasket.Project_ID__c = 'prodbasket';
        prodbasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodbasket;
        
        cscfga__Product_Definition__c currentProductCatalog = new cscfga__Product_Definition__c(Name = 'Current Product Catalog', cscfga__Description__c = 'This is non-modular product for GCC');
        insert currentProductCatalog;
          
           Marketable_Offer__c moIoT = new Marketable_Offer__c();
           moIoT.OfferDefinationName__c ='Telstra Collaboration Professional Services Solution' ;
           moIoT.Name = 'Telstra Collaboration Professional Services';
           moIoT.Offer_ID__c = 'DMCAT_Offer_000936';
           insert moIoT; 
           
       /* cscfga__Product_Configuration__c config3 = ProductTestService.createProductConfiguration();
        config3.cscfga__Product_Basket__c = prodbasket.id;
        config3.cscfga__Description__c = 'test Description 3';
        config3.cscfga__Product_Definition__c=currentProductCatalog.Id;
        config3.cscfga__Contract_Term__c = 12;
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c> {config3};
        insert prodConfigList;*/
           
           //Create Product configuration
           List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
           cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(currentProductCatalog.id);
           config.cscfga__Product_Definition__c = currentProductCatalog.id;
           config.cscfga__Product_Basket__c = prodbasket.id;
           config.cscfga__Description__c = 'test Description';
           config.cscfga__Contract_Term__c = 36;
           config.Commercial_Config__c='Yes';
           config.Quantity_Product_Configuration__c=1;
           config.cscfga__total_one_off_charge__c=100.12;
           config.cscfga__total_recurring_charge__c=100;
           config.name='Test Configs';
           config.Type__c = 'New';
           config.Marketable_Offer__c = moIoT.id;
           config.cscfga__Product_Family__c='Current Product Catalog';
           config.cscfga__unit_recurring_charge__c = 200;
           prodConfigList.add(config);
           insert prodConfigList;
           
   
        cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
        testPriceItem.Name = 'CurrentProductCatalog';
        testPriceItem.cspmb__Contract_Term__c = '12';
        testPriceItem.cspmb__Recurring_Charge__c = 75;
        testPriceItem.cspmb__One_Off_Charge__c = 750;
        testPriceItem.Unit_Of_Measure__c='per device';
        testPriceItem.Maxim_Product_Name__c ='CurrentProductCatalog';
        testPriceItem.Product_Code__c = '1234';
        testPriceItem.Product_Family__c = 'Family';
        testPriceItem.Product_Group__c = 'Group';
        insert testPriceItem;
                     
       List<cscfga__Attribute_Definition__c> lstAttrDefs = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ATTDEF1 = ProductTestFactory.buildAttributeDefinition('OldProduct', config.cscfga__Product_Definition__c);
        ATTDEF1.cscfga__Is_Line_Item__c = true;
        lstAttrDefs.add(ATTDEF1);
        cscfga__Attribute_Definition__c ATTDEF2 = ProductTestFactory.buildAttributeDefinition('Product', config.cscfga__Product_Definition__c);
        ATTDEF2.cscfga__Is_Line_Item__c = true;
        lstAttrDefs.add(ATTDEF2);
        cscfga__Attribute_Definition__c ATTDEF3 = ProductTestFactory.buildAttributeDefinition('ProductMaximName', config.cscfga__Product_Definition__c);
        ATTDEF3.cscfga__Is_Line_Item__c = true;
        lstAttrDefs.add(ATTDEF3);
        insert lstAttrDefs;
           
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for (cscfga__Product_Configuration__c config0 : prodConfigList) {
            Blob r = Crypto.GenerateAESKey(128);
            String s = EncodingUtil.ConvertTohex(r);
            String t = s.SubString(0,8)+ '-' + s.SubString(8,12) + '-' + s.SubString(12,16) + '-' + s.SubString(16,20) + '-' + s.substring(20);
			
           cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('Product', testPriceItem.Id, config0.id);
            attr0.cscfga__Attribute_Definition__c = ATTDEF2.Id;
            attr0.Name = 'Product';
            attr0.cscfga__Display_Value__c = testPriceItem.Id;
            attr0.csexpimp1__guid__c = t;
            attr0.cscfga__Is_Line_Item__c = false;
            attr0.cscfga__Key__c = s;
            attr0.cscfga__Product_Configuration__c = config0.id;
            attr0.cscfga__Recurring__c = false;
            attr0.cscfga__Value__c = testPriceItem.Id;
            attr0.cscfga__Cascade_value__c = false;
            attList.add(attr0);
          
        }
        insert attList;
        
     }  
    
    @isTest
    static void positiveBatchTest(){
        test.StartTest();        
        cscfga__Product_Basket__c basket = [SELECT Id, cscfga__opportunity__c FROM cscfga__Product_Basket__c where Project_ID__c='prodbasket' limit 1];
        ExecuteRulesInBatch myBatchObject = new ExecuteRulesInBatch(basket.Id); 
        Id batchId = Database.executeBatch(myBatchObject,4);
        test.StopTest();
    }
       
  /*  @isTest
       static void positiveBatchTest(){
        /*ExecuteRulesInBatchTest testclass= new ExecuteRulesInBatchTest();
        testclass.setup();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
		List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        prodconfigList = [SELECT id FROM cscfga__Product_Configuration__c];
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Current Product Catalog';
        testConfig.cscfga__Product_Basket__c = prodBasket.Id;
        testConfig.csordtelcoa__Replaced_Product_Configuration__c = prodconfigList[0].Id;
        INSERT testConfig;   */      
		/*test.StartTest();
        ExecuteRulesInBatch myBatchObject = new ExecuteRulesInBatch(prodBasket.Id); 
        Id batchId = Database.executeBatch(myBatchObject,1);            
        test.StopTest();
    }*/
    /*static void negativeBatchTest(){
        test.StartTest();
        cscfga__Product_Basket__c basket = [SELECT Id, cscfga__opportunity__c FROM cscfga__Product_Basket__c LIMIT 1];
        String basketId = basket.Id;
        ExecuteRulesInBatch myBatchObject = new ExecuteRulesInBatch(basketId); 
        Id batchId = Database.executeBatch(myBatchObject,10);
        test.StopTest();
    }*/
        
}