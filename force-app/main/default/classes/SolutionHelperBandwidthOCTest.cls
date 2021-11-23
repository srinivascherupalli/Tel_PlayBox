/* ****************************************************************************
*Class Name     : SolutionHelperBandwidthOCTest
* Author        : Aman Soni || EDGE-113848
* Date          : 17 Oct 2019
* Description   : This is a test class to simulate and test the logic of SolutionHelperBandwidthOC
* *****************************************************************************/

@isTest(SeeAllData=FALSE)
private class SolutionHelperBandwidthOCTest {
    
  /******************************************************************************************************
    * Method Name : getBandwidthDownGradeOCTest
    * Description : Used to simulate and test the logic of getBandwidthDownGradeOC method in SolutionHelperBandwidthOC
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getBandwidthDownGradeOCTest(){
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('','');
        cspmb__Price_Item__c userPI = new cspmb__Price_Item__c(Name = 'Internet Site', cspmb__Is_Active__c = TRUE, cspmb__Product_Definition_Name__c = 'Internet Site', Package_Name__c = 'Telstra Internet Direct', Type__c = '', Zone__c = '', cspmb__Effective_End_Date__c = System.today().addDays(1), cspmb__Effective_Start_Date__c = System.today().addDays(-1),Offer_Id__c = System.Label.TID_OfferID,cspmb__One_Off_Charge__c=500,External_Id__c = System.Label.TID_ExternalId,ProdSpecId__c = System.Label.TID_ProdSpecId);
        INSERT userPI;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        SolutionHelperBandwidthOC shbnd = new SolutionHelperBandwidthOC();
        returnMap = shbnd.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
    }
}