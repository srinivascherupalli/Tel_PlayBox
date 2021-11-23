/********************************************************
Class Name      :   DP_DealQueryUtilTest
Main Class      :   DP_DealQueryUtil
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Aditya Pareek         29/01/2020      Test Class for DP_DealQueryUtil
2.            Laxmi Rahate          07/02/2020       Instead of individual data set up using ProductTestFactoryMethods
********************************************************************/
@isTest
public class DP_DealQueryUtilTest{
    
@TestSetup static void CreateData()
{
        //Added State as Active for Account 
        Account accDeal = new Account (name= 'accDeal',cscfga__Active__c = 'Yes',Customer_Status__c = 'Active');
        insert accDeal;
        System.debug ('Account -----' + accDeal.id);
   
        Opportunity  opp = ProductTestFactory.getOpportunityBasic (accDeal);
        opp.CloseDate = Date.today();
        opp.Product_Type__c = 'Modular';
        opp.Pricing_Method__c = 'Delegated Pricing';
        opp.StageName ='Define';
        insert Opp;
    
 
        system.debug('Opp--------'+Opp);
        Delegated_Pricing_Request__c  DPRS = new Delegated_Pricing_Request__c(Opportunity__c = Opp.id,Contract_Acceptance_Date__c  = System.today() );
        insert DPRS;       
        system.debug('DPRS::::'+DPRS);
        Marketable_Offer__c MarkOffer= new Marketable_Offer__c(Name='TestMO',Offer_ID__c='DMCAT_Offer_000646'); 
        insert MarkOffer;      
         
        system.debug('MarkOffer::::'+MarkOffer);
        DPR_Offer__c DPROffer =new DPR_Offer__c(Name='TestDPR',Delegated_Pricing_Request__c=DPRS.Id,Marketable_Offer__c=MarkOffer.Id,Hardware_Option__c = 'One Fund');
        insert DPROffer;   

    
            
       Opp.Pricing_Method__c = 'Delegated Pricing';
       opp.StageName ='Closed Won';

       update Opp;
       
}
    
    
@isTest
   public static void testisHardwareOptionNegative() {
  
        Account accDeal =[Select name,id from Account where name = 'accDeal'];
        System.debug ('Account -----' + accDeal.id);
        //there is Trigger on Opportunity because of which the Pricing_Method__c is inserted as Off the Shelf
        Opportunity Opp =[Select name,CloseDate,Product_Type__c,Pricing_Method__c,StageName from Opportunity where name = 'TestOpp'];
 
         string OfferId='DMCAT_Offer_000646';
         test.startTest();
         boolean IsActive= DP_DealQueryUtil.isHardwareOptionOneFund(OfferId,accDeal.id);
         test.stopTest();
         system.assertEquals(true,IsActive);   
       
    
   }
    
   @isTest
   public static void testisHardwareOptionPositive() {

        Account accDealNeg = new Account (name= 'accDealNeg');
        insert accDealNeg;
 
         string OfferId='DMCAT_Offer_000xxx';
         Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
         User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        System.runAS (sales){
   
         test.startTest();
       
         boolean IsActive= DP_DealQueryUtil.isHardwareOptionOneFund(OfferId,accDealNeg.id);
         test.stopTest();
         system.assertEquals(false,IsActive);   
        
       }
   }
    
 @isTest
   public static void testretrieveContractSignDatePositive() {

        Account accDealNeg = new Account (name= 'accDealNeg');
        insert accDealNeg;
 
         string OfferId='DMCAT_Offer_000xxx';
         Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
         User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');
        System.runAS (sales){
   
         test.startTest();
       
         Date contractSignedDate= DP_DealQueryUtil.retrieveContractSignDate(OfferId,accDealNeg.id);
         test.stopTest();
         system.assertEquals(null,contractSignedDate);   
        
       }
   }    
    
    @isTest
   public static void tesgetActiveDealsForAccountPositive() {
    
            Account accDeal =[Select name,id from Account where name = 'accDeal'];
            test.startTest();
            List<Delegated_Pricing_Request__c> dprList = DP_DealQueryUtil.getActiveDealsForAccount (accDeal.id);
            test.stopTest();
            system.assertEquals(1,dprList.size());    

        }
    
 @isTest
   public static void testretriveContractDatePositive() {
  
        Account accDeal =[Select name,id from Account where name = 'accDeal'];
        System.debug ('Account -----' + accDeal.id);
        //there is Trigger on Opportunity because of which the Pricing_Method__c is inserted as Off the Shelf
        Opportunity Opp =[Select name,CloseDate,Product_Type__c,Pricing_Method__c,StageName from Opportunity where name = 'TestOpp'];
 
         string OfferId='DMCAT_Offer_000646';
         test.startTest();
         Date contractSignedDate= DP_DealQueryUtil.retrieveContractSignDate(OfferId,accDeal.id);
         test.stopTest();
         system.assertEquals(System.today(),contractSignedDate);   
       
    
   }   
  
    
    @isTest
   public static void isAnyActiveDealWithOffer() {
  
        Account accDeal =[Select name,id from Account where name = 'accDeal'];
        System.debug ('Account -----' + accDeal.id);
        //there is Trigger on Opportunity because of which the Pricing_Method__c is inserted as Off the Shelf
        Opportunity Opp =[Select name,CloseDate,Product_Type__c,Pricing_Method__c,StageName from Opportunity where name = 'TestOpp'];
 
         string OfferId='DMCAT_Offer_000646';
         test.startTest();
         boolean dealOffer= DP_DealQueryUtil.isAnyActiveDealWithOffer(OfferId,accDeal.id);
         test.stopTest();
         system.assertEquals(true,dealOffer);   
       
    
   }  
    
     @isTest
   public static void isAnyActiveDealWithOfferNegative() {
  
        Account accDeal =[Select name,id from Account where name = 'accDeal'];
        System.debug ('Account -----' + accDeal.id);
        //there is Trigger on Opportunity because of which the Pricing_Method__c is inserted as Off the Shelf
        Opportunity Opp =[Select name,CloseDate,Product_Type__c,Pricing_Method__c,StageName from Opportunity where name = 'TestOpp'];
 
         string OfferId='DMCAT_Offer_000XXX';
         test.startTest();
         boolean dealOffer= DP_DealQueryUtil.isAnyActiveDealWithOffer(OfferId,accDeal.id);
         test.stopTest();
         system.assertEquals(false,dealOffer);   
       
    
   } 
    @isTest
   public static void getActiveDealsForAccountPositive() {
  
        Account accDeal =[Select name,id from Account where name = 'accDeal'];
        System.debug ('Account -----' + accDeal.id);
        //there is Trigger on Opportunity because of which the Pricing_Method__c is inserted as Off the Shelf
         Opportunity Opp =[Select name,CloseDate,Product_Type__c,Pricing_Method__c,StageName from Opportunity where name = 'TestOpp'];
 
         //string OfferId='DMCAT_Offer_000646';
         test.startTest();
         List<Delegated_Pricing_Request__c> DPRlist = DP_DealQueryUtil.getActiveDealsForAccount(accDeal.id);
         Delegated_Pricing_Request__c dpr = DPRlist[0];
       
         List<DPR_Offer__c> dprOffers  =  DP_DealQueryUtil.getDPROffers(DPRlist);
         DPR_Offer__c dprOffer =  dprOffers [0];
         test.stopTest();
         system.assertEquals(Opp.id,dpr.Opportunity__c);  
         system.assertEquals('DMCAT_Offer_000646',dprOffer.Marketable_Offer__r.offer_Id__c);  
      
   }   
 
}