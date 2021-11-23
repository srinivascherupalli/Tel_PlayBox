/*****************************************************************************
@Name: CampaignMemberTriggerHelper
@Author: Team SFO ( Prathyusha , Sravanthi)
@CreateDate: 29/07/2019
@Description: EDGE-98344:CampaignMemberTrigger to implement history tracking on campaign member.
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*******************************************************************************/
public without sharing class CampaignMemberTriggerHelper {
    // 19.10 EDGE-98344
    // @Author: Team SFO (Prathyusha , Sravanthi)
    //@Description : Inserts Campaign_Member_History__c records when campaign member record is edited.
    public void insertCampaignMemberHistoryCampMemEdit(list<CampaignMember> newCampaignMemberlist,list<CampaignMember> oldCampaignMemberlist,Map<Id,CampaignMember> oldCampaignMemberMap){
        try{
            list<Campaign_Member_History__c> campaignMemberHistoryList = new  list<Campaign_Member_History__c>();
            Schema.FieldSet fieldSet = Schema.SObjectType.CampaignMember.fieldSets.getMap().get('HistoryTracking');
            if(!newCampaignMemberlist.isEmpty() && !oldCampaignMemberlist.isEmpty() ){
                for(CampaignMember newcampMember: newCampaignMemberlist){
                    for(Schema.FieldSetMember fsMember : fieldSet.getFields()) {
                        String fieldName = fsMember.getFieldPath(); 
                        if(newcampMember.get(fieldname) != oldCampaignMemberMap.get(newcampMember.id).get(fieldname))
                        {Campaign_Member_History__c cmh = new Campaign_Member_History__c();   
                         cmh.Date__c = System.now();
                         cmh.Field__c = fieldName;
                         cmh.OwnerId = UserInfo.getUserId();
                         cmh.Old_Value__c = String.valueOf(oldCampaignMemberMap.get(newcampMember.id).get(fieldname)); 
                         cmh.New_Value__c = String.valueOf(newcampMember.get(fieldName));             
                         cmh.Lead__c = newcampMember.LeadId;
                         cmh.Contact__c = newcampMember.ContactId;
                         cmh.Campaign__c = newcampMember.CampaignId;
                         campaignMemberHistoryList.add(cmh); 
                        }
                    }
                    
                }
            } 
            if(campaignMemberHistoryList != null && !campaignMemberHistoryList.isEmpty()){
                insert campaignMemberHistoryList;
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->CampaignMemberTriggerHelper Class,insertCampaignMemberHistoryCampMemEdit Method'+ Ex.getMessage());
        }
    }
    
    // 19.10 EDGE-98344
    // @Author: Team SFO (Prathyusha , Sravanthi)
    //@Description : Inserts Campaign_Member_History__c records when campaign member record is Craeted.
    public void insertCampaignMemberHistoryCampMemCraeted(list<CampaignMember> newCampaignMemberlist,list<CampaignMember> oldCampaignMemberlist,Map<Id,CampaignMember> oldCampaignMemberMap){
        try{
            list<Campaign_Member_History__c> campaignMemberHistoryList = new  list<Campaign_Member_History__c>();
            if(newCampaignMemberlist != NULL ){  
                for(CampaignMember newcampMember: newCampaignMemberlist){
                    Campaign_Member_History__c cmh = new Campaign_Member_History__c();
                    cmh.Date__c = System.now();
                    cmh.Field__c = 'Created.';
                    cmh.OwnerId = UserInfo.getUserId();
                    cmh.Old_Value__c = '';
                    cmh.New_Value__c = '';
                    cmh.Lead__c = newcampMember.LeadId;
                    cmh.Contact__c = newcampMember.ContactId;
                    cmh.Campaign__c = newcampMember.CampaignId;
                    campaignMemberHistoryList.add(cmh);
                }
            }
            if(campaignMemberHistoryList != null && !campaignMemberHistoryList.isEmpty()){
                insert campaignMemberHistoryList;
            } 
        }
        catch(Exception Ex){
            system.debug('Exception:--->CampaignMemberTriggerHelper Class,insertCampaignMemberHistoryCampMemCraeted Method'+ Ex.getMessage());
        }
    }
    
    // 19.10 EDGE-98344
    // @Author:Team SFO ( Prathyusha , Sravanthi)
    //@Description : Inserts Campaign_Member_History__c records when campaign member record is deleted.
    public void insertCampaignMemberHistoryCampMemDeleted(list<CampaignMember> oldCampaignMemberlist){
        try{
            list<Campaign_Member_History__c> campaignMemberHistoryList = new  list<Campaign_Member_History__c>();
            if(oldCampaignMemberlist!=null){
                for(CampaignMember oldcampMember: oldCampaignMemberlist){
                    Campaign_Member_History__c cmh = new Campaign_Member_History__c();
                    cmh.Date__c = System.now();
                    cmh.Field__c = 'Deleted.';
                    cmh.OwnerId = UserInfo.getUserId();
                    cmh.Old_Value__c = '';
                    cmh.New_Value__c = '';
                    cmh.Lead__c = oldcampMember.LeadId;
                    cmh.Contact__c = oldcampMember.ContactId;
                    cmh.Campaign__c = oldcampMember.CampaignId;
                    campaignMemberHistoryList.add(cmh);
                }
            }
            if(campaignMemberHistoryList != null && !campaignMemberHistoryList.isEmpty()){
                insert campaignMemberHistoryList;
            }         
        }
        catch(Exception Ex){
            system.debug('Exception:--->CampaignMemberTriggerHelper Class,insertCampaignMemberHistoryCampMemDeleted Method'+ Ex.getMessage());
        }
    }
    
}