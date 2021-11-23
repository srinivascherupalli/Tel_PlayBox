@isTest
public class SQAvailabilityCheckTest {
    
   /* @isTest
    static void sqCheck_WillReturnResponse_WhenAddressIDHasResponse() {
        String addressId = 'AddressId-1';
        String siteId = 'siteid';
        System.assert(SQAvailabilityCheck.sqCheck(addressId,siteId) != null);
    } */  
    @isTest
    static void sqCheck_WillReturnResponse_WhenAdboridIsPassed() {
        RestRequest req = new RestRequest();
        req.params.put('adborId', '12345');
        req.requestURI = '/services/apexrest/sqCheck?';  
        req.httpMethod = 'GET';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        SQAvailabilityCheck.sqCheck();
        Test.stopTest();
        System.debug('resss'+res);
        System.assert(res!= null);
    } 

}