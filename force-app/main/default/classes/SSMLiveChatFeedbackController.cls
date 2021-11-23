/**
*	Purpose			:	This class is used to control feedback from Live Chat and store it as Live Chat Feedback object record.
*
*	Author			:	Padmesh Soni (Wipro)
*
*	Date			:	8/9/2019
*
*	Current Version	:	V_1.0
*
*	Revision Log	:	V_1.0 - DPA-42 - Created
**/
global without sharing class SSMLiveChatFeedbackController {
    
    //Constructor definition
    global SSMLiveChatFeedbackController() {
        
    }
    
    /**
    * 	@description	:	This method will process chat feedback and create Feedback record
    * 
    * 	@param			:	String optionSelected, String comments, String chatKey
    * 
    * 	@return			:	void
    **/
    @RemoteAction
    global static String finishFeedback(String optionSelected, String comments, String chatKey) {
        
        try {
            
            //Query result of Chat Transcript
            List<LiveChatTranscript> transcripts = [Select Id, ContactId, Contact.AccountId From LiveChatTranscript WHERE ChatKey =: chatKey];
            if(transcripts.size() > 0) {
                
                //Create a record of Feedback
                insert new Live_Chat_Feedback__c(Chat_Transcript__c = transcripts[0].Id, Query_Resolved__c = optionSelected, Comments__c = comments);
            }
            //return statement
            return 'Success';
        } catch(Exception e) {
            
            //return statement
            return 'Exception';
        }
    }
}