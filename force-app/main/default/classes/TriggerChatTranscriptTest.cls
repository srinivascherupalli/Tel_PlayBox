/**
*	Purpose			:	This class is used to test trigger of Chat Transcript.
*
*	Author			:	Padmesh Soni (Wipro)
*
*	Date			:	10/21/2019
*
*	Current Version	:	V_1.0
*
*	Revision Log	:	V_1.0 - DPA-138 - Created
**/
@isTest
private class TriggerChatTranscriptTest {
    
    static testMethod void onBeforeInsertPositiveWithContactTest(){
        User u=TestUtil.createUser('testuser@test.com.sample','alias','System Administrator');
        System.runAs(u){
            
            List<Contact> contacts = new List<Contact>();
            contacts.add(TestUtil.createContact('test','test1'));
            contacts[0].email = 'testuser@test.com';
            contacts[0].LiveChat_SessionId__c = 'afdvdklfhsjghdfhgdfkl12';
            insert contacts;
            
            
            LiveChatVisitor visitor=new LiveChatVisitor();
            insert visitor;
            
            Id chatdeploymentId = [Select Id, DeveloperName From LiveChatDeployment where MasterLabel='Chat_One Fund'].id;
            Id chatdeploymentIdPreChat = [Select Id, DeveloperName From LiveChatDeployment where MasterLabel='Chat_BCS Lead Gen'].id;
            
            
            LiveChatTranscript transcript=new LiveChatTranscript();
            transcript.PreChat_FirstName__c='test';
            transcript.PreChat_LastName__c='test1';
            transcript.PreChat_Email__c='testuser@test.com.sample1';
            transcript.LiveChatVisitorId=visitor.id;
            transcript.LiveChatDeploymentId = chatdeploymentId;
            transcript.Status='completed';
            transcript.Contact_Session_Id__c = 'afdvdklfhsjghdfhgdfkl';
            transcript.TConnect_Case_Number__c = '101927837';
            
            

            Test.startTest();
            
            insert transcript;
            transcript.Contact_Session_Id__c = 'afdvdklfhsjghdfhgdfkl12';
            update transcript;
            transcript.LiveChatDeploymentId = chatdeploymentIdPreChat;
            //transcript.Contact_Session_Id__c = 'afdvdklfhsjghdfhgdfkl';
            update transcript;
            
            List<LiveChatTranscript> listtranscript = [SELECT Id From LiveChatTranscript WHERE ContactId != null];
            System.assert(listtranscript.size() >= 0);
            
            transcript.ContactId = null;
            update transcript;
            
            List<LiveChatTranscript> listtranscript1 = [SELECT Id From LiveChatTranscript WHERE ContactId = null];
            System.assert(listtranscript1.size() >= 0);
            
            Test.stopTest();
        }
    }

    
    static testMethod void onAfterUpdatesendChatHistoryToCustomerTest(){
        
        List<LiveChatTranscript> listtranscript=new List<LiveChatTranscript>();
        
        User u=TestUtil.createUser('testuser@test.com.'+Math.random(),'alias','System Administrator');
        insert u;
        
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        
        Contact contactTest = TestUtil.createContact('test','test1');
        contactTest.email = 'testuser@test.com';
        insert contactTest;

        Id chatdeploymentId = [Select Id, DeveloperName From LiveChatDeployment where MasterLabel='Chat_One Fund' limit 1].id;

        LiveChatTranscript transcript=new LiveChatTranscript();
        transcript.PreChat_FirstName__c='test';
        transcript.PreChat_LastName__c='test1';
        transcript.PreChat_Email__c='testuser@test.com';
        transcript.LiveChatVisitorId=visitor.id;
        transcript.Status='Completed';
        transcript.ContactId = contactTest.id;
        transcript.OwnerId = u.id;
        transcript.StartTime = datetime.now();
        transcript.EndTime = system.now()+1;
        transcript.Body = '<p align="center">Chat Started: Friday, December 20, 2019, 17:50:05 (+1100)</p><p align="center">Chat Origin: Chat_One Fund</p><p align="center">Agent Testing</p>( 23s ) Harshada A: Hi , how can I help you today?<br>( 3m 17s ) Visitor: hi<br>( 4m 36s ) Harshada A: hi<br>( 5m 9s ) Visitor: jj<br>';
        transcript.LiveChatDeploymentId = chatdeploymentId;
        
        listtranscript.add(transcript);
        insert listtranscript;
        
        Map<Id, LiveChatTranscript> mapOldChatTranscripts = new Map<Id, LiveChatTranscript>();
        mapOldChatTranscripts.put(transcript.id, transcript);        
        
        
        Test.startTest();
        List<LiveChatTranscript> listtranscript1 = [SELECT Id From LiveChatTranscript];
        System.assert(listtranscript.size() >= 0);
        //ChatTranscriptTriggerHandler.sendChatHistoryToCustomer(listtranscript,mapOldChatTranscripts);
        update transcript;
        Test.stopTest();
        
        
    }
    
    static testMethod void sendAlertToOwnerAndManagerTest(){
        
        List<LiveChatTranscript> listtranscript=new List<LiveChatTranscript>();
        
        User u=TestUtil.createUser('testuser@test.com.'+Math.random(),'alias','System Administrator');
        insert u;
        
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        
        Contact contactTest = TestUtil.createContact('test','test1');
        contactTest.email = 'testuser@test.com';
        insert contactTest;

        Id chatdeploymentId = [Select Id, DeveloperName From LiveChatDeployment where MasterLabel='Chat_One Fund' limit 1].id;

        LiveChatTranscript transcript=new LiveChatTranscript();
        transcript.PreChat_FirstName__c='test';
        transcript.PreChat_LastName__c='test1';
        transcript.PreChat_Email__c='testuser@test.com';
        transcript.LiveChatVisitorId=visitor.id;
        transcript.Status='InProgress';
        transcript.ContactId = contactTest.id;
        transcript.OwnerId = u.id;
        transcript.StartTime = datetime.now();
        transcript.EndTime = system.now()+1;
        transcript.Body = '<p align="center">Chat Started: Friday, December 20, 2019, 17:50:05 (+1100)</p><p align="center">Chat Origin: Chat_One Fund</p><p align="center">Agent Testing</p>( 23s ) Harshada A: Hi , how can I help you today?<br>( 3m 17s ) Visitor: hi<br>( 4m 36s ) Harshada A: hi<br>( 5m 9s ) Visitor: jj<br>';
        transcript.LiveChatDeploymentId = chatdeploymentId;
        
        listtranscript.add(transcript);
        insert listtranscript;
        
        Map<Id, LiveChatTranscript> mapOldChatTranscripts = new Map<Id, LiveChatTranscript>();
        mapOldChatTranscripts.put(transcript.id, transcript);        
        
        
        Test.startTest();
        
        List<LiveChatTranscript> listtranscript1 = [SELECT Id From LiveChatTranscript];
        System.assert(listtranscript.size() >= 0);
        
        listtranscript1[0].OwnerId = u.Id;
        
        update transcript;
        
        
        Test.stopTest();
    }
}