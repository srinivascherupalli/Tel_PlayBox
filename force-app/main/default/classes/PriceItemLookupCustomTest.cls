/*********************************************************************************************************************************
Class Name : PriceItemColourLookupCustom
Test Class : PriceItemLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name        Date         Story Description
1.            Ankit Goswami         30/8/2019      EDGE-112367  PPHH Test class for PriceItemColourLookupCustom
2.            Aman Soni             15/10/2019     Changes made as part of EDGE-112367
3.            Aman Soni             25/06/2020     Changes made as part of EDGE-148667
*********************************************************************************************************************************/
@isTest
public class PriceItemLookupCustomTest{
  @TestSetup
  public static void testSetup(){
    //Created User, Profile and Price Item List to avoid individual record insert by Aman Soni as a part of EDGE-148667
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    List<cspmb__Price_Item__c> piLst = new List<cspmb__Price_Item__c>();
    cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
    testPriceItem.Name = 'Mobile Device';
    testPriceItem.Manufacturer__c = 'TestMan';
    testPriceItem.Model__c = 'TestMod';
    testPriceItem.offer_id__C = 'DMCAT_Offer_000646';
    testPriceItem.Colour__c = 'TestCol';
    testPriceItem.cspmb__Contract_Term__c = '12';
    testPriceItem.ChargeType__c = 'RC';
    testPriceItem.cspmb__Recurring_Charge__c = 75;
    piLst.add(testPriceItem);
    
    cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
    testPriceItem2.Name = 'Mobile Device';
    testPriceItem2.Manufacturer__c = 'TestMan';
    testPriceItem2.offer_id__C = 'DMCAT_Offer_000646';
    testPriceItem2.Model__c = 'TestModTestMod';
    testPriceItem2.Colour__c = 'TestCol';
    testPriceItem2.ChargeType__c = 'OC';
    testPriceItem2.cspmb__One_Off_Charge__c = 1000;
    piLst.add(testPriceItem2);   
    
    cspmb__Price_Item__c testPlanType = new cspmb__Price_Item__c();
    testPlanType.offer_id__C = 'DMCAT_Offer_000646';
    testPlanType.offer__c = 'Aggregated Data';
    testPlanType.plan__c = 'Local';
    piLst.add(testPlanType); 
    insert piLst;    
  }

  @IsTest
  public static void testGetRequiredAttributes()
  {
    Test.startTest();
    PriceItemColourLookupCustom colourInit = new PriceItemColourLookupCustom();
    //Added by Aman Soni as a part of EDGE-148667 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
    System.runAs(sales){
    String res3 = colourInit.getRequiredAttributes();
    System.assertEquals('["MobileHandsetManufacturer","MobileHandsetModel","OfferId"]', res3);
    }
    //Added by Aman Soni as a part of EDGE-148667 || End
    Test.stopTest();
  }

  @isTest
  public static void testGetUniqueListByField()
  {
    List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, Type__c,ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c where Colour__c != null];      
    PriceItemColourLookupCustom colourInit = new PriceItemColourLookupCustom();   
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-148667 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
    System.runAs(sales){
    List<cspmb__Price_Item__c> res3 = colourInit.getUniqueListByField(priceItemList, 'Colour__c');
    if(res3 != null && !res3.isEmpty()){
    System.assertEquals('TestCol', res3[0].Colour__c);
    }
    }
    //Added by Aman Soni as a part of EDGE-148667 || End
    Test.stopTest();
  }

  @isTest
  public static void testDoLookupSearch()
  {
    List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, offer_id__C,Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c where Colour__c != null];
    Map<String,String> testStringStringMap = new Map<String, String> {'MobileHandsetColour'=>String.valueOf(priceItemList[0].Id), 'MobileHandsetManufacturer'=>String.valueOf(priceItemList[0].Id), 'MobileHandsetModel'=>String.valueOf(priceItemList[0].Id), 'PaymentType'=>String.valueOf(priceItemList[0].Id),'OfferId'=>String.valueOf(priceItemList[0].offer_id__C), 'searchValue'=>''};
    PriceItemColourLookupCustom colourInit = new PriceItemColourLookupCustom();
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-148667 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com']; 
    List<cspmb__Price_Item__c> res3 = new List<cspmb__Price_Item__c>();     
    System.runAs(sales){
        res3 = (List<cspmb__Price_Item__c>)colourInit.doLookupSearch(testStringStringMap, '', null, 0, 0);
        if(!res3.isEmpty()){
        System.assertEquals(priceItemList[0].Name, res3[0].Name);
        }
    }
    //Added by Aman Soni as a part of EDGE-148667 || End
    Test.stopTest();
  }
}