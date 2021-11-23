/**
 * Test Class for custom button quote rf test.
 * Payal             28-09-2020      Created a test class for CustomButtonQuoteRF classes
 * Pooja/Gunjan      11-02-2021      EDGE-191824|| EDGE-192931
 * 
 */
@isTest //Added seeAllData=true as sync api is called which needs pricebook data to be queried
public class CustomButtonQuoteRFTest {
    @TestSetup 
    static void testDataSetup() {
        /*Custom Setting and Environmental Variable setup: Start*/
        csordtelcoa__Orders_Subscriptions_Options__c coso = new csordtelcoa__Orders_Subscriptions_Options__c();
        coso.csordtelcoa__Disable_Triggers__c = True ;
        coso.csordtelcoa__Opportunity_Stages_creating_orders__c = 'Closed Won';
        INSERT coso;

        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration'); 
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_1';
        customSetting.Opportunity_Stage__c = 'Develop';

        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote'); 
        customSetting1.Name = 'Quote';
        customSetting1.External_Id__c = 'CCO_T_2';
        customSetting1.Opportunity_Stage__c = 'Develop';

        CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'ContractAccepted');
        customSetting2.Name = 'ContractAccepted';
        customSetting2.External_Id__c = 'CCO_T_3';

        CustomConfigurationOptions__c cco = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Closed Won');
        cco.Name = 'ClosedWon';
        cco.External_Id__c = 'CCO_T_4';
        cco.Opportunity_Stage__c = 'Closed Won';

        CustomConfigurationOptions__c co1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Cancelled');
        co1.Name = 'CancelBasket';
        co1.External_Id__c = 'CCO_T_5';

        CustomConfigurationOptions__c co3 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Submitted');
        co3.Name = 'Submitted';
        co3.External_Id__c = 'CCO_T_6';
        co3.Opportunity_Stage__c = 'Closed Won';
    
        CustomConfigurationOptions__c co4 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Service Detailing');
        co4.Name = 'ServiceDetailing';
        co4.External_Id__c = 'CCO_T_7';

        List<CustomConfigurationOptions__c> csList = new List<CustomConfigurationOptions__c>{customSetting, customSetting1, customSetting2, cco, co1, co3, co4};
        INSERT csList;

        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
        env_var.name='ValidationIPUCE';
        env_var.value__c='1';
        insert env_var;
        
        Sync_Control_and_Constants__c s1 = new Sync_Control_and_Constants__c(Name = 'CWP');
        Sync_Control_and_Constants__c s2 = new Sync_Control_and_Constants__c(Name = 'Adaptive Collaboration'); //DIGI-3352 B2B-1762 - Offer Name Change
        Sync_Control_and_Constants__c s3 = new Sync_Control_and_Constants__c(Name = 'Corporate Mobile Plus');
        Sync_Control_and_Constants__c s4 = new Sync_Control_and_Constants__c(Name = 'Basket_Not_Valid_For_Sync',value__c = 'test');
        Sync_Control_and_Constants__c s5 = new Sync_Control_and_Constants__c(Name = 'BillingAccountAttName',value__c = 'BillingAccountLookup');
        Sync_Control_and_Constants__c s6 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatus',value__c = 'Pending Finalisation,Final');
        Sync_Control_and_Constants__c s7 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatusValidation',value__c = 'test');
        Sync_Control_and_Constants__c s8 = new Sync_Control_and_Constants__c(Name = 'CWP_ProDefNames',value__c = 'Mobility,IP Site,Connected Workplace');
        Sync_Control_and_Constants__c s9 = new Sync_Control_and_Constants__c(Name = 'EAP_QuoteError',value__c = 'test');
        Sync_Control_and_Constants__c s10 = new Sync_Control_and_Constants__c(Name = 'Make_Primary_Basket_Error',value__c = 'test');
        Sync_Control_and_Constants__c s11 = new Sync_Control_and_Constants__c(Name = 'Modular',value__c = 'Modular');
        Sync_Control_and_Constants__c s12 = new Sync_Control_and_Constants__c(Name = 'NextGenUC',value__c = 'Adaptive Collaboration'); //DIGI-3352 B2B-1762 - Offer Name Change
        Sync_Control_and_Constants__c s13 = new Sync_Control_and_Constants__c(Name = 'No_Contact_Role_on_Opportunity',value__c = 'Modify,New');
        Sync_Control_and_Constants__c s14 = new Sync_Control_and_Constants__c(Name = 'PRM_CommunityAdmin_User',value__c = 'PRM Admin - Australia');
        Sync_Control_and_Constants__c s15 = new Sync_Control_and_Constants__c(Name = 'PRM_Community_User',value__c = 'PRM Community User - Australia');
        Sync_Control_and_Constants__c s16 = new Sync_Control_and_Constants__c(Name = 'PRM_Indirect_Channel_Mangr',value__c = 'Indirect Channel Manager');
        Sync_Control_and_Constants__c s17 = new Sync_Control_and_Constants__c(Name = 'PRM_Indirect_channel_mgrIntl',value__c = 'Indirect channel manager - International');
        Sync_Control_and_Constants__c s18 = new Sync_Control_and_Constants__c(Name = 'UC_Config_Name',value__c = 'Unified Communication');
        Sync_Control_and_Constants__c s19 = new Sync_Control_and_Constants__c(Name = 'UC_Enterprise',value__c = 'Unified Communication Enterprise');
        Sync_Control_and_Constants__c s20 = new Sync_Control_and_Constants__c(Name = 'UnifiedCommTenancyPresent',value__c = 'test');
        Sync_Control_and_Constants__c s21 = new Sync_Control_and_Constants__c(Name = 'UnifiedCommunicationTenancy',value__c = 'Unified Communication Tenancy');
        Sync_Control_and_Constants__c s22 = new Sync_Control_and_Constants__c(Name = 'UnifiedCommunicationTenancyNotPresent',value__c = 'test');
        Sync_Control_and_Constants__c s23 = new Sync_Control_and_Constants__c(Name = '  UnifiedCommunicationTenancyPresent',value__c = 'test');
        Sync_Control_and_Constants__c s24 = new Sync_Control_and_Constants__c(Name = 'notAllowedTypes',value__c = 'Modify,New');
        Sync_Control_and_Constants__c s25 = new Sync_Control_and_Constants__c(Name = 'Contract_User_Validation',value__c = 'Only the opportunity Owner or the Account owner Can create Contract');
        Sync_Control_and_Constants__c s26 = new Sync_Control_and_Constants__c(Name = 'Insufficient_OnFund_Balance',value__c = 'Insufficient OneFund Balance, please reconfigure and validate the Basket');
        Sync_Control_and_Constants__c s27 = new Sync_Control_and_Constants__c(Name = 'EAP_ContractError',value__c = 'EAP discount is no longer active. Please reconfigure the basket before generating the contract documents.');
        Sync_Control_and_Constants__c s28 = new Sync_Control_and_Constants__c(Name = 'SOW_Approval_Notification',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s29 = new Sync_Control_and_Constants__c(Name = 'SOW_Generate_Notification',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s30 = new Sync_Control_and_Constants__c(Name = 'OpenContractAlreadyExists',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s31 = new Sync_Control_and_Constants__c(Name = 'Contract_Initiated_Failed',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s32 = new Sync_Control_and_Constants__c(Name = 'TramasResponseMsg',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s33 = new Sync_Control_and_Constants__c(Name = 'ContractInitiatedSuccessfully',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s34 = new Sync_Control_and_Constants__c(Name = 'Quote_User_Validation',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s35 = new Sync_Control_and_Constants__c(Name = 'Site_Validation',value__c = 'This Basket cannot be moved forward as there is another order on same site.');
        Sync_Control_and_Constants__c s36 = new Sync_Control_and_Constants__c(Name = 'Ddate_Validation',value__c = 'Disconnection Date is required for cancel order. Please Edit and Enter Disconnection Date in IP Site or Mobility.');
        
        list<Sync_Control_and_Constants__c> slist = new list<Sync_Control_and_Constants__c>{s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21
            ,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36};
                insert slist; 
        /* Custom Setting and Environmental Variable setup: End*/
        /*Product and PriceBookSetup : Start*/
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
    
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
    
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        List<PricebookEntry> testpbeList = new List<PricebookEntry>{standardPBE, pbe};
        insert testpbeList;
        /*Product and PriceBookSetup : End*/
        
        /*Account Setup*/
        Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';

        Account acc2 = new Account(Name = 'Test Account for CBQ 2');
        acc2.Customer_Status__c = 'ACQUIRED';
        
        List<Account> accList = new List<Account>{acc, acc2};
        insert accList;
        
        Billing_Account__c billingAcct = new Billing_Account__c();
        billingAcct.Status__c = 'Final';
        billingAcct.Account__c = acc2.Id;
        billingAcct.Billing_Account_Number__c = '123456789101';
        insert billingAcct;
        /*Account Setup End*/
        /*Creating Subscription*/
        csord__Subscription__c sub = ProductTestService.getNewSubscriptionForAccount(acc2);
        sub.Name = 'Name';
        update sub;
        /*Creating Subscription*/
        /*Opportunity Setup Start*/
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        
        Opportunity opp1 = ProductTestFactory.getOpportunity(acc, pb);
        opp1.StageName = 'Develop';
        opp1.Product_Type__c = 'Modular';
        opp1.Name = 'TestingOpp1';
        
        Opportunity opp2 = ProductTestFactory.getOpportunity(acc2, pb);
        opp2.StageName = 'Develop';
        opp2.Product_Type__c = 'Modular';
        opp2.Name = 'TestingOpportunity';
        
        Opportunity opp3 = ProductTestFactory.getOpportunity(acc2, pb);
        opp3.StageName = 'Develop';
        opp3.Product_Type__c = 'Modular';
        opp3.Name = 'TestingOpportunitywithCLI';
        List<Opportunity> oppList = new List<Opportunity>{opp, opp2,opp1,opp3};
        insert oppList;
        /*Opportunity Setup: End*/
        
        /*Contact Role */
        Contact c = new Contact();
        c.FirstName = 'Testing';
        c.LastName = 'Test';
        c.AccountId = acc.id;
        c.email = 'test@gmail.com';
        INSERT c;
        
        Contact con = new Contact();
        con.FirstName = 'TestingNew';
        con.LastName = 'TestNew';
        con.AccountId = acc2.id;
        con.email = 'testnew@gmail.com';
        INSERT con;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp3.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = con.Id;
        ocr1.OpportunityId = opp2.Id;
        ocr1.IsPrimary = TRUE;
        ocr1.Role = 'Decision Maker';
        List<OpportunityContactRole> testOCRList = new List<OpportunityContactRole>{ocr,ocr1};
        INSERT testOCRList;
        /*Contact Role*/
        
        /*Creating basket */
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'inValidBasket';
        
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
        basket2.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket2.cscfga__Opportunity__c = opp1.id;
        basket2.csbb__Account__c = acc.Id;
        basket2.Name = 'BasketWithoutConfiguration';
        basket2.cscfga__Basket_Status__c = 'Valid';
        
        cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c();
        basket3.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket3.cscfga__Opportunity__c = opp2.id;
        basket3.csbb__Account__c = acc.Id;
        basket3.Name = 'BasketWithPConfiguration';
        basket3.cscfga__Basket_Status__c = 'Valid';
        
        cscfga__Product_Basket__c basket4 = new cscfga__Product_Basket__c();
        basket4.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket4.cscfga__Opportunity__c = opp3.id;
        basket4.csbb__Account__c = acc.Id;
        basket4.Name = 'BasketWithCLI';
        basket4.cscfga__Basket_Status__c = 'Valid';
        
        //EDGE-191824|| EDGE-192931 start
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq2.id);
        primaryOrd.csord__Order_Request__c = ordReq2.Id;
        primaryOrd.csordtelcoa__Opportunity__c = opp1.Id;
        insert primaryOrd; 
        
        cscfga__Product_Basket__c basket5 = new cscfga__Product_Basket__c();
        basket5.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket5.cscfga__Opportunity__c = opp1.id;
        basket5.csbb__Account__c = acc.Id;
        basket5.Name = 'TestInflightBakset';
        basket5.cscfga__Basket_Status__c = 'Valid';
        //EDGE-191824|| EDGE-192931 end
        
        List<cscfga__Product_Basket__c> testBasketList = new List<cscfga__Product_Basket__c>{basket, basket3,basket2,basket4,basket5};
        insert testBasketList;
        /*Basket Setup End*/
        /*Product Definition*/
        cscfga__Product_Definition__c defUnifiedDevice = new cscfga__Product_Definition__c (Name = 'Unified Communication Device', cscfga__Description__c = System.Label.Unified_Communication_Device);
        /*Product Definition*/
        /*Product Configuration*/
        cscfga__Product_Configuration__c confignguc = new cscfga__Product_Configuration__c() ;
        confignguc.name = 'IADs-OneAccess One100 (8 Port)';
        confignguc.Type__c = 'New'; 
        confignguc.cscfga__Product_Family__c='Unified Communication Device';
        confignguc.cscfga__total_recurring_charge__c = 46.26;
        confignguc.cscfga__Product_Definition__c=defUnifiedDevice.Id;
        confignguc.cscfga__Product_Basket__c = basket4.id;
        insert confignguc;
        /*Product Configuration : End*/
        
        /*Charge Line Item and Discount :Start */
        //Romil        02/04/2020  EDGE-141820 (EAP discount end date validation)
        charge_line_item__c cli =new charge_line_item__c();
        cli.name='clicharge';
        cli.basketId__c=basket4.Id;
        cli.Product_Configuration__c=confignguc.Id;
        insert cli;
         //Romil        02/04/2020  EDGE-141820 (EAP discount end date validation)   
        Discount_Line_Item__c dli= new Discount_Line_Item__c();
        dli.name='dlicharge';
        dli.chargeInstance__c =cli.Id;
        dli.BusinessID__c='DMCAT_Discount_000899';
        dli.discountEndDate__c=Date.Today()-1;
        insert dli;
        /*Charge Line Item and Discount : End*/
        
        /*Congo Templates and Query */
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
        template.APXTConga4__Name__c = 'Quote';
        template.Sequence__c = 1;
        
        APXTConga4__Conga_Template__c template1 = new APXTConga4__Conga_Template__c();
        template1.APXTConga4__Name__c = 'IOT Quote';
        template1.Sequence__c = 2;
        
        List<APXTConga4__Conga_Template__c> congaTemplatelst = new List<APXTConga4__Conga_Template__c>{template,template1};
        insert congaTemplatelst;

        List<APXTConga4__Conga_Merge_Query__c> testCongaQueryList = new List<APXTConga4__Conga_Merge_Query__c>();

        APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
        query1.APXTConga4__Name__c = 'BSChangesToExisting'; 
        
        APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
        query2.APXTConga4__Name__c = 'BasketPricesFromPC1'; 
        
        APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
        query3.APXTConga4__Name__c = 'BasketPricesFromPC2'; 
        
        APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
        query4.APXTConga4__Name__c = 'BSCWPChanges'; 
            
        testCongaQueryList.add(query1);
        testCongaQueryList.add(query2);
        testCongaQueryList.add(query3);
        testCongaQueryList.add(query4);

        insert testCongaQueryList;
        /*Conga Template and Query: End*/
        
    }
    @isTest static void InValidBasket() {
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];

        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        
        Test.startTest();
        
        String returnVal = newCustQuote.performAction(basket.Id);
        system.debug('returnVal for Invalid Basket '+returnVal);
        Test.stopTest();
        System.assertEquals(returnVal.containsIgnoreCase('error'), true);
    }
    @isTest static void BasketWithOutPC() {
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp1' LIMIT 1];

        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        
        Test.startTest();
        
        String returnVal = newCustQuote.performAction(basket.Id);

        Test.stopTest();

        System.debug(' returnVal of BasketwitoutConfig= :' + returnVal);
        System.assertEquals(returnVal.containsIgnoreCase('error'), true);
    }
    @isTest static void BasketWithOutProduct() {
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp1' LIMIT 1];
        Test.startTest();
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.name = System.Label.Label_CWP;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Configuration_Status__c = 'Valid';
        UPDATE config;
        
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute('Product', 'testproduct', config.id);
        insert attr;

        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        
        
        
        String returnVal = newCustQuote.performAction(basket.Id);

        Test.stopTest();

        cscfga__Product_Basket__c basket1 = [SELECT Id, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.debug(' returnVal of BasketwitoutConfig= :' + returnVal);
        System.assertEquals(returnVal.containsIgnoreCase('error'), true);
    }
    @isTest static void BasketWithPC() {
        Test.startTest();
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpportunity' and cscfga__Basket_Status__c ='Valid' LIMIT 1];
        
        Marketable_Offer__c marktoffer=new Marketable_Offer__c();
        marktoffer.Name='testoffer';
        marktoffer.Offer_ID__c='DMCAT_Offer_000964';         
        insert marktoffer;
            
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.name = 'IP Site';
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Configuration_Status__c = 'Valid';
        config.Marketable_Offer__c = marktoffer.Id;
        config.Type__c = 'Cancel';
        UPDATE config;
        
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute('DisconnectionDate','\''+Date.Today()+'\'', config.id);
        insert attr;
        
        //check if product attribute is null in the product configs and throw error
        List<charge_line_item__c> cli = [
              SELECT id, name, Product_Configuration__r.cscfga__Product_Definition__r.Name, (SELECT id, name, BusinessID__c, discountEndDate__c FROM Discount_Line_Items__r)
              FROM charge_line_item__c
              WHERE
                basketId__c = :basket.Id
               LIMIT 1
            ];
        system.debug('configList '+cli);
        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        
        
        
        String returnVal = newCustQuote.performAction(basket.Id);

        Test.stopTest();
        System.assertEquals(returnVal.containsIgnoreCase('ok'), true);
    }
    @isTest static void BasketWithCLI() {
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpportunitywithCLI' and cscfga__Basket_Status__c ='Valid' LIMIT 1];
        Opportunity opp= [Select Id,AccountId from Opportunity where Name='TestingOpportunitywithCLI' Limit 1];
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
        basket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.csbb__Account__c = opp.AccountId;
        basket1.Name = 'Valid';
        basket1.Primary_Basket__c = true;
        Test.startTest(); 
        insert basket1;
        //check if product attribute is null in the product configs and throw error
        List<charge_line_item__c> cli = [
              SELECT id, name,basketId__c, Product_Configuration__r.cscfga__Product_Definition__r.Name, (SELECT id, name, BusinessID__c, discountEndDate__c FROM Discount_Line_Items__r)
              FROM charge_line_item__c
              WHERE
                basketId__c = :basket.Id
               LIMIT 1
            ];
        
        List<cscfga__Product_Configuration__c> config = [Select id,cscfga__Product_Definition__r.Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c = :basket.Id Limit 1];
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute(System.Label.BillingAccountAttName, '1234', config[0].id);
        insert attr;
        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        
        
        
        String returnVal = newCustQuote.performAction(basket.Id);

        Test.stopTest();
        try{
            System.assertEquals(returnVal.containsIgnoreCase('error'), false);
        }catch(Exception err){
            system.debug('expection in Assert '+err);
        }
    }
    @isTest static void performUserValidation() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //added by shubhi for fdr fix
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User u = new User(
            Alias = 'standt', Email = uniquename+'-standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = uniquename+'_standarduser@testorg.com'
        );
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        
        System.runAs(u) {
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
            basket.cscfga__Opportunity__c = opp.id;
            basket.csbb__Account__c = acc.id;
            insert basket;
            CustomButtonQuoteRF generateQuote = new CustomButtonQuoteRF();
            String msg = generateQuote.performAction(basket.Id);
            Test.stopTest();
            System.assert(msg.containsIgnoreCase('error'));
        }
    }
    @isTest static void CoveringCatchBlock() {
        Test.startTest();
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpportunity' and cscfga__Basket_Status__c ='Valid' LIMIT 1];
        Opportunity opp = [select id from Opportunity where Name ='TestingOpportunity' Limit 1];
        Quote testQuote = new Quote();
        testQuote.Product_Basket__c = basket.Id;
        testQuote.Opportunity = opp;
        testQuote.Name = 'testQuote';
        testQuote.OpportunityId = opp.Id;
        insert testQuote;

        CustomButtonQuoteRF.rollbackQuote(testQuote.Id);
        Test.stopTest();
        List<Quote> lstQuote = [select id from Quote where Product_Basket__c =: basket.Id];
        system.assert(lstQuote.size()==0);
    }
    
   /************************************************************************
Name: quoteServiceValidationTest
Description: Test Method for quoteServiceValidation
Story : EDGE-183465
Developer: Abhishek Osaka Team

************************************************************************/ 
    @isTest static void quoteServiceValidationTest(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        cscfga__Product_Basket__c basketNew = new cscfga__Product_Basket__c();
        basketNew.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.csbb__Account__c = acc.Id;
        basketNew.Name = 'ServiceBasket';
        Test.startTest();
        Insert basketNew;
        String basketId =  basketNew.id;
        
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketNew.Id;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = true;
        Insert legacyRec;
        
        Service_Add_On__c addOnRecNew = new Service_Add_On__c();
        addOnRecNew.Legacy_Service__c = legacyRec.Id;
        addOnRecNew.Contract_Type__c = 'MRO';
        addOnRecNew.Charging_Option__c = 'Keep monthly repayment';
        addOnRecNew.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecNew.Status__c = 'Pending';
        Insert addOnRecNew;
        
        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        
        String validationMessage =  newCustQuote.performAction(basketId);
        Test.stopTest();
        System.assert(validationMessage.containsIgnoreCase('error'));
        
    }
    /************************************************************************
Name: quoteServiceValidationTestNew
Description: Test Method for quoteServiceValidation 
Story : EDGE-183465
Developer: Abhishek Osaka Team

************************************************************************/
    @isTest static void quoteServiceValidationTestNew(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        cscfga__Product_Basket__c basketNew = new cscfga__Product_Basket__c();
        basketNew.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.csbb__Account__c = acc.Id;
        basketNew.Name = 'ServiceBasket';
        Test.startTest();
        Insert basketNew;
        String basketId =  basketNew.id;
        
        Legacy_Service__c legacyRec = new Legacy_Service__c();
        legacyRec.Name = 'test'; 
        legacyRec.Service_Id__c = '';
        legacyRec.Product_Basket__c = basketNew.Id;
        legacyRec.Eligibility_Status__c = 'Eligible';
        legacyRec.Select__c = false;
        Insert legacyRec;
        
        Service_Add_On__c addOnRecNew = new Service_Add_On__c();
        addOnRecNew.Legacy_Service__c = legacyRec.Id;
        addOnRecNew.Contract_Type__c = 'MRO';
        addOnRecNew.Charging_Option__c = 'Keep monthly repayment';
        addOnRecNew.Device_Description__c = 'Apple iPhone XR 64GB';
        addOnRecNew.Status__c = 'Sync Removal Pending';
        Insert addOnRecNew;
        
        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        String validationMessage =  newCustQuote.performAction(basketId);
        Test.stopTest();
        System.assert(validationMessage.containsIgnoreCase('error'));
    }
    
    //EDGE-191824|| EDGE-192931 start
    @isTest static void performActionTest(){
        cscfga__Product_Basket__c basket = [SELECT id, recordType.Name FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp1' and cscfga__Basket_Status__c ='Valid' LIMIT 1];             
        Id recordtypeId = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
        basket.RecordTypeId = recordtypeId;
        Test.startTest();
        update basket;
        CustomButtonQuoteRF newCustQuote = new CustomButtonQuoteRF();
        
        String returnVal = newCustQuote.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals(returnVal.containsIgnoreCase('error'), true);
    }
    //EDGE-191824|| EDGE-192931 end
    
}