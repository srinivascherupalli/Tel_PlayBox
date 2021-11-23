/*************************************************************************************************
Name : CustomButtonCreatePortinTest
Description : Test class for CustomButtonCreatePortin
Author: Kalashree Borgaonkar
Story: EDGE-80749
***************************************************************************************************/
@isTest
public class CustomButtonCreatePortinTest {
 @isTest
    static void testPerformAction()
    {
        String result;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        CustomButtonCreatePortin testClass = new CustomButtonCreatePortin();
        
        Test.startTest();
            result = testClass.performAction(testProductConfiguration.cscfga__Product_Basket__c, testProductConfiguration.Id);
        Test.stopTest();
        
        System.assertEquals('{"status":"ok","text":"", "displayInDialog": true,"size": "l","modalTitle": "Port In Qualification", "redirectURL":"/apex/c__PortInPage?basketID='+ testProductConfiguration.cscfga__Product_Basket__c +'"}', result , 'Result was not the expected return string');
    }
}