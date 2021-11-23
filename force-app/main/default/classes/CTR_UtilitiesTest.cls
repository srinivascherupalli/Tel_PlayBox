/*
* @Desc : CTR Utility test class
* @Jira : DIGI-518
*/
@isTest
private class CTR_UtilitiesTest {
    @testsetup 
    static void testdata() {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        insert basket;
    }
    
    @isTest
    public static void getContractGenerationSettingsTest(){
        String hName = [SELECT DeveloperName FROM Contract_Generation_Setting__mdt LIMIT 1].DeveloperName;
        Test.startTest();
        Contract_Generation_Setting__mdt cgs = CTR_Utilities.getContractGenerationSettings(hName);
        Test.stopTest();
        System.assertNotEquals(null, cgs);
    }
    
    @isTest
    public static void checkifContractExistsForAccountTest(){
        cscfga__Product_Basket__c prdBsk=[SELECT id,name FROM cscfga__Product_Basket__c LIMIT 1];
        Test.startTest();
        Boolean cgs = CTR_Utilities.checkifContractExistsForAccount(prdBsk.id, '');
        Test.stopTest();
        System.assertEquals(false, cgs);
    }
}