@isTest
public class TCMGetContactInfoTest {
    
    @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
    }
    
	static testMethod void contactImport200(){
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/WS0002?include=customer-accounts&limit=50&offset=0', 'tcm_200_WS0002');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('WS0002');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();
    }
    
    static testMethod void contactImport400(){
        Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/WS0001?include=customer-accounts&limit=50&offset=0', 'tcm_400_WS0001');
        multimock.setStatus('Bad Request');
        multimock.setStatusCode(400);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('WS0001');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();
    }
    
	static testMethod void contactImport401(){
		Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/401?include=customer-accounts&limit=50&offset=0', 'tcm_401');
        multimock.setStatus('Unauthorized');
        multimock.setStatusCode(401);
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('401');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();
    }
    
    static testMethod void contactImport403(){
		Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
		multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/403?include=customer-accounts&limit=50&offset=0', 'tcm_403');
        multimock.setStatus('Forbidden');
        multimock.setStatusCode(403);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('403');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();        
    }
    
	static testMethod void contactImport404(){
		Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
		multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/404?include=customer-accounts&limit=50&offset=0', 'tcm_404');
        multimock.setStatus('NotFound');
        multimock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('404');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();
    }
    
	static testMethod void contactImport405(){
		Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/405?include=customer-accounts&limit=50&offset=0', 'tcm_405');
        multimock.setStatus('Method not allowed');
        multimock.setStatusCode(405);
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('405');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();
    }
    
	static testMethod void contactImport415(){
		Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/415?include=customer-accounts&limit=50&offset=0', 'tcm_415');
        multimock.setStatus('Unsupported Media Type');
        multimock.setStatusCode(415);
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('415');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();        
    }
    
	static testMethod void contactImport500(){
		Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/GEN-0001?include=customer-accounts&limit=50&offset=0', 'tcm_500_GEN_0001');
        multimock.setStatus('Internal Server Error');
        multimock.setStatusCode(500);
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('GEN-0001');
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();        
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
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
		TCMGetContactInfo SearchByContactUUID_1= new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID_1.contactUUIDs(contactUUIDs);
        system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();
    }
    static testMethod void contactImport200ForAddress(){
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/5B664C76-659F-4cce-A37A-0D94343CF7DB?include=customer-accounts&limit=50&offset=0', 'TCMgetContact2');
       
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('5B664C76-659F-4cce-A37A-0D94343CF7DB');
        
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMGetContactInfo');
        searchByContactUUID.contactUUIDs(contactUUIDs);
		system.assertNotEquals(Null, contactUUIDs);
        Test.stopTest();
    }

}