trigger DPRSyncwithOpportunityTrigger on Delegated_Pricing_Request__c (before update, after update) {
 if(!DprTriggerhelper.BlockDprTrigger){     
       fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
 } 
}