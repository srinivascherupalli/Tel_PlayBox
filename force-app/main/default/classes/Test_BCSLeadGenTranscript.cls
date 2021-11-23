/**
 *	Purpose			:	This class is used to validate functionality of BCSLeadGenTranscript.
 *
 *	Author			:	Padmesh Soni (Wipro)
 *
 *	Date			:	13/8/2020
 *
 *	Current Version	:	V_1.0
 *
 *	Revision Log	:	V_1.0 - DPA-204 - Created
 *
 *	Code Coverage	:	V_1.0 - 81%
 **/
@isTest(seeAllData=false)
private class Test_BCSLeadGenTranscript {
	
    @testSetup
    private static void createTestData() {
        
        Account account = TestUtil.createAccount('Test Account');
        insert account;
        
        Contact contact = TestUtil.createContact(account.Id, 'FirstName', 'LastName');
        insert contact;
    }
    
    private static testmethod void testFeedbackFromCustomer() {
        
        List<Contact> contacts = [Select Id From Contact];
        System.assert(contacts.size() > 0);
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript tx = new LiveChatTranscript(ChatKey = '123',liveChatVisitorId = visitor.id, ContactId = contacts[0].Id,
                                                      Chat_Start_URL__c = 'www.telstra.com.au/business-enterprise/products/cloud/');
        insert tx;
        
        Test.startTest();
        
        BCSLeadGenTranscript.TranscriptWrapper result = BCSLeadGenTranscript.isOrphanTranscript(tx.Id);
        
        System.assert(result != null);
        
        Test.stopTest();
    }
    
    @isTest
    static void test(){
        
        Account ac = new Account(Name = 'name1',Pref_Comm_Method__c = 'Phone',Phone = '0400111222',Migrated_Customer__c = true,CIDN__c='12344566',Customer_Status__c='ACTIVE',APTPS_Tier__c = 'Enterprise & Government');
        insert ac; 
        
        Contact co = new Contact (lastname='lastname',Accountid=ac.id, Email = 'testuser@test.com');
        insert co;
        
        List<Contact> contacts = [Select Id From Contact];
        System.assert(contacts.size() > 0);
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript tx = new LiveChatTranscript(ChatKey = '123',liveChatVisitorId = visitor.id, ContactId = contacts[0].Id,
                                                      Chat_Start_URL__c = 'www.telstra.com.au/business-enterprise/products/cloud/');
        insert tx;
        
        list<lead> leadLst = new list<lead>();
        lead t=new lead(lastname='lead1',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(),
                        phone='031245678',Lead_Source_Original__c='Events',CIDN__c='12344566',Contact_Id__c=Co.id);
        leadLst.add(t);
        
        Test.startTest();
        
        insert leadLst;
        
        System.assert(leadLst.size() > 0);
        
        BCSLeadGenTranscript.leadAssign(new List<List<String>>{new List<String>{leadLst[0].Id, tx.Id}});
        
        test.stopTest();
    }
}