/****************************************************************************
@Name: SFOIdeaTriggerHandler
@Author: SFO/Sri
@CreateDate: 22/10/2019
@Sprint : 19.14[P2OB-3302]
@Description: This Class is for IdeaTrigger Trigger - P2OB-3302, to get the test coverage 
			  using the class SFOIdeaTriggerHandlerTest
Note : Implemented Trigger FrameWork
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*****************************************************************************/
public without sharing class SFOIdeaTriggerHandler  extends ATF_AbstractDomainHandler {
    final String POST_TYPE_TEXT = 'TextPost';        
    final String POST_TITLE_GROUP = 'Group';
    /****************************************************************************
    @Method Name: handleAfterInsert
    @Author: SFO/Sri
    @Sprint : 19.14[P2OB-3302]
    @CreateDate: 22/10/2019
    @Description: This Method is triggered after insert to post chatter to 
				  Change Champion Group(Chatter Group)
    ******************************************************************************/      
    public override void handleAfterInsert(){        
        try{            
            List<FeedItem> postList = new List<FeedItem>();
            for(Idea ide : (List<Idea>) Trigger.new) {
                Phoenix_Configurations__c pc = Phoenix_Configurations__c.getInstance();
                Id groupID = pc.ChangeChampionsGroup_ChatterGroupID__c;
                FeedItem post = new FeedItem();
                post.Type = POST_TYPE_TEXT;
                post.ParentId = groupID;
                post.Title = POST_TITLE_GROUP;
                String msg1 = pc.ChangeChampionsChatterGroup_Msg1__c;
                String msg2 = pc.ChangeChampionsChatterGroup_Msg2__c;
                post.Body = msg1 +' '+ Userinfo.getName() +' '+ msg2 +' '+ ide.IdeaRecordUrl__c; 
                //'A new idea has been posted on Success Community by '+Userinfo.getName()+ ' . To view the details, click the following link:'+ide.IdeaRecordUrl__c;            
                postList.add(post);
            }
            if(postList.size()>0){
            	insert postList;
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOIdeaTriggerHandler Class:::: handleAfterInsert Method'+ Ex.getMessage());            
        }
    }
}