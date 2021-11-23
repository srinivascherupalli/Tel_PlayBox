/*
Name        Date      	   Description
Divya	12/15/2020	Test Class for SCProductCatalogueFilterUtility
*/
@isTest
public class SCProductCatalogueFilterUtilityTest {
    
    @isTest static  void filterTestPSWithActiveSubscription() { 
        String productCode;
        
        Account acc = TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = TestDataFactory.generateContact('TestPricing',acc.Id,'Active','TestDelegate',System.today(),'eMail');
        insert contact;
        contact.Email = 'test@tele2.com';
        update contact;
        
        
        
        Opportunity opp  = ApttusTestDataFactory.buildOpportunity(acc);
        insert opp;
        
        //CREATE OPP CONTACT ROLE
        OpportunityContactRole ocr = ApttusTestDataFactory.buildOpportunityContactRole(contact,opp);
        insert ocr; 
        
        cscfga__Product_Definition__c pd = TestDataFactory.generateProductDefinition('DMCAT_ProductSpecification_000965','Test Record');
        
        
        // CREATE MARKETABLE OFFERS
        Marketable_Offer__c moMob = ApttusTestDataFactory.buildMarketableOffer();
        
        insert moMob;
        
        // CREATE PRODUCT
        Product2 prd = TestDataFactory.generateProduct('Adaptive Mobility',true,productCode);
        insert prd;
        prd.Telstra_Marketable_Product_Family__c = 'Adaptive Mobility'; 
        update prd;
        
        cscfga__Product_Basket__c basket = ApttusTestDataFactory.buildProductBasket(acc,opp);
        insert basket;
        
        cscfga__Product_Configuration__c pconfig = ApttusTestDataFactory.buildProductConfiguration(moMob,pd,basket);
        insert pconfig;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 pb = ApttusTestDataFactory.buildPricebook2();
        
        PricebookEntry pbEntry = ApttusTestDataFactory.buildPricebookEntry(prd,pricebookId);
        
        cscfga__Attribute__c attr0 = ApttusTestDataFactory.buildAtrribute(pconfig);
        
        OpportunityLineItem oli = ApttusTestDataFactory.generateOpportunityLineItem(pbEntry,basket,pconfig,attr0);
        list<Marketable_Offer__c> resultt = SCProductCatalogueFilterUtility.getMarketableOffer(basket.id);
		 System.assert(resultt.size()==0);
            
        }
    

    
    @isTest static  void filterTestPSWithActiveSubscriptionPostive() { 
        String productCode;
        
        Account acc = TestDataFactory.generateAccount();
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        update acc;
        
        //CREATE CONTACT 
        Contact contact = TestDataFactory.generateContact('TestPricing',acc.Id,'Active','TestDelegate',System.today(),'eMail');
        insert contact;
        contact.Email = 'test@tele2.com';
        update contact;
        
        
        
        Opportunity opp  = ApttusTestDataFactory.buildOpportunity(acc);
        insert opp;
        
        //CREATE OPP CONTACT ROLE
        OpportunityContactRole ocr = ApttusTestDataFactory.buildOpportunityContactRole(contact,opp);
        insert ocr; 
        
        cscfga__Product_Definition__c pd = TestDataFactory.generateProductDefinition('DMCAT_ProductSpecification_000965','Test Record');
        
        
        // CREATE MARKETABLE OFFERS
        Marketable_Offer__c moMob = ApttusTestDataFactory.buildMarketableOffer();
        
        insert moMob;
         // CREATE MARKETABLE OFFERS
        Marketable_Offer__c moMob1 = ApttusTestDataFactory.buildMarketableOffer();
        insert moMob1;
        moMob1.Contract_Type__c = 'BSA';
        update moMob1;
        
        // CREATE PRODUCT
        Product2 prd = TestDataFactory.generateProduct('Adaptive Mobility',true,productCode);
        insert prd;
        prd.Telstra_Marketable_Product_Family__c = 'Adaptive Mobility'; 
        update prd;
        
        cscfga__Product_Basket__c basket = ApttusTestDataFactory.buildProductBasket(acc,opp);
        insert basket;
        
        cscfga__Product_Configuration__c pconfig = ApttusTestDataFactory.buildProductConfiguration(moMob,pd,basket);
        insert pconfig;
        cscfga__Product_Configuration__c pconfig1 = ApttusTestDataFactory.buildProductConfiguration(moMob1,pd,basket);
        insert pconfig1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 pb = ApttusTestDataFactory.buildPricebook2();
        
        PricebookEntry pbEntry = ApttusTestDataFactory.buildPricebookEntry(prd,pricebookId);
        
        cscfga__Attribute__c attr0 = ApttusTestDataFactory.buildAtrribute(pconfig);
        
        OpportunityLineItem oli = ApttusTestDataFactory.generateOpportunityLineItem(pbEntry,basket,pconfig,attr0);
        list<Marketable_Offer__c> resultt = SCProductCatalogueFilterUtility.getMarketableOffer(basket.id);
		 System.assert(resultt.size()>0);
            
        }
      
    
}