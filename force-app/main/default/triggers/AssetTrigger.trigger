/*-----------------------------------------------------------------------------------------
EDGE        -87057
Trigger     -AssetTrigger
Author      -Dheeraj Bhatt
---------------------------------------------------------------------------------------------*/
Trigger AssetTrigger on Asset (After Update) {
    if(Trigger.IsAfter && Trigger.IsUpdate){
        AssetTriggerHandler.afterUpdate(Trigger.newMap,Trigger.oldMap);
    }
}