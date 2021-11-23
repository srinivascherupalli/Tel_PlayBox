@isTest
public class CS_ConfirmedAddressesTest {

    public static testmethod void priceItemSearchReturningResult()
    {
        cscrm__Address__c addset = new cscrm__Address__c();
        addset.Name = 'TestAddress';
        addset.Address_ID__c = 'abc';
        addset.Address_Status__c = 'CONFIRMED';
       	insert addset;
		Map<String,String> searchFields = new Map<String,String>();
        searchFields.put('searchValue', 'abc');
        CS_ConfirmedAddresses piItem = new CS_ConfirmedAddresses();
        Test.startTest();
        Object[] res = piItem.doLookupSearch(searchFields, '1234rfdff4r3rr4',null,1,1);
        Test.stopTest();
        System.assertEquals(res.size()!=null,true);       
    }
}