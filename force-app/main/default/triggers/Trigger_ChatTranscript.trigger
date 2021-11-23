/**
*   Purpose         :   This trigger is used to perform all custom logic on Chat Transcript object for its before and after events
*
*   Author          :   Padmesh Soni (Wipro)
*
*   Date            :   10/21/2019
*
*   Current Version :   V_1.0
*
*   Revision Log    :   V_1.0 - DPA-138 - Created
**/
trigger Trigger_ChatTranscript on LiveChatTranscript (before update, after update) {
    
    if(Trigger.isBefore) {

        if(Trigger.isUpdate) {
            
            ChatTranscriptTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter) {

        if(Trigger.isUpdate) {
            
            ChatTranscriptTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}