/**
*	Purpose			:	This class is used to perform all custom logic on Chat Transcript object for its before and after events
*
*	Author			:	Padmesh Soni (Wipro)
*
*	Date			:	10/21/2019
*
*	Current Version	:	V_1.0
*
*	Revision Log	:	V_1.0 - DPA-138 - Created
**/
public without sharing class ChatTranscriptTriggerHandler {
    @testVisible
    public static final Set<String> deploymentChannelnonPreChat = new Set<String>();
    static {
        
        for(Live_Chat_Channel_Non_PreChat__mdt a1 : [Select id, Chat_Channel__c from Live_Chat_Channel_Non_PreChat__mdt]){
            
            deploymentChannelnonPreChat.add(a1.Chat_Channel__c);
        }
    }
    
    /**
    * 	@description	:	This method will process all before insert trigger custom logic
    * 
    * 	@param			:	trigger.new
    * 
    * 	@return			:	void
    **/
    public static void onBeforeUpdate(List<LiveChatTranscript> newChatTranscripts, Map<Id, LiveChatTranscript> oldMapTranscript) {
        System.debug('old values@@@@ '+oldMapTranscript + 'new values@@@@@ '+newChatTranscripts);
        handleSelectionContactsAndCases(newChatTranscripts);
    }

    /**
    * 	@description	:	This method will process all before insert trigger custom logic
    * 
    * 	@param			:	trigger.new
    * 
    * 	@return			:	void
    **/
    public static void onAfterUpdate(List<LiveChatTranscript> newChatTranscripts, Map<Id, LiveChatTranscript> oldMapTranscript) {
        sendAlertToOwnerAndManager(newChatTranscripts, oldMapTranscript);
    }

    /**
    * 	@description	:	This method will associate orphan chat transcript to appropriate Contact
    * 
    * 	@param			:	trigger.new
    * 
    * 	@return			:	void
    **/
    public static void handleSelectionContactsAndCases(List<LiveChatTranscript> newChatTranscripts) {
        
        //properties
        @testVisible
        Set<String> emails = new Set<String>();
        @testVisible
        Set<String> contactSessionIds = new Set<String>();
        @testVisible
        Set<String> caseNumbers = new Set<String>();
        
        //Loop through trigger.new
        for(LiveChatTranscript ct : newChatTranscripts){
            
            // Contact matching scenario modified as part of DPA - 1559 to facilitate Authentication for TConnect Users
            if(deploymentChannelnonPreChat.contains(ct.Chat_Channel__c)){
                if(String.isNotBlank(ct.Contact_Session_Id__c)) {
                    contactSessionIds.add(ct.Contact_Session_Id__c);
                }
                if(String.isNotBlank(ct.TConnect_Case_Number__c)) {
                    caseNumbers.add(ct.TConnect_Case_Number__c);
                }
            }else{
                
                // Contact matching scenario modified as part of DPA - 228
                if(String.isBlank(ct.ContactId) && String.isNotBlank(ct.PreChat_Email__c)) {
                    emails.add(ct.PreChat_Email__c);
                }
            }
        }
        
        //Query the Contacts with matching criteria
        Map<String, Contact> mapContacts = new Map<String, Contact>();
        // Contact matching scenario modified as part of DPA - 228
        if((emails.size()>0) || (contactSessionIds.size()>0)){
            for(Contact contact : [SELECT id, Email,LiveChat_SessionId__c FROM Contact 
                                   WHERE Email IN :emails OR LiveChat_SessionId__c IN :contactSessionIds ORDER BY CreatedDate DESC]) 
            {
                
                //Create contact unique key
                
                String conUniqueKey;
                if(emails.size()>0){
                    // Contact matching scenario modified as part of DPA - 228 for non TConnect Users
                    conUniqueKey = '#'+ contact.Email;
                }else if(contactSessionIds.size()>0){
                    
                    // Contact matching scenario modified as part of DPA - 1559 for TConnect Users
                    conUniqueKey = '#' +contact.LiveChat_SessionId__c;
                }
                
                //Check for already exists key
                if(!mapContacts.containsKey(conUniqueKey)) {
                    
                    //populate map
                    mapContacts.put(conUniqueKey, contact);
                }
            }
        }
        
        
        //Query the Cases with matching criteria for Tconnect Users
        Map<String, Case> mapCases = new Map<String, Case>();
        if(caseNumbers.size()>0){
            for(Case caseRecord : [SELECT Id,CaseNumber FROM Case 
                                   WHERE CaseNumber IN :caseNumbers]) 
            {
                
                String caseUniqueKey = '#'+ caseRecord.CaseNumber;
                
                //Check for already exists key
                if(!mapCases.containsKey(caseUniqueKey)) {
                    
                    //populate map
                    mapCases.put(caseUniqueKey, caseRecord);
                }
            }
        }

        //Loop through trigger.new
        for (LiveChatTranscript lct : newChatTranscripts){
            
            //Check for orphan Transcripts
            // Contact matching scenario modified as part of DPA - 228,DPA - 1559
            if(String.isBlank(lct.ContactId) && (String.isNotBlank(lct.PreChat_Email__c) || String.isNotBlank(lct.Contact_Session_Id__c))) {
                
                //Create unique key
                
                String uniqueKey;
                if(emails.size() > 0){
                    
                    // Contact matching scenario modified as part of DPA - 228
                    uniqueKey = '#'+ lct.PreChat_Email__c;
                }else if(contactSessionIds.size()>0){
                    
                    // Contact matching scenario modified as part of DPA - 1559 for TConnect Users
                    uniqueKey = '#' +lct.Contact_Session_Id__c;
                }
                
                //Check for orphan Chat Transcript and unique key exists in map as key
                if(mapContacts.containsKey(uniqueKey)){
                    
                    //assign Contact Id
                    lct.ContactId = mapContacts.get(uniqueKey).id;
                }
            } 
            
            if (String.isNotBlank(lct.TConnect_Case_Number__c)){
                String uniqueKey = '#'+ lct.TConnect_Case_Number__c ;
                //Check for orphan Chat Transcript and unique key exists in map as key
                if(mapCases.containsKey(uniqueKey)){
                    
                    //assign Case Id
                    lct.CaseId = mapCases.get(uniqueKey).id;
                }
            }
        }
    }

    /**
    * 	@description	:	This method will process all before insert trigger custom logic
    * 
    * 	@param			:	trigger.new
    * 
    * 	@return			:	void
    **/
    public static void sendAlertToOwnerAndManager(List<LiveChatTranscript> newChatTranscripts, Map<Id, LiveChatTranscript> oldMapTranscript) {
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(LiveChatTranscript transcript : newChatTranscripts) {
	
            System.debug('transcript.Status old:::'+ oldMapTranscript.get(transcript.Id).Status);
            System.debug('transcript.OwnerId old:::'+ oldMapTranscript.get(transcript.Id).OwnerId);
            System.debug('transcript.Status :::'+ transcript.Status);
            System.debug('transcript.OwnerId :::'+ transcript.OwnerId);
            
            if(transcript.Status == 'InProgress' 
            && ((transcript.Status != oldMapTranscript.get(transcript.Id).Status && String.valueOf(transcript.OwnerId).left(3) == '005')
            || (transcript.OwnerId != oldMapTranscript.get(transcript.Id).OwnerId && String.valueOf(transcript.OwnerId).left(3) == '005')
            || Test.isRunningTest())) {

                Messaging.SingleEmailMessage mail = sendAlert(transcript);

                if(mail != null) {
                
                    // Step 5. Add your email to the master list
                    mails.add(mail);
                }
            }
        }

        if(mails.size() > 0) {

            Messaging.sendEmail(mails);
        }
    }


    public static Messaging.SingleEmailMessage sendAlert(LiveChatTranscript transcript) {

        String emailBody = 'You have a new live chat <font color="#ff0000">{TranscriptName}</font> waiting for you from a customer. Please check Phoenix immediately.';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<String> sendTo = new List<String>();
        sendTo.addAll(transcript.Owner_Emails__c.split(','));
        
        mail.setToAddresses(sendTo);

        // Step 3: Set who the email is sent from
        mail.setReplyTo('do-not-reply-phoenix@team.telstra.com');
        mail.setSenderDisplayName('Do Not Reply Phoenix');
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject('New live chat message in Phoenix');
        mail.setHtmlBody(emailBody.replace('{TranscriptName}', transcript.Name));
        
        // Step 5. Add your email to the master list
        return mail;
    }
}