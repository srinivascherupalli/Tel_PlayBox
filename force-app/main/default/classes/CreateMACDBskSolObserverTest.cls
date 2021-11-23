/******************************************************************************************************
*Class Name     : CreateMACDBskSolObserver
*Test Class     : CreateMACDBskSolObserverTest

Ch.No.    Developer Name          Date          Story Description
_________________________________________________________________
1.       Rajiv Singh            23.09.2021      DIGI-11609 - Create a Listener for Solution Processing Async CS APIs, and Respond to MS with Record Ids
******************************************************************************************************/
@isTest
public class CreateMACDBskSolObserverTest {
  @TestSetup
  
    static void makeData(){
   
        BDS_Notify_Settings__c bdsNotifySettingFeatureLevel = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingFeatureLevel.Name = 'Feature Level';
        bdsNotifySettingFeatureLevel.Value__c = 'FeatureLevelShadow';
        BDS_Notify_Settings__c bdsNotifySettingTechnicalSupport = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingTechnicalSupport.Name = 'Technical Support';
        bdsNotifySettingTechnicalSupport.Value__c = 'TechnicalSupportShadow';
        
        insert new List<BDS_Notify_Settings__c>{bdsNotifySettingFeatureLevel, bdsNotifySettingTechnicalSupport};
 
    Account acc = new Account();
    acc.Name = 'test acc';
    acc.CIDN__c = '123476';
    acc.Account_Status__c = 'Active';
    insert acc;
    
    Account acc2 = new Account();
    acc2.Name = 'test acc2';
    acc2.CIDN__c = '22222';
    acc2.Account_Status__c = 'Active';
    insert acc2;
    
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Profile prof = [SELECT Id FROM Profile WHERE NAME = 'System Administrator'];
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
    User tuser = new User(  firstname = 'test',
                          lastName = 'user 1',
                          email = uniqueName + '@test' + orgId + '.org',
                          Username = uniqueName + '@test' + orgId + '.org',
                          EmailEncodingKey = 'ISO-8859-1',
                          Alias = uniqueName.substring(18, 23),
                          TimeZoneSidKey = 'America/Los_Angeles',
                          LocaleSidKey = 'en_US',
                          LanguageLocaleKey = 'en_US',
                          ProfileId = prof.Id);
    
    insert tuser;
    
    
    Opportunity opp = new Opportunity();
    opp.AccountId = acc.Id;
    opp.Product_Domain__c = 'MOBILES';
    opp.Name = 'testopp';
    opp.StageName = 'New';
    opp.CloseDate = date.newInstance(2021,12,1);
    insert opp;
    system.debug('opp Id '+opp.Id);
    
    csord__Order__c ord = new csord__Order__c();
    ord.Name = 'testord';
    ord.csord__Identification__c = 'test123';
    ord.csordtelcoa__Opportunity__c = opp.Id;
    ord.csord__Status2__c = 'in Progress';
    
    insert ord;
    cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
    testBasket.csbb__Account__c = acc.Id;
    testBasket.channelFrom__c = 'TED-81 onlineAPI';
    testBasket.Name = 'ShowSubTestBasket';
    testBasket.cscfga__Opportunity__c = opp.Id;
    // testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
    insert testBasket;
    
    csord__Solution__c sol = new csord__Solution__c();
    sol.Name = 'Adaptive Mobility';
    sol.csord__Identification__c = 'testing';
    sol.csord__Account__c = acc.Id;
    sol.cssdm__product_basket__c = testBasket.Id;
    sol.csord__Order__c = ord.Id;
    insert sol;
    
    csord__Subscription__c sub = new csord__Subscription__c();
    sub.Name = 'testsub';
    sub.cssdm__solution_association__c = sol.Id;
    sub.csord__Account__c = acc.Id;
    sub.csord__Order__c = ord.Id;
    sub.csord__Identification__c = 'testing';
    sub.Point_of_No_Return_Reached__c = false;
    sub.csordtelcoa__Subscription_Number__c = 'SN-000101578';
    sub.customerFacingServiceId__c = '1234';
    sub.csord__Status__c = 'Active';
    insert sub;
    
    
    
    
    cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
    pd1.Name = 'IP Network';
    pd1.cscfga__Description__c = 'Description';
    insert pd1;
    
    cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
    testConfig.Name = 'IP Network';
    testConfig.cscfga__Product_Basket__c = testBasket.Id;
    insert testConfig;
    cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
    testConfig.Name = ' Unified Communication Enterprise';
    testConfig.cscfga__Product_Basket__c = testBasket.Id;
    insert testConfig1;
    
  }

  @isTest
  static void testMethod01(){
    Test.startTest();
    Map<Id,cscfga__Product_Configuration__c> productConfigMap= new Map<Id,cscfga__Product_Configuration__c>([SELECT ID FROM cscfga__Product_Configuration__c]);
    List<Id> productConfigIdList = new List<Id>();
    productConfigIdList.addAll(productConfigMap.keyset());
    CreateMACDBskSolObserver observer = new CreateMACDBskSolObserver();
    csordtelcoa.ChangeRequestObservable  o = new csordtelcoa.ChangeRequestObservable('CreateMACDBskSolObserver',productConfigIdList );
    observer.execute(o, null);
    Test.stopTest();
  }

  // Calling Observer class
  @isTest 
  static void testMethod02(){
    Test.startTest();
    Map<Id,cscfga__Product_Configuration__c> productConfigMap= new Map<Id,cscfga__Product_Configuration__c>([SELECT ID FROM cscfga__Product_Configuration__c]);
    List<Id> productConfigIdList = new List<Id>();
    productConfigIdList.addAll(productConfigMap.keyset());
    CreateMACDBskSolObserver observer = new CreateMACDBskSolObserver();
    productConfigIdList = new List<Id>();
    csordtelcoa.ChangeRequestObservable  o = new csordtelcoa.ChangeRequestObservable('CreateMACDBskSolObserver',productConfigIdList );
    observer.execute(o, null);
    Test.stopTest();
    
  }

}