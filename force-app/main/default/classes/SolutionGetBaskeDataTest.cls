/***********************************************************************************************
Name          : SolutionGetBaskeDataTest
Created By    : Mahaboob Basha
Created Date  : Jun 11 2019
Description   : This is a test class to simulate and test the logic of SolutionGetBaskeData
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        11-06-2019      Created
1.1         Mahaboob        11-06-2019      Added methods getDataTest, getUnitPriceByProductTest
                                                        , getUnitPriceByProductTest1
***********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionGetBaskeDataTest {
    
    /********************************************************************************************
    * Method Name : getDataTest
    * Description : Used to simulate and test the logic of getData method in SolutionGetBaskeData
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************/
    static testmethod void getDataTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        inputMap.put('basketId', basket.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = SolutionGetBaskeData.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('basket'));
    }
    
    /**********************************************************************************************************
    * Method Name : getUnitPriceByProductTest
    * Description : Used to simulate and test the logic of getUnitPriceByProduct method in SolutionGetBaskeData
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************************/
    static testmethod void getUnitPriceByProductTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cspmb__Price_Item__c huntGrpPI = new cspmb__Price_Item__c(Name = 'Hunt Group', cspmb__Is_Active__c = TRUE, cspmb__Product_Definition_Name__c = 'Hunt Group');
        INSERT huntGrpPI;
        inputMap.put('Hunt Group', 'cspmb__Recurring_Charge__c');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = SolutionGetBaskeData.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('Hunt Group'));
        System.assertNotEquals(NULL, returnMap.get('Hunt Group'));
    }

    /**********************************************************************************************************
    * Method Name : getUnitPriceByProductforUCETest
    * Description : Used to simulate and test the logic of getUnitPriceByProductforUCE method in SolutionGetBaskeData
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************************/
    static testmethod void getUnitPriceByProductforUCETest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cspmb__Price_Item__c huntGrpPI = new cspmb__Price_Item__c(Name = 'Hunt Group', cspmb__Is_Active__c = TRUE, cspmb__Product_Definition_Name__c = 'Hunt Group');
        INSERT huntGrpPI;
        inputMap.put('Hunt Group', 'cspmb__Recurring_Charge__c');
		inputMap.put('Offer Id', 'Telstra Collaboration');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = SolutionGetBaskeData.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('Hunt Group'));
    }	
    
    /**********************************************************************************************************
    * Method Name : getUnitPriceByProductTest1
    * Description : Used to simulate and test the logic of getUnitPriceByProduct method in SolutionGetBaskeData
    * Parameters  : NA
    * Return      : NA                      
    **********************************************************************************************************/
    static testmethod void getUnitPriceByProductTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('Hunt Group', 'cspmb__Recurring_Charge__c');
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = SolutionGetBaskeData.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('Hunt Group'));
        System.assertEquals(NULL, returnMap.get('Hunt Group'));
    }
}