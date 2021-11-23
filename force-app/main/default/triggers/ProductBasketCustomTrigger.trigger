trigger ProductBasketCustomTrigger on cscfga__Product_Basket__c (before insert, before update, before delete, 
                                                           after insert, after update, after delete, after undelete) {
    if(EnvironmentalSettings.isTriggerDisabled('ProductBasketCustomTrigger')) {
        return;
    }
    ProductBasketCustomTriggerHandler handler = new ProductBasketCustomTriggerHandler();

    if(Trigger.isInsert && Trigger.isBefore){
        handler.onBeforeInsert(Trigger.new);
    }
   /*else if(Trigger.isInsert && Trigger.isAfter){
        handler.onAfterInsert(Trigger.new);     
    }*/
    else if(Trigger.isUpdate && Trigger.isBefore){
       handler.onBeforeUpdate(Trigger.oldMap, Trigger.new);
    }
    
    else if(Trigger.isUpdate && Trigger.isAfter){
        //handler.onAfterUpdateTransition(Trigger.oldMap, Trigger.newMap);//EDGE-203022 Kalashree Borgaonkar. 
        handler.onAfterUpdate(Trigger.old,Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    
    /*else if(Trigger.isDelete && Trigger.isBefore){
        //handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){   
        //handler.onAfterDelete(Trigger.old, Trigger.oldMap);       
    }*/
}