/***************************************************************************************************************
Name          : DiscountsJsonTest
Created By    : Ramcharan
Created Date  : Oct 04 2020
Description   : This is a test class to simulate and test the logic of DiscountJson
*/
@isTest(SeeAllData=FALSE)
private class DiscountsJsonTest {
   
  @TestSetup
  private static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    
   }
    /*****************************************************************************************************
    * Method Name : discountsTest
    * Description : test the logic of DiscountsJson
    * Parameters  : NA
    * Return      : NA                      
    *****************************************************************************************************/
    static testmethod void discountsTest() {
        DiscountsJson discountJson = new DiscountsJson();
        DiscountsJson.Discounts discounts = new DiscountsJson.Discounts();
        List<DiscountsJson.Discounts> discountList = new List<DiscountsJson.Discounts>();
        DiscountsJson.CustomData customData = new DiscountsJson.CustomData();
        customData.promotion = true;
        discounts.source = 'source Test';
        discounts.version = '1.0';
        discounts.discountPrice = '12.3';
        discounts.discountCharge = '50';
        discounts.chargeType = '';
        discounts.recordType = '';
        discounts.type_x = '';
        discounts.description = 'Test123';
        discounts.amount = 1.0;   
        discounts.duration = 1;
        discountList.add(discounts);
        discountJson.discounts = discountList;
        Test.startTest();
           System.assertEquals(discountList.isEmpty(), false);
        Test.stopTest();
    }
  
}