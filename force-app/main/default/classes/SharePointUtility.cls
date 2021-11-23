/*****************************************************************************
@Name: SharePointUtility
@Author: Murali Nunna
@CreateDate: 09/08/2018
@Description: This Class has logic for creating JSON String format of Account,Opportunity,OpportunityTeamMember records Information
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*******************************************************************************/
public without sharing class SharePointUtility {
    private static List<SharePointEventCode__mdt> sharepointEventList=[SELECT EventCode__c,DeveloperName,Id,
                                                                       ObjectName__c FROM SharePointEventCode__mdt];
    public String getAccountPayload(Account acc){ 
        SharePointMainPayload spu=new SharePointMainPayload();
        return JSON.serializePretty(spu.getAccountPayload(acc));
    }
    public String getAccountMemberPayload(Account acc,User userInfo){ 
        SharePointMainPayload spu=new SharePointMainPayload();
        return JSON.serializePretty(spu.getAccRequestAccessPayload(acc,userInfo));
    }
    public String getOpportunityPayload(Opportunity opp){
        SharePointMainPayload spu=new SharePointMainPayload();
        return JSON.serializePretty(spu.getOpportunityPayload(opp));
    }
    public String getOpportuntityMemberPayload(Opportunity oppMem, User userInfo){
        SharePointMainPayload spu=new SharePointMainPayload();
        return JSON.serializePretty(spu.getOppRequestAccessPayload(oppMem,userInfo));
    }
    public String getNewOpportunityTeamMemPayload(List<OpportunityTeamMember> oppTeamMem){
        SharePointMainPayload spu=new SharePointMainPayload();
        return JSON.serializePretty(spu.getOpportunityTeamMemberPayloadCreate(oppTeamMem,null));
    }
    public String getUpdateOpportunityTeamMemPayload(List<OpportunityTeamMember> oppTeamMem,Map<Id,OpportunityTeamMember> oppTeamMemOld){
        SharePointMainPayload spu=new SharePointMainPayload();
        return JSON.serializePretty(spu.getOpportunityTeamMemberPayloadUpdate(oppTeamMem,oppTeamMemOld));
    }
    public String getRemoveOpportunityTeamMemPayload(List<OpportunityTeamMember> oppTeamMem,Map<Id,Opportunity> oppMap){
        SharePointMainPayload spu=new SharePointMainPayload();
        return JSON.serializePretty(spu.getOpportunityTeamMemberPayloadRemove(oppTeamMem,oppMap));
    }
    public String getSharepointEventCode(String SharePointEventCodeName){
        String eventCode=null;
        for(SharePointEventCode__mdt spEvnt:sharepointEventList){
            if(spEvnt.DeveloperName==SharePointEventCodeName && SharePointEventCodeName.equals(spEvnt.DeveloperName)){
                eventCode=spEvnt.EventCode__c;
                break;
            }
        }
        return eventCode;
    }
    
    public SharePointEvent__c createSharePointEvent(String SharePointEventCodeName,String payLoad){
        SharePointEvent__c spe = new SharePointEvent__c();
        spe.Event_Code__c = getSharepointEventCode(SharePointEventCodeName);
        if(null!=payLoad){
            JSONParser parser = JSON.createParser(payLoad);
            SharePointMainPayload.SharepointPayLoad inv = (SharePointMainPayload.SharepointPayLoad)parser.readValueAs(SharePointMainPayload.SharepointPayLoad.class);
            if(null!=inv.AccountInfo.CustomerID && !String.isEmpty(inv.AccountInfo.CustomerID)){
                spe.Related_Account__c=inv.AccountInfo.CustomerID;
            }
            if(inv.AccountInfo.OpportunityInfo!=null){
                if(null!=inv.AccountInfo.OpportunityInfo.OpportunityID && !String.isEmpty(inv.AccountInfo.OpportunityInfo.OpportunityID)){
                    spe.Related_Opportunity__c=inv.AccountInfo.OpportunityInfo.OpportunityID;
                }
            }
        }
        spe.Event_Payload__c=payLoad;
        return spe;
    }
}