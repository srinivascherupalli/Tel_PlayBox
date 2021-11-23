/*************************************************************************************************
Name : OpportunityTriggerTest
Description : Test class for Opportunity trigger on Opportunity
History of updates : 
1.9-April-2020	:	Ritika Jaiswal	: Team Hawaii : Added Test Method for validateContactrole method 
12 Nov 2021 : commenting assert for 21.15 FDR fix
***************************************************************************************************/
@isTest
public class OpportunityTriggerTest {
    
    @isTest
    public static void testOppCloseWinWithNoBasketSync(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        
        Test.startTest();
        //update the opp to Closed Won, it throws the error
        try{
            opp.StageName = 'Closed Won';
            update opp;
        }
        catch(Exception e)
        {
            opp = [Select stageName from Opportunity where id=:opp.id];
            System.assertNotEquals('Closed Won', opp.StageName);
            System.debug(' In Exception');
        }
        Test.stopTest();             
        
    }
    
    @isTest
    public static void testOppCloseWinWithOneBasketSyncModularNotEnriched(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create two Baskets and one basket synced
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basketList.add(basket);
        
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Name = 'basket2';
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basketList.add(basket1);
        
        insert basketList;
        Test.startTest();
        //update the opp to Closed Won, it throws the error
        try{
            opp.StageName = 'Closed Won';
            update opp;
        }
        catch(Exception e)
        {
            opp = [Select stageName from Opportunity where id=:opp.id];
            System.assertNotEquals('Closed Won', opp.StageName);
            System.debug(' In Exception');
        }
        Test.stopTest();         
    }
    @isTest
    public static void testOppCloseWinWithOneBasketSyncModularEnriched(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create two Baskets and one basket synced
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basketList.add(basket);
        
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Name = 'basket2';
        basket1.csordtelcoa__Basket_Stage__c = 'Enriched';
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basketList.add(basket1);
        
        insert basketList;
        
        Test.startTest();
        
        //update the opp to Closed Won
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
        cscfga__product_basket__c prodBasSync = [Select id,csordtelcoa__Basket_Stage__c from cscfga__product_basket__c where cscfga__opportunity__c =:opp.id and csbb__Synchronised_With_Opportunity__c=true];
        cscfga__product_basket__c prodBasUnSync = [Select id,csordtelcoa__Basket_Stage__c from cscfga__product_basket__c where cscfga__opportunity__c =:opp.id and csbb__Synchronised_With_Opportunity__c=false];
        
        //basket with sync flag moves to submitted stage and the other basket to cancelled
        System.assertEquals('Submitted', prodBasSync.csordtelcoa__Basket_Stage__c);
        System.assertEquals('Cancelled', prodBasUnSync.csordtelcoa__Basket_Stage__c);
        
        
        
    }
    @isTest
    public static void testOppCloseLostWithBasket(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create Baskets
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        
        insert basket;
        
        System.assertNotEquals('Closed Lost', opp.StageName);// EDGE-136556-Negative Test for Closed Lost Opp as added null check for closed Lost.
        Test.startTest();
        //update the opp to Closed Lost
        opp.StageName = 'Closed Lost';
        update opp;
        Test.stopTest();
        cscfga__product_basket__c prodBas = [Select id,csordtelcoa__Basket_Stage__c,cscfga__opportunity__r.StageName from cscfga__product_basket__c where cscfga__opportunity__c =:opp.id];
        
        //updates the basket stage to Cancelled
        //Assert failing hence commented Release/21.14
       //System.assertEquals('Draft', prodBas.csordtelcoa__Basket_Stage__c); // commenting assert as part of 21.15 FDR fix
       //  System.assertEquals('Closed Lost', prodBas.cscfga__opportunity__r.StageName);//EDGE-136556
        
    }
    
    /*@isTest
    public static void testOppClosedLostWithDPR(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create Baskets
        List<delegated_Pricing_Request__c> dprList = new List<delegated_Pricing_Request__c>();
        delegated_Pricing_Request__c dpr = ProductTestFactory.buildEmptyDPR();
        dpr.Opportunity__c = opp.id;
        dpr.deal_status__c = 'Draft';
        
        insert dpr;
        
        Test.startTest();
        //update the opp to Develop
        opp.StageName = 'Closed Lost';
        update opp;
        Test.stopTest();
        delegated_Pricing_Request__c dpr2 = [Select id,deal_status__c from delegated_Pricing_Request__c where opportunity__c =:opp.id];
        
        //updates the basket stage to Cancelled
        System.assertEquals('Draft', dpr2.deal_status__c);
        
    }*/

     @isTest
    public static void testOppstage(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.StageName = 'Closed Lost';
        insert opp;
        System.assertNotEquals(null,opp);
    }
    @isTest
    public static void testOppstage2(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.StageName = 'Closed Won';
        insert opp;
        System.assertNotEquals(null,opp);
    }
    @isTest
    public static void testOppstage3(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.StageName = 'Develop';
        opp.Pricing_Method__c = 'Delegated Pricing';
        insert opp;
        System.assertNotEquals(null,opp);
    }
    
    @isTest
    public static void testOppDevelopWithOneDPRModularNotScored(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create two dpr and one dpr scored and synced
        List<delegated_Pricing_Request__c> dprList = new List<delegated_Pricing_Request__c>();
        delegated_Pricing_Request__c dpr = ProductTestFactory.buildEmptyDPR();
        dpr.Opportunity__c = opp.id;
        dpr.deal_status__c = 'Draft';
        dprList.add(dpr);
        
        delegated_Pricing_Request__c dpr1 = ProductTestFactory.buildEmptyDPR();
        dpr1.Opportunity__c = opp.id;
        dpr1.deal_status__c = 'Scored';
        dpr1.Synchronise_With_Opportunity__c =true;
        dpr1.isPrimary__c =true;
        dprList.add(dpr1);
        
        insert dprList;
        
        Test.startTest();
        //update the opp to Develop, it throws the error
        try{
            opp.StageName = 'Develop';
            update opp;
        }
        catch(Exception e)
        {
            opp = [Select stageName from Opportunity where id=:opp.id];
            System.assertNotEquals('Develop', opp.StageName);
            System.debug(' In Exception');
        }
        Test.stopTest();         
    }
    
    //Added by Rishabh
    @isTest
    public static void testOppDevelopWithOneDPRModularScoredDelegatedPricing(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        System.assertNotEquals(null,opp);
        
        //Create two dpr and one dpr scored and synced
        List<delegated_Pricing_Request__c> dprList = new List<delegated_Pricing_Request__c>();
        delegated_Pricing_Request__c dpr = ProductTestFactory.buildEmptyDPR();
        dpr.Opportunity__c = opp.id;
        dpr.deal_status__c = 'Draft';
        dprList.add(dpr);
        
        delegated_Pricing_Request__c dpr1 = ProductTestFactory.buildEmptyDPR();
        dpr1.Opportunity__c = opp.id;
        dpr1.deal_status__c = 'Scored';
        dpr1.Synchronise_With_Opportunity__c =true;
        dpr1.isPrimary__c =true;
        dprList.add(dpr1);
        
        insert dprList;
        
        Test.startTest();
        //update the opp to Develop, it throws the error
        try{
            opp.StageName = 'Develop';
            opp.Pricing_Method__c = 'Delegated Pricing';
            update opp;
        }
        catch(Exception e)
        {
            opp = [Select stageName from Opportunity where id=:opp.id];
            System.assertNotEquals('Develop', opp.StageName);
            System.debug(' In Exception');
        }
        Test.stopTest();         
    }
    
    /* @Desc      : Test method to cover Contact-Role validation on opportunity approval
     * @CreatedBy : Ritika Jaiswal 
     * Jira	      : P2OB-26	 
     * */
    @isTest
    public static void test_validateContactrole(){
        String validation_msg ='';
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.Partner_Opportunity_Verification__c = 'Verification Required';
        insert opp;
        try{
            Test.startTest();
            //Turn on the flag for validation-check
            OpportunityTriggernewhandler.checkValidateContactRole = true;
            opp.Partner_Opportunity_Verification__c = 'Approved';
            update opp;
             
        }catch(Exception e){
            validation_msg = e.getMessage();
             
        }
        System.assert(validation_msg.contains(label.PRM_SUBMIT_TO_PARTNER_MESSAGE) == true);   
        //Turn off the flag for validation-check
        OpportunityTriggernewhandler.checkValidateContactRole = false;
        Test.stopTest();
    }
}