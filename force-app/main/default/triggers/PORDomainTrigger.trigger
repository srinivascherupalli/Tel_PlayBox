trigger PORDomainTrigger on Partner_of_Record_Domain__c (after update) {
   new PORDomainTriggerHandler(Partner_of_Record_Domain__c.sObjectType).run();
}