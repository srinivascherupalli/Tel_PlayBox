/******************************************************************************************************************************
* @Desc         : Test class for SDWANDataHandler
* @Created Date : 15th Mar 2021
* @Author       : Lalit Motiray/Payel Ganguly 
 *@JIRA  : DPG-4421

 /***History of Updates
  *Sharmila/Payel: Added changes for DIGI-929 and DIGI-930
  *Payel: Added changes for DIGI-13857 and DIGI-13858
*******************************************************************************************************************************/
@isTest
private class SDWANDataHandlerTest { 
    
    @testSetup
    static void createTestData() {
        
        Environment_Configurations__c settings=new Environment_Configurations__c();
        settings.No_Triggers__c=true;
        INSERT settings; 
        
        EnvironmentVariable__c transitionClone =  new EnvironmentVariable__c();
        transitionClone.name='TransitionClone';
        transitionClone.value__c='3';
        INSERT transitionClone ;
        
        //Account creation  
        Account testAccount = AccountTestFactory.buildAccount('TestAccSDWAN');
        testAccount.CIDN__c = '1234567890';
        testAccount.Customer_Status__c='Active';
        insert testAccount;
        
        // Billing Account
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
        billAcc.Account__c = testAccount.id;
        insert billAcc;
        
        EnvironmentVariable__c enviromentVar = new EnvironmentVariable__c();
        enviromentVar.name='Committed_Data';
        enviromentVar.value__c='True';
        insert enviromentVar;
        
        //Custom configuration custom settings
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
        
        INSERT customConfigList;
        
        //Opportunity Creation
        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity opp1  = ProductTestFactory.getOpportunityBasic(testAccount);
        opp1.Name = 'SDWAN Opportunity';
        //opp1.Type = 'New To Market';
        opp1.Product_Type__c ='Modular';
        opportunities.add(opp1);
        
        Opportunity opp2  = ProductTestFactory.getOpportunityBasic(testAccount);
        opp2.Name = 'SDWAN Opportunity_MAC';
        //opp2.Type = 'MACs (Moves, Adds & Change)';
        opp2.Product_Type__c ='Modular';
        opportunities.add(opp2);
   
        INSERT opportunities;
        
        //Product Basket Creation
        List<cscfga__Product_Basket__c> prodBasketList = new List<cscfga__Product_Basket__c>();
        
        cscfga__Product_Basket__c boltOnBasket1 = ProductTestFactory.buildEmptyBasket();
        boltOnBasket1.cscfga__Opportunity__c = opp1.id;
        boltOnBasket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket1.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket1.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket1.cscfga__total_contract_value__c = 11111;
		boltOnBasket1.csordtelcoa__Change_Type__c = '';
        
        prodBasketList.add(boltOnBasket1);
        
        cscfga__Product_Basket__c boltOnBasket2 = ProductTestFactory.buildEmptyBasket();
        boltOnBasket2.cscfga__Opportunity__c = opp2.id;
        boltOnBasket2.csordtelcoa__Synchronised_with_Opportunity__c =true;
        boltOnBasket2.csbb__Synchronised_With_Opportunity__c =true;
        boltOnBasket2.cscfga__Basket_Status__c = 'Valid';
        boltOnBasket2.cscfga__total_contract_value__c = 11111;
        boltOnBasket2.csordtelcoa__Change_Type__c ='Change Solution';
        
        prodBasketList.add(boltOnBasket2);
        
        INSERT prodBasketList;
        
        //Product Defination creation
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>();
        
        cscfga__Product_Definition__c sdwan_pd = ProductTestFactory.buildProductDefinition('SDWAN ADAPT S1', 'Test Plan');
        sdwan_pd.product_Specification__c = 'DMCAT_Offer_001343';
        sdwan_pd.csordtelcoa__Product_Type__c = 'Subscription';
        sdwan_pd.cscfga__Label__c = 'SDWAN ADAPT S1';
        sdwan_pd.cscfga__Active__c = true;
        sdwan_pd.cscfga__Allow_progress_from_incomplete_screens__c = true;
        prodDefList.add(sdwan_pd);
        
        cscfga__Product_Definition__c sd_wan_pd = ProductTestFactory.buildProductDefinition('SD-WAN ADAPT S1', 'Test Plan');
        sd_wan_pd.product_Specification__c = System.Label.SDWAN_ADAPT_OFFER;
        sd_wan_pd.csordtelcoa__Product_Type__c = 'Subscription';
        sd_wan_pd.cscfga__Label__c = 'SD-WAN ADAPT S1';
        sd_wan_pd.cscfga__Active__c = true;
        sd_wan_pd.cscfga__Allow_progress_from_incomplete_screens__c = true;
        prodDefList.add(sd_wan_pd);
        
        cscfga__Product_Definition__c secE_pd1 = ProductTestFactory.buildProductDefinition('SecureEdge Cloud', 'Test Plan');
        secE_pd1.product_Specification__c = 'DMCAT_ProductSpecification_001368';
        secE_pd1.csordtelcoa__Product_Type__c = 'Subscription';
        secE_pd1.cscfga__Label__c = 'SecureEdge Cloud';
        secE_pd1.cscfga__Active__c = true;
        secE_pd1.cscfga__Allow_progress_from_incomplete_screens__c = true;
        prodDefList.add(secE_pd1);
        
        cscfga__Product_Definition__c secE_pd2 = ProductTestFactory.buildProductDefinition('External IP Address', 'Test Plan');
        secE_pd2.product_Specification__c = 'DMCAT_ProductSpecification_001461';
        secE_pd2.csordtelcoa__Product_Type__c = 'Subscription';
        secE_pd2.cscfga__Label__c = 'External IP Address';
        secE_pd2.cscfga__Active__c = true;
        secE_pd2.cscfga__Allow_progress_from_incomplete_screens__c = true;
        prodDefList.add(secE_pd2);
        
        cscfga__Product_Definition__c secE_pd3 = ProductTestFactory.buildProductDefinition('SecureEdge Cloud Remote', 'Test Plan');
        secE_pd3.product_Specification__c = 'DMCAT_ProductSpecification_001459';
        secE_pd3.csordtelcoa__Product_Type__c = 'Subscription';
        secE_pd3.cscfga__Label__c = 'SecureEdge Cloud Remote';
        secE_pd3.cscfga__Active__c = true;
        secE_pd3.cscfga__Allow_progress_from_incomplete_screens__c = true;
        prodDefList.add(secE_pd3);
        
        cscfga__Product_Definition__c secE_pd4 = ProductTestFactory.buildProductDefinition('Enterprise Wireless', 'Test Plan');
        secE_pd4.product_Specification__c = 'DMCAT_ProductSpecification_001447';
        secE_pd4.csordtelcoa__Product_Type__c = 'Subscription';
        secE_pd4.cscfga__Label__c = 'Enterprise Wireless';
        secE_pd4.cscfga__Active__c = true;
        secE_pd4.cscfga__Allow_progress_from_incomplete_screens__c = true;
        prodDefList.add(secE_pd4);
        
        INSERT prodDefList;
        
        //SDWAN Marketable Offer
        Marketable_Offer__c sdwan_MO = new Marketable_Offer__c();
        
        sdwan_MO.OfferDefinationName__c ='SD-WAN Adapt S1';
        
        sdwan_MO.Name = 'SD-WAN Adapt S1';
        sdwan_MO.Offer_ID__c = 'DMCAT_Offer_001343';
        sdwan_MO.Solution_Template__c = 'SD-WAN Adapt S1 Solution';
        sdwan_MO.Invoice_Definition__c = 'Invoice_Def_1';
        sdwan_MO.Configurations__c = '{"skipBasketSyncValidations":false}';
        sdwan_MO.Config__c = '{"skipBasketSyncValidations":false}';
        sdwan_MO.Product_Family__c = 'SD-WAN';
        sdwan_MO.Contract_Type__c = 'DSA';
        
        INSERT sdwan_MO; 
        
       
        //Installable address for Site
        cscrm__Address__c address = new cscrm__Address__c();
        address.Name = '21 CRESTING AVE, Melbourne Aussie PROSPECT TAS 7250';
        address.Address_Type__c = 'Property With Number';
        address.streetType__c = 'DRIVE';
        address.cscrm__Street_Name__c = 'Property With Number';
        address.cscrm__Street__c = 'LILA DRIVE';
        address.Locality__c = 'PROSPECT';
        address.cscrm__State_Province__c = 'TAS';
        address.cscrm__Zip_Postal_Code__c = '7250';
        address.cscrm__Country__c = 'AUSTRALIA';
        address.Address_Line_1__c = '21 CRESTING AVE,';
        address.Address_Line_2__c = 'Melbourne';
        address.Address_Line_2__c = 'Aussie';
        address.Address_ID__c = '50844332';

        INSERT address;
        system.debug('address ' + address);
       
        //Site insertion
        cscrm__Site__c site = new cscrm__Site__c();
        site.Name = '242 Exhibition Street Melbourne';
        //site.cscrm__Installation_Address__c = address.Name;
        //site.AdborID__c = '50844332';
        //site.address_Status__c = 'CONFIRMED';
        //site.cscrm__Account__c = 'TestAccSDWAN';
        site.cscrm__Account__c = testAccount.id;
        //site.cscrm__Installation_Address__c = [SELECT Id FROM cscrm__Address__c WHERE Name = '21 CRESTING AVE, Melbourne Aussie PROSPECT TAS 7250'];
        //site.cscrm__Installation_Address__c = address.Address_ID__c;
        site.cscrm__Installation_Address__c = address.id;
        INSERT site;
        
        
        //Solution Defination creation
        List<csord__Solution__c> SDWAN_Solution = new List <csord__Solution__c>();
		csord__Solution__c sol1 = new csord__Solution__c(Name = 'SD-WAN Adapt S1 Solution_242 Exhibition Street Melbourne', 
                                                                   csord__Status__c = 'Completed', cssdm__main_product__c = 'ce109a77-df54-e909-0e92-a27b5a94902d',
                                                                   csord__Identification__c = 'Solution Console 2021-03-16 07:15:11',
                                                                   cssdm__product_basket__c = boltOnBasket1.Id);
        SDWAN_Solution.add(sol1);
        
		csord__Solution__c sol2 = new csord__Solution__c(Name = 'SD-WAN Adapt S1 Solution_242 Exhibition Street Melbourne', 
                                                                   csord__Status__c = 'Completed', cssdm__main_product__c = 'ce109a77-df54-e909-0e92-a27b5a94902d',
                                                                   csord__Identification__c = 'Solution Console 2021-03-16 07:15:11',
                                                                   cssdm__product_basket__c = boltOnBasket2.Id);
        SDWAN_Solution.add(sol2);
        
        INSERT SDWAN_Solution;
        

        
        //Product configuration creation
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        
         cscfga__Product_Configuration__c config0 = ProductTestFactory.buildProductConfig(sdwan_pd.id);
        config0.name= 'SD-WAN Adapt S1 Solution';
        config0.Type__c = 'New';
        config0.Marketable_Offer__c = sdwan_MO.id;
        config0.cscfga__Product_Family__c='SDWAN ADAPT S1';
        config0.cscfga__Product_Definition__c =sdwan_pd.id;
        config0.cscfga__unit_recurring_charge__c = 0.00;
        config0.cscfga__Product_Basket__c = boltOnBasket1.id;
        config0.cscfga__total_one_off_charge__c = 250.00;
		config0.csordtelcoa__Replaced_Product_Configuration__c = null;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
        prodConfigList.add(config0);

        
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(sd_wan_pd.id);
        config1.name= 'SD-WAN ADAPT S1';
        config1.Type__c = 'New';
        config1.Marketable_Offer__c = sdwan_MO.id;
        config1.cscfga__Product_Family__c='SD-WAN ADAPT S1';
        config1.cscfga__Product_Definition__c = sd_wan_pd.id;
        config1.cscfga__unit_recurring_charge__c = 15600.00;
        config1.cscfga__Product_Basket__c = boltOnBasket1.id;
        //config1.cssdm__solution_association__c = SDWAN_Solution.Id;
        config1.cscfga__total_one_off_charge__c=250.00;
		config1.csordtelcoa__Replaced_Product_Configuration__c = null;
        prodConfigList.add(config1);
        
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(secE_pd4.id);
        config2.name= 'Enterprise Wireless 1';
        config2.Type__c = 'New';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config2.cscfga__Product_Family__c='Enterprise Wireless';
        config2.cscfga__Product_Definition__c =secE_pd4.id;
        config2.cscfga__unit_recurring_charge__c = 0.00;
        config2.cscfga__Product_Basket__c = boltOnBasket1.id;
        config2.cscfga__total_one_off_charge__c = 0.00;
        config2.Quantity_Product_Configuration__c = 1;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
		config2.csordtelcoa__Replaced_Product_Configuration__c = null;
        prodConfigList.add(config2);
        
        
        cscfga__Product_Configuration__c config3 = ProductTestFactory.buildProductConfig(secE_pd1.id);
        config3.name= 'SecureEdge Cloud';
        config3.Type__c = 'New';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config3.cscfga__Product_Family__c='SecureEdge Cloud';
        config3.cscfga__Product_Definition__c =secE_pd1.id;
        config3.cscfga__unit_recurring_charge__c = 10080.00;
        config3.cscfga__Product_Basket__c = boltOnBasket1.id;
        config3.cscfga__total_one_off_charge__c = 0.00;
        config3.Quantity_Product_Configuration__c = 1;
		config3.csordtelcoa__Replaced_Product_Configuration__c = null;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
        prodConfigList.add(config3);
        
        cscfga__Product_Configuration__c config4 = ProductTestFactory.buildProductConfig(secE_pd3.id);
        config4.name= 'SecureEdge Cloud Remote';
        config4.Type__c = 'New';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config4.cscfga__Product_Family__c='SecureEdge Cloud Remote';
        config4.cscfga__Product_Definition__c =secE_pd3.id;
        config4.cscfga__unit_recurring_charge__c = 0.00;
        config4.cscfga__Product_Basket__c = boltOnBasket1.id;
        config4.cscfga__total_one_off_charge__c = 80.00;
        config4.Quantity_Product_Configuration__c = 1;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
		config4.csordtelcoa__Replaced_Product_Configuration__c = null;
        prodConfigList.add(config4);
        
        cscfga__Product_Configuration__c config5 = ProductTestFactory.buildProductConfig(secE_pd3.id);
        config5.name= 'SecureEdge Cloud Remote Worker';
        config5.Type__c = 'New';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config5.cscfga__Product_Family__c='SecureEdge Cloud Remote Worker';
        config5.cscfga__Product_Definition__c =secE_pd3.id;
        config5.cscfga__unit_recurring_charge__c = 0.00;
        config5.cscfga__Product_Basket__c = boltOnBasket1.id;
        config5.cscfga__total_one_off_charge__c = 0.00;
        config5.Quantity_Product_Configuration__c = 1;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
		config5.csordtelcoa__Replaced_Product_Configuration__c = null;
        prodConfigList.add(config5);
        
        cscfga__Product_Configuration__c config6 = ProductTestFactory.buildProductConfig(secE_pd2.id);
        config6.name= 'External IP Address 1';
        config6.Type__c = 'New';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config6.cscfga__Product_Family__c='External IP Address';
        config6.cscfga__Product_Definition__c =secE_pd2.id;
        config6.cscfga__unit_recurring_charge__c = 0.00;
        config6.cscfga__Product_Basket__c = boltOnBasket1.id;
        config6.cscfga__total_one_off_charge__c = 0.00;
        config6.Quantity_Product_Configuration__c = 1;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
        prodConfigList.add(config6);
        
        INSERT prodConfigList;
        
        List<cscfga__Product_Configuration__c> prodConfigList_can = new List<cscfga__Product_Configuration__c>();
        
        cscfga__Product_Configuration__c config_cal0 = ProductTestFactory.buildProductConfig(sdwan_pd.id);
        config_cal0.name= 'SD-WAN Adapt S1 Solution';
        config_cal0.Type__c = 'Cancel';
        config_cal0.Marketable_Offer__c = sdwan_MO.id;
        config_cal0.cscfga__Product_Family__c='SDWAN ADAPT S1';
        config_cal0.cscfga__Product_Definition__c =sdwan_pd.id;
        config_cal0.cscfga__unit_recurring_charge__c = 0.00;
        config_cal0.cscfga__Product_Basket__c = boltOnBasket2.id;
        config_cal0.cscfga__total_one_off_charge__c = 250.00;
        config_cal0.csordtelcoa__Replaced_Product_Configuration__c = config0.id;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
        prodConfigList_can.add(config_cal0);

        
        cscfga__Product_Configuration__c config_cal1 = ProductTestFactory.buildProductConfig(sd_wan_pd.id);
        config_cal1.name= 'SD-WAN ADAPT S1';
        config_cal1.Type__c = 'Cancel';
        config_cal1.Marketable_Offer__c = sdwan_MO.id;
        config_cal1.cscfga__Product_Family__c='SD-WAN ADAPT S1';
        config_cal1.cscfga__Product_Definition__c = sd_wan_pd.id;
        config_cal1.cscfga__unit_recurring_charge__c = 00;
        config_cal1.cscfga__Product_Basket__c = boltOnBasket2.id;
        //config1.cssdm__solution_association__c = SDWAN_Solution.Id;
        config_cal1.cscfga__total_one_off_charge__c=00;
        config_cal1.csordtelcoa__Replaced_Product_Configuration__c = config1.id;
        prodConfigList_can.add(config_cal1);
        
        cscfga__Product_Configuration__c config_cal2 = ProductTestFactory.buildProductConfig(secE_pd4.id);
        config_cal2.name= 'Enterprise Wireless 1';
        config_cal2.Type__c = 'Cancel';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config_cal2.cscfga__Product_Family__c='Enterprise Wireless';
        config_cal2.cscfga__Product_Definition__c =secE_pd4.id;
       // config_cal2.cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_001447';
        config_cal2.cscfga__unit_recurring_charge__c = 0.00;
        config_cal2.cscfga__Product_Basket__c = boltOnBasket2.id;
        config_cal2.cscfga__total_one_off_charge__c = 0.00;
        config_cal2.Quantity_Product_Configuration__c = 1;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
        config_cal2.csordtelcoa__Replaced_Product_Configuration__c = config2.id;
        prodConfigList_can.add(config_cal2);
        
         cscfga__Product_Configuration__c config_cal3 = ProductTestFactory.buildProductConfig(secE_pd1.id);
        config_cal3.name= 'SecureEdge Cloud';
        config_cal3.Type__c = 'Modify';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config_cal3.cscfga__Product_Family__c='SecureEdge Cloud';
        config_cal3.cscfga__Product_Definition__c =secE_pd1.id;
       // config_cal2.cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_001447';
        config_cal3.cscfga__unit_recurring_charge__c = 0.00;
        config_cal3.cscfga__Product_Basket__c = boltOnBasket2.id;
        config_cal3.cscfga__total_one_off_charge__c = 0.00;
        config_cal3.Quantity_Product_Configuration__c = 1;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
        config_cal3.csordtelcoa__Replaced_Product_Configuration__c = config3.id;
        prodConfigList_can.add(config_cal3);
        
        cscfga__Product_Configuration__c config_cal4 = ProductTestFactory.buildProductConfig(secE_pd2.id);
        config_cal4.name= 'External IP Address 1';
        config_cal4.Type__c = 'Cancel';
        //config0.Marketable_Offer__c = sdwan_MO.id;
        config_cal4.cscfga__Product_Family__c='External IP Address';
        config_cal4.cscfga__Product_Definition__c =secE_pd2.id;
       // config_cal2.cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_001447';
        config_cal4.cscfga__unit_recurring_charge__c = 0.00;
        config_cal4.cscfga__Product_Basket__c = boltOnBasket2.id;
        config_cal4.cscfga__total_one_off_charge__c = 0.00;
        config_cal4.Quantity_Product_Configuration__c = 1;
        //config0.cssdm__solution_association__c = SDWAN_Solution.Id;
        config_cal4.csordtelcoa__Replaced_Product_Configuration__c = config6.id;
        prodConfigList_can.add(config_cal4);
        
        INSERT prodConfigList_can;
        
       /*List<cscfga__Attribute_Definition__c> attDefList = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = secE_pd1.Id,
            Name = 'Add-On Bandwidth',
            cscfga__Default_Value__c = '100 Mbps'
            //Snapshot_Attribute_Value_Field__c = 'Once_Off__c',
            //Snapshot_Attribute_Fields__c = 'cspmb__One_Off_Charge__c'
        ); 
        attDefList.add(ad1);
        
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = secE_pd3.Id,
            Name = 'Commercial Product Id'
            //Snapshot_Attribute_Value_Field__c = 'Once_Off__c',
            //Snapshot_Attribute_Fields__c = 'cspmb__One_Off_Charge__c'
        ); 
        attDefList.add(ad2);
        insert attDefList;*/
        
        
        
        
        //Commercial Products
        List<cspmb__Price_Item__c> price_item_shared_dataList = new List<cspmb__Price_Item__c>();

        cspmb__Price_Item__c price_item_shared_data1 = new cspmb__Price_Item__c();
        price_item_shared_data1.Name = 'SD-WAN Adapt S1 – Small';
        price_item_shared_data1.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data1.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data1.cspmb__Is_Active__c = true;
        price_item_shared_data1.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        price_item_shared_data1.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        price_item_shared_data1.Charge_Id__c='DMCAT_RecurringCharge_001350';
        price_item_shared_data1.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data1.Billing_Description__c = 'SD-WAN Adapt S1 Small Bundle';
        price_item_shared_data1.Offer_Id__c = 'DMCAT_Offer_001343';
        price_item_shared_data1.ChargeType__c = 'RC';
        price_item_shared_data1.cspmb__Recurring_Charge__c = 380.00;
        price_item_shared_data1.cspmb__One_Off_Charge__c = 250.00;
       price_item_shared_data1.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data1.cspmb__Role__c = 'Basic';
        //price_item_shared_data1.cspmb__offer_code__c = 'Test';
        price_item_shared_data1.cspmb__Price_Item_Code__c = 'User Support';
        price_item_shared_dataList.add(price_item_shared_data1);
        
        
        cspmb__Price_Item__c price_item_shared_data2 = new cspmb__Price_Item__c();
        
        price_item_shared_data2.Name = 'SD-WAN Adapt S1 – Medium';
        price_item_shared_data2.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data2.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data2.cspmb__Is_Active__c = true;
        price_item_shared_data2.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8163';
        price_item_shared_data2.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8163';
        price_item_shared_data2.Charge_Id__c='DMCAT_RecurringCharge_001350';
        price_item_shared_data2.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data2.Billing_Description__c = 'SD-WAN Adapt S1 Medium Bundle';
        price_item_shared_data2.Offer_Id__c = 'DMCAT_Offer_001343';
        //Plan__c = '50 KB',
        price_item_shared_data2.ChargeType__c = 'RC';
        price_item_shared_data2.cspmb__Recurring_Charge__c = 450.00;
        price_item_shared_data2.cspmb__One_Off_Charge__c = 250.00;
        price_item_shared_data2.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data2.cspmb__Role__c = 'Basic';
        //price_item_shared_data2.cspmb__offer_code__c = 'Test';
        price_item_shared_data2.cspmb__Price_Item_Code__c = 'User Support';
        
        price_item_shared_dataList.add(price_item_shared_data2);

        cspmb__Price_Item__c price_item_shared_data3 = new cspmb__Price_Item__c();
        
        price_item_shared_data3.Name = 'SD-WAN Adapt S1 – Large';
        price_item_shared_data3.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data3.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data3.cspmb__Is_Active__c = true;
        price_item_shared_data3.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8164';
        price_item_shared_data3.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8164';
        price_item_shared_data3.Charge_Id__c='DMCAT_RecurringCharge_001350';
        price_item_shared_data3.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data3.Billing_Description__c = 'SD-WAN Adapt S1 Large Bundle';
        price_item_shared_data3.Offer_Id__c = 'DMCAT_Offer_001343';
        price_item_shared_data3.ChargeType__c = 'RC';
        price_item_shared_data3.cspmb__Recurring_Charge__c = 650.00;
        price_item_shared_data3.cspmb__One_Off_Charge__c = 250.00;
        price_item_shared_data3.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data3.cspmb__Role__c = 'Basic';
        price_item_shared_data3.cspmb__Price_Item_Code__c = 'User Support';
        //price_item_shared_data3.cspmb__offer_code__c = 'Test';
        
        price_item_shared_dataList.add(price_item_shared_data3);

        cspmb__Price_Item__c price_item_shared_data4 = new cspmb__Price_Item__c();
        
        price_item_shared_data4.Name = 'SD-WAN Adapt S1 – Extra Large';
        price_item_shared_data4.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data4.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data4.cspmb__Is_Active__c = true;
        price_item_shared_data4.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8165';
        price_item_shared_data4.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8165';
        price_item_shared_data4.Charge_Id__c='DMCAT_RecurringCharge_001350';
        price_item_shared_data4.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data4.Billing_Description__c = 'SD-WAN Adapt S1 Extra Large Bundle';
        price_item_shared_data4.Offer_Id__c = 'DMCAT_Offer_001343';
        price_item_shared_data4.ChargeType__c = 'RC';
        price_item_shared_data4.cspmb__Recurring_Charge__c = 1200.00;
        price_item_shared_data4.cspmb__One_Off_Charge__c = 250.00;
        price_item_shared_data4.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data4.cspmb__Role__c = 'Basic';
        price_item_shared_data4.cspmb__Price_Item_Code__c = 'User Support';
        //price_item_shared_data4.cspmb__offer_code__c = 'Test';
        
        price_item_shared_dataList.add(price_item_shared_data4);
        
        cspmb__Price_Item__c price_item_shared_data5 = new cspmb__Price_Item__c();
        price_item_shared_data5.Name = 'SecureEdge Add-on Bandwidth Monthly Charge';
        price_item_shared_data5.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data5.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data5.cspmb__Is_Active__c = true;
        price_item_shared_data5.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        //price_item_shared_data5.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        price_item_shared_data5.Charge_Id__c='DMCAT_RecurringCharge_001372';
        price_item_shared_data5.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data5.Billing_Description__c = '500Mbps additional bandwidth';
        price_item_shared_data5.Offer_Id__c = 'DMCAT_Offer_001367';
        //price_item_shared_data5.ChargeType__c = 'RC';
        price_item_shared_data5.cspmb__Recurring_Charge__c = 1420.00;
        price_item_shared_data5.cspmb__One_Off_Charge__c = 0.00;
        price_item_shared_data5.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data5.cspmb__Role__c = 'Basic';
        price_item_shared_data5.cspmb__Price_Item_Code__c = 'User Support';
        //price_item_shared_data5.cspmb__offer_code__c = 'Test';
        price_item_shared_dataList.add(price_item_shared_data5);
        
        cspmb__Price_Item__c price_item_shared_data6 = new cspmb__Price_Item__c();
        price_item_shared_data6.Name = 'SecureEdge Add-on Bandwidth Monthly Charge';
        price_item_shared_data6.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data6.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data6.cspmb__Is_Active__c = true;
        price_item_shared_data6.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        //price_item_shared_data6.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        price_item_shared_data6.Charge_Id__c='DMCAT_RecurringCharge_001372';
        price_item_shared_data6.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data6.Billing_Description__c = '100Mbps additional bandwidth';
        price_item_shared_data6.Offer_Id__c = 'DMCAT_Offer_001367';
        //price_item_shared_data6.ChargeType__c = 'RC';
        price_item_shared_data6.cspmb__Recurring_Charge__c = 420.00;
        price_item_shared_data6.cspmb__One_Off_Charge__c = 0.00;
        price_item_shared_data6.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data6.cspmb__Role__c = 'Basic';
        price_item_shared_data6.cspmb__Price_Item_Code__c = 'User Support';
        //price_item_shared_data6.cspmb__offer_code__c = 'Test';
        price_item_shared_dataList.add(price_item_shared_data6);
        
        cspmb__Price_Item__c price_item_shared_data7 = new cspmb__Price_Item__c();
        price_item_shared_data7.Name = 'SecureEdge Add-On Remote Monthly Charge';
        price_item_shared_data7.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data7.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data7.cspmb__Is_Active__c = true;
        price_item_shared_data7.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        //price_item_shared_data7.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162';
        price_item_shared_data7.Charge_Id__c='DMCAT_RecurringCharge_001463';
        price_item_shared_data7.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data7.Billing_Description__c = 'Remote worker';
        price_item_shared_data7.Offer_Id__c = 'DMCAT_Offer_001367';
        //price_item_shared_data7.ChargeType__c = 'RC';
        price_item_shared_data7.cspmb__Recurring_Charge__c = 8.00;
        price_item_shared_data7.cspmb__One_Off_Charge__c = 0.00;
        price_item_shared_data7.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data7.cspmb__Role__c = 'Basic';
        price_item_shared_data7.cspmb__Price_Item_Code__c = 'User Support';
        //price_item_shared_data7.cspmb__offer_code__c = 'Test';
        price_item_shared_dataList.add(price_item_shared_data7);
        
        cspmb__Price_Item__c price_item_shared_data9 = new cspmb__Price_Item__c();
        
        price_item_shared_data9.Name = 'SecureEdge Add-On External IP Addresses Charge';
        price_item_shared_data9.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data9.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data9.cspmb__Is_Active__c = true;
        price_item_shared_data9.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8163';
        //price_item_shared_data8.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8163';
        price_item_shared_data9.Charge_Id__c='DMCAT_RecurringCharge_001462';
        price_item_shared_data9.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data9.Billing_Description__c = 'External IP address';
        price_item_shared_data9.Offer_Id__c = 'DMCAT_Offer_001367';
        //Plan__c = '50 KB',
        //price_item_shared_data8.ChargeType__c = 'RC';
        price_item_shared_data9.cspmb__Recurring_Charge__c = 126.00;
        price_item_shared_data9.cspmb__One_Off_Charge__c = 0.00;
        price_item_shared_data9.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data9.cspmb__Role__c = 'Basic';
        price_item_shared_data9.cspmb__Price_Item_Code__c = 'User Support';
        //price_item_shared_data9.cspmb__offer_code__c = 'Test';
        
        price_item_shared_dataList.add(price_item_shared_data9);
		
		cspmb__Price_Item__c price_item_shared_data8 = new cspmb__Price_Item__c();
        
        price_item_shared_data8.Name = 'Enterprise Wireless Plan Charge';
        price_item_shared_data8.cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31);
        price_item_shared_data8.cspmb__Effective_Start_Date__c = Date.newInstance(2020,09,14);
        price_item_shared_data8.cspmb__Is_Active__c = true;
        price_item_shared_data8.Commercial_Product_Code__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8163';
        //price_item_shared_data8.External_Id__c = 'DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8163';
        price_item_shared_data8.Charge_Id__c='DMCAT_RecurringCharge_001451';
        price_item_shared_data8.BillingSpecId__c = 'BSRC001_CB';
        price_item_shared_data8.Billing_Description__c = 'Enterprise Wireless Epic Plan';
        price_item_shared_data8.Offer_Id__c = 'DMCAT_Offer_001343';
        //Plan__c = '50 KB',
        //price_item_shared_data8.ChargeType__c = 'RC';
        price_item_shared_data8.cspmb__Recurring_Charge__c = 45.45;
        price_item_shared_data8.cspmb__One_Off_Charge__c = 0.00;
        price_item_shared_data8.cspmb__Type__c = 'Commercial Product';
        price_item_shared_data8.cspmb__Role__c = 'Basic';
        price_item_shared_data8.cspmb__Price_Item_Code__c = 'User Support';
        //price_item_shared_data8.cspmb__offer_code__c = 'Test';
        price_item_shared_dataList.add(price_item_shared_data8);

        INSERT price_item_shared_dataList;
		
		/*List<cspmb__Usage_Type__c> UsageType = new List<cspmb__Usage_Type__c>();
       
        cspmb__Usage_Type__c UT = new cspmb__Usage_Type__c(Name = 'Add On Usage');
        
        
        UsageType.add(UT);
		INSERT UsageType;
		
		//Allowance
		List<cspmb__Allowance__c> planAllow = new List<cspmb__Allowance__c>();
       
        cspmb__Allowance__c planAll = new cspmb__Allowance__c(Name = 'Domestic Data Top Up Charge', plan__c = 'Auto Data Top-up (250GB)', 
                                                                      Description__c = 'Auto data top-up (250GB)',
                                                                      ocsProdId__c = 'T22EM_AUTO_TOPUP-2', Allowance_Id__c = 'DMCAT_RecurringCharge_001451', 
                                                                      	Offer_Id__c = 'DMCAT_Offer_001343',cspmb__usage_type__c=UT.id);
        
        
        planAllow.add(planAll);
		INSERT planAllow;*/
        
        //Product configuration Attribute
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
       
        cscfga__Attribute__c planName_attr = new cscfga__Attribute__c(Name = 'Plan Name', cscfga__Display_Value__c = 'SD-WAN Adapt S1 – Large', 
                                                                      cscfga__Price__c = 0.0,
                                                                      cscfga__Value__c = price_item_shared_data3.Id, cscfga__Discount_Type__c = 'amount', 
                                                                      cscfga__Product_Configuration__c = config1.Id);
        
        
        attList.add(planName_attr);
		
		cscfga__Attribute__c planName_attr_cal = new cscfga__Attribute__c(Name = 'Plan Name', cscfga__Display_Value__c = 'SD-WAN Adapt S1 – Small', 
                                                                      cscfga__Price__c = 0.0,
                                                                      cscfga__Value__c = price_item_shared_data1.Id, cscfga__Discount_Type__c = 'amount', 
                                                                      cscfga__Product_Configuration__c = config_cal1.Id);
        
        
        attList.add(planName_attr_cal);		
        
        
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
                Name = 'Add-On Bandwidth',
                cscfga__Value__c = price_item_shared_data6.id,
                cscfga__is_active__c = true,
                cscfga__Product_Configuration__c = config_cal3.Id
            );
        attList.add(att1);
		
		
		cscfga__Attribute__c att1_cal = new cscfga__Attribute__c(
                Name = 'Add-On Bandwidth',
                cscfga__Value__c = price_item_shared_data6.id,
                cscfga__is_active__c = true,
                cscfga__Product_Configuration__c = config_cal1.Id
            );
        attList.add(att1_cal);
        
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(
                Name = 'Commercial Product Id',
                cscfga__Value__c = price_item_shared_data7.id,
                cscfga__is_active__c = true,
                cscfga__Product_Configuration__c = config4.Id
            );
        attList.add(att2);
        
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(
                Name = 'WirelessPlanChargeId',
                cscfga__Value__c = price_item_shared_data7.id,
                cscfga__is_active__c = true,
                cscfga__Product_Configuration__c = config2.Id
            );
        attList.add(att3);
		
		cscfga__Attribute__c att3_cal = new cscfga__Attribute__c(
                Name = 'WirelessPlanChargeId',
                cscfga__Value__c = price_item_shared_data8.id,
				cscfga__Display_Value__c = 'Enterprise Wireless Plan Charge',
                cscfga__is_active__c = true,
                cscfga__Product_Configuration__c = config_cal2.Id
            );
        attList.add(att3_cal);

        cscfga__Attribute__c att4_cal = new cscfga__Attribute__c(
                Name = 'LTE Mode',
                cscfga__Value__c = 'Active',
				cscfga__Display_Value__c = 'Active',
                cscfga__is_active__c = true,
                cscfga__Product_Configuration__c = config_cal2.Id
            );
        attList.add(att4_cal);
		
		cscfga__Attribute__c att14_cal = new cscfga__Attribute__c(
                Name = 'LTE Mode',
                cscfga__Value__c = 'Active',
				cscfga__Display_Value__c = 'Active',
                cscfga__is_active__c = true,
                cscfga__Product_Configuration__c = config_cal1.Id
            );
        attList.add(att14_cal);

		 cscfga__Attribute__c att5_cal = new cscfga__Attribute__c(
                Name = 'Auto Data Top Up',
                cscfga__Value__c = null,
                cscfga__is_active__c = true,
				cscfga__Display_Value__c = null,
                cscfga__Product_Configuration__c = config_cal2.Id
            );
        attList.add(att5_cal);
        
        cscfga__Attribute__c att6_cal = new cscfga__Attribute__c(
                Name = 'Commercial Product Id',
                cscfga__Value__c = price_item_shared_data9.id,
                cscfga__is_active__c = true,
				cscfga__Display_Value__c = null,
                cscfga__Product_Configuration__c = config_cal4.Id
            );
        attList.add(att6_cal);
        
        insert attList;
        System.debug('attList6'+attList);
        
    }
    
     
   //@purpose : To create create test class for getSDWANServices
   @isTest 
   static void  getSDWANServicesTest(){ 
        
        
        Test.startTest();
            cscfga__Product_Basket__c prodBasket = [SELECT Id, Name 
                                                    FROM cscfga__Product_Basket__c
                                                    WHERE cscfga__Opportunity__r.Name = 'SDWAN Opportunity'
                                                    LIMIT 1];
            String basketId = '';
            if(prodBasket !=null){
                basketId = prodBasket.id;
            }
            
            SDWANDataHandler handler = new SDWANDataHandler();
             
            List<Map<String,Object>> rows = handler.getSDWANServices(basketId,new Map<String,String>{'Query_Type'=>'SDWANServices',
                                                                                                     'Type'=>'New'});
            system.debug('sdwan5rows :: ' + rows);
            System.debug('basketId5'+basketId);
            //System.assertNotEquals('Connected Workplace',rows[0].get('Product_Module_Name'));
            //System.assertEquals('SD-WAN Adapt S1 Large Bundle',rows[0].get('Product_Module_Name'));
        Test.stopTest();
        
        System.assert(rows.isEmpty() == false);
        System.assertEquals(true, rows[0].get('isSDWAN'));
        System.assertEquals('SD-WAN Adapt S1 Large Bundle',rows[0].get('Product_Module_Name'));

    }
    
    //@purpose : To create create test class for getSDWANCancelServices
    @isTest 
 static void  getSDWANCancelServicesTest(){ 
        
        
        Test.startTest();
            cscfga__Product_Basket__c prodBasket = [SELECT Id, Name 
                                                    FROM cscfga__Product_Basket__c
                                                    WHERE csordtelcoa__Change_Type__c = 'Change Solution'
                                                    LIMIT 1];
            String basketId = '';
            if(prodBasket !=null){
                basketId = prodBasket.id;
            }
            
            SDWANDataHandler handler = new SDWANDataHandler();             
            List<Map<String,Object>> rows = handler.getSDWANCancelServices(basketId);
            system.debug('sdwan5rows_cal :: ' + rows);
            System.debug('basketId5_cal'+basketId);
            //System.assertNotEquals('Connected Workplace',rows[0].get('Product_Module_Name'));
            //System.assertEquals('SD-WAN Adapt S1 Large Bundle',rows[0].get('Product_Module_Name'));
       Test.stopTest();  
        System.assert(rows.isEmpty() == false);
       System.assertEquals('SD-WAN Adapt S1 Small Bundle',rows[0].get('Product_Module_Name'));
       System.assertNotEquals('Connected Workplace',rows[0].get('Product_Module_Name'));

    }

    
    //@purpose : To create create test class for getSDWANServicesSecureEdge
    @isTest 
    static void  getSDWANServicesSecureEdgeTest(){
        
        Test.startTest();
        
            cscfga__Product_Basket__c prodBasket = [SELECT Id, Name 
                                                    FROM cscfga__Product_Basket__c
                                                    WHERE cscfga__Opportunity__r.Name = 'SDWAN Opportunity'
                                                    LIMIT 1];
            String basketId = '';
            if(prodBasket !=null)
            basketId = prodBasket.id;
            SDWANDataHandler handler = new SDWANDataHandler();
            List<Map<String,Object>> rows = handler.getSDWANServicesSecureEdge(basketId,new Map<String,String>{'Query_Type'=>'SECUREEDGEServices','Type'=>'New'});
               
        Test.stopTest();
        
        System.assert(rows.isEmpty() == false);
        System.assertEquals(true, rows[0].get('isSDWAN'));
        System.assertEquals('Remote worker', rows[0].get('Product_Module_Name'));

    }
    
    //@purpose : To create create test class for getSDWANServicesSecureEdgeModify
    @isTest 
    static void  getSDWANServicesSecureEdgeModifyTest(){
        
        Test.startTest();
        
            cscfga__Product_Basket__c prodBasket = [SELECT Id, Name 
                                                    FROM cscfga__Product_Basket__c
                                                    WHERE csordtelcoa__Change_Type__c = 'Change Solution'
                                                    LIMIT 1];
            String basketId = '';
            if(prodBasket !=null)
            basketId = prodBasket.id;
            SDWANDataHandler handler = new SDWANDataHandler();
            List<Map<String,Object>> rows = handler.getSDWANServicesSecureEdgeModify(basketId);
               
        Test.stopTest();
        
        System.assert(rows.isEmpty() == false);
        System.assertEquals(true, rows[0].get('isSDWAN'));
        System.assertEquals('100Mbps additional bandwidth', rows[0].get('Product_Module_Name'));

    }
    
    //@purpose : To create create test class for getSDWANServicesSecureEdgeCancel
    @isTest 
    static void  getSDWANServicesSecureEdgeCancelTest(){
        
        Test.startTest();
        
            cscfga__Product_Basket__c prodBasket = [SELECT Id, Name 
                                                    FROM cscfga__Product_Basket__c
                                                    WHERE csordtelcoa__Change_Type__c = 'Change Solution'
                                                    LIMIT 1];
            String basketId = '';
            if(prodBasket !=null)
            basketId = prodBasket.id;
            SDWANDataHandler handler = new SDWANDataHandler();
            List<Map<String,Object>> rows = handler.getSDWANServicesSecureEdgeCancel(basketId);
               
        Test.stopTest();
        
        System.assert(rows.isEmpty() == false);
        System.assertEquals(true, rows[0].get('isSDWAN'));
        System.assertEquals('External IP address', rows[0].get('Product_Module_Name'));

    }
}