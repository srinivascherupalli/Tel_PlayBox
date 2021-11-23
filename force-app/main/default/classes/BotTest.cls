@isTest
public without sharing class BotTest {

    static testMethod void testServiceNumberBotController() {
        Bot_Command__c bc = new Bot_Command__c(Sample_Utterance__c='service no', apex_class__c='HandlerFindService', pattern__c='(?i).*service (.*)');
        insert bc;
        WC_CSSA_ServicesFunction_VW__x mockedRequest = new WC_CSSA_ServicesFunction_VW__x(
                                                            Billing_Account_Info__c ='Flexcab',
                                                            SingleBilled__c = 'N',
                                                            Silent__c = 'N',
                                                            Plan1__c = 'Plan',
                                                            Address__c = 'Address',
                                                            CIDN__C = '0102030405',
                                                            DataPlan__c = '',
                                                            VisibleSvcDescription__c = '0357224435');


        ExternalSearchServiceRequest.mockedRequests.add(mockedRequest);
        
        BotResponse response = BotController.submit('service 0357224435', null);
        System.assertEquals(1, response.messages[0].records.size(), 'Exactly 1 record should be returned');

        Map<String, String> session = response.session;
        response = BotController.submit('Something', session);
        System.assertEquals('I don\'t know how to answer that', response.messages[0].messageText, 'No records should be returned');
    }

    static testMethod void testServiceEmailSearchBotController() {
        Bot_Command__c bc = new Bot_Command__c(Sample_Utterance__c='service no', apex_class__c='HandlerFindService', pattern__c='(?i).*service (.*)');
        insert bc;
        Test.startTest();
        WC_CSSA_ServicesFunction_VW__x mockedRequest = new WC_CSSA_ServicesFunction_VW__x(
                                                            Billing_Account_Info__c ='Flexcab',
                                                            SingleBilled__c = 'N',
                                                            Silent__c = 'N',
                                                            Plan1__c = 'Plan',
                                                            Address__c = 'Address',
                                                            CIDN__C = '0102030405',
                                                            DataPlan__c = '',
                                                            VisibleSvcDescription__c = 'abc@abc.com');


        ExternalSearchServiceRequest.mockedRequests.add(mockedRequest);
        
        BotResponse response = BotController.submit('service abc@abc.com', null);
        System.assertEquals(1, response.messages[0].records.size(), 'Exactly 1 record should be returned');

        Map<String, String> session = response.session;
        response = BotController.submit('Something', session);
        Test.stopTest();
        System.assertEquals('I don\'t know how to answer that', response.messages[0].messageText, 'No records should be returned');
    }    
    
    static testMethod void testFindService() {
		Test.startTest();
    	WC_CSSA_ServicesFunction_VW__x mockedRequest = new WC_CSSA_ServicesFunction_VW__x(
        Billing_Account_Info__c ='Flexcab',
        SingleBilled__c = 'N',
        Silent__c = 'N',
        Plan1__c = 'Plan',
        Address__c = 'Address',
        CIDN__C = '0102030405',
        DataPlan__c = '',
        VisibleSvcDescription__c = '0357224435');

    	ExternalSearchServiceRequest.mockedRequests.add(mockedRequest);
        
        BotHandler handler = new HandlerFindService();
        BotResponse response = handler.handle('', new String[]{mockedRequest.VisibleSvcDescription__c}, null);
        
        Test.stopTest();

        System.assertEquals(1, response.messages[0].records.size(), 'Exactly 1 record should be returned');
    }
    
 	static testMethod void testFindServiceByEmail() {
		Test.startTest();
    	WC_CSSA_ServicesFunction_VW__x mockedRequest = new WC_CSSA_ServicesFunction_VW__x(
        Billing_Account_Info__c ='Flexcab',
        SingleBilled__c = 'N',
        Silent__c = 'N',
        Plan1__c = 'Plan',
        Address__c = 'Address',
        CIDN__C = '0102030405',
        DataPlan__c = '',
        VisibleSvcDescription__c = 'aura@bigpond.com');

    	ExternalSearchServiceRequest.mockedRequests.add(mockedRequest);
        
        BotHandler handler = new HandlerFindService();
        BotResponse response = handler.handle('', new String[]{mockedRequest.VisibleSvcDescription__c}, null);
        
        Test.stopTest();

        System.assertEquals(1, response.messages[0].records.size(), 'Exactly 1 record should be returned');
    }
    
    
	static testMethod void testHelp() {
		Bot_Command__c bc = new Bot_Command__c(Sample_Utterance__c='Hello', apex_class__c='HelloHandler', pattern__c='Hello');
        insert bc;
        BotHandler handler = new HandlerHelp();
        BotResponse response = handler.handle('', null, null);
        System.assert(response.messages[0].items.size() == 1);
    }


    /*
     The method does not do any actual unit testing and is only used for code coverage purposes.
     Since we are not using the entire functionality
     of Bot framework at this point, the test method is created to increase code coverage.
     In future when the Bot framework is used for other use cases, this test method may or may not be needed
     */
    static testMethod void testHelpers(){

        List<BotMessage> botmessages = new List<BotMessage>();

        BotItem bItem1 = new BotItem('someItem');
        BotItem bItem2 = new BotItem('anotherItem', 'somelinkURL');

        BotField bField1 = new BotField('somename', 'somefield', 'someURL');
        BotField bField2 = new BotField('somename', 'somefield');

        BotMessageButton msgButton = new BotMessageButton('label', 'value');

        BotMessage botmsg1 = new BotMessage('author', 'some test message', new List<BotMessageButton> {msgButton});
        BotMessage botmsg2 = new BotMessage('author', 'some test message', 'http://sampleurl');
        botmessages.add(botmsg1);
        botmessages.add(botmsg2);
        
        BotResponse response1 = new BotResponse();
        //BotResponse response2 = new BotResponse(botmessages);
        
        BotResponse response3 = new BotResponse(botmsg1, new Map<String, String> {'somestr' => 'anotherstr'});
        BotResponse response4 = new BotResponse(botmessages, new Map<String, String> {'somestr' => 'anotherstr'});
		System.assert(botmessages.size() > 1);
    }
    

}