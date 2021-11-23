/*****************************************************************************
@Name: CampaignMemberTriggerHandler
@Author: Team SFO ( Prathyusha , Sravanthi)
@CreateDate: 29/07/2019
@Description: EDGE-98344:CampaignMemberTrigger to implement history tracking on campaign member.
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 updating API version to 50.
*******************************************************************************/
public without sharing class CampaignMemberTriggerHandler {
    public CampaignMemberTriggerHelper campMemberTriggerHelper=null;
    public CampaignMemberTriggerHandler(){
        campMemberTriggerHelper=new CampaignMemberTriggerHelper();
    }
    // 19.10 EDGE-98344
 	// @Author: Prathyusha , Sravanthi
 	//@Description : Inserts Campaign_Member_History__c records when campaign member record is edited.
    public void beforeUpdate(list<CampaignMember> newCampaignMemberlist,list<CampaignMember> oldCampaignMemberlist,Map<Id,CampaignMember> oldCampaignMemberMap){
        campMemberTriggerHelper.insertCampaignMemberHistoryCampMemEdit(newCampaignMemberlist,oldCampaignMemberlist,oldCampaignMemberMap);
    }
    // 19.10 EDGE-98344
 	// @Author: Prathyusha , Sravanthi
 	//@Description : Inserts Campaign_Member_History__c records when campaign member record is Craeted.
    public void afterInsert(list<CampaignMember> newCampaignMemberlist,list<CampaignMember> oldCampaignMemberlist,Map<Id,CampaignMember> oldCampaignMemberMap){
        campMemberTriggerHelper.insertCampaignMemberHistoryCampMemCraeted(newCampaignMemberlist,oldCampaignMemberlist,oldCampaignMemberMap);
    }
    // 19.10 EDGE-98344
 	// @Author: Prathyusha , Sravanthi
 	//@Description : Inserts Campaign_Member_History__c records when campaign member record is deleted.
    public void beforeDelete(list<CampaignMember> oldCampaignMemberlist,Map<Id,CampaignMember> oldCampaignMemberMap){
        campMemberTriggerHelper.insertCampaignMemberHistoryCampMemDeleted(oldCampaignMemberlist);
    }
    
}