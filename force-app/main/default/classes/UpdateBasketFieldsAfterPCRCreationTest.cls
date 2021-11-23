/*************************************************************************************************
Name : UpdateBasketFieldsAfterPCRCreationTest
Description : Test class for UpdateBasketFieldsAfterPCRCreation
Ch.No.    Developer Name          Date          Story Description
1.        Pooja/Aditya/Gnana      18/07/2020:   CS Spring'20 Upgrade
***************************************************************************************************/
@isTest
public class UpdateBasketFieldsAfterPCRCreationTest {
    
    @testSetup
    static void testData() {
        
        //Create Custom Setting for basket stages
        List<CustomConfigurationOptions__c> configOptionsList = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Submitted';
        configOptions.External_Id__c = '9ExternalIdtest';
        configOptions.Name = 'Submitted';
        configOptionsList.add(configOptions);
        
        CustomConfigurationOptions__c configOptions1 = new CustomConfigurationOptions__c();
        configOptions1.Enrichment_Basket_Stage__c = 'Cancelled';
        configOptions1.External_Id__c = '9ExternalIdtest1';
        configOptions1.Name = 'CancelBasket';
        configOptionsList.add(configOptions1);
        
        CustomConfigurationOptions__c configOptions2 = new CustomConfigurationOptions__c();
        configOptions2.Enrichment_Basket_Stage__c = 'Draft';
        configOptions2.External_Id__c = '9ExternalIdtest2';
        configOptions2.Name = 'Draft';
        configOptionsList.add(configOptions2);
        
        CustomConfigurationOptions__c configOptions3 = new CustomConfigurationOptions__c();
        configOptions3.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        configOptions3.External_Id__c = '9ExternalIdtest3';
        configOptions3.Name = 'CommercialConfiguration';
        configOptions3.Opportunity_Stage__c='Develop';
        configOptionsList.add(configOptions3);
        
        CustomConfigurationOptions__c configOptions4 = new CustomConfigurationOptions__c();
        configOptions4.Enrichment_Basket_Stage__c = 'Quote';
        configOptions4.External_Id__c = '9ExternalIdtest4';
        configOptions4.Name = 'Quote';
        configOptions4.Opportunity_Stage__c='Propose';
        configOptionsList.add(configOptions4);
        
        insert configOptionsList;
        
        
        //Create Account
        //Account acc = new Account(Name = 'Test Account');
            //Insted of creating separate test data, using existing TestUtil factory method for creating Account. 
            //Sprint 19.17 P2OB-4149
            Account acc=TestUtil.createAccount('Test Account');
        acc.cscfga__Active__c = 'Yes';
        insert acc;
        
        //Create Opportunity
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
        
        //Create Product Definition
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Current Product Catalog Test',null);
        insert pd;        
        
    }
    
    static testMethod void testSyncFlag() {
        Account acc = [Select id from Account];
        acc.cscfga__Active__c = 'Yes';
        upsert acc;
        Opportunity opp = [Select id from Opportunity];   
        opp.Product_Type__c = 'Non Modular'; //Change 18/07/2020: CS Spring'20 Upgrade
        opp.Account = acc;
        upsert opp;     
        cscfga__Product_Basket__c basket = [Select id,name,csordtelcoa__Synchronised_with_Opportunity__c,cscfga__Basket_Status__c,csbb__Synchronised_With_Opportunity__c from cscfga__Product_Basket__c where cscfga__Opportunity__c =: opp.id];
        cscfga__Product_Definition__c pd = [Select id from cscfga__Product_Definition__c Limit 1];
        cscfga__Product_Configuration__c pconfig = ProductTestFactory.buildProductConfig(pd.id);
        pconfig.cscfga__Configuration_Status__c='Valid';
        insert pconfig;
        
        Test.startTest();
        //Create ProductConfigurationRequest 
        cscfga__Product_Category__c  pc = ProductTestFactory.buildProductCategory();
        insert pc;
        csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
        pcr.csbb__Product_Category__c = pc.id;
        pcr.csbb__Product_Basket__c =basket.id;
        pcr.csbb__Product_Configuration__c = pconfig.id;
        insert pcr;
        Test.stopTest();        
        basket = [Select id,name,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c from cscfga__Product_Basket__c where cscfga__Opportunity__c =: opp.id];
        System.AssertEquals(false,basket.csbb__Synchronised_With_Opportunity__c);
        System.AssertEquals(false,basket.csordtelcoa__Synchronised_with_Opportunity__c);
        
    }
    
    static testMethod void testbasketStage() {
        Account acc = [Select id from Account];
        acc.cscfga__Active__c = 'Yes';
        upsert acc;
        Opportunity opp = [Select id from Opportunity];   
        opp.Product_Type__c = 'Non Modular'; //Change 18/07/2020: CS Spring'20 Upgrade
        opp.Account = acc;
        upsert opp; 
        cscfga__Product_Basket__c basket = [Select id,name,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_With_Opportunity__c from cscfga__Product_Basket__c where cscfga__Opportunity__c =: opp.id];
        cscfga__Product_Definition__c pd = [Select id from cscfga__Product_Definition__c Limit 1];
        cscfga__Product_Configuration__c pconfig = ProductTestFactory.buildProductConfig(pd.id);
        pconfig.cscfga__Configuration_Status__c='Valid';
        insert pconfig;
        Test.startTest();
        //Create ProductConfigurationRequest 
        cscfga__Product_Category__c  pc = ProductTestFactory.buildProductCategory();
        insert pc;
        csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
        pcr.csbb__Product_Category__c = pc.id;
        pcr.csbb__Product_Basket__c =basket.id;
        pcr.csbb__Product_Configuration__c = pconfig.id;
        insert pcr;
        Test.stopTest();  
        basket = [Select id,name,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where cscfga__Opportunity__c =: opp.id];
        System.AssertEquals('Commercial Configuration',basket.csordtelcoa__Basket_Stage__c);         
    }
}