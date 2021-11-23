/********************************************************************************
* Trigger Name  : C2O_NumberTrigger 
* Description : Trigger on Number__c object
* Created By  : Dinesh Sekar
* Change Log  : 09 May 2021 - Created 
********************************************************************************/
trigger C2O_NumberTrigger on Number__c (before insert, before update,after insert, after update) {
	
    new C2O_NumberTriggerHandler().run();
    
}