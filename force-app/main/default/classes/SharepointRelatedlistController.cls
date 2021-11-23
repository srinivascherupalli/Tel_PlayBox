/*
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

public with sharing class SharepointRelatedlistController {
    
    @AuraEnabled
    public static Opportunity getOppRecData(Id opportunityId) {
        
        Opportunity opp = [SELECT Id, SharePoint_Folder_Link__c, Name, OwnerId,AccountId,Account.OwnerId,CIDN__c
                           FROM Opportunity
                           WHERE Id = :opportunityId];
        return opp;
        
    }
    @AuraEnabled
    public static user fetchUser(){
        // query current user information  
        User oUser = [select id 
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;    
    }
    
    @AuraEnabled
    public static SharePointEvent__c createOppRecEventSync(Id opportunityId) {
        
        SharePointUtility spu=new SharePointUtility();
        list<SharePointEvent__c> speList = new list<SharePointEvent__c>();
        try{
            List<Opportunity> listOpps=[Select Id,Name,CIDN__c,Opportunity_Number__c,Archetype__c,LastModifiedDate,AccountId,Maxim_Sync_Indicator__c,Owner.FederationIdentifier,Owner.Email,Account.LastModifiedDate,Account.Customer_ID__c,Account.Owner.FederationIdentifier,Account.Owner.Email,Account.Name From Opportunity Where Id  = :opportunityId ];
            for(Opportunity opp : listOpps){
                SharePointMainPayload sopl=new SharePointMainPayload();
                SharePointEvent__c spe = spu.createSharePointEvent('SPOpportunityTeamMemberSync',spu.getOpportunityPayload(opp));
                speList.add(spe);
            }
            if(!speList.isEmpty() && speList.size()>0){
                insert speList;
            }
        }catch(Exception Ex){
            system.debug('Exception:--->SharepointRelatedlistController Class,createOppRecEventSync Method'+ Ex.getMessage());
        }
        return speList.get(0);
        
    }
    
    
    @AuraEnabled
    public static SharePointEvent__c createOppRequestAccess(Id opportunityId) {
        
        SharePointUtility spu=new SharePointUtility();
        list<SharePointEvent__c> speList = new list<SharePointEvent__c>();
        try{
            List<Opportunity> listOpps=[Select Id,Name,CIDN__c,Opportunity_Number__c,Archetype__c,LastModifiedDate,AccountId,Maxim_Sync_Indicator__c,Owner.FederationIdentifier,Owner.Email,Account.LastModifiedDate,Account.Customer_ID__c,Account.Owner.FederationIdentifier,Account.Owner.Email,Account.Name From Opportunity Where Id  = :opportunityId ];
            user userInfo= [select id,FederationIdentifier,email from user where id =: userinfo.getUserId()];
            for(Opportunity opp : listOpps){
                SharePointMainPayload sopl=new SharePointMainPayload();
                SharePointEvent__c spe = spu.createSharePointEvent('SPOpportunityRequestAccess',spu.getOpportuntityMemberPayload(opp,userInfo));
                speList.add(spe);
            }
            if(!speList.isEmpty() && speList.size()>0){
                insert speList;
            }
        }catch(Exception Ex){
            system.debug('Exception:--->SharepointRelatedlistController Class,createOppRequestAccess Method'+ Ex.getMessage());
        }
        return speList.get(0);
        
    }
    
}