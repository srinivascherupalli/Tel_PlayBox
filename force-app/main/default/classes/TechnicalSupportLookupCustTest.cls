/*********************************************************************************************************************************
Test Class : TechnicalSupportLookupCustTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Laxmi  Rahate       01/10/2019        EDGE-116138-> TID - Dispaly Unique Technical
2.            shubhi               31/10/2019        EDGE-117563 
 *********************************************************************************************************************************
*/
@isTest
public class TechnicalSupportLookupCustTest {
  @TestSetup
  private static void testSetup()
  {
          
    cspmb__Price_Item__c testTechnical = new cspmb__Price_Item__c();
    testTechnical.offer_id__C = 'DMCAT_Offer_000854';
    testTechnical.ProdSpecId__c  = 'DMCAT_Offer_000854';
    testTechnical.Feature_Level__c = 'Standard';
    testTechnical.Technical_Support__c  = 'Bus Hrs';
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testTechnical};
    insert PIList;
  }
    
  @IsTest
  private static void testGetRequiredAttributes()
  {
      TechnicalSupportLookupCustom technicalSupportLookupCustom = new TechnicalSupportLookupCustom();
      Test.startTest();
      String res1  = technicalSupportLookupCustom.getRequiredAttributes();
      Test.stopTest();
      System.assertNotEquals('', res1);

  }
    
     @isTest
  private static void testGetUniqueListByField()
  {
        TechnicalSupportLookupCustom technicalSupportLookupCustom = new TechnicalSupportLookupCustom();
    
        List<cspmb__Price_Item__c> priceItemList = [select Id, Name, cspmb__Recurring_Charge__c  , cspmb__One_Off_Charge__c,Check_todays_date__c ,Billing_Description__c, currency__c, cspmb__Contract_Term__c,Technical_Support__c,Feature_Level__c,Offer_Id__c,ProdSpecId__c   from cspmb__Price_Item__c];
        Test.startTest();
        List<cspmb__Price_Item__c> res1 =technicalSupportLookupCustom.getUniqueListByField(priceItemList, 'Technical_Support__c');

        Test.stopTest();
        System.assertNotEquals(true, res1.isEmpty());

  }
    
    
 @isTest
  private static void testDoLookupSearch()
  {
       List<cspmb__Price_Item__c> priceItemList = [select Id, Name, cspmb__Recurring_Charge__c  , cspmb__One_Off_Charge__c,Check_todays_date__c ,Billing_Description__c, currency__c, cspmb__Contract_Term__c,Technical_Support__c,Feature_Level__c,Offer_Id__c,ProdSpecId__c  from cspmb__Price_Item__c];
       Map<String,String> testFeature = new Map<String, String> {'OfferId'=>'DMCAT_Offer_000854','ProductSpecId'=>'DMCAT_Offer_000854'};
       TechnicalSupportLookupCustom technicalSupportLookupCustom = new TechnicalSupportLookupCustom();
       Test.startTest();
       List<Object> res1 = technicalSupportLookupCustom.doLookupSearch (testFeature,'',null,0,0);
       Test.stopTest();
       System.assertNotEquals(true, res1.isEmpty());
     

  }
    
    @isTest
  private static void testDoLookupSearchNull()
  {
       List<cspmb__Price_Item__c> priceItemList = [select Id, Name, cspmb__Recurring_Charge__c  , cspmb__One_Off_Charge__c,Check_todays_date__c ,Billing_Description__c, currency__c, cspmb__Contract_Term__c,Technical_Support__c,Feature_Level__c,Offer_Id__c,ProdSpecId__c  from cspmb__Price_Item__c];
       Map<String,String> testFeature = new Map<String, String> {'OfferId'=>''};
       TechnicalSupportLookupCustom technicalSupportLookupCustom = new TechnicalSupportLookupCustom();
       Test.startTest();
       List<Object> res1 = technicalSupportLookupCustom.doLookupSearch (testFeature,'',null,0,0);
       Test.stopTest();
       System.assertEquals(true, res1.isEmpty());
     

  }
}