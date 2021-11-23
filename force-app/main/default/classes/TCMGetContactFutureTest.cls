@isTest
public class TCMGetContactFutureTest {
  @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
           
    }
    static testMethod void UnitTest1(){
        Account a= TestUtil.createAccount('TestAccount');
        insert a;
       Contact c= TestUtil.createContact(a.Id,'FirstTest','LastTest');
       c.UUID__c ='123456';
        insert c;
        
        List<String> UUIDs = new List<String>();
        UUIDs.add(c.UUID__c);
        TCMGetContactFuture CallByUUIDs = new TCMGetContactFuture();
        CallByUUIDs.futureCalloutAccount(a,'TCMGETCONTACT');
    } 
    
     static testMethod void multiStaticResource(){
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/5B664C76-659F-4cce-A37A-0D94343CF7DB?include=customer-accounts&limit=50&offset=0', 'getcontact_5B664C76_659F_4cce_A37A_0D94343CF7DB');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/5FDD5562-660C-4a73-B8BA-2B9A0E5CE1F7?include=customer-accounts&limit=50&offset=0', 'getcontact_5FDD5562_660C_4a73_B8BA_2B9A0E5CE1F7');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/BEE8826B-5453-49f3-92F7-E9AA62A350A7?include=customer-accounts&limit=50&offset=0', 'getcontact_BEE8826B_5453_49f3_92F7_E9AA62A350A7');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('5B664C76-659F-4cce-A37A-0D94343CF7DB');
        contactUUIDs.add('5FDD5562-660C-4a73-B8BA-2B9A0E5CE1F7');
        contactUUIDs.add('BEE8826B-5453-49f3-92F7-E9AA62A350A7');
        TCMGetContactFuture CallByUUIDs = new TCMGetContactFuture();
        //CallByUUIDs.futureCalloutAccount(a);
        Test.stopTest();
    }
}