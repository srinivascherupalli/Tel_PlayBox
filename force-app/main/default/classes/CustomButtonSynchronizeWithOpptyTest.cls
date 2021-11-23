/*************************************************************************************************************
Name          : CustomButtonSynchronizeWithOpptyTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of CustomButtonSynchronizeWithOpportunity
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods performActionTest, performActionTest1
                                                        , performActionTest2
***********************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class CustomButtonSynchronizeWithOpptyTest {
    
    /********************************************************************************************************************
    * Method Name : performActionTest
    * Description : Used to simulate and test the logic of performAction method in CustomButtonSynchronizeWithOpportunity
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************************/
    static testmethod void performActionTest() {
        String result;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        Test.startTest();
            CustomButtonSynchronizeWithOpportunity cbSync = new CustomButtonSynchronizeWithOpportunity();
            result = cbSync.performAction(basket.Id);
        Test.stopTest();
        System.assertEquals('{"status":"ok","redirectURL":"Synchronise with opportunity failed: product basket has to be valid."}', result);
    }
    
    /********************************************************************************************************************
    * Method Name : performActionTest1
    * Description : Used to simulate and test the logic of performAction method in CustomButtonSynchronizeWithOpportunity
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************************/
    static testmethod void performActionTest1() {
        String result;
        Opportunity opp = TestDataFactory.generateOpportunity();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__Opportunity__c = opp.Id;
        UPDATE basket;
        Test.startTest();
            CustomButtonSynchronizeWithOpportunity cbSync = new CustomButtonSynchronizeWithOpportunity();
            result = cbSync.performAction(basket.Id);
        Test.stopTest();
        System.assertNotEquals(NULL, result);
    }
    

}