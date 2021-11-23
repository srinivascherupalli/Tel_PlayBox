@isTest
public class DocusignClientRESTCallTest{
    
    @isTest(seeAllData=False)
    Public static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpDocuSignResGenerator());
        Organization OrgDetails = [select id,IsSandbox, InstanceName from Organization LIMIT 1];
        String DeveloperNameDocuSign = '';
        if(OrgDetails.IsSandbox){
            DeveloperNameDocuSign = 'DocuSign_Sandbox_Org';
        }
        else{
            DeveloperNameDocuSign = 'DocuSign_Prod_Org';
        }
        DocuSign_REST_API__mdt docuSignAPIDetails = RetractContractComponent.getDocuSignMataDataType(DeveloperNameDocuSign);
        String voidReason = 'Test void reason';
        String envelopeId = '60B2E98B-4244-4409-80A6-E90DF35DC9FC';
        dsfs__DocuSign_Status__c docuSignStatus = new dsfs__DocuSign_Status__c();
        dsfs__DocuSign_Recipient_Status__c docuSignRecStatus = new dsfs__DocuSign_Recipient_Status__c();
        // Call method to test
        DocusignClientRESTCall docuSignRestCall = new DocusignClientRESTCall();
        Test.startTest();
        HttpResponse res = docuSignRestCall.voidEnvelope(envelopeId,voidReason,docuSignAPIDetails);
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        System.assertEquals(actualValue, expectedValue);
		Test.stopTest();
   
    }
}