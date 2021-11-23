/*************************************************************************************************************************************************
 * Name         :   ProductBasketTrigger  
 * Description  :   Trigger on ProductBasket Object
    
 Sr.No.     Developer Name      Date            Story           Description
    1.      Pooja Bhat          22/09/2020      EDGE-178203     Technical Refactoring - Opportunity Sync - DML Operations
    2.      Gokul/Pooja         01/02/2021      EDGE-192806     In-Flight: Basket to Opportunity line item sync framework enhancements
**************************************************************************************************************************************************/
trigger ProductBasketTrigger on cscfga__Product_Basket__c (after delete, after insert, after update, before delete, before insert, before update) {
    
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

    if(notriggers == null || !notriggers.Flag__c) { 
        if((trigger.isInsert) && (trigger.IsAfter)) {
            ProductBasketTriggerHandler.AfterInsertHandle(trigger.new, trigger.newMap);
        }
        if((trigger.isUpdate) && (trigger.IsAfter) && !StaticUtilForRecursion.checkInflightSync) {  //EDGE-192806: Added Recursion Check
            ProductBasketTriggerHandler.AfterUpdateHandle(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
        }
    }
}