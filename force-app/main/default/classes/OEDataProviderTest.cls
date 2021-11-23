/************************************************************************************
Name          : OEDataProviderTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of OEDataProvider
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods getDataTest, getDataTest1
                                                        , getDataTest2
************************************************************************************/
@isTest(SeeAllData=FALSE)
private class OEDataProviderTest {
    
    /**************************************************************************************
    * Method Name : getDataTest
    * Description : Used to simulate and test the logic of getData method in OEDataProvider
    * Parameters  : NA
    * Return      : NA                      
    **************************************************************************************/
    static testmethod void getDataTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            OEDataProvider oe = new OEDataProvider();
            returnMap = oe.getData(inputMap);
        Test.stopTest();
        System.assertEquals(0, returnMap.size());
        System.assert(returnMap.isEmpty());
    }
    
    /**************************************************************************************
    * Method Name : getDataTest1
    * Description : Used to simulate and test the logic of getData method in OEDataProvider
    * Parameters  : NA
    * Return      : NA                      
    **************************************************************************************/
    static testmethod void getDataTest1() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('object', 'contact');
        Contact con = new Contact(LastName = 'Test Con');
        INSERT con;
        inputMap.put('id', con.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            OEDataProvider oe = new OEDataProvider();
            returnMap = oe.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('response'));
    }
    
    /**************************************************************************************
    * Method Name : getDataTest2
    * Description : Used to simulate and test the logic of getData method in OEDataProvider
    * Parameters  : NA
    * Return      : NA                      
    **************************************************************************************/
    static testmethod void getDataTest2() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('object', 'address');
        cscrm__Address__c addr = new cscrm__Address__c(Name = 'Test Addr');
        INSERT addr;
        inputMap.put('id', addr.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            OEDataProvider oe = new OEDataProvider();
            returnMap = oe.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('response'));
    }
    
    /**************************************************************************************
    * Method Name : getDataTest3
    * Description : Used to simulate and test the logic of getData method in OEDataProvider
    * Parameters  : NA
    * Return      : NA                      
    **************************************************************************************/
    static testmethod void getDataTest3() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('object', 'funccontact');
        Contact con = new Contact(LastName = 'Test Con');
        INSERT con;
        Functional_Contact_Role__c fcr = new Functional_Contact_Role__c(ContactID__c = con.Id);
        INSERT fcr;
        inputMap.put('id', fcr.Id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            OEDataProvider oe = new OEDataProvider();
            returnMap = oe.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('response'));
    }
}