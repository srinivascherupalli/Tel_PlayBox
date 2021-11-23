/*********************************************************************************************************************************
Class Name : EMPlanLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Mahima Gandhe         12/8/2021      Test class for EMPlanLookupCustom
*********************************************************************************************************************************/
@isTest
public class EMPlanLookupCustomTest  {
    @TestSetup
  private static void testSetup()
  {
    //Added by Aman Soni as a part of EDGE-154026 || Start    
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    //Added by Aman Soni as a part of EDGE-154026 || End
      
    cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
    testPriceItem.Name = 'Mobile Device';
    testPriceItem.Manufacturer__c = 'TestMan';
    testPriceItem.Model__c = 'TestMod';
    testPriceItem.Colour__c = 'TestCol';
    testPriceItem.cspmb__Contract_Term__c = '12';
    testPriceItem.ChargeType__c = 'RC';
    testPriceItem.cspmb__Recurring_Charge__c = 75;
    testPriceItem.Type__c='TestType';//Added by Aman Soni as a part of EDGE-154026
    testPriceItem.Plan__c='Plan';

    cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
    testPriceItem2.Name = 'Mobile Device';
    testPriceItem2.Manufacturer__c = 'TestMan';
    testPriceItem2.Model__c = 'TestMod';
    testPriceItem2.Colour__c = 'TestCol';
    testPriceItem2.ChargeType__c = 'OC';
    testPriceItem2.cspmb__One_Off_Charge__c = 1000;
    testPriceItem2.Type__c='TestType';//Added by Aman Soni as a part of EDGE-154026
    testPriceItem2.Plan__c='Plan';
        
    cspmb__Price_Item__c testPlanType = new cspmb__Price_Item__c();
    testPlanType.offer_id__C = 'DMCAT_Offer_000646';
    testPlanType.offer__c = 'Aggregated Data';
    testPlanType.plan__c = 'Local';
    testPlanType.Type__c='TestType';//Added by Aman Soni as a part of EDGE-154026
      
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem,testPriceItem2,testPlanType};
    insert PIList;   
  }
  @IsTest
  private static void testGetRequiredAttributes()
  {   
    EMPlanLookupCustom emPlanLookupCustom = new EMPlanLookupCustom();  
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-154026 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];    
    System.runAs(sales){    
    String res1  = emPlanLookupCustom.getRequiredAttributes();
    System.assertEquals('["OfferId,OfferTypeString,PlanTypeString,basketId"]', res1);
    }
    //Added by Aman Soni as a part of EDGE-154026 || End    
    Test.stopTest();
  }

  @isTest
  private static void testGetUniqueListByField()
  {
    List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c,ChargeType__c, cspmb__One_Off_Charge__c,Type__c, Plan__c,cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];
    EMPlanLookupCustom emPlanLookupCustom = new EMPlanLookupCustom();  
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-154026 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
    System.runAs(sales){  
    List<cspmb__Price_Item__c> res1 = emPlanLookupCustom.getUniqueListByField(priceItemList, 'Plan__c');
    if(res1 != null && !res1.isEmpty()){
        System.assertEquals('Plan', res1[0].Plan__c);
      }
    }
    //Added by Aman Soni as a part of EDGE-154026 || End    
    Test.stopTest();    
  }
  @isTest
  private static void testDoLookupSearch()
  {
    List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c,Type__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];
    Map<String,String> testplanTypeStringMap = new Map<String, String> {'OfferId'=>'DMCAT_Offer_000646', 'prodSpecID'=>'DMCAT_Test_ID', 'OfferTypeString'=>'Aggregated Data'};
    EMPlanLookupCustom emPlanLookupCustom = new EMPlanLookupCustom();
    Test.startTest();
    //Added by Aman Soni as a part of EDGE-154026 || Start
    User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
    System.runAs(sales){
        List<cspmb__Price_Item__c> res1 = (List<cspmb__Price_Item__c>)emPlanLookupCustom.doLookupSearch (testplanTypeStringMap,'',null,0,0);
            if(res1 != null && !res1.isEmpty()){
                System.assertEquals(priceItemList[0].Type__c, res1[0].Type__c);
            }
    }
    //Added by Aman Soni as a part of EDGE-154026 || End
    Test.stopTest();
  }
}