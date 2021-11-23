@isTest

/*************************************************************************************************
Name : AfterBasketClonePcCreatedHandlerTest 
Description : Test class for AfterBasketClonePcCreatedHandler
Sr no 1.02/05/2019      Zeeshan        Added methods  
Sr No 2. 02/05/2019     Laxmi Rahate    EDGE-75157 - Added test method -
**************************************************************************************************/
public class AfterBasketClonePcCreatedHandler_Test {
      

    /*public static testMethod void processSiteSQForBasketCloneTest(){

        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;

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
        
        List<Opportunity> oppList = new List<Opportunity>{opp, opp2, opp3, opp4};
            insert oppList;
        
        Contact c = new Contact();
        c.FirstName = 'Testing';
        c.LastName = 'Test';
        c.AccountId = acc.id;
        INSERT c;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = c.Id;
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
        
        List<cscfga__Product_Basket__c> testBasketList = new List<cscfga__Product_Basket__c>{basket, basket2, basket3, basket4, basket5, basket6};
            insert testBasketList;
        
        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defIpSite, defIpNetwork, defUcEnterprise};
            insert prodDefList;
        
        cscfga__Attribute_Definition__c atrDef = ProductTestFactory.buildAttributeDefinition('test',defIpSite.id);
        atrDef.cscfga__is_Significant__c = true;
        insert atrDef;
        
        //create Product Configuration
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        //List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>(); 
        for (Integer i=0; i < 15; i++){
            //cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defIpSite.id);
            config.cscfga__total_contract_value__c = 325;
            config.Technology_Type__c = 'NBN Access';
            
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
            config.Name = 'IP Site';
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
            cscfga__Attribute__c attr20 = ProductTestFactory.buildAttribute('AdborID', '123456798', config0.id);
            attList.add(attr20);
            
        }
        insert attList;
        System.assert(attList.Size()>0);
        
        cscrm__Address__c addressRecord = AccountTestFactory.buildAddress('123456798');
        Insert addressRecord;
        System.assertNotEquals(addressRecord.Id, Null);
        cscrm__Site__c siteRecord =  AccountTestFactory.buildSite(addressRecord.Id, acc.Id);
        Insert siteRecord;
        System.assertNotEquals(siteRecord.Id, Null);
        
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
        
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>{oli, oli1, oli2};
            insert oLIList;

        AfterBasketClonePcCreatedHandler afterBasket = new AfterBasketClonePcCreatedHandler();
        afterBasket.processSiteSQForBasketClone(basket);
     
    }
    
    static testMethod void testExecute(){
        AfterBasketClonePcCreatedHandler afterBasket = new AfterBasketClonePcCreatedHandler();
        
        //null check
        afterBasket.execute(null,null);
        
        //csbb.ProductConfigurationObservable observable = (csbb.ProductConfigurationObservable);
        //afterBasket.execute('basketClone',null);

    }  */

    
    public static testMethod void processTransitionDataCloneForClonedPC() {
   
       //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);

        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        System.assertNotEquals(null,opp);

        //Create Basket Original
        cscfga__Product_Basket__c basketOr = ProductTestFactory.buildEmptyBasket();
        basketOr.csbb__Account__c = acc.id;
        basketOr.cscfga__Opportunity__c = opp.id;
        basketOr.Name = 'basketOriginal';
        insert basketOr;
    
           //Create Basket Cloned
        cscfga__Product_Basket__c basketCl = ProductTestFactory.buildEmptyBasket();
        basketCl.csbb__Account__c = acc.id;
        basketCl.cscfga__Opportunity__c = opp.id;
        basketCl.Name = 'basketCloned';
        insert basketCl;

        cscfga__Product_Configuration__c PCOrig = ProductTestService.createProductConfiguration();
        PCOrig.cscfga__Product_Basket__c = basketOr.id;
        PCOrig.cscfga__Description__c = 'test Description ';
        PCOrig.cscfga__Contract_Term__c = 36;
        PCOrig.cscfga__Configuration_Status__c = 'Valid';
        PCOrig.name = 'IP Site';
        update PCOrig;
        
         //Cloned Basket PC
        cscfga__Product_Configuration__c pcCloned = ProductTestService.createProductConfiguration();
        pcCloned.cscfga__Product_Basket__c = basketCl.id;
        pcCloned.cscfga__Description__c = 'test Description ';
        pcCloned.cscfga__Contract_Term__c = 36;
        pcCloned.cscfga__Configuration_Status__c = 'Valid';
        pcCloned.name = 'IP Site';    
        pcCloned.PC_cloned_from_Id__c = PCOrig.id;
        update pcCloned;
        //Cloned Basket PCR 
         csbb__Product_Configuration_Request__c pcrCl = new csbb__Product_Configuration_Request__c();
        // pcrCl.csbb__Product_Category__c = pc.id;
        pcrCl.csbb__Product_Configuration__c = pcCloned.id;
        insert pcrCl;
        //Original Basket PCR 

        csbb__Product_Configuration_Request__c pcrOr = new csbb__Product_Configuration_Request__c();
         pcrOr.csbb__Product_Configuration__c = PCOrig.id;
        insert pcrOr;
    
        Attachment attOr = new Attachment ();
        attOr.parentID  = pcrOr.id ;
        attOr.Name = 'TransitionJSONData.json';
        attOr.Body = Blob.valueof ('Attachment Body');
        insert attOr;
        AfterBasketClonePcCreatedHandler aftBasketClone = new AfterBasketClonePcCreatedHandler();
        aftBasketClone.processTransitionDataCloneForClonedPC(basketCl.id);
    }
}