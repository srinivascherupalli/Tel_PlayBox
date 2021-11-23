/******************************************************** 
* Class Name      :   IntegrationRecordHandlerUtilTest
* ===============================================================================================================================
* Change.No.    Developer Name          Date          Story Description
* 1.            Shreya Jaiswal       15/10/19     added test method to increase the code coverage
*********************************************************
*/

/************
Modified By: Team Hawaii
Modified Date : 17/3/2030
Description : Modified only test data to fix test class failure due to introduction 
              of validation rule on contact object 
Key Note : Partner Contact record type of contact only use to create contact which is associated to partner user. 
Jira : P2OB-5160
***********/
@isTest
private class IntegrationRecordHandlerUtilTest {
    @testSetup static void setup() {
 
 
         UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
    
               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
          
        insert uSysAdmin;

        }
    
    private static String testMetadataTypeRecord = 'ManageCustomerCreateHandler';
    private static String testMetadataTypeSyncRecord = 'BillingAccountValidationService';
    private static String testMetadataTypeSyncRecordMassl = 'AddressValidateService';
    
    
    @isTest static void getIntegrationHandlerSettingsTest() {
        Integration_Handler__mdt manageCustomer_mdt = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(testMetadataTypeRecord);
        System.assert(manageCustomer_mdt != null, 'Error accessing the custom metadata');
    }
    
    @isTest static void getMaxNoOfRetriesTest() {
        Integer maxRetries = IntegrationRecordHandlerUtil.getMaxNoOfRetries(testMetadataTypeRecord);
        System.assert(maxRetries == 3, 'Error: incorrect maximum number of retries');
        
        maxRetries = IntegrationRecordHandlerUtil.getMaxNoOfRetries(null);
        System.assert(maxRetries == 3, 'Error: incorrect maximum number of retries');
    }
    
    @isTest static void getMaxNoOfRowsTest() {
        Integer maxRows = IntegrationRecordHandlerUtil.getMaxNoOfRows(testMetadataTypeRecord, 2);
        System.assertEquals(2, maxRows, 'Error: incorrect maximum number of rows');
        
        maxRows = IntegrationRecordHandlerUtil.getMaxNoOfRows(testMetadataTypeRecord, null);
        System.assertEquals(1, maxRows, 'Error: incorrect maximum number of rows');
        
        maxRows = IntegrationRecordHandlerUtil.getMaxNoOfRows(null, null);
        System.assertEquals(20, maxRows, 'Error: incorrect maximum number of rows when set via Custom Label');
        
    }
    
    @isTest static void getMaxNoOfParallelsTest() {
        Integer maxParallels = IntegrationRecordHandlerUtil.getMaxNoOfParallels(testMetadataTypeRecord, 2);
        System.assertEquals(2, maxParallels, 'Error: incorrect maximum number of Parallels');
        
        maxParallels = IntegrationRecordHandlerUtil.getMaxNoOfParallels(testMetadataTypeRecord, null);
        System.assertEquals(1, maxParallels, 'Error: incorrect maximum number of Parallels');
        
        maxParallels = IntegrationRecordHandlerUtil.getMaxNoOfParallels(null, null);
        System.assertEquals(1, maxParallels, 'Error: incorrect maximum number of Parallels');
        
        //Need to make sure the parallel number of requests do not exceed the Salesforce limit
        maxParallels = IntegrationRecordHandlerUtil.getMaxNoOfParallels(testMetadataTypeRecord, 200);
        System.assertEquals(50, maxParallels, 'Error: incorrect maximum number of Parallels');
        
    }
    
    @isTest static void createRequestsTest() {
        List<String> paramList = new List<String>{'123', '222'};
            IntegrationRecordHandlerUtil.createRequests(testMetadataTypeRecord, paramList);
        
        Test.StartTest();
        List<Integration_Record__c> intRecList = new List<Integration_Record__c>([SELECT Id 
                                                                                  FROM Integration_Record__c 
                                                                                  WHERE Handler__c = : testMetadataTypeRecord AND Params__c IN : paramList]);
        System.debug('IntRecList: ' + intRecList); 
        Test.stopTest();
        
        System.assertNotEquals(null, intRecList.size(), 'Error in creating Integration Records');
    }
    //Start Changes for EDGE-127536 Code Refector 
    @isTest static void createRequestsForTramasTest() {
        List<String> paramList = new List<String>{'123', '222'};
         List<Integration_Record__c> existingRequests = new List<Integration_Record__c>();
            IntegrationRecordHandlerUtil.createRequestsForTramas('TM2TramasExecution', paramList,null,existingRequests);
        
        Test.StartTest();
        List<Integration_Record__c> intRecList = new List<Integration_Record__c>([SELECT Id 
                                                                                  FROM Integration_Record__c 
                                                                                  WHERE Handler__c = : 'TM2TramasExecution' AND Params__c IN : paramList]);
        System.debug('IntRecList: ' + intRecList); 
        Test.stopTest();
        
        System.assertNotEquals(null, intRecList.size(), 'Error in creating Integration Records');
    }
      //End Changes for EDGE-127536 Code Refector 
    @isTest static void callout_successTest() {
        List<String> paramList = new List<String>{'123', '222'};
            HttpResponse res = new HttpResponse();
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_POST, null, testMetadataTypeRecord, paramList, null);
        Test.stopTest();
        System.assert(null != res);
    }
    
    @isTest static void callout_successTestOverload() {
        List<String> paramList = new List<String>{'123', '222'};
            HttpResponse res = new HttpResponse();
        Map<String,String> pathMap = new Map<String,String>();
        pathMap.put('70000008987','subscriptions');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_POST, null, testMetadataTypeRecord, paramList, null,pathMap);
        Test.stopTest();
        System.assert(null != res);
    }
     @isTest static void callout_successTestOverloadGet() {
        List<String> paramList = new List<String>{'123', '222'};
            HttpResponse res = new HttpResponse();
        Map<String,String> pathMap = new Map<String,String>();
        pathMap.put('70000008987','subscriptions');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_GET, null, testMetadataTypeSyncRecordMassl, paramList, null,pathMap);
        Test.stopTest();
        System.assert(null != res);
    }
    
    
    @isTest static void callout_successTest1() {
        List<String> paramList = new List<String>{'123', '222'};
            HttpResponse res = new HttpResponse();
        Map<String,String> pathMap = new Map<String,String>();
        pathMap.put('70000008987','subscriptions');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_POST, null, testMetadataTypeRecord, paramList);
        Test.stopTest();
        System.assert(null != res);
    }
    
    @isTest static void callout_successTestGet() {
        Map<String,String> headers = new Map<String, String>{'Content-Type' => 'application/json'};
        List<String> paramList = new List<String>{'123', '222'};
            HttpResponse res = new HttpResponse();
        Map<String,String> pathMap = new Map<String,String>();
        pathMap.put('70000008987','subscriptions');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headers, testMetadataTypeRecord, paramList);
        Test.stopTest();
        System.assert(null != res);
    }
    
    @isTest static void callout_Sync_successTest() {
		HttpResponse res = new HttpResponse();
        Map<String,String> headers = new Map<String, String>{'Content-Type' => 'application/json'};
            Map<String,String> pathMap = new Map<String,String>();
                pathMap.put('70000008987','subscriptions');
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res = IntegrationRecordHandlerUtil.calloutSync('', IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headers, testMetadataTypeSyncRecord,pathMap);
        Test.stopTest();
        System.assert( res != null);
        }
    
     @isTest static void callout_Sync_successTest1() {

        Map<String,String> headers = new Map<String, String>{'Content-Type' => 'application/json'};
        HttpResponse res = new HttpResponse();  
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res = IntegrationRecordHandlerUtil.calloutSync('', IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headers, testMetadataTypeSyncRecord);
        Test.stopTest();
         System.assert(res != null);
        }
    
    
    @isTest static void callout_failTest() {
        List<String> paramList = new List<String>{'123', '222'};
            HttpResponse res = new HttpResponse();
        HttpResponse res1 = new HttpResponse();
        Map<String,String> headers = new Map<String, String>{'Content-Type' => 'application/json'};
            Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        res=IntegrationRecordHandlerUtil.callout('Error', IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headers, testMetadataTypeRecord, paramList, null);
        res1=IntegrationRecordHandlerUtil.callout('Error', IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headers, testMetadataTypeRecord, paramList, null);
        
        System.assert(null != res);
        Test.stopTest();
    }
    
    @isTest static void isValidHandlerTest() {
        //Enter a handler name at org level that should be excluded from queuing
        Environment_Configurations__c intHandlerSetting = new Environment_Configurations__c();
        intHandlerSetting.Exclude_Integration_Handlers__c = 'excludedHandler';
        insert intHandlerSetting;
        
        Boolean checkValidity = EnvironmentalSettings.isValidHandler(testMetadataTypeRecord);
        System.assert(checkValidity, 'Error: handler incorrectly marked as invalid');
        
        checkValidity = EnvironmentalSettings.isValidHandler('excludedHandler');
        System.assert(!checkValidity, 'Error: handler incorrectly marked as valid');        
    }
    
    
    
    
    @isTest static void getUUIDTest(){
        IntegrationRecordHandlerUtil.getUUID();
        system.assertNotEquals(null,IntegrationRecordHandlerUtil.getUUID());
    }
    @isTest static void calloutContinuationTest() {        
        Account ac = new Account(name ='Telecom',Account_Status__c = 'Active');
        insert ac; 
        Account ac1 = new Account(name ='Telecom',Account_Status__c = 'New');
        insert ac1; 
        
        insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');
        String params = JSON.serialize(
            new Map<String, Object> {
                'userPid' => '',
                    'userFirstName'=>'Nikita',
                    'userLastName'=>'Tiwa',
                    'userEmail'=>'abc@telstra.com',
                    'isPDUA'=>'false',
                    'isDeactivate'=>'false',
                    'pimsAPIType'=>'MANAGEORG',
                    'pageObjectID'=>ac.id,
                    'mobileNumber'=>'0419111000',
                    'pimsCallType'=>'createOrg'
                    });
        
        
        Map<String, String> headerMap= new  Map<String, String>();
        headerMap.put('content-type','Application/json');
        List<String> param = new list<String>();
        object res;
        
        
        WrapperMSPIMSParams.WrapperPageParameters pageParams = ManagePIMSController.parsePageParams(params);
        res=IntegrationRecordHandlerUtil.calloutContinuation('CallbackPMS',pageParams,'Test',params,'',headerMap,'PimsMicroserviceManageOrg',param,'');
        IntegrationRecordHandlerUtil.getCorrelationId(); 
        System.assert(null != res);
    }
    @isTest static void CallPIMsToManageTest() {   
        
        Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS('200'));      
        
        Account ac = new Account(name ='Test123',Account_Status__c = 'New');
        insert ac; 
        
        insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');
        list<id> accids= new list<id>();
        accids.add(ac.id);
        test.startTest();
        AccountTriggerHelperPRM.CallPIMsToManage(accids,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
        test.stopTest();
        
        System.assert(null != ac);
    }
    @isTest static void CallPIMsToManageErrorTest() {   
        
        Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS('400'));      
        
        Account ac = new Account(name ='Test123',Account_Status__c = PRMConstants.PRM_Account_Status_Frozen);
        insert ac; 
        Account ac1 = new Account(name ='Test',Account_Status__c = 'Pending Activation');
        insert ac1; 
        insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');
        list<id> accids= new list<id>();
        accids.add(ac1.id);
        list<id> accids1= new list<id>();
        accids.add(ac.id);
        test.startTest();
        AccountTriggerHelperPRM.CallPIMsToManage(accids,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
        AccountTriggerHelperPRM.CallPIMsToManage(accids1,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
        
        test.stopTest();
        
        System.assert(null != ac);
    }
    
    @isTest static void CallPIMsTest() {   
         User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
        Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS('200'));    
        // Hawaii - Fetch Partner Contact record type
        Id contactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
        // Hawaii - Fetch Partner record type
        Id partnerAccRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); // fetch partner record type
        //Hawaii - create Partner Principle contact
        Contact principleCon = new Contact(LastName ='testPrinCon',Work_Phone_Number__c= '+61123456789',OTP_Mobile_Phone_Number__c='+61123456789',RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG');
        insert principleCon;
        Account ac = new Account(name ='Test123',Account_Status__c = 'New');
        insert ac; 
        //Hawaii - Modified existing account creation logic to create partner account
        Account ac1 = new Account(name ='Test',Account_Status__c = 'Pending Activation',PRM_Remaining_License__c=25,RecordtypeId = partnerAccRecTypeId,
            					Customer_Trading_Name__c = 'Test',
            					ABN__c = 'aaaa',
            					ACN__c = 'ccc',
            					State_Coverage__c = 'VIC',
            					Partner_Type__c = 'Distributor',
            					Website = 'www.vsygqwoci.com',
            					Phone = '0412354323',
            					Overall_Accreditation__c = 'Platinum',
            					Mobility_Accreditation__c = 'Platinum',
            					Cloud_Accreditation__c = 'Platinum',
            					Data_Security_Accreditation__c = 'Platinum',
            					Collaboration_Accreditation__c = 'Platinum',
                                PartnerPrincipalContact__c = principleCon.id
                                );
        insert ac1; 
        
        
        Set<String> customerUserTypes = new Set<String> {'PRM Community User - Australia'};
        Profile p2 = [select Id,name from Profile where Name in :customerUserTypes limit 1];
        Contact con1 = new Contact();
        con1.AccountId = ac1.Id;
        con1.LastName = 'TestLastName';
        con1.Email = 'test@test345345345345.com';
        con1.OTP_Mobile_Phone_Number__c = '+911234567891'; 
        con1.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); 
        con1.Onboarding_Status__c='Active';
        insert con1;
        
        User u2 = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', profileid =p2.id, country='United States',IsActive =true,
                           ContactId = con1.Id,
                           timezonesidkey='America/Los_Angeles', username='Cont987657w9@noemail.com');
        
        insert u2;
        
        
        insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');
        list<id> conids= new list<id>();
        conids.add(con1.id);
        
        test.startTest();
        AccountTriggerHelperPRM.CallPIMs(conids,'MANAGEUSER','updateUser','PimsMicroserviceManageUserBatch');
        test.stopTest();  
        
        System.assert(null != ac);
    }
    }
    
}