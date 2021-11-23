@isTest
public class AddressEastCalloutTest {
 @isTest
    public static void executeQueable(){
        Test.setMock(HttpCalloutMock.class, new MockAddressSearchResponse('Adbor'));
        Test.startTest();
        List<String> adboridList = new  List<String>{'161152457'};
		AddressEastCallout.makeCallout(adboridList);
        Test.stopTest();
        System.assertEquals([SELECT count() FROM cscrm__Address__c]>0, true,'East callout successful');
    }
}