/***********************************************************************************************
Name          : SolutionOpportunityHelperTest
Created By    : Mahaboob Basha
Created Date  : Jun 11 2019
Description   : This is a test class to simulate and test the logic of SolutionOpportunityHelper
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        11-06-2019      Created
1.1         Mahaboob        11-06-2019      Added methods getRequiredInfoTest
***********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionOpportunityHelperTest {
    
    /*********************************************************************************************************
    * Method Name : getRequiredInfoTest
    * Description : Used to simulate and test the logic of getRequiredInfo method in SolutionOpportunityHelper
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************/
    static testmethod void getRequiredInfoTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        inputMap.put('basketId', basket.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionOpportunityHelper sOPPH = new SolutionOpportunityHelper();
            returnMap = sOPPH.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('IP Site'));
    }
}