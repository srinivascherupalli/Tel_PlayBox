@IsTest
public class ProfileLayoutAssigmentBatchTest {
    
    @testsetup
    static void createTestData(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
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
        pLookup2.Name__c = 'Account'; 
        pLookup2.Field_Name__c = 'Prefix';
        pLookup2.PII_Code__c = '001';
        pLookup2.Is_Active__c = true;
        pLookupList.add(pLookup2);
        
        insert pLookupList;
    }
    
    /*
*   Test inserting records into the Profile_Layout__c object through a batch process
*/
    @isTest
    static void ProfileLayoutAssigmentTest() {
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new Util_PLRMock());
        
        Test.startTest();            
        profileLayoutassigmentBatch profileLayoutBatch = new profileLayoutassigmentBatch();
        Database.executebatch(profileLayoutBatch, 2);            
        Test.stopTest();
        
        List<Profile_Layout__c> profileLayoutList = new List<Profile_Layout__c>([SELECT Id, Profile__c FROM Profile_Layout__c]);
        System.assert(profileLayoutList.size() == 1, 'Error: Not able to retrieve Profile Layout records');
        Profile_Layout__c pl = profileLayoutList.get(0);
        System.assertEquals(pl.Profile__c, 'admin', 'Error: Incorrect profile record upserted');
        
    }
    @isTest
    static void ContactRecrotypeTest()
    {
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new Util_PLRMock());
        
        Account testAcc = new Account(Name='testAcc');
        Insert testAcc;
        Account acctest = [SELECT Id FROM Account Where Name='testAcc'];
        Contact con1 = new Contact(LastName='testCon',AccountId=acctest.Id);
        Insert con1;
        
        Test.startTest();            
        profileLayoutassigmentBatch profileLayoutBatch = new profileLayoutassigmentBatch();
        Database.executebatch(profileLayoutBatch, 2);            
        Test.stopTest();
        
        List<Profile_Layout__c> profileLayoutList = new List<Profile_Layout__c>([SELECT Id FROM Profile_Layout__c where RecordType__c='NA']);
        System.assertEquals(testAcc!=null,true, 'Not able to retrieve contact records with recordtype value NA');
        
    }
}