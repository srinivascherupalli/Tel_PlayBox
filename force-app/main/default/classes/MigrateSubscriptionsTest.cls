/*******************************************************************************************************
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description

1.        Vamsi               22-Feb-2021       Edge-152456 CHOWN
2.        Shubhi V            22-Feb-2021       EDGE-152457(new chown)  
3.        Jagadeswary         16/4/21           EDGE-213796    Migrate Device

===============================================================================================================================
***************************************************************************************************/

@isTest
public class MigrateSubscriptionsTest {
    
    //Edge-152456,EDGE-152457 start
    @Testsetup
    static void dataSetup(){
        
        List<Account> accList = new List<Account>();
        Account acc = AccountTestFactory.buildAccount('Test Account3');
        accList.add(acc);
        Account acc2 = AccountTestFactory.buildAccount('Test Account4');
        accList.add(acc2);
        insert accList; 
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        oppList.add(opp);
        Opportunity opp2  = ProductTestFactory.getOpportunityBasic(acc2);
        oppList.add(opp2);
        insert oppList;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basketList.add(basket);   
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.cscfga__Opportunity__c = opp2.id;
        basket2.csbb__Account__c = acc2.Id;
        basketList.add(basket2);
        insert basketList;  
        
        List<Migration_Change_Request__c> mcrList = new List<Migration_Change_Request__c>();
        Migration_Change_Request__c mcr = new Migration_Change_Request__c();
        mcr.target_account__c = acc.id;
        mcr.account_id__c = acc2.id;
        mcr.macd_basket_ids__c = basket.id+','+basket2.id;
        mcr.migration_status__c = 'Basket Created';
        mcrList.add(mcr);
        insert mcrList;

    }
  //Edge-152456,EDGE-152457 ends
   
     @isTest static void testsourceTargetSolutionsObservers(){
        List<csord__Solution__c> solnList = new List<csord__Solution__c>();
        cssdm__Solution_Definition__c soldfn = new cssdm__Solution_Definition__c();
        soldfn.Name = 'Adaptive Mobility';
        insert soldfn;
        csord__Solution__c soln = new csord__Solution__c();
        soln.csord__status__c = 'Completed';
        soln.cssdm__replaced_solution__c = null;
        soln.cssdm__Solution_Definition__c = soldfn.id;
        soln.csord__Identification__c = 'test';
        insert soln;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c();
        pd.Name = 'Adaptive Mobility';
        pd.product_Specification__c = 'test';
        pd.cscfga__Description__c = 'test';
        pd.CHown_Enabled__c = true;

        insert pd;
        Marketable_Offer__c mkd = new Marketable_Offer__c();
        mkd.Name= 'Adaptive Mobility';
        mkd.CHown_Enabled__c = true;
        mkd.offer_id__c = 'test';
        insert mkd;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
        pc.cscfga__Product_Definition__c = pd.id;
        pc.Marketable_Offer__c = mkd.id;
        insert pc;
        cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c();
        pc2.cscfga__Product_Definition__c = pd.id;
        pc2.Marketable_Offer__c = mkd.id;
        insert pc2;
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.csord__status__c = 'Active';
        sub.csord__Identification__c = 'test';
        sub.cssdm__solution_association__c = soln.id;
        sub.csordtelcoa__Product_Configuration__c = pc.id;
        insert sub;
        csord__Subscription__c sub2 = new csord__Subscription__c();
        sub2.csord__status__c = 'Active';
        sub2.csord__Identification__c = 'test';
        sub2.csordtelcoa__Product_Configuration__c = pc2.id;
        insert sub2;
        soln = [select id,csord__status__c,cssdm__replaced_solution__c,cssdm__Solution_Definition__r.Name from csord__Solution__c where id =:soln.id]; 
        solnList.add(soln);
        Map<String, Object> inputMap = new Map<String,Object>();
        inputMap.put('solutions',solnList);
        SourceSolutions sr = new SourceSolutions();
        Map<String, Object> opMap = sr.executeLogic(inputMap);
        List<csord__solution__c> edList = (List<csord__solution__c>)opMap.get('solutions');
        inputMap.put('sourceSubscriptions',new List<String>{sub.id});
        TargetSolutions tr = new TargetSolutions();
        Map<String, Object> opMap2 = tr.executeLogic(inputMap);
        
        system.assertEquals(edList.size(),1);

     }
     @isTest static void testSourceSubscriptionObservers(){
         List<csord__Solution__c> solnList = new List<csord__Solution__c>();
        cssdm__Solution_Definition__c soldfn = new cssdm__Solution_Definition__c();
        soldfn.Name = 'Adaptive Mobility';
        insert soldfn;
        csord__Solution__c soln = new csord__Solution__c();
        soln.csord__status__c = 'Completed';
        soln.cssdm__replaced_solution__c = null;
        soln.cssdm__Solution_Definition__c = soldfn.id;
        soln.csord__Identification__c = 'test';
        insert soln;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c();
        pd.Name = 'Adaptive Mobility';
        pd.product_Specification__c = 'test';
        pd.cscfga__Description__c = 'test';
        pd.CHown_Enabled__c = true;

        insert pd;
        Marketable_Offer__c mkd = new Marketable_Offer__c();
        mkd.Name= 'Adaptive Mobility';
        mkd.CHown_Enabled__c = true;
        mkd.offer_id__c = 'test';
        insert mkd;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
        pc.cscfga__Product_Definition__c = pd.id;
        pc.Marketable_Offer__c = mkd.id;
        insert pc;
        cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c();
        pc2.cscfga__Product_Definition__c = pd.id;
        pc2.Marketable_Offer__c = mkd.id;
        insert pc2;
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.csord__status__c = 'Active';
        sub.csord__Identification__c = 'test';
        sub.cssdm__solution_association__c = soln.id;
        sub.csordtelcoa__Product_Configuration__c = pc.id;
        insert sub;
        csord__Subscription__c sub2 = new csord__Subscription__c();
        sub2.csord__status__c = 'Suspended';
        sub2.csord__Identification__c = 'test';
        sub2.csordtelcoa__Product_Configuration__c = pc2.id;
        insert sub2;
        csord__Subscription__c sub3 = new csord__Subscription__c();
        sub3.csord__status__c = 'Pending';
        sub3.csord__Identification__c = 'test';
        insert sub3;
        
        
        subsList.add(sub);
        subsList.add(sub2);
        subsList.add(sub3);
        Map<String, Object> inputMap = new Map<String,Object>();
        inputMap.put('subscriptions',subsList);
        SourceSubscriptions ss = new SourceSubscriptions();
        Map<String, Object> opMap = ss.executeLogic(inputMap);
        List<csord__Subscription__c> edList = (List<csord__Subscription__c>)opMap.get('subscriptions');

        system.assertEquals(edList.size(),2);


     }
     @isTest static void testTargetAccountObservers(){
        
        List<Account> accList = [select id,isPartner from Account limit 2];
        
        Map<String, Object> inputMap = new Map<String,Object>();
        inputMap.put('accounts',accList);
        TargetAccounts ta = new TargetAccounts();
        Map<String, Object> opMap = ta.executeLogic(inputMap);
        List<Account> edList = (List<Account>)opMap.get('accounts');

        system.assertEquals(edList.size(),2);

     }
     @isTest static void testprocessBuilderObservers(){
        List<Opportunity> oppList  = [select id,AccountId from Opportunity];
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = oppList[0].id;
        basket.csbb__Account__c =  oppList[0].AccountId;
        insert basket;   
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.cscfga__Opportunity__c = oppList[1].id;
        basket2.csbb__Account__c =  oppList[1].AccountId;
        insert basket2;         
        Migration_Change_Request__c mcr = new Migration_Change_Request__c();
        mcr.target_account__c = oppList[0].AccountId;
        mcr.account_id__c = oppList[1].AccountId;
        mcr.macd_basket_ids__c = basket.id+','+basket2.id;
        insert mcr;
        List<Id> migrationIds = new List<Id>();
        migrationIds.add(mcr.id);
        MigrateSubscriptionCustomUtility.updateOpportunityFields(migrationIds);
        system.assert([select type from Opportunity where id=:oppList[0].id].type.contains('CHOWN'));

      }
      @isTest static void testBeforeMigrationSubmitObserver(){
         List<csord__Solution__c> solnList = new List<csord__Solution__c>();
         cssdm__Solution_Definition__c soldfn = new cssdm__Solution_Definition__c();
         soldfn.Name = 'Adaptive Mobility';
         insert soldfn;
         csord__Solution__c soln = new csord__Solution__c();
         soln.csord__status__c = 'Completed';
         soln.cssdm__replaced_solution__c = null;
         soln.cssdm__Solution_Definition__c = soldfn.id;
         soln.csord__Identification__c = 'test';
         insert soln;
         List<Opportunity> oppList  = [select id,AccountId from Opportunity];
            
         cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
         basket.cscfga__Opportunity__c = oppList[0].id;
         basket.csbb__Account__c = oppList[0].AccountId;
         basket.csbb__Synchronised_With_Opportunity__c = true;
         basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
         insert basket;   
         cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
         basket2.cscfga__Opportunity__c = oppList[1].id;
         basket2.csbb__Account__c = oppList[1].AccountId;
         basket2.csbb__Synchronised_With_Opportunity__c = true;
         basket2.csordtelcoa__Synchronised_with_Opportunity__c = true;
         insert basket2;         
         Migration_Change_Request__c mcr = new Migration_Change_Request__c();
         mcr.target_account__c = oppList[0].AccountId;
         mcr.account_id__c = oppList[1].AccountId;
         mcr.macd_basket_ids__c = basket.id+','+basket2.id;
         mcr.selected_source_solution_ids__c = soln.id ;
         insert mcr;

         Map<String, Object> inputMap = new Map<String, Object>();
         inputMap.put('mcrId',mcr.id);
            Test.startTest();
         BeforeMigrationSubmit ba =new BeforeMigrationSubmit();
         
         Map<String, Object> opMap = ba.executeLogic(inputMap);
         Test.stopTest();
         system.assertEquals(opMap.get('status'),true);       
         
}
       //EDGE-14125     CHOWN Quote & Contract for Adaptive Collaboration & Adaptive Collaboration Tenancy
         @isTest static void ngucEnabledforMigrtionTest(){
            List<csord__Solution__c> solnList = new List<csord__Solution__c>();
         cssdm__Solution_Definition__c soldfn = new cssdm__Solution_Definition__c();
         soldfn.Name = 'Adaptive Mobility';
         insert soldfn;
         csord__Solution__c soln = new csord__Solution__c();
         soln.csord__status__c = 'Completed';
         soln.cssdm__replaced_solution__c = null;
         soln.cssdm__Solution_Definition__c = soldfn.id;
         soln.csord__Identification__c = 'test';
         insert soln;
            List<Opportunity> oppList  = [select id,AccountId from Opportunity];
            
         cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
         basket.cscfga__Opportunity__c = oppList[0].id;
         basket.csbb__Account__c = oppList[0].AccountId;
         basket.csbb__Synchronised_With_Opportunity__c = true;
         basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
         insert basket;   
         cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
         basket2.cscfga__Opportunity__c = oppList[1].id;
         basket2.csbb__Account__c = oppList[1].AccountId;
         basket2.csbb__Synchronised_With_Opportunity__c = true;
         basket2.csordtelcoa__Synchronised_with_Opportunity__c = true;
         insert basket2;         
         Migration_Change_Request__c mcr = new Migration_Change_Request__c();
         mcr.target_account__c = oppList[0].AccountId;
         mcr.account_id__c = oppList[1].AccountId;
         mcr.macd_basket_ids__c = basket.id+','+basket2.id;
         mcr.selected_source_solution_ids__c = soln.id ;
         insert mcr;
         
         Map<String, Object> inputMap = new Map<String, Object>();
         inputMap.put('mcrId',mcr.id);        
         String mcrid = (String)inputMap.get('mcrId');         
         Test.startTest();
         boolean  isAdaptive = MigrateSubscriptionCustomUtility.checkForAdaptiveCollabTenancy(mcr);
         Test.stopTest();         
         system.assertEquals(isAdaptive,false);
         
}

    //Edge-152456,EDGE-152457 start
         @isTest static void updateBasketWithCHOWNNegative()
         {
        
        List<Migration_Change_Request__c> migrate =  [SELECT id,target_account__c,account_id__c,name from Migration_Change_Request__c where migration_status__c = 'Basket Created' LIMIT 1 ];
             List<id> ids = new List<id>();
             //ids.add(migrate[0].id);
             MigrateSubscriptionCustomUtility.updateOpportunityFields(ids);
      //system.assert([SELECT id,csbb__Account__r.id,BasketType__c from cscfga__Product_Basket__c where csbb__Account__r.id =: migrate[0].target_account__c].BasketType__c.contains('Incoming'));
       cscfga__Product_Basket__c bskt = [SELECT id,csbb__Account__r.id,BasketType__c from cscfga__Product_Basket__c where csbb__Account__c=: migrate[0].target_account__c LIMIT 1];
        String str = bskt.BasketType__c; 
             system.assertEquals(str,'Non Modular');

      }
    //Edge-152456,EDGE-152457 ends

}