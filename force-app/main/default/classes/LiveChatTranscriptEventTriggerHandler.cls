/**
*   Purpose         :   This class is used to perform all custom logic on LiveChatTranscriptEvent object for its before and after events
*
*   Author          :   Pratap Garani (Wipro)
*
*   Date            :   10/27/2020
*
*   Current Version :   V_1.0
*
*   Revision Log    :   V_1.0 - DPA-2215 - Created
**/


public class LiveChatTranscriptEventTriggerHandler {
    
     /**
    * 	@description	:	This method will process all before delete trigger custom logic
    * 
    * 	@param			:	trigger.old
    * 
    * 	@return			:	void
    **/
    
    public static void onBeforeDelete(List<LiveChatTranscriptEvent> chatEvents){
        
        handleRestrictDelete(chatEvents);
        
    }
    
    /**
    * 	@description	:	This method will prevent deletion of Chat transcript events
    * 
    * 	@param			:	trigger.old
    * 
    * 	@return			:	void
    **/
    
    public static void handleRestrictDelete(List<LiveChatTranscriptEvent> chatEvents) {
        
        for(LiveChatTranscriptEvent lcte : chatEvents){
            
            lcte.adderror('Chat Events cannot be deleted');
            
        }
        
    }

}