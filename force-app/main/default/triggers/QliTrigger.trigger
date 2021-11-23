/********************************************************************************
* Class Name  : C2O_ProductBasketTrigger
* Description : C2O_ProductBasketTrigger executes logic on product configuration on before insert/update & after insert/update.   
* Created By  : Uday Dunna 
* Change Log  : Created
********************************************************************************/
trigger QliTrigger on Queried_Line_Item__c (before insert,before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert && FeatureEligibilityChecker.determineFeatureEligiblity('QLiTrigger','beforeInsert')){
            QliTriggerHandler.beforeInsert(Trigger.new);
        }
    }
}