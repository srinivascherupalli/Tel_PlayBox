/******************************************************************************************************
 
    
   Sr.No.      Developer Name          Date            Story           Description
    1.         Jagadeswary            31/3/21          EDGE-209486    Publish new platform event

    2.          Gokul                   14/05/21        EDGE-215986     Post chatter notification based on order status
    3.          Gokul                   12/07/21        DIGI-2150       Commented the Order Generation Event 
**************************************************************************************************/
Trigger OrderTriggerCustom on csord__Order__c (after update) { 
    if (Trigger.size > 0 && Trigger.isAfter && Trigger.isUpdate) { 
        CSPOFA.Events.emit('update', Trigger.newMap.keySet()); 
            OrderCustomTriggerHandler.generateOrderMSEvent(Trigger.new,Trigger.oldMap);
        // EDGE-215986 
        OrderCustomTriggerHandler.postChatterNotification(Trigger.new,Trigger.oldMap);

    } 
}