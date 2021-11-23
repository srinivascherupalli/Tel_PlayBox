/*****************************************************************************
@Name: OpportunityTriggerHandler
@Author: SFO Team 
@CreateDate: 09/08/2018
@Description: 
Updated : 16/03/2020 - Hawaii - P2OB-5047 - Calling OpportunityTriggerPRMHelper methods
Updated : 22/05/2020 - Hawaii - P2OB-6584 - Calling Cust Auth Rep Details in Chatter post method
Updated : 15/06/2020 - SFO - P2OB-6727 - Calling CustomerRiskScore Method.
Updated : 11/11/2020 - SFO - P2OB-7883 - Commented method calling Code as part of P2OB-7883 Sprint 20.15 
as it is replaced with Funnel Scorecard Lightning component functionality 

@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 20/04/2021 21.06 P2OB-13967
@Last Modified      : 12/08/2021 21.11 DIGI-4646 Reopen Opportunities
@Last Modified      : 
No.       Developer Name        Date            Story Description 
01.       Sravanthi         01/11/2021     Sprint 21.15 - DIGI-24459  invoked sendNotificationToPartnerOppCurrentAppr() in afterUpdate to send chatter notifications to approvers

*******************************************************************************/
public without sharing class OpportunityTriggerHandler {
    public OpportunityTriggerHelper oppTriggerHelper=new OpportunityTriggerHelper();
    public static boolean isoppoTypeUpdated=true;
    public OpportunityTriggerHandler(){
    }
    
    public void onBeforeInsert(List<Opportunity> newOpps){
        //this is to set recordtype level defualt values for opp on create
        oppTriggerHelper.assignDefaultValuesOnCreate(newOpps);
        
        // 18.11 Edge-34281,15883 Start
        // @Author: Murali Nunna
        //@CreateDate: 09/08/2018
        
        oppTriggerHelper.onBeforeInsert(newOpps);
        
        //@Description: To stop updation of Opportunity of Custom Recordtype with Null Proposal due Date
        //@Author: Mahaboob Subani    
        OppProposalDueDateTrigger_Handler OppProposalTriggerHandler=new OppProposalDueDateTrigger_Handler();
        OppProposalTriggerHandler.OpportunityProposalCheck(trigger.new);
        //Commented below Method calling as part of P2OB-13640 Sprint 21.05
        //oppTriggerHelper.customerRiskScore(trigger.new,null,null,null); //SFO - P2OB-6727 - Calling CustomerRiskScore Method in OpportunityTriggerHelper 
        OpportunityTriggernewhandler triggerNewHandler = new OpportunityTriggernewhandler();
        triggerNewHandler.onBeforeInsert(newOpps);//EDGE-151595
        if(isoppoTypeUpdated){
            oppTriggerHelper.updateOpportunityTypeRestrict(newOpps);//EDGE-186496:Enabling of a new Opportunity type for migration orders 
            isoppoTypeUpdated=false;     
        }  
        
    }
    
    public void onBeforeUpdate(List<Opportunity> newOpps,Map<Id,Opportunity> newMapOpps,List<Opportunity> oldOpps,Map<Id,Opportunity> oldMapOpps){
        
        //this is to set recordtype level defualt values for opp on create
        oppTriggerHelper.assignDefaultValuesOnUpdate(newOpps, oldMapOpps);
        
        //OpptyTriggerHelper opptyHelper = new OpptyTriggerHelper();
        OpportunityTriggerHelper.updateBasket(newMapOpps,oldMapOpps);// PS-13703 Added to test basket Status update
        //EDGE-198050. Kalashree borgaonkar. Fix for Migration Profile
        oppTriggerHelper.setTypeForMigrationOnUpdate( newMapOpps, oldMapOpps);
        oppTriggerHelper.opprtunityValidationNoContactRoles(newMapOpps,oldMapOpps,newOpps);
        //@Description: To stop updation of Opportunity of Custom Recordtype with Null Proposal due Date
        //@Author: Mahaboob Subani
        OppProposalDueDateTrigger_Handler OppProposalTriggerHandler=new OppProposalDueDateTrigger_Handler();
        OppProposalTriggerHandler.OpportunityProposalCheck(newOpps);
        //Sprint 19.03 Edge-63675, SFO Team : Subani Shaik
        oppTriggerHelper.offShoreRestrictedRolAndAccountCheckOnOpportunity(newOpps,oldMapOpps);
        //It's part of Team Orlando
        OpportunityTriggernewhandler handler = new OpportunityTriggernewhandler();
        handler.OnBeforeUpdate(newMapOpps,oldMapOpps,newOpps);
        // P2OB-5047 - Hawaii - prepare Opportunity Team Member List
        OpportunityTriggerPRMHelper.prepareOpportunityTeamMemberList(newOpps, oldMapOpps);
        oppTriggerHelper.customerRiskScore(newOpps,newMapOpps,oldOpps,oldMapOpps);  //SFO - P2OB-6727 - Calling CustomerRiskScore Method in OpportunityTriggerHelper 
        OpportunityTriggerHelper.sendCustomNotification(newOpps, oldMapOpps);//P2OB-13967 
        //DIGI:4646 Sprint 21.11 Setting opp values when opp is reopened in same month
        oppTriggerHelper.setReopenValues(newMapOpps,oldMapOpps);
        
    }
    
    public void onAfterInsert(List<Opportunity> newOpps){
        // 18.11 Edge-34281,15883 Start
        // @Author: Murali Nunna
        //@CreateDate: 09/08/2018
        oppTriggerHelper.createSharePointEventOnOppCreation(newOpps); 
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Opportunity_Notifications','sendNotificationToOppAppr')){
            //DIGI:6047
            oppTriggerHelper.sendNotificationToOppAppr(newOpps);
        }

    }
    
    public void onAfterUpdate(List<Opportunity> oldOpps,Map<Id,Opportunity> oldMapOpps,List<Opportunity> newOpps,Map<Id,Opportunity> newMapOpps){
        // 18.11 Edge-34281,15883 Start
        // @Author: Murali Nunna
        //@CreateDate: 09/08/2018
        oppTriggerHelper.updateSharePointEventOnOppCreation(newMapOpps,oldMapOpps);
        // P2OB-5047 - Hawaii - prepare Opportunity Team Member List 
        OpportunityTriggerPRMHelper.reinsertOpportunityTeamMembers(newOpps, oldMapOpps); 

        // DIGI-18800
        OpportunityTriggerPRMHelper oppIns = new OpportunityTriggerPRMHelper();
        oppIns.createPlatformEvents(newOpps);

        // P2OB-6584 - Hawaii - Calling Cust Auth Rep Details in Chatter post method
        OpportunityTriggerPRMHelper.postCustRepChatter(newOpps, oldMapOpps);
        //Added as part of EDGE-204335
        BsktStageUpdateForClosedOppsTrigHandler bsktStageHandler = new BsktStageUpdateForClosedOppsTrigHandler();   
        
        bsktStageHandler.updateFAAndDealStatus(newOpps);
        
        //DIGI:4646 Sprint 21.11 Sending chatter to requestor when opp has been reopened
        oppTriggerHelper.sendChatterToRequestor(newMapOpps,oldMapOpps);
        //DIGI-24459 Sprint 21.15 Sending chatter to approvers when opp has been requested for closure from partner portal.
		oppTriggerHelper.sendNotificationToPartnerOppCurrentAppr(newMapOpps,oldMapOpps);
        /******************************************************************************************/
        //@description: Order Generation when OnS setting is configured to generate order manually
        //@Test: OrderBifurcationFramework_Test
        /******************************************************************************************/
        orderGenrationHelper.orderGenerationDecision(newOpps, oldMapOpps);
         
    }
  }