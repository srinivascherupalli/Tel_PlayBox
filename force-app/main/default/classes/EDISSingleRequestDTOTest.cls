@isTest
public class EDISSingleRequestDTOTest {
	@istest 
    static void test_parse() {
       String jsonStr = '{"path": "","method": "POST","data": { "type": "","serviceOrderDetails": { "temporaryServiceIndicator": "N","telstraCommitmentDate": null,"telstraAddressId": "241031544","soCreationTimestamp": null, "serviceType": "","provisionCompletionDate": "","productName": "","portFlag": "", "originatingSystem": "", "originalGivenNames": "","originalFNN": "","originalFamilyName": "", "originalAddressIdentifier": "","orderType": "", "orderStatus": "","orderID": null,"listCode": "No Entry Line","lineItemStatus": "","interimServiceIndicator": "N","alternateAddressFlag": "T"},"listingDetails": {"subactionCode": "", "reasonCode": "","organizationName": "","listingFNN": "","givenNames": "TestMunich","familyOrEntityName": "TestMunich","actionCode": "add"},"customerDetails": {"registeredCompanyName": "", "givenNames": "TestMunich","familyName": "TestMunich","customerType": "Company","customerTitle": null,"customerID": "9834556", "customerContactGivenNames": "","customerContactFamilyName": "","contactPosition": "","contactFNN": 0,"contactEmail": "praj@gmail.com"},"customerContactAddress": {"ccaOverseasAddressLine3": "","ccaOverseasAddressLine2": "","ccaOverseasAddressLine1": "","ccaOverseasAddressCountryCode": "","ccaIdentifier": "241031544"}},"correlationId": "798cd026-07e1-7af1-9e5d-1f20f9f7d9bd"}}';
    
    Test.startTest();
    EDISSingleRequestDTO edissingledto = EDISSingleRequestDTO.parse(jsonStr);
    Test.stopTest();
    System.assertEquals('798cd026-07e1-7af1-9e5d-1f20f9f7d9bd', edissingledto.correlationId);
    System.assertEquals('', edissingledto.path);
    System.assertEquals('POST', edissingledto.method);
    System.assertEquals('', edissingledto.data.type);
    System.assertEquals('N', edissingledto.data.serviceOrderDetails.temporaryServiceIndicator);
        System.assertEquals(null, edissingledto.data.serviceOrderDetails.telstraCommitmentDate);
        System.assertEquals('241031544', edissingledto.data.serviceOrderDetails.telstraAddressId);
        System.assertEquals(null, edissingledto.data.serviceOrderDetails.soCreationTimestamp);
        System.assertEquals('', edissingledto.data.serviceOrderDetails.serviceType);
        System.assertEquals('', edissingledto.data.serviceOrderDetails.provisionCompletionDate);
     	System.assertEquals('', edissingledto.data.serviceOrderDetails.productName);
        System.assertEquals('', edissingledto.data.serviceOrderDetails.portFlag);
        System.assertEquals('', edissingledto.data.serviceOrderDetails.originatingSystem);
        System.assertEquals('N', edissingledto.data.serviceOrderDetails.interimServiceIndicator);
        System.assertEquals('T', edissingledto.data.serviceOrderDetails.alternateAddressFlag);
        System.assertEquals('TestMunich', edissingledto.data.listingDetails.givenNames);
        System.assertEquals('TestMunich', edissingledto.data.listingDetails.familyOrEntityName);
        System.assertEquals('add', edissingledto.data.listingDetails.actionCode);
        System.assertEquals('', edissingledto.data.listingDetails.reasonCode);
        System.assertEquals('', edissingledto.data.listingDetails.organizationName);
        System.assertEquals('', edissingledto.data.customerDetails.registeredCompanyName);
        System.assertEquals('TestMunich', edissingledto.data.customerDetails.givenNames);
        System.assertEquals('TestMunich', edissingledto.data.customerDetails.familyName);
        System.assertEquals('Company', edissingledto.data.customerDetails.customerType);
        System.assertEquals('9834556', edissingledto.data.customerDetails.customerID);
        System.assertEquals(null, edissingledto.data.customerDetails.customerTitle);
        System.assertEquals('', edissingledto.data.customerDetails.customerContactGivenNames);
        System.assertEquals('', edissingledto.data.customerDetails.customerContactFamilyName);
        System.assertEquals('praj@gmail.com', edissingledto.data.customerDetails.contactEmail);
        System.assertEquals('', edissingledto.data.customerContactAddress.ccaOverseasAddressCountryCode);
        System.assertEquals('', edissingledto.data.customerContactAddress.ccaOverseasAddressLine3);
        System.assertEquals('', edissingledto.data.customerContactAddress.ccaOverseasAddressLine2);
        System.assertEquals('', edissingledto.data.customerContactAddress.ccaOverseasAddressLine1);
        System.assertEquals('241031544', edissingledto.data.customerContactAddress.ccaIdentifier);
         System.assertEquals('', edissingledto.data.CustomerDetails.contactPosition);
        System.assertEquals('0', edissingledto.data.CustomerDetails.contactFNN);
        System.assertEquals('', edissingledto.data.listingDetails.subactionCode);
        System.assertEquals('', edissingledto.data.listingDetails.listingFNN);
         System.assertEquals('No Entry Line', edissingledto.data.ServiceOrderDetails.listCode);
         System.assertEquals('', edissingledto.data.ServiceOrderDetails.orderType);
        System.assertEquals('', edissingledto.data.ServiceOrderDetails.orderStatus);
        System.assertEquals(null, edissingledto.data.ServiceOrderDetails.orderId);
         System.assertEquals('', edissingledto.data.ServiceOrderDetails.originalFNN);
        
          System.assertEquals('', edissingledto.data.ServiceOrderDetails.originalFamilyName);
          System.assertEquals('', edissingledto.data.ServiceOrderDetails.originalGivenNames);
          System.assertEquals('', edissingledto.data.ServiceOrderDetails.originalAddressIdentifier);
         System.assertEquals('', edissingledto.data.ServiceOrderDetails.lineItemStatus);
        
        
        
   
}
}