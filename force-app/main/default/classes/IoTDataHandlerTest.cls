/*
* @Author : Vitap/Aruna 
* @Date : 18th Oct 2020
* @Desc : Handler class for ProductBasketDataSourceConnection
*/
/****History of Updates 
1. Aruna Aware DPG-2421 - IOT Shared Plan || Recurring charge incorrect in Quote(Coming as 1.64$)
2. Jayesh DPG-1311 - Logic to retrieve Recurring charges for IOT Services
3. Jayesh/Aruna DPG-1481 - Method to fetch IoT Shared Data Plan Rate Matrix details
4. Jayesh - DPG-1454 & DPG-1033 - Method to fetch IoT Cancellation details
5. Jayesh - DPG-1690 - removing try as per Governance review comments
6.Aruna Aware 11/02/2020 - DPG-2673 - Generate order form for the IoT Digital water metering solution
****/

@isTest
public class IoTDataHandlerTest {
    @Testsetup
    static void dataSetup() {
        Environment_Configurations__c settings=new Environment_Configurations__c();
        settings.No_Triggers__c=true;
        insert settings; 
        EnvironmentVariable__c transitionClone =  new EnvironmentVariable__c();
        transitionClone .name='TransitionClone';
        transitionClone .value__c='3';
        insert transitionClone ;
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        //EDGE-127817 Start
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
        //billAcc.name = 'BA-0004772';
        billAcc.Account__c = acc.id;
        insert billAcc;
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Committed_Data';
        ev.value__c='True';
        insert ev;
        //EDGE-165488 Start | TestClass Fix
        List<CustomConfigurationOptions__c> customConfigList = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c customConfig00 = new CustomConfigurationOptions__c();
        customConfig00.name = 'CommercialConfiguration';
        customConfig00.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        customConfig00.External_Id__c = 'CCO4';
        customConfigList.add(customConfig00);
        CustomConfigurationOptions__c customConfig01 = new CustomConfigurationOptions__c();
        customConfig01.name = 'Quote';
        customConfig01.Enrichment_Basket_Stage__c = 'Quote';
        customConfig01.External_Id__c = 'CCO8';
        customConfigList.add(customConfig01);
        CustomConfigurationOptions__c customConfig02 = new CustomConfigurationOptions__c();
        customConfig02.name = 'ContractAccepted';
        customConfig02.Enrichment_Basket_Stage__c = 'Contract Accepted';
        customConfig02.External_Id__c = 'CCO5';
        customConfigList.add(customConfig02);
        insert customConfigList;
        //EDGE-165488 End
        system.debug('billAcc@@::' + billAcc);
        //EDGE-127817 End
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Name = 'Test Cancel';
        opp.Product_Type__c ='Modular';
        lstOpportunity.add(opp);
        //insert opp;
        Opportunity opp1  = ProductTestFactory.getOpportunityBasic(acc);
        opp1.Product_Type__c ='Modular';
        opp1.Name = 'Test Order Form YVW opty';
        lstOpportunity.add(opp1);
        //insert opp1;
        Opportunity oppRightPlan  = ProductTestFactory.getOpportunityBasic(acc);
        oppRightPlan.Product_Type__c ='Modular';
        oppRightPlan.Name = 'Test Order Form Right Plan opty';
        lstOpportunity.add(oppRightPlan);
        
        Opportunity oppSD  = ProductTestFactory.getOpportunityBasic(acc);
        oppSD.Product_Type__c ='Modular';
        oppSD.Name = 'Test Order Shared Data Plan';
        lstOpportunity.add(oppSD);
        
        Opportunity oppMSIO  = ProductTestFactory.getOpportunityBasic(acc);
        oppMSIO.Product_Type__c ='Modular';
        oppMSIO.Name = 'Test Order Form MSIO';
        lstOpportunity.add(oppMSIO);
        
        insert lstOpportunity; 
        
        List<cscfga__Product_Basket__c> pbList = new List<cscfga__Product_Basket__c>();
        // DPG-2673 - Generate order form for the IoT Digital water metering solution.
        cscfga__Product_Basket__c boltOnBasket1 = ProductTestFactory.buildEmptyBasket();
        boltOnBasket1.cscfga__Opportunity__c = opp1.id;
        boltOnBasket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket1.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket1.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket1.cscfga__total_contract_value__c = 11111;
        pbList.add(boltOnBasket1);
        
        cscfga__Product_Basket__c boltOnBasket2 = ProductTestFactory.buildEmptyBasket();
        boltOnBasket2.cscfga__Opportunity__c = oppRightPlan.id;
        boltOnBasket2.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket2.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket2.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket2.cscfga__total_contract_value__c = 11111;
        pbList.add(boltOnBasket2);
        
         cscfga__Product_Basket__c boltOnBasket3 = ProductTestFactory.buildEmptyBasket();
        boltOnBasket3.cscfga__Opportunity__c = opp.id;
        boltOnBasket3.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket3.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket3.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket3.cscfga__total_contract_value__c = 11111;
        pbList.add(boltOnBasket3);
        
        cscfga__Product_Basket__c boltOnBasket4 = ProductTestFactory.buildEmptyBasket();
        boltOnBasket4.cscfga__Opportunity__c = oppSD.id;
        boltOnBasket4.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket4.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket4.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket4.cscfga__total_contract_value__c = 11111;
        pbList.add(boltOnBasket4);
        
        cscfga__Product_Basket__c boltOnBasket5 = ProductTestFactory.buildEmptyBasket();
        boltOnBasket5.cscfga__Opportunity__c = oppMSIO.id;
        boltOnBasket5.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket5.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket5.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket5.cscfga__total_contract_value__c = 3.18;
        pbList.add(boltOnBasket5);
        insert pbList;
        
        List<cscfga__Product_Definition__c> lstPDn = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c='DMCAT_ProductSpecification_000965';
        lstPDn.add(pd);
        insert lstPDn;
        
        cscfga__Configuration_Offer__c offernameIOT= new cscfga__Configuration_Offer__c();
        offernameIOT.Offer_Spec_Id__c='DMCAT_Offer_000964';
        offernameIOT.name='IOT Offer';//EDGE-162365 Defect Fix
        offernameIOT.cscfga__Active__c=true;
        offernameIOT.cscfga__Description__c='';
        insert offernameIOT;
        
        // DPG 598  
        Marketable_Offer__c ioTMob = new Marketable_Offer__c();
        ioTMob.OfferDefinationName__c ='IoT solutions' ;
        ioTMob.Name = 'IoT Connectivity';
        ioTMob.Offer_ID__c = 'DMCAT_Offer_000964';
        insert ioTMob;
        
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config0 = ProductTestFactory.buildProductConfig(pd.id);
        config0.name= 'IoT Right Plan';
        config0.Type__c = 'New';
        config0.Marketable_Offer__c = ioTMob.id;
        config0.Offer_Reference__c =offernameIOT.id;
        config0.cscfga__Product_Family__c='IOT Subscription';
        config0.cscfga__Product_Definition__c =pd.Id;
        config0.cscfga__unit_recurring_charge__c = 2.53;
        config0.cscfga__Product_Basket__c = boltOnBasket2.id;
        config0.cscfga__total_one_off_charge__c=00.00;
        prodConfigList.add(config0);
        
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.id);
        config.name= 'IoT Right Plan';
        config.Type__c = 'New';
        config.Marketable_Offer__c = ioTMob.id;
        config.Offer_Reference__c =offernameIOT.id;
        //config.cscfga__Product_Family__c='IOT Subscription';
    config.cscfga__Product_Family__c='IOT Plans';
        config.cscfga__Product_Definition__c =pd.Id;
        config.cscfga__unit_recurring_charge__c = 2.53;
        config.cscfga__Product_Basket__c = boltOnBasket2.id;
        config.cscfga__total_one_off_charge__c=10.00;
        config.Quantity_Product_Configuration__c=3;
        prodConfigList.add(config);
        
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(pd.id);
        config2.name= 'IoT Right Plan';
        config2.Type__c = 'New';
        config2.Marketable_Offer__c = ioTMob.id;
        config2.Offer_Reference__c =offernameIOT.id;
        config2.cscfga__Product_Family__c='IoT solutions';
        config2.cscfga__unit_recurring_charge__c = 2.53;
        config2.cscfga__Product_Basket__c = boltOnBasket2.id;
        config2.cscfga__total_one_off_charge__c=5.00;
        config2.Quantity_Product_Configuration__c=3;
        prodConfigList.add(config2);
        
        cscfga__Product_Configuration__c config3 = ProductTestFactory.buildProductConfig(pd.id);
        config3.name= 'IoT Shared Data';
        config3.Type__c = 'New';
        config3.Marketable_Offer__c = ioTMob.id;
        config3.Offer_Reference__c =offernameIOT.id;
        //config3.cscfga__Product_Family__c='IoT solutions';
    config3.cscfga__Product_Family__c='IOT Plans';
        config3.cscfga__unit_recurring_charge__c = 2.53;
        config3.cscfga__total_one_off_charge__c=00.00;
        config3.Quantity_Product_Configuration__c=3;
        prodConfigList.add(config3);
        
        // DPG-2673 - Generate order form for the IoT Digital water metering solution.
        cscfga__Product_Configuration__c config4 = ProductTestFactory.buildProductConfig(pd.id);
        config4.name= 'IoT Annual Data Plan';
        config4.Type__c = 'New';
        config4.Marketable_Offer__c = ioTMob.id;
        config4.Offer_Reference__c =offernameIOT.id;
        //config4.cscfga__Product_Family__c='IOT Subscription';
    config4.cscfga__Product_Family__c='IOT Plans';
        config4.cscfga__Product_Definition__c =pd.Id;
        config4.cscfga__unit_recurring_charge__c = 2.53;
        config4.cscfga__total_one_off_charge__c=00.00;
        config4.Quantity_Product_Configuration__c=3;
        config4.cscfga__Product_Basket__c = boltOnBasket1.id;
        prodConfigList.add(config4);
        // DPG-2673 - Generate order form for the IoT Digital water metering solution.
        cscfga__Product_Configuration__c config5 = ProductTestFactory.buildProductConfig(pd.id);
        config5.name= 'IoT Annual Data Plan';
        config5.Type__c = 'New';
        config5.cscfga__Product_Basket__c = boltOnBasket1.id;
        config5.Marketable_Offer__c = ioTMob.id;
        config5.Offer_Reference__c =offernameIOT.id;
        config5.cscfga__Product_Family__c='IoT solutions';
        config5.cscfga__unit_recurring_charge__c = 2.53;
        config5.cscfga__total_one_off_charge__c=00.00;
        config5.Quantity_Product_Configuration__c=3;
        prodConfigList.add(config5);
        
        
        cscfga__Product_Configuration__c config7 = ProductTestFactory.buildProductConfig(pd.id);
        config7.name= 'IoT Shared Data Plan';
        config7.Type__c = 'New';
        config7.Marketable_Offer__c = ioTMob.id;
        config7.Offer_Reference__c =offernameIOT.id;
        config7.cscfga__Product_Family__c='IOT Subscription';
    config7.cscfga__Product_Definition__c =pd.Id;
        config7.cscfga__unit_recurring_charge__c = 2.53;
        config7.cscfga__Product_Basket__c = boltOnBasket4.id;
        config7.cscfga__total_one_off_charge__c=00.00;
        config7.Quantity_Product_Configuration__c=3;
        prodConfigList.add(config7);
    
    cscfga__Product_Configuration__c config7a = ProductTestFactory.buildProductConfig(pd.id);
        config7a.name= 'IoT Shared Data Plan';
        config7a.Type__c = 'New';
        config7a.Marketable_Offer__c = ioTMob.id;
        config7a.Offer_Reference__c =offernameIOT.id;
        //config7a.cscfga__Product_Family__c='IOT Subscription';
    config7a.cscfga__Product_Family__c='IOT Plans';
        config7a.cscfga__Product_Definition__c =pd.Id;
        config7a.cscfga__unit_recurring_charge__c = 2.53;
        config7a.cscfga__Product_Basket__c = boltOnBasket4.id;
        config7a.cscfga__total_one_off_charge__c=00.00;
        config7a.Quantity_Product_Configuration__c=3;
        prodConfigList.add(config7a);
        
        cscfga__Product_Configuration__c config8 = ProductTestFactory.buildProductConfig(pd.id);
        config8.name= 'IoT Shared Data Plan';
        config8.Type__c = 'New';
        config8.Marketable_Offer__c = ioTMob.id;
        config8.Offer_Reference__c =offernameIOT.id;
        config8.cscfga__Product_Family__c='IoT solutions';
        config8.cscfga__unit_recurring_charge__c = 2.53;
        config8.cscfga__Product_Basket__c = boltOnBasket4.id;
        config8.cscfga__total_one_off_charge__c=00.00;
        prodConfigList.add(config8);
        
        cscfga__Product_Configuration__c config9 = ProductTestFactory.buildProductConfig(pd.id);
        config9.name= 'IoT Utilities Data Plan';
        config9.Type__c = 'New';
        config9.Marketable_Offer__c = ioTMob.id;
        config9.Offer_Reference__c =offernameIOT.id;
        config9.cscfga__Product_Family__c='IoT solutions';
        config9.cscfga__unit_recurring_charge__c = 0.36;
        config8.cscfga__Product_Basket__c = boltOnBasket5.id;
        config9.cscfga__total_one_off_charge__c=3.18;
        prodConfigList.add(config9);
        
        insert prodConfigList;
        
        cscfga__Product_Configuration__c config6 = ProductTestFactory.buildProductConfig(pd.id);
        config6.name='IoT';
        config6.cscfga__Product_Basket__c = boltOnBasket3.id;
        config6.Type__c = 'Cancel';
        config6.Marketable_Offer__c = ioTMob.id;
        config6.cscfga__Product_Family__c='IOT Subscription';
        config6.cscfga__Product_Definition__c =pd.Id;
        config6.cscfga__total_recurring_charge__c = 2.82;
        config6.csordtelcoa__Replaced_Product_Configuration__c = config0.id;
        insert config6;
        prodConfigList[5].cscfga__Parent_Configuration__c = prodConfigList[4].id;
        List<cscfga__Product_Configuration__c> pcUpsertlist= new List<cscfga__Product_Configuration__c>();
        pcUpsertlist.add(prodConfigList[5]);
        upsert pcUpsertlist;
        
        //DPG -598
        List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'OneOffCharge',
            Snapshot_Attribute_Value_Field__c = 'Once_Off__c',
            Snapshot_Attribute_Fields__c = 'cspmb__One_Off_Charge__c'
        ); 
        attDefList.add(ad1);
        
       /* cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'RecurringCharges',
            Snapshot_Attribute_Value_Field__c = 'Recurring_Charges__c',
            Snapshot_Attribute_Fields__c = 'Recurring_Charges__c'
        );
        attDefList.add(ad2);
        cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'AnnualSupportMaintenance',
            Snapshot_Attribute_Value_Field__c = 'Annual_support_and_maintenance__c',
            Snapshot_Attribute_Fields__c = 'Annual_support_and_maintenance__c'
        );
        attDefList.add(ad3);*/
        insert attDefList;
        
      /*  List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = prodConfigList[4].Id,
                Name = 'TotalRecurringPrice',
                cscfga__Value__c = '100',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = attDefList[2].Id
            );
        attList.add(att1); 
        insert attList;*/
        
        // DPG-598        
      /*  cspmb__Price_Item__c testPriceItemIOT = new cspmb__Price_Item__c();
        testPriceItemIOT.Name = 'Telstra IOT Data Plan 100KB';
        testPriceItemIOT.cspmb__Contract_Term__c = '1';
        testPriceItemIOT.Unit_Of_Measure__c='';
        testPriceItemIOT.Billing_Description__c = 'Telstra IOT Data Plan 100KB Charge';
    insert testPriceItemIOT;*/
        
        /* DPG-1481 START******************************************************************************************************************* */
       /* cspmb__Price_Item__c price_item_shared_data = new cspmb__Price_Item__c(
            Name = 'IoT Shared Data 50KB',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            // cspmb__Price_Item_Code__c = 'IoT Shared Data',//EDGE-169456
            Commercial_Product_Code__c = 'IoT Shared Data', //EDGE-169456
            cspmb__Product_Definition_Name__c = 'IoT Solutions',
            External_Id__c = 'dmcat_112',
            Charge_Id__c='DMCAT_RecurringCharge_000814',
            Package_Name__c = 'IoT Solution',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Plan',
            Offer_Id__c = 'DMCAT_Offer_000964',
            Plan__c = '50 KB'
        );
        insert price_item_shared_data;
        
        cspmb__Rate_Card__c rateCard_shared_data = new cspmb__Rate_Card__c();
        rateCard_shared_data.Name = 'IoT Shared Data 50KB';
        rateCard_shared_data.Offer_Id__c ='DMCAT_Offer_000964';
        rateCard_shared_data.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000814';  
        rateCard_shared_data.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data.cspmb__Is_Active__c = true;
        insert  rateCard_shared_data;
        
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        cspmb__Rate_Card_Line__c rcl1 = new cspmb__Rate_Card_Line__c();
        rcl1.toUnit__c = 499;
        rcl1.fromUnit__c = 1;  
        rcl1.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl1.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl1.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl1.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl1);
        cspmb__Rate_Card_Line__c rcl2 = new cspmb__Rate_Card_Line__c();
        rcl2.toUnit__c = 999;
        rcl2.fromUnit__c = 500;  
        rcl2.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl2.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl2.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl2.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl2);
        cspmb__Rate_Card_Line__c rcl3 = new cspmb__Rate_Card_Line__c();
        rcl3.toUnit__c = 2499;
        rcl3.fromUnit__c = 1000;  
        rcl3.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl3.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl3.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl3.cspmb__rate_value__c = 3.5;
        rateCardLineList.add(rcl3);
        cspmb__Rate_Card_Line__c rcl4 = new cspmb__Rate_Card_Line__c();
        rcl4.toUnit__c = 9999;
        rcl4.fromUnit__c = 2500;  
        rcl4.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl4.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl4.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl4.cspmb__rate_value__c = 4.5;
        rateCardLineList.add(rcl4);
        cspmb__Rate_Card_Line__c rcl5 = new cspmb__Rate_Card_Line__c();
        rcl5.toUnit__c = 99999;
        rcl5.fromUnit__c = 10000;  
        rcl5.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl5.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl5.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl5.cspmb__rate_value__c = 5.5;
        rateCardLineList.add(rcl5);
        cspmb__Rate_Card_Line__c rcl6 = new cspmb__Rate_Card_Line__c();
        rcl6.toUnit__c = NULL;
        rcl6.fromUnit__c = NULL;  
        rcl6.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl6.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl6.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl6.cspmb__rate_value__c = 6.5;
        rateCardLineList.add(rcl6);
        insert rateCardLineList;
        
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation.cspmb__Price_Item__c = price_item_shared_data.id;
        sharedDataassociation.cspmb__Rate_Card__c = rateCard_shared_data.id;
        insert sharedDataassociation;*/
        /* DPG-1481 END******************************************************************************************************************* */
    }
    // DPG-598 and DPG-1311 code coverage 
    @isTest static void getIOTServicesOCSuccess(){
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'Test Order Form Right Plan opty' limit 1];
        
        Test.startTest();
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        IoTDataHandler handler = new IoTDataHandler();
        System.debug('basketId'+basketId);
        List<Map<String,Object>> rows = handler.getIOTServicesOC(basketId,new Map<String,String>{'Query_Type'=>'IOTServicesOC','Type'=>'New'});
        system.debug('rows :: ' + rows);
        Test.stopTest();
        // EDGE-165831 - existing Assert to check method output.
        System.assert(rows.isEmpty() == false);
        System.assertNotEquals('Connected Workplace',rows[0].get('Product_Module_Name'));
        System.assertEquals('IoT Right Plan',rows[0].get('Product_Module_Name'));
    }
    // DPG-1481 code coverage  
   /* @isTest static void getIoTSharedDataPlanSuccess(){
        
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        IoTDataHandler handler = new IoTDataHandler();
        List<Map<String,Object>> rows = handler.getIoTSharedDataPlan(basketId,new Map<String,String>{'Query_Type'=>'IoTSharedDataPlan','Type'=>'New'});
        system.debug('rows :: ' + rows);
        Test.stopTest();
        // EDGE-165831 - existing Assert to check method output.
        System.assert(rows.isEmpty() == false);
        System.assertNotEquals('30 KB',rows[0].get('Plan_Data'));
        System.assertEquals('50KB',rows[0].get('Plan_Data'));
    }*/
    @isTest static void getIoTServiceOCSharedPlan(){
        
        Test.startTest();
        
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c  WHERE cscfga__Opportunity__r.Name = 'Test Order Shared Data Plan' limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        IoTDataHandler handler = new IoTDataHandler();
        List<Map<String,Object>> rows = handler.getIOTServicesOC(basketId,new Map<String,String>{'Query_Type'=>'IOTServicesOC','Type'=>'New'});
        system.debug('rows :: ' + rows);
        Test.stopTest();
        // EDGE-165831 - existing Assert to check method output.
        System.assert(rows.isEmpty() == false);
        System.assertNotEquals('Connected Workplace',rows[0].get('Product_Module_Name'));
        System.assertEquals('IoT Shared Data Plan',rows[0].get('Product_Module_Name'));
    }
    // DPG-2673 - Generate order form for the IoT Digital water metering solution.
    @isTest static void getIoTAnnualDataPlanSuccess(){
        
        Test.startTest();
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'Test Order Form YVW opty' limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        IoTDataHandler handler = new IoTDataHandler();
        List<Map<String,Object>> rows = handler.getIOTServicesOC(basketId,new Map<String,String>{'Query_Type'=>'IOTServicesOC','Type'=>'New'});
        system.debug('rows :: ' + rows);
        Test.stopTest();
        // EDGE-165831 - existing Assert to check method output.
        System.assert(rows.isEmpty() == false);
        System.assertNotEquals('Connected Workplace',rows[0].get('Product_Module_Name'));
        System.assertEquals('IoT Annual Data Plan',rows[0].get('Product_Module_Name'));
    }
    // DPG-1454 and DPG-1033 code coverage 
    @isTest static void getIOTCancelServicesSuccess()
    {
        
        Test.startTest();
        
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where  cscfga__Opportunity__r.Name = 'Test Cancel' limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        System.debug('Product Basket --> '+prodBasket);
        IoTDataHandler handler = new IoTDataHandler();
        List<Map<String,Object>> rows = handler.getIoTCancelServices(basketId,new Map<String,String>{'Query_Type'=>'IoTCancelServices','Type'=>'Cancel'});
        System.debug('------ ROWS --> ' + rows);
        System.debug('------ ROWS[0] --> ' + rows[0].get('Type'));
        Test.stopTest();
        // EDGE-165831 - Assert to check method output.
        System.assert(rows.isEmpty() == false);
        System.assertNotEquals('New',rows[0].get('Type'));
        System.assertEquals('Cancel',rows[0].get('Type'));
    }
  // getM2MServicesOC code coverage 
    @isTest static void getM2MServicesOCTest()
    {
        
        Test.startTest();
        
        cscfga__Product_Basket__c prodBasket = [select id from cscfga__Product_Basket__c where  cscfga__Opportunity__r.Name = 'Test Order Shared Data Plan' limit 1];
        String basketId = '';
        if(prodBasket !=null)
            basketId = prodBasket.id;
        System.debug('Product Basket --> '+prodBasket);
        IoTDataHandler handler = new IoTDataHandler();
        List<Map<String,Object>> rows = handler.getM2MServicesOC(basketId,new Map<String,String>{'Query_Type'=>'M2MServicesOC','Type'=>'New'});
        System.debug('------ ROWS --> ' + rows);
        System.debug('------ ROWS[0] --> ' + rows[0].get('Type'));
        Test.stopTest();
        // EDGE-165831 - Assert to check method output.
        System.assert(rows.isEmpty() == false);
        //System.assertEquals('New',rows[0].get('Type'));
        //System.assertEquals('Cancel',rows[0].get('Type'));
    }   
}