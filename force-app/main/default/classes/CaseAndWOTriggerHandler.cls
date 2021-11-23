/***********************************************************************************************************
 *  DIGI-18800      : Post a chatter msg and close the cases and Work Order once Opportunity is closed. 
 *  Feature Team    : Hawaii (21.15)
 *  Trigger         : CaseAndWOTrigger 
 *  Test Class      : Covered by OpportunityTriggerHandler's Test classes.
 ***********************************************************************************************************/
public without sharing class CaseAndWOTriggerHandler {
    List<Case_and_Work_Order_Data__e> recordNewList = new List<Case_and_Work_Order_Data__e>();
    List<sObject> caseWOList = new List<sObject>();
    public CaseAndWOTriggerHandler(List<Case_and_Work_Order_Data__e> newList){
        this.recordNewList = newList;
    }
    
    public void beforeInsert(){
        try{
            system.debug('CaseAndWOTriggerHandler handler called*****');
            List<String> caseIdList = new List<String>();
            List<String> woIdList = new List<String>();
            
            List<FeedItem> FeedItemList = new List<FeedItem>();
            for(Case_and_Work_Order_Data__e cwo : recordNewList){
                if(cwo.Object_Name__c == 'Case'){
                    caseIdList.add(cwo.Record_Id__c);
                }else if(cwo.Object_Name__c == 'WorkOrder'){
                    woIdList.add(cwo.Record_Id__c);
                }
            }
            
            List<Case> caseToCloseList = new List<Case>();
            caseToCloseList = [ SELECT Id, Status FROM Case WHERE Id =: caseIdList AND Status != 'Closed' ]; // changing filter from Case Closed to Closed
            
            if(caseToCloseList.size() > 0){
                for(Case cs : caseToCloseList){
                    cs.Status = 'Closed'; // changing case status for closure from Case Closed to Closed
                }
            }
            caseWOList.addAll(caseToCloseList);

            List<WorkOrder> woToCloseList = new List<WorkOrder>();
            woToCloseList = [ SELECT Id, Status FROM WorkOrder WHERE Id =: woIdList AND Status != 'Closed' ];
            if(woToCloseList.size() > 0){
                for(WorkOrder wo : woToCloseList){
                    wo.Status = 'Closed';
                }           
            }
            caseWOList.addAll(woToCloseList);
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), PostChatter(caseWOList));
        }catch(exception e){
            System.debug('Chatter Post Exception:: '+e.getMessage());
        }
    }

    
    public static List<ConnectApi.BatchInput> PostChatter(List<sObject> updateResult){
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        List<Database.SaveResult> updatedResultList = Database.update(updateResult, false);
        List<ConnectApi.FeedItemInput> FeedItemInputList = new List<ConnectApi.FeedItemInput>();
        List<Id> caseWoIdList = new List<Id>();
        for(Database.SaveResult ds : updatedResultList){
            caseWoIdList.add(ds.getId());
        }
        
        Map<Id,Case> caseMap = new Map<Id,Case>([ SELECT Id, OpportunityId__c, OpportunityId__r.Name, OwnerId, CaseNumber FROM Case WHERE Id =: caseWoIdList ]);
        Map<Id,WorkOrder> WorkOrderMap = new Map<Id,WorkOrder>([ SELECT Id, cusdl_opportunityId__c, cusdl_opportunityId__r.Name, WorkOrderNumber, OwnerId FROM WorkOrder WHERE Id =: caseWoIdList ]);
        
        for(Database.SaveResult sr : updatedResultList){
            ConnectApi.FeedItemInput        feedItemInput       = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput  mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput     messageBodyInput    = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput     textSegmentInput    = new ConnectApi.TextSegmentInput();

            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            mentionSegmentInput.id = sr.getId().getSObjectType().getDescribe().getName() == 'Case' ? caseMap.get(sr.getId()).OwnerId : WorkOrderMap.get(sr.getId()).OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);

            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = sr.getId();
            system.debug('***sr.isSuccess()***'+sr.isSuccess());
            if(sr.isSuccess()){
                // If record is Closed successfully . Inform Record Owner by Chatter post
                if(sr.getId().getSObjectType().getDescribe().getName() == 'Case'){
                    String caseSuccess = System.Label.caseCloseSuccessMsg.replace('#OpportunityName#',caseMap.get(sr.getId()).OpportunityId__r.Name);
                    caseSuccess = caseSuccess.replace('#CaseNumber#',caseMap.get(sr.getId()).CaseNumber);
                    textSegmentInput.text = caseSuccess;
                }else{
                    String woSuccess = System.Label.workOrderCloseSuccessMsg.replace('#OpportunityName#',WorkOrderMap.get(sr.getId()).cusdl_opportunityId__r.Name);
                    woSuccess = woSuccess.replace('#WorkOrderNumber#',WorkOrderMap.get(sr.getId()).WorkOrderNumber);
                    textSegmentInput.text = woSuccess;
                }
                
            }else{
                // If record is not Closed successfully . Inform Record Owner by Chatter post and ask them to do manually.
                if(sr.getId().getSObjectType().getDescribe().getName() == 'Case'){
                    String caseCloseFail = System.Label.caseCloseFailMsg.replace('#OpportunityName#',caseMap.get(sr.getId()).OpportunityId__r.Name);
                    caseCloseFail = caseCloseFail.replace('#CaseNumber#',caseMap.get(sr.getId()).CaseNumber);
                    textSegmentInput.text = caseCloseFail;
                }else{
                    String woCloseFail = System.Label.woCloseFailMsg.replace('#OpportunityName#',WorkOrderMap.get(sr.getId()).cusdl_opportunityId__r.Name);
                    woCloseFail = woCloseFail.replace('#WorkOrderNumber#',WorkOrderMap.get(sr.getId()).WorkOrderNumber);
                    textSegmentInput.text = woCloseFail;
                }
            }
            messageBodyInput.messageSegments.add(textSegmentInput);

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(batchInput);
        }
        return batchInputs; 
    }
}