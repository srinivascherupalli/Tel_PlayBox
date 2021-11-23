trigger C2O_OrderTrigger on csord__Order__c (before insert, before update,after insert, after update) {   
    /* 
    if(!FeatureEligibilityChecker.determineFeatureEligiblity('BypassLogic', 'False') && Trigger.isInsert){
    BypassTrigger.bypassTriggerAtOG = true;
       }
    */
    if(BypassTrigger.bypassTriggerAtOG == true && !Trigger.isInsert){  /**the insert condition has to be removed once the insert event related code is moved to observer **/ 
        return;
    }
    else{
        new C2O_OrderTriggerHandler().run();
    }
}