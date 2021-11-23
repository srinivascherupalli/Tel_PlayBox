trigger SharePointEventTrigger on SharePointEvent__c (after delete, after insert, after update, before delete, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
}