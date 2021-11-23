@isTest
public class PlatformEventPublisherTests {
	@testSetup
    static void testDataSetup() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
    	Account testAccount = new Account();
     	testAccount.name = 'TestClassEvent';
     	testAccount.CIDN__c = 'ASDF1234';
     	testAccount.RecordTypeId = accRecordTypeId;
     	testAccount.Migrated_Customer__c = true;
     	testAccount.Customer_status__c = 'ACTIVE';
     	insert testAccount;
            
   	 	Opportunity testOpp=new Opportunity();
     	testOpp.AccountId=testAccount.Id;
     	testOpp.Name='TestOppCreateForEventCreate';
     	testOpp.Proposal_Required_Date__c=System.today()+2;
     	testOpp.CloseDate=System.today()+10;
     	testOpp.StageName=System.label.Opp_Stage_Develop;
     	testOpp.Description__c='Test';
     	testOpp.Product_Domain__c='MOBILES';
     	testOpp.Shared_Opportunity__c=True;
     	insert testOpp;
        
        Attachment testAttachment = new Attachment();
        testAttachment.ParentId = testOpp.Id;
        testAttachment.Name = 'Test Attachment';
        testAttachment.Body = Blob.valueOf('Unit Test Attachment Body');
        insert testAttachment;
    }
    
    @isTest 
    static void testCreateProposalPlatformEvent() {
        Attachment testAttachment = [SELECT Id, ParentId, Name 
                                     FROM Attachment 
                                     WHERE Name = 'Test Attachment'];
        Opportunity testOpp = [SELECT ID FROM Opportunity WHERE Name = 'TestOppCreateForEventCreate'];
        Test.startTest();
        	DocumentGenerationNotification__e testDocGeneration = 
                platformEventPublisher.createProposalPlatformEvent(testOpp, testAttachment);
        Test.stopTest();
        System.assertNotEquals(testDocGeneration, null,'Object should not be null');
   }
    
    
}