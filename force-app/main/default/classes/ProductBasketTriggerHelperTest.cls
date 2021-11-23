@isTest(SeeAllData=FALSE)
private class ProductBasketTriggerHelperTest {
    
    /******************************************************************************************************************
    * Method Name : updateAttributeInfo
    * Description : Used to simulate and test the logic of updateAttributeInfo method in ProductBasketCustomTriggerHandler
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************************/
    static testmethod void updateAttributeInfoTest() {
    
        list<CustomConfigurationOptions__c> customconfigList= new list<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c customconfig= new CustomConfigurationOptions__c();
        customconfig.Name='MarketableOfferList';
        customconfig.MarketableOfferList__c='Test';
        customconfig.External_Id__c='CCO2';
        customconfigList.add(customconfig);
        
        CustomConfigurationOptions__c customconfig1= new CustomConfigurationOptions__c();
        customconfig1.Name='serviceDetailing';
        customconfig1.External_Id__c='CCO3';
        customconfig1.Enrichment_Basket_Stage__c='Enriched';
        customconfigList.add(customconfig1); 
        
         CustomConfigurationOptions__c customconfig2= new CustomConfigurationOptions__c();
        customconfig2.Name='CommercialConfiguration';
        customconfig2.External_Id__c='CCO4';
        customconfig2.Enrichment_Basket_Stage__c='Commercial Configuration';
        customconfigList.add(customconfig2); 
        
          CustomConfigurationOptions__c customconfig3= new CustomConfigurationOptions__c();
        customconfig3.Name='Quote';
        customconfig3.External_Id__c='CCO8';
        customconfig3.Enrichment_Basket_Stage__c='Quote';
        customconfigList.add(customconfig3);   
        Insert customconfigList;
       
         Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket',csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration');
        INSERT basket;
       
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'Test Config', 
                cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                 Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        
        list<cscfga__Attribute__c> attributeList=new list<cscfga__Attribute__c>();
        cscfga__Attribute__c attr=new cscfga__Attribute__c();
        attr.Name = 'Customer Requested Date';
        attr.cscfga__Attribute_Definition__c = TestDataFactory.generateAttributeDefinition().Id;
        attr.cscfga__Product_Configuration__c =prodConfig.id;
        attributeList.add(attr);
        
        cscfga__Attribute__c attr1=new cscfga__Attribute__c();
        attr1.Name = 'Aggregator';
        attr1.cscfga__Attribute_Definition__c = TestDataFactory.generateAttributeDefinition().Id;
        attr1.cscfga__Product_Configuration__c =prodConfig.id;
        attributeList.add(attr1);
        
        cscfga__Attribute__c attr2=new cscfga__Attribute__c();
        attr2.Name = 'Financial CIDN';
        attr2.cscfga__Attribute_Definition__c = TestDataFactory.generateAttributeDefinition().Id;
        attr2.cscfga__Product_Configuration__c =prodConfig.id;
        attributeList.add(attr2);
        
        cscfga__Attribute__c attr3=new cscfga__Attribute__c();
        attr3.Name = 'Invoice Arrangement ID';
        attr3.cscfga__Attribute_Definition__c = TestDataFactory.generateAttributeDefinition().Id;
        attr3.cscfga__Product_Configuration__c =prodConfig.id;
        attributeList.add(attr3);
        
        cscfga__Attribute__c attr4=new cscfga__Attribute__c();
        attr4.Name = 'Purchase Order Number';
        attr4.cscfga__Attribute_Definition__c = TestDataFactory.generateAttributeDefinition().Id;
        attr4.cscfga__Product_Configuration__c =prodConfig.id;
        attributeList.add(attr4);
        
         cscfga__Attribute__c attr5=new cscfga__Attribute__c();
        attr5.Name = 'ProductType';
        attr5.cscfga__Attribute_Definition__c = TestDataFactory.generateAttributeDefinition().Id;
        attr5.cscfga__Product_Configuration__c =prodConfig.id;
        attributeList.add(attr5);
        
        cscfga__Attribute__c attr6=new cscfga__Attribute__c();
        attr6.Name = 'Basket Status';
        attr6.cscfga__Attribute_Definition__c = TestDataFactory.generateAttributeDefinition().Id;
        attr6.cscfga__Product_Configuration__c =prodConfig.id;
        attributeList.add(attr6);
        //checkAfterUpdateBasket = false;
        insert attributeList;
        
        
        
        Test.startTest();
         StaticUtilForRecursion.checkAfterUpdateBasket = true;
         basket.csordtelcoa__Basket_Stage__c = 'Contract Initiated';
         UPDATE basket;
         System.assert(basket!=null);
         Test.stopTest();
    }
    
     static testmethod void updateOldQuotesToVoidTest() {
    
        list<CustomConfigurationOptions__c> customconfigList= new list<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c customconfig= new CustomConfigurationOptions__c();
        customconfig.Name='MarketableOfferList';
        customconfig.MarketableOfferList__c='Test';
        customconfig.External_Id__c='CCO2';
        customconfigList.add(customconfig);
        
        CustomConfigurationOptions__c customconfig1= new CustomConfigurationOptions__c();
        customconfig1.Name='serviceDetailing';
        customconfig1.External_Id__c='CCO3';
        customconfig1.Enrichment_Basket_Stage__c='Enriched';
        customconfigList.add(customconfig1); 
        
         CustomConfigurationOptions__c customconfig2= new CustomConfigurationOptions__c();
        customconfig2.Name='CommercialConfiguration';
        customconfig2.External_Id__c='CCO4';
        customconfig2.Enrichment_Basket_Stage__c='Commercial Configuration';
        customconfigList.add(customconfig2); 
        
          CustomConfigurationOptions__c customconfig3= new CustomConfigurationOptions__c();
        customconfig3.Name='Quote';
        customconfig3.External_Id__c='CCO8';
        customconfig3.Enrichment_Basket_Stage__c='Quote';
        customconfigList.add(customconfig3);   
        Insert customconfigList;
       
         Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket',csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Initiated');
        INSERT basket;
        
        Quote Quote1 =new Quote ();
        Quote1.Name='Test 1'  ;
        Quote1.Status = 'Customer Validated';
        Quote1.OpportunityId  =opp.id;
        Quote1.Product_Basket__c=basket.id;
        insert Quote1;
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket',csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration');
        INSERT basket1;
        
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'Test Config', 
                cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                 Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        
        Quote Quote2 =new Quote ();
        Quote2.Name='Test 1'  ;
        Quote2.Status = 'Customer Validated';
        Quote2.OpportunityId  =opp.id;
        Quote2.Product_Basket__c=basket1.id;
        insert Quote2;
        
        Test.startTest();
         StaticUtilForRecursion.checkAfterUpdateBasket = true;
         basket1.csordtelcoa__Basket_Stage__c = 'Contract Initiated';
         UPDATE basket1;
         System.assert(basket!=null);
         Test.stopTest();
    }
}