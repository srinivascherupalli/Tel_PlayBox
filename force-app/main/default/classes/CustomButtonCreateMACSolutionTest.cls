@isTest
public class CustomButtonCreateMACSolutionTest {

    @isTest
    static void testPerformAction()
    {
        String result;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        CustomButtonCreateMACSolution testClass = new CustomButtonCreateMACSolution();
        
        Test.startTest();
            result = testClass.performAction(testProductConfiguration.cscfga__Product_Basket__c, testProductConfiguration.Id);
        Test.stopTest();
        System.debug('result::'+result);
        
        System.assertEquals('{"status":"ok","text":"", "displayInDialog": true,"size": "l","modalTitle": "Existing Solutions", "redirectURL":"/apex/c__MACSolutionsPage?basketID='+ testProductConfiguration.cscfga__Product_Basket__c +'"}', result , 'Result was not the expected return string');
    }
    
    @isTest
    static void testPerformActionNull()
    {
        String result;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        CustomButtonCreateMACSolution testClass = new CustomButtonCreateMACSolution();
        
        Test.startTest();
            result = testClass.performAction(null, testProductConfiguration.Id);
        Test.stopTest();
        System.debug('result::'+result);
        
        System.assertEquals(null, result , 'Result was not the expected return string');
    }
}