/**
 * Test Class for SOWItemDetails
 EDGE-129805
****************************************************************************************************************************
1. Payal   19/04/2020   EDGE-213120: Commented CustomButtonContractSent part as it is not used and main class will be removed.
 */
@isTest

public with sharing class SOWItemDetailsTest {
 @isTest static void updateBasketStageTest(){

        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
         //createCustomSettingValues();
        Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='AgreementGeneration';
        ev.Value__c='true';
        insert ev;
        
        //CREATE OPPORTUNITY
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csordtelcoa__Basket_Stage__c='Contract Initiated';  
        basket.csbb__Synchronised_With_Opportunity__c =false;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =false;
        basket.cscfga__Opportunity__c =opp.id;
        basket.csbb__Account__c = acc.id;
        insert basket; 

        Marketable_Offer__c Moffer= new Marketable_Offer__c();
        Moffer.Name='PS';
        MOffer.Type__c='Professional Service';
        MOffer.Offer_ID__c='Offer1';    
        insert Moffer;
        
        cscfga__Product_Definition__c PS_PD = new cscfga__Product_Definition__c(Name = 'Professional Service', cscfga__Description__c = 'Professional Service');
        insert PS_PD;
 
        cscfga__Product_Basket__c basket1 = [SELECT id FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Name = 'TestingOpp' LIMIT 1];
         
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Professional Service';
        testConfig.Type__c = 'Cancel';
        testConfig.cscfga__Product_Basket__c = basket1.Id;
        testConfig.cscfga__Product_Definition__c=PS_PD.id;
        testConfig.Marketable_Offer__C=Moffer.id;
        insert testConfig;
        
        SOW__c Sow= new SOW__c();
        Sow.Basket__c=basket1.id;
        Sow.Status__c='SOW Configuration';
        insert Sow;
           
        //Payal: Comments as it is not used : CustomButtonContractSent generateContract = new CustomButtonContractSent();
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestSub', acc.id, ord.id, ordReq.id);
        insert subs;
        
        FulfillmentLineItem__c f= new FulfillmentLineItem__c(subscription__c=subs.id);
        insert f;
        
        Test.startTest();
            Sow.Status__c='Approved';
            update Sow;
            SOWItemDetails.getSOWItems(f.id);
        Test.stopTest();

}
}