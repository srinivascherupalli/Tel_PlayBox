/****************************************************************************
@Author: Kunal Mannan
@CreateDate: 24/04/2018.
@Description: FunctionalContactRoleTrigger object for Microservices.
@TestCoverageClass: FunctionalContactRoleTriggerTest
@ChangeLog: v1 - Created
			v1.1 - Modified as part of EDGE-25250 story by Nilesh Dethe
********************************************************************************/
trigger FunctionalContactRoleTrigger on Functional_Contact_Role__c (before insert,after update,after insert) {
    
    if(EnvironmentalSettings.isTriggerDisabled('FunctionalContactRoleTrigger')){
        return;
    } 
    
    FunctionalContactRoleTriggerHandler fcr=new FunctionalContactRoleTriggerHandler();
    
    if(Trigger.isafter && Trigger.isinsert){
        fcr.onAfterInsert(Trigger.new,Trigger.newMap);
    }
    if(Trigger.isafter && Trigger.isUpdate){
        fcr.onAfterUpdate(Trigger.new);
    }
    //Start EDGE-25250(AC1)
    if(Trigger.isBefore && Trigger.isInsert){
        //system.debug('Inside before insert FCR');
        fcr.onBeforeInsert(Trigger.new);
    }
    //End 
}