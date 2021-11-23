/**
 * Test Class for custom button contract accepted test.
 * 
 * Sr.No.    Developer Name      Date          Story Description
	1.        Vijaylakshmi    02/06/2020      P2OB-4991  Opportunity Contact role Changes
 */
@isTest//(seeAllData=true)//Added seeAllData=true as sync api is called which needs pricebook data to be queried
public class CustomButtonContractAcceptedTest {

    /*@isTest static void performActionTest() {

        disableCSTrigger();
        //createCustomSettingValues();
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Product2 p2 = ProductTestFactory.getProduct();
        insert p2;
        
        Pricebook2 pb2 = ProductTestFactory.getPricebook();
        insert pb2;
        
        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(p2, pb2.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.StageName ='Develop';
        insert opp;
        
        OpportunityLineItem oli= ProductTestFactory.getOpportunityLineItem(opp, pbe);
        insert oli;
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.cscfga__Opportunity__c = opp.Id;
        update basket;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        
        
       // CustomButtonContractAccepted newCustContractAccepted = new CustomButtonContractAccepted();
        //newCustContractAccepted.performAction(basket.Id);
        Test.startTest();
                
        //cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
                
        Test.stopTest();
        
        System.assertEquals('Commercial Configuration', basket1.csordtelcoa__Basket_Stage__c);

    }*/
    
    @isTest static void performActionTestError() {

        //disableCSTrigger();
        createCustomSettingValues();
        Account acc = new Account(Name='Test Account', Customer_Status__c=Label.Acc_Customer_Status);
        insert acc;
		
		cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        basket.csordtelcoa__Change_Type__c = 'Change Solution';
		
		update basket;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        
        Test.startTest();
        CustomButtonContractAccepted newCustContractAccepted = new CustomButtonContractAccepted();
        String ret = newCustContractAccepted.performAction(basket.Id);
        newCustContractAccepted.validateMACDbasket(basket.Id,true); 
        
        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        Test.stopTest();
        //System.assertEquals('{"status":"error","text":"Contract Accepted Error"}', ret);
		System.assertEquals('Contract Accepted', basket1.csordtelcoa__Basket_Stage__c);
		
    }
    @isTest static void testerrormethod() {

        //disableCSTrigger();
       // createCustomSettingValues();
        Account acc = new Account(Name='Test Account', Customer_Status__c=Label.Acc_Customer_Status);
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        basket.csordtelcoa__Change_Type__c = 'Change Solution';
        update basket;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        
        Test.startTest();
        CustomButtonContractAccepted newCustContractAccepted = new CustomButtonContractAccepted();
        String ret = newCustContractAccepted.performAction(basket.Id);
        String ret1 = newCustContractAccepted.validateMACDbasket(basket.Id,true); 
        newCustContractAccepted.validateBasketStageClosedWon(basket.Id); 
                newCustContractAccepted.validateBasketStageCancelled(basket.Id); 
        system.assertEquals(null,ret1);
        
        Test.stopTest();
        }
    static void disableCSTrigger() {
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = [Select id,csordtelcoa__Disable_Triggers__c,csordtelcoa__Opportunity_Stages_creating_orders__c from csordtelcoa__Orders_Subscriptions_Options__c where SetupOwnerId =: Userinfo.getOrganizationId()];
        //subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = True ; 
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Closed Won';
        update subsSettings ; 
    }
    
    static void createCustomSettingValues() { 
             //Create Custom Setting for basket stages
             List<CustomConfigurationOptions__c> configOptionsList = new List<CustomConfigurationOptions__c>();
             CustomConfigurationOptions__c configOptions = new CustomConfigurationOptions__c();
             configOptions.Enrichment_Basket_Stage__c = 'Closed Won';
             configOptions.External_Id__c = '9ExternalIdtest';
             configOptions.Opportunity_Stage__c = 'Closed Won';
             configOptions.Name = 'ClosedWon';
             configOptionsList.add(configOptions);
             
             CustomConfigurationOptions__c configOptions1 = new CustomConfigurationOptions__c();
             configOptions1.Enrichment_Basket_Stage__c = 'Cancelled';
             configOptions1.External_Id__c = '9ExternalIdtest1';
             configOptions1.Name = 'CancelBasket';
             configOptionsList.add(configOptions1);
             
             CustomConfigurationOptions__c configOptions2 = new CustomConfigurationOptions__c();
             configOptions2.Enrichment_Basket_Stage__c = 'Contract Accepted';
             configOptions2.External_Id__c = '9ExternalIdtest2';
             configOptions2.Name = 'ContractAccepted';
             configOptionsList.add(configOptions2);
             
             CustomConfigurationOptions__c configOptions3 = new CustomConfigurationOptions__c();
             configOptions3.Enrichment_Basket_Stage__c = 'Commercial Configuration';
             configOptions3.External_Id__c = '9ExternalIdtest3';
             configOptions3.Name = 'CommercialConfiguration';
             configOptionsList.add(configOptions3);

             CustomConfigurationOptions__c configOptions4 = new CustomConfigurationOptions__c();
             configOptions4.Enrichment_Basket_Stage__c = 'Order Enrichment';
             configOptions4.External_Id__c = '9ExternalIdtest4';
             configOptions4.Name = 'ServiceDetailing';
             configOptions4.Opportunity_Stage__c = 'Committed';
             configOptionsList.add(configOptions4);
             insert configOptionsList;
    }
}