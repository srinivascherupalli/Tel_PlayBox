/**************************************************************************
EDGE        - 215747
component   -
Description - Test class for OneOffChargeDetailsHandler 
Author      - Pawan Singh
Team        - Munich 
*********************************************************************************/

@isTest
public with sharing class OneOffChargeDetailsHandlerTest {

    
    @isTest
    public static void calloutOneOffChargeDetailsFail(){
       // String reqBody = '{"chargeId":"7001","statementNumber":"9900000182889","accountNumber":555666444}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnceOffCallout('success_Error'));
        string response = OneOffChargeDetailsHandler.calloutOneOffChargeDetails(7001,'9900000182889','555666444','InvoiceOrderHandler');
        Test.stopTest();
        System.assertNotEquals(Null, response);        
    }
    
    
    @isTest
    public static void calloutOneOffChargeDetailsPass(){
       // String reqBody = '{"chargeId":"7001","statementNumber":"9900000182889","accountNumber":555666444}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnceOffCallout('success_Search'));
        String response = OneOffChargeDetailsHandler.calloutOneOffChargeDetails(7001,'9900000182889','555666444','InvoiceOrderHandler');
        Test.stopTest();
        System.assertNotEquals(Null,response);        
        
    }

    @isTest
    public static void calloutOneOffChargeDetailsException(){
        //String reqBody = '{"chargeId":"7001","statementNumber":"9900000182889"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnceOffCallout('success_Search'));
        String response = OneOffChargeDetailsHandler.calloutOneOffChargeDetails(7001,'9900000182889','555666444','Handler');
        Test.stopTest();
        list<Exception_Log__c> expList = [select id,Error_Description__c from Exception_Log__c];
        system.assertEquals('Attempt to de-reference a null object',expList[0].Error_Description__c);
                
     }
}