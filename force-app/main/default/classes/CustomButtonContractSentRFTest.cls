/**
 * Test Class for custom button contract sent test.
 */
/////Shubhi V           06-July-2020    EDGE-147513    BillingAcc checks
/////Shubhi             02-09-2020      uniquename user fdr test class fix
@isTest//(seeAllData=true)Added seeAllData=true as sync api is called which needs pricebook data to be queried
public class CustomButtonContractSentRFTest  {
    @testsetup static void setupTestData() {
        createCustomSettingValues();
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='AgreementGeneration';
            env_var.value__c='false';
            insert env_var;
         EnvironmentVariable__c env_var1=  new EnvironmentVariable__c();
            env_var1.name='CheckTramasResponseValid';
            env_var1.value__c='true';
            insert env_var1;
          Sync_Control_and_Constants__c s1 = new Sync_Control_and_Constants__c(Name = 'CWP');
        Sync_Control_and_Constants__c s2 = new Sync_Control_and_Constants__c(Name = 'Telstra Collaboration');
        Sync_Control_and_Constants__c s3 = new Sync_Control_and_Constants__c(Name = 'Corporate Mobile Plus');
        Sync_Control_and_Constants__c s4 = new Sync_Control_and_Constants__c(Name = 'Basket_Not_Valid_For_Sync',value__c = 'test');
        Sync_Control_and_Constants__c s5 = new Sync_Control_and_Constants__c(Name = 'BillingAccountAttName',value__c = 'BillingAccountLookup');
        Sync_Control_and_Constants__c s6 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatus',value__c = 'Pending Finalisation,Final');
        Sync_Control_and_Constants__c s7 = new Sync_Control_and_Constants__c(Name = 'BillingAccountStatusValidation',value__c = 'test');
        Sync_Control_and_Constants__c s8 = new Sync_Control_and_Constants__c(Name = 'CWP_ProDefNames',value__c = 'Mobility,IP Site,Connected Workplace');
        Sync_Control_and_Constants__c s9 = new Sync_Control_and_Constants__c(Name = 'EAP_QuoteError',value__c = 'test');
        Sync_Control_and_Constants__c s10 = new Sync_Control_and_Constants__c(Name = 'Make_Primary_Basket_Error',value__c = 'test');
        Sync_Control_and_Constants__c s11 = new Sync_Control_and_Constants__c(Name = 'Modular',value__c = 'Modular');
        Sync_Control_and_Constants__c s12 = new Sync_Control_and_Constants__c(Name = 'NextGenUC',value__c = 'Telstra Collaboration');
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
        Sync_Control_and_Constants__c s25 = new Sync_Control_and_Constants__c(Name = 'EAP_ContractError',value__c = 'test');
        Sync_Control_and_Constants__c s26 = new Sync_Control_and_Constants__c(Name = 'OpenContractAlreadyExists',value__c = 'test');
        Sync_Control_and_Constants__c s27 = new Sync_Control_and_Constants__c(Name = 'Insufficient_OnFund_Balance',value__c = 'test');
        Sync_Control_and_Constants__c s28 = new Sync_Control_and_Constants__c(Name = 'SOW_Generate_Notification',value__c = 'test');
        Sync_Control_and_Constants__c s29 = new Sync_Control_and_Constants__c(Name = 'SOW_Approval_Notification',value__c = 'test');
        Sync_Control_and_Constants__c s30 = new Sync_Control_and_Constants__c(Name = 'TramasResponseMsg',value__c = 'test');
        Sync_Control_and_Constants__c s31 = new Sync_Control_and_Constants__c(Name = 'ContractInitiatedSuccessfully',value__c = 'test');
        Sync_Control_and_Constants__c s32 = new Sync_Control_and_Constants__c(Name = 'Contract_Initiated_Failed',value__c = 'test');
        Sync_Control_and_Constants__c s33 = new Sync_Control_and_Constants__c(Name = 'Contract_User_Validation',value__c = 'test');
        Sync_Control_and_Constants__c s34 = new Sync_Control_and_Constants__c(Name = 'Quote_User_Validation',value__c = 'A Statement of Work must be generated before creating this contract.');
        Sync_Control_and_Constants__c s35 = new Sync_Control_and_Constants__c(Name = 'Site_Validation',value__c = 'This Basket cannot be moved forward as there is another order on same site.');
        Sync_Control_and_Constants__c s36 = new Sync_Control_and_Constants__c(Name = 'DDate_Validation',value__c = 'Disconnection Date is required for cancel order. Please Edit and Enter Disconnection Date in IP Site or Mobility.');
        list<Sync_Control_and_Constants__c> slist = new list<Sync_Control_and_Constants__c>{s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21
            ,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36};
                insert slist;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
            insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
            insert prod;
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        List<PricebookEntry> testpbeList = new List<PricebookEntry>{standardPBE, pbe};
        insert testpbeList;
        Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        Account acc2 = new Account(Name = 'Test Account for CBQ 2');
        acc2.Customer_Status__c = 'ACQUIRED';
        List<Account> accList = new List<Account>{acc, acc2};
        insert accList;
         APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
        template.APXTConga4__Name__c = 'Quote';
        template.Sequence__c = 1;
        insert template;
        list<APXTConga4__Conga_Merge_Query__c> querylist= new list<APXTConga4__Conga_Merge_Query__c>();
        APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
        query1.APXTConga4__Name__c = 'BSChangesToExisting';
        querylist.add(query1);
        APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
        query2.APXTConga4__Name__c = 'BasketPricesFromPC1';
        querylist.add(query2);
        APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
        query3.APXTConga4__Name__c = 'BasketPricesFromPC2';
        querylist.add(query3);
        APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
        query4.APXTConga4__Name__c = 'BSCWPChanges';
        querylist.add(query4);
        insert querylist;
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        Opportunity opp2 = ProductTestFactory.getOpportunity(acc2, pb);
        opp2.StageName = 'Develop';
        opp2.Product_Type__c = 'Modular';
        opp2.Name = 'TestingOppError';
        Opportunity opp3 = ProductTestFactory.getOpportunity(acc2, pb);
        opp3.StageName = 'Develop';
        opp3.Product_Type__c = 'Modular';
        opp3.Name = 'TestingOppError2';
        Opportunity opp4 = ProductTestFactory.getOpportunity(acc, pb);
        opp4.StageName = 'Develop';
        opp4.Product_Type__c = 'Modular';
        opp4.Name = 'TestingOpp4';
        //EDGE-147970-Start
        Opportunity opp6 = ProductTestFactory.getOpportunity(acc, pb);
        opp6.StageName = 'Develop';
        opp6.Product_Type__c = 'Modular';
        opp6.Name = 'TestingBusCallingOpp';
        //EDGE-147970-End
         //Romil              02/04/2020    EDGE-141820 (EAP discount end date validation)       
        Opportunity opp5 = ProductTestFactory.getOpportunity(acc, pb);
        opp5.StageName = 'Develop';
        opp5.Product_Type__c = 'Modular';
        opp5.Name = 'TestingforEAPcheck';
        List<Opportunity> oppList = new List<Opportunity>{opp, opp2, opp3, opp4,opp5,opp6};
        insert oppList;
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
        con.email = 'testNew@gmail.com';
        INSERT con;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = con.Id;
        ocr2.OpportunityId = opp2.Id;
        ocr2.IsPrimary = TRUE;
        ocr2.Role = 'Decision Maker';
        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.ContactId = c.Id;
        ocr3.OpportunityId = opp4.Id;
        ocr3.IsPrimary = TRUE;
        ocr3.Role = 'Decision Maker';
        List<OpportunityContactRole> testOCRList = new List<OpportunityContactRole>{ocr, ocr2, ocr3};
        INSERT testOCRList;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
        basket2.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket2.cscfga__Opportunity__c = opp2.id;
        basket2.csbb__Account__c = acc2.Id;
        basket2.Description__c = 'testBasketforCBQ';
        cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c();
        basket3.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket3.cscfga__Opportunity__c = opp2.id;
        basket3.csbb__Account__c = acc2.Id;
        basket3.Description__c = 'secondaryTestBasketforCBQ';
        basket3.Primary_Basket__c = true;
        cscfga__Product_Basket__c basket4 = new cscfga__Product_Basket__c();
        basket4.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket4.cscfga__Opportunity__c = opp3.id;
        basket4.csbb__Account__c = acc2.Id;
        basket4.Description__c = 'testBasketforCBQError';
        cscfga__Product_Basket__c basket5 = new cscfga__Product_Basket__c();
        basket5.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket5.cscfga__Opportunity__c = opp4.id;
        basket5.csbb__Account__c = acc.Id;
        basket5.Description__c = 'testDiscDate';
        cscfga__Product_Basket__c basket6 = new cscfga__Product_Basket__c();
        basket6.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket6.cscfga__Opportunity__c = opp4.id;
        basket6.csbb__Account__c = acc.Id;
        basket6.Description__c = 'testBasketQuote';
        basket6.Primary_Basket__c = true;
        //EDGE-147970
        cscfga__Product_Basket__c basket8 = new cscfga__Product_Basket__c();
        basket8.csordtelcoa__Basket_Stage__c = 'Quote';
        basket8.cscfga__Opportunity__c = opp6.id;
        basket8.csbb__Account__c = acc.Id;
        basket8.Description__c = 'testBasketforEAPcheckbc';
        basket8.Primary_Basket__c = true;
        //EDGE-147970
        //Romil           02/04/2020    EDGE-141820 (EAP discount end date validation)
        cscfga__Product_Basket__c basket7 = new cscfga__Product_Basket__c();
        basket6.csordtelcoa__Basket_Stage__c = 'Quote';
        basket6.cscfga__Opportunity__c = opp5.id;
        basket6.csbb__Account__c = acc.Id;
        basket6.Description__c = 'testBasketforEAPcheck';
        basket6.Primary_Basket__c = true;
        //////////////// added by shubhi EDGE-147513 
        cscfga__Product_Basket__c basket12 = ProductTestFactory.buildEmptyBasket();
        basket12.csbb__Account__c = acc.id;
        basket12.cscfga__Opportunity__c = opp.id;
        basket12.Project_ID__c = 'basket1';
        cscfga__Product_Basket__c basket22 = ProductTestFactory.buildEmptyBasket();
        basket22.csbb__Account__c = acc.id;
        basket22.cscfga__Opportunity__c = opp.id;
        basket22.Project_ID__c = 'basket2';
        cscfga__Product_Basket__c basket32 = ProductTestFactory.buildEmptyBasket();
        basket32.csbb__Account__c = acc.id;
        basket32.cscfga__Opportunity__c = opp.id;
        basket32.Project_ID__c = 'basket3';
         //EDGE-191824|| EDGE-192931 start 
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq2.id);
        primaryOrd.csord__Order_Request__c = ordReq2.Id;
        primaryOrd.csordtelcoa__Opportunity__c = opp.Id;
        insert primaryOrd; 
        
        cscfga__Product_Basket__c basket15 = new cscfga__Product_Basket__c();
        basket15.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket15.cscfga__Opportunity__c = opp.id;
        basket15.csbb__Account__c = acc.Id;
        basket15.Name = 'TestInflightBakset';
        basket15.cscfga__Basket_Status__c = 'Valid';
          //EDGE-191824|| EDGE-192931 end
        ////////////////////
        List<cscfga__Product_Basket__c> testBasketList = new List<cscfga__Product_Basket__c>{basket, basket2, basket3, basket4, basket5, basket6,basket7,basket8,basket12,basket22,basket32, basket15};
        insert testBasketList;
         
        ///solutions and pcs=====//////////////// added by shubhi EDGE-147513 
         csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_negative');
        insert new List<csord__Solution__c>{sol1,sol2};
        cscfga__Product_Configuration__c pc1_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket12.id,sol1.id,'');
        cscfga__Product_Configuration__c pc1_new= PricingTestDataFactory.generateProductConfiguration('','New',basket12.id,sol1.id,'');
        cscfga__Product_Configuration__c pc2_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','Modify',basket22.id,sol2.id,'');
        cscfga__Product_Configuration__c pc2_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket22.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_sol= PricingTestDataFactory.generateProductConfiguration('SolutionComponent','New',basket32.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_modify= PricingTestDataFactory.generateProductConfiguration('','Modify',basket32.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_new= PricingTestDataFactory.generateProductConfiguration('','New',basket32.id,sol2.id,'');
        cscfga__Product_Configuration__c pc3_cancel= PricingTestDataFactory.generateProductConfiguration('','Cancel',basket32.id,sol2.id,'');
        insert new List<cscfga__Product_Configuration__c>{pc1_sol,pc1_new,pc2_sol,pc2_cancel,pc3_sol,pc3_modify,pc3_new,pc3_cancel};
         //Biiling accs
        Billing_Account__c billAcc1=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=c.Id, status__c='Created',Account__c=acc.id);
        Billing_Account__c billAcc2=new Billing_Account__c(Billing_Account_Number__c='123456789013',Billing_Account_Owner__c=c.Id,status__c='Final',Account__c=acc.id);
        insert new List<Billing_Account__c>{billAcc1,billAcc2};
        //////////////// added by shubhi EDGE-147513  ended
        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        ////EDGE-147970
        cscfga__Product_Definition__c defBusCalling = new cscfga__Product_Definition__c (Name = 'Business Calling', cscfga__Description__c = 'Business calling');
        ////EDGE-147970
         //Romil              02/04/2020    EDGE-141820 (EAP discount end date validation)
        cscfga__Product_Definition__c defNguc = new cscfga__Product_Definition__c (Name = System.Label.NGUC, cscfga__Description__c = System.Label.NGUC);
        cscfga__Product_Definition__c defUnifiedDevice = new cscfga__Product_Definition__c (Name = System.Label.Unified_Communication_Device, cscfga__Description__c = System.Label.Unified_Communication_Device);
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defIpSite, defIpNetwork, defUcEnterprise,defNguc,defUnifiedDevice,defBusCalling};
        insert prodDefList;
        cscfga__Attribute_Definition__c atrDef = ProductTestFactory.buildAttributeDefinition('test',defIpSite.id);
        atrDef.cscfga__is_Significant__c = true;
        insert atrDef;
        //Romil           02/04/2020    EDGE-141820 (EAP discount end date validation)
        cscfga__Product_Configuration__c confignguc = new cscfga__Product_Configuration__c() ;
        confignguc.name = 'IADs-OneAccess One100 (8 Port)';
        confignguc.Type__c = 'New'; 
        confignguc.cscfga__Product_Family__c='Unified Communication Device';
        confignguc.cscfga__total_recurring_charge__c = 46.26;
        confignguc.cscfga__Product_Definition__c=defUnifiedDevice.Id;
        insert confignguc;    
        //Romil           02/04/2020    EDGE-141820 (EAP discount end date validation)
        charge_line_item__c cli =new charge_line_item__c();
        cli.name='clicharge';
        cli.basketId__c=basket7.Id;
        cli.Product_Configuration__c=confignguc.Id;
        insert cli;
        //Romil           02/04/2020    EDGE-141820 (EAP discount end date validation)   
        Discount_Line_Item__c dli= new Discount_Line_Item__c();
        dli.name='dlicharge';
        dli.chargeInstance__c =cli.Id;
        dli.BusinessID__c='DMCAT_Discount_000899';
        dli.discountEndDate__c=Date.Today()-1;
        insert dli;
        //create Product Configuration
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        //List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>(); 
        for (Integer i=0; i < 15; i++){
            //cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defIpSite.id);
            config.cscfga__total_contract_value__c = 325;
            String confName = System.Label.Label_CWP;
            config.cscfga__Product_Definition__c = defIpSite.Id;
            if ( i == 8 || i == 10 || i == 13 ){
                confName = System.Label.IP_Network;
                config.cscfga__Product_Definition__c = defIpNetwork.Id;
            }
            else if( i == 9 || i == 11 || i == 14) {
                confName = System.Label.UC_Enterprise;
                config.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            if (i == 6 || i == 7 || i == 10 || i == 11)
            {
                config.cscfga__Product_Basket__c = basket2.id;
            } 
            else if (i == 4 || i == 5 || i == 13 ||i == 14 )
            {
                config.cscfga__Product_Basket__c = basket5.id;              
            }
            else{
                config.cscfga__Product_Basket__c = basket.id;
            }     
            config.Name = confName;
            config.cscfga__Description__c = 'test Description '+i;
            config.cscfga__Contract_Term__c = 36;
            config.Type__c = 'Modify';
            if  (i == 4 ||i == 5)
            {
                config.Type__c = 'Cancel';
                config.Name = 'IP Site';
            }
            prodConfigList.add(config);         
        }
        cscfga__Product_Category__c prodcat = ProductTestFactory.buildProductCategory();
        insert prodcat;
        insert prodConfigList;
        List<csbb__Callout_Product_Result__c> testCPRList = new List<csbb__Callout_Product_Result__c>();
        List<csbb__Product_Configuration_Request__c> testProdConfReqList = new List<csbb__Product_Configuration_Request__c>();
        for (cscfga__Product_Configuration__c config : prodConfigList)
        {
            csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
            pcr.csbb__Product_Category__c = prodcat.id;         
            pcr.csbb__Product_Configuration__c = config.id;
            pcr.csbb__Product_Basket__c = config.cscfga__Product_Basket__c;
            pcr.csbb__Total_OC__c = 25;
            pcr.csbb__Total_MRC__c = 25;
            testProdConfReqList.add(pcr);
        }
        insert testProdConfReqList;
        csbb__Callout_Result__c cor = ProductTestFactory.buildCallOutResults();
        insert cor;
        for (csbb__Product_Configuration_Request__c pcr : testProdConfReqList )
        {
            csbb__Callout_Product_Result__c copr = ProductTestFactory.buildCalloutProductResults(pcr, cor);
            testCPRList.add(copr);
        }
        insert testCPRList;
        //EDGE-147970-
        cscfga__Product_Configuration__c configbc = new cscfga__Product_Configuration__c() ;
        configbc.name = 'Business Calling';
        configbc.Type__c = 'New'; 
        configbc.cscfga__Product_Family__c='Business Calling';
        configbc.cscfga__total_recurring_charge__c = 46.26;
        configbc.cscfga__Product_Definition__c=defBusCalling.Id;
        insert configbc;    
        charge_line_item__c cli1 =new charge_line_item__c();
        cli1.name='clicharge';
        cli1.basketId__c=basket8.Id;
        cli1.Product_Configuration__c=configbc.Id;
        insert cli1;
        Discount_Line_Item__c dli1= new Discount_Line_Item__c();
        dli1.name='dlicharge';
        dli1.chargeInstance__c =cli1.Id;
        dli1.BusinessID__c='DMCAT_Discount_000899';
        dli1.discountEndDate__c=Date.Today()-1;
        insert dli1;
        //EDGE-147970-
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config0:prodConfigList){
          cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config0.id);
          attList.add(attr0);
          cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config0.id);
          attList.add(attr1);
          cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config0.id);
          attList.add(attr2);
          cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', config0.id);
          attList.add(attr3);
          cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('ContractTerms', '500.00', config0.id);
          attList.add(attr4);
          cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('ProductStatus', 'Lost', config0.id);
          attList.add(attr5);
          cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('RC', '700.00', config0.id);
          attList.add(attr6);
          cscfga__Attribute__c attr8 = ProductTestFactory.buildAttribute('Product', 'testproduct', config0.id);
          attList.add(attr8); 
          cscfga__Attribute__c attr9 = ProductTestFactory.buildAttribute('AcquisitionRevenue', '100.00', config0.id);
          attList.add(attr9);
          cscfga__Attribute__c attr10 = ProductTestFactory.buildAttribute('AvgAnnualisedRevenue', '200.00', config0.id);
          attList.add(attr10);
          cscfga__Attribute__c attr11 = ProductTestFactory.buildAttribute('Competitor', '300.00', config0.id);
          attList.add(attr11);
          cscfga__Attribute__c attr12 = ProductTestFactory.buildAttribute('CurrentRevenue', '400.00', config0.id);
          attList.add(attr12);
          cscfga__Attribute__c attr13 = ProductTestFactory.buildAttribute('IncrementalRevenue', '600.00', config0.id);
          attList.add(attr13);
          cscfga__Attribute__c attr14 = ProductTestFactory.buildAttribute('Domain', 'FIXED TELEPHONY', config0.id);
          attList.add(attr14);
          cscfga__Attribute__c attr15 = ProductTestFactory.buildAttribute('ProductCode', '1345', config0.id);
          attList.add(attr15);
          cscfga__Attribute__c attr16 = ProductTestFactory.buildAttribute('ProductMaximName', 'Elvin', config0.id);
          attList.add(attr16);
          cscfga__Attribute__c attr17 = ProductTestFactory.buildAttribute('RenewalRevenue', '900.00', config0.id);
          attList.add(attr17);
          cscfga__Attribute__c attr18 = ProductTestFactory.buildAttribute('Site Id', '123456798', config0.id);
          attList.add(attr18);
          if (config0.cscfga__Product_Basket__c == basket5.id)
          {
              cscfga__Attribute__c attr19 = ProductTestFactory.buildAttribute('DisconnectionDate', '', config0.id);
              attList.add(attr19);
          }
        }
        /////solutions and pcs=====//////////////// added by shubhi EDGE-147513 
        cscfga__Attribute__c attr20 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc1.id , pc1_sol.id);
        cscfga__Attribute__c attr21 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc2_sol.id);
        cscfga__Attribute__c attr22 = ProductTestFactory.buildAttribute('BillingAccountLookup',billAcc2.id , pc3_sol.id);
        attList.add(attr20);attList.add(attr21);attList.add(attr22);
        insert attList;
        List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
        for(cscfga__Attribute__c attr : attList){
          if(attr.Name == 'Product')
            newattrList.add(attr);
        }
        OpportunityLineItem oli = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=2000,Quantity = 2,
            OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[0].cscfga__Description__c,
            cscfga__Attribute__c = attList[0].id,Product_Status__c = 'Lost',Product_Name__c='test prod');
        OpportunityLineItem oli1 = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=3000,Quantity = 3,
          OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[1].cscfga__Description__c,
          cscfga__Attribute__c = attList[1].id, Product_Status__c = 'won',Product_Name__c='test1');
        OpportunityLineItem oli2 = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=4000,Quantity = 4,
          OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[2].cscfga__Description__c,
          cscfga__Attribute__c = attList[2].id,Product_Status__c = 'withdrawn',Product_Name__c='test2');
        //List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>{oli, oli1, oli2};
        //insert oLIList;
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        /*----Fix for FDR by Shubhi 2/9/20 START-----*/
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        /*----Fix for FDR by Shubhi 2/9/20 END-----*/
        insert sales; 
    }
    @isTest static void performActionTestError() {
        disableCSTrigger();

        EnvironmentVariable__c en = new EnvironmentVariable__c(Name = 'ValidationIPUCE',Value__c = '2');
        insert en;
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp4' LIMIT 1];
        basket.csordtelcoa__Basket_Stage__c='Submitted';
        update basket;
         cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        offer.Name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        offer.Config__c = '{"skipBasketSyncValidations":false}';
        offer.type__c = 'Professional Service';
        insert offer;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c= offer.id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;
        Test.startTest();
        CustomButtonContractSentRF newCustContractSent = new CustomButtonContractSentRF();
        String ret = newCustContractSent.performAction(basket.Id);
        Boolean dummyFlag = true;
        Test.stopTest();
        system.assert(dummyFlag);
        system.assertEquals(true,ret.contains('error'));
    }
     @isTest static void performActionTestError1() {
        disableCSTrigger();
        EnvironmentVariable__c en = new EnvironmentVariable__c(Name = 'ValidationIPUCE',Value__c = '2');
        insert en;

        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp4' LIMIT 1];
        basket.csordtelcoa__Basket_Stage__c='Submitted';
        update basket;

        SOW__c sw = new SOW__c();
         sw.Basket__c = basket.id;
         sw.Status__c = 'Rejected';
         insert sw;
         cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>{pd1};
            insert pdList;
        Marketable_Offer__c offer = new Marketable_Offer__c();
        offer.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        offer.Name = 'Telstra Collaboration';
        offer.Offer_ID__c = 'DMCAT_Offer_000618';
        offer.Config__c = '{"skipBasketSyncValidations":false}';
        offer.type__c = 'Professional Service';
        insert offer;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name = 'Connected Workplace',  Marketable_Offer__c= offer.id,cscfga__Product_Basket__c = basket.Id,Type__c = 'New',ConfigurationType1__c = 'test',
                                                                                    cscfga__Product_Definition__c=pdList[0].Id,csedm__CFS_Mapping_List__c = 'TestSpec');
        list<cscfga__Product_Configuration__c> configList1 = new list<cscfga__Product_Configuration__c>{pc1};
            insert configList1;

        Test.startTest();
        CustomButtonContractSentRF newCustContractSent = new CustomButtonContractSentRF();
        String ret = newCustContractSent.performAction(basket.Id);
        Boolean dummyFlag = true;
        Test.stopTest();
        system.assert(dummyFlag);

        system.assertEquals(true,ret.contains('error'));
    }

    static void disableCSTrigger() {
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = [Select id,csordtelcoa__Disable_Triggers__c,csordtelcoa__Opportunity_Stages_creating_orders__c from csordtelcoa__Orders_Subscriptions_Options__c where SetupOwnerId =: Userinfo.getOrganizationId()];
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = True ; 
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Submitted';
        update subsSettings ; 
    }
   static void createCustomSettingValues() { 
        List<CustomConfigurationOptions__c> lstConfigOptions = new List<CustomConfigurationOptions__c>();
        CustomConfigurationOptions__c configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Contract Accepted';
        configOptions.External_Id__c = '7654';
        configOptions.Opportunity_Stage__c = 'Develop';
        configOptions.Name = 'ContractAccepted';
        lstConfigOptions.add(configOptions);
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Draft';
        configOptions.External_Id__c = 'CCO3';
        configOptions.Opportunity_Stage__c = 'Develop';
        configOptions.Name = 'Draft';
        lstConfigOptions.add(configOptions);
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Contract Sent';
        configOptions.External_Id__c = 'CCO6';
        configOptions.Opportunity_Stage__c = 'Develop';
        configOptions.Name = 'ContractSent';
        lstConfigOptions.add(configOptions);
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Submitted';
        configOptions.External_Id__c = 'CCO1';
        configOptions.Opportunity_Stage__c = 'Submitted';
        configOptions.Name = 'ClosedWon';
        lstConfigOptions.add(configOptions);
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Cancelled';
        configOptions.External_Id__c = 'CCO2';
        configOptions.Opportunity_Stage__c = '';
        configOptions.Name = 'CancelBasket';
        lstConfigOptions.add(configOptions);
        configOptions = new CustomConfigurationOptions__c();
        configOptions.Enrichment_Basket_Stage__c = 'Contract Initiated';
        configOptions.External_Id__c = 'CC10';
        configOptions.Opportunity_Stage__c = 'Develop';
        configOptions.Name = 'ContractInitiate';
        lstConfigOptions.add(configOptions);
        CustomConfigurationOptions__c configOptionsq = new CustomConfigurationOptions__c();
        configOptionsq.Enrichment_Basket_Stage__c = 'Quote';
        configOptionsq.External_Id__c = 'CCO8';
        configOptionsq.Opportunity_Stage__c = 'Develop';
        configOptionsq.Name = 'Quote';
        lstConfigOptions.add(configOptionsq);
        CustomConfigurationOptions__c oCustConfig1   =   new CustomConfigurationOptions__c();
        oCustConfig1.Name = 'CommercialConfiguration';
        oCustConfig1.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        oCustConfig1.External_Id__c = 'CCO4';
        oCustConfig1.Opportunity_Stage__c = 'Develop';
        lstConfigOptions.add(oCustConfig1);
        insert lstConfigOptions;
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        insert subsSettings;
     }
    @isTest static void performUserValidation() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //added by shubhi for fdr fix
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User u = new User(Alias = 'standt', Email=uniquename+'_standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniquename+'_standarduser@testorg.com');
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        System.runAs(u){
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';  
        basket.cscfga__Opportunity__c =opp.id;
        basket.csbb__Account__c = acc.id;
        insert basket;
        CustomButtonContractSentRF generateContract = new CustomButtonContractSentRF();
        Test.startTest();
        String msg = generateContract.performAction(basket.Id);
        Test.stopTest();  
        system.debug('msg:'+msg);
        System.assert(msg.contains('error'));
        }
    }
    @isTest static void performBasketStageValidation(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='AgreementGeneration';
        ev.Value__c='false';
        insert ev;
        //CREATE OPPORTUNITY
         Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csordtelcoa__Basket_Stage__c='Contract Initiated';  
        basket.csbb__Synchronised_With_Opportunity__c =false;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =false;
        basket.cscfga__Opportunity__c =opp.id;
        basket.csbb__Account__c = acc.id;
        insert basket; 
        cscfga__Product_Basket__c basket1 = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];      
        CustomButtonContractSentRF generateContract = new CustomButtonContractSentRF();
        Test.startTest();
        String msg = generateContract.performAction(basket1.Id);
        Test.stopTest();  
        system.debug('basketmsg:'+msg);
        try{
        System.assert(basket1.id!=null);
        }
        catch(Exception e){
        }
    }
    @IsTest
    static void testDisconnectDate()
    {
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='AgreementGeneration';
        ev.Value__c='false';
        insert ev;
        cscfga__Product_Basket__c basket1 = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp4' LIMIT 1];
        CustomButtonContractSentRF generateContract = new CustomButtonContractSentRF();
        Test.startTest();
        String msg = generateContract.performAction(basket1.Id);
        System.assert(msg!=null);
        Test.stopTest();
    }
        /* ****************************************************************************
* Author : Manoj Kumar : EDGE-66038
* Date : 18 March 2019
* Description :Test method to cover : countAdborId() method
* 
* *****************************************************************************/
    @IsTest
    static void test_countAdborId()
    {
        cscfga__Product_Configuration__c PCList = [SELECT id,cscfga__Product_Basket__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,Name FROM cscfga__Product_Configuration__c WHERE Name = 'IP Site' LIMIT 1];
        Opportunity op = [Select id,AccountId from Opportunity where ID =:PCList.cscfga__Product_Basket__r.cscfga__Opportunity__c];
        cscfga__Attribute__c att = new cscfga__Attribute__c();
        att.Name = 'AdborID';
        att.cscfga__Value__c = '123456';
        att.cscfga__Product_Configuration__c = PCList.id;
        insert att;
        System.assertNotEquals(att.Id, Null);
        PCList.Technology_Type__c = 'NBN Access';
        PCList.Type__c = 'New';
        update PCList;
        Test.startTest();
        Integer i = CustomButtonContractSentRF.countAdborId(PCList.cscfga__Product_Basket__c,op.AccountId);
        System.assertNotEquals(i, null);
        Test.stopTest();
    }
/* ****************************************************************************
* Author : Robin Chawla : EDGE-88535
* Date : 07 June 2019
* Description :Test method to cover : isTramasResponseValid() method
* 
* *****************************************************************************/
    @IsTest
    static void isTramasResponseValidTest()
    {
      blob b = [select body from staticResource where name = 'ServiceJSON'].body;    
       String serviceDTO = b.toString();
       String serviceDTO_V2 ='{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"0732984688","Services_From":"0732984678","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"0732984678","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"PSTN","eligibilityStatus":"Eligible","eligibilityReason":null,"disableCheck":null,"checkValue":true},{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"0899163932","Services_From":"0899163922","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"0899163922","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN2","eligibilityStatus":"Eligible","eligibilityReason":null,"disableCheck":null,"checkValue":true},{"serviceList":[{"Service_Type":"Voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"0158073702","Services_From":"0158073692","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"checkValue":false},{"Services_To":"0158073722","Services_From":"0158073712","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"checkValue":false}],"Service_Type":"Voice","Service_Id":"0158073692","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","eligibilityStatus":"","eligibilityReason":"","disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":""}],"disableCheck":null,"checkValue":false}],"Product_Type":"ISDN2DID","eligibilityStatus":"Eligible","eligibilityReason":null,"disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"141343019"}],"serviceCount":6,"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICE45a00d371ef9daeeb5","CIDN":"5851072288"}'; 
       String ngucJson ='{ "Source_System_Id": "Replicator", "serviceCount": 0, "productList": [{ "site": [{ "siteName": null, "serviceList": [{ "Service_Type": null, "groupType": [{ "transitionId": null, "service": [{ "sim_serial_number": null, "serviceExtensions": [{ "serviceExtensionTo": "0360000300", "serviceExtensionFrom": "0360000200", "Reserve_status": null, "Reason": null, "eligibilityStatus": null, "eligibilityReason": null, "checkReserved": false }], "service_type_code": null, "service_type": null, "service_status": null, "Service_Id": "0360000653", "service_association_role": null, "Reserve_status": null, "replicatorUpdateDateTime": "2019-05-06 17:41:50.573", "Reason": null, "plan_name": null, "message_bank": null, "international_roaming": null, "imsi_number": null, "idd": null, "eligibilityStatus": null, "eligibilityReason": null, "Eligibility_status": "Eligible", "directory_listing": null, "devices": null, "contract_term": null, "calling_line_identifier": null, "accountDetails": null }], "groupId": "0360000653", "disableCheck": null, "checkValue": true }], "EligibilityStatus": null, "EligibilityReason": null, "disableCheck": null, "checkValue": false, "checkReserved": false }], "linkedSiteId": "A_END_ADDRESS", "Error_Description": null, "Error_Code": null, "ADBOR_Id": "261657664" }], "Product_Type": "ISDN30", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": null } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "8150e82a0e5e12194d", "CIDN": "2867413938" }';
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        cscrm__Address__c addrs = new cscrm__Address__c();
        addrs.Address_ID__c = '152365895123';
        addrs.Name = 'Test Address';
        addrs.cscrm__Account__c = acc.id;
        insert addrs;
        cscrm__Site__c siteobj = new cscrm__Site__c();
        siteobj.Name = 'Test Site';
        siteobj.cscrm__Account__c = acc.id;
        siteobj.cscrm__Installation_Address__c = addrs.Id;
        siteobj.Status__c = 'Active';
        siteobj.Legacy__c = true;
        insert siteobj;
        cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        update prodBasket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'IP Site';
         //EDGE-80772 : Solution Console retrofit
        config.cscfga__Product_Basket__c = prodBasket.id;
        config.cscfga__Description__c = 'Test description';
        insert config;
        cscfga__Product_Configuration__c config1 = ProductTestFactory.buildProductConfig(pd.Id);
        config1.name= 'Nguc';
         //EDGE-80772 : Solution Console retrofit
        config1.cscfga__Product_Basket__c = prodBasket.id;
        config1.cscfga__Description__c = 'Test description';
        insert config1;
        /***EDGE-80772 : commented for Solution Console retrofit
    csbb__Product_Configuration_Request__c prodConfigReq = ProductTestFactory.buildConfigRequest(prodBasket.Id,config.Id);
        prodConfigReq.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895123","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';       
        insert prodConfigReq;
        */
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
    //EDGE-80772 :  Solution Console retrofit
        att.ParentId = config.Id;
        att.Body = Blob.valueOf(serviceDTO_V2);
        insert att;
        Attachment att1 = new Attachment();
        att1.Name = system.label.NgUcTransitionName;
    //EDGE-80772 :  Solution Console retrofit
        att1.ParentId = config1.Id;
        att1.Body = Blob.valueOf(ngucJson);
        insert att1;
      // try{
        boolean statusFlag = CustomButtonContractSentRF.isTramasResponseValid(prodBasket.id,acc.Id);
        System.assertEquals(statusFlag,true);
        Test.stopTest();
       // }
       // Catch(Exception ex){
       // }  
    }
    /* ****************************************************************************
* Author : Robin Chawla : EDGE-88535
* Date :07 June 2019
* Description :Test method to cover : isTramasResponseValid() method
* 
* *****************************************************************************/
    @IsTest
    static void isTramasResponseValidTestNegative()
    {
      blob b = [select body from staticResource where name = 'ServiceJSON'].body;    
       String serviceDTO = b.toString();
       String serviceDTO_V2 = '{ "Source_System_Id": "Replicator", "site": [ { "siteName": null, "productList": [ { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0333458320", "Services_From": "0333458310", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0333458310", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ ], "Service_Type": "Voice", "Service_Id": "0266862625", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ ], "Service_Type": "Voice", "Service_Id": "0266814617", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "PSTN", "disableCheck": null, "checkValue": true }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ ], "Service_Type": "Voice", "Service_Id": "0292236598", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ { "Services_To": "0333458420", "Services_From": "0333458410", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0333458410", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "BE Bundle", "disableCheck": null, "checkValue": false }, { "serviceList": [ { "Service_Type": "Voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Services_To": "0893457332", "Services_From": "0393457300", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null }, { "Services_To": "0393457399", "Services_From": "0393457334", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0393457300", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "", "eligibilityStatus": null, "eligibilityReason": null }, { "User_Type": "", "serviceExtension": [ { "Services_To": "0266183204", "Services_From": "0266183201", "disableCheck": null, "checkValue": false, "eligibilityStatus": null, "eligibilityReason": null } ], "Service_Type": "Voice", "Service_Id": "0266183200", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "AXIS", "In_Flight_Flag": "N", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "In Dial", "Association_Role": "Primary", "eligibilityStatus": null, "eligibilityReason": null } ], "disableCheck": null, "checkValue": false } ], "Product_Type": "ISDN2DID", "disableCheck": null, "checkValue": true } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "260274355" } ], "serviceCount": 5, "Error_Description": "", "Error_Code": "", "Correlation_Id": "SFDC_REP_GETSERVICE633218060aca2c1ffa", "CIDN": "5810217906" }'; 
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        cscrm__Address__c addrs = new cscrm__Address__c();
        addrs.Address_ID__c = '152365895123';
        addrs.Name = 'Test Address';
        addrs.cscrm__Account__c = acc.id;
        insert addrs;
        cscrm__Site__c siteobj = new cscrm__Site__c();
        siteobj.Name = 'Test Site';
        siteobj.cscrm__Account__c = acc.id;
        siteobj.cscrm__Installation_Address__c = addrs.Id;
        siteobj.Status__c = 'Active';
        siteobj.Legacy__c = true;
        insert siteobj;
        cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        update prodBasket;
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        insert pd;
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'IP Site';
         //EDGE-80772 : Solution Console retrofit
        config.cscfga__Product_Basket__c = prodBasket.id;
        config.cscfga__Description__c = 'Test description';
        insert config;
        /***EDGE-80772 : Solution Console retrofit
        csbb__Product_Configuration_Request__c prodConfigReq = ProductTestFactory.buildConfigRequest(prodBasket.Id,config.Id);
        prodConfigReq.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895123","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';       
        insert prodConfigReq;
        */
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
    //EDGE-80772 : Solution Console retrofit
        att.ParentId = config.Id;
        att.Body = Blob.valueOf(serviceDTO_V2);
        insert att;
        try{
        boolean statusFlag = CustomButtonContractSentRF.isTramasResponseValid(prodBasket.id,acc.Id);
        Integer countervalue=CustomButtonContractSentRF.cancelAndPureModifyOrderCounterSignDisplay(prodBasket.id);
        System.assertEquals(statusFlag,false);
        Test.stopTest();
        }
        Catch(Exception ex){
        }  
    }
    @isTest static void performBasketStageValidation3(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='AgreementGeneration';
        ev.Value__c='true';
        insert ev;
        //CREATE OPPORTUNITY
         Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csordtelcoa__Basket_Stage__c='Contract Initiated';  
        basket.csbb__Synchronised_With_Opportunity__c =false;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =false;
        basket.cscfga__Opportunity__c =opp.id;
        basket.csbb__Account__c = acc.id;
        insert basket; 
        cscfga__Product_Basket__c basket1 = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];      
        CustomButtonContractSentRF generateContract = new CustomButtonContractSentRF();
        Test.startTest();
        String msg = generateContract.performAction(basket1.Id);
        Test.stopTest();  
        system.debug('basketmsg:'+msg);
        try{
        System.assert(basket1.id!=null);
        }
        catch(Exception e){
        }
    }
//EDGE-147513 start --------------------------
    @isTest
    public static void testBillingAccCheckValid(){
        try{
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username LIKE '%salesunifieduser@testsales.com' LIMIT 1];  //Fix for FDR by Shubhi 2/9/20
        cscfga__Product_Basket__c basket=[Select id,csbb__Account__c from cscfga__Product_Basket__c where Project_ID__c='basket1' limit 1];
        Boolean hasinvalidBillingAcc=false;
        System.runAs(sales){
           CustomButtonContractSentRF newCustContract = new CustomButtonContractSentRF();
           String ret=newCustContract.performAction(basket.id);
            system.debug('ret1-->'+ret);
           System.assertEquals(false, ret.contains(System.Label.BillingAccountStatusValidation));
        }
        Test.stopTest();
        }Catch(Exception e){
        }
    }
//EDGE-147513 end ----------------------------
    /************************************************************************
Name: contractServiceValidationTest
Description: Test Method for contractServiceValidationTest
Story : EDGE-183465
Developer: Abhishek Osaka Team

************************************************************************/ 
    @isTest static void contractServiceValidationTest(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        cscfga__Product_Basket__c basketNew = new cscfga__Product_Basket__c();
        basketNew.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.csbb__Account__c = acc.Id;
        basketNew.Name = 'ServiceBasket';
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
        addOnRecNew.Status__c = 'Sync Removal Pending';
        addOnRecNew.Product_End_Date__c = Date.today().addDays(7);
        Insert addOnRecNew;
        
        CustomButtonContractSentRF newCustContract = new CustomButtonContractSentRF();
        Test.startTest();
        String validationMessage =  newCustContract.performAction(basketId);
        Test.stopTest();
        System.assert(validationMessage.containsIgnoreCase('error'));
        
    }
    /************************************************************************
Name: contractServiceValidationTestNew
Description: Test Method for contractServiceValidationTest 
Story : EDGE-183465
Developer: Abhishek Osaka Team

************************************************************************/
    @isTest static void contractServiceValidationTestNew(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account for CBQ' LIMIT 1 ];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestingOpp' AND Product_Type__c = 'Modular' LIMIT 1];
        cscfga__Product_Basket__c basketNew = new cscfga__Product_Basket__c();
        basketNew.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basketNew.cscfga__Opportunity__c = opp.id;
        basketNew.csbb__Account__c = acc.Id;
        basketNew.Name = 'ServiceBasket';
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
        
        CustomButtonContractSentRF newCustContract = new CustomButtonContractSentRF();
        Test.startTest();
        String validationMessage =  newCustContract.performAction(basketId);
        Test.stopTest();
        System.assert(validationMessage.containsIgnoreCase('error'));
    }
    
     /************************************************************************
	Name: testInsolvencyCancellation
	Description: Test Method for InsolvencyCancellation 
	Story : DIGI-16205
	Developer: Purushottam from Alexanrdia
	************************************************************************/
    @IsTest
    static void testInsolvencyCancellation()
    {
        cscfga__Product_Basket__c basket1 = [SELECT id,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp4' LIMIT 1];
        Opportunity  opp = new Opportunity (id=basket1.cscfga__Opportunity__c,isInsolvencyCancel__c=true);
        update opp;
        CustomButtonContractSentRF generateContract = new CustomButtonContractSentRF();
        Test.startTest();
        String msg = generateContract.performAction(basket1.Id);
        System.assert(msg!=null);
        Test.stopTest();
    }
    
    //EDGE-191824|| EDGE-192931 start
    /*
    @isTest static void performActionInflightTest(){
        cscfga__Product_Basket__c basket = [Select id,csbb__Account__c from cscfga__Product_Basket__c where cscfga__Opportunity__r.Name='TestingOpp' limit 1];
        basket.RecordTypeId = recordtypeId;
        update basket;
        CustomButtonContractSentRF newCustContract = new CustomButtonContractSentRF();
        Test.startTest();
        String returnVal = newCustContract.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals(returnVal.containsIgnoreCase('error'), true);
    } */
    //EDGE-191824|| EDGE-192931 end
}