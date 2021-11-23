/*************************************************************************************************
Name : NewBasketOverrideRedirectPgCtrlTest
Description : Test class for NewBasketOverrideRedirectPageController
***************************************************************************************************/
@isTest
public class NewBasketOverrideRedirectPgCtrlTest {
    
static testMethod void testWithOneBasket() {
        
            //Create Account 
            Account acc = AccountTestFactory.buildAccount('Test Account');
            insert acc;
            
            //Create Opportunity
             Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
             insert opp;
                        
            Test.startTest();
            cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(basket);
            NewBasketOverrideRedirectPageController bktRedirect = new NewBasketOverrideRedirectPageController(sc);
        
        PageReference pageRef = Page.NewBasketOverrideRedirectPage;
        NewBasketOverrideRedirectPageController.oppId = ''+opp.Id;
        pageRef.getParameters().put('test_lkid', String.valueOf(opp.Id));
        
        Test.setCurrentPage(pageRef);
        bktRedirect.init();
        cscfga__Product_Basket__c basket1 = NewBasketOverrideRedirectPageController.basket;
        //opportunity has no basket, thus new basket is created and pagereference is returned.
        //Page Reference is not null
        System.AssertNotEquals(null,basket1);
        
         Test.stopTest();
      }
    
      
 static testMethod void testWithMoreThanOneBasketNonModular() {
        
            //Create Account
            Account acc = AccountTestFactory.buildAccount('Test Account');
            insert acc;
            
            //Create Opportunity
             Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
             opp.Product_Type__c = 'Non Modular';
             insert opp;
                        
            //Create Basket and link to Opportunity
              cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
     		  basket.cscfga__Products_In_Basket__c = '[Current Product Catalog]';
              basket.cscfga__Opportunity__c = opp.id;
              insert basket;
     
            Test.startTest();
            cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(basket2);
            NewBasketOverrideRedirectPageController bktRedirect = new NewBasketOverrideRedirectPageController(sc);
            PageReference pageRef;
            cscfga__Product_Basket__c basket1;
            Boolean isNotError;
            try
            {
              pageRef = Page.NewBasketOverrideRedirectPage;
              NewBasketOverrideRedirectPageController.oppId = ''+opp.Id;
              pageRef.getParameters().put('test_lkid', String.valueOf(opp.Id));
              Test.setCurrentPage(pageRef);
              basket1 = NewBasketOverrideRedirectPageController.basket;
                      
              bktRedirect.init();
              isNotError = NewBasketOverrideRedirectPageController.isNotError;  
            }  
            Catch(Exception e)
            {
                //Opportunity already has a basket and new button is clicked. Page throws error and returns null reference
                System.AssertEquals(null,basket1);
                System.assertEquals(false, isNotError);
                List<Apexpages.Message> msgs = ApexPages.getMessages();
                boolean msgThrown = false;
                for(Apexpages.Message msg:msgs){
                      if (msg.getDetail().contains('Only one Basket can be created for opportunity')) 
                          msgThrown = true;
                }

                system.assert(msgThrown);
            }
         Test.stopTest();
      }
      
      static testMethod void testWithMoreThanOneBasketProductTypeNull() {
        
            //Create Account
            Account acc = AccountTestFactory.buildAccount('Test Account');
            insert acc;
            
            //Create Opportunity
             Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
             opp.Product_Type__c = '';
             insert opp;
                        
            //Create Basket and link to Opportunity
              cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
     		  basket.cscfga__Products_In_Basket__c = '[Current Product Catalog]';
              basket.cscfga__Opportunity__c = opp.id;
              insert basket;
     
            Test.startTest();
            cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(basket2);
            NewBasketOverrideRedirectPageController bktRedirect = new NewBasketOverrideRedirectPageController(sc);
            PageReference pageRef;
            cscfga__Product_Basket__c basket1;
            Boolean isNotError;
            try
            {
              pageRef = Page.NewBasketOverrideRedirectPage;
              NewBasketOverrideRedirectPageController.oppId = ''+opp.Id;
              pageRef.getParameters().put('test_lkid', String.valueOf(opp.Id));
              Test.setCurrentPage(pageRef);
              basket1 = NewBasketOverrideRedirectPageController.basket;
                      
              bktRedirect.init();
              isNotError = NewBasketOverrideRedirectPageController.isNotError;  
            }  
            Catch(Exception e)
            {
                //Opportunity already has a basket and new button is clicked. Page throws error and returns null reference
                System.AssertEquals(null,basket1);
                System.assertEquals(false, isNotError);
                List<Apexpages.Message> msgs = ApexPages.getMessages();
                boolean msgThrown = false;
                for(Apexpages.Message msg:msgs){
                      if (msg.getDetail().contains('Only one Basket can be created for opportunity')) 
                          msgThrown = true;
                }

                system.assert(msgThrown);
            }
         Test.stopTest();
      }
    static testMethod void testWithMoreThanOneBasketModular() {
        
            //Create Account
            Account acc = AccountTestFactory.buildAccount('Test Account');
            insert acc;
            
            //Create Opportunity
             Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
             opp.Product_Type__c = 'Modular';
             insert opp;
                        
            //Create Basket and link to Opportunity
              cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
     		  basket.cscfga__Products_In_Basket__c = '[Current Product Catalog]';
              basket.cscfga__Opportunity__c = opp.id;
              insert basket;
     
            Test.startTest();
            cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(basket2);
            NewBasketOverrideRedirectPageController bktRedirect = new NewBasketOverrideRedirectPageController(sc);
        
        PageReference pageRef = Page.NewBasketOverrideRedirectPage;
        NewBasketOverrideRedirectPageController.oppId = ''+opp.Id;
        pageRef.getParameters().put('test_lkid', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        bktRedirect.init();
        cscfga__Product_Basket__c basket1 = NewBasketOverrideRedirectPageController.basket;
        system.debug('******basket1 : '+basket1);
        //opportunity has one basket and opportunity is modular, thus new basket is created and pagereference is returned.
        //Page Reference is not null
        System.AssertNotEquals(null,basket1);
        Test.stopTest();
    }
    //DIGI-721
    static testMethod void testBasketCreationForDelegatedPricing() {
        
            //Create Account
            Account acc = AccountTestFactory.buildAccount('Test Account');
            insert acc;
            
            //Create Opportunity
             Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
             opp.Product_Type__c = 'Modular';
        	 opp.Pricing_Method__c = 'Delegated Pricing';
        	 opp.RecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        	 insert opp;
                        
     
            Test.startTest();
            cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(basket2);
            NewBasketOverrideRedirectPageController bktRedirect = new NewBasketOverrideRedirectPageController(sc);
        
        PageReference pageRef = Page.NewBasketOverrideRedirectPage;
        NewBasketOverrideRedirectPageController.oppId = ''+opp.Id;
        pageRef.getParameters().put('test_lkid', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        bktRedirect.init();
        List<cscfga__Product_Basket__c> basket1 =[Select Id from cscfga__Product_Basket__c
                                            Where cscfga__Opportunity__c=:opp.Id];// NewBasketOverrideRedirectPageController.basket;
        system.debug('******basket1 : '+basket1);
        //opportunity has no basket and opportunity is modular with Record.Developername = 'Defined' & PricingMethod = Delegated Pricing
        //Now as per check in main class, new basket will not be created
        System.Assert(basket1.isEmpty());
        Test.stopTest();
    }
    static testMethod void testSync() {
        
            //Create Account
            Account acc = AccountTestFactory.buildAccount('Test Account');
            insert acc;
            
            //Create Opportunity
             Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
             insert opp;
                        
            //Create Basket and link to Opportunity
              cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
              basket.cscfga__Opportunity__c = opp.id;
              insert basket;
              Boolean isOppRedirect;
            Test.startTest();
              PageReference pageRef = Page.NewBasketOverrideRedirectPage;
              Test.setCurrentPage(pageRef);
              pageRef.getParameters().put('test_lkid', String.valueOf(opp.Id));
              pageRef.getParameters().put('linkedId', String.valueOf(opp.Id));
              ApexPages.StandardController sc = new ApexPages.StandardController(basket);
              NewBasketOverrideRedirectPageController bktRedirect = new NewBasketOverrideRedirectPageController(sc);
              NewBasketOverrideRedirectPageController.oppId = ''+opp.Id;
              NewBasketOverrideRedirectPageController.basket = basket;
                      
              bktRedirect.init();
              isOppRedirect = NewBasketOverrideRedirectPageController.isOppRedirect;
               
         Test.stopTest();
              System.AssertNotEquals(null,basket);
              System.AssertEquals(true,isOppRedirect);
      }

}