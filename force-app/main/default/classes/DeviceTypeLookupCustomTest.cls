/*********************************************************************************************************************************
Class Name : DeviceTypeLookupCustom
Test Class : DeviceTypeLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date     Story        Description
1.            Ankit Goswami     30/8/2019      EDGE-112367  PPHH - Test Class for DeviceTypeLookupCustom
2.            Aman Soni         27/9/2019      EDGE-112367  Added testDoLookupSearchforPlanTypeNull method
3.            Aman Soni         16/10/2019     EDGE-148729  Added by Aman Soni
3.            Aman Soni         25/06/2020     EDGE-148667  Added by Aman Soni
*********************************************************************************************************************************/

@isTest
public class DeviceTypeLookupCustomTest  {
  @TestSetup
  public static void testSetup()
  {
    //Added by Aman Soni as a part of EDGE-148729/148667 || Start    
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    //Added by Aman Soni as a part of EDGE-148729/148667 || End
    
    cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
    testPriceItem.Name = 'Mobile Device';
    testPriceItem.Manufacturer__c = 'TestMan';
    testPriceItem.Model__c = 'TestMod';
    testPriceItem.offer_id__c = 'DMCAT_Offer_000646';
    testPriceItem.Colour__c = 'TestCol';
    testPriceItem.cspmb__Contract_Term__c = '12';
    testPriceItem.ChargeType__c = 'RC';
    testPriceItem.Type__c='Enterprise Gateway';//Added by Aman Soni as a part of EDGE-148667
    testPriceItem.cspmb__Recurring_Charge__c = 75;

    cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
    testPriceItem2.Name = 'Mobile Device';
    testPriceItem2.Manufacturer__c = 'TestMan';
    testPriceItem2.Model__c = 'TestMod';
    testPriceItem2.offer_id__c = 'DMCAT_Offer_000646';
    testPriceItem2.Colour__c = 'TestCol';
    testPriceItem2.ChargeType__c = 'OC';
    testPriceItem2.Type__c='Enterprise Gateway';//Added by Aman Soni as a part of EDGE-148667
    testPriceItem2.cspmb__One_Off_Charge__c = 1000;
        
    cspmb__Price_Item__c testPlanType = new cspmb__Price_Item__c();
    testPlanType.offer_id__c = 'DMCAT_Offer_000646';
    testPlanType.offer__c = 'Aggregated Data';
    testPlanType.plan__c = 'Local';
    testPlanType.Type__c='Enterprise Gateway';
    
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem,testPriceItem2,testPlanType};
    insert PIList;    
  }

  @IsTest
  public static void testGetRequiredAttributes(){    
    DeviceTypeLookupCustom deviceTypeLookupCustom=new DeviceTypeLookupCustom();
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-148729/148667 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
    System.runAs(sales){
        String res1  = deviceTypeLookupCustom.getRequiredAttributes();
        System.assertEquals('["OfferId,PlanType,ItemCode"]', res1);
    }
    //Added by Aman Soni as a part of EDGE-148729/148667 || End
    Test.stopTest();
  }
 
  @isTest
  public static void testDoLookupSearch(){
      List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Colour__c, Type__c,cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];
      Map<String,String> testdeviceTypeStringMap = new Map<String, String> {'OfferId'=>'DMCAT_Offer_000646', 'PlanType'=>'voice and data'};
      DeviceTypeLookupCustom deviceTypeLookupCustom=new DeviceTypeLookupCustom();  
      Test.startTest();
      //Added by Aman Soni as a part of EDGE-148729/148667 || Start
      User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
      System.runAs(sales){    
      //List<Object> res1 = deviceTypeLookupCustom.doLookupSearch(testdeviceTypeStringMap,'',null,0,0);
      List<cspmb__Price_Item__c> res1 = (List<cspmb__Price_Item__c>)deviceTypeLookupCustom.doLookupSearch(testdeviceTypeStringMap,'',null,0,0);
      List<cspmb__Price_Item__c> res2 =deviceTypeLookupCustom.getUniqueListByField(priceItemList, 'Type__c');
      if(res2 != null && !res2.isEmpty()){
        System.assertEquals('Enterprise Gateway', res2[0].Type__c);
      }
      if(res1 != null && !res1.isEmpty()){
        System.assertEquals(priceItemList[0].Name, res1[0].Name);
      }
      //Added by Aman Soni as a part of EDGE-148729/148667 || End
      }
      Test.stopTest();      
  }
  
  //EDGE-112367  Added testDoLookupSearchforPlanTypeNull method
  @isTest
  public static void testDoLookupSearchforPlanTypeNull()
  {
    List<cspmb__Price_Item__c> priceItemList = [SELECT id, offer_id__c,Name, Manufacturer__c, Model__c, Colour__c, Type__c,cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];   
    Map<String,String> testdeviceTypeStringMapDOP = new Map<String, String> {'OfferId'=>'DMCAT_Offer_000646', 'PlanType'=> null};
    DeviceTypeLookupCustom deviceTypeLookupCustom=new DeviceTypeLookupCustom();   
    Test.startTest(); 
    //Added by Aman Soni as a part of EDGE-148729/148729 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
    System.runAs(sales){
        //List<Object> res1 = deviceTypeLookupCustom.doLookupSearch (testdeviceTypeStringMapDOP,'',null,0,0);
        List<cspmb__Price_Item__c> res1 = (List<cspmb__Price_Item__c>)deviceTypeLookupCustom.doLookupSearch (testdeviceTypeStringMapDOP,'',null,0,0);
        List<cspmb__Price_Item__c> res2 =deviceTypeLookupCustom.getUniqueListByField(priceItemList, 'Type__c');
        if(res2 != null && !res2.isEmpty()){
            System.assertEquals('Enterprise Gateway', res2[0].Type__c);
        }
        if(res1 != null && !res1.isEmpty()){
            System.assertEquals(priceItemList[0].Name, res1[0].Name);
        }
    }
    //Added by Aman Soni as a part of EDGE-148729/148667 || End
    Test.stopTest();
  }
}