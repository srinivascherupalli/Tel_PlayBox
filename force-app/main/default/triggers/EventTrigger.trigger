/****************************************************************************
@Name: EventTrigger.
@Author: SFO/ Vamshi
@CreateDate: 09/04/2020
@Sprint : 20.05[P2OB-5475]
@Description: This Trigger is for Event Object - P2OB-5475
*****************************************************************************/
trigger EventTrigger on Event (before insert, 
                             before update,
                             before delete,
                             after insert,
                             after update,
                             after delete){
                                 //Implemeted Trigger framework
                                 fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
                             }