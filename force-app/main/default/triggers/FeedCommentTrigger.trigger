/*------------------------------------------------------------ 
Author: Ivan Aerlic 
Company: Telstra 
Description: Feed Comment trigger created to implement Trigger Framework.
Inputs: N/A
Jira Story Ref: Originaly made for EDGE-80291 
Test Class: TestFeedCommentHelperAndTrigger ++ Others
History 
24/05/2019, Ivan Aerlic, Creation date
------------------------------------------------------------*/
trigger FeedCommentTrigger on FeedComment(after delete, after insert, after update, before delete, before insert, before update) {
    if(!EnvironmentalSettings.isTriggerDisabled('FeedCommentTrigger'))
    	fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
}