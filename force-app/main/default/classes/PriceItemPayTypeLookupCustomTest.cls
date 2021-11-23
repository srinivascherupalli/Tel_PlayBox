/******************************************************************************************************
Name          : PriceItemPayTypeLookupCustomTest
Created By    : Ashish
Description   : This is a test class to simulate and test the logic of PriceItemPayTypeLookupCustom
===============================================================================================================================
Change.No.    Developer Name        Date         Story Description
1.            Aman Soni             25/06/2020   Changes made as part of EDGE-148667
******************************************************************************************************/
@isTest
public class PriceItemPayTypeLookupCustomTest {
  //Created new method by Aman Soni as a part of EDGE-148667 || Start
  @TestSetup
  public static void testSetup(){    
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
    testPriceItem.offer_id__C = 'DMCAT_Offer_000646';
    testPriceItem.Model__c = 'TestMod';
    testPriceItem.Colour__c = 'TestCol';
    testPriceItem.cspmb__Contract_Term__c = '12';
    testPriceItem.ChargeType__c = 'RC';
    testPriceItem.Contract_Type__c = 'TestContract';
    testPriceItem.cspmb__Recurring_Charge__c = 75;
    piLst.add(testPriceItem);
    
    cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
    testPriceItem2.Name = 'Mobile Device';
    testPriceItem2.Manufacturer__c = 'TestMan';
    testPriceItem2.offer_id__C = 'DMCAT_Offer_000646';
    testPriceItem2.Model__c = 'TestMod';
    testPriceItem2.Colour__c = 'TestCol';
    testPriceItem2.Contract_Type__c = 'TestContract';
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
  //Created new method by Aman Soni as a part of EDGE-148667 || End
    
    /******************************************************************************************************************
    * Method Name : getRequiredAttributesTest
    * Description : Used to simulate and test the logic of getRequiredAttributes method in PriceItemPayTypeLookupCustom
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************************/
    public static testmethod void getRequiredAttributesTest() {
        String result;
        Test.startTest();
        PriceItemPayTypeLookupCustom piCTermLkp = new PriceItemPayTypeLookupCustom();
        //Added by Aman Soni as a part of EDGE-148667 || Start
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
        result = piCTermLkp.getRequiredAttributes();
        System.assertEquals('["ManufacturerString","ModelString","ColourString","PaymentTypeString","OfferId"]', result);}
        //Added by Aman Soni as a part of EDGE-148667 || End
        Test.stopTest();       
    }
    
    /***********************************************************************************************************
    * Method Name : doLookupSearchTest
    * Description : Used to simulate and test the logic of doLookupSearch method in PriceItemPayTypeLookupCustom
    * Parameters  : NA
    * Return      : NA                      
    ***********************************************************************************************************/
    public static testmethod void doLookupSearchTest() {
        List<cspmb__Price_Item__c> result;
        //Added by Aman Soni as a part of EDGE-148667 || Start
        List<cspmb__Price_Item__c> priceItemList = [SELECT id, Name, Manufacturer__c, Model__c, Contract_Type__c,offer_id__C,Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c];
        Map<String,String> testStringStringMap = new Map<String, String> {'MobileHandsetColour'=>String.valueOf(priceItemList[0].Id),'ColourString'=>String.valueOf(priceItemList[0].Colour__c), 'MobileHandsetManufacturer'=>String.valueOf(priceItemList[0].Id), 'ManufacturerString'=>String.valueOf(priceItemList[0].Manufacturer__c),'MobileHandsetModel'=>String.valueOf(priceItemList[0].Id),'ModelString'=>String.valueOf(priceItemList[0].Model__c), 'PaymentType'=>String.valueOf(priceItemList[0].Id),'PaymentTypeString'=>String.valueOf(priceItemList[0].Contract_Type__c),'OfferId'=>String.valueOf(priceItemList[0].offer_id__C), 'searchValue'=>''};
        Test.startTest();
        PriceItemPayTypeLookupCustom piCTermLkp = new PriceItemPayTypeLookupCustom();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            result = (List<cspmb__Price_Item__c>)piCTermLkp.doLookupSearch(testStringStringMap, '', NULL, 10, 10);
            if(!result.isEmpty()){
            System.assertEquals(priceItemList[0].Name, result[0].Name);
            }
        }
        //Added by Aman Soni as a part of EDGE-148667 || End       
        Test.stopTest();
    }
}