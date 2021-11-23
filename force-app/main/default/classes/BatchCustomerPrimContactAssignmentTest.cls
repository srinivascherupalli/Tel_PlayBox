/*
    AUTHOR : Abhishek Rao
    DESCRIPTION : EDGE-93284 :: <Technical story> Batch script to update Customer Primary Contact for existing and migrated Agreement records
*/
@IsTest
public class BatchCustomerPrimContactAssignmentTest {
    
    @testSetup static void setup() {
        Id profile = [select id from profile where name='Sales - Enterprise'].id;
        List<User> listUserRecord = new List<User>();
        User userRecord1 = new User(alias = 'conf3', email='test@noemail.com',
                                    emailencodingkey='UTF-8', lastname='conf3', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = profile, country='United States',IsActive =true,
                                    timezonesidkey='America/Los_Angeles', username='test@calms.com',phone='+121231231234');
        User userRecord2 = new User(alias = 'conf3', email='test@calmsNoEmail.com',
                                    emailencodingkey='UTF-8', lastname='conf3', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = profile, country='United States',IsActive =true,
                                    timezonesidkey='America/Los_Angeles', username='test@calmsNoEmail.com',phone='+121231231234');
        
        listUserRecord.add(userRecord1);
        listUserRecord.add(userRecord2);
        insert listUserRecord;
    }
    
    static testMethod void createRelatedRecordForAgmt() {
        List<User> userRecordList = [select id  from User where username='test@calms.com'];
        List<User> userRecordList1 = [select id from User where username='test@calmsNoEmail.com'];
        
        Test.startTest();
        Account acc = new Account();
        acc.name = 'TestAccount1';
        acc.CIDN__c = '9878467453';
        acc.Customer_ID__c = '2021945565';
        acc.Customer_status__c = 'ACTIVE';
        acc.Portfolio_Code__c = 'XYZ';
        acc.TCM_MasterID__c ='10000257090';
        acc.OwnerId = userRecordList[0].Id;
        insert acc;  
        
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acc.id);
        agmt.APTPS_Sales_Account_Executive__c = userRecordList[0].Id;
        agmt.APTPS_Customer_Primary_Contact__c = null;
        update agmt;
        
        BatchCustomerPrimaryContactAssignment custPrimContactBatch = New BatchCustomerPrimaryContactAssignment();
        database.executeBatch(custPrimContactBatch);
        list<Apttus__APTS_Agreement__c> apttusAgreement = [SELECT ID, Name FROM Apttus__APTS_Agreement__c];
        System.assert(apttusAgreement != null);
        System.assert(apttusAgreement.size() > 0);
        Test.stopTest();
    }
}