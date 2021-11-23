@isTest
public class TCMCustomerSearchLightningTest {
    
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
        
        Control_Manage_Invocation__c cmi = new Control_Manage_Invocation__c();
        cmi.Name ='GetContactInfo';
        cmi.GetContactInfo__c = True;
        insert cmi;
        
        Account a = TestUtil.createAccount('Smith');
        a.Customer_Status__c='SUSPECT';
        a.Pref_Comm_Method__c='Fax';
        a.Fax='12345';
        a.Customer_ID__c = '987654325';
        a.Type='Sole Trader';
        a.ABN__c='10000000000';
        a.ACN__c='123456';
        a.Website='www.vsygwoci.com';
        a.FraudFlag__c=false;
        a.VIP_Customer__c=false; 
        a.Phone='0412354327';
        a.birthDate__c='23-04-1994';
        a.Pref_Comm_Method__c='Fax';
        a.Email__c='sahs.ray@gmail.com';
        a.TCM_MasterID__c='123456789';
        a.CIDN__c='12345678';
        a.Service_ID__c='3456789';
        a.Name='Lastname';
        
        insert a;
        
    }
    
    private static HttpResponse res() {
        HttpResponse resp = new HttpResponse();
        resp.setStatus('OK');
        resp.setStatusCode(200);
        resp.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        return resp;
    }
    
    
    
    
    
    static testMethod void lastname_search() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        
        
        system.assertNotEquals('', TCMCustomerSearchControllerLightning.getTCMSearch('Smith', null, null, null, null, null, null, null, null, '0', null, null) );
        Test.stopTest();
        
    }
    
    
    
    static testMethod void abn_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertNotEquals('', TCMCustomerSearchControllerLightning.getTCMSearch(null, '10000000000', null, null, null, null, null, null, null, '0', null, null) );
        
        Test.stopTest();
    }
    
    static testMethod void abnsearch_exception() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        CustomerObject co=TCMCustomerSearchControllerLightning.searchByABN('78106902','649410310064160616',null,null,null);
        system.assertNotEquals(Null, co);
        Test.stopTest();
    }
    
    static testMethod void acn_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertNotEquals(null, TCMCustomerSearchControllerLightning.searchByACN('abc', '111470038', null,null,null) );
        
        Test.stopTest();
    }   
    static testMethod void fnn_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertNotEquals(null, TCMCustomerSearchControllerLightning.searchByFNN('0362100234', '0',null,null) );
        
        Test.stopTest();
    }   
    
    static testMethod void dob_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertNotEquals(null, TCMCustomerSearchControllerLightning.searchByDOB('Smith', '1998-12-12', null,null,null) );
        
        Test.stopTest();
    }   
    static testMethod void masterid_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertNotEquals(null, TCMCustomerSearchControllerLightning.searchByMasterID('10000156052', true, '0',null,null) );
        
        Test.stopTest();
    }   
    static testMethod void cac_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertNotEquals(null, TCMCustomerSearchControllerLightning.searchByCAC('2021916651', '0',null,null) );
        
        Test.stopTest();
    }   
    static testMethod void cidn_search() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertNotEquals(null, TCMCustomerSearchControllerLightning.searchByCIDN('3891261368', '0',null,null) );
        
        Test.stopTest();
    }  
    
    static testMethod void masterid_with_contacts() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        system.assertEquals(null, TCMCustomerSearchControllerLightning.searchByMasterIDForContactDetails('10000156052', true,'0',null,null) );
        
        Test.stopTest();
    } 
    
    static testmethod void accountcontactsave_test(){
        Test.startTest();
        CustomerObject.Customer customer = new CustomerObject.Customer();
        customer.masterID = '1234567890';
        customer.cidn ='2222222';
        customer.cac = '111111';
        customer.customerType ='Sole Trader';
        customer.lastVerifiedDate = '2017-09-09';
        customer.customerManagedFlag = 'Y';
        customer.effectiveRetiredDate='2017-09-09';
        
        customer.createdDate='1991-09-09';
        customer.ownershipCode='adadadd';
        customer.revenueOrganisationUnit='test'; 
        
        customer.customerAccount = new CustomerObject.CustomerAccount();
        customer.customerAccount.lastName = 'Lastname';
        customer.customerAccount.firstName ='first';
        //customer.customerAccount.middleName ='middle';
        customer.customerAccount.birthDate ='1991-09-09';
        //customer.customerAccount.driverLicenseNumber ='1234';
        //customer.customerAccount.driverLicenseState ='abcd';
        customer.customerAccount.accountUuid = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
        customer.customerAccount.dataSovereignty = '';
        customer.customerAccount.preferredMethod ='Email';
        customer.customerAccount.emailAddress = 'abc@abc.com';
        customer.customerAccount.faxNumber = '+61678465734'; 
        customer.customerAccount.phoneNumber = '+61212345678';
        JSON2TCMCustomerContactObject jo=new JSON2TCMCustomerContactObject();
        jo.Data = new JSON2TCMCustomerContactObject.Data();
        jo.Data.id ='123456';
        jo.Data.abn ='123456';
        jo.Data.acn ='123456';
        jo.Data.firstName ='rayna';
        jo.Data.accountStatus ='';
        jo.Data.lastName ='lastra';
        jo.Data.birthDate ='';
        /*   
jo.Contacts = new JSON2TCMCustomerContactObject.Contacts();
jo.Contacts .id='12345';
jo.Contacts .href ='';
jo.Contacts .title ='Mr';
jo.Contacts .firstName ='shambo';
jo.Contacts .middleName ='';
jo.Contacts .lastName ='ray';
jo.Contacts .birthDate ='1994-04-23';*/
        /*jc.endDate ='';
jc.contactType ='';
jc.contactUsage ='';*/
        
        TCMCustomerSearchControllerLightning.includeContacts=true;
        TCMCustomerSearchControllerLightning.convertToAccountContact(Json.serialize(jo));
        system.debug('json in test'+Json.serialize(customer));
        try{
            TCMCustomerSearchControllerLightning.accountContactSave('{'+Json.serialize(customer)+'}');
        }
        catch(Exception e){
            system.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
    
    static testMethod void searchByLastNameABN(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('Lastname','10000000000','','','','','','',''));
        //P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code 
	System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('Lastname','10000000000','',''));
        Test.stopTest();
    }
    static testMethod void searchByLastNameABNNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('Lastname','DKKd','','','','','','','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByLastNameACN(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('Lastname','','','','123456','','','',''));
        //P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code --START
	System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('Lastname','','123456',''));
        try{
            System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('Lastname','','sadw',''));
        }
        
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code --END
        Test.stopTest();
    }
    static testMethod void searchByLastNameACNNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('Lastname','','','','badbjda','','','','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByLastName(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('Lastname','','','','','','','',''));
        //P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code 
	System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('Lastname','','',''));
        Test.stopTest();
    }
    static testMethod void searchByDOB(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('Lastname','','23-04-1994','','','','','',''));
        Test.stopTest();
    }
    static testMethod void searchByDOBNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('hjhv','','23','','','','','','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }   
        
        Test.stopTest();
    }
    static testMethod void searchByMasterId(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','','','123456789',''));
        Test.stopTest();
    }
    static testMethod void searchByMasterIdNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','','','fsadfa','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByCIDN(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','','12345678','',''));
        //P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code --START
	System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('','','','12345678'));
        try{
            System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('','','','fafa'));
        }
        
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        //P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code --END
        Test.stopTest();
    }
    static testMethod void searchByCIDNNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','','fsgasag','','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByCAC(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','987654325','','',''));
        Test.stopTest();
    }
    static testMethod void searchByCACNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','svgaavs','','','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        
        Test.stopTest();
    }
    static testMethod void searchByFNN(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','','','','3456789'));
        
        Test.stopTest();
    }
    static testMethod void searchByFNNNegative(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('','','','','','','','','fasfafa');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByABNNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('','dafafgghhdfddah','','','','','','','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByABNOnly(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('','10000000000','','','','','','',''));
        //P2OB-3651 : Gives Coverage for getinternalSearch,getinternalSearchPRM existing code --START
	System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('','10000000000','',''));
        try{
            System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('','daw','',''));
        }        
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByABNLastName(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('324','10000000000','','','','','','',''));
        System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('last','10000000000','',''));
        try{
            System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('232','daw','',''));
        }
        
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    //P2OB-3651 : Gives Coverage for getinternalSearch,getinternalSearchPRM existing code --END
    static testMethod void searchByACNOnly(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        
        System.assertNotEquals(Null,TCMCustomerSearchControllerLightning.getinternalSearch('','','','','123456','','','',''));
        //P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code --START
	System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('','','123456',''));
        try{
            System.assertNotequals(Null,TCMCustomerSearchControllerLightning.getinternalSearchPRM('','','wrr',''));
        }
        
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getinternalSearchPRM existing code --END
        Test.stopTest();
    }    
    static testMethod void searchByACNNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getinternalSearch('','','','','fFFFVVVvD','','','','');
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }  
    static testMethod void searchByABNACNNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '10000000000', '', '', '462141', '', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getTCMSearch existing code --START
	try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '462141', '', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getTCMSearch existing code --END
        Test.stopTest();
    } 
    
    static testMethod void searchByABNACNNegativeNonNumeric(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', 'fFFFF', '', '', '', '', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    
    
    
    static testMethod void searchByABNACNNegative_two(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '123456', '462141', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    
    static testMethod void searchByABNACNNegativeNonNumeric_two(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', 'afagagag', '', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByMasteridLastname(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('Lastname', '', '', '', '', '', '', '10000156052', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getTCMSearch existing code --START
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('Lastname', '', '2017-09-09', '', '', '', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getTCMSearch existing code --END
        Test.stopTest();
    } 
    static testMethod void searchByMasteridTCM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '', '', 'daadadad', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getTCMSearch existing code --START
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '', '', '23124234', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
	//P2OB-3651 : Gives Coverage for getTCMSearch existing code --END
        Test.stopTest();
    } 
    static testMethod void searchByCIDNTCM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '', '3891261368', '', '', null, null, null);
            
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByCIDNCACTCM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '2021916651', '3891261368', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByCIDNCACTCMNonNumeric(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '', 'fsFSFf', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByCACTCM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '2021916651', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByCACTCMinavalid(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('FFAVVDA', '', '', '', '', '2021916651', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByCACTCMInvalid_two(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', 'cCccc', '', '', '', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByFNNTCM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '', '', '', '0424979654', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByFNNTCMInvalid(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('', '', '', '', '', '', '', '', 'affafafa', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
    static testMethod void searchByFNNTCMInvalidTwo(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        //TCMCustomerSearchControllerLightning tcmSearch = new TCMCustomerSearchControllerLightning();
        try{
            TCMCustomerSearchControllerLightning.getTCMSearch('Lastname', '', '', '', '', '', '', '', '0424979654', null, null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
//P2OB-3651 : Modified for Test coverage for portfolio code changes -- START    
    static testmethod void accountcontactsave_test_PortfolioValid(){
        Test.startTest();
        List<user> userList = new List<user>();
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; 
        
        User admin = new User(alias = 'standt',email='adminuserTCMACC@testadmin.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdminTCMACC', languagelocalekey='en_US',localesidkey='en_US', 
                              profileid = pfAdmin.id, 
                              timezonesidkey='Australia/Sydney', 
                              username='TestingAdmin@TestingAdmin.com'); 
        userList.add(admin);
        insert userList;        
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABCTer1', 'XYZTer2'});
        insert territories;
        System.runAs(admin){
            CustomerObject customer1 = TCMCustomerSearchControllerLightning.convert(null);
            
            CustomerObject.Customer customer = new CustomerObject.Customer();
            customer.masterID = '1234567890';
            customer.cidn ='2222222';
            customer.cac = '111111';
            customer.customerType ='Sole Trader';
            customer.lastVerifiedDate = '2017-09-09';
            customer.customerManagedFlag = 'Y';
            customer.effectiveRetiredDate='2017-09-09';
            
            customer.createdDate='1991-09-09';
            customer.ownershipCode='adadadd';
            customer.revenueOrganisationUnit='test';
            customer.portfolioCode= 'ABCTer1'; 
            
            customer.customerAccount = new CustomerObject.CustomerAccount();
            customer.customerAccount.lastName = 'Lastname';
            customer.customerAccount.firstName ='first';
            customer.customerAccount.birthDate ='1991-09-09';
            customer.customerAccount.accountUuid = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
            customer.customerAccount.dataSovereignty = '';
            customer.customerAccount.preferredMethod ='Email';
            customer.customerAccount.emailAddress = 'abc@abc.com';
            customer.customerAccount.faxNumber = '+61678465734'; 
            customer.customerAccount.phoneNumber = '+61212345678';
            JSON2TCMCustomerContactObject jo=new JSON2TCMCustomerContactObject();
            jo.Data = new JSON2TCMCustomerContactObject.Data();
            jo.Data.id ='123456';
            jo.Data.abn ='123456';
            jo.Data.acn ='123456';
            jo.Data.firstName ='rayna';
            jo.Data.accountStatus ='';
            jo.Data.lastName ='lastra';
            jo.Data.birthDate ='';
            
            
            TCMCustomerSearchControllerLightning.includeContacts=true;
            TCMCustomerSearchControllerLightning.convertToAccountContact(Json.serialize(jo));
            system.debug('json in test'+Json.serialize(customer));
            try{
                TCMCustomerSearchControllerLightning.accountContactSave('{'+Json.serialize(customer)+'}');
            }
            catch(Exception e){
                system.assertNotEquals(null, e);
            }
            
            
        }
        Test.stopTest();
    } 
    static testmethod void accountcontactsave_test_invalid_portfolio(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        CustomerObject.Customer customer = new CustomerObject.Customer();
        customer.masterID = '1234567890';
        customer.cidn ='2222222';
        customer.cac = '111111';
        customer.customerType ='Sole Trader';
        customer.lastVerifiedDate = '2017-09-09';
        customer.customerManagedFlag = 'Y';
        customer.effectiveRetiredDate='2017-09-09';
        
        customer.createdDate='1991-09-09';
        customer.ownershipCode='adadadd';
        customer.revenueOrganisationUnit='test'; 
        customer.portfolioCode= 'SVU01'; 
        
        customer.customerAccount = new CustomerObject.CustomerAccount();
        customer.customerAccount.lastName = 'Lastname';
        customer.customerAccount.firstName ='first';
        customer.customerAccount.birthDate ='1991-09-09';
        customer.customerAccount.accountUuid = 'C3DE634F-6ED9-4240-9427-FA428F582BD4';
        customer.customerAccount.dataSovereignty = '';
        customer.customerAccount.preferredMethod ='Email';
        customer.customerAccount.emailAddress = 'abc@abc.com';
        customer.customerAccount.faxNumber = '+61678465734'; 
        customer.customerAccount.phoneNumber = '+61212345678';
        JSON2TCMCustomerContactObject jo=new JSON2TCMCustomerContactObject();
        jo.Data = new JSON2TCMCustomerContactObject.Data();
        jo.Data.id ='123456';
        jo.Data.abn ='123456';
        jo.Data.acn ='123456';
        jo.Data.firstName ='rayna';
        jo.Data.accountStatus ='';
        jo.Data.lastName ='lastra';
        jo.Data.birthDate ='';
        
        
        TCMCustomerSearchControllerLightning.includeContacts=false;
        TCMCustomerSearchControllerLightning.convertToAccountContact(Json.serialize(jo));
        system.debug('json in test'+Json.serialize(customer));
        try{
            TCMCustomerSearchControllerLightning.accountContactSave('{'+Json.serialize(customer)+'}');
        }
        catch(Exception e){
            system.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
 //P2OB-3651 : Modified for Test coverage for portfolio code changes -- END    
 //P2OB-3651 : Gives Coverage for getTCMSearchPRM existing code --START
    static testmethod void fetchUser_test(){
        try{
            TCMCustomerSearchControllerLightning.fetchUser();
        }
        catch(Exception e){
            system.assertNotEquals(null, e);
        }
    }
    static testMethod void searchByCIDNTCMPRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('', '', '', '3891261368', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('lastname', '', '', '3891261368', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('', '', '', 'fsefe', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByACNCIDNTCMPRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('', '', '004410833', '3891261368', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    
    static testMethod void searchByACNTCMPRM_numeric(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('', '', '004410833', '', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByACNNonNumeric_PRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('','', 'fFFFF', '', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByLastname_PRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('lname',null, '', '', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByABNACNNegative_two_PRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('','123456', '462141', '', '', null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByABNACNNegativePRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('', '10000000000','462141', '', '',  null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    
    static testMethod void searchByABNACNNegativeNonNumericPRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('', 'fFFFF','', '', '',  null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    } 
    static testMethod void searchByABNACNNegativeNumericPRM(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        try{
            TCMCustomerSearchControllerLightning.getTCMSearchPRM('', '34562','', '', '',  null, null);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());  
        }
        Test.stopTest();
    }
     //P2OB-3651 : Gives Coverage for getTCMSearchPRM existing code --END 
}