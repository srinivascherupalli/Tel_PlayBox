/*
    AUTHOR : Sajal Shah    
    DESCRIPTION : This class is the Test class for GetOneFundTransferToken
*/


@isTest
public class GetOneFundTransferTokenTest {
    
    @testSetup static void setup() {
        EnvironmentVariable.put('onefund_okapi_certificate_name', 'sfdcokapijks');
        EnvironmentVariable.put('onefund_okapi_clientId', '1234');
        EnvironmentVariable.put('onefund_okapi_clientSecret', '1234');
        EnvironmentVariable.put('onefund_okapi_contenttype', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('onefund_okapi_patch_contenttype', 'application/json');
        EnvironmentVariable.put('onefund_okapi_grantType', 'client_credentials');
        EnvironmentVariable.put('onefund_okapi_scope', 'ORDEREXPRESS');
        EnvironmentVariable.put('onefund_okapi_cidn', 'cidn');
        EnvironmentVariable.put('onefund_okapi_fundBalance', 'fundBalance');
        EnvironmentVariable.put('onefund_okapi_contributionBalance', 'contributionBalance');
        EnvironmentVariable.put('onefund_okapi_message', 'message');
    }

    static testMethod void GetResponseWhenSameCidn() {
        EnvironmentVariable.put('onefund_okapi_token_endpoint', 'https://slot1.org002.t-dev.telstra.net/v2/oauth/token');
        EnvironmentVariable.put('onefund_okapi_transaction_endpoint', 'https://slot1.org002.t-dev.telstra.net/application/b2bforce/v1/OneFundTransaction');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String, String> tokenResponseMap = GetOneFundTransferToken.getOneFundAuthToken('3898757888');
        System.assertEquals('3898757888',tokenResponseMap.get('cidn'),'Check Same Cidn');
        Test.stopTest();
    }

    static testMethod void GetResponseWhenGetCallout() {
        EnvironmentVariable.put('onefund_okapi_transaction_endpoint', 'https://slot1.org002.t-dev.telstra.net/application/b2bforce/v1/OneFundTransaction');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String, String> tokenResponseMap = GetOneFundTransferToken.getOneFundTransactionDetails();
        System.assertEquals(tokenResponseMap.get('contributionBalance') > '0.0', true, 'GetResponseWhenGetCallout');
        Test.stopTest();
    }

    static testMethod void GetResponseWhenPatchCallout() {
        EnvironmentVariable.put('onefund_okapi_transaction_endpoint', 'https://slot1.org002.t-dev.telstra.net/application/b2bforce/v1/OneFundTransaction');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String, String> tokenResponseMap = GetOneFundTransferToken.getOneFundTransactionTransfer();
        System.assertEquals(true, tokenResponseMap.size() > 0, 'One fund account found!');
        Test.stopTest();
    }

    static testMethod void GetExceptionWhenGetCalloutWithoutEndpoint() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String, String> tokenResponseMap = GetOneFundTransferToken.getOneFundAuthToken('3898757888');
        System.assertEquals(null,tokenResponseMap.get('cidn'),'GetExceptionWhenGetCalloutWithoutEndpoint');
        Test.stopTest();
    }

    static testMethod void GetExceptionWhenPostCalloutNullResponse() {
        EnvironmentVariable.put('onefund_okapi_token_endpoint', 'https://slot1.org002.t-dev.telstra.net/v2/oauth/token');
        EnvironmentVariable.put('onefund_okapi_transaction_endpoint', null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String, String> tokenResponseMap = GetOneFundTransferToken.getOneFundAuthToken('3898757888');
        System.assertEquals(null,tokenResponseMap.get('cidn'),'GetExceptionWhenPostCalloutNullResponse');
        Test.stopTest();
    }

    static testMethod void GetExceptionWhenGetCalloutNullResponse() {
        EnvironmentVariable.put('onefund_okapi_transaction_endpoint', 'https://slot1.org002.t-dev.telstra.net/application/b2bforce/v1/OneFundTransactionTest');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String, String> tokenResponseMap = GetOneFundTransferToken.getOneFundTransactionDetails();
        System.assertEquals(null,tokenResponseMap.get('cidn'),'GetExceptionWhenGetCalloutNullResponse');
        Test.stopTest();
    }

    static testMethod void GetExceptionWhenPatchCalloutNullResponse() {
        EnvironmentVariable.put('onefund_okapi_transaction_endpoint', 'https://slot1.org002.t-dev.telstra.net/application/b2bforce/v1/OneFundTransactionTestPatch');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String, String> tokenResponseMap = GetOneFundTransferToken.getOneFundTransactionTransfer();
        System.assertEquals(null,tokenResponseMap.get('cidn'),'GetExceptionWhenPatchCalloutNullResponse');
        Test.stopTest();
    }
    
}