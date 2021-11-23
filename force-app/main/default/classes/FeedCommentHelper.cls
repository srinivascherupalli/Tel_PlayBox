/*------------------------------------------------------------ 
Author: Ivan Aerlic 
Company: Telstra 
Description: An helper class for changing the Status of a Case when a Feed Comment is inserted.
Inputs: "comments" - A list of FeedComments
Jira Story Ref: EDGE-80291
Test Class: TestFeedCommentHelperAndTrigger
History:
24/05/2019, Ivan Aerlic, Creation date.
------------------------------------------------------------*/
public Without Sharing class FeedCommentHelper extends ATF_AbstractDomainHandler {
    /**
    *  This method take a list of FeedComments that we expect to be related to a parent Case. 
    *  If the Case Status = 'Waiting User Response', and was made by the creating User, then we change the 
    *  Status to 'User Response Received'
    *  @name handleAfterInsert
    *  @param - N/A
    *  @return void - N/A
    *  @throws exception-N/A
    *  @ EDGE 80291
    */
    public override void handleAfterInsert()  {
        //Variable Initialization
        List<Id> caseIds = new List<Id>();
        List<Id> creatorIds = new List<Id>();
        
        //Create a list of Case ids and a list of User ids
        //The Case the FeedComment belongs to and the User that created it
        for(FeedComment comment: (List<FeedComment>)Trigger.new){
            if(((String)comment.ParentId).substring(0, 3) == '500'){
                caseIds.add(comment.ParentId);
                creatorIds.add(comment.CreatedById);
            }
        }
        //Retrieve and update Cases
        if(!(caseIds.isEmpty())){
            List<Case> relevantCases = [SELECT Id FROM Case WHERE Id IN :caseIds AND CreatedById IN :creatorIds AND Status = 'Waiting User Response'
                                        AND (RecordType.Name = 'Feedback' OR RecordType.Name = 'Access Issue')];
            System.debug('Cases returned: '+relevantCases);
            for(Case var : relevantCases){
                var.Status = 'User Response Received';
            }
            update relevantCases;
        }
    }
}