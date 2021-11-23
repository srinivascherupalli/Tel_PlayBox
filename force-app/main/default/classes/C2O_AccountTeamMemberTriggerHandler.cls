/********************************************************************************
* Class Name  : C2O_AccountTeamMemberTriggerHandler
* Description : DIGI-12760, Sprint 21.12
                This class is Handler Class to call the helper to execute the logic.   
* Created By  :  Sri (Team SFO) 

********************************************************************************/
public with sharing class C2O_AccountTeamMemberTriggerHandler extends SYS_TriggerHandler {
    // DECLARE GLOBAL VARIABLES     
    private Map<Id, AccountTeamMember> newAccTeamMemMap;   
    private Map<Id, AccountTeamMember> oldAccTeamMemMap; 
    private List<AccountTeamMember> newAccTeamMemList;
    private List<AccountTeamMember> oldAccTeamMemList;    
    
    
    public C2O_AccountTeamMemberTriggerHandler() {
        this.setHandlerName('C2O_AccountTeamMemberTriggerHandler');
        this.newAccTeamMemList = (List<AccountTeamMember>) Trigger.new;
        this.oldAccTeamMemList = (List<AccountTeamMember>) Trigger.old;
        this.newAccTeamMemMap = (Map<Id, AccountTeamMember>) Trigger.newMap;
        this.oldAccTeamMemMap = (Map<Id, AccountTeamMember>) Trigger.oldMap;
    }    
    
    /***************************************************************************************
* Method Name - beforeInsert
* Description - DIGI-12760, Sprint 21.12
                This method is used to call the before Insert operation on record.
****************************************************************************************/
    public override void beforeInsert(){             
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Account_Team_Member','triggerBeforeInsert')){
            C2O_AccountTeamMemberTriggerHelper.checkOpportunityApproverTeamMember(newAccTeamMemList);
        }
    }

    /***************************************************************************************
* Method Name - beforeUpdate
* Description - DIGI-12760, Sprint 21.12
                This method is used to call the before Update operation on record.
****************************************************************************************/
    public override void beforeUpdate(){             
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Account_Team_Member','triggerBeforeUpdate')){
            C2O_AccountTeamMemberTriggerHelper.checkOpportunityApproverTeamMember(newAccTeamMemList);
        }
    }
}