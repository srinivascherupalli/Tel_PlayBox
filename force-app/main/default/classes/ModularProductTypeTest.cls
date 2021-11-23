/********************************************************
Class Name      :   ModularProductTypeTest
Main Class      :   ModularProductType
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
2.        Laxmi Rahate      08/04/2020    EDGE-131729 Method Name change 
3.        Shubhi V      25/05/2020    fdr test class fixes       
********************************************************************/
@isTest
public class ModularProductTypeTest {
    @testsetup static void testdata() {
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
    opp.Product_Domain__c='MOBILES';
    opp.description='test description';
    opp.Billing_Solution__c = 'In Contract';
    opp.Pricing_Method__c='PET';
    opp.Product_Type__c = 'Modular';
    opp.Won_Lost_Reason__c='Contractual Terms';
    opp.Competitor__c='AAPT';
    insert opp;

    Contact c = new Contact();
    c.FirstName = 'Testing';
    c.LastName = 'Test';
    c.AccountId = acc.id;
    insert c;

    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = c.Id;
    ocr.OpportunityId = opp.Id;
    ocr.IsPrimary = TRUE;
    ocr.Role = 'Decision Maker';
    insert ocr;

    cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
    basket.csbb__Account__c = acc.id;
    basket.cscfga__Opportunity__c = opp.id;
    basket.Name = 'basket1';
    basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
    basket.cscfga__total_contract_value__c = 10000;
    insert basket;

    cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
    config.Name = System.Label.Label_CWP;
    config.cscfga__Product_Basket__c = basket.id;
    config.cscfga__Description__c = 'test Description ';
    config.cscfga__Contract_Term__c = 36;

    cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
    config1.cscfga__Product_Basket__c = basket.id;
    config1.cscfga__Description__c = 'test Description 1';
    config1.cscfga__Contract_Term__c = 24;

    cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
    config2.cscfga__Product_Basket__c = basket.id;
    config2.cscfga__Description__c = 'test Description 2';
    config2.cscfga__Contract_Term__c = 12;

    List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c> {config, config1, config2};
    update configList;

    
    cscfga__Attribute__c attr0;
    //Creation of Attributes with different attrbiutes Name and values.
    List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
    for (cscfga__Product_Configuration__c config0 : configList) {
      attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config0.id);
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
    }
    insert attList;

    //EDGE-131729  - Data Set UP
    cscfga__Attribute_Definition__c attrDefin = ProductTestFactory.buildAttributeDefinition ('RC',config.cscfga__Product_Definition__c); 
  insert attrDefin;
        
    cscfga__Attribute_Field_Definition__c attrFieldDefin = ProductTestFactory.buildAttributeFieldDefinition ('IncrementalRevenue',attrDefin.id, '1000'); 
  insert attrFieldDefin;
    //EDGE-131729 - Data Set up ENd
    List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
    for (cscfga__Attribute__c attr : attList) {
      if (attr.Name == 'Product')
        newattrList.add(attr);
    }

    OpportunityLineItem oli = new OpportunityLineItem(
      pricebookentryid = pbe.Id, 
      TotalPrice = 2100, 
      Quantity = 2,
      OpportunityID = basket.cscfga__Opportunity__c, 
      Description = configList[0].cscfga__Description__c,
      cscfga__Attribute__c = attList[0].id, 
      Product_Status__c = 'Lost', 
      Product_Name__c = 'test prod',
      Recurring_Price__c = 0,
      One_Off_Price__c = 0,
      New_Income_Revenue__c = null
    );
        insert oli;

    OpportunityLineItem oli1 = new OpportunityLineItem(pricebookentryid = pbe.Id, TotalPrice = 3000, Quantity = 3,
        OpportunityID = basket.cscfga__Opportunity__c, Description = configList[1].cscfga__Description__c,
        cscfga__Attribute__c = attList[1].id, Product_Status__c = 'won', Product_Name__c = 'test1',
        Recurring_Price__c = 2000,
      One_Off_Price__c = 100,
      New_Income_Revenue__c = null);
        insert oli1;


    CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration');
    customSetting.Name = 'CommercialConfiguration';
    customSetting.External_Id__c = 'CCO_T_1';
    customSetting.Opportunity_Stage__c = 'Develop';    
    insert customSetting;

    CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote');
    customSetting1.Name = 'Quote';
    customSetting1.External_Id__c = 'CCO_T_2';
    customSetting1.Opportunity_Stage__c = 'Develop';   
    insert customSetting1;

    CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Contract Accepted');
    customSetting2.Name = 'ContractAccepted';
    customSetting2.External_Id__c = 'CCO_T_3';
    customSetting2.Opportunity_Stage__c = 'Develop';   
    insert customSetting2;
  }
  
  static testMethod void testupdateOpportunityLineItem(){
      OpportunityLineItem oli1 = [select id,New_Income_Revenue__c,Recurring_Price__c,Quantity,One_Off_Price__c,cscfga__Attribute__r.name,cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c,cscfga__Attribute__r.cscfga__Product_Configuration__r.OfferName__c,Incremental_Revenue__c from OpportunityLineItem where Product_Status__c = 'won'];
      //CHanges for EDGE-131729
      Opportunity Opp =[Select name,CloseDate,Product_Type__c,Pricing_Method__c,StageName from Opportunity where name = 'TestOpp'];

      List<cscfga__Attribute_Field__c> attributeFieldList = [select id, cscfga__Attribute__c,  
                                                             cscfga__Value__c from cscfga__Attribute_Field__c 
                                                             where 
                                                             cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c =:Opp.id  
                                                             and name = 'IncrementalRevenue'];
      
      Map<String, String> incrRevenueMap = new Map<String, String>();
      for (cscfga__Attribute_Field__c attributeField : attributeFieldList ){
          incrRevenueMap.put (attributeField.cscfga__Attribute__c, attributeField.cscfga__Value__c);
      } 
      // Changes END - EDGE-131729
      ModularProductType MPT5 = new ModularProductType();
      MPT5.updateOpportunityLineItem(oli1,incrRevenueMap);
      Test.startTest();
      System.assertNotEquals(null,oli1.New_Income_Revenue__c);
      System.assertEquals(oli1.Avg_Annualised_Revenue__c,oli1.New_Income_Revenue__c); 
      
      OpportunityLineItem oli10 = [select id,New_Income_Revenue__c,Recurring_Price__c,Quantity,One_Off_Price__c,cscfga__Attribute__r.name,cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c,cscfga__Attribute__r.cscfga__Product_Configuration__r.OfferName__c,Incremental_Revenue__c from opportunityLineitem where Product_Status__c = 'Lost'];
      //ModularProductType MPT5 = new ModularProductType();
      oli10.Once_Off_Revenue__c=null;
      oli10.New_Income_Revenue__c=100;
      update oli10;
       //EDGE-131729 - Added Map as additional Paremeter in Method Call
      OpportunityLineItem returnedOLI = MPT5.updateOpportunityLineItem(oli10,incrRevenueMap);
      System.assertEquals(100,returnedOLI.New_Income_Revenue__c);
      
      oli10.New_Income_Revenue__c = null;
      update oli10;
      //EDGE-131729 - Added Map as additional Paremeter in Method Call

      MPT5.updateOpportunityLineItem(oli10,incrRevenueMap);
      System.assertEquals(oli10.Incremental_Revenue__c,oli10.Once_Off_Revenue__c);
      
      oli10.Once_Off_Revenue__c = null;
      oli10.New_Income_Revenue__c = 100;
      update oli10;
      //EDGE-131729 - Added Map as additional Paremeter in Method Call

      returnedOLI = MPT5.updateOpportunityLineItem(oli10,incrRevenueMap);
      System.assertEquals(100,returnedOLI.New_Income_Revenue__c);
    
  //    oli1.cscfga__Attribute__r.name = 'NoEarlyTerminationCharge';
  //    oli10.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c = 100;
  //    oli10.UnitPrice = 100;
      
      Test.stopTest();
  }
    
  static testMethod void testRefreshOffer(){
      List<cscfga__Product_Configuration__c> configIds = New List<cscfga__Product_Configuration__c> (); 
        List<ID> pcIds = New List<ID> ();
      
      cscfga__Configuration_Offer__c offerDef = new cscfga__Configuration_Offer__c();
        offerDef.Name = 'Unified Communication Enterprise';
        offerDef.cscfga__Description__c ='Description';
        insert offerDef;
      
      cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c();
        prodConfig.Name = 'Communication Enterprise';
        prodConfig.cscfga__Product_Basket__c = null;
        prodConfig.Name  = 'testConfig';
        prodConfig.cscfga__Configuration_Offer__c = offerDef.Id;
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        insert prodConfig;
        
        configIds.add(prodConfig);
        pcIds.add(prodConfig.Id);


        Test.startTest();
        String productType = 'Modular';
        ModularProductType modularType = new ModularProductType();
      modularType.refreshOffer(productType);
        cscfga__Product_Configuration__c prodConfig1 = [Select id, Name from cscfga__Product_Configuration__c where name = 'testConfig' LIMIT 1];  
        OfferAutoRefresh.offerRefresh('Modular');
        System.assert(prodConfig1 != null);
        Test.stopTest();
  }
  
  
  static testMethod void testModularProductType(){
      Opportunity opp = [select id, pricebook2id FROM Opportunity];
      cscfga__Product_Basket__c basket = [SELECT Id, Name, cscfga__opportunity__c, cscfga__total_contract_value__c, csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c = :opp.id ];
      Test.startTest();
      ModularProductType.updateOpportunityInfo(basket);
      
      ModularProductType.updateOpportunityInfo(basket);
 
      Opportunity opt = [Select amount from Opportunity where id=:opp.id];
     System.assertEquals(5100,opt.Amount);
      
      basket.csordtelcoa__Basket_Stage__c = 'Quote';
      update basket;
      ModularProductType.updateOpportunityInfo(basket);
  
       basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
      update basket;
      ModularProductType.updateOpportunityInfo(basket);

    Test.stopTest(); // updated by shubhi for fdr fixes 
      
  }
}