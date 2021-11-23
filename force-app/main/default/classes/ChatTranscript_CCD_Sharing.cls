/**
*   Purpose         :   This class is used to create the share record on chat Transcript
*
*   Author          :   Samiksha Dalvi (Wipro)
*
*   Date            :   2/26/2021
*
*   Current Version :   V_1.0
*
*   Revision Log    :   V_1.0 - DPA-3010 - Created
**/

public without sharing class ChatTranscript_CCD_Sharing {
    @AuraEnabled
    public static void shareTranscriptToQueue(String transcriptId, String ButtonName) {
        
        // To get the chat channel and Group from custom label
        List<String> channels = label.Chat_Channel_ccd.split(',');
        List<String> groups = label.CCD_GROUP.split(',');
        Map<String, String> sharingChannelGroup = new Map<String, String>();
        
        //Check for chat channel and accordingly put the group data in sharingChannelGroup
        for(String channel : channels) {
            
            System.debug('channel ::'+ channel);
            if(channel == 'Chat_Telstra Connect Concierge')
                sharingChannelGroup.put(channel, 'Live_Chat_Telstra_Connect_Concierge');
            else if(channel == 'Chat_Telstra Connect Faults Onshore')
                sharingChannelGroup.put(channel, 'Live_Chat_TConnect_Faults_Onshore');
            else if(channel == 'Chat_Telstra Connect Faults Offshore')
                sharingChannelGroup.put(channel, 'Live_Chat_TConnect_Faults_Offshore');
        }
        System.debug('sharingChannelGroup :::'+ sharingChannelGroup);
        System.debug('ButtonName :::'+ ButtonName);
        
        //Created the Map for Group and fetching the current group details and add that in Group
        Map<String, String> mapGroupNames = new Map<String, String>();
        for(Group currentGroup : [SELECT id, Name,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName In: groups]) {
            
            mapGroupNames.put(currentGroup.DeveloperName, currentGroup.Id);
        }
               
        System.debug('mapGroupNames :::'+ mapGroupNames);
        
        // If the mapgroup has a group details and sharingchannelGroup has a channel Name
        if(mapGroupNames.size() > 0 && sharingChannelGroup.containsKey(ButtonName) && mapGroupNames.containsKey(sharingChannelGroup.get(ButtonName))){
            List<LiveChatTranscriptShare> shareRecordsToBeInsert = new List<LiveChatTranscriptShare>();
            
            //Here add the element to LiveChatTranscriptShare to create share record
            shareRecordsToBeInsert.add(new LiveChatTranscriptShare(UserOrGroupId = mapGroupNames.get(sharingChannelGroup.get(ButtonName)), ParentId = transcriptId, AccessLevel = 'Edit'));
            
            
            system.debug('shareRecordsToBeInsert'+shareRecordsToBeInsert);
            //Check if size is greater than zero
            if(shareRecordsToBeInsert.size() > 0 ) {
                  
                // Create the share record on LiveChatTranscript
                insert shareRecordsToBeInsert;
            }
        }
        
        
    }
}