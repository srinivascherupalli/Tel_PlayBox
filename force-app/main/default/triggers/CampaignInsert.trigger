/*******************************************************************************
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
					  as part of P2OB-9943/P2OB-6772 updating API version to 50.
@Last Modified      : 
*******************************************************************************/
trigger CampaignInsert on Campaign (after insert) { 
     /* Last Modified : 20:17
		Below logic used to stop to execute trigger logic when no Trigger option in Environment Configurations(custom setting)
	   for specific user
     */
     if(EnvironmentalSettings.isTriggerDisabled('CampaignInsert')){
        return;
    } 
    CampaignTriggerHelper campTrg=new CampaignTriggerHelper();
    if(Trigger.isAfter && Trigger.isInsert){
        campTrg.insertCampaignMemberStatusValues(trigger.new);
    }
}