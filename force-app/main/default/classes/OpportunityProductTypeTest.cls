@isTest
public class OpportunityProductTypeTest {
  
  @testsetup static void testdata() {
    Account acc = AccountTestFactory.buildAccount('Test Account') ;
    acc.Customer_Status__c = 'ACTIVE';
    insert acc;
    System.assertNotEquals(null, acc);

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

    cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
    basket.csbb__Account__c = acc.id;
    basket.cscfga__Opportunity__c = opp.id;
    basket.Name = 'basket1';
    basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
    basket.cscfga__total_contract_value__c = 10000;
    insert basket;
  }

  @isTest
  static void testProductTypeInstance(){
     OpportunityProductType type = OpportunityProductType.getProductTypeInstance(null);
     System.assertEquals(null, type);

     type = OpportunityProductType.getProductTypeInstance('');
     System.assertEquals(null, type);

     type = OpportunityProductType.getProductTypeInstance('Modular');
     System.assertNotEquals(null, type);
  }
    
  @isTest
  static void testIfModular(){
    Opportunity opp = [select id, pricebook2id FROM Opportunity];
    cscfga__Product_Basket__c basket = [SELECT Id, Name, cscfga__opportunity__c, cscfga__Opportunity__r.Product_Type__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c = :opp.id ];
    Boolean isModular = OpportunityProductType.isModularProductType(basket);
    System.assert(isModular);
  }

}