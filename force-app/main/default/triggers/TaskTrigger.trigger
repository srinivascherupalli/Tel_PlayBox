/****************************************************************************
@Name: TaskTrigger.
@Author: SFO/ Vamshi
@CreateDate: 07/04/2020
@Sprint : 20.05[P2OB-5475]
@Description: This Trigger is for Task Object - P2OB-5475
*****************************************************************************/
trigger TaskTrigger on Task (before insert, 
                             before update,
                             before delete,
                             after insert,
                             after update,
                             after delete){
                                 //Implemeted Trigger framework
                                 fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
                             }