/********************************************************************************
* Class Name  : C2O_ChatterUtil
* Description : This class is Handler Class for chatter functionality 
* Created By  : Sri    
* Test Class  : C2O_ChatterUtilTest    
@Last Modified      : 
No.       Developer Name        Date            Story Description 
1.        Sri                   01/10/2021      Sprint 21.15 - updated to handle/avoid null pointer exception 

********************************************************************************/
public class C2O_ChatterUtil {
    /***************************************************************************************
    * Author - Sudheendra
    * Wrapper Class - ChatterFeedInfo
    * Description - This wrapper class is meant for holding the Chatter Feed details (Parent Record Id, mentionIds, and Chatter Message) .
    ****************************************************************************************/
    public class ChatterFeedInfo{
        public String parentRecId {get; set;}
        public set<Id> mentionIds{get; set;}
        public String chatterFeedText{get; set;}
        public ChatterFeedInfo(String parId, Set<Id> mentionIds, String feed){
            this.parentRecId = parId;
            this.mentionIds = mentionIds;
            this.chatterFeedText = feed;
        }
    }

    // Create Bulk Chatter Feeds in Queuable mode...
    public class InvokeBulkChatterFeedQueueable implements Queueable {
        List<ChatterFeedInfo> listOfChatterFeedInfo;

        public InvokeBulkChatterFeedQueueable(List<ChatterFeedInfo> listOfChatterinfo){
            this.listOfChatterFeedInfo = listOfChatterinfo;
        }

        public void execute(QueueableContext context) {
            if(!this.listOfChatterFeedInfo.isEmpty()){
                List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
                for(ChatterFeedInfo feed: listOfChatterFeedInfo){
                    if(feed == null){
                        continue;
                    }
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(createChatterPost(feed.parentRecId, feed.mentionIds,  feed.chatterFeedText));
                    batchInputs.add(batchInput);
                }
                    if(batchInputs.size() <= 500){
                        try{
                            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                        }
                        catch(Exception ex){
                            PRMUtilityClass.createException(ex);
                        }
                    }
                    else{
                        batchInputs = new List<ConnectApi.BatchInput>();
                    }
            }
        }
    }
    
     /***************************************************************************************
    * Author - Sudheendra
    * Method - createChatterPost
    * Description - This Method returns the ChatterFeedInstance that will be used in invoke bulk chatter feed queuable class.
    ****************************************************************************************/
    public Static ConnectApi.FeedItemInput createChatterPost(Id parentRecordId, Set<Id> setOfUserId, String chatterTxtMsg){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = parentRecordId;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        Integer count = 0;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
            count++;
            if(count ==  25){
                break;
            }
        }
        messageSegments = PRMUtilityClass.addTextSegment(chatterTxtMsg, messageSegments);

        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }


}