/*
    AUTHOR : Sajal Shah    
    DESCRIPTION : Test class for FundBalanceTransfer
*/


@isTest
public class FundBalanceTransferTest {
    static Id flexibleRecordId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();

    @testSetup static void setup() {
        EnvironmentVariable.put('onefund_okapi_certificate_name', 'sfdcokapijks');
        EnvironmentVariable.put('onefund_okapi_clientId', '1234');
        EnvironmentVariable.put('onefund_okapi_clientSecret', '1234');
        EnvironmentVariable.put('onefund_okapi_token_endpoint', 'https://slot1.org002.t-dev.telstra.net/v2/oauth/token');
        EnvironmentVariable.put('onefund_okapi_contenttype', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('onefund_okapi_patch_contenttype', 'application/json');
        EnvironmentVariable.put('onefund_okapi_transaction_endpoint', 'https://slot1.org002.t-dev.telstra.net/application/b2bforce/v1/OneFundTransaction');
        EnvironmentVariable.put('onefund_okapi_grantType', 'client_credentials');
        EnvironmentVariable.put('onefund_okapi_scope', 'ORDEREXPRESS');
        EnvironmentVariable.put('onefund_okapi_contributionBalance', 'contributionBalance');
    }

    @isTest
    public static void CheckOneFundRecordsWhenActive(){
        EnvironmentVariable.put('onefund_okapi_cidn', 'cidn');
        EnvironmentVariable.put('onefund_okapi_message', 'message');
        EnvironmentVariable.put('onefund_okapi_fundBalance', 'fundBalance');
        Account acc = TestDataFactory.generateAccount();
        acc.CIDN__c = '3898757888';
        Database.update(acc);
        OneFund__c oneFund = new OneFund__c(RecordTypeId = flexibleRecordId, CIDN__c=acc.id, OneFund_Accrual_Frequency__c='Monthly', OneFund_Status__c='Active');
        insert oneFund;
        System.debug('---oneFund---'+oneFund.CIDN__r.CIDN__c);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String,String> fundMap = FundBalanceTransfer.CheckOneFundRecords(acc.Id);
        Test.stopTest();
        System.assertEquals(true, !fundMap.isEmpty(), 'CheckOneFundRecordsWhenActive');
    }

    @isTest
    public static void CheckOneFundRecordsWhenInactive(){
        EnvironmentVariable.put('onefund_okapi_cidn', 'cidn');
        EnvironmentVariable.put('onefund_okapi_message', 'message');
        EnvironmentVariable.put('onefund_okapi_fundBalance', 'fundBalance');
        Account acc = TestDataFactory.generateAccount();
        acc.CIDN__c = '3898757888';
        Database.update(acc);
        OneFund__c oneFund = new OneFund__c(RecordTypeId = flexibleRecordId, CIDN__c=acc.id, OneFund_Accrual_Frequency__c='Monthly', OneFund_Status__c='Terminated');
        insert oneFund;
        System.debug('---oneFund---'+oneFund.CIDN__r.CIDN__c);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String,String> fundMap = FundBalanceTransfer.CheckOneFundRecords(acc.Id);
        Test.stopTest();
        System.assertEquals(false, fundMap == null, 'CheckOneFundRecordsWhenInactive');
    }

    @isTest
    public static void CheckOneFundRecordsWhenCatch(){
        Account acc = TestDataFactory.generateAccount();
        acc.CIDN__c = '3898757888';
        OneFund__c oneFund = new OneFund__c(RecordTypeId = flexibleRecordId, CIDN__c=acc.id, OneFund_Accrual_Frequency__c='Monthly', OneFund_Status__c='Active');
        insert oneFund;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String,String> fundMap = FundBalanceTransfer.CheckOneFundRecords(acc.Id);
        Test.stopTest();
        System.assertEquals(true, fundMap == null, 'CheckOneFundRecordsWhenCatch');
    }

    @isTest
    public static void createTelstraEnterpriceFundAllocationCatch(){
        EnvironmentVariable.put('onefund_okapi_cidn', 'cidn');
        EnvironmentVariable.put('onefund_okapi_message', 'message');
        Account acc = TestDataFactory.generateAccount();
        acc.CIDN__c = '3898757888';
        Database.update(acc);
        OneFund__c oneFund = new OneFund__c(RecordTypeId = flexibleRecordId, CIDN__c=acc.id, OneFund_Accrual_Frequency__c='Monthly', OneFund_Status__c='Active');
        insert oneFund;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String,String> fundMap = FundBalanceTransfer.CheckOneFundRecords(acc.Id);
        Test.stopTest();
        System.assertEquals(true, !fundMap.isEmpty(), 'createTelstraEnterpriceFundAllocationCatch');
    }

    // START: Added for DIGI-2094
    @isTest
    public static void WhenNoActiveOnefundTest(){
        EnvironmentVariable.put('onefund_okapi_cidn', 'cidn');
        EnvironmentVariable.put('onefund_okapi_message', 'message');
        Account acc = TestDataFactory.generateAccount();
        acc.CIDN__c = '3898757888';
        Database.update(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnefundHttpResponseGenerator());
        Map<String,String> fundMap = FundBalanceTransfer.CheckOneFundRecords(acc.Id);
        Test.stopTest();
        System.assertEquals(true, !fundMap.isEmpty(), 'createTelstraEnterpriceFundAllocationCatch');
    }
    //END for DIGI-2094
}