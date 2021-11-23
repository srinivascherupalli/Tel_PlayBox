/********************************************************************************************************************************
Main Class : ModifyTonStatusAccountController
Test Class : ModifyTonStatusAccountControllerTest
=================================================================================================================================
Sr.No.    Developer Name            Date             Story          Sprint               Description
1.        Sarfraj Ahmad          01/07/2021        DPG-5729       21.09(New Class)     To cover ModifyTonStatusAccountController functionality  
********************************************************************************************************************************/

@isTest
public with sharing class ModifyTonStatusAccountControllerTest {
    public static Account acc = null;
    public static csord__Order__c order = null;
    public static Billing_Account__c billingAccount = null;
    public static Opportunity opp = null;
    public static ContractJunction__c contractJunction = null;
    public static Marketable_Offer__c marketableOffer = null;
    public static cscfga__Product_Configuration__c productConfig = null;
    public static List<csord__Subscription__c> subscriptions = null;
    public static cscfga__Product_Definition__c productDefination = null;
    public static List<csord__Service__c> services = null;
    
    
    public static void setUpData(){
        
        acc = new Account(name='Account Test',CIDN__c='6655434',ABN__c='667788',Parent_CIDN__c='23456');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        order = BDSNotifyTestFactory.createOrder(acc);
        billingAccount = BDSNotifyTestFactory.createBillingAccount(1);
        opp = BDSNotifyTestFactory.createOpportunity(acc);
        contractJunction = BDSNotifyTestFactory.createContractJunction(acc, opp);
        productDefination = createProductDefinition('DMCAT_ProductSpecification_001196');
        marketableOffer = BDSNotifyTestFactory.createMarketableOffer('DMCAT_Offer_000681', 'Telstra Mobile Device Management - Vmware');
        productConfig = BDSNotifyTestFactory.createProductConfiguration('New', 'HandHeldEpic');
        cscfga__Product_Definition__c pd = productConfig.cscfga__Product_Definition__r;
        pd.product_Specification__c = 'DMCAT_ProductSpecification_001196';
        update pd;
        
        
        subscriptions = new List<csord__Subscription__c>();
        subscriptions.add(createSubscription('handheld-essential'));
        subscriptions.add(createSubscription('handheld-epic'));
        subscriptions.add(createSubscription('accelator'));
        insert subscriptions;
        
        csord__Service__c service1 = ProductTestFactory.buildService('Accelator', order.id, subscriptions[0].id, null);
        csord__Service__c service2 = ProductTestFactory.buildService('Telstra One Number', order.id, subscriptions[0].id, null);
      services = new List<csord__Service__c>();
        services.add(service1);
        services.add(service2);
        insert services; 
        
        insert new EnvironmentVariable__c(Name='notAllowTONSubscriptionStatus',Value__c = 'Closed Replaced,Pending');
    }
    
    testMethod static void getSubscriptionsRecordsByAccountIdTest(){
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name like 'System Admin%' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        system.runAs(u){
            setUpData();
            List<SubscriptionWrapperData> subscriptionsWrapper = new List<SubscriptionWrapperData>();
            subscriptionsWrapper = ModifyTonStatusAccountController.getSubscriptionsRecordsByAccountId(acc.id);
        }
        Test.stopTest();
    }
    
    testMethod static void updateTonStatusSuccessTest(){
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name like 'System Admin%' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        system.runAs(u){
             setUpData();
            String status;
            status = ModifyTonStatusAccountController.updateTonStatus(System.JSON.serialize(subscriptions));
        }
        Test.stopTest();
       
    }
    
    testMethod static void updateTonStatusErrorTest(){
        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name like 'System Admin%' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        system.runAs(u){
            setUpData();
            csord__Subscription__c subscription = subscriptions[0];
            subscription.TON_Barring_Status__c = 'Barred';
            update subscription;
            csord__Service__c service = services[1];
            service.csord__Status__c = 'Connected';
            update service;
            String status;
            status = ModifyTonStatusAccountController.updateTonStatus(System.JSON.serialize(subscriptions));
        }
        Test.stopTest();
    }
    
    private static cscfga__Product_Definition__c createProductDefinition(String prodSpecificationId){
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c = prodSpecificationId; //'DMCAT_ProductSpecification_001506';
        insert pd;
        return pd;
    }
    
    private static csord__Subscription__c createSubscription(String subscriptionName){
        csord__Subscription__c subscription = new csord__Subscription__c();
        subscription.Name = subscriptionName;
        subscription.csord__Account__c = acc.Id;
        subscription.MarketableOffer__c = marketableOffer.Id;
        subscription.MarketableOffer__r = marketableOffer;
        subscription.csord__Account__r = acc;
        subscription.Billing_Account__r = billingAccount;
        subscription.csordtelcoa__Product_Configuration__r = productConfig;
        subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r = productDefination;
        subscription.Billing_Account__c = billingAccount.Id;
        subscription.csord__Identification__c = 'test';
        subscription.TenancyID__c = '12345';
        subscription.csord__Order__c = order.Id;
        subscription.csordtelcoa__Product_Configuration__c = productConfig.Id;
        subscription.ContractJunction__c = contractJunction.Id;                     
        subscription.ContractJunction__r = contractJunction;                                                  
        return subscription;
        
    }
}