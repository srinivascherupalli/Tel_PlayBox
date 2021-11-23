/**
 *	Purpose			:	This class is used to validate functionality of SSMLiveChatFeedbackController.
 *
 *	Author			:	Padmesh Soni (Wipro)
 *
 *	Date			:	8/9/2019
 *
 *	Current Version	:	V_1.0
 *
 *	Revision Log	:	V_1.0 - DPA-42 - Created
 *
 *	Code Coverage	:	V_1.0 - 81%
 **/
@isTest(seeAllData=false)
private class SSMLiveChatFeedbackControllerTest {
	
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

        LiveChatTranscript tx = new LiveChatTranscript(ChatKey = '123',liveChatVisitorId = visitor.id, ContactId = contacts[0].Id);
        insert tx;
        
        Test.startTest();
        
        SSMLiveChatFeedbackController controller = new SSMLiveChatFeedbackController();
        
        SSMLiveChatFeedbackController.finishFeedback('Yes', 'Thanks for assistance', '123');
        
        List<Live_Chat_Feedback__c> feedback = [Select Id From Live_Chat_Feedback__c];
        
        System.assert(feedback.size() > 0);
        
        Test.stopTest();
    }
    
    private static testmethod void testFeedbackFromCustomerNegative() {
        
        List<Contact> contacts = [Select Id From Contact];
        System.assert(contacts.size() > 0);
        
        Test.startTest();
        
        SSMLiveChatFeedbackController controller = new SSMLiveChatFeedbackController();
        
        SSMLiveChatFeedbackController.finishFeedback('Yes', 'Thanks for assistance', null);
        
        List<Live_Chat_Feedback__c> feedback = [Select Id From Live_Chat_Feedback__c];
        
        System.assert(feedback.size() == 0);
        
        Test.stopTest();
    }
    private static testmethod void testFeedbackFromCustomerNegative1() {
        
        List<Contact> contacts = [Select Id From Contact];
        System.assert(contacts.size() > 0);
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript tx = new LiveChatTranscript(ChatKey = '123',liveChatVisitorId = visitor.id, ContactId = contacts[0].Id);
        insert tx;
        
        Test.startTest();
        
        SSMLiveChatFeedbackController controller = new SSMLiveChatFeedbackController();
        
        SSMLiveChatFeedbackController.finishFeedback('15', 'Thanks for assistance', '123');
        
        Test.stopTest();
    }
}