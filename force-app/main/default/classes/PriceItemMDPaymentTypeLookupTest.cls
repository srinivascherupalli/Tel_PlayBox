/******************************************************************************************************
Name          : PriceItemMDPaymentTypeLookupTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of PriceItemMDPaymentTypeLookup
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods getRequiredAttributesTest, doLookupSearchTest
******************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class PriceItemMDPaymentTypeLookupTest {
    
    /******************************************************************************************************************
    * Method Name : getRequiredAttributesTest
    * Description : Used to simulate and test the logic of getRequiredAttributes method in PriceItemMDPaymentTypeLookup
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************************/
    static testmethod void getRequiredAttributesTest() {
        String result;
        Test.startTest();
            PriceItemMDPaymentTypeLookup piPTermLkp = new PriceItemMDPaymentTypeLookup();
            result = piPTermLkp.getRequiredAttributes();
        Test.stopTest();
        System.assertNotEquals('', result);
        System.assertEquals('["ManufacturerString","ModelString","ColourString"]', result);
    }
    
    /***********************************************************************************************************
    * Method Name : doLookupSearchTest
    * Description : Used to simulate and test the logic of doLookupSearch method in PriceItemMDPaymentTypeLookup
    * Parameters  : NA
    * Return      : NA                      
    ***********************************************************************************************************/
    static testmethod void doLookupSearchTest() {
        Object[] result;
        Test.startTest();
            PriceItemMDPaymentTypeLookup piPTermLkp = new PriceItemMDPaymentTypeLookup();
            result = piPTermLkp.doLookupSearch(new Map<String, String>(), '', NULL, 10, 10);
        Test.stopTest();
        System.assertNotEquals(NULL, result);
    }
}