/* ****************************************************************************
*Class Name     : SolutionHelperESACodeTest
* Author        : Laxmi Rahate || EDGE-113848
* Date          : 28 NOv 2019
* Description   : This is a test class to simulate and test the logic of SolutionHelperESACode
* *****************************************************************************/

@isTest(SeeAllData=FALSE)
public class SolutionHelperESACodeTest {
    
  /******************************************************************************************************
    * Method Name : getESACodeTest
    * Description : Used to simulate and test the logic of getESACode method in SolutionHelperESACode
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    @isTest static void getESACodeTest(){
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('adborID','123456');
        inputMap.put('cidn','SHLN');
     
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap1.put('adborID','654321');
        inputMap1.put('cidn','SHLN');
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.CIDN__c = 'SHLN';
        insert acc;
        
        cscrm__Address__c address = AccountTestFactory.buildAddress ('TestAddress');
        address.Address_ID__c = '123456';
        address.ESA_Code__c  = 'ESA Code';
        
        insert address;

        cscrm__Address__c address1 = AccountTestFactory.buildAddress ('TestAddress');
        address.Address_ID__c = '654321';
        address.ESA_Code__c  = null;
        
        insert address1;
    
        cscrm__Site__c site = new cscrm__Site__c(Name = 'Test Site', cscrm__Account__c = acc.id, cscrm__Installation_Address__c = address.id );
        cscrm__Site__c site1 = new cscrm__Site__c(Name = 'Test Site', cscrm__Account__c = acc.id, cscrm__Installation_Address__c = address1.id );

        INSERT site;
        
        Test.startTest();
        Map<String, Object> returnMap = new Map<String, Object>();

        SolutionHelperESACode solnHelESACode = new SolutionHelperESACode();
        returnMap = solnHelESACode.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());

    }
}