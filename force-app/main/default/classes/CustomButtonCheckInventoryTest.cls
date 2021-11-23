/*************************************************************************************************
Name : CustomButtonCreatePortinTest
Description : Test class for CustomButtonCreatePortin
Author: Kalashree Borgaonkar
Story: EDGE-80749
***************************************************************************************************/
@isTest
public class CustomButtonCheckInventoryTest {
 @isTest
    static void testPerformAction()
    {
        String result;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        CustomButtonCheckInventory testClass = new CustomButtonCheckInventory();
        
        Test.startTest();
            result = testClass.performAction(testProductConfiguration.cscfga__Product_Basket__c, testProductConfiguration.Id);
        Test.stopTest();

        System.assertEquals(result!=null,true, 'Result was not the expected return string');
    }
}