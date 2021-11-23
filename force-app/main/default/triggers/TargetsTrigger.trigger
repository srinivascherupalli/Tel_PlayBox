/****************************************************************************
@Name: TargetsTrigger.
@Author: SFO/ Sravanthi
@CreateDate: 14/10/2019.
@Description: This Trigger is for Targets Object - P2OB-3297
********************************************************************************/
trigger TargetsTrigger on Targets__c (before insert, 
                                      before update,
                                      before delete,
                                      after insert,
                                      after update,
                                      after delete){
       //Implemeted Trigger framework 
       fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);

}