@isTest
public class SiteLookupImplementationTests {
	@testSetup
    static void testDataSetup() {
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        insert testAccount;
        
        cscrm__Address__c testAddress = new cscrm__Address__c();
        testAddress.Address_ID__c = '444333';
        insert testAddress;
        
        cscrm__Site__c testSite = new cscrm__Site__c();
        testSite.Name = 'Test Site';
        testSite.cscrm__Installation_Address__c = testAddress.Id;
        testSite.cscrm__Account__c = testAccount.Id;
        insert testSite;
    }
    
    @isTest
    static void testDoLookupSearch() {
        Account testAccount = [SELECT Id FROM Account];
        Map<String, String> mapOfSearchFields = new Map<String, String>();
        mapOfSearchFields.put('AccountId', testAccount.Id);
        mapOfSearchFields.put('adborId', '444333');
        
        Test.startTest();
        	SiteLookupImplementation obj = new SiteLookupImplementation();
        	List<Object> listOfObject = obj.doLookupSearch(mapOfSearchFields, null, null, 0,0);
        Test.stopTest();
        System.assertNotEquals(listOfObject,null,'Value should not be null');
        
    }
    
    @isTest
    static void testDoLookupSearchWhenAdborIdIsNUll() {
        Account testAccount = [SELECT Id FROM Account];
        Map<String, String> mapOfSearchFields = new Map<String, String>();
        mapOfSearchFields.put('AccountId', testAccount.Id);
        mapOfSearchFields.put('searchValue', 'searchValue');
        
        Test.startTest();
        	SiteLookupImplementation obj = new SiteLookupImplementation();
        	List<Object> listOfObject = obj.doLookupSearch(mapOfSearchFields, null, null, 0,0);
        	obj.getRequiredAttributes();
        Test.stopTest();
        System.assertNotEquals(listOfObject,null,'Value should not be null');
        
    }
}