/*************************************************************************************************
Name : OpportunityTrigger(renamed CancelBasketsForClosedLost trigger)
Description : trigger Used to set the basket status to cancelled once the opportunity is set to 
Closed Lost
Also added below for EDGE-3570
trigger used to set synced basket status to submitted once the opportunity is set to
Closed Won
Code added for EDGE-6590 and trigger renamed
code added for EDGE-11862
@Last Modified      : Modified as part of EDGE-205345
***************************************************************************************************/
trigger OpportunityTrigger on Opportunity (Before Insert, Before Update,After Insert, After Update) {
    if(EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger')){
        return;
    }  
    Set<Id> ClosedLostDealOppIdSet = new Set<Id>();  
    Set<Id> closedLostOppIdSet = new Set<Id>();
    Set<Id> closedWonOppIdSet = new Set<Id>();
    Set<Id> developOppIdSet = new Set<Id>();
    Set<Id> closedWonOrProposeIdNonModularSet = new Set<Id>();
    Set<Id> oppIdSet = new Set<Id>();
        
    for(Opportunity opp: trigger.New){
      //get the opp ids which are moved to Closed Lost and pricing method as 'delegated Pricing' 
        if(opp.stageName == 'Closed Lost' && opp.Pricing_Method__c == 'Delegated Pricing')          //Modified as part of EDGE-205345
            ClosedLostDealOppIdSet.add(opp.id);
        //get the opp ids which are moved to Closed Lost
        if(opp.stageName == 'Closed Lost')
            closedLostOppIdSet.add(opp.id);
        //get the opp ids which are moved to Closed Won
        if(opp.stageName == 'Closed Won')
            closedWonOppIdSet.add(opp.id);
        //get the opp ids which are moved to Develop
        if(opp.stageName == 'Develop'&& opp.Pricing_Method__c == 'Delegated Pricing')//Modified by Rishabh Dhamu
            developOppIdSet.add(opp.id);
    }
    BsktStageUpdateForClosedOppsTrigHandler  can = new BsktStageUpdateForClosedOppsTrigHandler();
    if(trigger.isBefore){
        //before Closing the opp Won, checking if atleast one basket is synced and enriched
        if(!closedWonOppIdSet.isEmpty())
        can.validateClosedWon(closedWonOppIdSet,trigger.New);
    
        if(!developOppIdSet.isEmpty())
        can.validateDevelopOppty(developOppIdSet,trigger.New);
    
     /* if(!closedLostOppIdSet.isEmpty())
        can.cancelDPRStage(closedLostOppIdSet); */
    }

    if(trigger.isAfter){
        /*
        for(Opportunity opp :trigger.new){
            oppIdSet.add(opp.id);
        }  
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem where opportunityId IN: oppIdSet];
        
        //after Closing the opp updating the basket status accordingly
        //before changing the Opportunity Stage to Propose or Closed Won, Syncing the basket for Non- Modular
        for(Opportunity opp : trigger.new){   
            if(trigger.OldMap != null && trigger.OldMap.get(opp.id)!= null){
                if((opp.stageName == 'Develop' && trigger.OldMap.get(opp.id).stageName!= 'Develop') || (opp.stageName == 'Propose' && trigger.OldMap.get(opp.id).stageName!= 'Propose') ||(opp.stageName == 'Closed Won' && trigger.OldMap.get(opp.id).stageName!= 'Closed Won' && oliList.size()==0))
                {
                    if(opp.Product_Type__c == 'Non Modular')
                        closedWonOrProposeIdNonModularSet.add(opp.id);
                    }    
                }
            
        }
        if(!closedWonOrProposeIdNonModularSet.isEmpty()){
            system.debug(LoggingLevel.INFO, 'OpportunityTrigger.sync basket');
            SyncBasketOnClosedWonAndProposeOppty sy = new SyncBasketOnClosedWonAndProposeOppty();
            sy.synctheValidBasket(closedWonOrProposeIdNonModularSet,trigger.New);
        }
        */
        can.cancelBasketStage(closedLostOppIdSet);
        
        if(!closedWonOppIdSet.isEmpty())
        can.submitBasketStage(closedWonOppIdSet);
     
     //Modified as part of EDGE-205345
     if(!ClosedLostDealOppIdSet.isEmpty())
        can.cancelDPRStage(ClosedLostDealOppIdSet); 
    }
    
    
    OpportunityTriggerHandler handler=new OpportunityTriggerHandler();
    if(trigger.isBefore && trigger.isInsert){
        handler.OnBeforeInsert(Trigger.New);
    }
    if(trigger.isAfter && Trigger.isInsert){
        handler.onAfterInsert(Trigger.New); 
    }   
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
        handler.onBeforeUpdate(Trigger.new,Trigger.newMap,Trigger.Old,Trigger.OldMap);      
    }
    
    if(trigger.isAfter && Trigger.isUpdate){
        handler.OnAfterUpdate(Trigger.Old,Trigger.OldMap,Trigger.new,Trigger.newMap); 
                
    }
}