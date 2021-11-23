/*******************************************************************
   @Author : Rajesh.P / Sayantan.H
   @Description : Test Class for: AMMSMarketableOfferLookup
   @Release : Sprint 21.14 - DIGI-23856

   S.No.  Date         User Story   Owner      Description
   1      18-10-2021   DIGI-23856   Sayantan.H  Constructed test data setup for the test class
   2.     18-10-2021   DIGI-23856   Rajesh.P    Contructed test method for the test Class
*******************************************************************/

@isTest
public class AMMSMarketableOfferLookupTest {

    @testSetup
    static void testData(){
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Network Product','Premium');
    insert pd;
       Pricebook2 pb = new Pricebook2(Name = 'Test Price Book', Description = 'Test Price Book', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;
        Account acc = new Account(Name = 'Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'Test Opportunity';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csordtelcoa__Basket_Stage__c='Draft';  
        basket.csbb__Synchronised_With_Opportunity__c =false;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =false;
        basket.cscfga__Opportunity__c =opp.id;
        basket.csbb__Account__c = acc.id;
        insert basket; 

        Marketable_Offer__c Moffer= new Marketable_Offer__c();
        Moffer.Name='PS';
        MOffer.Offer_ID__c='Offer1';    
        insert Moffer;
        
        cscfga__Product_Definition__c PS_PD = new cscfga__Product_Definition__c(Name = 'Managed Service Solution', cscfga__Description__c = 'Managed Service Solution');
        insert PS_PD;
 
        cscfga__Product_Basket__c basket1 = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'Test Opportunity' LIMIT 1];
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        insert ord; 
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestSub', acc.id, ord.id, ordReq.id);
        insert subs;      
      }   
     @isTest
  static void lookupSearchforType(){
      Map<String,String> searchFields = new Map<String,String>();
    searchFields.put('OfferId','DMCAT_Offer_001562');
    searchFields.put('AccountID','123');     
    searchFields.put('SolutionTemplate','Managed Service Solution');
        cscfga__Product_Definition__c pd = [Select Id, Name From cscfga__Product_Definition__c where Name = 'Network Product'];
    List<Id> excludeIds = new List<Id>();
      AMMSMarketableOfferLookup ammsLookUp = new AMMSMarketableOfferLookup();
      ammsLookUp.getRequiredAttributes();
      Object[] lookupResult = ammsLookUp.doLookupSearch(searchFields,pd.Id,excludeIds,0,0);    
     System.assertEquals(true,lookupResult != null);
      
  }
    
}