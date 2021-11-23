@isTest
public class contactcontrollerTest {
    
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
    
     static testMethod void fnamelnamedobemailTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null, Contactcontroller.getStartSearch('Bourne','Jason','11-11-1981','jason.bourne@gmail.com','',false,false)) ;
        Test.stopTest();
    }
    
    static testMethod void fnamelnamedobemailTest_Negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('Bourne','Jason','11-11-1981','jason.bourne@gmail.com','456875457',true,true));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    static testMethod void getExpensestest(){
        ContactController.statuscode=200;
        ContactController.bodyresp='test';
        ContactController.httpURl='https://test.co.au';
        system.assertNotEquals(null, ContactController.getExpenses('fname'));
	}
    static testMethod void fnamelname() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
        system.assertNotEquals(Null, Contactcontroller.getStartSearch('Bourne','Jason','11-11-1981','','',false,false));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    
     static testMethod void conuuid() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //Contactcontroller tcmSearch = new Contactcontroller();
        System.assertNotEquals(Null, Contactcontroller.searchByContactUUID(null,true,false));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    static testMethod void fnamelname_Negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('Bourne','Jason','10-11-9459','acad.rat@gmail.com','',true,true));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    
    static testMethod void email() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('','','','jason.bourne@gmail.com','',false,false));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    
    static testMethod void email_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('','','','jason.bourne@gmail.com','',true,true));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
	
    static testMethod void dob() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('','','11-11-1981','','',false,false)); 
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    
    static testMethod void dob_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('','','11-11-1981','','',true,true)); 
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    
     static testMethod void uuid() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('','','','','1234567890',false,false)); 
       // tcmSearch.startSearch();
        Test.stopTest();
    } 
    
    static testMethod void uuid_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch('','','','','1234567890',true,true)); 
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    
    static testMethod void lnamedob() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch(null,'Jason','11-11-1981','','',false,false));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
    
    static testMethod void lnamedob_negative() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Contactcontroller tcmSearch = new Contactcontroller();
		System.assertNotEquals(Null,Contactcontroller.getStartSearch(null,'Jason','11-11-1981','','',true,true));
       // tcmSearch.startSearch();
        Test.stopTest();
    }
     
   
    static testMethod void contactImport_Not_200_conuuid(){
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
        //TCMGetContactInfo SearchByContactUUID = new TCMGetContactInfo();
         try{
             ContactController.searchByContactUUID('',true,false);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        Test.stopTest();
    }
     static testMethod void contactImport_Not_200_email(){
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
        //TCMGetContactInfo SearchByContactUUID = new TCMGetContactInfo();
         try{
             ContactController.searchByEmailAddress('',true,false);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        Test.stopTest();
    }
    static testMethod void contactSaveTest(){
        Test.startTest();
		String request = '[{"birthDate":"1991-03-01","customerAccounts":[{"accountUuid":"AD203578-6C0E-4e49-A9EC-831A172C0531","businessUnit":"","contactRelationship":{"contactType":"Full Authority","contactUsage":"Business","endDate":""},"dataSovereignty":"","directMailOptIn":"Y","emailOptIn":"Y","faceToFaceOptIn":"Y","id":"10000113307","lastName":"GAME PROPRIETARY LIMITED","mmsOptIn":"Y","phoneOptIn":"Y","smsOptIn":"Y"}],"firstName":"MARY","homeContact":{"emailAddress":"chetan.soni@team.telstra.com","faxNumber":"","mobileNumber":"","phoneNumber":""},"id":"48B61A78-8114-4c68-B4CD-919DC6B1C2FA","identification":{"driverLicense":{"state":""}},"languagePreference":"","lastName":"SMITH","middleName":"","onlineFlag":"N","preferredMethod":"","status":"Active","title":"MRS","workContact":{"emailAddress":"","faxNumber":"","mobileNumber":"","phoneNumber":""}}]'; 
        map<String, String> mapSting = ContactController.contactsave(request);
        System.assertNotEquals(Null,mapSting);
        Test.stopTest();
	}

    static testMethod void contactImport_Not_200(){
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
        //TCMGetContactInfo SearchByContactUUID = new TCMGetContactInfo();
         try{
             ContactController.offset=null;
             ContactController.searchByName('Mary','Smith',null,null);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        Test.stopTest();
    }
    
    
    static testMethod void contactImport_Not_200_Exception(){
        Test.startTest();
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('', 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_contactEndpoint')+'/WS0001?include=customer-accounts&limit=50&offset=0', 'tcm_400_WS0001');
        multimock.setStatus('Bad Request');
        multimock.setStatusCode(400);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        List<String> contactUUIDs = new List<String>();
        contactUUIDs.add('WS0001');
        //TCMGetContactInfo SearchByContactUUID = new TCMGetContactInfo();
         try{
             ContactController.offset=null;
             ContactController.searchByName('','',null,null);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        try{
             ContactController.searchByEmailAddress('',true,false);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        try{
             ContactController.offset=null;
             ContactController.searchByLastNameBirthDate('Mary','23-04-1994',null,null);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        try{
             ContactController.offset=null;
             ContactController.searchByBirthDate('23-04-1994',null,null);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        Test.stopTest();
    }
    
    
    static testMethod void contactImport_Not_200_searchByLastNameBirthDate(){
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
        //TCMGetContactInfo SearchByContactUUID = new TCMGetContactInfo();
         try{
             ContactController.offset=null;
             ContactController.searchByLastNameBirthDate('Mary','23-04-1994',null,null);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        Test.stopTest();
    } 
    
      static testMethod void contactImport_Not_200_searchByBirthDate(){
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
        //TCMGetContactInfo SearchByContactUUID = new TCMGetContactInfo();
         try{
             ContactController.offset=null;
             ContactController.searchByBirthDate('23-04-1994',null,null);
         }
         catch(Exception e){
             system.assertNotEquals('', e.getMessage());
         }
        Test.stopTest();
    }    
     
}