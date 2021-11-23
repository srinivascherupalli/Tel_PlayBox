/**
*	Purpose			:	This class is used to send an email to Chat Transcript's Email once it's completed by Live Chat Agent in SSM.
*
*	Author			:	Padmesh Soni (Wipro)
*
*	Date			:	8/1/2019
*
*	Current Version	:	V_1.0
*
**/
public with sharing class LiveChatTranscriptEmailService {
    //Class variables
    public static LiveChatTranscript chatTranscript;
    public static Boolean isGroupChat = false;
    public static final Set<String> deploymentChannel = new Set<String>();
    static {
        for(NotifyIntegrationLiveChatChannel__mdt a1 : [Select id, Deployment_Name__c from NotifyIntegrationLiveChatChannel__mdt]){
            deploymentChannel.add(a1.Deployment_Name__c);
        }
    }
    /**
    * 	@description	:	This method will process transcript to make request for Notify integration
    * 
    * 	@param			:	List<String> transcriptIds
    * 
    * 	@return			:	void
    **/
    @InvocableMethod
    public static void processChatTranscript(List<String> transcriptIds) {
        //Get Chat Transcript records
        List<LiveChatTranscript> chatTranscripts = [SELECT id, ContactId, Contact.Email,Contact.Name,Contact.FirstName,Contact.LastName, 
                                                    Body, StartTime, EndTime, ChatDuration, PreChat_Email__c, PreChat_FirstName__c, PreChat_LastName__c,
                                                    Owner.FirstName, Owner.LastName, 
                                                    (Select Id, Type, Agent.FirstName, Agent.LastName from LiveChatTranscriptEvents 
                                                     WHERE Type = 'Transfer' OR Type = 'OperatorJoinedConference')
                                                    From LiveChatTranscript WHERE Id IN : transcriptIds AND LiveChatDeployment.DeveloperName IN: deploymentChannel];
        //Check for size
        if(chatTranscripts.size() > 0){
            //Assign value to transcript instance
            chatTranscript = chatTranscripts[0];
			isGroupChat = (chatTranscript.LiveChatTranscriptEvents.size() > 0);
            //Get Emails to list
            List<String> toEmails = new List<String>();
            if(String.isNotBlank(chatTranscript.ContactId)) {
                toEmails.add(chatTranscript.Contact.Email); 
                System.debug('toEmails1@@@ '+toEmails);
            } else if(String.isNotBlank(chatTranscript.PreChat_Email__c)) {
                toEmails.add(chatTranscript.PreChat_Email__c);
                System.debug('toEmails2@@@ '+toEmails);
            }
            System.debug('toEmails3@@@ '+toEmails);
            //Assign values to attributes
            String fromEmail = null;
            String body = chatTranscript.Body;
            String agentName = chatTranscript.Owner.FirstName + ' ' + chatTranscript.Owner.LastName.left(1);
            String clientName = String.isNotBlank(chatTranscript.ContactId) ? chatTranscript.Contact.Name : chatTranscript.PreChat_FirstName__c + ' ' + chatTranscript.PreChat_LastName__c;
            Map<String, String> otherKayValues = new Map<String, String>();
            otherKayValues.put('chat_start_time', chatTranscript.StartTime.format('hh:mm:ss a'));
            otherKayValues.put('chat_end_time', chatTranscript.EndTime.format('hh:mm:ss a'));
            otherKayValues.put('chat_duration', (chatTranscript.ChatDuration != null ? (chatTranscript.ChatDuration/60) : 0)+ ' mins');
            otherKayValues.put('agent_name', agentName);
            otherKayValues.put('client_name', clientName);
            otherKayValues.put('info_text', Label.SSM_EMAIL_INFO_MESSAGE);
            // Main Body
            LiveChatTranscriptWrapper.Data dataItem = new LiveChatTranscriptWrapper.Data();
            getLiveChatData(dataItem, otherKayValues);
            // Recipient
            LiveChatTranscriptWrapper.Recipient recipientItem = new LiveChatTranscriptWrapper.Recipient();
            getLiveChatDataRecipient(recipientItem,toEmails);
            dataItem.recipient = recipientItem;
            // Content Parameters
            LiveChatTranscriptWrapper.ContentParameters contentparameters = new LiveChatTranscriptWrapper.ContentParameters();
            LiveChatTranscriptWrapper.Values values = new LiveChatTranscriptWrapper.Values();
            dataItem.contentParameters = getContentParameter(contentparameters, otherKayValues, values, body, agentName, clientName, isGroupChat);
            String requestBody = System.JSON.serializePretty(dataItem, true);
            System.debug(' ::::::: requestBody' + requestBody) ;
            System.debug(Logginglevel.ERROR , ' ::::::: My Debug :::::::::::::') ;
            IntegrationRecordHandlerUtil.createRequests('CalloutNotify', new List<String>{dataItem.notificationEventType+':'+dataItem.recipient.emailAddress},JSON.serialize(dataItem));
            notifycallout(requestBody);
        }
    }
    /**
    * 	@description	:	This method will assign property value on wrapper's dataitem
    * 
    * 	@param			:	LiveChatTranscriptWrapper.Data dataItem, Map<String,String> wrapperdata
    * 
    * 	@return			:	void
    **/
    private static void getLiveChatData(LiveChatTranscriptWrapper.Data dataItem, Map<String,String> wrapperdata ){
        DateTime dt = System.Datetime.now();
        dataItem.notificationEventType = Label.ENT_LIVE_CHAT;
        dataItem.entityType = Label.NOT_APPLICABLE;
        dataItem.entityId = Label.NOT_APPLICABLE;
    }
    /**
    * 	@description	:	This method will get receipient emails
    * 
    * 	@param			:	LiveChatTranscriptWrapper.Recipient recipientItem, List<String> toEmails
    * 
    * 	@return			:	void
    **/
    private static void getLiveChatDataRecipient(LiveChatTranscriptWrapper.Recipient recipientItem, List<String> toEmails){
        if(toEmails!=null && !toEmails.isEmpty()){
            for(String email : toEmails){
                recipientItem.emailAddress = toEmails.get(0);
            }
        }
    }
    /**
    * 	@description	:	This method will made wapper for request to notify integration
    * 
    * 	@param			:	LiveChatTranscriptWrapper.ContentParameters contentparameters, Map<String, String> otherKayValues, LiveChatTranscriptWrapper.Values values, String body, String agentName, String clientName, Boolean isGroupChat
    * 
    * 	@return			:	List<LiveChatTranscriptWrapper.ContentParameters>
    **/
    private static List<LiveChatTranscriptWrapper.ContentParameters> getContentParameter(LiveChatTranscriptWrapper.ContentParameters contentparameters, Map<String, String> otherKayValues, LiveChatTranscriptWrapper.Values values, String body, String agentName, String clientName, Boolean isGroupChat){
        List<LiveChatTranscriptWrapper.ContentParameters> contentParametersData= new List<LiveChatTranscriptWrapper.ContentParameters>();
        if(otherKayValues != null && otherKayValues.size() > 0) {
            for(String key : otherKayValues.keySet()) {
                LiveChatTranscriptWrapper.ContentParameters contentparameters1 = new LiveChatTranscriptWrapper.ContentParameters();
                contentparameters1.name = key;
                contentparameters1.value = otherKayValues.get(key);
                contentParametersData.add(contentparameters1);
            }
        }
        LiveChatTranscriptWrapper.ContentParameters contentparameters2 = new LiveChatTranscriptWrapper.ContentParameters();
        contentparameters2.name = 'transcript_text';
        contentparameters2.values = new List<List<LiveChatTranscriptWrapper.Values>>();
        contentparameters2.values = getValues(values, body, agentName, clientName, isGroupChat);
        contentParametersData.add(contentparameters2);
        return contentParametersData;
    }
    /**
    * 	@description	:	This method will made inner wapper for request to notify integration
    * 
    * 	@param			:	LiveChatTranscriptWrapper.Values values, String body, String agentName, String clientName, Boolean isGroupChat
    * 
    * 	@return			:	List<List<LiveChatTranscriptWrapper.Values>>
    **/
    private static List<List<LiveChatTranscriptWrapper.Values>> getValues(LiveChatTranscriptWrapper.Values values, String body, String agentName, String clientName, Boolean isGroupChat){
        List<List<LiveChatTranscriptWrapper.Values>> listValuesData = new List<List<LiveChatTranscriptWrapper.Values>>();
        List<LiveChatTranscriptWrapper.Values> valuesData = new List<LiveChatTranscriptWrapper.Values>();
        if(isGroupChat) {
            Set<String> agentNames = new Set<String>{agentName};
            for(LiveChatTranscriptEvent event : chatTranscript.LiveChatTranscriptEvents) {
                agentNames.add(event.Agent.FirstName + ' '+ event.Agent.LastName.left(1));
            }
            System.debug('agentNames :::'+ agentNames);
            List<String> paraSplitBody = body.split('</p>');
            for(String paraSplit : paraSplitBody) {
                System.debug('paraSplit ::'+ paraSplit);
                if(paraSplit.contains('<br>')) {
                    for(String nxtLineStr : paraSplit.split('<br>')) {
                        System.debug('paraSplit ::'+ nxtLineStr);
                        valuesData = new List<LiveChatTranscriptWrapper.Values>();
                        LiveChatTranscriptWrapper.Values values1 = new LiveChatTranscriptWrapper.Values();
        				if(nxtLineStr.contains('s ) ')) {
                            String chatfinder = nxtLineStr.substringBetween(') ',':');
                            System.debug('Jeff :::'+ nxtLineStr.substringbefore(':'));
                            System.debug('Jeff :::'+ nxtLineStr.substringAfter(':'));
                            System.debug('chatfinder :::'+ chatfinder);
                            if(chatfinder != null && agentNames.contains(chatfinder)) {
                                values1.name = 'agent_text';
                                System.debug('Jeff inner :::'+ nxtLineStr.substringAfter(':'));
                            	values1.value = nxtLineStr.substringAfter(':');
                                valuesData.add(values1);
                            } else if(chatfinder != null && !agentNames.contains(chatfinder)) {
                                values1.name = 'client_text';
                                values1.value = nxtLineStr.substringAfter(':');
                                valuesData.add(values1);
                            }
                        }
                        if(valuesData.size() > 0) {
                            listValuesData.add(valuesData);
                        }
                    }
                }
            }
        } else {
            body = body.substringAfterLast('</p>');
            System.debug('body ::'+ body);
            for(String bodyStr : body.split('<br>'))
            {
                valuesData = new List<LiveChatTranscriptWrapper.Values>();
                LiveChatTranscriptWrapper.Values innerValues = new LiveChatTranscriptWrapper.Values();
        		System.debug('bodyStr ::'+ bodyStr);
                String chatfinder ='';
                chatfinder = bodyStr.substringBefore(':');
                if(chatfinder != null && chatfinder.contains(agentName))
                {
                    innerValues.name = 'agent_text';
                    innerValues.value = bodyStr.substringAfter(':');
                    valuesData.add(innerValues);
                }
                else if(chatfinder != null && !chatfinder.contains(agentName))
                {
                    innerValues.name = 'client_text';
                    innerValues.value = bodyStr.substringAfter(':');
                    valuesData.add(innerValues);
                }
                if(valuesData.size() > 0) {
                    listValuesData.add(valuesData);
                }
            }
        }
        return listValuesData;
    }
    /**
    * 	@description	:	This method is for intergration handler to use
    * 
    * 	@param			:	String param
    * 
    * 	@return			:	void
    **/
    @future(callout=true)
    public static void notifycallout(String param) {
        //String handlerName = 'CalloutNotify';
        /* For access token okapi prod end point url has to be used */
        String handlerName =  'EmailHandler';
        Logger2 logger2 = Logger2.getLogger(handlerName);
        String token = AuthenticationManager.getOauthToken(handlerName);
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json',
            'Authorization'=> 'Bearer '+token};
                HTTPResponse reponse = IntegrationRecordHandlerUtil.callout(param,
                                                                            IntegrationRecordHandlerUtil.HTTP_METHOD_POST,
                                                                            headerMap, handlerName, new List<String>{param},null);
        System.debug('response@@@ '+reponse);
        if(reponse != null && reponse.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED) 
        {
            logger2.logMessages(JSON.serialize(param), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
        } else {
            System.debug('-------------->>>>>>> ERROR sending email');
            String corId;
            String errorMsg;
            if(reponse != null && !String.isEmpty(reponse.getBody())) {
                errorMsg = ': Email Sent request failed with code ' + reponse.getStatusCode() + ' and error ' + reponse.getBody();
                logger2.logMessages(JSON.serialize(param), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
            } else {
                errorMsg = ': Email Sent request failed';
                logger2.logMessages(JSON.serialize(param), null, '', '', '', '', false, false, null , null, null, null);
            }
        }
        logger2.exitLogger();
    }
}