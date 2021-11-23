/**
*	Purpose			:	This class is used to test trigger of preChatDetailsController.
*
*	Author			:	Pratap Garani (Wipro)
*
*	Date			:	10/30/2020
*
*	Current Version	:	V_1.0
*
*	Revision Log	:	V_1.0 - DPA-1977 - Created
**/

@isTest
private class PreChatDetailsController_Test {
    
    static testMethod void getPreChatDataTest(){
        
        LiveChatVisitor visitor=new LiveChatVisitor();
        insert visitor;
        
        Id chatdeploymentId = [Select Id, DeveloperName From LiveChatDeployment where MasterLabel='Chat_One Fund'].id;
        
        LiveChatTranscript transcript=new LiveChatTranscript();
        transcript.LiveChatVisitorId=visitor.id;
        transcript.LiveChatDeploymentId = chatdeploymentId;
        transcript.Status='completed';
        transcript.PreChat_Email__c='test@test.com';
        transcript.PreChat_FirstName__c='TestFirstName';
        transcript.PreChat_LastName__c='TestLastName';
        transcript.PreChat_Phone_Number__c='1234567890';
        transcript.Company_Name__c='TestCompany';
        insert transcript;
        
               
        Test.startTest();
        PreChatDetailsController.getPreChatData(transcript.id);
        System.assertEquals(transcript.PreChat_Email__c, 'test@test.com');
        Test.stopTest();
    } 

}