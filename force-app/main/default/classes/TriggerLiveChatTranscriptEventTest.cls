/**
*	Purpose			:	This class is used to test trigger of Chat Transcript Event.
*
*	Author			:	Pratap Garani (Wipro)
*
*	Date			:	10/27/2020
*
*	Current Version	:	V_1.0
*
*	Revision Log	:	V_1.0 - DPA-2215 - Created
**/

@isTest
private class TriggerLiveChatTranscriptEventTest {
    
    static testMethod void handleRestrictDeleteTest(){
        
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        
        Id chatdeploymentId = [Select Id, DeveloperName From LiveChatDeployment where MasterLabel='Chat_One Fund'].id;
        
        LiveChatTranscript transcript=new LiveChatTranscript();
        transcript.LiveChatVisitorId=visitor.id;
        transcript.LiveChatDeploymentId = chatdeploymentId;
        transcript.Status='completed';
        insert transcript;
        
        LiveChatTranscriptEvent lcteRecord = new LiveChatTranscriptEvent();
        lcteRecord.LiveChatTranscriptId = transcript.id;
        lcteRecord.Type = 'Accept';
        lcteRecord.Detail = 'Chat request accepted by agent.';
        lcteRecord.Time = System.now();
        insert lcteRecord;
        
        Test.startTest();
        
        try{
            delete lcteRecord;
        }catch(DMLexception e){
            system.assert(e.getMessage().contains('Chat Events cannot be deleted'),'Chat Events cannot be deleted');                       
        }
        
        Test.stopTest();
    }
    
}