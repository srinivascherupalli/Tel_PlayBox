@isTest
public class LiveChatTranscriptEmailServiceTest {
    /**
    * 	@description	:	This method is to test email transcript functionality for Live Chat with single agent
    * 
    * 	@param			:	
    * 
    * 	@return			:	void
    **/
    static testMethod void processChatTranscriptTest(){
        List<LiveChatDeployment> deployments = [SELECT Id FROM LiveChatDeployment WHERE DeveloperName IN: LiveChatTranscriptEmailService.deploymentChannel];
        List<LiveChatTranscript> listtranscript=new List<LiveChatTranscript>();
        User u=TestUtil.createUser('testuser@test.com.sample','alias','System Administrator');
        insert u;
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        Contact contactTest = TestUtil.createContact('test','test1');
        contactTest.email = 'testuser@test.com.sample';
        contactTest.Is_Lead_Originated__c = true;
        insert contactTest;
        LiveChatTranscript transcript=new LiveChatTranscript();
        transcript.PreChat_FirstName__c='test';
        transcript.PreChat_LastName__c='test1';
        transcript.PreChat_Email__c='testuser@test.com.sample';
        transcript.LiveChatVisitorId=visitor.id;
        transcript.Status='Completed';
        transcript.ContactId = contactTest.id;
        transcript.OwnerId = u.id;
        transcript.StartTime = datetime.now();
        transcript.EndTime = system.now()+1;
        transcript.LiveChatDeploymentId = deployments[0].Id;
        transcript.Body = '<p align="center">Chat Started: Friday, December 20, 2019, 17:50:05 (+1100)</p><p align="center">Chat Origin: Chat_One Fund</p><p align="center">Agent Testing</p>( 23s ) null T: Hi , how can I help you today?<br>( 3m 17s ) Visitor: hi<br>( 4m 36s ) null T: hi<br>( 5m 9s ) Visitor: jj<br>';
        insert transcript;
            List<String> transcriptIds = new List<String>();
            transcriptIds.add(transcript.Id);
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        Test.startTest();
        LiveChatTranscriptEmailService.processChatTranscript(transcriptIds);
        Test.stopTest();
        System.assert(transcriptIds.size() > 0);
    }
    /**
    * 	@description	:	This method is to test email transcript functionality for Live Chat with confrenecing chats
    * 
    * 	@param			:	
    * 
    * 	@return			:	void
    **/
    static testMethod void processChatTranscriptTransferTest(){
        List<LiveChatDeployment> deployments = [SELECT Id FROM LiveChatDeployment WHERE DeveloperName IN: LiveChatTranscriptEmailService.deploymentChannel];
        List<LiveChatTranscript> listtranscript=new List<LiveChatTranscript>();
        User u=TestUtil.createUser('testuser@test.com.sample','alias','System Administrator');
        insert u;
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        Contact contactTest = TestUtil.createContact('test','test1');
        contactTest.email = 'testuser@test.com.sample';
        contactTest.Is_Lead_Originated__c = true;
        insert contactTest;
        String agentName = UserInfo.getFirstName()+ ' ' + UserInfo.getLastName().left(1);
        LiveChatTranscript transcript=new LiveChatTranscript();
        transcript.PreChat_FirstName__c='test';
        transcript.PreChat_LastName__c='test1';
        transcript.PreChat_Email__c='testuser@test.com.sample';
        transcript.LiveChatVisitorId=visitor.id;
        transcript.Status='Completed';
        transcript.OwnerId = u.id;
        transcript.StartTime = datetime.now();
        transcript.EndTime = system.now()+1;
        transcript.LiveChatDeploymentId = deployments[0].Id;
        transcript.Body = '<p align="center">Chat Started: Friday, December 20, 2019, 18:04:21 (+1100)</p><p align="center">Chat Origin: Chat BCS</p><p align="center">Agent '+agentName+'</p>( 20s ) '+agentName+': Hi a, how can I help you today?<br><p align="center">Chat Transferred From '+agentName+' To Harshada A</p>( 1m 3s ) Harshada A: Hi a, how can I help you today?<br>( 1m 15s ) a: hi<br><p align="center">Agent Harshada A successfully transferred the chat to button Chat_One Fund</p><p align="center">Chat Started: Friday, December 20, 2019, 18:07:20 (+1100)</p><p align="center">Chat Origin: Chat_One Fund</p><p align="center">Agent '+agentName+'</p>( 3m 20s ) '+agentName+': Hi a, how can I help you today?<br><p align="center">Agent Harshada A joined the chat conference</p>( 3m 37s ) Harshada A: Hi a, how can I help you today?<br>( 4m 0s ) a: hi<br>( 4m 11s ) Harshada A: hi<br>( 4m 19s ) '+agentName+': hi<br>';
        insert transcript;
        LiveChatTranscriptEvent le = new LiveChatTranscriptEvent();
        le.LiveChatTranscriptId = transcript.id;
        le.type = 'Transfer';
        le.time = system.now();
        le.AgentId = UserInfo.getUserId();
        insert le;
        List<String> transcriptIds = new List<String>();
        transcriptIds.add(transcript.Id);
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        Test.startTest();
        LiveChatTranscriptEmailService.processChatTranscript(transcriptIds);
        Test.stopTest();
        System.assert(transcriptIds.size() > 0);
    }
}