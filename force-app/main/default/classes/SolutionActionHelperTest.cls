/***************************************************************************************************************
Name          : SolutionActionHelperTest
Created By    : Mahaboob Basha
Created Date  : Jun 11 2019
Description   : This is a test class to simulate and test the logic of SolutionActionHelper
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        11-06-2019      Created
1.1         Mahaboob        11-06-2019      Added methods unreserveNumbersTest, getReservedNumbersTest
                                                        , DetachAccountFromSiteTest, DetachAccountFromSiteTest1
                                                        , DetachAccountFromSiteTest2, GetBasketTest
                                                        , GetBasketTest1, GetBasketTest2, GetPCDataTest
                                                        , GetPCDataTest1, GetPCDataTest2, GetSiteIdTest
                                                        , GetServiceStartDateTest, GetServiceStartDateTest1
                                                        , GetMobileUnitPriceTest, GetMobileUnitPriceTest1
1.2        Venkata Ramanan  21-07-2019      Added methods GetSubscriptionForConfigurationTest
1.3        Tihomir Baljak   13-08-2019      GetSmOptionsTest, GetExistingTenancySubscriptionsTest,getReservedNumbersTest1
1.4        Ankit Goswami    31-01-2020      Added method GetServiceForConfiguration
1.5        Ankit Goswami    26-02-2020      Added method GetCorrelationIdTest
1.6        Ankit            25/06/2020      EDGE-148733- Added GetAssetTestPositive & GetAssetTestNegative method
1.7        Aman Soni        25/06/2020      EDGE-148733- Added testSetup method and System.runAs()
1.8        Gnana/Pooja      19/07/2020      Spring'20 Upgrade
1.9        Sandip Deshmane  08/8/2020       Spring'20 Upgrade - added method
1.10       manish Berad     07/09/2020      EDGE-168275, EDGE-164350 EDGE-164351
1.11       Sandhya          05/09/2020      EDGE-172941 Added method GetPCIdTest
1.12       Manuga Kale      10/09/2020      EDGE-165017 Enable a button on CS Solution console for Sales/R2R/Partner users to view Power BI offer explorer
1.13       Krunal Taak      13/07/2020      DPG-1878 - Added getBillingCheckInfoPositiveTest method,DPG-4887
1.14       Krunal Taak      16/07/2020      DPG-1878 - Added getBillingCheckInfoNegativeTest method,DPG-4887
1.16       Krunal Taak      07/09/2020      DPG-2577 - Added method getActiveManagedServiceSubscriptionCheckInfoPositiveTest,   
                                                                    getActiveManagedServiceSubscriptionCheckInfoNegativeTest
1.17       Shresth Dixit    20/10/2020      DPG-2319
1.18       Sandip Deshmane  03/11/2020      EDGE-186945
1.19       Jagadeswary      25/11/2020      EDGE-188712
1.20       Vishal Arbune    10/05/2021      EDGE-216217: POS Redemption
1.21       Monali Mukherjee 09/06/2021      DPG-5626- Added GetPurchaseOrderNoTestPositive & GetPurchaseOrderNoTestNegative method updated
1.22       Don Navarro      22/10/2021      DIGI-456: added testMethod oeAM()
**************************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionActionHelperTest {
   Public static List<csord__Subscription__c> subLst = new List<csord__Subscription__c>();
   Public static List<cscfga__Product_Configuration__c> MacdprodConfigLst = new List<cscfga__Product_Configuration__c>();  
   Public static List<csord__Service__c> servLst = new List<csord__Service__c>();
  //Added by Aman Soni as a part of EDGE-148733 || Start
  @TestSetup
  private static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    
    List<Account> AccLst = new List<Account>();
    Account acc = new Account(Name = 'Test Account');
    AccLst.add(acc);
    
    Account acc1 = new Account(Name = 'Burlington');
    AccLst.add(acc1);
    insert AccLst;
    
    List<cscrm__Address__c> AddrLst = new List<cscrm__Address__c>();
    cscrm__Address__c addr = new cscrm__Address__c(Name = 'Test Addr', Address_ID__c = '12345');
    AddrLst.add(addr);
    insert AddrLst;
    
    List<cscrm__Site__c> SiteLst = new List<cscrm__Site__c>();
    cscrm__Site__c site = new cscrm__Site__c(Name = 'Test Site', cscrm__Account__c = acc.Id, cscrm__Installation_Address__c = addr.Id, Legacy__c = TRUE);
    SiteLst.add(site);
    insert SiteLst;
    
    List<Billing_Account__c> billAccLst = new List<Billing_Account__c>();
    Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
    billingAccount.Billing_Account_Number__c = '700000449806';
    billAccLst.add(billingAccount);
  Billing_Account__c billingAccount1 = ProductTestFactory.getBillingAccount();
    billingAccount1.Billing_Account_Number__c = '700000504654';
  billingAccount1.Account__c = acc1.Id;
    billAccLst.add(billingAccount1);
    insert billAccLst;
    
  List<cscfga__Product_Definition__c> prodDefLst = new List<cscfga__Product_Definition__c>();
    cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
    prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000087';
    prodDefLst.add(prodDef);
  cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product Def', 'Test Plan');
    prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000537';
    prodDefLst.add(prodDef1);
    insert prodDefLst;
  
    List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
    basket.csbb__Account__c = acc1.id;
    basket.csbb__Synchronised_with_Opportunity__c = true;
  basket.csordtelcoa__Synchronised_with_Opportunity__c = true; // Added for nullpointer exception
    basketLst.add(basket);
      
     cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
    basket2.csbb__Account__c = acc1.id;
    basketLst.add(basket2);
    insert basketLst;
      
    csord__Solution__c solution = new csord__Solution__c();
    solution.Name = 'Test Solution';
    solution.csord__Identification__c = 'Solution Management';
    insert solution;
  
    List<cscfga__Product_Configuration__c> prodConfigLst = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
    newConfig.name = 'new config';
    newConfig.cssdm__solution_association__c = solution.Id;
    newConfig.cscfga__total_contract_value__c = 1234.45;
    prodConfigLst.add(newConfig);
    
    cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
  testConfig.cscfga__Product_Definition__c = prodDef1.id;
    testConfig.name = 'Test Config';
    prodConfigLst.add(testConfig); 

    cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c();
    prodConfigLst.add(pc);  
  
    cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
    config.cscfga__Product_Definition__c = prodDef.id;
    config.name = 'prod config';
    config.cscfga__Contract_Term__c = 12;
    config.cscfga__total_contract_value__c = 325;
    config.cscfga__Product_Basket__c = basket.id;
    prodConfigLst.add(config);
  insert prodConfigLst; 
  
  cscfga__Product_Configuration__c config1 = new cscfga__Product_Configuration__c();
    config1.cscfga__Product_Definition__c = prodDef.id;
    config1.name = 'prod related config';
    config1.cscfga__Contract_Term__c = 12;
    config1.cscfga__total_contract_value__c = 325;
    config1.cscfga__Product_Basket__c = basket.id;
  config1.configGUID__c = '12345';
  config1.csordtelcoa__Replaced_Product_Configuration__c = config.id;
    insert config1;
  
  //DPG - 2577 - start
  Marketable_Offer__c marOff = new Marketable_Offer__c();
  marOff.Name = 'Enterprise Mobility Managed Service';
  marOff.Offer_ID__c = 'DMCAT_Offer_000854';
  insert marOff;
  //DPG - 2577 - end
    
 // List<csord__Subscription__c> subLst = new List<csord__Subscription__c>();
    csord__Subscription__c subs=new csord__Subscription__c();
    subs.name  = 'test subs';
    subs.csord__Identification__c = 'test identity';
    subs.Billing_Account__c = billingAccount.id;
    subs.csordtelcoa__Product_Configuration__c = newConfig.id;
    subs.csord__Status__c ='Active';
    subs.MarketableOffer__c = marOff.id;  
    subs.csord__Account__c = AccLst[0].Id;
    subLst.add(subs);
      
    insert subLst;
      
    List<csord__Subscription__c> subLst2 = new List<csord__Subscription__c>();
    csord__Subscription__c subs1=new csord__Subscription__c();
    subs1.name  = 'test subs';
    subs1.csord__Identification__c = 'test identity';
    subs1.Billing_Account__c = billingAccount.id;
    subs1.csordtelcoa__Product_Configuration__c = testConfig.id;
    subs1.csord__Account__c = AccLst[0].Id;
    subs1.csord__Status__c ='Active';
    subs1.MarketableOffer__c = marOff.id;
    subLst2.add(subs1); 
   
    insert subLst2;
  //DPG - 2577 - start
    List<csord__Subscription__c> subLst1 = new List<csord__Subscription__c>();
    csord__Subscription__c subten=new csord__Subscription__c();
    subten.name  = 'test subs';
    subten.csord__Identification__c = 'test identity';
    subten.Billing_Account__c = billingAccount.id;
    subten.csordtelcoa__Product_Configuration__c = testConfig.id;
    subten.csord__Account__c = AccLst[0].Id ;
    subten.TenancyID__c = '12345';
    subten.csord__Status__c ='Active';
    subten.MarketableOffer__c = marOff.id;
    subLst1.add(subten); 
    //DPG - 2577 - end
  insert subLst1; 
  
  //List<csord__Service__c> servLst = new List<csord__Service__c>();
    csord__Service__c serv1 = new csord__Service__c();
    serv1.name ='tst service1';
    serv1.csord__Identification__c  = 'test identify1';
    serv1.csord__Status__c = 'Service created';
    serv1.csord__Subscription__c  = subs.id;
    serv1.csordtelcoa__Service_Number__c = '3';
    serv1.Initial_Activation_Date__c = System.today()-365;
    serv1.Initial_Activation_DateTime__c = System.now()-365;
    serv1.csordtelcoa__Product_Configuration__c = newConfig.id;
    servLst.add(serv1); 
    
    csord__Service__c serv2 = new csord__Service__c();
    serv2.name ='tst service1';
    serv2.csord__Identification__c  = 'test identify1';
    serv2.csord__Status__c = 'Service created';
    serv2.csord__Subscription__c  = subs1.id;
    serv2.csordtelcoa__Service_Number__c = '3';
    serv2.Initial_Activation_Date__c = System.today()-365;
    serv2.csordtelcoa__Product_Configuration__c = testConfig.id;
    servLst.add(serv2); 
  insert servLst;
  
 // List<cscfga__Product_Configuration__c> MacdprodConfigLst = new List<cscfga__Product_Configuration__c>();  
    cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
    replacedConfig.name = 'Replaced config';
    replacedConfig.csordtelcoa__Replaced_Subscription__c = subs.id;
    replacedConfig.csordtelcoa__Replaced_Service__c = serv1.id;
    MacdprodConfigLst.add(replacedConfig);
    
    cscfga__Product_Configuration__c deviceConfig = new cscfga__Product_Configuration__c();
    deviceConfig.name = 'device config';
    deviceConfig.csordtelcoa__Replaced_Subscription__c = subs.id;
    deviceConfig.csordtelcoa__Replaced_Service__c = serv1.id;
    MacdprodConfigLst.add(deviceConfig);
  insert MacdprodConfigLst;

    csord__Subscription__c subsdev=new csord__Subscription__c();
    subsdev.name  = 'test subs';
    subsdev.csord__Identification__c = 'test identity';
    subsdev.Billing_Account__c = billingAccount.id;
    subsdev.csordtelcoa__Product_Configuration__c = deviceConfig.id;
    subsdev.MarketableOffer__c = marOff.id;  
    subsdev.csord__Account__c = AccLst[0].Id;
  insert subsdev;
  
    csord__Service__c servDev = new csord__Service__c();
    servDev.name ='tst service1';
    servDev.csord__Identification__c  = 'test identify1';
    servDev.csord__Status__c = 'Service created';
    servDev.csord__Subscription__c  = subsdev.id;
    servDev.csordtelcoa__Service_Number__c = '3';
    servDev.Initial_Activation_Date__c = System.today()-365;
    servDev.csordtelcoa__Product_Configuration__c = deviceConfig.id; 
  insert servDev;
  
    List<cscfga__Attribute__c>lstAttribute= new List<cscfga__Attribute__c>();
    cscfga__Attribute__c attreplace = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = replacedConfig.Id,
    Name = 'Test',
    cscfga__Recurring__c=true,
    cscfga__Is_Line_Item__c=true,
    cscfga__Value__c = '10',
    cscfga__is_active__c = true
    );
    lstAttribute.add(attreplace);
    
    cscfga__Attribute__c attr = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = deviceConfig.Id,
    Name = 'Test',
    cscfga__Recurring__c=true,
    cscfga__Is_Line_Item__c=true,
    cscfga__Value__c = '10',
    cscfga__is_active__c = true
    );
    lstAttribute.add(attr); 
  cscfga__Attribute__c attr1 = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = config.Id,
    Name = 'GUID',
    cscfga__Recurring__c=false,
    cscfga__Is_Line_Item__c=false,
    cscfga__Value__c = 'cf96d575-7198-2799-4d34-cd6eed1e4c71',
    cscfga__is_active__c = true
    );
    lstAttribute.add(attr1);
  cscfga__Attribute__c attr2 = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = config.Id,
    Name = 'BillingAccountShadowNextGenAC',
    cscfga__Recurring__c=false,
    cscfga__Is_Line_Item__c=false,
    cscfga__Value__c = '700000504654',
    cscfga__is_active__c = true
    );
    lstAttribute.add(attr2);
      
    cscfga__Attribute__c bauAttrOC = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = newConfig.Id,
    Name = 'OC',
    cscfga__Recurring__c=true,
    cscfga__Is_Line_Item__c=true,
    cscfga__Value__c = '100',
    cscfga__is_active__c = true
    );
    lstAttribute.add(bauAttrOC);
      
    cscfga__Attribute__c bauAttrRC = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = newConfig.Id,
    Name = 'RC',
    cscfga__Recurring__c=true,
    cscfga__Is_Line_Item__c=true,
    cscfga__Value__c = '10',
    cscfga__is_active__c = true
    );
    lstAttribute.add(bauAttrRC);
      
    cscfga__Attribute__c bauAttrRenewableRevenue = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = newConfig.Id,
    Name = 'RenewableRevenue',
    cscfga__Recurring__c=true,
    cscfga__Is_Line_Item__c=true,
    cscfga__Value__c = '10',
    cscfga__is_active__c = true
    );
    lstAttribute.add(bauAttrRenewableRevenue);
      
    cscfga__Attribute__c bauAttrTechTransRevenue = new cscfga__Attribute__c(
    cscfga__Product_Configuration__c = newConfig.Id,
    Name = 'TechTransRevenue',
    cscfga__Recurring__c=true,
    cscfga__Is_Line_Item__c=true,
    cscfga__Value__c = '10',
    cscfga__is_active__c = true
    );
    lstAttribute.add(bauAttrTechTransRevenue);
    insert lstAttribute;
    
    List<csoe__Non_Commercial_Schema__c> ncsLst= new List<csoe__Non_Commercial_Schema__c>();
    csoe__Non_Commercial_Schema__c cnse = new csoe__Non_Commercial_Schema__c();
    cnse.name = 'NumberManagementv1';
    ncsLst.add(cnse);
    insert ncsLst;
        
    List<Asset> AssetLst = new List<Asset>();
    Asset AssetId= new Asset();
    AssetId.Name='test';
    AssetId.AccountId=acc.id;
    AssetId.AssetID__c='12345';
    AssetId.Status='Installed';
    AssetId.Price=10;
    AssetId.csord__Service__c=serv2.id;
    AssetId.Subscription__c=subs1.id;
    AssetLst.add(AssetId);
    insert AssetLst;
    
    List<Attachment> AttachmentLst = new List<Attachment>();
    Attachment attachment = new Attachment();
    String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"RESERVED","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"}]}';
    attachment.Body = Blob.valueOf(encodedContentsString);
    attachment.Name = String.valueOf('NumberManagementv1_schema.json');
    attachment.ParentId = config.Id;
    AttachmentLst.add(attachment);
    insert AttachmentLst;

    //Pooja : Added CustomConfigurationOptions__c in test setup data as part of Spring'20 Upgrade
    List<CustomConfigurationOptions__c> custConfigList  =   new List<CustomConfigurationOptions__c>();
    CustomConfigurationOptions__c oCustConfig1   =   new CustomConfigurationOptions__c();
    oCustConfig1.Name = 'CommercialConfiguration';
    oCustConfig1.Enrichment_Basket_Stage__c = 'Commercial Configuration';
    oCustConfig1.External_Id__c = 'CCO4';
    oCustConfig1.Opportunity_Stage__c = 'Develop';
    custConfigList.add(oCustConfig1);
    CustomConfigurationOptions__c oCustConfig2   =   new CustomConfigurationOptions__c();
    oCustConfig2.Name = 'Draft';
    oCustConfig2.Enrichment_Basket_Stage__c = 'Draft';
    oCustConfig2.External_Id__c = 'CCO7';
    custConfigList.add(oCustConfig2);
    insert custConfigList;
      
    //DPG-2319 START
    cspmb__Price_Item__c  userSupportCommercial = new cspmb__Price_Item__c(
            Name = 'User Support',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            Technical_Support__c = 'Business hours',
            Feature_Level__c = 'Advanced',
            ProdSpecId__c = 'DMCAT_ProductSpecification_000940',
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'User Support',
            cspmb__Product_Definition_Name__c = 'User Support',
            External_Id__c = 'DMCAT_Offer_000854_DMCAT_ProductSpecification_000940_DMCAT_RecurringCharge_000852_6411',
            Charge_Id__c='DMCAT_RecurringCharge_000852',
            BillingSpecId__c = 'BSUSG003_CB',
            Billing_Description__c = 'User support - Standard - business hours',
            Offer_Id__c = 'DMCAT_Offer_000854',
            cspmb__Type__c = 'Commercial Product',
cspmb__Role__c = 'Basic'
     );
      
     Insert userSupportCommercial;
    //DPG-2319 End
    
      // Arinjay Start - 221460
      cscfga__Product_Configuration__c parentConfig201 = new cscfga__Product_Configuration__c();
      parentConfig201.configGUID__c = 'PQRS1234';
      insert parentConfig201;
      
      cscfga__Product_Configuration__c config201 = new cscfga__Product_Configuration__c();
      config201.configGUID__c = 'ABCD1234';
      config201.cscfga__Parent_Configuration__c = parentConfig201.id;
      config201.csordtelcoa__Replaced_Product_Configuration__c = parentConfig201.id;
      insert config201;
      // Arinjay End
    }
    //Added by Aman Soni as a part of EDGE-148733 || End
    
    /*****************************************************************************************************
    * Method Name : unreserveNumbersTest
    * Description : Used to simulate and test the logic of unreserveNumbers method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *****************************************************************************************************/
    static testmethod void unreserveNumbersTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();             
        cscfga__Product_Configuration__c config =[Select id,name from cscfga__Product_Configuration__c where name = 'prod config'];//Added by Aman Soni as a part of EDGE-148733
        Attachment attachment =[Select id,name,Body,ParentId from Attachment where ParentId =: config.Id];//Added by Aman Soni as a part of EDGE-148733
        inputMap.put('GetPCData', config.Id);
        inputMap.put('UnreserveNumbers', '1'); 
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(true, inputMap.size()>0);
    }
    
    /*******************************************************************************************************
    * Method Name : getReservedNumbersTest
    * Description : Used to simulate and test the logic of getReservedNumbers method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *******************************************************************************************************/
    static testmethod void getReservedNumbersTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetReservedNumbers','1');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(true, inputMap.size()>0);
    }

    /*******************************************************************************************************
   * Method Name : getReservedNumbersTest1
   * Description : Used to simulate and test the logic of getReservedNumbers method in SolutionActionHelper
   * Parameters  : NA
   * Return      : NA
   *******************************************************************************************************/
    static testmethod void getReservedNumbersTest1() {      
        Account account =[Select id,name from Account where name = 'Burlington'];//Added by Aman Soni as a part of EDGE-148733
        cscfga__Product_Configuration__c config =[Select id,name from cscfga__Product_Configuration__c where name = 'prod config'];//Added by Aman Soni as a part of EDGE-148733
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetReservedNumbers', config.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetReservedNumbers'));
    }

    
    /**********************************************************************************************************
    * Method Name : DetachAccountFromSiteTest
    * Description : Used to simulate and test the logic of DetachAccountFromSite method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************************/
    static testmethod void DetachAccountFromSiteTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        Account account =[Select id,name from Account where name = 'Test Account'];//Added by Aman Soni as a part of EDGE-148733
        cscrm__Address__c address =[Select id,name,Address_ID__c from cscrm__Address__c limit 1];//Added by Aman Soni as a part of EDGE-148733
        cscrm__Site__c site =[Select id,name,cscrm__Account__c,cscrm__Installation_Address__c,Legacy__c from cscrm__Site__c limit 1];//Added by Aman Soni as a part of EDGE-148733
        inputMap.put('DetachAccountFromSite', address.Address_ID__c);
        //inputMap.put('DetachAccountFromSite', '12345');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('DetachAccountFromSite'));
        System.assertEquals('Success', returnMap.get('DetachAccountFromSite'));
    }
    
    /**********************************************************************************************************
    * Method Name : DetachAccountFromSiteTest1
    * Description : Used to simulate and test the logic of DetachAccountFromSite method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************************/
    static testmethod void DetachAccountFromSiteTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('DetachAccountFromSite', '');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('DetachAccountFromSite'));
        System.assertEquals('No action performed', returnMap.get('DetachAccountFromSite'));
    }
    
    /**********************************************************************************************************
    * Method Name : DetachAccountFromSiteTest2
    * Description : Used to simulate and test the logic of DetachAccountFromSite method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************************/
    static testmethod void DetachAccountFromSiteTest2() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('DetachAccountFromSite', '1');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('DetachAccountFromSite'));
        System.assert(((String)returnMap.get('DetachAccountFromSite')).contains('Failed'));
    }
    
    /**********************************************************************************************
    * Method Name : GetBasketTest
    * Description : Used to simulate and test the logic of GetBasket method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetBasketTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        inputMap.put('GetBasket', basket.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket'));
        System.assertNotEquals('', returnMap.get('DetachAccountFromSite'));
    }
    
    /**********************************************************************************************
    * Method Name : GetBasketTest1
    * Description : Used to simulate and test the logic of GetBasket method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetBasketTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetBasket', '');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket'));
        System.assertEquals('', returnMap.get('GetBasket'));
    }
    
    /**********************************************************************************************
    * Method Name : GetBasketTest2
    * Description : Used to simulate and test the logic of GetBasket method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetBasketTest2() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetBasket', '123');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket'));
        System.assertNotEquals('', returnMap.get('GetBasket'));
    }
    
    
    
    /**********************************************************************************************
    * Method Name : GetPCDataTest
    * Description : Used to simulate and test the logic of GetPCData method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetPCDataTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        inputMap.put('GetPCData', pc.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetPCData'));
        System.assertNotEquals('', returnMap.get('GetPCData'));
    }
    
    /**********************************************************************************************
    * Method Name : GetOeAttachmentTest
    * Description : Used to simulate and test the logic of GetOeAttachment logic in SolutionActionHelper - Spring20 Upgrade
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetOeAttachmentTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        inputMap.put('GetOeAttachment', pc.Id);
        inputMap.put('AttachmentName', 'NumberManagement');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetOeAttachment'));
    }
    
    /**********************************************************************************************
    * Method Name : GetPCIdTest
    * Description : 
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetPCIdTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, String> returnMapOE = new Map<String, String>();
       // cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Configuration__c pc = [Select Id from cscfga__Product_Configuration__c WHERE Name='Replaced config' LIMIT 1];
        inputMap.put('getPCId', pc.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.AssertNotEquals(null,returnMap);
    }
    
    /**********************************************************************************************
    * Method Name : GetPCDataTest1
    * Description : Used to simulate and test the logic of GetPCData method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetPCDataTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        inputMap.put('GetPCData', '');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetPCData'));
        System.assertEquals('', returnMap.get('GetPCData'));
    }
    
    /**********************************************************************************************
    * Method Name : GetPCDataTest2
    * Description : Used to simulate and test the logic of GetPCData method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetPCDataTest2() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        inputMap.put('GetPCData', '1');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetPCData'));
        System.assertEquals('', returnMap.get('GetPCData'));
    }
    
    /**********************************************************************************************
    * Method Name : GetSiteIdTest
    * Description : Used to simulate and test the logic of GetSiteId method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetSiteIdTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetSiteId', '1');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        //System.assert(returnMap.containsKey('User'));
    }
    
    /********************************************************************************************************
    * Method Name : GetServiceStartDateTest
    * Description : Used to simulate and test the logic of GetServiceStartDate method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************/
    static testmethod void GetServiceStartDateTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        //csord__Service__c service = TestDataFactory.generateService();
        csord__Service__c service = [Select Id,csordtelcoa__Product_Configuration__c from csord__Service__c WHERE Name='tst service1' LIMIT 1];
        inputMap.put('GetServiceStartDate', service.csordtelcoa__Product_Configuration__c);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetServiceStartDate'));
        System.assertNotEquals('', returnMap.get('GetServiceStartDate'));
    }
    
    /********************************************************************************************************
    * Method Name : GetServiceStartDateTest1
    * Description : Used to simulate and test the logic of GetServiceStartDate method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************/
    static testmethod void GetServiceStartDateTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetServiceStartDate', '123');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetServiceStartDate'));
        System.assertEquals('', returnMap.get('GetServiceStartDate'));
    }
    
    /********************************************************************************************************
    * EDGE-93425
    * Written by  : Sasidhar Devarapalli
    * Method Name : getServiceForMAC_Test
    * Description : Used to simulate and test the logic of EDGE-93425 method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA
    ********************************************************************************************************/
    static testmethod void getServiceForMAC_Test() {
        Map<String, Object> inputMap = new Map<String, Object> ();
      //  cscfga__Product_Configuration__c  productConfiguration = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Configuration__c productConfiguration = [Select Id from cscfga__Product_Configuration__c WHERE Name='Replaced config' LIMIT 1];
        inputMap.put('getServiceForMAC', productConfiguration.id);
        //csord__Service__c service = TestDataFactory.generateService();
       csord__Service__c service = [Select Id,csordtelcoa__Product_Configuration__c from csord__Service__c WHERE Name='tst service1' LIMIT 1];
        inputMap.put('GetServiceStartDate', service.csordtelcoa__Product_Configuration__c);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('getServiceForMAC'));
        System.assertNotEquals('', returnMap.get('getServiceForMAC'));
    }

    
    /*------------------------------------------------------------
   EDGE-168275, EDGE-164350 
   Method: getChildServicesForDeviceCare_Test
   Description: 
   <03-09-2020> <Manish Berad>
   ------------------------------------------------------------*/
  static testmethod void getChildServicesForDeviceCare_Test() {
        Map<String, Object> inputMap = new Map<String, Object> ();
       // cscfga__Product_Configuration__c  productConfiguration = TestDataFactory.generateProductConfiguration();
       cscfga__Product_Configuration__c productConfiguration = [Select Id from cscfga__Product_Configuration__c WHERE Name='Replaced config' LIMIT 1]; 
       inputMap.put('getChildServicesForDeviceCare', productConfiguration.id);
       //csord__Service__c service = TestDataFactory.generateService();
       csord__Service__c cs = [Select Id,csordtelcoa__Product_Configuration__c from csord__Service__c WHERE Name='tst service1' LIMIT 1];
       csord__Subscription__c sub = [Select Id FROM csord__Subscription__c WHERE Name='test subs' LIMIT 1];
       csord__Service__c childService=new csord__Service__c();
       childService.Initial_Activation_Date__c=Date.today();
       childService.csord__Status__c='Connected';
       childService.Name='Mobile Device Care Purchase';
       //childService.csord__Service__c=service.Id;
       childService.csord__Service__c=cs.Id;
       childService.csordtelcoa__Product_Configuration__c=cs.csordtelcoa__Product_Configuration__c;
       childService.csord__Subscription__c=sub.Id;
       childService.csord__Identification__c='TestValue';
       insert childService;
        
        inputMap.put('getChildServicesForDeviceCare', childService.csordtelcoa__Product_Configuration__c);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest(); 
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('getChildServicesForDeviceCare'));
      }
    /*******************************************************************************************************************************************
    * EDGE-93425
    * Written by  : Sasidhar Devarapalli
    * Method Name : getServiceForMAC_Test1
    * Description : Used to simulate and test the logic of EDGE-93425 method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA
    ********************************************************************************************************/
    static testmethod void getServiceForMAC_Test1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('getServiceForMAC', '12345');
        cscfga__Product_Configuration__c testConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'Test Config'];
        inputMap.put('GetServiceStartDate', string.valueof(testConfig.id));
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('getServiceForMAC'));
        System.assertNotEquals('', returnMap.get('getServiceForMAC'));

    }

    /*******************************************************************************************************
    * Method Name : GetMobileUnitPriceTest
    * Description : Used to simulate and test the logic of GetMobileUnitPrice method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *******************************************************************************************************/
    static testmethod void GetMobileUnitPriceTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cspmb__Add_On_Price_Item__c addPI = new cspmb__Add_On_Price_Item__c(cspmb__Add_On_Price_Item_Code__c = 'Mobile Access', Message_Bank__c = 'Test', ProdSpecId__c = '12345');
        INSERT addPI;
        inputMap.put('GetMobileUnitPrice', 'Test');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetMobileUnitPrice'));
        System.assertNotEquals('', returnMap.get('GetMobileUnitPrice'));
    }
    
    /*******************************************************************************************************
    * Method Name : GetMobileUnitPriceTest1
    * Description : Used to simulate and test the logic of GetMobileUnitPrice method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *******************************************************************************************************/
    static testmethod void GetMobileUnitPriceTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetMobileUnitPrice', 'Test');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetMobileUnitPrice'));
        System.assertEquals('', returnMap.get('GetMobileUnitPrice'));
    }
    /*******************************************************************************************************
    * Method Name : GetSubscriptionForConfigurationTest
    * Description : Used to simulate and test the logic of GetSubscriptionForConfiguration method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *******************************************************************************************************/
    static testmethod void GetSubscriptionForConfigurationTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetSubscriptionForConfiguration', 'Test');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetSubscriptionForConfiguration'));
        System.assertEquals('', returnMap.get('GetSubscriptionForConfiguration'));
    }



 /*******************************************************************************************************
    * Method Name : GetServiceForConfigurationTest
    * Description : Used to simulate and test the logic of GetServiceForConfiguration method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    *******************************************************************************************************/
    static testmethod void GetServiceForConfigurationTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetServiceForConfiguration', 'Test');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetServiceForConfiguration'));
        System.assertEquals('', returnMap.get('GetServiceForConfiguration'));
    }
    /*******************************************************************************************************
    * Method Name : GetSmOptionsTest
    * Description : Used to simulate and test the logic of getting SM Options method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetSmOptionsTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetSmOptions', '');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetSmOptions'));
    }

    /*******************************************************************************************************
    * Method Name : GetExistingTenancySubscriptionsTest
    * Description :
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetExistingTenancySubscriptionsTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('getExistingTenancySubscriptions', '');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('getExistingTenancySubscriptions'));
        //System.assertEquals('', returnMap.get('getExistingTenancySubscriptions'));
    }

  /*******************************************************************************************************
    * Method Name : GetExistingTenancySubscriptionsForBillingTest
    * Description :
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetExistingTenancySubscriptionsForBillingTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
    Billing_Account__c billAcc = [SELECT id, Account__c, Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c = '700000449806' ];
        inputMap.put('getExistingTenancySubscriptionsForBilling', billAcc.id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        //System.assert(returnMap.containsKey('getExistingTenancySubscriptionsForBilling'));
        System.assertnotEquals(null, returnMap.get('getExistingTenancySubscriptionsForBilling'));
    }
  
     /*******************************************************************************************************
    * Method Name : GetCorrelationIdTest
    * Description :
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetCorrelationIdTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('CorrelationId', '12334444');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(!returnMap.containsKey('TCVMap'));
      
    }

    /*******************************************************************************************************
    * Method Name : getETCChargesForCMPDeviceTest
    * Jira : EDGE - 66137
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void getETCChargesForCMPDeviceTest() {
      cscfga__Product_Configuration__c replacedConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'Replaced config'];//Added by Aman Soni as a part of EDGE-148733 
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('CalculateEtc', '');
        inputMap.put('DisconnectionDate', String.valueOf(System.today()+30));
        inputMap.put('etc_Term','24');
        inputMap.put('etc_UnitPrice',5.00);
        inputMap.put('ProdConfigId',replacedConfig.id);
        //inputMap.put('deviceConfigID',deviceConfig.id);
        
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Test.startTest();        
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('CalculateEtc'));
    }
    
    /*******************************************************************************************************
    * Method Name : getETCChargesForNGUCTest
    * Jira : EDGE - 66137
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void getETCChargesForNGUCTest() {
        cscfga__Product_Configuration__c deviceConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'device config'];//Added by Aman Soni as a part of EDGE-148733
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('getETCChargesForNGUC', '');
        inputMap.put('DisconnectionDate', String.valueOf(System.today()+30));
        inputMap.put('etc_Term','24');
        inputMap.put('etc_UnitPrice',5.00);
        inputMap.put('ProdConfigId',deviceConfig.id);
        
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Test.startTest();        
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('getETCChargesForNGUC'));    
    }
    //EDGE-188712 - added test method
    static testmethod void getETCChargesForAMTest() {
        cscfga__Product_Configuration__c deviceConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'device config'];//Added by Aman Soni as a part of EDGE-148733
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('getETCChargesForAM', '');
        inputMap.put('DisconnectionDate', String.valueOf(System.today()+30));
        inputMap.put('etc_Term','24');
        inputMap.put('etc_UnitPrice',5.00);
        inputMap.put('ProdConfigId',deviceConfig.id);
        
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Test.startTest();        
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('getETCChargesForAM'));    
    }
    /*******************************************************************************************************
    * Method Name : getETCChargesForTIDTest
    * EDGE - 111053
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void getETCChargesForTIDTest() {
        cscfga__Product_Configuration__c newConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'new config'];//Added by Aman Soni as a part of EDGE-148733
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('getETCChargesForTID', '');
        inputMap.put('DisconnectionDate', String.valueOf(System.today()+30));
        inputMap.put('ContractTerm','24');
        inputMap.put('ETCPercentage','60');
        inputMap.put('ProdConfigId',newConfig.id);
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Test.startTest();        
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('getETCChargesForTID'));   
    } 
    /*******************************************************************************************************
    * Method Name : GetAssetTestPositive
    * Description : EDGE-148733- For GetAssetForConfiguration method
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetAssetTestPositive(){
        cscfga__Product_Configuration__c testConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'Test Config'];//Added by Aman Soni as a part of EDGE-148733
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetAssetForConfiguration',string.valueof(testConfig.id));
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        System.assert(returnMap.containsKey('GetAssetForConfiguration'));      
    }
   /*******************************************************************************************************
    * Method Name : GetAssetTestNegative
    * Description : EDGE-148733- For GetAssetForConfiguration method
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetAssetTestNegative(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetAssetForConfiguration', '12334444');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        system.debug(returnMap.Get('GetAssetForConfiguration'));
       System.assert(!returnMap.containsKey('GetAssetForConfigurtion'));
      
    }
    /*******************************************************************************************************
    * Method Name : GetPurchaseOrderNoTestPositive
    * Description : DPG-5626- For GetPurchaseOrderNoForConfiguration method
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetPurchaseOrderNoTestPositive(){
        cscfga__Product_Configuration__c testConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'Test Config'];//Added by Aman Soni as a part of EDGE-148733
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetPurchaseOrderNoForConfiguration',string.valueof(testConfig.id));
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        System.assert(returnMap.containsKey('GetPurchaseOrderNoForConfiguration'));      
    }
   /*******************************************************************************************************
    * Method Name : GetPurchaseOrderNoTestNegative
    * Description : EDGE-5626- For GetPurchaseOrderNoForConfiguration method
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void GetPurchaseOrderNoTestNegative(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetPurchaseOrderNoForConfiguration', '12334444');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        system.debug(returnMap.Get('GetPurchaseOrderNoForConfiguration'));
       System.assert(returnMap.containsKey('GetPurchaseOrderNoForConfiguration'));
      
    }
    
    /*******************************************************************************************************
    * Method Name : updateBasketOppySynFlagPositive
    * Description : Gnana : Spring'20 Upgradae
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void updateBasketOppySynFlagPositive(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c bask = [Select id, cscfga__Opportunity__r.Product_Type__c , csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where csbb__Synchronised_with_Opportunity__c = true];
        inputMap.put('updateBasketOppySynFlag', bask.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        cscfga__Product_Basket__c bask1 = [Select id, cscfga__Opportunity__r.Product_Type__c , csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where id = :bask.Id];
        system.assertEquals(false,bask1.csbb__Synchronised_with_Opportunity__c);
      
    }
    
    /*******************************************************************************************************
    * Method Name : updateBasketOppySynFlagNegative
    * Description : Gnana : Spring'20 Upgradae
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void updateBasketOppySynFlagNegative(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c bask = [Select id, cscfga__Opportunity__r.Product_Type__c , csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where csbb__Synchronised_with_Opportunity__c = false];
        System.debug('basket syn flag...'+bask.csbb__Synchronised_with_Opportunity__c);
        inputMap.put('updateBasketOppySynFlag', bask.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        cscfga__Product_Basket__c bask1 = [Select id, cscfga__Opportunity__r.Product_Type__c , csbb__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where id = :bask.Id];
        system.assertEquals(false,bask1.csbb__Synchronised_with_Opportunity__c);
      
    }

    /*******************************************************************************************************
    * Method Name : updateBasketStageDraft
    * Description : Gnana : Spring'20 Upgradae
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void updateBasketStageDraft(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c bask = [Select id, csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where csbb__Synchronised_with_Opportunity__c = false];
        System.debug('basket stage...'+bask.csordtelcoa__Basket_Stage__c);
        inputMap.put('updateBasketStageToDraft', bask.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        cscfga__Product_Basket__c bask1 = [Select id, csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where id = :bask.Id];
        system.assertEquals('Draft',bask1.csordtelcoa__Basket_Stage__c);
      
    }

    /*******************************************************************************************************
    * Method Name : updateBasketDetails
    * Description : Pooja : Spring'20 Upgradae
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void updateBasketDetails() {
        Map<String, Object> inputMap        =   new Map<String, Object> ();
        Map<String, Object> returnMap       =   new Map<String, Object>();
        cscfga__Product_Basket__c oBasket   =   [SELECT Id,csordtelcoa__Basket_Stage__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c where csbb__Synchronised_with_Opportunity__c = false];
        oBasket.csbb__Synchronised_With_Opportunity__c  =   true;
        update oBasket;
        System.assertNotEquals('Commercial Configuration',oBasket.csordtelcoa__Basket_Stage__c);
        System.assertNotEquals(false,oBasket.csbb__Synchronised_With_Opportunity__c); 

        inputMap.put('updateBasketDetails', oBasket.Id);
        
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales) {
            returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();

        cscfga__Product_Basket__c oBasket1 = [SELECT Id,csordtelcoa__Basket_Stage__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c WHERE Id=:oBasket.Id];
        system.assertEquals('Commercial Configuration',oBasket1.csordtelcoa__Basket_Stage__c);  
        System.assertEquals(false,oBasket1.csbb__Synchronised_With_Opportunity__c);  
        System.assertEquals(false,oBasket1.csordtelcoa__Synchronised_with_Opportunity__c);  
    }   //End of setBasketStageOppySyncFlag()
    
    /*******************************************************************************************************
    * Method Name : updateBasketStageDraft
    * Description : AB : Spring'20 Upgradae
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void updateSolutionTotals(){
        csord__Solution__c sol = [SELECT Id,Name FROM csord__Solution__c WHERE Name = 'Test Solution'];
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            SolutionActionHelper.updateSolutionTotals(sol.Id);
        }
        Test.stopTest();
        csord__Solution__c sol1 = [SELECT Id,cssdm__total_contract_value__c,Name FROM csord__Solution__c WHERE Name = 'Test Solution'];
        System.debug('sol1.cssdm__total_contract_value__c...'+sol1.cssdm__total_contract_value__c);
        system.assertEquals(1234.45,sol1.cssdm__total_contract_value__c);    
    }   

    /**********************************************************************************************
    * Method Name : updateISPOSReversalRequiredTest
    * Description : Description: EDGE-164351 test to update basket field Is_OF_POS_Reversal_Required__c on the basis of RedeemFundCopy attribute
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void updateISPOSReversalRequiredTest(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        inputMap.put('updateISPOSReversalRequired', basket.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
    cscfga__Product_Basket__c prodBasket = [Select id,Is_OF_POS_Reversal_Required__c
                                                      from cscfga__Product_Basket__c
                                                      where id = :basket.Id limit 1];
     System.assert(prodBasket.Is_OF_POS_Reversal_Required__c);
      }
    
     /**********************************************************************************************************************************************
    EDGE-165017
    Method: getLoginUserProfileNameTest
    Description:EDGE-165017 to fetch the profiles details
    <03-09-2020> <Manuga Kale>
    *******************************************************************************************************************/
    static testmethod void getLoginUserProfileNameTest(){
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('getLoginUserProfileName','');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        Object res=returnMap.get('getLoginUserProfileName');
        System.assert(res!=null);
    }
  
  /*******************************************************************************************************
    * Method Name : getBillingCheckInfoPositiveTest
    * Description : DPG-1878  - Positive Scenario
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void getBillingCheckInfoPositiveTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
    //Single query to fecth account id and billing account number as there is a parent child relationship
    Billing_Account__c billAcc = [SELECT id, Account__c, Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c = '700000504654' ];
    cscfga__Attribute__c guidAttr = [SELECT id, cscfga__Value__c, Name FROM cscfga__Attribute__c WHERE Name = 'GUID' ] ;
        inputMap.put('AccountId', billAcc.Account__c);
    inputMap.put('billingDetails', billAcc.Billing_Account_Number__c);
    inputMap.put('guid', guidAttr.cscfga__Value__c);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();        
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; 
        System.runAs(sales){
          returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        //System.assert(returnMap.containsKey('billingDetails'));
        System.assertEquals('false', returnMap.get('billingDetails'));
           
    }
  /*******************************************************************************************************
    * Method Name : getBillingCheckInfoNegativeTest 
    * Description : DPG-1878 - Negative Scenario
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void getBillingCheckInfoNegativeTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        //Single query to fecth account id and billing account number as there is a parent child relationship
    Billing_Account__c billAcc = [SELECT id, Account__c, Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c = '700000504654' ];
    inputMap.put('AccountId', billAcc.Account__c);
    inputMap.put('billingDetails', billAcc.Billing_Account_Number__c);
    inputMap.put('guid', ''); //sending GUID as blank will check the negative scenario
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();        
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; 
        System.runAs(sales){
          returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        //System.assert(returnMap.containsKey('billingDetails')); 
        System.assertEquals('true', returnMap.get('billingDetails'));  
    }
    /*******************************************************************************************************
    * Method Name : getActiveManagedServiceSubscriptionCheckInfoPositiveTest 
    * Description : DPG-2577 - Positive Scenario
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void getActiveManagedServiceSubscriptionCheckInfoPositiveTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('tenancyId', '12345'); 
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();        
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; 
        System.runAs(sales){
          returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        //boolean result = returnMap.get(tenancyId);
        System.assertEquals('true',returnMap.get('tenancyId'));
    }
    /*******************************************************************************************************
    * Method Name : getActiveManagedServiceSubscriptionCheckInfoNegativeTest 
    * Description : DPG-2577 - Negative Scenario
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void getActiveManagedServiceSubscriptionCheckInfoNegativeTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('tenancyId', '123456'); 
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();        
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; 
        System.runAs(sales){
          returnMap = SolutionActionHelper.getData(inputMap);
        }
        Test.stopTest();
        System.assertEquals('false',returnMap.get('tenancyId'));   
    }
    /*******************************************************************************************************
    * Method Name : getCommercialProductId 
    * Description : DPG-2319
    * Parameters  : String technicalSupport,String featureLevel,String productSpecificationId
    * Return      : String CommercialProductcodeid
    *******************************************************************************************************/
    static testmethod void getCommercialProductIdTest() {
        Id CommercialProductId = [SELECT Id FROM cspmb__Price_Item__c 
                                  WHERE External_Id__c = 'DMCAT_Offer_000854_DMCAT_ProductSpecification_000940_DMCAT_RecurringCharge_000852_6411'].Id;
         Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('getCommercialProductId', 'Business hours,Advanced,DMCAT_ProductSpecification_000940'); 
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
          returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals(CommercialProductId,returnMap.get('getCommercialProductId'));
         
    }
    /*******************************************************************************************************
    * Method Name : transitionDeviceCancelTest
    * Jira : EDGE - 66137
    * Parameters  : NA
    * Return      : NA
    *******************************************************************************************************/
    static testmethod void transitionDeviceCancelTest() {
        
        cscfga__Product_Configuration__c replacedConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'new config'];
        //cscfga__Product_Configuration__c replacedConfig =[Select id,name from cscfga__Product_Configuration__c where name = 'Replaced config'];//Added by Aman Soni as a part of EDGE-148733 
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('transitionDeviceCancel', '');
        inputMap.put('billingAccNum','abctest');
        inputMap.put('ConfigId',replacedConfig.id);
        //inputMap.put('deviceConfigID',deviceConfig.id);
        
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Test.startTest();        
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assertEquals('RCRT',returnMap.get('transitionDeviceCancel'));
    }
     
      /**********************************************************************************************
    * Method Name : GetOpptyTest
    * Description : Used to simulate and test the logic of GetOppty method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetOpptyTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        Account testAccount = TestDataFactory.generateAccount();
        testAccount.Customer_Status__c='Active';
        update testAccount;
        //insert testAccount;
        Opportunity testOppty = TestDataFactory.generateOpportunityForAccount(testAccount);
        inputMap.put('GetOppty', testOppty.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetOppty'));        
    }
    
        /**********************************************************************************************
    * Method Name : GetOpptyTest1
    * Description : Used to simulate and test the logic of GetOppty method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetOpptyTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetOppty', '');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetOppty'));
        System.assertEquals('', returnMap.get('GetOppty'));
    }
    
    /**********************************************************************************************
    * Method Name : GetOpptyTest2
    * Description : Used to simulate and test the logic of GetOppty method in SolutionActionHelper
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************/
    static testmethod void GetOpptyTest2() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('GetOppty', '123');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetOppty'));
        System.assertEquals('', returnMap.get('GetOppty'));
    }
    
    @isTest
    static void testUpdateBAUSolutionTotals(){
        BAUSolutionFields__mdt bauSolutionFieldInstance = new BAUSolutionFields__mdt();
        bauSolutionFieldInstance.Once_Off_Fields__c = 'OC';
        bauSolutionFieldInstance.Recurring_Fields__c = 'RC,RenewableRevenue,TechTransRevenue';
        csord__Solution__c sol = [SELECT Id,Name FROM csord__Solution__c WHERE Name = 'Test Solution'];
        Test.startTest();
            User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
            System.runAs(sales){
                SolutionActionHelper.updateBAUSolutionTotals(sol.Id);
            }
        Test.stopTest();
        csord__Solution__c sol1 = [SELECT Id,cssdm__total_one_off_charge__c,Name FROM csord__Solution__c WHERE Name = 'Test Solution'];
        system.assertEquals(100, sol1.cssdm__total_one_off_charge__c);    
    }  
    
    @isTest
    static void testGetDataForUpdateBAUSolution() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        csord__Solution__c sol = [SELECT Id,Name FROM csord__Solution__c WHERE Name = 'Test Solution'];
        inputMap.put('updateBAUSolutionTotals', sol.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();      
            returnMap = SolutionActionHelper.getData(inputMap);
        Test.stopTest();
        System.assertNotEquals(sol.Id, returnMap.get('updateBAUSolutionTotals'));
    }   
    
    //EDGE-216217
    @istest 
    static void testinvalidateOnBasketRedemptions(){        
        Account acc1 = ProductTestService.getNewAccount('Test Account');
        Opportunity opp1 = ProductTestFactory.getOpportunityBasic(acc1);
        opp1.Product_Type__c = 'Modular';
        insert opp1;
        cscfga__Product_Basket__c basket = [select id, cscfga__Basket_Status__c, cscfga__pricing_status__c from cscfga__Product_Basket__c limit 1];
        basket.cscfga__Opportunity__c = opp1.id; 
        update basket;
        String basketId = basket.id;
        
        System.Test.starttest();
        string response1 = SolutionActionHelper.invalidateOnBasketRedemptions(basketId);
        system.assertEquals(true,response1.contains('Success'));
        System.Test.stopTest();
    }
    
    @istest 
    static void testMarkBasketAsInvalid(){        
        Account acc1 = ProductTestService.getNewAccount('Test Account');
        Opportunity opp1 = ProductTestFactory.getOpportunityBasic(acc1);
        opp1.Product_Type__c = 'Modular';
        opp1.Basket_Redemption_amount__c = 999999;
        insert opp1;
        cscfga__Product_Basket__c basket = [select id,cscfga__Opportunity__r.AccountId, cscfga__Opportunity__r.Basket_Redemption_amount__c,
                                            cscfga__Basket_Status__c, cscfga__pricing_status__c from cscfga__Product_Basket__c limit 1];
        basket.cscfga__Opportunity__c = opp1.id; 
        update basket;
        String basketId = basket.id;
        
        System.Test.starttest();
        string response1 = SolutionActionHelper.markBasketAsInvalid(basketId);
        system.assertEquals(true,response1.contains('Success'));
        System.Test.stopTest();
    }
    @istest
    static void testGetReplacedConfigId(){
      Map<String, Object> inputMap = new Map<String, Object>();
      Map<String, Object> returnMap = new Map<String, Object>();
      cscfga__Product_Configuration__c pc=[Select id,configGUID__c,csordtelcoa__Replaced_Product_Configuration__c 
             from cscfga__Product_Configuration__c where configGUID__c = 'PQRS1234'];

      inputMap.put('replacedConfigId',pc.id);
      inputMap.put('attributeName','replacedConfigid');
      inputMap.put('GetConfigurationId','ABCD1234');
      System.Test.startTest();
      SolutionActionHelper.getReplacedConfigId(inputMap,returnMap);
      System.assertNotEquals(returnMap, null);
      System.Test.stopTest();
    }
    
    //DN: DIGI-456
    static testMethod void oeAM() {
        String inputKey = 'OrderEnrichment';
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put(inputKey, '');
        Test.startTest();
        Map<String, Object> response1 = SolutionActionHelper.getData(inputMap);
        system.assertEquals(true, response1 !=null);
        Test.stopTest();
    }
     static testMethod void errorTest() {
        String inputKey = 'oeError';
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put(inputKey, '');
        Test.startTest();
        Map<String, Object> response1 = SolutionActionHelper.getData(inputMap);
        system.assertEquals(true, response1.ContainsKey(inputKey));
        Test.stopTest();
    }
     static testMethod void CloneTest() {
        String inputKey = 'OrderReplacedId';
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put(inputKey, '');
        Test.startTest();
        Map<String, Object> response1 = SolutionActionHelper.getData(inputMap);
        system.assertEquals(true, response1.ContainsKey(inputKey));
        Test.stopTest();         
    }
}