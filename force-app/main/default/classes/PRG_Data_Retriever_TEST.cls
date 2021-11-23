@istest
public class PRG_Data_Retriever_TEST {

    @istest
    public static void TestMethod1(){

         cspmb__Pricing_Rule__c pr = new cspmb__Pricing_Rule__c();   
         pr.Name = 'BasePrices';
         pr.cspmb__pricing_rule_code__c = 'BasePrices';
         pr.cspmb__description__c = 'BasePrices';
         insert pr;


        cspmb__Pricing_Rule_Group__c pg = new cspmb__Pricing_Rule_Group__c();
        pg.Name = 'PG2';
        pg.cspmb__pricing_rule_group_code__c = 'PG2';
        pg.cspmb__user_selectable__c = true;
        pg.cspmb__priority__c = 1;
        pg.csfam__standard_price_book__c = true;
        insert pg;

        cspmb__Pricing_Rule_Group_Rule_Association__c PriceRuleAssoc = new cspmb__Pricing_Rule_Group_Rule_Association__c();
        PriceRuleAssoc.cspmb__pricing_rule_group__c = pg.Id;
        PriceRuleAssoc.cspmb__pricing_rule__c = pr.Id;
        insert PriceRuleAssoc;

    	Map<String,Object> mps = new Map<String,object>();
    	mps.put(PriceRuleAssoc.Name, PriceRuleAssoc);
        Test.startTest();
        PRG_Data_Retriever.getData(mps); 
        Test.stopTest();
        List<cspmb__Pricing_Rule_Group_Rule_Association__c> PriceRuleAssocList = [SELECT name,cspmb__pricing_rule_group__c FROM cspmb__Pricing_Rule_Group_Rule_Association__c];

        System.assertEquals(Pg.Id ,PriceRuleAssocList[0].cspmb__pricing_rule_group__c);

    }
}