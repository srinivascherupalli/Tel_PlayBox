/*************************************************************************************************
   Name : CustomButtonCreateOrderTest 
   Description : Class for custom button create order test..

Sr.No.    Developer Name      Date          Story Description

1.        Ankit Goswami     14/10/2019      Insert Opportunity
**************************************************************************************************/
@isTest
private class CustomButtonCreateOrderTest 
{
    
    /**
* Tests performAction method
*/
    @isTest static void performActionTestInProgress()
    {
        System.debug( 'Inside performActionTestInProgress');
        disableCSTrigger();
        createCustomSettingValues();
        Account acc = new Account(Name='Test Account');
       
    //Insert opportunity
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        basket.cscfga__opportunity__c=opp.id;
        update basket;
        
        Test.startTest();
        CustomButtonCreateOrder newCustOrder = new CustomButtonCreateOrder();
        newCustOrder.performAction(basket.Id);
        Test.stopTest();
        
        csord__Order__c ord = new csord__Order__c(name='test ord',csordtelcoa__Opportunity__c = opp.id, csord__Identification__c = 'test1ord');
        insert ord;
        
        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals('Submitted', basket1.csordtelcoa__Basket_Stage__c);
        
    }
    
    @isTest static void performActionTest()
    {
        System.debug( 'Inside performActionTest');
        disableCSTrigger();
        createCustomSettingValues();
        Account acc = new Account(Name='Test Account');
          //Insert opportunity
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
                basket.cscfga__opportunity__c=opp.id;

        update basket;
        
        Test.startTest();
        CustomButtonCreateOrder newCustOrder = new CustomButtonCreateOrder();
        newCustOrder.performAction(basket.Id);
        Test.stopTest();
        
        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals('Submitted', basket1.csordtelcoa__Basket_Stage__c);
        
    }
    
    /**
* Tests performAction method
*/
    @isTest static void performActionNegTest()
    {
        System.debug( 'Inside performActionNegTest');
        disableCSTrigger();
        createCustomSettingValues();
        Account acc = new Account(Name='Test Account');
          //Insert opportunity
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c='Enriched';
                basket.cscfga__opportunity__c=opp.id;

        update basket;
        String retVal;
        //Trying to create Order for existing Closed Won basket
        Test.startTest();
        CustomButtonCreateOrder newCustOrder = new CustomButtonCreateOrder();
        retVal = newCustOrder.performAction(basket.Id);
        Test.stopTest();
        System.debug('retVal' + retVal);
        
        System.assert(retVal.contains(Label.Basket_Closed_Won_Error));
        
        
    }
    
    /**
* Tests performAction method
*/
    @isTest static void performActionIncompleteTest()
    {
        System.debug( 'Inside performActionIncompleteTest');
        disableCSTrigger();
        createCustomSettingValues();
        Account acc = new Account(Name='Test Account');
          //Insert opportunity
           Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.cscfga__Basket_Status__c='Incomplete';
                basket.cscfga__opportunity__c=opp.id;

        update basket;
        String retVal;
        
        //Trying to create Order for existing Closed Won basket
        Test.startTest();
        CustomButtonCreateOrder newCustOrder = new CustomButtonCreateOrder();
        retVal = newCustOrder.performAction(basket.Id);
        Test.stopTest();
        System.debug('RetVal: ' + retVal);
        //System.assert(retVal.contains('Mandatory fields have not been completed'));
       
    }
    
    
    @isTest static void performActionTestServiceDetailing()
    {
        System.debug( 'Inside performActionTestServiceDetailing');
        disableCSTrigger();
        createCustomSettingValues();
        
        Account acc = new Account(Name='Test Account', Customer_Status__c=Label.Acc_Customer_Status);
        insert acc;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        basket.cscfga__Basket_Status__c = 'Valid';
                basket.cscfga__opportunity__c=opp.id;

        update basket;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb); 
        ProductTestService.getCompleteOrderWithSli(acc);
        
        Test.startTest();
        CustomButtonCreateOrder newCustOrder = new CustomButtonCreateOrder();
        newCustOrder.performAction(basket.Id);
        Test.stopTest();
        
        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.debug('TTTTTT-Basket after creating order=' + basket1  );
        System.assertEquals(basket1.csordtelcoa__Basket_Stage__c , 'Submitted');
    }
    static void disableCSTrigger()
    {
        
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c() ; 
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = true; 
        //subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Closed Won';
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Enriched';
        insert subsSettings ; 
        
        
    }
    static void createCustomSettingValues() 
    {
               
        list<CustomConfigurationOptions__c> lstCustomConfigs = new list<CustomConfigurationOptions__c>();
        
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Order Enrichment'); 
        customSetting.Name = 'ServiceDetailing';
        customSetting.Opportunity_Stage__c = 'Committed'; 
        customSetting.External_Id__c = 'CCO_T_1';
        lstCustomConfigs.add(customSetting);
        
        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Enriched',Opportunity_Stage__c = 'Closed Won'); 
        customSetting1.Name = 'ClosedWon';
        customSetting1.External_Id__c = 'CCO_T_2';
        lstCustomConfigs.add(customSetting1);
        
        CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Cancelled');
        customSetting2.Name = 'CancelBasket';
        customSetting2.External_Id__c = 'CCO_T_3';
        lstCustomConfigs.add(customSetting2);
        
        CustomConfigurationOptions__c objCustomConfig1 = new CustomConfigurationOptions__c();
        objCustomConfig1.Name='Submitted';
        objCustomConfig1.Enrichment_Basket_Stage__c ='Submitted';
        objCustomConfig1.External_Id__c = 'CCO_T_4';
        lstCustomConfigs.add(objCustomConfig1);  
        
        CustomConfigurationOptions__c objCustomConfig5 = new CustomConfigurationOptions__c();
        objCustomConfig5.Name='CommercialConfiguration';
        objCustomConfig5.Enrichment_Basket_Stage__c ='Commercial Configuration';
        objCustomConfig5.External_Id__c = 'CCO_T_5';
        objCustomConfig5.Opportunity_Stage__c = 'Define'; 
        lstCustomConfigs.add(objCustomConfig5);
        
        CustomConfigurationOptions__c objCustomConfig6 = new CustomConfigurationOptions__c();
        objCustomConfig6.Name='Quote';
        objCustomConfig6.Enrichment_Basket_Stage__c ='Commercial Configuration';
        objCustomConfig6.External_Id__c = 'CCO_T_6';
        objCustomConfig6.Opportunity_Stage__c = 'Define'; 
        lstCustomConfigs.add(objCustomConfig6);
        
        CustomConfigurationOptions__c objCustomConfig7 = new CustomConfigurationOptions__c();
        objCustomConfig7.Name='ContractAccepted';
        objCustomConfig7.Enrichment_Basket_Stage__c ='Commercial Configuration';
        objCustomConfig7.External_Id__c = 'CCO_T_7';
        objCustomConfig7.Opportunity_Stage__c = 'Define'; 
        lstCustomConfigs.add(objCustomConfig7);
              
        if( !lstCustomConfigs.IsEmpty())
        {
            insert lstCustomConfigs;
        }
    } 
    @isTest static void primaryAndTechnicalContactTest()
    {
        System.debug( 'Inside primaryAndTechnicalContactTest');
        disableCSTrigger();
        createCustomSettingValues();
        Account acc = new Account(Name='Test Account');
          //Insert opportunity
           Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
                basket.cscfga__opportunity__c=opp.id;

        update basket;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product','Test Product');
        insert prodDef;
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.cscfga__Product_Basket__c = basket.Id;
        prodConfig.Name = 'IP Site';
        insert prodConfig;
        
        List<cscfga__Attribute__c> lstAtt = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att = ProductTestFactory.buildAttribute('Primarycontactid', '', prodConfig.Id);
        lstAtt.add(att);
        att = ProductTestFactory.buildAttribute('Technicalcontactid', '', prodConfig.Id);
        lstAtt.add(att);
        insert lstAtt;
        
        Test.startTest();
        CustomButtonCreateOrder newCustOrder = new CustomButtonCreateOrder();
        String sErrorMsg = newCustOrder.performAction(basket.Id);
        Test.stopTest();
        
        System.assert(sErrorMsg.contains(Label.Create_Order_PrimaryAndTechnical_Contact_Error));
        
        
    }
    
   }