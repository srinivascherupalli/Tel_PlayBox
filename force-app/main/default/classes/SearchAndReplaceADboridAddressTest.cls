@isTest
public class SearchAndReplaceADboridAddressTest {
	@testSetup 
    static void setup() {
        List<cscrm__Address__c> addresses = new List<cscrm__Address__c>();
        // insert 10 accounts
        for (Integer i=0;i<1;i++) {
            addresses.add(new cscrm__Address__c(Address_ID__c='	240543'+i, 
                cscrm__City__c='New York', cscrm__Country__c='USA', Source_System__c='TCM'));
        }
        insert addresses;
    }

    static testmethod void test() {        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SearchAndReplaceADboridAddressMock());
        String q = 'SELECT Address_ID__c,Id,Source_System__c FROM cscrm__Address__c WHERE Source_System__c = \'TCM\' AND (NOT Address_ID__c LIKE \'T%\') AND (NOT Address_ID__c LIKE \'U%\')' ; 
        Database.executeBatch(new SearchAndReplaceADboridAddress(q)); 
        Test.stopTest();

        // after the testing stops, assert records were updated properly
        System.assertEquals(1, [select count() from cscrm__Address__c where Source_System__c = 'EAST']);
    }
}