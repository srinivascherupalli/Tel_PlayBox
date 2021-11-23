/*
===============================================================================================================================
Class : TM1TransactionEventTrigger
Developer Name : Rohit

===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Rohit				   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/


trigger TM1TransactionEventTrigger on TM1TransactionEvent__e (after insert) {    
    String basketId = '';
    system.debug('-------- Inside platform Trigger -------');
    for (TM1TransactionEvent__e tm1 : Trigger.newMap.values()){
    basketId = tm1.basketId__c;
    TM1ResponseEventTriggerHandler.updateFlag(basketId); 
        system.debug('-------- Basket ID from Trigger ------->'+basketId);
    }

}