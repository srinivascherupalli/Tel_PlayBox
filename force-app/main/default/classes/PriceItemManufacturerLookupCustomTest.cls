/*********************************************************************************************************************************
Class Name : PriceItemManufacturerLookupCustom
Test Class : PriceItemManufacturerLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name        Date           Story Description
1.            Ankit Goswami         30/8/2019      Written for PriceItemManufacturerLookupCustom class
2.            Aman Soni             25/06/2020     Changes made as part of EDGE-148667
*********************************************************************************************************************************/
@isTest
public class PriceItemManufacturerLookupCustomTest{
  @TestSetup
  public static void testSetup(){  
    //Created User, Profile by Aman Soni as a part of EDGE-148667
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
    testPriceItem.Name = 'Mobile Device';
    testPriceItem.Manufacturer__c = 'TestMan';
    testPriceItem.offer_id__C = 'DMCAT_Offer_000646';
    testPriceItem.Model__c = 'TestMod';
    testPriceItem.Type__c= 'TestDev';
    testPriceItem.Colour__c = 'TestCol';
    testPriceItem.cspmb__Contract_Term__c = '12';
    testPriceItem.ChargeType__c = 'RC';
    testPriceItem.cspmb__Recurring_Charge__c = 75;

    cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
    testPriceItem2.Name = 'Mobile Device';
    testPriceItem2.Manufacturer__c = 'TestMan';
    testPriceItem2.offer_id__C = 'DMCAT_Offer_000646';
    testPriceItem2.Model__c = 'TestMod';
    testPriceItem2.Type__c= 'TestDev';
    testPriceItem2.Colour__c = 'TestCol';
    testPriceItem2.ChargeType__c = 'OC';
    testPriceItem2.cspmb__One_Off_Charge__c = 1000;
    
    cspmb__Price_Item__c testPlanType = new cspmb__Price_Item__c();
    testPlanType.offer_id__C = 'DMCAT_Offer_000646';
    testPlanType.offer__c = 'Aggregated Data';
    testPlanType.plan__c = 'Local';
    
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem,testPriceItem2,testPlanType};
    insert PIList; 
  }

  @IsTest
  public static void testGetRequiredAttributes()
  {
    PriceItemManufacturerLookupCustom manufacturerInit = new PriceItemManufacturerLookupCustom();    
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-148667 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
    System.runAs(sales){
    String res1 = manufacturerInit.getRequiredAttributes();
    System.assertEquals('["OfferId,deviceTypeString"]', res1 );}
    //Added by Aman Soni as a part of EDGE-148667 || End    
    Test.stopTest();  
  }

  @isTest
  public static void testGetUniqueListByField()
  {
    List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, Type__c,ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];
    PriceItemManufacturerLookupCustom manufacturerInit = new PriceItemManufacturerLookupCustom();  
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-148667 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
    System.runAs(sales){
    List<cspmb__Price_Item__c> res1 = manufacturerInit.getUniqueListByField(priceItemList, 'Manufacturer__c'); 
        if(res1 != null && !res1.isEmpty()){
        System.assertEquals('TestMan', res1[0].Manufacturer__c);
        }
    }
    //Added by Aman Soni as a part of EDGE-148667 || End
    Test.stopTest();  
  }

  @isTest
  public static void testDoLookupSearch()
  {
    List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Type__c,offer_id__C, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];
    Map<String,String> testStringStringMap = new Map<String, String> {'MobileHandsetColour'=>String.valueOf(priceItemList[0].Id), 'MobileHandsetManufacturer'=>String.valueOf(priceItemList[0].Id), 'MobileHandsetModel'=>String.valueOf(priceItemList[0].Id), 'PaymentType'=>String.valueOf(priceItemList[0].Id),'deviceTypeString'=>String.valueOf(priceItemList[0].Type__c),'OfferId'=>String.valueOf(priceItemList[0].offer_id__C), 'searchValue'=>''};
    PriceItemManufacturerLookupCustom manufacturerInit = new PriceItemManufacturerLookupCustom();
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-148667 || Start
     List<cspmb__Price_Item__c> result= new  List<cspmb__Price_Item__c>();
     User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            result = (List<cspmb__Price_Item__c>)manufacturerInit.doLookupSearch(testStringStringMap, '', NULL, 10, 10);
            if(!result.isEmpty()){
            System.assertEquals(priceItemList[0].Name, result[0].Name);
            }
        }
     //Added by Aman Soni as a part of EDGE-148667 || End     
    Test.stopTest();
  }
}