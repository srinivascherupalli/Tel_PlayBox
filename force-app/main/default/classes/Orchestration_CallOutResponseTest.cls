/**================================================================
 * Appirio, Inc
 * Name: Orchestration_CallOutResponseTest
 * Description: This class is use to validate functionality of Orchestration_CallOutResponse class
 * Created Date: June 11, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/
@isTest
public class Orchestration_CallOutResponseTest {
    private static testMethod void testCalloutResponse() {
        Test.startTest();

        Orchestration_CallOutResponse response = new Orchestration_CallOutResponse('recordId', 'reqBody', 'responseBody', 'statusCode', 'loggerName', 'debugLevel', 'errorCategory', 'correlationId', 'errorCode', 12220202, 'requestMethod');
        Orchestration_CallOutResponse responseNew = new Orchestration_CallOutResponse('recordId', 'reqBody', 'responseBody', 'statusCode', 'loggerName', 'debugLevel', 'errorCategory', 'correlationId', 'errorCode', 12220202, 'requestMethod','uuid','errorDesc');

        System.assert(response != null);
        System.assert(responseNew != null);
        Test.stopTest();
    }
}