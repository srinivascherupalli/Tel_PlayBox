@isTest
public class TestAccountContactRelationshipCascade {
    @testSetup static void setup() {
        List<sobject> ls=Test.loadData(Account.sObjectType, 'TCM_ACC_TST');
        List<sobject> lc=Test.loadData(Contact.sObjectType, 'TCM_TEST_CONTACT');
    }
    static testMethod void getAllAccountContactRelationRecordsTestmethod() {
        Test.startTest();
        AccountContactRelation acr=[select id,contactId,AccountId from AccountContactRelation Limit 1];
        system.assertNotEquals(null,AccountContactRelationshipCascadeOptOut.getAllAccountContactRelationRecords(acr.Id,'Account.Name','ASC'));
        system.assertNotEquals(null,AccountContactRelationshipCascadeOptOut.getAllAccountContactRelationRecords(acr.Id,'Relationship_End_Date__c','DESC'));
        system.assertNotEquals(null,AccountContactRelationshipCascadeOptOut.getAllAccountContactRelationRecords(acr.Id,null,null));
        Test.stopTest();
    }
    static testMethod void saveRecordsTestmethod() {
        Test.startTest();
        AccountContactRelation acr=[select id from AccountContactRelation Limit 1];
        List<Id> idList=new  List<Id>{acr.Id};
        AccountContactRelationshipCascadeOptOut.saveAcrPreferences(acr.Id,idList); //EDGE - 30617
        system.assertNotEquals(null,acr);
        Test.stopTest();
    }
}