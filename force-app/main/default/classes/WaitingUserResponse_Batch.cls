/************************************************
 * Created By: Ivan Aerlic
 * Description: Batch that processes all Cases where the Status field equals 'Waiting User Response'
 * US: EDGE-80291, P2OB-3621
 ************************************************/
public without sharing class WaitingUserResponse_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    private Case [] cases; 
    
    
    public WaitingUserResponse_Batch(Case [] cases){ 
        this.cases = [SELECT Id, Status, CreatedBy.FirstName, CreatedDate, RecordTypeId, Days_Waiting_for_Response__c FROM Case 
                      WHERE Status = 'Waiting User Response' AND RecordTypeId IN (SELECT id FROM RecordType WHERE Name ='Feedback' OR Name ='Access Issue') AND Id IN: cases];
    }
    public Case [] start(Database.BatchableContext bc){
        return cases;
    }
    public void execute(Database.BatchableContext bc, List<Case> cases){
        //Look at all Cases where Status = 'Waiting User Response'
        incrementDays(cases);//Set the Days Waiting for Response (in business days)
        Map<Id, List<ConnectApi.BatchInput>> batchInputsByCaseId = addMessages(cases);
       
        //Update and insert records 
        Database.SaveResult [] results = Database.update(cases, false);
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Database.SaveResult result : results){
            if(result.isSuccess()){
                if(batchInputsByCaseId.get(result.getId()) != null){
                    batchInputs.addAll(batchInputsByCaseId.get(result.getId()));
                }
            }
        }
        if(!batchInputs.isEmpty()){
             ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);//Send Feed Items to the Api
        }
    }
    public void finish (Database.BatchableContext bc){}

    private Map<Id, List<ConnectApi.BatchInput>> addMessages(Case [] cases){
        Map<Id, List<ConnectApi.BatchInput>> batchInputByCaseId= new Map<Id, List<ConnectApi.BatchInput>>();
        for(Case_Messages__c message: [SELECT Id, Message__c, Day__c FROM Case_Messages__c]){
            for(Case cse:cases){ 
                if(message.Day__c == cse.Days_Waiting_for_Response__c){
                    System.debug('Day == day');
                    createFeedItem(batchInputByCaseId, cse, message);
                }
            }
        }
        return batchInputByCaseId;
    }
    //Represents one business day
    private void incrementDays(Case [] cases){
        for(Case cse: cases){
            if(cse.Days_Waiting_for_Response__c==null){
                cse.Days_Waiting_for_Response__c=1;
            }else{
                cse.Days_Waiting_for_Response__c++;
            }
        }
    }
    /*
     * Creates a FeedItem and adds it to a list of batch items that will later be inserted
     * this is needed as inserting by this method is the only way we can make a mention
     */
    private void createFeedItem(Map<Id, List<ConnectApi.BatchInput>> batchInputByCaseId, Case cse, Case_Messages__c message){    
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = cse.id;
        System.debug('Cse.Id: '+input.subjectId);
        
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        //Add Mention
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = cse.CreatedById;
        messageInput.messageSegments.add(mentionSegment);
        
        //Add text segment to Feed Item body
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = '\n\nHi '+cse.CreatedBy.FirstName+',\n\n';
        textSegment.text += message.Message__c;
        messageInput.messageSegments.add(textSegment);
        System.debug('Text: '+textSegment.text );
        input.body = messageInput;
        
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
        if(!batchInputByCaseId.containsKey(cse.Id)){
            batchInputByCaseId.put(cse.Id,new List<ConnectApi.BatchInput>());
        }
        batchInputByCaseId.get(cse.Id).add(batchInput);
    }
}