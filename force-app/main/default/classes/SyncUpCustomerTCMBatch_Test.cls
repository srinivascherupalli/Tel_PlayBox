/*
 * Test class for SyncUpCustomerTCMBatch
 */
 @isTest
public class SyncUpCustomerTCMBatch_Test{
    @testSetup 
    static void setup() {
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
        EnvironmentVariable.put('tcm_contact_scope', 'TCMCONTACT');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint', 'http://mocksandbox.getsandbox.com/MockService');
        
        Interface_Activation__c iActivation=new Interface_Activation__c(name='Manage Contact');
        iActivation.Status__c=true;
        insert iActivation;
        system.debug('Iactive'+iActivation);
        
        Interface_Activation__c iActivation2=new Interface_Activation__c(name='Manage Customer');
        iActivation2.Status__c=true;
        insert iActivation2;
        
    }
    static List<Account>getAccountList(String name,Integer num){
        List<Account> accList = new List<Account>();
        for(Integer i = 0;i<num;i++){
            Account acc = TestUtil.createAccount('Sample Account'+i);
            acc.Customer_Status__c = 'ACQUIRED';
            acc.Customer_Status__c='SUSPECT';
            acc.Pref_Comm_Method__c='Fax';
            acc.Fax='12345';
            acc.Customer_ID__c = '98765432'+i;
            acc.Type='Sole Trader';
            acc.ABN__c='aaaa';
            acc.ACN__c='ccc';
            acc.Website='www.infosys.com';
            acc.FraudFlag__c=false;
            acc.VIP_Customer__c=false; 
            acc.Phone='041235432'+i;
            acc.Email__c='test'+i+'@gmail.com'; 
            accList.add(acc);
        }
        
        return accList;
    }
    static List<cscrm__Account_Address_Relationship__c>getAddressAccountList(List<Account> accList,cscrm__Address__c address1){
        List<cscrm__Account_Address_Relationship__c> addAccJunctionObjectList = new List<cscrm__Account_Address_Relationship__c>();
        for(Account acc : accList){
            cscrm__Account_Address_Relationship__c accaddress = new cscrm__Account_Address_Relationship__c();
            accaddress.cscrm__Account__c= acc.id;
            accaddress.cscrm__Address__c= address1.id;
            accaddress.cscrm__Address_Type__c='Primary Address';
            accaddress.cscrm__Active__c = true;
            addAccJunctionObjectList.add(accaddress);   
        }
        return addAccJunctionObjectList;
    }
    @isTest
    static void positiveTest(){
        cscrm__Address__c address1 = new cscrm__Address__c();
        address1.Address_ID__c = '123';
        address1.cscrm__Street__c  = '150 TEST ROAD TEST';
        address1.cscrm__Address_Type__c ='Primary Address';
        address1.AddressCorrection__c=true;
        insert address1;
        System.assertEquals(address1.Address_ID__c,'123');
     
        List<Account> accList = getAccountList('Sample Account',15);
        insert accList;
        System.assertEquals(accList.size(), 15);
        List<cscrm__Account_Address_Relationship__c> addAccJunctionObjectList = getAddressAccountList(accList,address1);
        insert addAccJunctionObjectList;
        System.assertEquals(addAccJunctionObjectList.size(), 15);      
    
        test.StartTest();
        SyncUpCustomerTCMBatch invokeSyncObj = new SyncUpCustomerTCMBatch();
        Test.setMock(HttpCalloutMock.class, new SyncUpMockHttpResponseGenerator());
        Database.executeBatch(invokeSyncObj,15);
        test.StopTest();
    }
    @isTest
    static void negativeTest(){
        cscrm__Address__c address1 = new cscrm__Address__c();
        address1.Address_ID__c = '123';
        address1.cscrm__Street__c  = '150 TEST ROAD TEST';
        address1.cscrm__Address_Type__c ='Primary Address';
        address1.AddressCorrection__c=true;
        insert address1;
        System.assertEquals(address1.Address_ID__c,'123');
     
        List<Account> accList = getAccountList('Sample Account',15);
        insert accList;
        System.assertEquals(accList.size(), 15);
        List<cscrm__Account_Address_Relationship__c> addAccJunctionObjectList = getAddressAccountList(accList,address1);
        insert addAccJunctionObjectList;
        System.assertEquals(addAccJunctionObjectList.size(), 15);      
    
        test.StartTest();
        SyncUpCustomerTCMBatch  invokeSyncObj = new SyncUpCustomerTCMBatch();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        Database.executeBatch(invokeSyncObj,15);
        test.StopTest();
       
    }
}