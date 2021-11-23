@isTest
public class EDISSingleTransformerTest {
    
    @isTest
    static void fromDTOtoRequestTest(){
        String jsonStr = '{"path": "","method": "POST","data": { "type": "","serviceOrderDetails": { "temporaryServiceIndicator": "N","telstraCommitmentDate": null,"telstraAddressId": "241031544","soCreationTimestamp": null, "serviceType": "","provisionCompletionDate": "","productName": "","portFlag": "", "originatingSystem": "", "originalGivenNames": "","originalFNN": "","originalFamilyOrEntityName": "", "originalAddressIdentifier": "","orderType": "", "orderStatus": "","orderID": null,"listCode": "No Entry Line","lineItemStatus": "","interimServiceIndicator": "N","alternateAddressFlag": "T"},"listingDetails": {"subactionCode": "", "reasonCode": "","organizationName": "","listingFNN": "","givenNames": "TestMunich","familyOrEntityName": "TestMunich","actionCode": "add"},"customerDetails": {"registeredCompanyName": "", "givenNames": "TestMunich","familyName": "TestMunich","customerType": "Company","customerTitle": null,"customerID": "9834556", "customerContactGivenNames": "","customerContactFamilyName": "","contactPosition": "","contactFNN": 0,"contactEmail": "praj@gmail.com"},"customerContactAddress": {"ccaOverseasAddressLine3": "","ccaOverseasAddressLine2": "","ccaOverseasAddressLine1": "","ccaOverseasAddressCountryCode": "","ccaIdentifier": "241031544"}},"correlationId": "798cd026-07e1-7af1-9e5d-1f20f9f7d9bd"}}';
        Test.startTest();
        EDISSingleRequestDTO edissingledto = EDISSingleRequestDTO.parse(jsonStr);
        EDISSingleTransformer.fromDTOtoRequest(edissingledto);
        Test.stopTest();
        system.assertNotEquals(null, EDISSingleTransformer.fromDTOtoRequest(edissingledto));
    }

}