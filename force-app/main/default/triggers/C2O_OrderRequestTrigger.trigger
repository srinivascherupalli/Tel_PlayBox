trigger C2O_OrderRequestTrigger on csord__Order_Request__c (before insert, before update,after insert, after update) {
    
    if((!FeatureEligibilityChecker.determineFeatureEligiblity('BypassLogic', 'Old')) || BypassTrigger.isRunningTestCheck){
        BypassTrigger.bypassTriggerAtOG = true;
    }
    if(BypassTrigger.bypassTriggerAtOG == true){
        return;
    }
    
}