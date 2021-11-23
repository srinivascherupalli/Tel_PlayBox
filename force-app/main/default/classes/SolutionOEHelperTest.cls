/***********************************************************************************************
Name          : SolutionOEHelperTest
Created By    : Mahaboob Basha
Created Date  : Jun 11 2019
Description   : This is a test class to simulate and test the logic of SolutionOEHelper
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        11-06-2019      Created
1.1         Mahaboob        11-06-2019      Added methods getRequiredInfoTest
***********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionOEHelperTest {
    
    /************************************************************************************************
    * Method Name : getRequiredInfoTest
    * Description : Used to simulate and test the logic of getRequiredInfo method in SolutionOEHelper
    * Parameters  : NA
    * Return      : NA                      
    ************************************************************************************************/
    static testmethod void getRequiredInfoTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        Contact con = new Contact(LastName = 'Test Contact');
        INSERT con;
        Functional_Contact_Role__c fcr = new Functional_Contact_Role__c(Role_Type__c = 'Site', Role__c = 'Primary Contact', ContactID__c = con.Id);
        INSERT fcr;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionOEHelper sOEH = new SolutionOEHelper();
            returnMap = sOEH.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('Site Details'));
    }
}