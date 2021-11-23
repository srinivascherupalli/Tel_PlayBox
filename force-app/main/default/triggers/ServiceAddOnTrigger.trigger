/******************************************************************
Story ID     : EDGE-206201
Description  : Logic to populate Account__c field based on CIDN
Test Class   : ServiceAddOnTriggerTest
Created Data : 16-Mar-2021
*******************************************************************/


trigger ServiceAddOnTrigger on Service_Add_On__c (before insert) {
    ServiceAddOnTriggerHandler saHandler = new ServiceAddOnTriggerHandler();
    
    if(Trigger.isInsert && Trigger.isBefore)
    {
        ServiceAddOnTriggerHandler.populateAccountId(Trigger.new);      
    }
    
}