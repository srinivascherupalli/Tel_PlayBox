@isTest
public class TCMBusinessErrorCodeTest {
	


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
        
        insert new IntegrationSettings__c(SetupOwnerId=UserInfo.getOrganizationId(), EnableMocks__c=False);
       	ValidationRuleErrors__c ValidationRuleErrors=new ValidationRuleErrors__c();
        
        ValidationRuleErrors.Name='VR0001';
        ValidationRuleErrors.Value__c='The value entered for Salutation of contact is invalid. Please update Salutation';
        insert ValidationRuleErrors;      
    }

    /**private static HttpResponse res() {
        HttpResponse resp = new HttpResponse();
        resp.setStatus('OK');
        resp.setStatusCode(200);
        resp.setBody('{ "access_token": "lFYpKM2LkokcsbzQFKfsMTiPeFcA","expires_in": "3599"}}');
        return resp;
    } 
    static testmethod void check_logexception(){
        try{
          test.startTest();
          Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
           Account account=new Account(Name='1434145');
           insert account;
            if(account.Name.isNumeric()){
                insert account;
            }
          test.stopTest();
        }
        
        catch(Exception e){
            try{ 
                TCMBusinessErrorCode.logCustomerExcepction('7899251778','TCMSEARCHSERVICETEST',e);
               }
            catch(NullPointerException ne){
            //If No Cidn available
            System.assertNotEquals(null, ne);
        }
        }	           
    }
    static testmethod void getErrorMap_test(){
        TCMBusinessErrorCode.getErrorMap();
    }
   static testmethod void getErrorMsg_test(){
        system.assertequals('VR0039',TCMBusinessErrorCode.getCode('test'.toLowercase()));
    }
    static testmethod void getErrorlogging_test(){
        try{
          test.startTest();
          Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
           Account account=new Account(Name='1434145');
           insert account;
            if(account.Name.isNumeric()){
                insert account;
            }
          test.stopTest();
        }
        
        catch(Exception e){
            try{ 
                CustomerObject.customer customer=new CustomerObject.Customer();
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
                TCMBusinessErrorCode.logException(e,'TCMSEARCHSERVICETEST',EnvironmentVariable.get('tcm_baseUrl'),customer,TCMBusinessErrorCodeTest.res());
               }
            catch(NullPointerException ne){
            //For no response of the cidn or cac
            System.assertNotEquals(null, ne);
        }
    }
    
}**/
}