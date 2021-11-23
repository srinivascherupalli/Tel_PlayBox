/********************************************************************************
* Class Name  : C2O_ProductBasketTrigger
* Description : C2O_ProductBasketTrigger executes logic on product configuration on before insert/update & after insert/update.   
* Created By  : Uday Dunna 
* Change Log  : Created
* Activated by Eureka - 02/09/2021
********************************************************************************/
trigger C2O_ProductBasketTrigger on cscfga__Product_Basket__c (before insert,before update,after insert,after update) {
    if(EnvironmentalSettings.isTriggerDisabled('C2O_ProductBasketTrigger')){
        return;
    } 
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            C2O_ProductBasketTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            C2O_ProductBasketTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            C2O_ProductBasketTriggerHandler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            C2O_ProductBasketTriggerHandler.afterUpdate(Trigger.newMap,Trigger.oldMap);
        }
    }
}