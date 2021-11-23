@IsTest
public class DescribePageLayoutBatchTest {
    
    @testsetup
    static void createTestData(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Id recTypeId = Schema.SObjectType.PII_Lookup__c.getRecordTypeInfosByName().get('Object Prefix').getRecordTypeId();
        
        List<Profile_Layout__c> profileLayoutList = new List<Profile_Layout__c>();
        Profile_Layout__c pl1 = new Profile_Layout__c();
        pl1.Layout__c = 'Account-Account Layout';
        pl1.Profile__c = 'System Administrator';
        pl1.Profile_Key__c = 'Account-Admin-';
        profileLayoutList.add(pl1);
        
        Profile_Layout__c pl2 = new Profile_Layout__c();
        pl2.Layout__c = 'Contact-Contact Layout';
        pl2.Profile__c = 'System Administrator';
        pl2.Profile_Key__c = 'Contact-Admin-';
        profileLayoutList.add(pl2);
    
        insert profileLayoutList;
    }
    
    /*
    *   Test inserting records into the Layout_detail__c object through a batch process
    */
    @isTest
    static void describePageLayoutTest() {
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new Util_PLRMock());
        
        Test.startTest();            
            describePageLayoutBatch describePLBatch = new describePageLayoutBatch('sessionId');
            Database.executebatch(describePLBatch, 5);            
        Test.stopTest();
        
        List<Layout_detail__c> layoutDetailList = new List<Layout_detail__c>([SELECT Id, Layout_name__c FROM Layout_detail__c]);
        System.assert(layoutDetailList.size() == 2, 'Error: Not able to retrieve Layout Detail records');
    }
}