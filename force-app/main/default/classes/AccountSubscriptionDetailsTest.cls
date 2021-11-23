/* Added by Ramya - EDGE-125950 : Enable Partner details within the subscription so that Assurance agents can make an informed decision.
Test class for AccountSubscriptionDetails.
*/

@isTest
public without sharing class AccountSubscriptionDetailsTest {

     static testMethod void processTest() {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        //testOpp.Type = 'Disconnect';
         testOpp.Type = 'Price Review';
        testOpp.Billing_Solution__c= 'In Contract';
        insert testOpp;
        System.assertNotEquals(testOpp.id,null);

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c IPNet_PD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(IPNet_PD);
        cscfga__Product_Definition__c Mob_PD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility',product_Specification__c='DMCAT_ProductSpecification_000420');
        pdList.add(Mob_PD);
        insert pdList;
       

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.cscfga__Product_Basket__c = testBasket.Id;
        testConfig2.cscfga__Product_Definition__c=IPNet_PD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.cscfga__Product_Basket__c = testBasket.Id;
        testConfig3.cscfga__Product_Definition__c=Mob_PD.id;
        prodconfigList.add(testConfig3); 
        insert prodconfigList;

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        testOrder.isMSISDNHeld__c = false;
        insert testOrder;
        System.assertNotEquals(testOrder.id,null);

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        insert testSubscription;
        
        System.assertNotEquals(testSubscription.id,null); 
        
        test.starttest();
               
        AccountSubscriptionDetails.getPartnerDetails(testSubscription.id);
        try{
        AccountSubscriptionDetails.getPartnerDetails(null);
        }
        catch(Exception e){}
        
        test.stoptest();
         


}

}