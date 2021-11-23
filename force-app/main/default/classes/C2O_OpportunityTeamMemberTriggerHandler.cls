/********************************************************************************
* Class Name  : C2O_OpportunityTeamMemberTriggerHandler
* Description : This class is Handler Class to call the helper to execute the logic.   
* Created By  : Uday Dunna 
* Change Log  : Created
********************************************************************************/
public with sharing class C2O_OpportunityTeamMemberTriggerHandler extends SYS_TriggerHandler {
    
    // DECLARE GLOBAL VARIABLES     
    private Map<Id, OpportunityTeamMember> newOppTeamMemMap;   
    private Map<Id, OpportunityTeamMember> oldOppTeamMemMap; 
    private List<OpportunityTeamMember> newOppTeamMemList;
    private List<OpportunityTeamMember> oldOppTeamMemList;    
    
    
    public C2O_OpportunityTeamMemberTriggerHandler() {
        this.setHandlerName('C2O_OpportunityTeamMemberTriggerHandler');
        this.newOppTeamMemList = (List<OpportunityTeamMember>) Trigger.new;
        this.oldOppTeamMemList = (List<OpportunityTeamMember>) Trigger.old;
        this.newOppTeamMemMap = (Map<Id, OpportunityTeamMember>) Trigger.newMap;
        this.oldOppTeamMemMap = (Map<Id, OpportunityTeamMember>) Trigger.oldMap;
    }    
    
    /***************************************************************************************
* Method Name - beforeInsert
* Description - This method is used to call the before Insert operation on record.
****************************************************************************************/
    public override void beforeInsert(){             
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Opportunity_Team_Member','triggerBeforeInsert')){
            List<OpportunityTeamMember> oppTeamMemList = new List<OpportunityTeamMember>();
            for(OpportunityTeamMember otm: (List<OpportunityTeamMember>) Trigger.new){
                if(otm.addToTeamMemberCheck__c==FALSE){
                    oppTeamMemList.add(otm);
                    System.debug('oppTeamMemList::'+oppTeamMemList);
                }
            }
            
            if(!oppTeamMemList.isEmpty() && oppTeamMemList.size() > 0){
                C2O_OpportunityTeamMemberTriggerHelper.offShoreRestrictedRolAndAccountCheck(oppTeamMemList);
            }               
        }  
    }     
    
    /***************************************************************************************
    * Method Name - afterInsert
    * Description - This method is used to call the after Insert operation on record.
    ****************************************************************************************/
    public override void afterInsert() { 
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Opportunity_Team_Member','triggerAfterInsert')){
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOppNewMember');
            Map<Id,String> finalOppUpdate = new Map<Id,String>();
            List<OpportunityTeamMember> oppTeamMemberRecsToInsertList = new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> oppTeamMemberChatterRecsToInsertList = new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> addCaseTeamMemberFromOppTeamList = new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> prmAddPermissionSetToAccountOwnerList = new List<OpportunityTeamMember>();
            for(OpportunityTeamMember oppTeamMem : [Select Id, Opportunity.Maxim_Sync_Indicator__c,
                                                    TeamMemberRole,OpportunityId,
                                                    UserId,isTeamMemberReinsert__c,
                                                    Opportunity.RecordType.DeveloperName,
                                                    Opportunity.CreatedBy.Profile.Name,
                                                    Opportunity.Owner.Profile.Name,
                                                    isRecordCreatedThroughBatchClass__c,
                                                    Opportunity.Name,
                                                    Opportunity.CIDN__c,
                                                    Opportunity.Opportunity_Number__c,
                                                    Opportunity.Archetype__c,
                                                    Opportunity.LastModifiedDate,
                                                    Opportunity.AccountId,
                                                    Opportunity.Owner.Email,
                                                    Opportunity.Account.LastModifiedDate,
                                                    Opportunity.Owner.FederationIdentifier,
                                                    Opportunity.Account.Owner.FederationIdentifier,
                                                    Opportunity.Account.Owner.Email,
                                                    Opportunity.Account.Name ,
                                                    User.FederationIdentifier,
                                                    User.Email,OpportunityAccessLevel,
                                                    LastModifiedDate,
                                                    Opportunity.Account.Customer_ID__c
                                                    From OpportunityTeamMember Where Id IN :newOppTeamMemList]){
                if(oppTeamMem.Opportunity.Maxim_Sync_Indicator__c=='Yes' && hasCustomPermissionSet==True){
                    oppTeamMemberRecsToInsertList.add(oppTeamMem);
                }
                if(oppTeamMem.TeamMemberRole == Label.Telstra_Purple && !finalOppUpdate.containsKey(oppTeamMem.OpportunityId)){
                    finalOppUpdate.put(oppTeamMem.OpportunityId,Label.Telstra_Purple);
                }
                if(oppTeamMem.UserId != null && !oppTeamMem.isTeamMemberReinsert__c){
                    oppTeamMemberChatterRecsToInsertList.add(oppTeamMem);
                }
                if(((oppTeamMem.Opportunity.CreatedBy.Profile.Name == 'PRM Community User - Australia' || oppTeamMem.Opportunity.CreatedBy.Profile.Name == 'PRM Admin - Australia') && oppTeamMem.isTeamMemberReinsert__c == FALSE)
                   || (((oppTeamMem.Opportunity.Owner.Profile.Name == 'PRM Community User - Australia' || oppTeamMem.Opportunity.Owner.Profile.Name == 'PRM Admin - Australia') && oppTeamMem.isTeamMemberReinsert__c == FALSE))){                 
                       prmAddPermissionSetToAccountOwnerList.add(oppTeamMem);
                 } 
                if(oppTeamMem.UserId != null &&
                   oppTeamMem.Opportunity.RecordTypeId != null &&
                   (System.Label.PreSalesSolutionOppRecordTypeList == oppTeamMem.Opportunity.RecordType.DeveloperName) &&
                   !oppTeamMem.isTeamMemberReinsert__c &&
                   !oppTeamMem.isRecordCreatedThroughBatchClass__c){ 
                    addCaseTeamMemberFromOppTeamList.add(oppTeamMem);
                       System.debug('addCaseTeamMemberFromOppTeamList::'+addCaseTeamMemberFromOppTeamList);
                }
                                                        
            }
            if(!oppTeamMemberRecsToInsertList.isEmpty() && oppTeamMemberRecsToInsertList.size() > 0){
                C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemCreation(oppTeamMemberRecsToInsertList);
            }
            if(!oppTeamMemberChatterRecsToInsertList.isEmpty() && oppTeamMemberChatterRecsToInsertList.size() > 0){
                C2O_OpportunityTeamMemberTriggerHelper.createPostForNewOpportunityTeamMember(oppTeamMemberChatterRecsToInsertList);
            }
            if(!addCaseTeamMemberFromOppTeamList.isEmpty() && addCaseTeamMemberFromOppTeamList.size() > 0){
                C2O_OpportunityTeamMemberTriggerHelper.addCaseTeamMemberFromOppTeam(addCaseTeamMemberFromOppTeamList);
            }
            if(!prmAddPermissionSetToAccountOwnerList.isEmpty() && prmAddPermissionSetToAccountOwnerList.size() > 0){
                C2O_OpportunityTeamMemberTriggerHelper.prmAddPermissionSetToAccountOwner(prmAddPermissionSetToAccountOwnerList);
            }
            if(!finalOppUpdate.isEmpty()){
                C2O_OpportunityTeamRoleTriggerHelper.updateOppIndividualTelstra(finalOppUpdate);
            }
            
        }
    }
    
    /***************************************************************************************
* Method Name - afterUpdate
* Description - This method is used to call the after Update operation on record.
****************************************************************************************/
    public override void afterUpdate(){ 
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Opportunity_Team_Member','triggerAfterUpdate')){ 
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOppUpdateMember');
            set<Id> oppIdSet = new set<Id>();//Old team role is not purple and new team role is purple
            set<Id> oppIdSet1 = new set<Id>();//Old team role is  purple and new team role is not purple
            map<Id,String> finalOppUpdate = new map<Id,String>();
            List<OpportunityTeamMember> oppTeamMemberRecsToUpdateList = new List<OpportunityTeamMember>();
            for(OpportunityTeamMember oppTeam : (List<OpportunityTeamMember>) Trigger.new){
                String oldTeamRole=oldOppTeamMemMap.get(oppTeam.Id).TeamMemberRole;
                if(oppTeam.Opportunity.Maxim_Sync_Indicator__c != oldOppTeamMemMap.get(oppTeam.Id).Opportunity.Maxim_Sync_Indicator__c && oppTeam.Opportunity.Maxim_Sync_Indicator__c=='Yes' && hasCustomPermissionSet==True){
                    oppTeamMemberRecsToUpdateList.add(oppTeam);
                }
                if(oppTeam.TeamMemberRole != oldTeamRole){
                    if(oldTeamRole != Label.Telstra_Purple && oppTeam.TeamMemberRole == Label.Telstra_Purple){
                        oppIdSet.add(oppTeam.OpportunityId);
                        finalOppUpdate.put(oppTeam.OpportunityId,Label.Telstra_Purple);
                    } else if(oldTeamRole == Label.Telstra_Purple && oppTeam.TeamMemberRole != Label.Telstra_Purple){ 
                        oppIdSet1.add(oppTeam.OpportunityId);
                    }  
                }
            } 
            
            if(!oppTeamMemberRecsToUpdateList.isEmpty() && oppTeamMemberRecsToUpdateList.size() > 0 && !oldOppTeamMemMap.isEmpty()){
                C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemUpdate(oppTeamMemberRecsToUpdateList,oldOppTeamMemMap);
            }  
            if((oppIdSet != null && !finalOppUpdate.isEmpty()) || oppIdSet1 != null){
                C2O_OpportunityTeamRoleTriggerHelper.oppIdCheck(oppIdSet, oppIdSet1, finalOppUpdate);
            }            
        }
    }
    
/***************************************************************************************
* Method Name - onAfterDelete
* Description - This method is used to call the after Delete operation on record.
****************************************************************************************/
    public override void afterDelete(){ 
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Opportunity_Team_Member','triggerAfterDelete')){ 
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOppRemoveMember');
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
            List<OpportunityTeamMember> listOppsTM1=new List<OpportunityTeamMember>();
            Set<Id> oppIdPurple = new Set<Id>();
            for(OpportunityTeamMember oppTM: oldOppTeamMemMap.values()){
                if(oppTM.Opportunity.Maxim_Sync_Indicator__c == 'Yes' && hasCustomPermissionSet==True){
                    listOppsTM1.add(oppTM);
                    oppMap.put(oppTM.id,oppTM.Opportunity); 
                } 
                if(oppTM.TeamMemberRole == Label.Telstra_Purple){
                    oppIdPurple.add(oppTM.OpportunityId);
                }
            }
            
            if(!listOppsTM1.isEmpty() && !oppMap.isEmpty()){
                C2O_OpportunityTeamMemberTriggerHelper.createSPEventOnOppTeamMemRemove(listOppsTM1,oppMap);
            }
            
            if(oppIdPurple != null){ 
                C2O_OpportunityTeamRoleTriggerHelper.updateOppOnTeamMemDeletePurpleRole(oppIdPurple);
            }
        }
    }
}