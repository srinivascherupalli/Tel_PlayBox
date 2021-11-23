@isTest
private class ProductUtilTest
{
    /**
* Tests performAction method
*/
    @isTest 
    static void getFulfillmentAttributesByServicesTest01() {
        
        Account acc = new Account(Name = 'Test Account');
        csord__Order__c order = ProductTestService.getNewOrderWithRealAttributeDataAndMultipleServices(acc);
        cscfga__Product_Configuration__c config = [select id FROM cscfga__Product_Configuration__c where name = 'test config'];
        csord__Subscription__c parentSubs = [select id FROM csord__Subscription__c where name = 'Test Parent Subs'];
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        csord__Service__c ser = [select id,csordtelcoa__Product_Configuration__c, csord__Subscription__c, Parent_reference__c FROM csord__Service__c where name = 'Test Parent Service'];
        
        Map<id,csord__Service__c> servLst = new Map<id,csord__Service__c>();
        servLst.put(ser.id, ser);
        
        System.assertEquals(ser.csordtelcoa__Product_Configuration__c!=null, true);
        
        Test.startTest();
        
        Map<Id, Map<String, String>> retVal = ProductUtil.getFulfillmentAttributesByServices(servLst);
        cscfga__Product_Basket__c basket1=ProductUtil.getBasket(basket.id);
        
        Test.stopTest();
        
        System.assertEquals(retVal.size(),1);
        System.assertEquals(retVal.values().get(0).size(),7);
        
        
    }
    
    static void createCustomSettingEnrichment() {
        
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(MarketableOfferList__c = 'test config,Business IP'); 
        customSetting.Name = 'MarketableOfferList';
        insert customSetting;
    }
    
    //Added by Pooja to fix the coverage of this class.
    @isTest
    static void refNumPatternCheckTest(){
        Account acc = ProductTestService.getNewAccount('Test Account');
        Opportunity opp1 = ProductTestFactory.getOpportunityBasic(acc);
        opp1.StageName = 'Develop';
        opp1.Product_Type__c = 'Modular';
        opp1.Name = 'TestingOpp1';
        insert opp1;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp1.id;
        basket.Name = 'OutgoingBasket';
        basket.referencenumber__c ='TNC000000001';
        basket.cscfga__Basket_Status__c = 'valid';
        basket.csordtelcoa__Basket_Stage__c ='Draft';
        insert basket;
        
        Test.startTest();
        string res = ProductUtil.refNumPatternCheck(basket.referencenumber__c);
        system.assertEquals('Ok', res);
        Test.stopTest();
    }
    
}