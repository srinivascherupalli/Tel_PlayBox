trigger SYS_OpportunityTrigger on Opportunity (before insert, before update,after insert, after update) {
   
    new C2O_OpportunityTriggerHandler().run();
    
    
}