/********************************************************
Class Name      :   NonModularProductTypeTest
Main Class      :   NonModularProductType
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
2.			  Laxmi Rahate			08/04/2020		EDGE-131729 Method Name change 
********************************************************************/
@isTest
public class NonModularProductTypeTest {
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
    //opp.Contract_Type__c='Master Service Agreement';
    opp.Pricing_Method__c='PET';
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

    //Creation of Attributes with different attrbiutes Name and values.
    List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
    for (cscfga__Product_Configuration__c config0 : configList) {
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
    }
    insert attList;

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
      Recurring_Price__c = 2000,
      One_Off_Price__c = 100,
      New_Income_Revenue__c = null
    );

    OpportunityLineItem oli1 = new OpportunityLineItem(pricebookentryid = pbe.Id, TotalPrice = 3000, Quantity = 3,
        OpportunityID = basket.cscfga__Opportunity__c, Description = configList[1].cscfga__Description__c,
        cscfga__Attribute__c = attList[1].id, Product_Status__c = 'won', Product_Name__c = 'test1',
        Recurring_Price__c = 2000,
      One_Off_Price__c = 100,
      New_Income_Revenue__c = null);

    OpportunityLineItem oli2 = new OpportunityLineItem(pricebookentryid = pbe.Id, TotalPrice = 4000, Quantity = 4,
        OpportunityID = basket.cscfga__Opportunity__c, Description = configList[2].cscfga__Description__c,
        cscfga__Attribute__c = attList[2].id, Product_Status__c = 'withdrawn', Product_Name__c = 'test2',
      Recurring_Price__c = 2000,
      One_Off_Price__c = 100,
      New_Income_Revenue__c = null);

    List<OpportunityLineItem> oLIList = new List<OpportunityLineItem> {oli, oli1, oli2};
    insert oLIList;

    CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'CommercialConfiguration');
    customSetting.Name = 'CommercialConfiguration';
    customSetting.External_Id__c = 'CCO_T_1';
    insert customSetting;

    CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote');
    customSetting1.Name = 'Quote';
    customSetting1.External_Id__c = 'CCO_T_2';
    insert customSetting1;

    CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'ContractAccepted');
    customSetting2.Name = 'ContractAccepted';
    customSetting2.External_Id__c = 'CCO_T_3';
    insert customSetting2;
  }
  
  static testMethod void testNonModularProductType(){
      Opportunity opp = [SELECT id, pricebook2id FROM Opportunity];
      cscfga__Product_Basket__c basket = [
                                         SELECT id, cscfga__Opportunity__c, cscfga__Opportunity__r.Product_Type__c,
                                         (
                                           SELECT id, cscfga__Product_Basket__c, cscfga__Description__c
                                           FROM cscfga__Product_Configurations__r
                                         )
                                         FROM cscfga__Product_Basket__c
                                         WHERE cscfga__Opportunity__c = :opp.id
                                       ];
     Map <String,String> incrRevenueMap = new Map <String,String>(); //EDGE-131729 
 
      OpportunityLineItem oli = new OpportunityLineItem();
      oli = [
            SELECT id, Name, SRM__c, Product_Name__c, Quantity, pricebookentryid, Acquisition_Revenue__c, Renewal_Revenue__c, Current_Revenue__c,
            Incremental_Revenue__c, Avg_Annualised_Revenue__c, Competitor__c, Contract_Terms__c, OpportunityID, Description, Product_Status__c,
            unitPrice, cscfga__Attribute__c, cscfga__Attribute__r.cscfga__Product_Configuration__c,cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c
            FROM  OpportunityLineItem
            WHERE OpportunityID = : basket.cscfga__Opportunity__c LIMIT 1
          ];
	  oli.Product_Status__c = 'Lost';
      update oli;
      
      NonModularProductType nonModularType = new NonModularProductType();
      Test.startTest();

      nonModularType.updateOpportunityLineItem(oli,incrRevenueMap); //EDGE-131729 - Added Map as additional Paremeter in Method Call

      System.assertEquals(oli.UnitPrice,0.00);
      
      oli.Product_Status__c = 'Won';
      update oli;
      nonModularType.updateOpportunityLineItem(oli,incrRevenueMap);
      System.assertNotEquals(oli.UnitPrice,0.00);
      
      String offer = 'FIXED TELEPHONY';
      System.assertNotEquals(null,nonModularType.refreshOffer(offer));
      Test.stopTest();
      
  }
}