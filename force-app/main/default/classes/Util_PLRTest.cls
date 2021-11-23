@IsTest
public class Util_PLRTest {
     
    @testsetup
    static void createTestData(){
        Id recTypeId = Schema.SObjectType.PII_Lookup__c.getRecordTypeInfosByName().get('Object Prefix').getRecordTypeId();
        List<PII_Lookup__c> pLookupList = new List<PII_Lookup__c>();
        PII_Lookup__c pLookup1 = new PII_Lookup__c();
        pLookup1.RecordTypeId = recTypeId;
        pLookup1.Name__c = 'Contact'; 
        pLookup1.Field_Name__c = 'Prefix';
        pLookup1.PII_Code__c = '003';
        pLookup1.Is_Active__c = true;
        pLookupList.add(pLookup1);
        
        PII_Lookup__c pLookup2 = new PII_Lookup__c();
        pLookup2.RecordTypeId = recTypeId;
        pLookup2.Name__c = Constants_PLR.ACCOUNT_LABEL; 
        pLookup2.Field_Name__c = 'Prefix';
        pLookup2.PII_Code__c = '001';
        pLookup2.Is_Active__c = true;
        pLookupList.add(pLookup2);
    
        insert pLookupList;
    }
    
    /*
    *   Test functionality that check whether a sObject and Field combination is valid or not
    */
    @isTest
    static void checkSobjectColumnTest() {
        Boolean valid = Util_PLR.checkSobjectColumn(Constants_PLR.ACCOUNT_LABEL, 'Name');
        System.assert(valid, 'Error: Existing sObject to Field relationship not detected');
        
        Boolean inValid = Util_PLR.checkSobjectColumn(Constants_PLR.ACCOUNT_LABEL, 'Name2');
        System.assert(!inValid, 'Error: Non-Existent sObject to Field relationship detected');
        
    }
    
    /*
    *   Test Batch Setting custom metadata object contains records
    */
    @isTest
    static void getBatchSettingTest() {
        Batch_setting__mdt bsMDT = Util_PLR.getBatchSetting();
        System.assert(bsMDT != null, 'Error: Batch Setting Custom Metadata is incorrectly configured');
        System.assert(bsMDT.Admin_email__c != null, 'Error: Batch Setting Custom Metadata do not contain an email address');
    }
 
    /*
    *   Test sending an email
    */
    /* EDGE-52698: moved this email send functionality to process builder.
    @isTest
    static void sendEmailTest() {
        String emailBody = '';
        Integer cnt1 = Limits.getEmailInvocations();
        Util_PLR.sendEmail(emailBody);
        Integer cnt2 = Limits.getEmailInvocations();
        System.assert(cnt2 > cnt1, 'Error: In sending email');
        System.debug('Cnt1: ' + cnt1 + ', Cnt2: ' + cnt2);
    }*/
    
    /*
    *   Test logging batch class failures
    */
    @isTest
    static void logErrorTest() {
        PLRAudit_log__c plrLog = new PLRAudit_log__c();
        plrLog.Status__c = UTIL_PLR.AUDIT_LOG_STATUS_STARTED;
        plrLog.Batch_Name__c = 'testBatch';
        insert plrLog;
        
        CustomException ce = new CustomException();
        Util_PLR.logerror(ce, plrLog);
        
        PLRAudit_log__c updatedPLRLog = [SELECT Status__c  FROM PLRAudit_log__c WHERE Id = :plrLog.Id];
        System.assert(updatedPLRLog != null, 'Error: Not able to access the PLR Audit Log record');
        System.assertEquals(updatedPLRLog.Status__c, UTIL_PLR.AUDIT_LOG_STATUS_FAILED, 'Error: Incorrect PLR Audit Log record status');
    }    

    /*
    *   Test logging batch class success
    */
    @isTest
    static void logSuccessTest() {
        PLRAudit_log__c plrLog = new PLRAudit_log__c();
        plrLog.Status__c = UTIL_PLR.AUDIT_LOG_STATUS_STARTED;
        plrLog.Batch_Name__c = 'testBatch';
        insert plrLog;
        
        Util_PLR.logSuccess(plrLog, 2);
        
        PLRAudit_log__c updatedPLRLog = [SELECT Status__c  FROM PLRAudit_log__c WHERE Id = :plrLog.Id];
        System.assert(updatedPLRLog != null, 'Error: Not able to access the PLR Audit Log record');
        System.assertEquals(updatedPLRLog.Status__c, UTIL_PLR.AUDIT_LOG_STATUS_SUCCESS, 'Error: Incorrect PLR Audit Log record status');
    }
        
    /*
    *   Test log batch class start in PLR Audit Log
    */
    @isTest
    static void logBatchStartTest() {
        PLRAudit_log__c plrAuditLogRec = Util_PLR.logbatchstart('testBatch');
        System.assert(plrAuditLogRec != null, 'Error: PLR Audit Log record not generated');
        System.assertEquals(plrAuditLogRec.Status__c, UTIL_PLR.AUDIT_LOG_STATUS_STARTED, 'Error: Incorrect PLR Audit Log record status');
    }
    
    /*
    *   Test Object Key Ids custom metadata contains records
    */
    @isTest
    static void getObjectkeyIdsTest() {
        List<string> ObjectkeyIds = Util_PLR.getObjectkeyIds(Constants_PLR.ACCOUNT_LABEL);
        System.assert(ObjectkeyIds != null && ObjectkeyIds.size() == 6, 'Error: Object Key Ids Custom Metadata is incorrectly configured');
        
        System.assertEquals(ObjectkeyIds.get(0), 'Id', 'Error: Batch Setting Custom Metadata do not contain Key Value Id1');
    }
    
    /*
    *   Test retrieving of a map of user id and User records
    */
    @isTest
    static void getUserProfileMapTest() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User plrUser = new User(Alias = 'TestPLR', Email='testplr@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='PrivacyUser', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_AU', ProfileId = adminProfile.Id, CommunityNickname = 'TUCM',
        TimeZoneSidKey='Australia/Sydney', UserName='testPrivacy18@testorg.com');
        
        insert plrUser;    
        
        Map<Id, User> userMap = Util_PLR.getuserProfilemap();
        Set<Id> userIds = userMap.keySet(); 
        System.assert(userIds.contains(plrUser.Id), 'Error: Not able to retrieve User record');
    }
    
    /*
    *   Test retrieving object prefix stored in PII_lookup sobject
    */
    @isTest(SeeAllData=false)
    static void getObjPrefixMapTest() {
        List<PII_Lookup__c> piiLookupList = new List<PII_Lookup__c>([SELECT PII_Code__c, Name__c FROM PII_Lookup__c WHERE Field_Name__c = 'Prefix']);
        System.debug('PiiLookupList: ' + piiLookupList);
        System.assert(piiLookupList != null && piiLookupList.size() == 2, 'Error: Incorrect number of PII Lookup records retrieving');
        
        for(PII_Lookup__c pLookupRec : piiLookupList) {
            System.assert(pLookupRec.PII_Code__c == '001' || pLookupRec.PII_Code__c == '003', 'Error: Incorrect PII Code configured');
        }
    }
    
    /*
    *   Test converting string date into DateTime type and returning GMt dateTime
    */
    @isTest
    static void getGmtTimeTest() {
        String unconvertedDateTime = '2017-17-14T00:01:37.365Z';    
        DateTime dt = Util_PLR.getGmtTime(unconvertedDateTime);
        System.assert(dt != null, 'Error: Not able to convert string into correct dateTime record');
        System.assertEquals(dt.day(), 14, 'Error: Incorrect date component in the dateTime record');
        System.assertEquals(dt.minute(), 1, 'Error: Incorrect minute component in the dateTime record');
    }
    
    /*
    *   Test if FLS enablement checking for a perticular field is done correctly
    *   True if field do not provide permission to modify FLS  
    */
    @isTest
    static void checkFieldFlsTest() {
        Boolean noPermission = Util_PLR.checkFieldFls(Constants_PLR.ACCOUNT_LABEL, 'Name');
        System.assert(noPermission, 'Error: FLS is incorrectly specified for Account.Name');
        
        noPermission = Util_PLR.checkFieldFls(Constants_PLR.ACCOUNT_LABEL, 'Phone');
        System.assert(!noPermission, 'Error: FLS is incorrectly specified for Account.Phone');      
    }
    
    /*
    * Test the method implemented to retrieve MetadataService.MetadataPort class instance 
    */
    @isTest
    static void getMetadataServiceTest() {
        System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        MetadataService.MetadataPort service = Util_PLR.getMetadataService('sessionId');
        System.assert(service != null, 'Error: Not able to retrive MetadataPort instance');
    }
    
    /*
    *   Test getting peofile metadata from metadata api
    */
    @isTest
    static void getProfileMetadataTest() {
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        List<String> profileList = new List<String> {'System Admistrator'};
        List<MetadataService.Profile> profileMetadataList = Util_PLR.getprofilemetadata('sessionId', profileList);
        System.assert(profileMetadataList != null, 'Error: Not able to access profile metadata');
        MetadataService.Profile adminProfile=new MetadataService.Profile();
        String adminProfileName = 'admin';
        
        for(MetadataService.Profile prf : profileMetadataList) {
            if('admin'.equals(prf.fullName)) {
                adminProfile = prf;
            }
        }        
        System.assert(adminProfile != null, 'Error: Not able to access admin profile metadata');
        Test.stopTest();
    }

    /*
    *   Test getting layout metadata from metadata api
    */
    @isTest
    static void getLayoutMetadataTest() {
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        List<String> layoutnames = new List<String> {'Account-layout'};
        List<MetadataService.Layout> layoutMetadataList = Util_PLR.getlayoutmetadata('sessionId', layoutnames);
        System.assert(layoutMetadataList != null, 'Error: Not able to access layout metadata');
        MetadataService.Layout accountLayout=new MetadataService.Layout();
        
        for(MetadataService.Layout layoutMeta : layoutMetadataList) {
            if('Account-Account Layout'.equals(layoutMeta.fullName)) {
                accountLayout = layoutMeta;
            }
        }        
        System.assert(accountLayout != null, 'Error: Not able to access admin profile metadata');
        Test.stopTest();
    }
    
    /*
    *   Test the getSessionId callout
    */
    @isTest
    static void getSessionIdTest() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Util_PLRMock());
            String sessionId = Util_PLR.getSessionId();
            System.assertEquals(sessionId, 'sfdcSessionId', 'Error: Unexpected SessionId value');
        Test.stopTest();
    }    
}