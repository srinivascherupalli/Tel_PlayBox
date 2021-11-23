@isTest
private class CustomButtonCreateMACTest {

    @isTest
    static void testPerformAction()
    {
        String result;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        CustomButtonCreateMAC testClass = new CustomButtonCreateMAC();
        
        Test.startTest();
            result = testClass.performAction(testProductConfiguration.cscfga__Product_Basket__c, testProductConfiguration.Id);
        Test.stopTest();
        
        System.assertEquals('{"status":"ok","text":"", "displayInDialog": true,"size": "l","modalTitle": "Existing Subscriptions", "redirectURL":"/apex/c__MACPage?basketID='+ testProductConfiguration.cscfga__Product_Basket__c +'"}', result , 'Result was not the expected return string');
    }
}