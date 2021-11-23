/*********************************************************************************************************************************
Test Class : IPAccessConfigurationCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Laxmi  Rahate       01/10/2019        EDGE-98282 -> TID - Dispaly Unique IP Access Config Values
 *********************************************************************************************************************************
*/

@isTest
public class IPAccessConfigurationCustomTest {
  @TestSetup
  private static void testSetup()
  {
          
    cspmb__Price_Item__c testBandwidth = new cspmb__Price_Item__c();
    testBandwidth.offer_id__C = 'DMCAT_Offer_000709';
    testBandwidth.Zone__c = '1';
    testBandwidth.IP_Access_Configuration__c = 'Single Uplink';
    testBandwidth.Bandwidth__c = '50 Mbps'; 
    List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testBandwidth};
    insert PIList;
  }
    
  @IsTest
  private static void testGetRequiredAttributes()
  {
      IPAccessConfigurationCustom ipAccessConfigurationCustom = new IPAccessConfigurationCustom();
      Test.startTest();
      String res1  = ipAccessConfigurationCustom.getRequiredAttributes();
       Test.stopTest();
      System.assertNotEquals('', res1);

  }
    
     @isTest
  private static void testGetUniqueListByField()
  {
    IPAccessConfigurationCustom ipAccessConfigurationCustom = new IPAccessConfigurationCustom();
    
     List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name,Bandwidth__c, IP_Access_Configuration__c,Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, Type__c,ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c ,Zone__c FROM cspmb__Price_Item__c];
    Test.startTest();
    List<cspmb__Price_Item__c> res1 =ipAccessConfigurationCustom.getUniqueListByField(priceItemList, 'IP_Access_Configuration__c');

    Test.stopTest();
    System.assertNotEquals(true, res1.isEmpty());

  }
    
    
 @isTest
  private static void testDoLookupSearch()
  {
       List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, IP_Access_Configuration__c,Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];
        Map<String,String> testZone = new Map<String, String> {'OfferId'=>'DMCAT_Offer_000709'};
      IPAccessConfigurationCustom ipAccessConfigurationCustom = new IPAccessConfigurationCustom();
       Test.startTest();
       List<Object> res1 = ipAccessConfigurationCustom.doLookupSearch (testZone,'',null,0,0);
       Test.stopTest();
       System.assertEquals(true, res1.isEmpty());
     

  }
}