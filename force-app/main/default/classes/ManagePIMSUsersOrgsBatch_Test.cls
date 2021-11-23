@IsTest
public class ManagePIMSUsersOrgsBatch_Test {
    
    static testMethod void testMethod1(){
        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
       
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = partnerAccRecID;        
        insert acc;
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.RecordTypeId = partnerAccRecID;        
        insert acc1;
        Account acc2 = new Account();
        acc2.Name = 'Test Account';
        acc2.RecordTypeId = partnerAccRecID;        
        insert acc2;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        Id manageusersbatchjobid = Database.executeBatch(new ManagePIMSUsersOrgsBatch('SELECT Id,Account_Status__c,RecordType.Name FROM Account WHERE (Account_Status__c = ' + '\'New\' OR Account_Status__c = ' + '\'Pending Activation\' OR Account_Status__c = ' + '\'Inactive\') AND RecordType.Name=' + '\'Partner\' Limit 10','Account'));
 
        Test.stopTest();
                system.assertEquals('Test Account', acc2.Name);

    }
  
    static testMethod void testMethod2(){
        Id ContactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = partnerAccRecID;
        insert acc;
        
        Contact con = new Contact();
                con.AccountId = acc.Id;
                con.LastName = 'LASTNAME1';
                con.Email = 'Testsdjfksd@partnerg.com';
                con.OTP_Mobile_Phone_Number__c = '+612345678';
                con.RecordTypeId=ContactRecTypeId;
        
        insert con;
        
                Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());

        Test.startTest();
        Id manageusersbatchjobid1 = Database.executeBatch(new ManagePIMSUsersOrgsBatch('SELECT Id,Bulk_Load_Status__c,AccountId,RecordType.Name,Account.PIMS_Sync_Status__c FROM Contact WHERE Bulk_Load_Status__c = ' + '\'PIMSuserCreate\' AND Account.PIMS_Sync_Status__c = ' + '\'Not Synced\' AND Recordtype.Name = ' + '\'Partner Contact\' Limit 10','Contact'));
        Id manageusersbatchjobid2 = Database.executeBatch(new ManageUsersAccountsfromPIMS_Batch('SELECT Id,Bulk_Load_Status__c,AccountId,RecordType.Name,Account.PIMS_Sync_Status__c FROM Contact WHERE Bulk_Load_Status__c = ' + '\'PIMSuserCreate\' AND Account.PIMS_Sync_Status__c = ' + '\'Not Synced\' AND Recordtype.Name = ' + '\'Partner Contact\' Limit 10'));

        test.stopTest(); 
        system.assertEquals('Test Account', acc.Name);
        
    }

}