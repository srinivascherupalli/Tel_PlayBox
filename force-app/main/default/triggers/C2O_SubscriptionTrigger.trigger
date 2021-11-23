/********************************************************************************
* Trigger Name  : C2O_SubscriptionTrigger 
* Description : Trigger on csord__Subscription__c object
* Created By  : Sudheendra
* Change Log  : 06 May 2021 - Created 
* 27/09/2021 - Added BypassTrigger.incompleteOrderCounter check.
********************************************************************************/

trigger C2O_SubscriptionTrigger on csord__Subscription__c (before insert, before update,after insert, after update) {
    if(EnvironmentalSettings.isTriggerDisabled('C2O_SubscriptionTrigger')){
        return;
    }  
    if(!(trigger.isInsert && trigger.isBefore) && !BypassTrigger.isTriggeredByIncompleteOrder && BypassTrigger.incompleteOrderCounter == 0 && (!FeatureEligibilityChecker.determineFeatureEligiblity('BypassLogic', 'Old') || BypassTrigger.isRunningTestCheck)){            
        Integer inCompleteOrder = [SELECT COUNT() FROM csord__Subscription__c WHERE (Id = NULL OR Id IN:trigger.new) AND (csord__Order__c = NULL OR (csord__Order__c != NULL AND (csord__Order__r.csord__Status2__c = 'Incomplete' OR csord__Order__r.csord__Status2__c = '')))];
        BypassTrigger.incompleteOrderCounter += 1; 
        if(inCompleteOrder > 0){
            BypassTrigger.isTriggeredByIncompleteOrder = True;
        }
    }
    if( !Trigger.isInsert && BypassTrigger.isTriggeredByIncompleteOrder ){ /**the insert condition has to be removed once the insert event related code is moved to observer **/  
        return;      
    }else{   
        new C2O_SubscriptionTriggerHandler().run();
        if(Trigger.newMap != null){
            CSPOFA.Events.emit('update', Trigger.newMap.keySet());
        }
    }
}