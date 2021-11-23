/*
 * AUTHOR : Anil,Tejes
 * TEAM: Napier
 * DESCRIPTION : This Trigger is invoked based on actions on OneFund Object. Trigger Framework is used.
 * Please refer class NapierTeamOneFundTriggerHandler for more details.
 * EDGE-113060, EDGE-112655
*/
trigger OneFundTrigger on OneFund__c (after delete, after insert, after update, before delete, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
}