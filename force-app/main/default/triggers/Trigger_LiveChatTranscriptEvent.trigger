/**
*   Purpose         :   This trigger is used to perform all custom logic on LiveChatTranscriptEvent object for its before and after events
*
*   Author          :   Pratap Garani (Wipro)
*
*   Date            :   10/27/2020
*
*   Current Version :   V_1.0
*
*   Revision Log    :   V_1.0 - DPA-2215 - Created
**/

trigger Trigger_LiveChatTranscriptEvent on LiveChatTranscriptEvent (before delete) {
    
    if(Trigger.isBefore) {

        if(Trigger.isDelete) {
            
            LiveChatTranscriptEventTriggerHandler.onBeforeDelete(Trigger.old);
        }
    }
    
}