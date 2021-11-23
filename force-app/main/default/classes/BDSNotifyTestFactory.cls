/*
===============================================================================================================================
Class : BDSNotifyTestFactory
Developer Name :Anand Shekhar
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
4.      Akshay Gujar        19/08/2020   DIGI-25281 | Enable Intune | P2O | Notifications for New, Modify, Cancel
===============================================================================================================================
*/
@isTest
public class BDSNotifyTestFactory {

    public static void createBdsNotifySettings() {
        
        List<BDS_Notify_Settings__c> bdsNotifySettings = new List<BDS_Notify_Settings__c>();
       /* bdsNotifySettings.add(createCustomSettings('Discount Level Id', 'DMCAT_Discount_001269', false));
        bdsNotifySettings.add(createCustomSettings('One Day After', '0', false));
        bdsNotifySettings.add(createCustomSettings('One Day Prior', '2', false));
        bdsNotifySettings.add(createCustomSettings('Seven Days Prior', '8', false));
        bdsNotifySettings.add(createCustomSettings('TMDM Marketable Offer', 'DMCAT_Offer_000681', false));
		bdsNotifySettings.add(createCustomSettings('User Support', 'User Support', false));
		bdsNotifySettings.add(createCustomSettings('Platform Management', 'Platform Management', false));
		bdsNotifySettings.add(createCustomSettings('Technical Support', 'TechnicalSupportShadow', true));*/
        bdsNotifySettings.add(createCustomSettings('Discount Level Id', 'DMCAT_Discount_001269','',false,'',false));
        bdsNotifySettings.add(createCustomSettings('One Day After', '0','',false,'',false));
        bdsNotifySettings.add(createCustomSettings('One Day Prior', '2','',false,'',false));
        bdsNotifySettings.add(createCustomSettings('Seven Days Prior', '8','',false,'',false));
        bdsNotifySettings.add(createCustomSettings('TMDM Marketable Offer', 'DMCAT_Offer_000681','',false,'',false));
		bdsNotifySettings.add(createCustomSettings('User Support', 'User Support','',false,'',false));
		bdsNotifySettings.add(createCustomSettings('Platform Management', 'Platform Management','',false,'',false));
        bdsNotifySettings.add(createCustomSettings('Feature Level', 'FeatureLevelShadow','',false,'attributeQuery', false));
        bdsNotifySettings.add(createCustomSettings('Technical Support', 'TechnicalSupportShadow','',false,'attributeQuery', false));
        bdsNotifySettings.add(createCustomSettings('Adaptive Mobility Care', 'DMCAT_Offer_001251','DMCAT_Offer_001251' ,true,'offerIdCheck',true));
        bdsNotifySettings.add(createCustomSettings('Adaptive Mobility Managed Services', 'DMCAT_Offer_000854', 'DMCAT_Offer_000854',true,'offerIdCheck', true));
        bdsNotifySettings.add(createCustomSettings('Professional Services - TMDM', 'DMCAT_Offer_000750','DMCAT_Offer_000750', true,'offerIdCheck', true));
        bdsNotifySettings.add(createCustomSettings('Lifecycle Management', 'DMCAT_Offer_001551','DMCAT_Offer_001551', true,'offerIdCheck', true));  
        bdsNotifySettings.add(createCustomSettings('Intune Management', 'DMCAT_Offer_001562','DMCAT_Offer_001562', true,'offerIdCheck', true)); // DIGI - 25281     
        insert bdsNotifySettings;
    }
    
    public static void createTBNSettings() {
        
        List<TimeBased_Notification_Settings__c> tbnSettings = new List<TimeBased_Notification_Settings__c>();
        tbnSettings.add(createTBNCustomSettings('Accelerator', 'PRODUCT_SPECIFICATION', 'DMCAT_ProductSpecification_001506', 'Accelerator', 30, 'DAY', 'BILLING_CYCLE', '16,6,0'));
        tbnSettings.add(createTBNCustomSettings('TMDM', 'MARKETABLE_OFFER', 'DMCAT_Offer_000681', 'Telstra Mobile Device Management - VMware', 30, 'DAY', 'ACTIVATION', '8,2,0'));
        insert tbnSettings;
    }
    
    private static TimeBased_Notification_Settings__c createTBNCustomSettings(String name, String specificationType, String specificationId, String promotionName, Decimal promotionFrequencyValue, String promotionFrequencyType, String promotionCycleType, String mailTriggerDuration) {
        TimeBased_Notification_Settings__c tbn = new TimeBased_Notification_Settings__c();
        tbn.Name = name;
        tbn.Specification_Type__c = specificationType;
        tbn.Specification_Id__c = specificationId;
        tbn.Promotion_Name__c = promotionName;
        tbn.Promotion_Frequency_Value__c = promotionFrequencyValue;
        tbn.Promotion_Frequency_Type__c = promotionFrequencyType;
        tbn.Promotion_Cycle_Type__c = promotionCycleType;
        tbn.Mail_Trigger_Duration__c = mailTriggerDuration;
        return tbn;
        
    }

    public static Account createAccount(){

        Account acc = new Account(name='TestParentAccount',CIDN__c='123467',ABN__c='12323',Parent_CIDN__c='123');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        return acc;

    }
    
    public static Partner_of_Record__c createPor(Account acc, Contact con) {
        
        Partner_of_Record__c por = new Partner_of_Record__c();
        por.Customer__c=acc.Id;
        por.Partner__c=acc.Id;
        por.Partner_Signatories__c= con.Id;
        por.Status__c='Active'; 
        insert por;
        return por;
    }
    
    public static Contact createContact(Account acc){
        
        Contact con = new Contact(LastName ='testCon',FirstName='notempty',AccountId = acc.Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active', Email='test@test.com',Partner_Role__c='Engineering User');
        insert con;            
        return con;
        
    }
    
    public static csord__Order__c createOrder(Account acc){
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.name = 'testorder' ;
        ord.csord__Status__c = 'Connected';
        insert ord;
        return ord;
        
    }

    public static Marketable_Offer__c createMarketableOffer(String offerId, String offerName){

        Marketable_Offer__c marketableOffer = new Marketable_Offer__c();
        marketableOffer.Offer_ID__c = offerId;
        marketableOffer.Name = offerName;
        insert marketableOffer;
        return marketableOffer;

    }

    public static Billing_Account__c createBillingAccount(Integer day){
        
        Billing_Account__c billingAccount = new Billing_Account__c();
        billingAccount.Billing_Account_Number__c = '123456789012';
        billingAccount.BillCycleday__c = day;
        insert billingAccount;
        return billingAccount;

    }

    public static csord__Subscription__c createSubscription(Account acc, Marketable_Offer__c marketableOffer,
                                                            Billing_Account__c billingAccount, csord__Order__c order, 
                                                            cscfga__Product_Configuration__c productConfig, 
                                                            csord__Subscription__c replacedSubscription, ContractJunction__c contractJunction){
        
        csord__Subscription__c subscription = new csord__Subscription__c();
        subscription.csord__Account__c = acc.Id;
        subscription.MarketableOffer__c = marketableOffer.Id;
        subscription.MarketableOffer__r = marketableOffer;
        //subscription.MarketableOffer__r.Name = marketableOffer.Name;
        subscription.csord__Account__r = acc;
        subscription.Billing_Account__r = billingAccount;
        subscription.csordtelcoa__Product_Configuration__r = productConfig;
        //subscription.csordtelcoa__Product_Configuration__r.Name = productConfig.Name; 
        //subscription.csordtelcoa__Product_Configuration__r.Type__c = productConfig.Type__c;                                                       
        subscription.Billing_Account__c = billingAccount.Id;
        subscription.csord__Identification__c = 'test';
        subscription.TenancyID__c = '12345';
        subscription.csord__Order__c = order.Id;
        subscription.csordtelcoa__Product_Configuration__c = productConfig.Id;
        subscription.csordtelcoa__Replaced_Subscription__c = replacedSubscription.Id;
        subscription.csordtelcoa__Replaced_Subscription__r = replacedSubscription;
        subscription.ContractJunction__c = contractJunction.Id;                     
        subscription.ContractJunction__r = contractJunction;                                                  
        insert subscription;
        return subscription;

    }

    public static csord__Subscription__c createReplacedSubscription(Account acc, Marketable_Offer__c marketableOffer,
                                                            Billing_Account__c billingAccount, csord__Order__c order, 
                                                            cscfga__Product_Configuration__c productConfig, ContractJunction__c contractJunction){
        
        csord__Subscription__c subscription = new csord__Subscription__c();
        subscription.csord__Account__c = acc.Id;
        subscription.MarketableOffer__c = marketableOffer.Id;
        subscription.MarketableOffer__r = marketableOffer;
        //subscription.MarketableOffer__r.Name = marketableOffer.Name;
        subscription.csord__Account__r = acc;
        subscription.Billing_Account__r = billingAccount;
        subscription.csordtelcoa__Product_Configuration__r = productConfig;
        //subscription.csordtelcoa__Product_Configuration__r.Name = productConfig.Name; 
        //subscription.csordtelcoa__Product_Configuration__r.Type__c = productConfig.Type__c;                                                       
        subscription.Billing_Account__c = billingAccount.Id;
        subscription.csord__Identification__c = 'test';
        subscription.TenancyID__c = '12345';
        subscription.csord__Order__c = order.Id;
        subscription.csordtelcoa__Product_Configuration__c = productConfig.Id;
        subscription.ContractJunction__c = contractJunction.Id;                     
        subscription.ContractJunction__r = contractJunction;   
        insert subscription;
        return subscription;

    }
    
    public static Opportunity createOpportunity(Account acc){        
        
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        return opp;
        
    }
    
    public static ContractJunction__c createContractJunction(Account acc, Opportunity opp){
        
        ContractJunction__c contractJunction = new ContractJunction__c();
        contractJunction.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        //contractJunction.Related_Basket__c = basket.id;
        contractJunction.CongaStatus__c = 'NotStarted';
        contractJunction.Status__c = 'Initiated';
        //contractJunction.Account__c = basket.csbb__Account__c;
        contractJunction.Related_Opportunity__c = opp.Id;
        contractJunction.Contract_Activated_Date__c = System.today();
        contractJunction.Contract_Term_Months__c = 36;
        contractJunction.BSA_Generated__c = true;
        contractJunction.GPTVersion__c = 1.2;
        contractJunction.OFTVersion__c = 1.4;
        contractJunction.BSAVersion__c = 1.3;
        contractJunction.Account__c = acc.id;
        insert contractJunction;
        return contractJunction;
        
    }
    
    public static csord__Service__c createService(csord__Subscription__c subscription, csord__Order__c order, cscfga__Product_Configuration__c productConfig){

        csord__Service__c serv = new csord__Service__c();
        Date activationDate = Date.today();
        Integer d = activationDate.day();
        Integer mo = activationDate.month();
        Integer yr = activationDate.year();
        DateTime activationDateTime = DateTime.newInstance(yr, mo, d);
        serv.Initial_Activation_Date__c = activationDate;
        serv.csord__Subscription__c = subscription.Id;
        serv.csord__Identification__c = 'test';
        serv.csord__Status__c='Connected';
        serv.serviceMSISDN__c='0411111111';
        serv.csord__Order__c = order.Id;
        serv.csord__Order__r = order;
        serv.csordtelcoa__Product_Configuration__c = productConfig.Id;
        serv.csordtelcoa__Product_Configuration__r = productConfig;
        insert serv;
        return serv;

    }

    public static csord__Service__c createServiceNoActivation(csord__Subscription__c subscription){

        csord__Service__c serv = new csord__Service__c();
        serv.csord__Subscription__c = subscription.Id;
        serv.csord__Identification__c = 'test';
        serv.csord__Status__c='Connected';
        insert serv;
        return serv;

    }
    
    public static cscfga__Product_Definition__c createProductDefinition(){
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c = 'DMCAT_ProductSpecification_001506';
        insert pd;
        return pd;
    }

    public static cscfga__Product_Configuration__c createProductConfiguration(String type, String name){

        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        //productConfig.Offer_Reference__c = originatingOffer.id;
        productConfig.Type__c = type;
        productConfig.Name = name;
        cscfga__Product_Definition__c pd = createProductDefinition();
        System.debug('ProductDefinition :: '+pd);
        productConfig.cscfga__Product_Definition__c = pd.Id;
        productConfig.cscfga__Product_Definition__r = pd;
        insert productConfig;
        return productConfig;
    }
    
    public static void createAttribute(cscfga__Product_Configuration__c productConfig){
        
        List<cscfga__Attribute__c> attribute = new List<cscfga__Attribute__c>();
        attribute.add(new cscfga__Attribute__c(Name='FeatureLevelShadow',cscfga__Value__c = 'Integrated',cscfga__Product_Configuration__c=productConfig.id));
        attribute.add(new cscfga__Attribute__c(Name='TechnicalSupportShadow',cscfga__Value__c = '24x7',cscfga__Product_Configuration__c=productConfig.id));
        insert attribute;
    }

    public static void createDiscountLevel(){
        
        cspmb__Discount_Level__c discountLevel = new cspmb__Discount_Level__c();
        discountLevel.Business_ID__c = 'DMCAT_Discount_001269';
        discountLevel.cspmb__duration__c = 30;
        insert discountLevel;

    }
    
    private static BDS_Notify_Settings__c createCustomSettings(String name, String value,String OfferID,boolean triggerOrderNotifications,String useSettingFor, boolean isSI5Offer) {
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.Name = name;
        bds.Value__c = value;
        bds.OfferID__c=OfferID;
        bds.triggerOrderNotifications__c=triggerOrderNotifications;
        bds.useSettingFor__c= useSettingFor;
        bds.Is_SI5_Offer__c = isSI5Offer;
        return bds;
        
    }
    
    public static csord__Subscription__c createTestDataSI5(String offerId, String offerName, String type, String prodConfigName,
                                                           Account acc, Billing_Account__c billingAccount, csord__Order__c order, 
                                                           ContractJunction__c contractJunction){
        
        Marketable_Offer__c marketableOffer = createMarketableOffer(offerId, offerName);
        cscfga__Product_Configuration__c productConfig = createProductConfiguration(type, prodConfigName);
        createAttribute(productConfig);
        csord__Subscription__c replacedSubscription = createReplacedSubscription(acc, marketableOffer, billingAccount, order, productConfig, contractJunction);
        csord__Subscription__c subscription = createSubscription(acc, marketableOffer, billingAccount, order, productConfig, replacedSubscription, contractJunction);        
        csord__Service__c service = createService(subscription, order, productConfig);
        createDiscountLevel();
        return subscription;
        
        
    }
    
    public static List<csord__Subscription__c> createTestDataNewComplete() {        
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Billing_Account__c billingAccount = createBillingAccount(1);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        
        Contact con = createContact(acc);
        createPor(acc, con);
        
        
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_001251', 'Adaptive Mobility Care', 'New', 'Adaptive Care', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'New', 'Unified Endpoint Management - End User Support', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'New', 'Unified Endpoint Management - Platform Management', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000750', 'Professional Services - TMDM', 'New', 'Professional Services-MDM COnfig', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_001551', 'Lifecycle Management', 'New', 'Endpoint Lifecycle - Solution', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_001562', 'Intune Management', 'New', 'Adaptive Mobility Managed Services Modular - Endpoint Management Intune', acc, billingAccount, order, contractJunction)); // DIGI - 25281 
        return subscriptionList;
        
    }
    
    public static List<csord__Order__c> createTestDataSI5Order() {        
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Billing_Account__c billingAccount = createBillingAccount(1);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        
        Contact con = createContact(acc);
        createPor(acc, con);
        
        
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_001251', 'Adaptive Mobility Care', 'New', 'Adaptive Care', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000681', 'TMDM Marketable Offer', 'New', 'TMDM', acc, billingAccount, order, contractJunction));
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orderList.add(order);
        return orderList;
        
    }
    
    public static List<csord__Order__c> createTestDataNonSI5Order() {        
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Billing_Account__c billingAccount = createBillingAccount(1);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        
        Contact con = createContact(acc);
        createPor(acc, con);
        
        
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orderList.add(order);
        return orderList;
        
    }
    
    public static List<csord__Subscription__c> createTestDataCancelComplete() {        
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Billing_Account__c billingAccount = createBillingAccount(1);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        
        Contact con = createContact(acc);
        createPor(acc, con);
        
        
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_001251', 'Adaptive Mobility Care', 'Cancel', 'Adaptive Care', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'Cancel', 'Unified Endpoint Management - End User Support', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'Cancel', 'Unified Endpoint Management - Platform Management', acc, billingAccount, order, contractJunction));
        return subscriptionList;
        
    }
    
    public static List<csord__Subscription__c> createTestDataModifyComplete() {        
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Billing_Account__c billingAccount = createBillingAccount(1);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        
        Contact con = createContact(acc);
        createPor(acc, con);
        
        
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'Modify', 'Unified Endpoint Management - End User Support', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'Modify', 'Unified Endpoint Management - Platform Management', acc, billingAccount, order, contractJunction));
        return subscriptionList;
        
    }
    
    public static List<csord__Subscription__c> createTestDataNewInProgress() {        
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Billing_Account__c billingAccount = createBillingAccount(1);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        
        Contact con = createContact(acc);
        createPor(acc, con);
        
        
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'New', 'Unified Endpoint Management - End User Support', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'New', 'Unified Endpoint Management - Platform Management', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000750', 'Professional Services - TMDM', 'New', 'Professional Services-MDM Config', acc, billingAccount, order, contractJunction));
        return subscriptionList;
        
    }
    
    public static List<csord__Subscription__c> createTestDataModifyInProgress() {        
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Billing_Account__c billingAccount = createBillingAccount(1);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        
        Contact con = createContact(acc);
        createPor(acc, con);
        
        
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'Modify', 'Unified Endpoint Management - End User Support', acc, billingAccount, order, contractJunction));
        subscriptionList.add(createTestDataSI5('DMCAT_Offer_000854', 'Adaptive Mobility Managed Services', 'Modify', 'Unified Endpoint Management - Platform Management', acc, billingAccount, order, contractJunction));
        return subscriptionList;
        
    }
    
    public static void createTestDataTimeBound(Integer daysDiff) {        
        
        createBdsNotifySettings();
        createTBNSettings();
        Date intialActivationDate = Date.today().addDays(daysDiff);
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Marketable_Offer__c marketableOffer = createMarketableOffer('DMCAT_Offer_000681', 'Telstra Mobile Device Management - Vmware');
        Billing_Account__c billingAccount = createBillingAccount(intialActivationDate.Day());
        cscfga__Product_Configuration__c productConfig = createProductConfiguration('New', 'Name');
        System.debug('productConfig :: '+productConfig);
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        csord__Subscription__c replacedSubscription = createReplacedSubscription(acc, marketableOffer, billingAccount, order, productConfig, contractJunction);
        csord__Subscription__c subscription = createSubscription(acc, marketableOffer, billingAccount, order, productConfig, replacedSubscription, contractJunction);        
        csord__Service__c service = createService(subscription, order, productConfig);
        service.Initial_Activation_Date__c = intialActivationDate;
        update service;
        createDiscountLevel();
        
    }


    
    public static void createTestDataTimeBoundNoActivationDate(Integer daysDiff) {
        
        createBdsNotifySettings();
        Account acc = createAccount();
        csord__Order__c order = createOrder(acc);
        Marketable_Offer__c marketableOffer = createMarketableOffer('DMCAT_Offer_000681', 'Telstra Mobile Device Management - Vmware');
        Billing_Account__c billingAccount = createBillingAccount(1);
        cscfga__Product_Configuration__c productConfig = createProductConfiguration('New', 'Name');
        Opportunity opp = createOpportunity(acc);
        ContractJunction__c contractJunction = createContractJunction(acc, opp);
        csord__Subscription__c replacedSubscription = createReplacedSubscription(acc, marketableOffer, billingAccount, order, productConfig, contractJunction);
        csord__Subscription__c subscription = createSubscription(acc, marketableOffer, billingAccount, order, productConfig, replacedSubscription, contractJunction);     
        csord__Service__c service = createServiceNoActivation(subscription);
        createDiscountLevel();
        
    }
}