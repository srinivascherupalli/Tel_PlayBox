/*
* @Desc : Basket Utility Test class
* @Jira : DIGI-518
*/
@isTest
public class BSK_UtilitiesTest {
    @testsetup 
    static void testdata() {
        Account acct = AccountTestFactory.buildAccount('TestAcct1');
        insert acct;
        cscfga__Configuration_Offer__c offerDef = new cscfga__Configuration_Offer__c();
        offerDef.Name = 'TestOffer';
        offerDef.cscfga__Description__c ='Description';
        insert offerDef;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Product Def1', 'Core Plan');
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000423';
        insert prodDef;
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c(csordtelcoa__Change_Type__c = '', name = 'Test Basket');
        insert prodBasket;
        cscfga__Product_Configuration__c prodConfig1 = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig1.cscfga__Product_Basket__c = prodBasket.Id;        
        insert prodConfig1;
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.cscfga__Product_Basket__c = prodBasket.Id;
        prodConfig.Commercial_Config__c = 'Yes';
        prodConfig.Offer_Reference__c=offerDef.Id;
        prodConfig.cscfga__Parent_Configuration__c=prodConfig1.Id;
        insert prodConfig;
        cscfga__Attribute__c attr=new cscfga__Attribute__c();
        attr.name='CaseStatus';
        attr.cscfga__Product_Configuration__c=prodConfig.Id;
        attr.cscfga__Value__c='1234';
        insert attr;
    }
    @isTest
    static void getOffersInBasketTest(){
        //List<String> productSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ProductSpeccificationCode'));
       
        Set<String> offers = null;
        Set<String> offers1 = null;
        cscfga__Product_Basket__c prdBsk=[SELECT id,name FROM cscfga__Product_Basket__c LIMIT 1];
        
        Test.startTest();       
        offers=BSK_Utilities.getOffersInBasket(prdBsk.Id);
        offers1=BSK_Utilities.getOffersInBasket(null);
        Test.stopTest();
        System.assertNotEquals(null,offers1);        
        System.assertNotEquals(null,offers);
        }       
        
    @isTest
    static void getBasketTest(){
        cscfga__Product_Basket__c prdBsk=[SELECT id,name FROM cscfga__Product_Basket__c LIMIT 1];
        
        Test.startTest();       
        cscfga__Product_Basket__c bsk=BSK_Utilities.getBasket(prdBsk.Id);
        Test.stopTest();
        
        System.assertNotEquals(null,bsk);
    }

   /* @isTest
    static void logExceptionTest(){
        BSK_Utilities.logException('getOffersInBasketTest','testid','test','getOffersInBasketTest failed');       
    }*/

    @isTest
    static void doesBasketHaveOfferTest1(){
        cscfga__Product_Basket__c prdBsk=[SELECT id,name FROM cscfga__Product_Basket__c LIMIT 1];
        cscfga__Configuration_Offer__c prdOffer=[SELECT id,name FROM cscfga__Configuration_Offer__c LIMIT 1];
        Boolean haveOffer = false;
        Boolean haveOffer1 = false;
        Boolean haveOffer2 = false;

        Test.startTest();
        haveOffer = BSK_Utilities.doesBasketHaveOffer(prdBsk,prdOffer.Name);
        haveOffer1 = BSK_Utilities.doesBasketHaveOffer(null,null);
        haveOffer2 = BSK_Utilities.doesBasketHaveOffer(prdBsk,'wrong_name');
        Test.stopTest();
        System.assertEquals(false,haveOffer1);
        System.assertEquals(false,haveOffer2);
        System.assertEquals(true,haveOffer);
    }
}