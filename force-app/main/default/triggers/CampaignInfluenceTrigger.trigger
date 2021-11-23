/* Still under development by Mahendra */
trigger CampaignInfluenceTrigger on CampaignInfluence (after insert,after delete) {
    if(Trigger.Isafter && Trigger.Isinsert ){
        CampaignInfluenceTriggerHandler camInfHandler = new CampaignInfluenceTriggerHandler();
        camInfHandler.UpdateInfluencepercentage(trigger.new);
    }
    if(Trigger.Isafter && Trigger.Isdelete ){
        CampaignInfluenceTriggerHandler camInfHandler = new CampaignInfluenceTriggerHandler();
        camInfHandler.deleteInfluence(trigger.OldMap);
    }
    
}