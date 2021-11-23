/**================================================================
 * Name: IOTSharedPlanLookupTest
 * Class:IOTSharedPlanLookup
 * DIGI-5706
 * Created By: Pawan Singh
 ==================================================================*/

@isTest
public with sharing class IOTSharedPlanLookupTest {
    
  @TestSetup
  private static void testSetup()
  {
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='TestIOT', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;


    cspmb__Price_Item__c testPriceItem1 = new cspmb__Price_Item__c();
    testPriceItem1.Name = 'Shared Data Plan - LPWAN';
    testPriceItem1.Manufacturer__c = 'TestMan';
    testPriceItem1.Offer_Id__c = 'DMCAT_Offer_001522';
    testPriceItem1.offer__c = 'Shared Data Plan';
    testPriceItem1.ChargeType__c = 'RC';
    testPriceItem1.cspmb__Recurring_Charge__c = 75;
    testPriceItem1.Type__c='Data';
    testPriceItem1.Plan__c='100 KB';
    testPriceItem1.Plan_Type__c = 'LPWAN';

    cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
    testPriceItem2.Name = 'Shared Data Plan - LPWAN';
    testPriceItem2.Manufacturer__c = 'TestMan';
    testPriceItem2.Offer_Id__c = 'DMCAT_Offer_001522';
    testPriceItem2.offer__c = 'Shared Data Plan';
    testPriceItem2.ChargeType__c = 'RC';
    testPriceItem2.cspmb__Recurring_Charge__c = 75;
    testPriceItem2.Type__c='Data';
    testPriceItem2.Plan__c='1 MB';
    testPriceItem2.Plan_Type__c = 'LPWAN';
        
    cspmb__Price_Item__c testPriceItem3 = new cspmb__Price_Item__c();
    testPriceItem3.Name = 'Shared Data Plan - LPWAN';
    testPriceItem3.Manufacturer__c = 'TestMan';
    testPriceItem3.Offer_Id__c = 'DMCAT_Offer_001522';
    testPriceItem3.offer__c = 'Shared Data Plan';
    testPriceItem3.ChargeType__c = 'RC';
    testPriceItem3.cspmb__Recurring_Charge__c = 75;
    testPriceItem3.Type__c='Data';
    testPriceItem3.Plan__c='LPWAN';
    testPriceItem3.Plan_Type__c = '10 GB';

    cspmb__Price_Item__c testPriceItem4 = new cspmb__Price_Item__c();
    testPriceItem4.Name = 'Shared Data Plan - LPWAN';
    testPriceItem4.Manufacturer__c = 'TestMan';
    testPriceItem4.Offer_Id__c = 'DMCAT_Offer_001522';
    testPriceItem4.offer__c = 'Shared Data Plan';
    testPriceItem4.ChargeType__c = 'RC';
    testPriceItem4.cspmb__Recurring_Charge__c = 75;
    testPriceItem4.Type__c='Data';
    testPriceItem4.Plan__c='10 KB';
    testPriceItem4.Plan_Type__c = 'LPWAN';

    cspmb__Price_Item__c testPriceItem5 = new cspmb__Price_Item__c();
    testPriceItem5.Name = 'Shared Data Plan - LPWAN';
    testPriceItem5.Manufacturer__c = 'TestMan';
    testPriceItem5.Offer_Id__c = 'DMCAT_Offer_001522';
    testPriceItem5.offer__c = 'Shared Data Plan';
    testPriceItem5.ChargeType__c = 'RC';
    testPriceItem5.cspmb__Recurring_Charge__c = 75;
    testPriceItem5.Type__c='Data';
    testPriceItem5.Plan__c='100 MB';
    testPriceItem5.Plan_Type__c = 'LPWAN';

    cspmb__Price_Item__c testPriceItem6 = new cspmb__Price_Item__c();
    testPriceItem6.Name = 'Shared Data Plan - LTE';
    testPriceItem6.Manufacturer__c = 'TestMan';
    testPriceItem6.Offer_Id__c = 'DMCAT_Offer_001522';
    testPriceItem6.offer__c = 'Shared Data Plan';
    testPriceItem6.ChargeType__c = 'RC';
    testPriceItem6.cspmb__Recurring_Charge__c = 75;
    testPriceItem6.Type__c='Data';
    testPriceItem6.Plan__c='100 MB';
    testPriceItem6.Plan_Type__c = 'LTE';
      
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem1,testPriceItem2,testPriceItem3,testPriceItem4,testPriceItem5,testPriceItem6};
    insert PIList;
        
  }

  @IsTest
  private static void testGetRequiredAttributes()
  {   
    IOTSharedPlanLookup planTypeLookupCustom = new IOTSharedPlanLookup();  
    Test.startTest();

    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
    System.runAs(sales){    
    String res1  = planTypeLookupCustom.getRequiredAttributes();
    System.assertEquals('["OfferId","SelectPlanName","OfferTypeString"]', res1);
    }

    Test.stopTest();
  }

  @isTest
  private static void testDoLookupSearch()
  {
    Map<String,String> testplanTypeStringMap = new Map<String, String> {'OfferId'=>'DMCAT_Offer_001522', 'SelectPlanName'=>'LPWAN', 'OfferTypeString'=>Null};

    
    IOTSharedPlanLookup IOTSharedPlanLookup1 = new IOTSharedPlanLookup();
    Test.startTest();
    
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
    System.runAs(sales){
        List<cspmb__Price_Item__c> res1 = (List<cspmb__Price_Item__c>)IOTSharedPlanLookup1.doLookupSearch (testplanTypeStringMap,'',null,0,0);
            if(res1 != null && !res1.isEmpty()){
                System.assertEquals('10 KB', res1[0].Plan__c);
            }
    }
    
    Test.stopTest();
  }

  
}