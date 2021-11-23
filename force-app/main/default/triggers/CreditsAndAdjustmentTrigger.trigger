/*
 * AUTHOR : Vamshi
 * TEAM: Napier
 * DESCRIPTION : This Trigger is invoked based on actions on Credit and adjustment Object. Trigger Framework is used.
 * Please refer class NapierTeamOneFundTriggerHandler for more details.
 * EDGE-135560
 ******************************************************** CHANGE LOG ********************************************************
 * SL.No    Name            Date            Description
 * 1.       Pooja Bhat      20/July/2021    EDGE-228125:Added after undelete trigger event
 * 2.       Shishir Pareek  04/Aug/2021     DIGI-      : Refactored Trigger according to new framework
*/
trigger CreditsAndAdjustmentTrigger on Credits_and_Adjustments__c (after undelete, after delete, after insert, after update, before delete, before insert, before update) {
    FINAL String CREDITS_AND_ADJUSTMENTS_OBJ_NAME = 'Credits_and_Adjustments__c';
    new CreditAndAdjustmentTriggerHandler(CREDITS_AND_ADJUSTMENTS_OBJ_NAME).run();
}